#include-once

#cs
	Function: Captures region and if there is saves into bmp if there is a specified file name.
	Parameters:
		$iMode: Change mode of capture: $MODE_BITMAP(0) uses WinAPI to create a bitmap. $MODE_ADB(1) sends screencap command and creates bitmap from file created.
		$sFileName: File name saved to main folder.
#ce
Global $g_hCaptureRegion_CD = TimerInit()
Global $g_aCaptureRegion_Previous = CreateArr(0, 0, 0, 0)
Func CaptureRegion($sFileName = "", $iX = 0, $iY = 0, $iWidth = $EMULATOR_WIDTH, $iHeight = $EMULATOR_HEIGHT, $iBackgroundMode = $Config_Capture_Mode)
    If TimerDiff($g_hCaptureRegion_CD) < 200 Then
        If ($g_aCaptureRegion_Previous[0] = $iX And $g_aCaptureRegion_Previous[1] = $iY) And ($g_aCaptureRegion_Previous[2] = $iWidth And $g_aCaptureRegion_Previous[3] = $iHeight) Then
            Return $g_hBitmap
        EndIf
    EndIf

    ;Log_Add(StringFormat("CaptureRegion(%d, %d, %d, %d)", $iX, $iY, $iWidth, $iHeight), $LOG_DEBUG)

    $g_hCaptureRegion_CD = TimerInit()
    $g_aCaptureRegion_Previous = CreateArr($iX, $iY, $iWidth, $iHeight)

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
Func getBitmapHandles(ByRef $hHBitmap, ByRef $hBitmap, $iX = 0, $iY = 0, $iWidth = $EMULATOR_WIDTH, $iHeight = $EMULATOR_HEIGHT, $iBackgroundMode = $Config_Capture_Mode, $hControl = $g_hControl)
    If $hHBitmap <> 0 Or $hBitMap <> 0 Then
        _GDIPlus_BitmapDispose($hBitmap)
        _WinAPI_DeleteObject($hHBitmap)

        $hBitmap = 0
        $hHBitmap = 0
    EndIf

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

Func BitmapFromBuffer(ByRef $hBitmap, ByRef $hHBitmap, $aBuffer, $iWidth = $EMULATOR_WIDTH, $iHeight = $EMULATOR_HEIGHT)
    $hBitmap = _GDIPlus_BitmapCreateFromScan0($iWidth, $iHeight, $GDIP_PXF32ARGB, $iWidth*4, $aBuffer)
    $hHBitmap = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hBitmap)
    saveHBitmap("test.bmp")
EndFunc

;GDIP_PXF32ARGB
;RGBA from file
Func CreateImageBuffer($iSkip = 12, $iWidth = $EMULATOR_WIDTH, $iHeight = $EMULATOR_HEIGHT)
    Local $hFile = FileOpen(@ScriptDir & "\test.rgba", 16)
    FileRead($hFile, $iSkip)

    Local $tPixel = DllStructCreate("uint[" & $iWidth * $iHeight & "];")
    Local $iOffset = 0
    ;Using ARGB format
    For $y = 0 To $iHeight - 1
        $iOffset = $y * $iWidth
        For $x = 0 To $iWidth - 1
            Local $iR = FileRead($hFile, 1)
            Local $iG = FileRead($hFile, 1)
            Local $iB = FileRead($hFile, 1)
            Local $iA = FileRead($hFile, 1)
            DllStructSetData($tPixel, 1, BitOr(BitShift($iA, -24), BitShift($iR, -16), BitShift($iG, -8), $iB), $iOffset + $x + 1)
        Next
    Next

    FileClose($hFile)
    Return $tPixel
EndFunc