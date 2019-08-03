#include-once
#include "../imports.au3"

#cs 
    Function: Sends swipes to emulator
    Parameters:
        $aPoints: x1, y1, x2, y2
            - If in $SWIPE_KEYMAP mode, uses "left", "right", "up", "down" using ControlSend
#ce
Func clickDrag($aPoints, $iAmount = 1, $iDelay = $g_iSwipeDelay, $iSwipeMode = $g_iSwipeMode)
    Local $iSwipes = 0
    While $iSwipes < $iAmount
        Switch $iSwipeMode
            Case $SWIPE_KEYMAP
                ;Pre-set-up keymap
                ControlSend($g_hWindow, "", "", "{" & StringUpper($aPoints[4]) & "}")
            Case $SWIPE_ADB
            ;Adb swipe mode
            If (Not(isArray($aPoints))) Then $aPoints = StringSplit($aPoints, ",", $STR_NOCOUNT)

            If (UBound($aPoints) < 4) Then 
                ;handle error
                $g_sErrorMessage = "swipe() => Invalid argument for points."
                Return False
            EndIf

            ;executing swipe
            If $g_sADBMethod = "input event" Then
                ADB_Command("shell input swipe " & $aPoints[0] & " " & $aPoints[1] & " " & $aPoints[2] & " " & $aPoints[3])
            Else
                ADB_Shell("input swipe " & $aPoints[0] & " " & $aPoints[1] & " " & $aPoints[2] & " " & $aPoints[3])
            EndIf
        Case $SWIPE_REAL
            ;clickdrags using real mouse.
            WinActivate($g_hWindow)

            $aPoints[0] = $aPoints[0]/($g_iDisplayScaling/100)
            $aPoints[1] = $aPoints[1]/($g_iDisplayScaling/100)

            Local $aOffset = WinGetPos($g_hControl)
            MouseClickDrag("left", ($aPoints[0]+$aOffset[0]), ($aPoints[1]+$aOffset[1]), ($aPoints[2]+$aOffset[0]), ($aPoints[3]+$aOffset[1]))
        EndSwitch
        If (_Sleep($iDelay)) Then Return False
        $iSwipes += 1
    WEnd
    Return True
EndFunc

#cs
    Function: Clicks point in specified location.
    Parameters:
        $vPoint: Format = [x, y] or "x,y"
        $iAmount: Number of clicks to perform.
        $iInterval: Interval between clicks.
        $bRealMouse: Whether to use real mouse or simulated mouse clicks.
        $hWindow: Window handle to send clicks for.
        $hControl: Control handle to send clicks for.
#ce
Func clickPoint($vPoint, $iAmount = 1, $iInterval = 0, $iMouseMode = $g_iMouseMode, $hWindow = $g_hWindow, $hControl = $g_hControl)
    $g_bLogEnabled = $g_bLogClicks
    Local $aPoint[2] ;Point array
    Local $bOutput = False

    ;Fixing format to [x, y]
    While True
        If (Not(isArray($vPoint))) Then
            If ($vPoint = "" Or $vPoint = -1) Then
                Log_Add("Invalid points: " & $vPoint, $LOG_ERROR)
                $g_sErrorMessage = "clickPoint() => Invalid points."
                ExitLoop
            EndIf

            Local $t_aPoint = StringSplit(StringStripWS($vPoint, $STR_STRIPALL), ",", $STR_NOCOUNT)
            $aPoint[0] = StringStripWS($t_aPoint[0], $STR_STRIPLEADING + $STR_STRIPTRAILING)
            $aPoint[1] = StringStripWS($t_aPoint[1], $STR_STRIPLEADING + $STR_STRIPTRAILING)
        Else
            If (UBound($vPoint) < 2) Then 
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

            Switch $iMouseMode
                Case $MOUSE_REAL ;clicks using real mouse.
                    WinActivate($hWindow)

                    $aNewPoint[0] = $aNewPoint[0]/($g_iDisplayScaling/100)
                    $aNewPoint[1] = $aNewPoint[1]/($g_iDisplayScaling/100)

                    Local $t_aDesktopPoint = WinGetPos($hControl)
                    $aNewPoint[0] += $t_aDesktopPoint[0]
                    $aNewPoint[1] += $t_aDesktopPoint[1]

                    Log_Add("Click point: " & _ArrayToString($aNewPoint), $LOG_DEBUG)
                    MouseClick("left", $aNewPoint[0], $aNewPoint[1], 1, 0)
                Case $MOUSE_CONTROL ;clicks using fake mouse.
                    If ($g_old_hControl <> $hControl) Then
                        $g_old_hControl = $hControl
                        $g_sControlID = "[CLASS:Qt5QWindowIcon; TEXT:ScreenBoardClassWindow]" ;Default for nox
                    EndIf

                    Log_Add("Click point: " & _ArrayToString($aNewPoint), $LOG_DEBUG)
                    ControlClick($hWindow, "", $g_sControlID, "left", 1, $aNewPoint[0]/($g_iDisplayScaling/100), $aNewPoint[1]/($g_iDisplayScaling/100)) ;For simulated clicks
                Case $MOUSE_ADB
                ;clicks using adb commands
                    Log_Add("Click point: " & _ArrayToString($aNewPoint), $LOG_DEBUG)
                    ADB_Command("shell input tap " & $aNewPoint[0] & " " & $aNewPoint[1])
                Case Else
                    Log_Add("Invalid mouse mode: " & $iMouseMode, $LOG_ERROR)
                    $g_sErrorMessage = "clickPoint() => Invalid mouse mode: " & $iMouseMode
                    ExitLoop(2)
            EndSwitch

            If _Sleep($iInterval) Then ExitLoop(2)
        Next

        $bOutput = True
        ExitLoop
    WEnd
    
    $g_bLogEnabled = True
    Return $bOutput
