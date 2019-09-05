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

Func TestFunction()
    Local $MousePos = MouseGetPos()
    Local $GamePos = WinGetPos(ControlGetHandle(WinGetHandle($Config_Emulator_Title), "", $Config_Emulator_Property))

    Local $Rel = [$MousePos[0] - $GamePos[0], $MousePos[1] - $GamePos[1]]
    CaptureRegion()

    Log_Add($Rel[0] & "," & $Rel[1] & "," & GetColor($Rel[0], $Rel[1]), $LOG_INFORMATION)
    ClipPut($Rel[0] & "," & $Rel[1] & "," & GetColor($Rel[0], $Rel[1]))
    $g_bRunning = True
    ;navigate("map")
    $g_bRunning = False
EndFunc