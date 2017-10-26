#include-once
#include "../imports.au3"

Func adbShell($sCommand, $sAdbPort = $g_sAdbPort, $sAdbPath = $g_sAdbPath)
    Local $iPID = RunWait('"' & $sAdbPath & '"' & " -s 127.0.0.1:" & $sAdbPort & " shell " & '"' & $sCommand & '"')
    ProcessClose($iPID)

    Return StdoutRead($iPID)
EndFunc

Func swipe($vArgument, $iSwipeMode = $g_iSwipeMode)
    If $iSwipeMode = $SWIPE_KEYMAP Then
        ;Pre-set-up keymap
    Else
        ;Adb swipe mode
        Local $aPoints[4]

        ;Formatting argument to [x1, y1, x2, y2]
        If isArray($vArgument) = True Then
            $aPoints = $vArgument
        Else
            $vArgument = StringSplit($vArgument, ",", $STR_NOCOUNT)
            $aPoints = $vArgument
        EndIf

        If UBound($aPoints) <> 4 Then 
          ;handle error
            $g_sErrorMessage = "swipe() => Invalid argument for points."
           Return -1
        EndIf

        ;executing swipe
        adbShell("input swipe " & $aPoints[0] & " " & $aPoints[1] & " " & $aPoints[2] & " " & $aPoints[3])
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
    Local $aPoint[2] ;Point array

    ;Fixing format to [x, y]
    If isArray($vPoint) = False Then
        Local $t_aPoint = StringSplit($vPoint, ",", $STR_NOCOUNT)
        $aPoint[0] = StringStripWS($t_aPoint[0], $STR_STRIPLEADING + $STR_STRIPTRAILING)
        $aPoint[1] = StringStripWS($t_aPoint[1], $STR_STRIPLEADING + $STR_STRIPTRAILING)
    Else
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

            MouseClick("left", $aNewPoint[0], $aNewPoint[1], 1, 0)
        ElseIf $iMouseMode = $MOUSE_CONTROL Then
            ;clicks using fake mouse.
            Local $t_aOffset = ControlGetPos($hWindow, "", $hControl)
            ControlClick($hWindow, "", "", "left", 1, $aNewPoint[0]+$t_aOffset[0], $aNewPoint[1]+$t_aOffset[1]) ;For simulated clicks
        ElseIf $iMouseMode = $MOUSE_ADB Then
            ;clicks using adb commands
            adbShell("input tap " & $aNewPoint[0] & " " & $aNewPoint[1])
        Else
            $g_sErrorMessage = "clickPoint() => Invalid mouse mode: " & $iMouseMode
            Return -1
        EndIf

        If _Sleep($iInterval) Then Return -2
    Next
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
	Local $aArg[0] ;Function arguments

    ;Fix format to array: [arg1, arg2, ...]
    If isArray($vArg) = False And $vArg <> Null Then
        $aArg = StringSplit($vArg, ",", $STR_NOCOUNT)
    Else   
        $aArg = $vArg
    EndIf

    For $i = 0 To $iAmount-1
		Local $t_vTimerStart = TimerInit()
		While TimerDiff($t_vTimerStart) < $iInterval
			If _Sleep(100) Then Return -2
			If Call($sBooleanFunction, $aArg) = True Then Return True
		WEnd

		If clickPoint($aPoint, 1, 0, $vRandom, $iMouseMode, $hWindow, $hControl) = -2 Then Return -2
	Next
    
	Return False
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
	Local $aArg[0] ;Function arguments

    ;Fix format to array: [arg1, arg2, ...]
    If isArray($vArg) = False And $vArg <> Null Then
        $aArg = StringSplit($vArg, ",", $STR_NOCOUNT)
    EndIf

    For $i = 0 To $iAmount-1
		Local $t_vTimerStart = TimerInit()
		While TimerDiff($t_vTimerStart) < $iInterval
            If _Sleep(100) Then Return -2
			If Call($sBooleanFunction, $aArg) = False Then Return True
		WEnd

        If clickPoint($aPoint, 1, 0, $vRandom, $iMouseMode, $hWindow, $hControl) = -2 Then Return -2
	Next

    Return False ;If condition is still true
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
		$hBitmap = _ScreenCapture_Capture("", $aNewPoint[0], $aNewPoint[1], $aNewPoint[0] + $iWidth, $aNewPoint[1] + $iHeight)
    ElseIf $iBackgroundMode = $BKGD_ADB Then

    EndIf
EndFunc

#cs
    Function: Create image file from bitmap in memory.
    Parameters:
        $sName: Name of file without extension.
        $hHBitmap: WINAPI bitmap handle.
#ce
Func saveHBitmap($sName, $hHBitmap = $g_hHBitmap)
    _WinAPI_SaveHBITMAPToFile (@ScriptDir & "\" & $sName & ".bmp", $hHBitmap)
EndFunc
