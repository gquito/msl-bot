#include-once
#include "../imports.au3"

#cs 
    Function: Sends swipes to emulator
    Parameters:
        $aPoints: x1, y1, x2, y2
            - If in $SWIPE_KEYMAP mode, uses "left", "right", "up", "down" using ControlSend
#ce
Func clickDrag($aPoints, $iSwipeMode = $g_iSwipeMode)
    If $iSwipeMode = $SWIPE_KEYMAP Then
        ;Pre-set-up keymap
        ControlSend($g_hWindow, "", "", "{" & StringUpper($aPoints[4]) & "}")
    ElseIf $iSwipeMode = $SWIPE_ADB Then
        ;Adb swipe mode
        If isArray($aPoints) = False Then
            $aPoints = StringSplit($aPoints, ",", $STR_NOCOUNT)
        EndIf

        If UBound($aPoints) < 4 Then 
          ;handle error
            $g_sErrorMessage = "swipe() => Invalid argument for points."
           Return -1
        EndIf

        ;executing swipe
        adbCommand("shell input swipe " & $aPoints[0] & " " & $aPoints[1] & " " & $aPoints[2] & " " & $aPoints[3])
    ElseIf $iSwipeMode = $SWIPE_REAL Then
        ;clickdrags using real mouse.
        WinActivate($g_hWindow)

        $aPoints[0] = $aPoints[0]/($g_iDesktopScaling/100)
        $aPoints[1] = $aPoints[1]/($g_iDesktopScaling/100)

        Local $aOffset = WinGetPos($g_hControl)
        MouseClickDrag("left", ($aPoints[0]+$aOffset[0]), ($aPoints[1]+$aOffset[1]), ($aPoints[2]+$aOffset[0]), ($aPoints[3]+$aOffset[1]))
    EndIf
EndFunc

#cs
    Function: Clicks point in specified location.
    Parameters:
        $vPoint: Format = [x, y] or "x,y"
        $iAmount: Number of clicks to perform.
        $iInterval: Interval between clicks.
        $vRandom: Format = [min, max] offset in pixel.
        $bRealMouse: Whether to use real mouse or simulated mouse clicks.
        $hWindow: Window handle to send clicks for.
        $hControl: Control handle to send clicks for.
