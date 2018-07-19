#include-once
#include "../imports.au3"

#cs
	Function: Captures region and if there is saves into bmp if there is a specified file name.
	Parameters:
		$iMode: Change mode of capture: $MODE_BITMAP(0) uses WinAPI to create a bitmap. $MODE_ADB(1) sends screencap command and creates bitmap from file created.
		$sFileName: File name saved to main folder.
#ce
Func captureRegion($sFileName = "", $iX = 0, $iY = 0, $iWidth = $g_aControlSize[0], $iHeight = $g_aControlSize[1], $iBackgroundMode = $g_iBackgroundMode)
	getBitmapHandles($g_hHBitmap, $g_hBitmap, $iX, $iY, $iWidth, $iHeight, $iBackgroundMode)

	If $sFileName <> "" Then
		$sFileName = StringReplace($sFileName, ".bmp", "")
		saveHBitmap($sFileName)
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
        $hHBitmap: HBITMAP
#ce
Func saveHBitmap($sName, $hHBitmap = $g_hHBitmap)
    $sName = StringReplace($sName, ".bmp", "")
    _WinAPI_SaveHBITMAPToFile (@ScriptDir & "\" & $sName & ".bmp", $hHBitmap)
EndFunc