#include-once
#include "../imports.au3"

Func CreateGUI()
    Local $sUpdate = ""
    Local $t_aVersion[0] ;Will contain [Major,Minor,Build]
    Local $t_sRaw = StringSplit(BinaryToString(INetRead("https://raw.githubusercontent.com/GkevinOD/msl-bot/v3.0/msl-bot/msl-bot.au3", $INET_FORCERELOAD)), @CRLF, $STR_NOCOUNT)[0]
    If StringInStr($t_sRaw, "[") And StringInStr($t_sRaw, "]") Then
        Local $t_sRaw2 = StringSplit(StringStripWS($t_sRaw, $STR_STRIPALL), "[", $STR_NOCOUNT)[1]
        Local $t_sRaw3 = StringSplit($t_sRaw2, "]", $STR_NOCOUNT)[0]
        $t_aVersion = StringSplit($t_sRaw3, ",", $STR_NOCOUNT)
    EndIf

    If (UBound($t_aVersion) <> 3) Or ($t_aVersion[0] <> $aVersion[0]) Or ($t_aVersion[1] <> $aVersion[1]) Or ($t_aVersion[2] <> $aVersion[2]) Then
        $sUpdate = " (Out-of-date)"
    EndIf

    Local Const $GUI_FONTSIZE = 11
    Global $hParent = GUICreate($g_sAppTitle & $sUpdate, 400, 380, -9999, -9999)
    GUISetBkColor(0xFFFFFF)
    GUISetFont(8.5)
    GUISetState(@SW_SHOW, $hParent)
    _WINAPI_Setfocus($hParent)

    Global $hTb_Main = GUICtrlGetHandle(GUICtrlCreateTab(0, 0, 400, 380, $TCS_TOOLTIPS+$WS_TABSTOP+$WS_CLIPSIBLINGS+$TCS_FIXEDWIDTH))
    _GUICtrlTab_SetItemSize($hTb_Main, 100, 18)

;################################################## SCRIPT TAB ##################################################
    GUICtrlCreateTabItem("Script")

    GUISetFont(11)
    Global $idLbl_Scripts = GUICtrlCreateLabel("Select a script:", 50, 32, 96)
    GUISetFont(8.5)

    Global $hCmb_Scripts = GUICtrlGetHandle(GUICtrlCreateCombo("_Config", 146, 30, 150, -1, $CBS_DROPDOWNLIST))
    _GUICtrlComboBox_AddString($hCmb_Scripts, "_Hourly")
    _GUICtrlComboBox_AddString($hCmb_Scripts, "_Filter")
    _GUICtrlComboBox_AddString($hCmb_Scripts, "Farm Rare")
    _GUICtrlComboBox_AddString($hCmb_Scripts, "Farm Golem")
    _GUICtrlComboBox_AddString($hCmb_Scripts, "Farm Gem")
    _GUICtrlComboBox_AddString($hCmb_Scripts, "Farm Astromon")

    Global $hBtn_Start = GUICtrlGetHandle(GUICtrlCreateButton("Start", 298, 29, 50, 23))
    ControlDisable("", "", $hBtn_Start)

    Global $hLbl_ScriptDescription = GUICtrlCreateLabel("Select a script for a description of the process", 20, 56, 360, 46, $WS_BORDER+$SS_CENTER)

    Global $hLV_ScriptConfig = GUICtrlGetHandle(GUICtrlCreateListView("", 20, 106, 360, 200, $LVS_REPORT+$LVS_SINGLESEL+$LVS_NOSORTHEADER))
    _GUICtrlListView_SetExtendedListViewStyle($hLV_ScriptConfig, $LVS_EX_FULLROWSELECT+$LVS_EX_GRIDLINES)
    _GUICtrlListView_AddColumn($hLV_ScriptConfig, "Setting", 116, 0)
    _GUICtrlListView_AddColumn($hLV_ScriptConfig, "Value (Double click to edit)", 240, 0)
    ;hidden
    _GUICtrlListView_AddColumn($hLV_ScriptConfig, "Description", 0) 
    _GUICtrlListView_AddColumn($hLV_ScriptConfig, "Type", 0) 
    _GUICtrlListView_AddColumn($hLV_ScriptConfig, "Type Values", 0) 
    ;end hidden
    ControlDisable("", "", HWnd(_GUICtrlListView_GetHeader($hLV_ScriptConfig))) ;Prevents changing column size

    Global $hLbl_ConfigDescription = GUICtrlCreateLabel("Click on a setting for a description.", 20, 310, 360, 56, $WS_BORDER+$SS_CENTER)
;################################################## END SCRIPT TAB ##################################################

;################################################## LOG TAB ##################################################
    GUICtrlCreateTabItem("Log")

    GUISetFont(11)
    Global $idLbl_RunningScript = GUICtrlCreateLabel("Running Script: " & $g_sScript, 0, 32, 400, -1, $SS_CENTER)
    GUISetFont(8.5)

    Global $idPB_Progress = GUICtrlCreateProgress(34, 55, 242, 21)

    Global $idBtn_Stop = GUICtrlCreateButton("Stop", 278, 54, 40, 23)
    Global $hBtn_Stop = GUICtrlGetHandle($idBtn_Stop)
    Global $hBtn_Pause = GUICtrlGetHandle(GUICtrlCreateButton("Pause", 318, 54, 50, 23))
    ControlDisable("", "", $hBtn_Pause)
    ControlDisable("", "", $hBtn_Stop)

    Global $hLV_Stat = GUICtrlGetHandle(GUICtrlCreateListView("", 20, 86, 360, 180, $LVS_REPORT+$LVS_SINGLESEL+$LVS_NOSORTHEADER))
    _GUICtrlListView_SetExtendedListViewStyle($hLV_Stat, $LVS_EX_FULLROWSELECT+$LVS_EX_GRIDLINES)
    _GUICtrlListView_AddColumn($hLV_Stat, "Stat", 116, 0)
    _GUICtrlListView_AddColumn($hLV_Stat, "Value", 240, 0)

    Global $hLV_Log = GUICtrlGetHandle(GUICtrlCreateListView("", 20, 270, 360, 100, $LVS_REPORT+$LVS_SINGLESEL+$LVS_NOSORTHEADER))
    _GUICtrlListView_SetExtendedListViewStyle($hLV_Log, $LVS_EX_FULLROWSELECT+$LVS_EX_GRIDLINES)
    _GUICtrlListView_AddColumn($hLV_Log, "Time", 76, 0)
    _GUICtrlListView_AddColumn($hLV_Log, "Log", 1000, 0)
    _GUICtrlListView_JustifyColumn($hLV_Log, 0, 0)
    _GUICtrlListView_JustifyColumn($hLV_Log, 1, 0)

;################################################## END LOG TAB ##################################################

    ChangeScript()
    _GUICtrlTab_ActivateTab($hTb_Main, 0)

    ;Register WM_COMMAND and WM_NOTIFY for UDF controls
    GUIRegisterMsg($WM_COMMAND, "WM_COMMAND")
    GUIRegisterMsg($WM_NOTIFY, "WM_NOTIFY")

    WinMove($hParent, "", (@DesktopWidth / 2)-200, (@DesktopHeight / 2)-200)
    GUIMain()
EndFunc