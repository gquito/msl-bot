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
    _ArrayDisplay(rankLocations(10))
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

Func Compare_Locations($sLocation, $bUpdate = True)
    $g_aLocations = getArgsFromFile($g_sLocalOriginalFolder & $g_sLocations)
    mergeArgFromTo(getArgsFromFile($g_sLocalDataFolder & $g_sLocations), $g_aLocations)

    Local $sData = ""
    For $i = 0 To UBound($g_aLocations)-1
        If $g_aLocations[$i][0] == $sLocation Then
            $sData = $g_aLocations[$i][1]
        EndIf
    Next
    If $sData == "" Then
        MsgBox(0, "", "FAILED")
        Return -1
    EndIf

    Local $aRaw = StringSplit($sData, "/", $STR_NOCOUNT)
    Local $sCurrent = ""

    If $bUpdate = True Then CaptureRegion()
    For $i = 0 To UBound($aRaw)-1
        $sCurrent &= @CRLF & @CRLF
        Local $aSubSet = StringSplit($aRaw[$i], "|", $STR_NOCOUNT)
        For $x = 0 To UBound($aSubSet)-1
            Local $aPixel = StringSplit($aSubSet[$x], ",", $STR_NOCOUNT)
            $sCurrent &= "|" & $aPixel[0] & "," & $aPixel[1] & "," & compareColors(getColor($aPixel[0], $aPixel[1]), $aPixel[2])
        Next
    Next
    MsgBox(0, "", $sCurrent)
    Return 1
EndFunc

;Handles only titan active attack.
Global $g_bTitansFast = False
Func Titans_Fast()
    Log_Level_Add("Titans_Fast")
    Log_Add("Titans Fast has started.", $LOG_INFORMATION)

    $g_bTitansFast = Not($g_bTitansFast)

    Local $iColorSP = 0x37BECF 
    Local $iColorNOSP = 0xC0F18 
    Local $aPoint = CreateArr(545, 42)

    Local $bAntiStuck_Temp = $g_bAntiStuck
    $g_bAntiStuck = False

    Local $bScheduleBusy = $g_bScheduleBusy
    $g_bScheduleBusy = True
    While $g_bTitansFast
        If _Sleep(100, True) Then ExitLoop
        CaptureRegion()

        If isPixel(CreateArr($aPoint[0], $aPoint[1], $iColorSP), 20) = True Then 
            If _Sleep(500) Then ExitLoop

            clickPoint("39,459", 3, 20) ;Pause
            clickPoint("325,331", 10, 100) ;Continue
        EndIf
    WEnd
    $g_bAntiStuck = $bAntiStuck_Temp
    $g_bScheduleBusy = $bScheduleBusy

    Log_Add("Titans Fast has stopped.", $LOG_INFORMATION)
    Log_Level_Remove()
EndFunc

Global $g_hHidden = False
Global $g_aHiddenSavePos = Null
Func Toggle_Hidden()
    If $g_hWindow = 0 Then Return SetError(1, 0, False)
    If $g_hHidden = False Then
        MsgBox($MB_ICONINFORMATION+$MB_OK, "Toggle hidden warning", "Hiding the window might not render the game. Check Vision tab to see if the game still renders.")
        
        $g_aHiddenSavePos = WinGetPos($g_hWindow)
        WinMove($g_hWindow, "", -10000, -10000)
    Else
        WinMove($g_hWindow, 0, $g_aHiddenSavePos[0], $g_aHiddenSavePos[1])
    EndIf
    $g_hHidden = Not($g_hHidden)
EndFunc

Func LoadImage($sImage)
    _WinAPI_DeleteObject($g_hBitmap)
    $g_hBitmap = _WinAPI_LoadImage(0, @ScriptDir & "\" & $sImage, $IMAGE_BITMAP, 0, 0, $LR_LOADFROMFILE)
EndFunc