#ce
Func clickPoint($vPoint, $iAmount = 1, $iInterval = 0, $vRandom = $g_aRandomClicks, $iMouseMode = $g_iMouseMode, $hWindow = $g_hWindow, $hControl = $g_hControl)
    $g_bLogEnabled = $g_bLogClicks
    Log_Level_Add("clickPoint")
    Local $aPoint[2] ;Point array
    Local $bOutput = False

    ;Fixing format to [x, y]
    While True
        If isArray($vPoint) = False Then
            If $vPoint = "" Or $vPoint = -1 Then
                Log_Add("Invalid points: " & $vPoint, $LOG_ERROR)
                $g_sErrorMessage = "clickPoint() => Invalid points."
                ExitLoop
            EndIf

            Local $t_aPoint = StringSplit(StringStripWS($vPoint, $STR_STRIPALL), ",", $STR_NOCOUNT)
            $aPoint[0] = StringStripWS($t_aPoint[0], $STR_STRIPLEADING + $STR_STRIPTRAILING)
            $aPoint[1] = StringStripWS($t_aPoint[1], $STR_STRIPLEADING + $STR_STRIPTRAILING)
        Else
            If UBound($vPoint) < 2 Then 
                Log_Add("Invalid points: " & _ArrayToString($vPoint), $LOG_ERROR)
                $g_sErrorMessage = "clickPoint() => Invalid points."
                ExitLoop
            EndIf
            
            $aPoint[0] = $vPoint[0]
            $aPoint[1] = $vPoint[1]
        EndIf

        ;Processing clicks
        Local Const $RDM_RETURN_INT = 1
        For $i = 0 To $iAmount-1
            Local $aNewPoint = [$aPoint[0], $aPoint[1]]

            ;Random variation setup
            If isArray($vRandom) = True And ($g_iDesktopScaling = 100) Then
                $aNewPoint[0] += Random($vRandom[0], $vRandom[1], $RDM_RETURN_INT)
                $aNewPoint[1] += Random($vRandom[0], $vRandom[1], $RDM_RETURN_INT)
            EndIf

            ;Actual clicks
            If $iMouseMode = $MOUSE_REAL Then
                ;clicks using real mouse.
                WinActivate($hWindow)

                $aNewPoint[0] = $aNewPoint[0]/($g_iDesktopScaling/100)
                $aNewPoint[1] = $aNewPoint[1]/($g_iDesktopScaling/100)

                Local $t_aDesktopPoint = WinGetPos($hControl)
                $aNewPoint[0] += $t_aDesktopPoint[0]
                $aNewPoint[1] += $t_aDesktopPoint[1]

                Log_Add("Click point: " & _ArrayToString($aNewPoint), $LOG_DEBUG)
                MouseClick("left", $aNewPoint[0], $aNewPoint[1], 1, 0)
            ElseIf $iMouseMode = $MOUSE_CONTROL Then
                ;clicks using fake mouse.
                If isDeclared("old_hControl") = False Then
                    Global $old_hControl = $hControl
                    
                    Local $t_aOffset = ControlGetPos("", "", $hControl) ;Actual control position from window.
                    Global $sControlID = ""
                    If isArray($t_aOffset) = True Then
                        $sControlID = "[X: " & $t_aOffset[0] & "; " & "Y:" & $t_aOffset[1] & "]" ;Used to correctly send click to correct control.
                    Else
                        $sControlID = "[CLASS:Qt5QWindowIcon; TEXT:QWidgetClassWindow]" ;Default for nox
                    EndIf
                Else
                    If $old_hControl <> $hControl Then
                        $old_hControl = $hControl

                        Local $t_aOffset = ControlGetPos("", "", $hControl)
                        If isArray($t_aOffset) = True Then
                            $sControlID = "[X: " & $t_aOffset[0] & "; " & "Y:" & $t_aOffset[1] & "]" ;Used to correctly send click to correct control.
                        Else
                            $sControlID = "[CLASS:Qt5QWindowIcon; TEXT:QWidgetClassWindow]" ;Default for nox
                        EndIf
                    EndIf
                EndIf

                Log_Add("Click point: " & _ArrayToString($aNewPoint), $LOG_DEBUG)
                ControlClick($hWindow, "", $sControlID, "left", 1, $aNewPoint[0]/($g_iDesktopScaling/100), $aNewPoint[1]/($g_iDesktopScaling/100)) ;For simulated clicks
            ElseIf $iMouseMode = $MOUSE_ADB Then
                ;clicks using adb commands
                Log_Add("Click point: " & _ArrayToString($aNewPoint), $LOG_DEBUG)
                If $g_sAdbMethod = "input event" Then
                    adbCommand("shell input tap " & $aNewPoint[0] & " " & $aNewPoint[1])
                Else
                    If isDeclared("sEvent") = 0 Then
                        Global $g_sEvent = getEvent()
                    EndIf
                    Local $aTCV = ["0 0 0", "1 330 1", "3 58 1", "3 53 " & $aNewPoint[0], "3 54 " & $aNewPoint[1], "0 2 0", "0 0 0", "0 2 0", "0 0 0", "1 330 0", "3 58 0", "3 53 0", "3 54 32", "0 2 0", "0 0 0"]
                    adbCommand("shell " & sendEvent($g_sEvent, $aTCV))
                EndIf
            Else
                Log_Add("Invalid mouse mode: " & $iMouseMode, $LOG_ERROR)
                $g_sErrorMessage = "clickPoint() => Invalid mouse mode: " & $iMouseMode
                ExitLoop(2)
            EndIf

            If _Sleep($iInterval) Then ExitLoop(2)
        Next

        $bOutput = True
        ExitLoop
    WEnd
    
    $g_bLogEnabled = True
    Log_Level_Remove()
    Return $bOutput
EndFunc

#cs
    Function: Clicks for a number of times until a condition is true
    Parameters:
        $aPoint: Format = [x, y] or "x,y"
        $sBooleanFunction: Function name.
        $vArg: Function arguments. Format = [arg1, arg2] or "arg1,arg2"
        $iAmount: Number of clicks to perform.
        $iInterval: Interval between clicks.
        $vRandomized: Format = [min, max] offset in pixel.
        $bRealMouse: Whether to use real mouse or simulated mouse clicks.
        $hWindow: Window handle to send clicks for.
        $hControl: Control handle to send clicks for.
    Return: True if condition was met and false if maximum clicks exceeds.
