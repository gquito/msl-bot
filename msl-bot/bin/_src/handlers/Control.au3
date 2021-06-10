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

            ADB_Command("shell input swipe " & $aPoints[0] & " " & $aPoints[1] & " " & $aPoints[2] & " " & $aPoints[3])
        Case $SWIPE_REAL
            ;clickdrags using real mouse.
            WinActivate($g_hWindow)

            $aPoints[0] = $aPoints[0]/($Config_Display_Scaling/100)
            $aPoints[1] = $aPoints[1]/($Config_Display_Scaling/100)

            Local $aOffset = WinGetPos($g_hControl)
            If isArray($aOffset) = True Then
                MouseClickDrag("left", ($aPoints[0]+$aOffset[0]), ($aPoints[1]+$aOffset[1]), ($aPoints[2]+$aOffset[0]), ($aPoints[3]+$aOffset[1]))
            Else
                Log_Add("Could not find emulator position.", $LOG_ERROR)
            EndIf
        Case $SWIPE_CONTROL
            ControlClickDrag($g_hControl, CreateArr($aPoints[0], $aPoints[1]), $aPoints[2]-$aPoints[0], $aPoints[3]-$aPoints[1], 100)
        EndSwitch
        If _Sleep($iDelay, True) Then Return False
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
    ;$g_bLogEnabled = True ;Debug
    Local $aPoint[2] ;Point array
    Local $bOutput = False

    ;Fixing format to [x, y]
    While True
        If isArray($vPoint) = 0 Then
            If ($vPoint == "" Or $vPoint = -1) Then
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
                    ;WinActivate($hWindow)
                    
                    If $i = 0 Then
                        $aPoint[0] = $aPoint[0]/($Config_Display_Scaling/100)
                        $aPoint[1] = $aPoint[1]/($Config_Display_Scaling/100)

                        Local $t_aDesktopPoint = WinGetPos($hControl)
                        If isArray($t_aDesktopPoint) = True Then
                            $aPoint[0] += $t_aDesktopPoint[0]
                            $aPoint[1] += $t_aDesktopPoint[1]
                        Else
                            Log_Add("Could not find emulator position.", $LOG_ERROR)
                        EndIf
                    EndIf

                    Log_Add("Click point: " & _ArrayToString($aPoint), $LOG_DEBUG)
                    MouseClick("left", $aPoint[0], $aPoint[1], 1, 0)
                Case $MOUSE_CONTROL ;clicks using fake mouse.
                    Log_Add("Click point: " & _ArrayToString($aPoint), $LOG_DEBUG)
                    ControlClick($hWindow, "", $hControl, "left", 1, $aPoint[0]/($Config_Display_Scaling/100), $aPoint[1]/($Config_Display_Scaling/100)) ;For simulated clicks
                Case $MOUSE_ADB
                ;clicks using adb commands
                    Log_Add("Click point: " & _ArrayToString($aPoint), $LOG_DEBUG)
                    ADB_Command("shell input tap " & $aPoint[0] & " " & $aPoint[1])
                Case Else
                    Log_Add("Invalid mouse mode: " & $iMouseMode, $LOG_ERROR)
                    $g_sErrorMessage = "clickPoint() => Invalid mouse mode: " & $iMouseMode
                    ExitLoop(2)
            EndSwitch

            If _Sleep($iInterval, True) Then ExitLoop(2)
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
                If _Sleep($iInterval, True) Then Return -1
            Next
        Case $MOUSE_ADB
            ;Generating click commands for ADB
            Local $sCommand = ';input tap ' & $aPoints[0][0] & " " & $aPoints[0][1]
            For $i = 1 To UBound($aPoints)-1
                $sCommand &= ';input tap ' & $aPoints[$i][0] & " " & $aPoints[$i][1]
            Next
            $sCommand = StringMid($sCommand, 2)
            $sCommand = 'shell ' & $sCommand

            ADB_Command($sCommand)
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

    If isArray($vArg) = False Then $vArg = CreateArr($vArg)
    Local $sPointString = (isArray($aPoint)?_ArrayToString($aPoint, ","):$aPoint)
    Log_Add("Clicking until (" & $sPointString & ") => Function: " & $sBooleanFunction & ", Arguments: " & _ArrayToString($vArg, ";"), $LOG_DEBUG)

    _ArrayInsert($vArg, 0, "CallArgArray")
    Local $bOutput = False

    Local $bLogClicks = $Config_Log_Clicks
    $Config_Log_Clicks = False
    Local $iClicked = 0
    Local $hTimer = TimerInit()
    While ($iClicked < $iAmount)
        If $sExecute <> "" Then Execute($sExecute)
        $bOutput = Call($sBooleanFunction, $vArg)
        If $bOutput > 0 Or (@error Or @extended) Then ExitLoop

        If TimerDiff($hTimer) > $iInterval Then
            $hTimer = TimerInit()
            clickPoint($aPoint, 1, 0, $iMouseMode, $hWindow, $hControl)
            $iClicked += 1
        Else
            If _Sleep(50, True) Then ExitLoop
        EndIf
    WEnd
    $Config_Log_Clicks = $bLogClicks

    Log_Add("Clicking until result: " & ($bOutput<>False) & " (# Clicks: " & $iClicked & ")", $LOG_DEBUG)
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
        $sExecute: Run a line of code before each boolean function check.
        $bRealMouse: Whether to use real mouse or simulated mouse clicks.
        $hWindow: Window handle to send clicks for.
        $hControl: Control handle to send clicks for.
    Return: True if condition is not met and false if maximum clicks exceeds.
