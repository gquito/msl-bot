#cs ----------------------------------------------------------------------------
 Function: _CaptureRegion

 Saves BMP of window to memory.

 Parameter:

	strScreen: Directory of save screen

	iLeft: Left of rectangle, x.

	iTop: Top of rectangle, y.

	iRight: Right of bottom, x2.

	iBottom: Bottom of rectangle, y2.

#ce ----------------------------------------------------------------------------

Func _CaptureRegion($strScreen = "", $iLeft = 0, $iTop = 0, $iRight = 800, $iBottom = 600)
	_GDIPlus_BitmapDispose($hBitmap)
	_WinAPI_DeleteObject($hHBitmap)

	If GUICtrlRead($chkBackground) = 1 Then
		Local $iW = Number($iRight) - Number($iLeft), $iH = Number($iBottom) - Number($iTop)

		Local $hDC_Capture = _WinAPI_GetWindowDC($hControl)
		Local $hMemDC = _WinAPI_CreateCompatibleDC($hDC_Capture)
		$hHBitmap = _WinAPI_CreateCompatibleBitmap($hDC_Capture, $iW, $iH)
		Local $hObjectOld = _WinAPI_SelectObject($hMemDC, $hHBitmap)

		DllCall("user32.dll", "int", "PrintWindow", "hwnd", $hWindow, "handle", $hMemDC, "int", 0)
		_WinAPI_SelectObject($hMemDC, $hHBitmap)
		_WinAPI_BitBlt($hMemDC, 0, 0, $iW, $iH, $hDC_Capture, $iLeft, $iTop, 0x00CC0020)

		Global $hBitmap = _GDIPlus_BitmapCreateFromHBITMAP($hHBitmap)

		_WinAPI_DeleteDC($hMemDC)
		_WinAPI_SelectObject($hMemDC, $hObjectOld)
		_WinAPI_ReleaseDC($hWindow, $hDC_Capture)
	Else
		Dim $windowPos = WinGetPos($hControl)
		$hHBitmap = _ScreenCapture_Capture("", $iLeft + $windowPos[0], $iTop + $windowPos[1], $iRight + $windowPos[0], $iBottom + $windowPos[1])
		Global $hBitmap = _GDIPlus_BitmapCreateFromHBITMAP($hHBitmap)
	EndIf

	If Not $strScreen = "" Then _WinAPI_SaveHBITMAPToFile (@ScriptDir & "\" & $strScreen, $hHBitmap)
EndFunc   ;==>_CaptureRegion