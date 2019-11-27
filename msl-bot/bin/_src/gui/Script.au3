#include-once

Func Script_ChangeConfig()
    Local $sItem = ""
    _GUICtrlComboBox_GetLBText($g_hCmb_Scripts, _GUICtrlComboBox_GetCurSel($g_hCmb_Scripts), $sItem)
    If $sItem = "" Then Return False

    If (StringLeft($sItem, 1) = "_") Then
        ControlDisable("", "", $g_hBtn_Start)
    Else
        ControlEnable("", "", $g_hBtn_Start)
    EndIf

    $sItem = StringReplace($sItem, " ", "_")
    Local $aConfig = Script_DataByName($sItem)
    If isArray($aConfig) = True Then
        Config_Display($g_hLV_ScriptConfig, $aConfig)
        GUICtrlSetData($g_hLbl_ScriptDescription, $aConfig[1])
    EndIf
EndFunc

Func Script_ChangeProfile($sName)
    _GUICtrlListView_DeleteAllItems($g_hLV_OverallStats)

    $g_aScripts = CreateArr()
    Script_SetData($g_sLocalFolder &  $g_sScriptsSettings)
    Script_SetData($g_sLocalCacheFolder & $g_sScriptsSettings)

    For $i = 0 To UBound($g_aScripts, $UBOUND_ROWS)-1
        Local $aConfig = $g_aScripts[$i]
        If FileExists($g_sProfileFolder & "\" & $sName & "\" & $aConfig[$CONFIG_NAME]) = True Then 
            Script_SetConfigByFile($aConfig[$CONFIG_NAME], $g_sProfileFolder & "\" & $sName & "\")
        EndIf
    Next

    If FileExists($g_sProfileFolder & "\" & $sName & "\") = False Then
        Script_SetSetting("_Config", "Profile_Name", $sName)
    EndIf

    Config_Update()
    Script_ChangeConfig()
EndFunc

Func Script_SetConfigByFile($sName, $sPath = $g_sProfileFolder & "\" & $Config_Profile_Name & "\")
    $sName = StringReplace($sName, " ", "_")
    Local $iIndex = Script_IndexByName($sName)
    If $iIndex = -1 Then Return -1

    Local $aConfig2D = getArgsFromFile($sPath & "\" & $sName) ;2D array [[Name, Value], ...]
    For $i = 0 To UBound($aConfig2D)-1
        Script_SetSetting($sName, $aConfig2D[$i][0], $aConfig2D[$i][1])
    Next
EndFunc

Func Script_SetSetting($sConfig, $sSetting, $sValue)
    Local $iConfig = Script_IndexByName($sConfig)
    If $iConfig = -1 Then Return -1

    Local $aConfig = $g_aScripts[$iConfig]
    Local $aSettingList = $aConfig[$CONFIG_SETTINGLIST]

    Local $iSetting = -1
    For $i = 0 to UBound($aSettingList)-1
        If ($aSettingList[$i])[$SETTING_NAME] = $sSetting Then
            $iSetting = $i
            ExitLoop
        EndIf
    Next
    If $iSetting = -1 Then Return -2

    Local $aSettings = $aSettingList[$iSetting]
    $aSettings[$SETTING_VALUE] = $sValue

    $aSettingList[$iSetting] = $aSettings
    $aConfig[$CONFIG_SETTINGLIST] = $aSettingList
    $g_aScripts[$iConfig] = $aConfig
EndFunc

Func Script_DataByName($sName)
    Local $iSize = UBound($g_aScripts)
    For $i = 0 To $iSize-1
        Local $aConfig = $g_aScripts[$i]
        If ($aConfig[0] = $sName) Then Return $aConfig
    Next
    Return ""
EndFunc

Func Script_IndexByName($sName)
    Local $iSize = UBound($g_aScripts, $UBOUND_ROWS)
    For $i = 0 To $iSize-1
        If ($g_aScripts[$i])[0] = $sName Then Return $i
    Next
    Return -1
EndFunc

;Script data [[script, description, [[config, value, description], [..., ..., ...]]], ...]
Func Script_SetData($sPath, $sCachePath = "")
    Local $sData ;Contains unparsed data
    If FileExists($sPath) Then
        $sData = FileRead($sPath)
    Else
        $sData = BinaryToString(InetRead($sPath, $INET_FORCERELOAD))
        If $sCachePath <> "" Then
            Local $hFile = FileOpen($sCachePath, $FO_OVERWRITE+$FO_CREATEPATH)
            FileWrite($hFile, $sData)
            FileClose($hFile)
        EndIf
    EndIf
    If ($sData = "") Then Return -1

    Local $c = StringSplit($sData, "", $STR_NOCOUNT)

    Local $t_aScripts = $g_aScripts ;Temporarily stores script data
    Local $t_aScript[3] ;Stores single script

    Local $t_aConfig[5] 
    Local $t_aConfigs[0] 

    Local $bScript = False
    For $i = -1 To UBound($c)-1
        If (_Script_NextValidChar($c, $i) = -1) Then ExitLoop
        If (Not($bScript)) Then
            If ($c[$i] = "[") Then
                _Script_NextValidChar($c, $i)
                $t_aScript[0] = _Script_GetNextField($c, $i)
                $bScript = True
            EndIf
        Else
            Switch $c[$i]
                Case "[" ;field
                    _Script_NextValidChar($c, $i)
                    Local $cur_sField = _Script_GetNextField($c, $i)
                    Switch $cur_sField
                        Case "description"
                            $t_aScript[1] = _Script_GetNextString($c, $i)
                        Case "text", "combo", "setting", "list"
                            $t_aConfig[3] = $cur_sField
                            While $c[$i] <> "]"
                                _Script_NextValidChar($c, $i)
                                Local $sField = _Script_GetNextField($c, $i)
                                Switch $sField
                                    Case "name"
                                        $t_aConfig[0] = StringReplace(_Script_GetNextString($c, $i), " ", "_")
                                    Case "description"
                                        $t_aConfig[2] = _Script_GetNextString($c, $i)
                                    Case "default"
                                        $t_aConfig[1] = _Script_GetNextString($c, $i)
                                    Case "data"
                                        $t_aConfig[4] = _Script_GetNextString($c, $i)
                                    Case Else
                                        MsgBox(0, "", "Unknown field: " & $sField)
                                        Return -1
                                EndSwitch
                            WEnd

                            If ($c[$i] = "]") Then
                                ReDim $t_aConfigs[UBound($t_aConfigs)+1]
                                $t_aConfigs[UBound($t_aConfigs)-1] = $t_aConfig
                            EndIf
                    EndSwitch
                Case "]"
                    $t_aScript[2] = $t_aConfigs
                    Local $t_aNewConfig[0]
                    $t_aConfigs = $t_aNewConfig

                    If Script_IndexByName($t_aScript[0]) = -1 Then
                        ReDim $t_aScripts[UBound($t_aScripts)+1]
                        $t_aScripts[UBound($t_aScripts)-1] = $t_aScript
                    EndIf
                    
                    $bScript = False
            EndSwitch

        EndIf
    Next

    $g_aScripts = $t_aScripts
EndFunc


;Helper Functions--------------------------------------------------------

Func _Script_GetNextString($aChar, ByRef $iIndex)
    Local $sText = ""
    While $aChar[$iIndex] <> '"'
        _Script_NextValidChar($aChar, $iIndex)
    WEnd

    _Script_NextValidChar($aChar, $iIndex)
    While $aChar[$iIndex] <> '"'
        $sText &= $aChar[$iIndex]
        $iIndex += 1
    WEnd

    _Script_NextValidChar($aChar, $iIndex)
    Return $sText
EndFunc

Func _Script_GetNextField($aChar, ByRef $iIndex)
    Local $sText = ""

    While $aChar[$iIndex] <> ':'
        If StringIsSpace($aChar[$iIndex]) = False Then $sText &= $aChar[$iIndex]
        $iIndex += 1
    WEnd

    Return $sText
EndFunc

Func _Script_NextValidChar($aChar, ByRef $iIndex)
    $iIndex += 1
    While ($iIndex < UBound($aChar)) And StringIsSpace($aChar[$iIndex])
        $iIndex += 1
    WEnd

    If ($iIndex >= UBound($aChar)) Then Return -1
EndFunc
