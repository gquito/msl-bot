#include-once

Global $g_hCumulativeTimer = Null
Func Cumulative_Handle()
    If $g_hCumulativeTimer = Null Then $g_hCumulativeTimer = TimerInit()
    If ($g_bRunning = True And $g_bPaused = False) Then
        If TimerDiff($g_hCumulativeTimer) > 5000 Then
            
            Cumulative_AddTime("Time Spent (" & $g_sScript & ")", 5)
            Cumulative_AddTime("Time Spent (Total)", 5)
            $g_hCumulativeTimer = Null
        EndIf
    EndIf
EndFunc

Func Cumulative_Load($sFile = $g_sProfileFolder & "\" & $Config_Profile_Name & "\Cumulative")
    Local $t_a[0]
    $g_aCumulative = $t_a

    If FileExists($sFile) = True Then
        Local $sCumulative = FileRead($sFile)
        Local $aCumulative = StringSplit($sCumulative, @CRLF, 2)
        GUICtrlSetData($g_idLbl_Stat, "Cumulative stats (Last reset: " & formatDateTime(FileGetTime($sFile, 1, 1)) & ")")
        For $i = 0 To UBound($aCumulative)-1
            If $aCumulative[$i] <> "" Then
                _ArrayAdd($g_aCumulative, $aCumulative[$i])
            EndIf
        Next
        Cumulative_Update($g_hLV_OverallStats)
        Return 1
    Else
        Return 0
    EndIf
EndFunc

Func Cumulative_Save($sFile = $g_sProfileFolder & "\" & $Config_Profile_Name & "\Cumulative")
    Local $hFile = FileOpen($sFile, 10)
    Local $iResult = FileWrite($hFile, _ArrayToString($g_aCumulative, @CRLF))
    FileClose($hFile)

    Return $iResult
EndFunc

Func Cumulative_Update($hListView)
    _ArraySort($g_aCumulative)

    _GUICtrlListView_BeginUpdate($hListView)
    Local $iSize = UBound($g_aCumulative)
    Local $bAddItems = False

    If _GUICtrlListView_GetItemCount($hListView) <> $iSize Then 
        _GUICtrlListView_DeleteAllItems($hListView)
        $bAddItems = True
    EndIf

    For $i = 0 To $iSize-1
        Local $aData = StringSplit($g_aCumulative[$i], ":", 2)
        If UBound($aData) = 2 Then
            If $bAddItems = True Then _GUICtrlListView_AddItem($hListView, $aData[0])

            _GUICtrlListView_SetItemText($hListView, $i, $aData[0], 0)
            _GUICtrlListView_SetItemText($hListView, $i, $aData[1], 1)
        EndIf
    Next
    _GUICtrlListView_EndUpdate($hListView)
EndFunc

Func Cumulative_Find($sName)
    Local $iLength = StringLen($sName)
    For $i = 0 To UBound($g_aCumulative)-1
        If StringMid($g_aCumulative[$i], 1, $iLength) = $sName Then
            Return $i
        EndIf
    Next

    Return -1
EndFunc

Func Cumulative_Get($sName)
    Local $iIndex = Cumulative_Find($sName)
    If $iIndex <> -1 Then Return StringMid($g_aCumulative[$iIndex], StringLen($sName)+2)
    Return -1
EndFunc

Func Cumulative_Set($sName, $sData)
    Local $iIndex = Cumulative_Find($sName)
    If $iIndex <> -1 Then
        $g_aCumulative[$iIndex] = $sName & ":" & $sData
    Else
        _ArrayAdd($g_aCumulative, $sName & ":" & $sData)
    EndIf

    Cumulative_Update($g_hLV_OverallStats)
EndFunc

;---------------

Func Cumulative_AddRatio($sName)
    Local $sData = Cumulative_Get($sName)
    If $sData <> -1 Then
        Local $aData = StringSplit($sData, "/", 2)
        If UBound($aData) = 2 Then
            $aData[0] += 1
            $aData[1] += 1
            Cumulative_Set($sName, _ArrayToString($aData, "/"))
        EndIf
    Else
        Cumulative_Set($sName, "1/1")
    EndIf
EndFunc

Func Cumulative_SubRatio($sName)
    Local $sData = Cumulative_Get($sName)
    If $sData <> -1 Then
        Local $aData = StringSplit($sData, "/", 2)
        If UBound($aData) = 2 Then
            $aData[1] += 1
            Cumulative_Set($sName, _ArrayToString($aData, "/"))
        EndIf
    Else
        Cumulative_Set($sName, "0/1")
    EndIf
EndFunc

Func Cumulative_SubRatio_Num($sName)
    Local $sData = Cumulative_Get($sName)
    If $sData <> -1 Then
        Local $aData = StringSplit($sData, "/", 2)
        If UBound($aData) = 2 Then
            $aData[0] -= 1
            Cumulative_Set($sName, _ArrayToString($aData, "/"))
        EndIf
    Else
        Cumulative_Set($sName, "0/1")
    EndIf
EndFunc

Func Cumulative_AddNum($sName, $iValue)
    Local $sData = Cumulative_Get($sName)
    If $sData <> -1 Then
        Cumulative_Set($sName, $sData + $iValue)
    Else
        Cumulative_Set($sName, $iValue)
    EndIf
EndFunc

Func Cumulative_AddTime($sName, $iSeconds)
    Local $sData = getSecondsFromString(Cumulative_Get($sName))
    If $sData <> -1 Then
        Cumulative_Set($sName, getTimeString($sData + $iSeconds))
    Else
        Cumulative_Set($sName, getTimeString(0))
    EndIf
EndFunc