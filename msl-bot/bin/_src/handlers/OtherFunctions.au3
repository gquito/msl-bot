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

; Directory with respect to @ScriptDir
Func ProgressiveCaptureRegion($sName, $sDir = "", $bCreateFolder = False)
    Local $iCount = 0
    Local $sFile = $sName
    Local $sExtension = ".bmp"

    Local $sFilePath = @ScriptDir & "/" & $sDir & "/" & $sName & $iCount & $sExtension
    If $bCreateFolder = True Then
        If FileExists(@ScriptDir & "/" & $sDir) = False Then
            DirCreate(@ScriptDir & "/" & $sDir)
        EndIf
    EndIf
    
    While FileExists($sFilePath)
        $iCount += 1
        $sFilePath = @ScriptDir & "/" & $sDir & "/" & $sName & $iCount & $sExtension
    WEnd

    CaptureRegion($sDir & "/" & $sName & $iCount & $sExtension)
EndFunc

Func GetCurrentProfileFolder()
    Return $g_sProfileFolder & $Config_Profile_Name & "\"
EndFunc

Func GetDistance($aPoint1, $aPoint2)
    If UBound($aPoint1) < 2 Then Return SetError(1, 0, 0)
    If Ubound($aPoint2) < 2 Then Return SetError(2, 0, 0)
    Local $x = ($aPoint1[0] - $aPoint2[0])
    Local $y = ($aPoint1[1] - $aPoint2[1])
    Return Sqrt($x*$x + $y*$y)
EndFunc

Func SummonScript()
    While True
        If _Sleep($Delay_Script_Loop) Then ExitLoop

        CaptureRegion()
        Select
            Case isPixel("102,510,0x22160F")
                clickPoint("102,510")
                clickPoint(getPointArg("tap"), 10, 500)
            Case isPixel("771,20,0x563133|688,18,0x5A3131")
                clickPoint("726,19")
            Case isPixel("439,309,0x00686F|346,307,0x036E6F")
                SendBack(4, 500)
                navigate("monsters")
                ExitLoop
        EndSelect
    WEnd
EndFunc