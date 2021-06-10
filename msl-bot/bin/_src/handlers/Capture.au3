#include-once

#cs
	Function: Captures region and if there is saves into bmp if there is a specified file name.
	Parameters:
		$iMode: Change mode of capture: $MODE_BITMAP(0) uses WinAPI to create a bitmap. $MODE_ADB(1) sends screencap command and creates bitmap from file created.
		$sFileName: File name saved to main folder.
#ce
Global $g_hTimer_CaptureRegion = TimerInit()
Global $g_hBitmap_Cache = Null
Global $g_aCache_CropHBITMAP = [0, 0, 0, 0]
Func CaptureRegion($sFileName = "", $iX = 0, $iY = 0, $iWidth = $EMULATOR_WIDTH, $iHeight = $EMULATOR_HEIGHT, $iBackgroundMode = $Config_Capture_Mode)
    If TimerDiff($g_hTimer_CaptureRegion) > 100 Then
        $g_hTimer_CaptureRegion = TimerInit()

        getBitmapHandles($g_hBitmap, $iBackgroundMode)
        GetColorMap($g_aMap, $g_hBitmap)

        _WinAPI_DeleteObject($g_hBitmap_Cache)
        $g_hBitmap_Cache = $g_hBitmap

        $g_aCache_CropHBITMAP = CreateArr(0, 0, 800, 552)
    EndIf

    If Not(($g_aCache_CropHBITMAP[0] = $iX And $g_aCache_CropHBITMAP[1] = $iY) And ($g_aCache_CropHBITMAP[0] = $iX And $g_aCache_CropHBITMAP[1] = $iY)) Then
        If $g_hBitmap <> $g_hBitmap_Cache Then _WinAPI_DeleteObject($g_hBitmap)
        $g_hBitmap = CropHBITMAP($g_hBitmap_Cache, $EMULATOR_WIDTH, $EMULATOR_HEIGHT, $iX, $iY, $iWidth, $iHeight)
        $g_aCache_CropHBITMAP = CreateArr($iX, $iY, $iWidth, $iHeight)
    EndIf

	If ($sFileName <> "") Then saveHBitmap($sFileName)
    UpdatePicture()
    Return $g_aMap
EndFunc

#cs
    Function: Gets handle for saved BMP
    Parameters:
        $hBitmap: ByRef WinAPI bitmap handle
        $iX: X Coordinate.
        $iY: Y Coordinate.
        $iWidth: Width of the rectangle.
        $iHeight: Height of the rectangle.
        $bBackground: To get bitmap from background or not background.
        $hControl: Control to take a bitmap image from.
    Return: Handle of bitmap in memory.
