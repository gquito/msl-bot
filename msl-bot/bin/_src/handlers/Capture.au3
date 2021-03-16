#include-once

#cs
	Function: Captures region and if there is saves into bmp if there is a specified file name.
	Parameters:
		$iMode: Change mode of capture: $MODE_BITMAP(0) uses WinAPI to create a bitmap. $MODE_ADB(1) sends screencap command and creates bitmap from file created.
		$sFileName: File name saved to main folder.
#ce
Global $g_hCaptureRegion_CD = TimerInit()
Global $g_iCaptureRegion_Previous = 0
Global $g_hBitmap_Uncropped = 0
Global $g_hHBitmap_Uncropped = 0
Func CaptureRegion($sFileName = "", $iX = 0, $iY = 0, $iWidth = $EMULATOR_WIDTH, $iHeight = $EMULATOR_HEIGHT, $iBackgroundMode = $Config_Capture_Mode)
    If $iWidth+$iX > $EMULATOR_WIDTH Then $iWidth = $EMULATOR_WIDTH - $iX
    If $iHeight+$iY > $EMULATOR_HEIGHT Then $iHeight = $EMULATOR_HEIGHT - $iY

    If TimerDiff($g_hCaptureRegion_CD) < 100 Then
        If $g_iCaptureRegion_Previous <> $iX^2+$iY^2+$iWidth^2+$iHeight^2 Then
            $g_iCaptureRegion_Previous = $iX^2+$iY^2+$iWidth^2+$iHeight^2

            If $g_hBitmap <> $g_hBitmap_Uncropped Then 
                _GDIPlus_BitmapDispose($g_hBitmap)
                _WinAPI_DeleteObject($g_hHBitmap)
            EndIf

            $g_hBitmap = _GDIPlus_BitmapCloneArea($g_hBitmap_Uncropped, $iX, $iY, $iWidth, $iHeight)
            $g_hHBitmap = _GDIPlus_BitmapCreateHBITMAPFromBitmap($g_hBitmap)
        EndIf

        If ($sFileName <> "") Then saveHBitmap($sFileName)
        Return $g_hBitmap
    EndIf

    ;Log_Add(StringFormat("CaptureRegion(%d, %d, %d, %d)", $iX, $iY, $iWidth, $iHeight), $LOG_DEBUG)
    $g_hCaptureRegion_CD = TimerInit()
    $g_iCaptureRegion_Previous = $iX^2+$iY^2+$iWidth^2+$iHeight^2

	getBitmapHandles($g_hHBitmap_Uncropped, $g_hBitmap_Uncropped, $iBackgroundMode)
    If $g_hBitmap <> $g_hBitmap_Uncropped Then _GDIPlus_BitmapDispose($g_hBitmap)
    If $g_hHBitmap <> $g_hHBitmap_Uncropped Then _WinAPI_DeleteObject($g_hHBitmap)

    If $g_iCaptureRegion_Previous <> $EMULATOR_WIDTH^2+$EMULATOR_HEIGHT^2 Then
        $g_hBitmap = _GDIPlus_BitmapCloneArea($g_hBitmap_Uncropped, $iX, $iY, $iWidth, $iHeight)
        $g_hHBitmap = _GDIPlus_BitmapCreateHBITMAPFromBitmap($g_hBitmap)
    Else
        $g_hBitmap = $g_hBitmap_Uncropped
        $g_hHBitmap = $g_hHBitmap_Uncropped
    EndIf

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
Func getBitmapHandles(ByRef $hHBitmap, ByRef $hBitmap, $iBackgroundMode = $Config_Capture_Mode, $hControl = $g_hControl)
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
            $hHBitmap = _WinAPI_CreateCompatibleBitmap($hDC_Capture, $EMULATOR_WIDTH, $EMULATOR_HEIGHT)
            Local $hObjectOld = _WinAPI_SelectObject($hMemDC, $hHBitmap)

            DllCall("user32.dll", "int", "PrintWindow", "hwnd", $hControl, "handle", $hMemDC, "int", 0)
            _WinAPI_SelectObject($hMemDC, $hHBitmap)
            _WinAPI_BitBlt($hMemDC, 0, 0, $EMULATOR_WIDTH, $EMULATOR_HEIGHT, $hDC_Capture, 0, 0, 0x00CC0020)

            $hBitmap = _GDIPlus_BitmapCreateFromHBITMAP($hHBitmap)

            _WinAPI_DeleteDC($hMemDC)
            _WinAPI_SelectObject($hMemDC, $hObjectOld)
            _WinAPI_ReleaseDC($hControl, $hDC_Capture)
        Case $BKGD_NONE
            Local $aWinPos = WinGetPos($hControl)
            Local $aNewPoint = [$aWinPos[0], $aWinPos[1]]
            $hHBitmap = _ScreenCapture_Capture("", $aNewPoint[0], $aNewPoint[1], $aNewPoint[0] + $EMULATOR_WIDTH, $aNewPoint[1] + $EMULATOR_HEIGHT, False)
            $hBitmap = _GDIPlus_BitmapCreateFromHBITMAP($hHBitmap)
        Case $BKGD_ADB
            $g_bLogEnabled = False
            ADB_Command("shell screencap " & $ADB_Android_Shared & "\" & $Config_Emulator_Title & ".rgba")
            $g_bLogEnabled = True
            RGBAToHBITMAP($hBitmap, $hHBitmap, $ADB_PC_Shared & "\" & $Config_Emulator_Title & ".rgba", $EMULATOR_WIDTH, $EMULATOR_HEIGHT, 0, 0, $EMULATOR_WIDTH, $EMULATOR_HEIGHT)
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

Global $g_hMSLHelper = -1
Func RGBAToHBITMAP(ByRef $hBitmap, ByRef $hHBitmap, $sPath, $iWidth, $iHeight, $iCropX, $iCropY, $iCropWidth, $iCropHeight)
    If $g_hMSLHelper <= 0 Then
        $g_hMSLHelper = DllOpen($g_sMSLHelperPath)
        If @error Then Return -1
    EndIf

    Local $aResult = DllCall($g_hMSLHelper, "int:cdecl", "RGBAToHBITMAP", "handle*", $hHBitmap, "str", $sPath, "int", $iWidth, "int", $iHeight, "int", $iCropX, "int", $iCropY, "int", $iCropWidth, "int", $iCropHeight)
    If isArray($aResult) And $aResult[0] = 1 Then 
        _GDIPlus_BitmapDispose($hBitmap)
        _WinAPI_DeleteObject($hHBitmap)

        $hHBitmap = $aResult[1]
        $hBitmap = _GDIPlus_BitmapCreateFromHBITMAP($hHBitmap)
        Return 1
    EndIf
    Return 0
EndFunc

Func GetPixelSum($hHBitmap = $g_hHBitmap_Uncropped)
    If $hHBitmap = 0 Then Return SetError(1, 0, -1)
    If $g_hMSLHelper <= 0 Then
        $g_hMSLHelper = DllOpen($g_sMSLHelperPath)
        If @error Then Return SetError(2, 0, -1)
    EndIf

    Local $aResult = DllCall($g_hMSLHelper, "uint:cdecl", "GetPixelSum", "handle", $hHBitmap)
    If @error Then SetError(3, 0, -1)
    If isArray($aResult) Then 
        Return $aResult[0]
    EndIf
    Return SetError(4, 0, -1)
EndFunc