#include-once


;-----------------------------
;["variable,type,p1,p2,p3...", "..."] 
;$g_aStats

Func Status($sText, $iLogType = $LOG_DEBUG)
    If $sText == $g_sStatus Then Return False
    Log_Add($sText, $iLogType)

    If isDeclared("Status") = True Then $Status = $sText
    $g_sStatus = $sText
    Return True
EndFunc

;[{Array}, {Array}, ...]
;{Array}: ["TYPE", "PARAM1", "PARAM2", "PARAM3", ...]
;PARAM1 Will be displayed.
Func Stats_Add($aVariables)
    For $i = 0 To UBound($aVariables)-1
        Local $iIndex = Stats_GetIndexByName(($aVariables[$i])[1])
        If $iIndex <> -1 Then
            $g_aStats[$iIndex] = $aVariables[$i]
        Else
            _ArrayAdd($g_aStats, $aVariables[$i], 0, "|", @CRLF, 1)
        EndIf

        Switch ($aVariables[$i])[0]
            Case "Text"
                Assign(($aVariables[$i])[1], "", 2)
            Case "Ratio", "Number", "Percent", "Time", "Invisible"
                Assign(($aVariables[$i])[1], 0, 2)
        EndSwitch
    Next
EndFunc

Func Stats_Handle()
    If (($g_bRunning > 0 And TimerDiff($g_aStatsCD) > 1000) And BitAnd(WinGetState($g_hParent), $WIN_STATE_MINIMIZED) = False) And _GUICtrlTab_GetCurSel($g_hTb_Main) = 1 Then
        $g_aStatsCD = TimerInit()
        Stats_Update()
    EndIf
EndFunc

Func Stats_Update()
    For $i = 0 To UBound($g_aStats)-1
        Local $aParam = $g_aStats[$i]
        Local $iIndex = Stats_GetLVIndexByName($aParam[1])
        If $iIndex = -1 And $aParam[0] <> "Invisible" Then $iIndex = _GUICtrlListView_AddItem($g_hLV_Stat, $aParam[1])
        Local $sString = ""
        Switch $aParam[0]
            Case "Ratio"
                If Eval($aParam[2]) = 0 Then ContinueCase

                Local $sNumerator = FormatNumber(Eval($aParam[1]))
                Local $sDenominator = FormatNumber(Eval($aParam[2]))
                $sString = $sNumerator & "/" & $sDenominator
            Case "Number"
                $sString = FormatNumber(Eval($aParam[1]))
            Case "Text"
                $sString = Eval($aParam[1])
            Case "Time"
                Local $iNumerator = Eval($aParam[1])
                Local $iDenominator = (Eval($aParam[2])="")?0:Eval($aParam[2])
                Local $iSeconds = ($iDenominator>0)?Int($iNumerator/$iDenominator):$iNumerator
                $sString = getTimeString($iSeconds)
            Case "Percent"
                Local $iNumerator = Eval($aParam[1])
                Local $iDenominator = Eval($aParam[2])
                $sString = (($iDenominator>0)?(($iNumerator / $iDenominator) * 100):("0")) & "%"
        EndSwitch
        _GUICtrlListView_SetItem($g_hLV_Stat, $sString, $iIndex, 1)
    Next
EndFunc

Func Stats_GetValues(ByRef $aStats, $aNames = Null)
    Local $aValues[0][2]
    If $aNames = Null Then
        For $i = 0 To UBound($aStats)-1
            _ArrayAdd($aValues, "")
            $aValues[$i][0] = ($aStats[$i])[1]
            $aValues[$i][1] = Eval($aValues[$i][0])
        Next
    Else
        For $i = 0 To UBound($aNames)-1
            For $x = 0 To UBound($aStats)-1
                If ($aStats[$x])[1] <> $aNames[$i] Then ContinueLoop
                _ArrayAdd($aValues, "")
                $aValues[$x][0] = ($aStats[$x])[1]
                $aValues[$x][1] = Eval($aValues[$x][0])
            Next
        Next
    EndIf
    Return $aValues
EndFunc

Func Stats_Values_Edit(ByRef $aValues, $iIndex, $Value)
    If $iIndex <> -1 Then $aValues[$iIndex][1] = $Value
EndFunc

Func Stats_Values_IndexByName($aValues, $sName)
    Return _ArraySearch($aValues, $sName)
EndFunc

Func Stats_Values_Set($aValues)
    For $i = 0 To UBound($aValues)-1
        Assign($aValues[$i][0], $aValues[$i][1])
    Next
EndFunc

Func Stats_Values_Add(ByRef $aValues, $sName, $sValue)
    Local $iIndex = _ArraySearch($aValues, $sName) 
    If $iIndex = -1 Then 
        Stats_Values_Edit($aValues, $iIndex, $sValue)
    Else
        $iIndex = _ArrayAdd($aValues, $sName)
        $aValues[$iIndex][1] = $sValue
    EndIf
EndFunc

Func Stats_Values_Remove(ByRef $aValues, $aRemove)
    For $i = 0 To UBound($aRemove)-1
        Local $iIndex = _ArraySearch($aValues, $aRemove[$i])
        If $iIndex <> -1 Then _ArrayDelete($aValues, $iIndex)
    Next
EndFunc

Func Stats_Values_GetSpecific($aValues, $aNames)
    Local $aNew_Values[0][2]
    For $i = 0 To UBound($aNames)-1
        Local $iIndex = _ArraySearch($aValues, $aNames[$i])
        If $iIndex <> -1 Then 
            Local $iNew_Index = _ArrayAdd($aNew_Values, "")
            $aNew_Values[$iNew_Index][0] = $aNames[$i]
            $aNew_Values[$iNew_Index][1] = $aValues[$iIndex][1]
        EndIf
    Next
    Return $aNew_Values
EndFunc

Func Stats_Clear()
    $g_aStats = CreateArr()
    _GUICtrlListView_DeleteAllItems($g_hLV_Stat)
EndFunc

Func Stats_GetLVIndexByName($sName)
    For $i = 0 To _GUICtrlListView_GetItemCount($g_hLV_Stat)-1
        If _GUICtrlListView_GetItemText($g_hLV_Stat, $i) == $sName Then Return $i
    Next
    Return -1
EndFunc

Func Stats_GetIndexByName($sName)
    For $i = 0 To UBound($g_aStats)-1
        If ($g_aStats[$i])[1] == $sName Then Return $i
    Next    
    Return -1
EndFunc