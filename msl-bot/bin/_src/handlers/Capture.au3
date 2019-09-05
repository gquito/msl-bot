#include-once

#cs
	Function: Captures region and if there is saves into bmp if there is a specified file name.
	Parameters:
		$iMode: Change mode of capture: $MODE_BITMAP(0) uses WinAPI to create a bitmap. $MODE_ADB(1) sends screencap command and creates bitmap from file created.
		$sFileName: File name saved to main folder.
#ce
Func CaptureRegion($sFileName = "", $iX = 0, $iY = 0, $iWidth = $NOX_WIDTH, $iHeight = $NOX_HEIGHT, $iBackgroundMode = $Config_Capture_Mode)
	getBitmapHandles($g_hHBitmap, $g_hBitmap, $iX, $iY, $iWidth, $iHeight, $iBackgroundMode)
	If ($sFileName <> "") Then saveHBitmap($sFileName)

    Return $g_hBitmap
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
Func getBitmapHandles(ByRef $hHBitmap, ByRef $hBitmap, $iX = 0, $iY = 0, $iWidth = $NOX_WIDTH, $iHeight = $NOX_HEIGHT, $iBackgroundMode = $Config_Capture_Mode, $hControl = $g_hControl)
	_GDIPlus_BitmapDispose($hBitmap)
    _WinAPI_DeleteObject($hHBitmap)

    Switch $iBackgroundMode
        Case $BKGD_WINAPI
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
        Case $BKGD_NONE
            Local $aWinPos = WinGetPos($hControl)
            Local $aNewPoint = [$iX + $aWinPos[0], $iY + $aWinPos[1]]
            $hHBitmap = _ScreenCapture_Capture("", $aNewPoint[0], $aNewPoint[1], $aNewPoint[0] + $iWidth, $aNewPoint[1] + $iHeight, False)
            $hBitmap = _GDIPlus_BitmapCreateFromHBITMAP($hHBitmap)
        Case $BKGD_ADB
            ADB_Command("shell screencap " & $Config_ADB_Shared_Folder1 & "\" & $Config_Emulator_Title & ".png")
            Local $t_hBitmap = _GDIPlus_BitmapCreateFromFile($Config_ADB_Shared_Folder2 & "\" & $Config_Emulator_Title & ".png")

            $hBitmap = _GDIPlus_BitmapCloneArea($t_hBitmap, $iX, $iY, $iWidth, $iHeight)
            $hHBitmap = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hBitmap)

            _GDIPlus_BitmapDispose($t_hBitmap)
    EndSwitch
EndFunc

#cs
    Function: Create image file from bitmap in memory.
    Parameters:
        $sName: Name of file without extension.
        $hHBitmap: HBITMAP
#ce
Func saveHBitmap($sName, $hHBitmap = $g_hHBitmap)
    $sName = StringReplace($sName, ".bmp", "")
    If (StringInStr($sName,":\")) Then
        _WinAPI_SaveHBITMAPToFile($sName & ".bmp", $hHBitmap)
    Else
        _WinAPI_SaveHBITMAPToFile(@ScriptDir & "\" & $sName & ".bmp", $hHBitmap)
    EndIf
EndFunc