#ce
Func getBitmapHandles(ByRef $hBitmap, $iBackgroundMode = $Config_Capture_Mode, $hControl = $g_hControl)
    If $hBitmap <> 0  Then
        _WinAPI_DeleteObject($hBitmap)
        $hBitmap = 0
    EndIf

    Switch $iBackgroundMode
        Case $BKGD_WINAPI
            Local $hDC_Capture = _WinAPI_GetWindowDC($hControl)
            Local $hMemDC = _WinAPI_CreateCompatibleDC($hDC_Capture)
            $hBitmap = _WinAPI_CreateCompatibleBitmap($hDC_Capture, $EMULATOR_WIDTH, $EMULATOR_HEIGHT)
            Local $hObjectOld = _WinAPI_SelectObject($hMemDC, $hBitmap)

            DllCall("user32.dll", "int", "PrintWindow", "hwnd", $hControl, "handle", $hMemDC, "int", 0)
            _WinAPI_SelectObject($hMemDC, $hBitmap)
            _WinAPI_BitBlt($hMemDC, 0, 0, $EMULATOR_WIDTH, $EMULATOR_HEIGHT, $hDC_Capture, 0, 0, 0x00CC0020)

            _WinAPI_DeleteDC($hMemDC)
            _WinAPI_SelectObject($hMemDC, $hObjectOld)
            _WinAPI_ReleaseDC($hControl, $hDC_Capture)
        Case $BKGD_NONE
            Local $aWinPos = WinGetPos($hControl)
            If isArray($aWinPos) = True Then
                Local $aNewPoint = [$aWinPos[0], $aWinPos[1]]
                $hBitmap = _ScreenCapture_Capture("", $aNewPoint[0], $aNewPoint[1], $aNewPoint[0] + $EMULATOR_WIDTH - 1, $aNewPoint[1] + $EMULATOR_HEIGHT - 1, False)
            EndIf
        Case $BKGD_ADB
            $g_bLogEnabled = False
            ;Data in from adb is in ABGR format must be converted to ARGB when used as HBITMAP. Done in RGBAToHBITMAP
            ADB_Command("shell screencap " & $ADB_Android_Shared & "\" & $Config_Emulator_Title & ".rgba")
            $g_bLogEnabled = True
            RGBAToHBITMAP($hBitmap, $ADB_PC_Shared & "\" & $Config_Emulator_Title & ".rgba", $EMULATOR_WIDTH, $EMULATOR_HEIGHT, 0, 0, $EMULATOR_WIDTH, $EMULATOR_HEIGHT)
            If @error Then Log_Add("Could not load DLL: " & $g_sMSLHelperPath, $LOG_ERROR)
    EndSwitch
EndFunc

#cs
    Function: Create image file from bitmap in memory.
    Parameters:
        $sName: Name of file without extension.
        $hBitmap: HBITMAP
#ce
Func saveHBitmap($sName, $hBitmap = $g_hBitmap)
    $sName = StringReplace($sName, ".bmp", "")
    If (StringInStr($sName,":\")) Then
        _WinAPI_SaveHBITMAPToFile($sName & ".bmp", $hBitmap)
    Else
        _WinAPI_SaveHBITMAPToFile(@ScriptDir & "\" & $sName & ".bmp", $hBitmap)
    EndIf
EndFunc

Global $g_hMSLHelper = -1
Func RGBAToHBITMAP(ByRef $hBitmap, $sPath, $iWidth, $iHeight, $iCropX, $iCropY, $iCropWidth, $iCropHeight)
    If $g_hMSLHelper <= 0 Then
        $g_hMSLHelper = DllOpen($g_sMSLHelperPath)
        If @error Then Return SetError(1, 0, False)
    EndIf

    Local $aResult = DllCall($g_hMSLHelper, "int:cdecl", "RGBAToHBITMAP", "handle*", $hBitmap, "str", $sPath, "int", $iWidth, "int", $iHeight, "int", $iCropX, "int", $iCropY, "int", $iCropWidth, "int", $iCropHeight)
    If isArray($aResult) And $aResult[0] = 1 Then 
        _WinAPI_DeleteObject($hBitmap)

        $hBitmap = $aResult[1]
        Return True
    EndIf
    Return False
EndFunc

;For 800x552 dimension
Func GetColorMap(ByRef $aMap, $hBitmap = $g_hBitmap)
    $aMap = 0 ;Deallocate
    $aMap = DllStructCreate("uint Pixel[" & 800*552 & "]")
    Return _WinAPI_GetBitmapBits($g_hBitmap, 800*552*4, $aMap)
EndFunc

;Assuming 800x552 dimension
Func GetPixelSum($aMap = $g_aMap, $iSkip = 200, $iLeft = 0, $iTop = 0, $iWidth = 800, $iHeight = 552)
    Local $iSum = 0

    For $i = 0 To ($iWidth*$iHeight) - 1 Step $iSkip
        Local $x = $iLeft + Mod($i, $iWidth)
        Local $y = $iTop + Int($i / $iWidth)
        
        Local $iColor = _getColor($x, $y, $aMap)
        $iSum += _ColorGetRed($iColor) + _ColorGetGreen($iColor) + _ColorGetBlue($iColor)
    Next

    Return $iSum
EndFunc

Func CropHBITMAP(ByRef $hBitmap, $iWidth, $iHeight, $iCropX, $iCropY, $iCropWidth, $iCropHeight)
    If ($iCropWidth - $iCropX = $iWidth And $iCropHeight - $iCropY = $iHeight) Then Return $hBitmap

    ;Log_Add("Crop: " & _ArrayToString(CreateArr($iCropX, $iCropY, $iCropWidth, $iCropHeight), ","), $LOG_DEBUG)

    If $g_hMSLHelper <= 0 Then
        $g_hMSLHelper = DllOpen($g_sMSLHelperPath)
        If @error Then Log_Add("Could not open DLL: " & $g_sMSLHelperPath, $LOG_ERROR)
    EndIf

    $g_aCache_CropHBITMAP = CreateArr($iCropX, $iCropY, $iCropWidth, $iCropHeight)
    If $g_hMSLHelper > 0 Then
        Local $aResult = DllCall($g_hMSLHelper, "handle:cdecl", "CropHBITMAP", "handle*", $hBitmap, "int", $iWidth, "int", $iHeight, "int", $iCropX, "int", $iCropY, "int", $iCropWidth, "int", $iCropHeight)
        If @error Then SetError(3, 0, -1)
        If isArray($aResult) Then 
            Return $aResult[0]
        EndIf
        Return SetError(4, 0, -1)
    Else
        Local $srcDC = _WinAPI_CreateCompatibleDC(Null)
        Local $newDC = _WinAPI_CreateCompatibleDC(Null)
    
        Local $hBitmap_cropped = _WinAPI_CreateBitmap($iCropWidth, $iCropHeight, 1, 32, Null)
    
        Local $srcBitmap = _WinAPI_SelectObject($srcDC, $hBitmap)
        Local $newBitmap = _WinAPI_SelectObject($newDC, $hBitmap_cropped)
    
        _WinAPI_BitBlt($newDC, 0, 0, $iCropX + $iCropWidth, $iCropY + $iCropHeight, $srcDC, $iCropX, $iCropY, 0x00CC0020) ;SRCCOPY
    
        _WinAPI_SelectObject($srcDC, $srcBitmap)
        _WinAPI_SelectObject($newDC, $newBitmap)
    
        _WinAPI_DeleteDC($srcDC)
        _WinAPI_DeleteDC($newDC)
        Return $hBitmap_cropped
    EndIf
EndFunc