EndFunc

Func clickMultiple($aPoints, $iInterval = 0, $iMouseMode = $g_iMouseMode, $hWindow = $g_hWindow, $hControl = $g_hControl)
    ;Must have format [[x, y, count, delay], [x1, y1, count1, delay1], [x2, y2, count2, delay2]]
    If (Not(isArray($aPoints))) Then
        Log_Add("clickMultiple() => Invalid format.", $LOG_ERROR)
        Return -1
    Else
        If (UBound($aPoints, 2) <> 4) Then 
            Log_Add("clickMultiple() => Invalid format.", $LOG_ERROR)
            Return -2
        EndIf
    EndIf

    Switch $iMouseMode
        Case $MOUSE_REAL, $MOUSE_CONTROL
            For $i = 0 To UBound($aPoints)-1
                clickPoint($aPoints[$i][0] & "," & $aPoints[$i][1], $aPoints[$i][2], $aPoints[$i][3], $iMouseMode, $hWindow, $hControl)
                If _Sleep($iInterval) Then Return -1
            Next
        Case $MOUSE_ADB
            ;Generating click commands for ADB
            Local $sCommand = ""
            For $i = 0 To UBound($aPoints)-1
                For $iCount = 0 To $aPoints[$i][2]-1
                    If ($g_sADBMethod = "sendevent") Then
                        Local $aTCV = getSendEventArray($aPoints[$i])
                        $sCommand &= @CRLF & ADB_ConvertEvent($g_sADBEvent, $aTCV)

                        If $aPoints[$i][3] <> 0 Then
                            $sCommand &= @CRLF & "sleep " & $aPoints[$i][3]/1000
                        EndIf
                    Else
                        $sCommand &= @CRLF & "input tap " & $aPoints[$i][0] & " " & $aPoints[$i][1]
                        
                        If $aPoints[$i][3] <> 0 Then
                            $sCommand &= @CRLF & "sleep " & $aPoints[$i][3]/1000
                        EndIf
                    EndIf
                Next

                If $iInterval <> 0 Then
                    $sCommand &= @CRLF & "sleep " & $iInterval/1000
                EndIf
            Next
            $sCommand = StringMid($sCommand, 2)
            ADB_Shell($sCommand, $g_iADB_Timeout, True, True)
    EndSwitch
EndFunc

#cs
    Function: Clicks for a number of times until a condition is true
    Parameters:
        $aPoint: Format = [x, y] or "x,y"
        $sBooleanFunction: Function name.
        $vArg: Function arguments. Format = [arg1, arg2] or "arg1,arg2"
        $iAmount: Number of clicks to perform.
        $iInterval: Interval between clicks.
        $sExecute: Run a line of code before each boolean function check.
        $bRealMouse: Whether to use real mouse or simulated mouse clicks.
        $hWindow: Window handle to send clicks for.
        $hControl: Control handle to send clicks for.
    Return: True if condition was met and false if maximum clicks exceeds.
