#include-once
#include "../imports.au3"

#cs 
    Function: Sends command to Android Debug Bridge and returns output
    Parameters:
        $sCommand: Command to send
        $sAdbDevice: If more than one device, device is needed.
        $sAdbPath: ADB executable path.
    Returns: Output after command has been executed.
#ce
Func adbCommand($sCommand, $sAdbDevice = $g_sAdbDevice, $sAdbPath = $g_sAdbPath)
    Local $iPID = Run('"' & $sAdbPath & '"' & " -s " & $sAdbDevice & " " & $sCommand, "", @SW_HIDE, $STDERR_MERGED)

    Local $sResult = ""
    While 1
        $sResult &= StdoutRead($iPID)
        If @error Or (ProcessExists($iPID) = False) Then ExitLoop
    WEnd
    StdioClose($iPID)

    Return $sResult
EndFunc

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

        Local $aOffset = WinGetPos($g_hControl)
        MouseClickDrag("left", $aPoints[0]+$aOffset[0], $aPoints[1]+$aOffset[1], $aPoints[2]+$aOffset[0], $aPoints[3]+$aOffset[1])
    EndIf
EndFunc

#cs
    Function: Clicks point in specified location.
    Parameters:
        $vPoint: Format = [x, y] or "x,y"
        $iAmount: Number of clicks to perform.
        $iInterval: Interval between clicks.
        $vRandomized: Format = [min, max] offset in pixel.
        $bRealMouse: Whether to use real mouse or simulated mouse clicks.
        $hWindow: Window handle to send clicks for.
        $hControl: Control handle to send clicks for.
#ce
Func clickPoint($vPoint, $iAmount = 1, $iInterval = 0, $vRandom = $g_aRandomClicks, $iMouseMode = $g_iMouseMode, $hWindow = $g_hWindow, $hControl = $g_hControl)
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

            Local $t_aPoint = StringSplit($vPoint, ",", $STR_NOCOUNT)
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
            If isArray($vRandom) = True Then
                $aNewPoint[0] += Random($vRandom[0], $vRandom[1], $RDM_RETURN_INT)
                $aNewPoint[1] += Random($vRandom[0], $vRandom[1], $RDM_RETURN_INT)
            EndIf

            ;Actual clicks
            If $iMouseMode = $MOUSE_REAL Then
                ;clicks using real mouse.
                WinActivate($hWindow)

                Local $t_aDesktopPoint = WinGetPos($hControl)
                $aNewPoint[0] += $t_aDesktopPoint[0]
                $aNewPoint[1] += $t_aDesktopPoint[1]

                Log_Add("Click point: " & _ArrayToString($aNewPoint), $LOG_DEBUG)
                MouseClick("left", $aNewPoint[0], $aNewPoint[1], 1, 0)
            ElseIf $iMouseMode = $MOUSE_CONTROL Then
                ;clicks using fake mouse.
                Local $t_aOffset = ControlGetPos("", "", $hControl)
                If isArray($t_aOffset) = True Then
                    If ($t_aOffset[0] = 0) And ($t_aOffset[1] = 0) Then
                        If ($t_aOffset[2] <> $g_aControlSize[0]) Or ($t_aOffset[3] <> $g_aControlSize[1]) Then
                            ;Using default Nox offsets
                            Local $iPID = WinGetProcess($g_hWindow)
                            Local $sPath = _WinAPI_GetProcessFileName($iPID)
                            If StringInStr($sPath, "Nox") = True Then
                                $t_aOffset[0] = 2
                                $t_aOffset[1] = 30
                            EndIf
                        EndIf
                    EndIf 

                    $aNewPoint[0]+=$t_aOffset[0]
                    $aNewPoint[1]+=$t_aOffset[1]
                EndIf

                Log_Add("Click point: " & _ArrayToString($aNewPoint), $LOG_DEBUG)
                ControlClick($hWindow, "", "", "left", 1, $aNewPoint[0], $aNewPoint[1]) ;For simulated clicks
            ElseIf $iMouseMode = $MOUSE_ADB Then
                ;clicks using adb commands
                Log_Add("Click point: " & _ArrayToString($aNewPoint), $LOG_DEBUG)
                adbCommand("shell input tap " & $aNewPoint[0] & " " & $aNewPoint[1])
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
Func clickUntil($aPoint, $sBooleanFunction, $vArg = Null, $iAmount = 5, $iInterval = 500, $vRandom = null, $iMouseMode = $g_iMouseMode, $hWindow = $g_hWindow, $hControl = $g_hControl)
	Log_Level_Add("clickUntil")

    Local $bOutput = False
    While True
        Local $aArg[0] ;Function arguments

        ;Fix format to array: [arg1, arg2, ...]
        If isArray($vArg) = False And $vArg <> Null Then
            $aArg = StringSplit($vArg, ",", $STR_NOCOUNT)
        Else   
            $aArg = $vArg
        EndIf

        Log_Add("Clicking until => Function: " & $sBooleanFunction & ", Arguments: " & _ArrayToString($aArg), $LOG_DEBUG)
        For $i = 0 To $iAmount-1
            Local $t_vTimerStart = TimerInit()
            While TimerDiff($t_vTimerStart) < $iInterval
                If _Sleep(100) Then ExitLoop(2)
                If Call($sBooleanFunction, $aArg) = True Then 
                    $bOutput = True
                    ExitLoop(2)
                EndIf
            WEnd

            clickPoint($aPoint, 1, 0, $vRandom, $iMouseMode, $hWindow, $hControl)
        Next
        
        ExitLoop
    WEnd

    Log_Add("Clicking until result: " & $bOutput, $LOG_DEBUG)
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
Func clickWhile($aPoint, $sBooleanFunction, $vArg = Null, $iAmount = 5, $iInterval = 500, $vRandom = null, $iMouseMode = $g_iMouseMode, $hWindow = $g_hWindow, $hControl = $g_hControl)
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

        Log_Add("Clicking while => Function: " & $sBooleanFunction & ", Arguments: " & _ArrayToString($aArg), $LOG_DEBUG)
        For $i = 0 To $iAmount-1
            Local $t_vTimerStart = TimerInit()
            While TimerDiff($t_vTimerStart) < $iInterval
                If _Sleep(100) Then ExitLoop(2)
                If Call($sBooleanFunction, $aArg) = False Then 
                    $bOutput = True
                    ExitLoop(2)
                EndIf
            WEnd

            clickPoint($aPoint, 1, 0, $vRandom, $iMouseMode, $hWindow, $hControl)
        Next
        
        ExitLoop
    WEnd

    Log_Add("Clicking while result: " & $bOutput, $LOG_DEBUG)
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

