#include-once

Func Config_Save($sConfig = "", $sPath = "")
    Local $iIndex = -1
    If $sConfig == "" Then _GUICtrlComboBox_GetLBText($g_hCmb_Scripts, _GUICtrlComboBox_GetCurSel($g_hCmb_Scripts), $sConfig)
    $sConfig = StringReplace($sConfig, " ", "_")
    If $sPath == "" Then $sPath = $g_sProfileFolder & "\" & $Config_Profile_Name & "\" & StringReplace($sConfig, " ", "_")

    $iIndex = Script_IndexByName($sConfig)
    If $iIndex = -1 Then Return False

    Local $sData = ""

    Local $aConfig = $g_aScripts[$iIndex]
    Local $aSettingList = $aConfig[$CONFIG_SETTINGLIST] ;Array of settings

    For $i = 0 To UBound($aSettingList)-1
        Local $aSetting = $aSettingList[$i]
        $aSetting[$SETTING_VALUE] = _GUICtrlListView_GetItemText($g_hLV_ScriptConfig, $i, 1)
        $aSettingList[$i] = $aSetting

        $sData &= @CRLF & $aSetting[0] & ':"' & $aSetting[1] & '"'
    Next

    $aConfig[$CONFIG_SETTINGLIST] = $aSettingList
    $g_aScripts[$iIndex] = $aConfig

    $sData = StringMid($sData, 2)
    If ($sPath <> "") Then
        FileOpen($sPath, $FO_OVERWRITE+$FO_CREATEPATH)
        FileWrite($sPath, $sData)
        FileClose($sPath)
    EndIf

    Config_Update()
EndFunc

Func Config_Update($bForce = False)
    If $g_bRunning = True Or $bForce Then Return False ;Prevent settings changing during runtime

    Local Const $aSettings = ["_Config", "_General", "_ADB", "_Delay", "_Hourly", "_Guardian", "_Filter", _
                              "Farm_Rare", "Farm_Golem", "Farm_Gem", "Farm_Astromon", "Farm_Guardian", "Farm_Starstone"]
    For $sSetting In $aSettings
        Local $aSetting = formatArgs(Script_DataByName($sSetting)[$CONFIG_SETTINGLIST])
        Config_CreateGlobals($aSetting, $sSetting)
    Next 

    ;Emulator Console ADB and Shared folder
    Global $Config_Console_ADB
    Switch Stringlower($Config_Emulator_Console)
        Case "ldconsole", "dnconsole"
            $Config_Console_ADB = 'ldconsole adb --name ' & $Config_Emulator_Title & ' --command '
            If $ADB_Android_Shared == "~AUTO" Then $ADB_Android_Shared = "/mnt/sdcard/Pictures/Screenshots/"
            If $ADB_PC_Shared == "~AUTO" Then $ADB_PC_Shared = @HomePath & "\Documents\XuanZhi\Pictures\Screenshots\"
        Case "noxconsole"
            $Config_Console_ADB = 'NoxConsole adb -name:' & $Config_Emulator_Title & ' -command:'
            If $ADB_Android_Shared == "~AUTO" Then $ADB_Android_Shared = "/mnt/sdcard/Pictures/"
            If $ADB_PC_Shared == "~AUTO" Then $ADB_PC_Shared = @HomePath & "\Nox_share\Pictures\"
        Case "memuc"
            $Config_Console_ADB = 'memuc adb -n ' & $Config_Emulator_Title & ' '
            If $ADB_Android_Shared == "~AUTO" Then $ADB_Android_Shared = "/mnt/sdcard/Pictures/"
            If $ADB_PC_Shared == "~AUTO" Then $ADB_PC_Shared = @HomePath & "\Pictures\MEmu Photo"
    EndSwitch

    ;parsing settings
    $Config_Capture_Mode = Eval("BKGD_" & $Config_Capture_Mode)
    $Config_Mouse_Mode = Eval("MOUSE_" & $Config_Mouse_Mode)
    $Config_Swipe_Mode = Eval("SWIPE_" & $Config_Swipe_Mode)
    $Config_Back_Mode = Eval("BACK_" & $Config_Back_Mode)

    ;Cumulative
    If FileExists($g_sProfileFolder & "\" & $Config_Profile_Name & "\Cumulative") > 0 And $g_hLV_OverallStats <> Null Then
        Cumulative_Load()
    EndIf

    Return True
EndFunc

Func Config_Display(ByRef $hListView, $aScript) ;displayScriptData
    ;Must be in format: [[script, description, [[config, value, description], [..., ..., ...]]], ...]
    If isArray($aScript) = 0 Or UBound($aScript, $UBOUND_ROWS) <> 3 Then Return -1
    
    Local $aConfigList = $aScript[2] ;[[config, value, description], [..., ..., ...]]
    Local $iSize = UBound($aConfigList, $UBOUND_ROWS)

    _GUICtrlListView_DeleteAllItems($hListView)
    For $i = 0 To $iSize-1
        Local $aSetting = $aConfigList[$i] ;[config, value, description]
        _GUICtrlListView_AddItem($hListView, StringReplace($aSetting[0], "_", " "))
        _GUICtrlListView_AddSubItem($hListView, $i, $aSetting[1], 1)

        ;hidden values
        _GUICtrlListView_AddSubItem($hListView, $i, $aSetting[2], 2) ;description
        _GUICtrlListView_AddSubItem($hListView, $i, $aSetting[3], 3) ;type
        _GUICtrlListView_AddSubItem($hListView, $i, $aSetting[4], 4) ;type values
    Next
EndFunc

;Helper Functions----------------------------------------------------------------------

Func Config_Parse($sValue)
    Switch $sValue
        Case "Enabled", "Disabled"
            Return $sValue == "Enabled"
        Case "Never"
            Return -1
        Case "Immediately"
            Return 0
        Case Else
            If StringInStr($sValue, "Hours") Then
                $sValue = Int(StringMid($sValue, 1, StringLen($sValue) - StringLen(" Hours")))
            ElseIf StringInStr($sValue, "Minutes") Then
                $sValue = Int(StringMid($sValue, 1, StringLen($sValue) - StringLen(" Minutes")))
            ElseIf StringInStr($sValue, "Seconds") Then
                $sValue = Int(StringMid($sValue, 1, StringLen($sValue) - StringLen(" Seconds")))
            EndIf

            Return $sValue
    EndSwitch
EndFunc

Func Config_CreateGlobals($aSetting, $sName)
    For $i = 0 To UBound($aSetting)-1
        If $aSetting[$i][1] == "~DEFAULT" Then ContinueLoop
        
        If StringLeft($sName, 1) == "_" Then $sName = StringMid($sName, 2)
        Assign($sName & "_" & $aSetting[$i][0], Config_Parse($aSetting[$i][1]), $ASSIGN_FORCEGLOBAL)
    Next
EndFunc