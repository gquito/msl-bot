#include-once
#include "../imports.au3"

;For cumulative stats

;$aData will store data from the file to an array
Func Stat_Read(ByRef $aData, $sFilePath = $g_sProfilePath & "\CumulativeStats")
    $aData = Null
    If (Not(FileExists($sFilePath))) Then
        Local $t_aData[0]
        _ArrayAdd($t_aData,"Hours_spent:0")
        _ArrayAdd($t_aData,"Golem_runs:0")
        _ArrayAdd($t_aData,"Gems_sold:0")
        _ArrayAdd($t_aData,"Gems_kept:0")
        _ArrayAdd($t_aData,"Eggs_found:0")
        _ArrayAdd($t_aData,"Gold_profit:0")
        _ArrayAdd($t_aData,"Gold_spent:0")
        _ArrayAdd($t_aData,"Astrogems_farmed:0")
        _ArrayAdd($t_aData,"Astrogems_spent:0")
        _ArrayAdd($t_aData,"Gold_net_profit:0")
        _ArrayAdd($t_aData,"Astrogem_net_profit:0")
        _ArrayAdd($t_aData,"Legendary_caught:0")
        _ArrayAdd($t_aData,"Super_Rare_caught:0")
        _ArrayAdd($t_aData,"Exotic_caught:0")
        _ArrayAdd($t_aData,"Rare_caught:0")
        _ArrayAdd($t_aData,"Variant_caught:0")
        _ArrayAdd($t_aData,"Overall_caught:0")
        _ArrayAdd($t_aData,"Astrochips_used:0")
        _ArrayAdd($t_aData,"PVP_battles:0")
        _ArrayAdd($t_aData,"PVP_won:0")
        _ArrayAdd($t_aData,"Hidden_rewards:0")
        _ArrayAdd($t_aData,"Nezz_found:0")
        _ArrayAdd($t_aData,"Guardian_dungeons:0")
        _ArrayAdd($t_aData,"Quest_collected:0")
        _FileWriteFromArray($sFilePath,$t_aData)
    EndIf

    If (FileExists($sFilePath & "Update")) Then
        GUICtrlSetData($g_idLbl_Stat, "Cumulative stats (Last reset: " & FileRead($sFilePath & "Update") & ")")
    Else
        GUICtrlSetData($g_idLbl_Stat, "Cumulative stats (Last reset: Never)")
    EndIf

    $aData = getArgsFromFile($sFilePath)
    If (Not(isArray($aData))) Then Return False
    For $i = 0 To UBound($aData)-1
        $aData[$i][0] = StringReplace($aData[$i][0], "_", " ")
    Next
    Return True
EndFunc

Func Stat_Save(ByRef $aData, $sFilePath = $g_sProfilePath & "\CumulativeStats")
    If (Not(isArray($aData))) Then Return False

    Local $hFile = FileOpen($sFilePath, $FO_OVERWRITE)

    ;File format='DATA:VALUE'
    Local $sFinalData = ""
    For $i = 0 To UBound($aData)-1
        $sFinalData &= @CRLF & $aData[$i][0] & ":" & $aData[$i][1]
    Next
    $sFinalData = StringReplace(StringMid($sFinalData, 2), " ", "_")

    FileWrite($hFile, $sFinalData)
    FileClose($hFile)
    Return True
EndFunc

Func Stat_Set(ByRef $aDataList, $sData, $sValue, $bUpdate = True, $hListView = $g_hLV_OverallStats)
    If (Not(isArray($aDataList))) Then Return False

    ;Saves every 10 modifications.
    If ($g_iStatModify >= 10) Then
        Stat_Save($aDataList)
        $g_iStatModify = 0
    Else
        $g_iStatModify += 1
    EndIf

    Local $bExist = False
    For $i = 0 To UBound($aDataList)-1
        If ($aDataList[$i][0] = $sData) Then
            $aDataList[$i][1] = $sValue
            $bExist = True
            ExitLoop
        EndIf
    Next
    
    ;Adds value if it does not exist
    If (Not($bExist)) Then
        ReDim $aDataList[UBound($aDataList)+1][2]
        $aDataList[UBound($aDataList)-1][0] = $sData
        $aDataList[UBound($aDataList)-1][1] = $sValue
    EndIf

    _Stat_Calculated($aDataList)
    If ($g_hTimeSpent = Null) Then $g_hTimeSpent = TimerInit()

    If ($bUpdate) Then Stat_Update($aDataList, $hListView)

    Return True
