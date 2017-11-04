#include-once
#include "../imports.au3"

Func CreateMslGUI()
    Local Const $GUI_FONTSIZE = 11
    Global $hParent = GUICreate("MSL Bot v3", 400, 400)
    GUISetBkColor(0xFFFFFF)
    GUISetFont($GUI_FONTSIZE)
    GUISetState(@SW_SHOW, $hParent)
    _WINAPI_Setfocus($hParent)

    Global $hTb_Main = TabCreate($hParent, 0, 0)
    Local $tb_Home = TabCreateItem($hTb_Main, "Home", 100)
    Local $tb_Config = TabCreateItem($hTb_Main, "Config", 100)
    Local $tb_Debug = TabCreateItem($hTb_Main, "Debug", 100)
    Local $tb_About = TabCreateItem($hTb_Main, "About", 100)

    Global $hTb_HomeTab = TabCreate($hTb_Main[0], 0, 0)
    Local $tb_Script = TabCreateItem($hTb_HomeTab, "Script", 200)
    Local $tb_Log = TabcreateItem($hTb_HomeTab, "Log", 200)
    TabAddControl($hTb_Main, $tb_Home, $hTb_HomeTab[0])

;################################################## SCRIPT TAB ##################################################
    Global $hLbl_Scripts = GUICtrlCreateLabel("Select a script:", 50, 12, 96)
    TabAddControl($hTb_HomeTab, $tb_Script, $hLbl_Scripts)

    Global $hCmb_Scripts = _GUICtrlComboBox_Create($hParent, "", 146, 10, 150, -1, $CBS_DROPDOWNLIST)
    _GuiCtrlComboBox_AddString($hCmb_Scripts, "Farm Rare")
    _GUICtrlComboBox_AddString($hCmb_Scripts, "Farm Golem")
    TabAddControl($hTb_HomeTab, $tb_Script, $hCmb_Scripts)

    Global $hBtn_Start = _GUICtrlButton_Create($hParent, "Start", 298, 9, 50, 23)
    TabAddControl($hTb_HomeTab, $tb_Script, $hBtn_Start)

    GUISetFont(8.5)
    Global $hLbl_ScriptDescription = GUICtrlCreateLabel("Select a script for a description of the process", 20, 36, 360, 46, $WS_BORDER+$SS_CENTER)
    GUISetFont($GUI_FONTSIZE)
    TabAddControl($hTb_HomeTab, $tb_Script, $hLbl_ScriptDescription)

    Global $hLV_ScriptConfig = _GUICtrlListView_Create($hParent, "", 20, 86, 360, 200, $LVS_REPORT+$LVS_SINGLESEL+$LVS_NOSORTHEADER+$WS_BORDER)
    _GUICtrlListView_AddColumn($hLV_ScriptConfig, "Setting", 120, 2)
    _GUICtrlListView_AddColumn($hLV_ScriptConfig, "Value (Double click to edit)", 240, 2)
    ;hidden
    _GUICtrlListView_AddColumn($hLV_ScriptConfig, "Description", 0) 
    _GUICtrlListView_AddColumn($hLV_ScriptConfig, "Type", 0) 
    _GUICtrlListView_AddColumn($hLV_ScriptConfig, "Type Values", 0) 
    ;end hidden
    _GUICtrlListView_SetExtendedListViewStyle($hLV_ScriptConfig, $LVS_EX_DOUBLEBUFFER+$LVS_EX_FULLROWSELECT+$LVS_EX_GRIDLINES)
    ControlDisable("", "", HWnd(_GUICtrlListView_GetHeader($hLV_ScriptConfig))) ;Prevents changing column size
    TabAddControl($hTb_HomeTab, $tb_Script, $hLV_ScriptConfig)

    GUISetFont(8.5)
    Global $hLbl_ConfigDescription = GUICtrlCreateLabel("Click on a setting for a description.", 20, 290, 360, 56, $WS_BORDER+$SS_CENTER)
    GUISetFont($GUI_FONTSIZE)
    TabAddControl($hTb_HomeTab, $tb_Script, $hLbl_ConfigDescription)
;################################################## END SCRIPT TAB ##################################################

    Local $t_aGroup = [$hTb_Main, $hTb_HomeTab]
    Global $g_aTabgroup = [$t_aGroup]
    TabUpdate($g_aTabgroup)

    ;Register WM_COMMAND and WM_NOTIFY for UDF controls
    GUIRegisterMsg($WM_COMMAND, "WM_COMMAND")
    GUIRegisterMsg($WM_NOTIFY, "WM_NOTIFY")

    GUIMainLoop()
EndFunc