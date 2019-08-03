#include-once
#include "../imports.au3"

#cs
	Function: Captures region and if there is saves into bmp if there is a specified file name.
	Parameters:
		$iMode: Change mode of capture: $MODE_BITMAP(0) uses WinAPI to create a bitmap. $MODE_ADB(1) sends screencap command and creates bitmap from file created.
		$sFileName: File name saved to main folder.
#ce
Func captureRegion($sFileName = "", $iX = 0, $iY = 0, $iWidth = $NOX_WIDTH, $iHeight = $NOX_HEIGHT, $iBackgroundMode = $g_iBackgroundMode)
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
Func getBitmapHandles(ByRef $hHBitmap, ByRef $hBitmap, $iX = 0, $iY = 0, $iWidth = $NOX_WIDTH, $iHeight = $NOX_HEIGHT, $iBackgroundMode = $g_iBackgroundMode, $hControl = $g_hControl)
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
        Case $BKGD_ADB ;Disabled for now
            ;If $g_sADBMethod = "input event" Then
            ;    ADB_Command("shell screencap " & $g_sEmuSharedFolder[0] & $g_sWindowTitle & ".png")
            ;Else
            ;    ADB_Shell("screencap " & $g_sEmuSharedFolder[0] & "\" & $g_sWindowTitle & ".png")
            ;EndIf
            ;Local $t_hBitmap = _GDIPlus_BitmapCreateFromFile($g_sEmuSharedFolder[1] & "\" & $g_sWindowTitle & ".png")

            ;$hBitmap = _GDIPlus_BitmapCloneArea($t_hBitmap, $iX, $iY, $iWidth, $iHeight)
            ;$hHBitmap = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hBitmap)
            ;_GDIPlus_BitmapDispose($t_hBitmap)
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

Func takeScreenShot($bPartial = False, $iLeft = 0, $iTop = 0, $iWidth = $NOX_WIDTH, $iHeight = $NOX_HEIGHT)
    Local $sFileName = StringRegExpReplace(_NowCalc(), "[/\s:]", "-")
    Local $sFilePath = $g_sProfileImagePath & "ScreenShots\" & formatDate() & "\"
    If (Not(FileExists($g_sProfileImagePath & "ScreenShots\"))) Then DirCreate($g_sProfileImagePath & "ScreenShots\")
    If (Not(FileExists($sFilePath))) Then DirCreate($sFilePath)
    $sFileName = StringFormat("%sScreenshot_%s.bmp", $sFilePath, $sFileName)
    If ($bPartial) Then
        captureRegion($sFileName, $iTop, $iLeft, $iWidth, $iHeight)
    Else
        captureRegion($sFileName)
    EndIf
    Log_Add("Screenshot taken. Path: " & $sFileName, $LOG_INFORMATION)
EndFunc

Func openScreenshotFolder()
    If (Not(FileExists($g_sProfileImagePath & "ScreenShots\"))) Then DirCreate($g_sProfileImagePath & "ScreenShots\")
    ShellExecute($g_sProfileImagePath & "ScreenShots")
EndFunc

Func takeErrorScreenshot($sFunction)
    Local $sFileName = StringRegExpReplace(_NowCalc(), "[/\s:]", "-")
    Local $sFuncImagePath = $g_sProfileImageErrorPath & formatDate() & "\"
    If (Not(FileExists($sFuncImagePath))) Then DirCreate($sFuncImagePath)
    $sFuncImagePath = $sFuncImagePath & $sFunction & "\" ; Image error path: profiles\profilename\images\error + date + functionname
    If (Not(FileExists($sFuncImagePath))) Then DirCreate($sFuncImagePath)
    $sFileName = StringFormat("%sError_%s_Screenshot_%s.bmp", $sFuncImagePath, $sFunction, $sFileName)
    captureRegion($sFileName)
    Log_Add("Error Screenshot taken. Path: " & $sFileName, $LOG_INFORMATION)
EndFunc