#ce
Func clickWhile($aPoint, $sBooleanFunction, $vArg = Null, $iAmount = 5, $iInterval = 500, $sExecute = "", $iMouseMode = $Config_Mouse_Mode, $hWindow = $g_hWindow, $hControl = $g_hControl)
    Log_Level_Add("clickWhile")

    Local $sPointString = (isArray($aPoint)?_ArrayToString($aPoint, ","):$aPoint)
    Log_Add("Clicking while (" & $sPointString & ") => Function: " & $sBooleanFunction & ", Arguments: " & _ArrayToString($vArg, ";"), $LOG_DEBUG)

    _ArrayInsert($vArg, 0, "CallArgArray")
    Local $bOutput = False

    Local $bLogClicks = $Config_Log_Clicks
    $Config_Log_Clicks = False
    Local $iClicked = 0
    Local $hTimer = TimerInit()
    While ($iClicked < $iAmount)
        If $sExecute <> "" Then Execute($sExecute)
        $bOutput = Call($sBooleanFunction, $vArg)
        If $bOutput <= 0 Or (@error Or @extended) Then ExitLoop

        If TimerDiff($hTimer) > $iInterval Then
            $hTimer = TimerInit()
            clickPoint($aPoint, 1, 0, $iMouseMode, $hWindow, $hControl)
            $iClicked += 1
        Else
            If _Sleep(50, True) Then ExitLoop
        EndIf
    WEnd
    $Config_Log_Clicks = $bLogClicks

    Log_Add("Clicking while result: " & ($bOutput=False) & " (# Clicks: " & $iClicked & ")", $LOG_DEBUG)
    Log_Level_Remove()
	Return $bOutput=False
EndFunc

#cs 
    Function: Sends key to emulator.
    Parameters:
        $sKey = Key to send. Look up https://www.autoitscript.com/autoit3/docs/appendix/SendKeys.htm
        $hWindow = Window handle to send keys to.
        $sControlInstance = Control ID or Control instance.
    Returns: True if nothing goes wrong. -1 With error if handle not found.
#ce
Func sendKey($sKey, $hWindow = $g_hWindow, $hControl = $g_hControl)
    Local $iResult = ControlSend($hWindow, "", "", $sKey)
    ControlSend($hControl, "", "", $sKey)

    If ($iResult = 1) Then Return True
    
    $g_sErrorMessage = "sendKey() => Window handle not found."
    Return -1
EndFunc

Func getSendEventArray($aClickPoints, $sSendEvent = $g_sSendEvent)
    Local $aSendEvent = StringSplit(StringFormat($sSendEvent, $aClickPoints[0], $aClickPoints[1]), ",", $STR_NOCOUNT)
    Return $aSendEvent
EndFunc

Func SendBack($iCount = 1, $iSpeed = 50, $iMode = $Config_Back_Mode)
    Log_Level_Add("SendBack")
    Log_Add("Sending back command.", $LOG_DEBUG)
    While $iCount >= 1
        Switch $iMode
            Case $BACK_REAL
                Send("{ESC}")
            Case $BACK_CONTROL
                SendKey("{ESC}")
            Case $BACK_ADB
                ADB_SendESC($iCount)
                ExitLoop
        EndSwitch

        $iCount -= 1
        Sleep($iSpeed)
    WEnd
    Log_Level_Remove()
EndFunc