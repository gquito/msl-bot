#include-once

#cs 
    Function: Sends swipes to emulator
    Parameters:
        $aPoints: x1, y1, x2, y2
            - If in $SWIPE_KEYMAP mode, uses "left", "right", "up", "down" using ControlSend
#ce
Func clickDrag($aPoints, $iAmount = 1, $iDelay = $Delay_Swipe_Delay, $iSwipeMode = $Config_Swipe_Mode)
    Local $iSwipes = 0
    While $iSwipes < $iAmount
        Switch $iSwipeMode
            Case $SWIPE_ADB
            ;Adb swipe mode
            If (Not(isArray($aPoints))) Then $aPoints = StringSplit($aPoints, ",", $STR_NOCOUNT)

            If (UBound($aPoints) < 4) Then 
                ;handle error
                $g_sErrorMessage = "swipe() => Invalid argument for points."
                Return False
            EndIf

            ;executing swipe
            If $Config_ADB_Method = "input event" Then
                ADB_Command("shell input swipe " & $aPoints[0] & " " & $aPoints[1] & " " & $aPoints[2] & " " & $aPoints[3])
            Else
                ADB_Shell("input swipe " & $aPoints[0] & " " & $aPoints[1] & " " & $aPoints[2] & " " & $aPoints[3])
            EndIf
        Case $SWIPE_REAL
            ;clickdrags using real mouse.
            WinActivate($g_hWindow)

            $aPoints[0] = $aPoints[0]/($Config_Display_Scaling/100)
            $aPoints[1] = $aPoints[1]/($Config_Display_Scaling/100)

            Local $aOffset = WinGetPos($g_hControl)
            MouseClickDrag("left", ($aPoints[0]+$aOffset[0]), ($aPoints[1]+$aOffset[1]), ($aPoints[2]+$aOffset[0]), ($aPoints[3]+$aOffset[1]))
        Case $SWIPE_CONTROL
            ControlClickDrag($g_hControl, CreateArr($aPoints[0], $aPoints[1]), $aPoints[2]-$aPoints[0], $aPoints[3]-$aPoints[1], 100)
        EndSwitch
        If (_Sleep($iDelay)) Then Return False
        $iSwipes += 1
    WEnd
    Return True
EndFunc

Func ControlClickDrag($hWnd, $point, $x_offset, $y_offset, $time)
    _WinAPI_PostMessage($hWnd, $WM_LBUTTONDOWN, 0x01, _GetPos($point[0], $point[1]))
    Local $x = $point[0]
    Local $y = $point[1]
    For $i = 1 To $time*4
        $x += $x_offset/($time*4)
        $y += $y_offset/($time*4)
        _HighPrecisionSleep(250)
        If Mod($i, 4) = 0 And (Floor($x) <> $point[0] Or Floor($y) <> $point[1]) Then
            $point[0] = Floor($x)
            $point[1] = Floor($y)
            _WinAPI_PostMessage($hWnd, $WM_MOUSEMOVE, 0x01, _GetPos(Floor($x), Floor($y)))
        EndIf
    Next
    _WinAPI_PostMessage($hWnd, $WM_LBUTTONUP, 0x00, _GetPos($point[0]+$x_offset, $point[1]+$y_offset))
EndFunc

Func _GetPos($x, $y)
    Return BitOR($y * 0x10000, BitAND($x, 0xFFFF))
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
Func clickPoint($vPoint, $iAmount = 1, $iInterval = 0, $iMouseMode = $Config_Mouse_Mode, $hWindow = $g_hWindow, $hControl = $g_hControl)
    Local $bLog = $g_bLogEnabled
    If $g_bLogEnabled <> False Then $g_bLogEnabled = $Config_Log_Clicks
    Local $aPoint[2] ;Point array
    Local $bOutput = False

    ;Fixing format to [x, y]
    While True
        If isArray($vPoint) = False Then
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
        For $i = 0 To $iAmount-1
            Switch $iMouseMode
                Case $MOUSE_REAL ;clicks using real mouse.
                    WinActivate($hWindow)

                    $aPoint[0] = $aPoint[0]/($Config_Display_Scaling/100)
                    $aPoint[1] = $aPoint[1]/($Config_Display_Scaling/100)

                    Local $t_aDesktopPoint = WinGetPos($hControl)
                    $aPoint[0] += $t_aDesktopPoint[0]
                    $aPoint[1] += $t_aDesktopPoint[1]

                    Log_Add("Click point: " & _ArrayToString($aPoint), $LOG_DEBUG)
                    MouseClick("left", $aPoint[0], $aPoint[1], 1, 0)
                Case $MOUSE_CONTROL ;clicks using fake mouse.
                    Log_Add("Click point: " & _ArrayToString($aPoint), $LOG_DEBUG)
                    ControlClick($hWindow, "", $Config_Emulator_Property, "left", 1, $aPoint[0]/($Config_Display_Scaling/100), $aPoint[1]/($Config_Display_Scaling/100)) ;For simulated clicks
                Case $MOUSE_ADB
                ;clicks using adb commands
                    Log_Add("Click point: " & _ArrayToString($aPoint), $LOG_DEBUG)
                    ADB_Command("shell input tap " & $aPoint[0] & " " & $aPoint[1])
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
    
    $g_bLogEnabled = $bLog
    Return $bOutput
EndFunc

Func clickMultiple($aPoints, $iInterval = 0, $iMouseMode = $Config_Mouse_Mode, $hWindow = $g_hWindow, $hControl = $g_hControl)
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
                    If ($Config_ADB_Method = "sendevent") Then
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

            ADB_Shell($sCommand, $Delay_ADB_Timeout, True, True)
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
Func clickUntil($aPoint, $sBooleanFunction, $vArg = Null, $iAmount = 5, $iInterval = 500, $sExecute = "", $iMouseMode = $Config_Mouse_Mode, $hWindow = $g_hWindow, $hControl = $g_hControl)
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

    Local $t_bLogClicks = $Config_Log_Clicks
    $Config_Log_Clicks = False
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
    $Config_Log_Clicks = $t_bLogClicks

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
Func clickWhile($aPoint, $sBooleanFunction, $vArg = Null, $iAmount = 5, $iInterval = 500, $sExecute = "", $iMouseMode = $Config_Mouse_Mode, $hWindow = $g_hWindow, $hControl = $g_hControl)
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

    Local $t_bLogClicks = $Config_Log_Clicks
    $Config_Log_Clicks = False
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
    $Config_Log_Clicks = $t_bLogClicks

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
Func sendKey($sKey, $hWindow = $g_hWindow, $sControlInstance = $Config_Emulator_Property)
    Local $iResult = ControlSend($hWindow, "", $sControlInstance, $sKey)

    If ($iResult = 1) Then Return True
    
    $g_sErrorMessage = "sendKey() => Window handle not found."
    Return -1
EndFunc

Func getSendEventArray($aClickPoints, $sSendEvent = $g_sSendEvent)
    Local $aSendEvent = StringSplit(StringFormat($sSendEvent, $aClickPoints[0], $aClickPoints[1]), ",", $STR_NOCOUNT)
    Return $aSendEvent
EndFunc