EndFunc

;Stats that are calculated after another stat has been set.
Func _Stat_Calculated(ByRef $aData)
    If (Not(isArray($aData))) Then Return False

    ;Time spent
    If ($g_hTimeSpent <> Null And TimerDiff($g_hTimeSpent) > 60000) Then
        Local $iSeconds = TimerDiff($g_hTimeSpent)/1000
        $g_hTimeSpent = Null
        Stat_Set($aData, "Hours spent", Round(Number(getArg($aData, "Hours spent"))+($iSeconds/60/60), 4))
    EndIf

    ;Gold and astrogem profit
    Local $iGoldNetProfit = Int(getArg($aData, "Gold profit")) - Int(getArg($aData, "Gold spent"))
    If ($iGoldNetProfit <> Int(getArg($aData, "Gold net profit"))) Then Stat_Set($aData, "Gold net profit", $iGoldNetProfit)

    Local $iAstrogemNetProfit = Int(getArg($aData, "Astrogems farmed")) - Int(getArg($aData, "Astrogems spent"))
    If ($iAstrogemNetProfit <> Int(getArg($aData, "Astrogem net profit"))) Then Stat_Set($aData, "Astrogem net profit", $iAstrogemNetProfit)
EndFunc

Func Stat_Increment(ByRef $aDataList, $sData, $iAmount = 1)
    Local $sDataValue = getArg($aDataList, $sData)
    If ($sDataValue = -1) Then Return False
    
    Return Stat_Set($aDataList, $sData, $sDataValue+$iAmount)
EndFunc

;Listview must have 2 columns
Func Stat_Update(ByRef $aData, ByRef $hListView)
    If (Not(isArray($aData))) Then Return False
    _GUICtrlListView_BeginUpdate($hListView)

    If (_GUICtrlListView_GetItemCount($hListView) = UBound($aData) And _GUICtrlListView_GetItem($hListView, 0) = $aData[0][0]) Then
        For $i = 0 To UBound($aData)-1
            _GUICtrlListView_SetItem($hListView, $aData[$i][0], $i)
            _GUICtrlListView_SetItem($hListView, $aData[$i][1], $i, 1)
        Next
    Else
        _GUICtrlListView_DeleteAllItems($hListView)
        For $i = 0 To UBound($aData)-1
            _GUICtrlListView_AddItem($hListView, $aData[$i][0])
            _GUICtrlListView_AddSubItem($hListView, $i, $aData[$i][1], 1)
        Next
    EndIf
    
    _GUICtrlListView_EndUpdate($hListView)
    Return True
EndFunc

Func Stat_Reset(ByRef $aData, ByRef $hListView, $sFilePath = $g_sProfilePath & "\CumulativeStats")
    If (Not(isArray($aData))) Then Return False
    For $i = 0 To UBound($aData)-1  
        $aData[$i][1] = 0
        _GUICtrlListView_SetItem($hListView, 0, $i, 1)
    Next

    Stat_Save($aData, $sFilePath)
    Local $sDate = _Now()
    If (Not(FileExists($sFilePath & "Update"))) Then
        FileWrite($sFilePath & "Update", $sDate)
    Else
        Local $hFile = FileOpen($sFilePath & "Update", $FO_OVERWRITE)
        FileWrite($hFile, $sDate)
    EndIf
    
    GUICtrlSetData($g_idLbl_Stat, "Cumulative stats (Last reset: " & $sDate & ")")
EndFunc