#cs
    Function: Gets handle for saved BMP
    Parameters:
        $hHBitmap: ByRef WinAPI bitmap handle
        $hBitmap: ByRef GDIPlus bitmap handle
        $iX: X Coordinate.
        $iY: Y Coordinate.
        $iWidth: Width of the rectangle.
        $iHeight: Height of the rectangle.
        $bBackground: To get bitmap from background or not background.
        $hControl: Control to take a bitmap image from.
    Return: Handle of bitmap in memory.
#ce
Func getBitmapHandles(ByRef $hHBitmap, ByRef $hBitmap, $iX = 0, $iY = 0, $iWidth = $g_aControlSize[0], $iHeight = $g_aControlSize[1], $iBackgroundMode = $g_iBackgroundMode, $hControl = $g_hControl)
	_GDIPlus_BitmapDispose($hBitmap)
    _WinAPI_DeleteObject($hHBitmap)

    If $iBackgroundMode = $BKGD_WINAPI Then
		Local $hDC_Capture = _WinAPI_GetWindowDC($hControl)
		Local $hMemDC = _WinAPI_CreateCompatibleDC($hDC_Capture)
		$hHBitmap = _WinAPI_CreateCompatibleBitmap($hDC_Capture, $iWidth, $iHeight)
		Local $hObjectOld = _WinAPI_SelectObject($hMemDC, $hHBitmap)

		DllCall("user32.dll", "int", "PrintWindow", "hwnd", $hControl, "handle", $hMemDC, "int", 0)
		_WinAPI_SelectObject($hMemDC, $hHBitmap)
		_WinAPI_BitBlt($hMemDC, 0, 0, $iWidth, $iHeight, $hDC_Capture, $iX, $iY, 0x00CC0020)

        $hBitmap = _GDIPlus_BitmapCreateFromHBITMAP($hHBitmap)

		_WinAPI_DeleteDC($hMemDC)
		_WinAPI_SelectObject($hMemDC, $hObjectOld)
		_WinAPI_ReleaseDC($hControl, $hDC_Capture)
    
    Elseif $iBackgroundMode = $BKGD_NONE Then
		Local $aWinPos = WinGetPos($hControl)
        Local $aNewPoint = [$iX + $aWinPos[0], $iY + $aWinPos[1]]
		$hHBitmap = _ScreenCapture_Capture("", $aNewPoint[0], $aNewPoint[1], $aNewPoint[0] + $iWidth, $aNewPoint[1] + $iHeight, False)
        $hBitmap = _GDIPlus_BitmapCreateFromHBITMAP($hHBitmap)
        
    ElseIf $iBackgroundMode = $BKGD_ADB Then
        adbCommand("shell screencap " & $g_sEmuSharedFolder[0] & "\" & $g_sWindowTitle & ".png")
		Local $t_hBitmap = _GDIPlus_BitmapCreateFromFile($g_sEmuSharedFolder[1] & "\" & $g_sWindowTitle & ".png")

        $hBitmap = _GDIPlus_BitmapCloneArea($t_hBitmap, $iX, $iY, $iWidth, $iHeight)
        $hHBitmap = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hBitmap)

        _GDIPlus_BitmapDispose($t_hBitmap)
    EndIf
EndFunc

#cs
    Function: Create image file from bitmap in memory.
    Parameters:
        $sName: Name of file without extension.
        $hBitmap: GDI Plus bitmap
#ce
Func savehBitmap($sName, $hBitmap = $g_hBitmap)
    _WinAPI_SaveHBITMAPToFile (@ScriptDir & "\" & $sName & ".bmp", _GDIPlus_BitmapCreateHBITMAPFromBitmap($hBitmap))
EndFunc