#ce
Func clickUntil($aPoint, $sBooleanFunction, $vArg = Null, $iAmount = 5, $iInterval = 500, $vRandom = Null, $iMouseMode = $g_iMouseMode, $hWindow = $g_hWindow, $hControl = $g_hControl)
	$g_bLogEnabled = $g_bLogClicks
    Log_Level_Add("clickUntil")

    Local $bOutput = False
    While True
        Local $aArg[0] ;Function arguments

        ;Fix format to array: [arg1, arg2, ...]
        If isArray($vArg) = False And $vArg <> Null Then
            If StringLeft($vArg, 1) = "$" Then
                Local $aRaw[1];
                $aRaw[0] = StringMid($vArg, 2)
                $aArg = $aRaw
            Else
                $aArg = StringSplit($vArg, ",", $STR_NOCOUNT)
            EndIf
        Else   
            $aArg = $vArg
        EndIf

        If isArray($aPoint) = False Then $aPoint = StringSplit(StringStripWS($aPoint, $STR_STRIPALL), ",", $STR_NOCOUNT)
        Log_Add("Clicking until (" & _ArrayToString($aPoint) & ") => Function: " & $sBooleanFunction & ", Arguments: " & _ArrayToString($aArg) & ", Randomized: " & _ArrayToString($vRandom), $LOG_DEBUG) 
        Local $iClicks = 0
        Local $t_bLogClicks = $g_bLogClicks
        $g_bLogClicks = False
        For $i = 0 To $iAmount-1
            Local $t_vTimerStart = TimerInit()
            While TimerDiff($t_vTimerStart) < $iInterval
                If _Sleep(100) Then ExitLoop(2)
                If Call($sBooleanFunction, $aArg) = True Then 
                    $bOutput = True
                    ExitLoop(2)
                EndIf
            WEnd

            $iClicks += 1
            clickPoint($aPoint, 1, 0, $vRandom, $iMouseMode, $hWindow, $hControl)
        Next
        $g_bLogClicks = $t_bLogClicks
        
        ExitLoop
    WEnd

    $g_bLogEnabled = $g_bLogClicks
    Log_Add("Clicking until result: " & $bOutput & " (# Clicks: " & $iClicks & ")", $LOG_DEBUG)
    $g_bLogEnabled = True
    Log_Level_Remove()
	Return $bOutput
EndFunc

#cs
    Function: Clicks for a number of times while a condition is true
    Parameters:
        $aPoint: Format = [x, y] or "x,y"
        $sBooleanFunction: Function name.
        $vArg: Function arguments. Format = [arg1, arg2] or "arg1,arg2"
        $iAmount: Number of clicks to perform.
        $iInterval: Interval between clicks.
        $vRandomized: Format = [min, max] offset in pixel.
        $bRealMouse: Whether to use real mouse or simulated mouse clicks.
        $hWindow: Window handle to send clicks for.
        $hControl: Control handle to send clicks for.
    Return: True if condition is not met and false if maximum clicks exceeds.
#ce
Func clickWhile($aPoint, $sBooleanFunction, $vArg = Null, $iAmount = 5, $iInterval = 500, $vRandom = Null, $iMouseMode = $g_iMouseMode, $hWindow = $g_hWindow, $hControl = $g_hControl)
	$g_bLogEnabled = $g_bLogClicks
    Log_Level_Add("clickWhile")

    Local $bOutput = False
    While True
        Local $aArg[0] ;Function arguments

        ;Fix format to array: [arg1, arg2, ...]
        If isArray($vArg) = False And $vArg <> Null Then
            $aArg = StringSplit($vArg, ",", $STR_NOCOUNT)
        Else   
            $aArg = $vArg
        EndIf

        If isArray($aPoint) = False Then $aPoint = StringSplit(StringStripWS($aPoint, $STR_STRIPALL), ",", $STR_NOCOUNT)
        Log_Add("Clicking while (" & _ArrayToString($aPoint) & ") => Function: " & $sBooleanFunction & ", Arguments: " & _ArrayToString($aArg) & ", Randomized: " & _ArrayToString($vRandom), $LOG_DEBUG)
        Local $iClicks = 0
        Local $t_bLogClicks = $g_bLogClicks
        $g_bLogClicks = False
        For $i = 0 To $iAmount-1
            Local $t_vTimerStart = TimerInit()
            While TimerDiff($t_vTimerStart) < $iInterval
                If _Sleep(100) Then ExitLoop(2)
                If Call($sBooleanFunction, $aArg) = False Then 
                    $bOutput = True
                    ExitLoop(2)
                EndIf
            WEnd

            $iClicks += 1
            clickPoint($aPoint, 1, 0, $vRandom, $iMouseMode, $hWindow, $hControl)
        Next
        $g_bLogClicks = $t_bLogClicks
        
        ExitLoop
    WEnd

    $g_bLogEnabled = $g_bLogClicks
    Log_Add("Clicking while result: " & $bOutput & " (# Clicks: " & $iClicks & ")", $LOG_DEBUG)
    $g_bLogEnabled = True
    Log_Level_Remove()
	Return $bOutput
EndFunc

#cs 
    Function: Sends key to emulator.
    Parameters:
        $sKey = Key to send. Look up https://www.autoitscript.com/autoit3/docs/appendix/SendKeys.htm
        $hWindow = Window handle to send keys to.
        $sControlInstance = Control ID or Control instance.
    Returns: True if nothing goes wrong. -1 With error if handle not found.
#ce
Func sendKey($sKey, $hWindow = $g_hWindow, $sControlInstance = $g_sControlInstance)
    Local $iResult = ControlSend($hWindow, "", $sControlInstance, $sKey)

    If $iResult = 1 Then
        Return True
    Else
        $g_sErrorMessage = "sendKey() => Window handle not found."
        Return -1
    EndIf
EndFunc