#ce
Func clickUntil($aPoint, $sBooleanFunction, $vArg = Null, $iAmount = 5, $iInterval = 500, $sExecute = "", $iMouseMode = $g_iMouseMode, $hWindow = $g_hWindow, $hControl = $g_hControl)
	$g_bLogEnabled = $g_bLogClicks
    Log_Level_Add("clickUntil")

    Local $bOutput = False
    Local $aArg = parseVArg($vArg)

    If (Not(isArray($aPoint))) Then $aPoint = StringSplit(StringStripWS($aPoint, $STR_STRIPALL), ",", $STR_NOCOUNT)

    Log_Add("Clicking until (" & _ArrayToString($aPoint) & ") => Function: " & $sBooleanFunction & ", Arguments: " & _ArrayToString($aArg, ";"), $LOG_DEBUG)

    Local $bResult = False
    If $aArg = Null Then
        $bResult = Call($sBooleanFunction)
    Else
        $bResult = Call($sBooleanFunction, $aArg)
    EndIf
    If $bResult = True Then
        $bOutput = True
        Log_Add("Clicking until result: " & $bOutput & " (# Clicks: 0)", $LOG_DEBUG)
        Log_Level_Remove()
        Return $bOutput
    EndIf

    Local $t_bLogClicks = $g_bLogClicks
    $g_bLogClicks = False
    For $i = 1 To $iAmount
        Local $t_vTimerStart = TimerInit()
        clickPoint($aPoint, 1, 0, $iMouseMode, $hWindow, $hControl)

        While TimerDiff($t_vTimerStart) < $iInterval
            If (_Sleep(100)) Then ExitLoop(2)

            If $sExecute <> "" Then Execute($sExecute)
            If $aArg = Null Then
                $bResult = Call($sBooleanFunction)
            Else
                $bResult = Call($sBooleanFunction, $aArg)
            EndIf
            If $bResult = True Then
                $bOutput = True
                ExitLoop(2)
            EndIf
        WEnd
    Next
    $g_bLogClicks = $t_bLogClicks

    Log_Add("Clicking until result: " & $bOutput & " (# Clicks: " & $i & ")", $LOG_DEBUG)
    Log_Level_Remove()
	Return $bOutput
EndFunc

Func parseVArg($vArg)
    If isArray($vArg) = True Then
        If $vArg[0] <> "CallArgArray" Then
            _ArrayInsert($vArg, 0, "CallArgArray")
        EndIf
        Return $vArg
    EndIf
    If $vArg = Null Then Return $vArg

    Local $t_sStartChar, $t_sIdChar, $t_sArg
    Local $t_aArg = ["CallArgArray"]
    $t_sStartChar = StringLeft($vArg, 1)
    $t_sIdChar = StringMid($vArg, 1, 1)
    $t_sArg = StringMid($vArg, 2)
    Switch $t_sStartChar
        Case "$"
            Local $aRaw[1];
            $aRaw[0] = $t_sArg
            $t_aArg = $aRaw
        Case "%"
            CaptureRegion()
            Switch $t_sIdChar
                Case "!" ;point
                    _ArrayAdd($t_aArg, getPointArg($t_sArg), 0, null, null, 1)
                Case "@" ;Location
                    _ArrayAdd($t_aArg, getLocationArg($t_sArg), 0, null, null, 1)
                Case "^" ;Treat as pixels
                    _ArrayAdd($t_aArg, getPixelArg($t_sArg), 0, null, null, 1)
                Case Else ;Treat as pixels
                    ;$t_sArg = StringMid($vArg,1)
                    _ArrayAdd($t_aArg, getPixelArg($t_sArg), 0, null, null, 1)
            EndSwitch
        Case Else
            $t_aArg = StringSplit($vArg, ",", $STR_NOCOUNT)
    EndSwitch
    ;_ArrayDisplay($t_aArg)
    Return $t_aArg
EndFunc

#cs
    Function: Clicks for a number of times while a condition is true
    Parameters:
        $aPoint: Format = [x, y] or "x,y"
        $sBooleanFunction: Function name.
        $vArg: Function arguments. Format = [arg1, arg2] or "arg1,arg2"
        $iAmount: Number of clicks to perform.
        $iInterval: Interval between clicks.
        $sExecute: Run a line of code before each boolean function check.
        $bRealMouse: Whether to use real mouse or simulated mouse clicks.
        $hWindow: Window handle to send clicks for.
        $hControl: Control handle to send clicks for.
    Return: True if condition is not met and false if maximum clicks exceeds.
