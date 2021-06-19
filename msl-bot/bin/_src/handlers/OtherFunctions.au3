#include-once

Func SortString($sString)
    Local $aArr1 = StringSplit($sString, @CRLF, 2)
    _ArraySort($aArr1)

    For $i = 0 To UBound($aArr1) - 1
        Local $aArr2 = StringSplit($aArr1[$i], ":", 2)
        Local $aArr3 = StringSplit($aArr2[1], ",", 2)
        _ArraySort($aArr3)

        $aArr2[1] = _ArrayToString($aArr3, ",")
        $aArr1[$i] = $aArr2[0] & ":" & $aArr2[1]
    Next

    ClipPut(_ArrayToString($aArr1, @CRLF))
    Return _ArrayToString($aArr1, @CRLF)
EndFunc

Func FormatNumber($sNumber)
    Local $iSize = StringLen($sNumber)
    If $iSize > 3 Then Return FormatNumber(StringMid($sNumber, 1, $iSize-3)) & "," & StringRight($sNumber, 3)
    Return $sNumber
EndFunc

Func GetWorkingDirectory($sFullPath)
    If $sFullPath == "" Then Return -1
    If StringRight($sFullPath, 1) == "\" Then Return $sFullPath
    Return GetWorkingDirectory(StringLeft($sFullPath, StringLen($sFullPath)-1))
EndFunc

Func TestFunction()
    CaptureRegion()
    ScriptTest_CreateGui("TEST RIGHT NOW", $g_hBitmap)
EndFunc

Func ClipSave_Bitmap()
    Local $sInput = InputBox("Save image", "Enter name for image")
    $sInput &= ".bmp"

    _ClipBoard_Open(0)
    Local $hBitmap = _ClipBoard_GetDataEx(2) ;CF_BITMAP
    _ClipBoard_Close()
    If $hBitmap = 0 Then Return SetError(1, 0, False)
    
    Local $aSplit = StringSplit($sInput, "-", $STR_NOCOUNT)
    If UBound($aSplit) = 0 Then Return SetError(2, 0, False)

    Local $sFolder = $aSplit[0]
    Local $iResult = _WinAPI_SaveHBITMAPToFile(@ScriptDir & "\bin\images\" & $sFolder & "\" & $sInput, $hBitmap, 2834, 2834)

    Return $iResult
EndFunc

Func ClipPut_Bitmap(ByRef $hBitmap)
    If _ClipBoard_Open(0) = False Then Return SetError(1, 0, False)
    If _ClipBoard_Empty() = False Then Return SetError(2, 0, False)
    Local $bResult = _ClipBoard_SetDataEx($hBitmap, 2) ;CF_BITMAP
    _Clipboard_Close()

    Return $bResult
EndFunc

;Handles only titan active attack.
Func Titans_Fast()
    Local $iColorSP = 0x37BECF 
    Local $iColorNOSP = 0xC0F18 
    Local $aPoint = CreateArr(545, 42)

    Local $bAntiStuck_Temp = $g_bAntiStuck
    $g_bAntiStuck = False

    Local $bScheduleBusy = $g_bScheduleBusy
    $g_bScheduleBusy = False
    While Not(_Sleep(100, True))
        CaptureRegion()

        If isPixel(CreateArr($aPoint[0], $aPoint[1], $iColorSP), 20) = True Then 
            If _Sleep(500) Then ExitLoop

            clickPoint("39,459", 3, 20) ;Pause
            clickPoint("325,331", 10, 100) ;Continue
        EndIf
    WEnd
    $g_bAntiStuck = $bAntiStuck_Temp
    $g_bScheduleBusy = $bScheduleBusy
EndFunc