#ce
Func clickWhile($aPoint, $sBooleanFunction, $vArg = Null, $iAmount = 5, $iInterval = 500, $sExecute = "", $iMouseMode = $g_iMouseMode, $hWindow = $g_hWindow, $hControl = $g_hControl)
	$g_bLogEnabled = $g_bLogClicks
    Log_Level_Add("clickWhile")

    Local $bOutput = False
    Local $aArg = parseVArg($vArg)

    If (Not(isArray($aPoint))) Then $aPoint = StringSplit(StringStripWS($aPoint, $STR_STRIPALL), ",", $STR_NOCOUNT)

    Log_Add("Clicking while (" & _ArrayToString($aPoint) & ") => Function: " & $sBooleanFunction & ", Arguments: " & _ArrayToString($aArg, ";"), $LOG_DEBUG)

    Local $bResult = False
    If $aArg = Null Then
        $bResult = Call($sBooleanFunction)
    Else
        $bResult = Call($sBooleanFunction, $aArg)
    EndIf
    If $bResult = False Then 
        $bOutput = True
        Log_Add("Clicking while result: " & $bOutput & " (# Clicks: 0)", $LOG_DEBUG)
        Log_Level_Remove()
        Return $bOutput
    EndIf

    Local $t_bLogClicks = $g_bLogClicks
    $g_bLogClicks = False
    For $i = 1 To $iAmount
        Local $t_vTimerStart = TimerInit()
        clickPoint($aPoint, 1, 0, $iMouseMode, $hWindow, $hControl)

        While TimerDiff($t_vTimerStart) < $iInterval
            If (_Sleep(100)) Then ExitLoop(2)

            If $sExecute <> "" Then Execute($sExecute)

            If $aArg = Null Then
                $bResult = Call($sBooleanFunction)
            Else
                $bResult = Call($sBooleanFunction, $aArg)
            EndIf
            If $bResult = False Then 
                $bOutput = True
                ExitLoop(2)
            EndIf
        WEnd
    Next
    $g_bLogClicks = $t_bLogClicks

    Log_Add("Clicking while result: " & $bOutput & " (# Clicks: " & $i & ")", $LOG_DEBUG)
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

    If ($iResult = 1) Then Return True
    
    $g_sErrorMessage = "sendKey() => Window handle not found."
    Return -1
EndFunc

Func getSendEventArray($aClickPoints, $sSendEvent = $g_sSendEvent)
    Local $aSendEvent = StringSplit(StringFormat($sSendEvent, $aClickPoints[0], $aClickPoints[1]), ",", $STR_NOCOUNT)
    Return $aSendEvent
EndFunc

Func SetupKeymap()
	Log_Add("Right click the keymap icon...")
	While _IsPressed(02) = False
		If (_Sleep(10)) Then Return -1
	WEnd

	;Left keymap
	Log_Add("Setting up left keymap...")
	Local $initialPos = MouseGetPos()

	MouseClickDrag("Left", $initialPos[0]-224, $initialPos[1]+202, $initialPos[0]-495, $initialPos[1]+341, 10)
	Send("{LEFT}")

	;Right keymap
	Log_Add("Setting up right keymap...")

	MouseClickDrag("Left", $initialPos[0]-620, $initialPos[1]+306, $initialPos[0]-483, $initialPos[1]+206, 10)
	Send("{RIGHT}")

	;Up keymap
	Log_Add("Setting up up keymap...")

	MouseClickDrag("Left", $initialPos[0]-386, $initialPos[1]+313, $initialPos[0]-386, $initialPos[1]+241, 10)
	Send("{UP}")
	MouseClickDrag("Left", $initialPos[0]-386, $initialPos[1]+241, $initialPos[0]-600, $initialPos[1]+241, 10)

	;Down keymap
	Log_Add("Setting up down keymap...")

	MouseClickDrag("Left", $initialPos[0]-386, $initialPos[1]+241, $initialPos[0]-386, $initialPos[1]+313, 10)
	Send("{DOWN}")

	Log_Add("Setup complete.")
EndFunc