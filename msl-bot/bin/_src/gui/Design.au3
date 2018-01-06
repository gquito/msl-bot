#include-once
#include "../imports.au3"

Func CreateGUI()
    Local Const $GUI_FONTSIZE = 11
    Global $hParent = GUICreate($g_sAppTitle, 400, 380, -9999, -9999)
    Global $hLogWindow ;Will contain log window
    WinSetTitle($hParent, "", $g_sAppTitle & UpdateStatus())
    GUISetBkColor(0xFFFFFF)
    GUISetFont(8.5)
    GUISetState(@SW_SHOW, $hParent)
    _WINAPI_Setfocus($hParent)

    ;--------------------------------------------------------
    Global $hDM_ForceQuit = GUICtrlCreateDummy()
    Global $hDM_Debug = GUICtrlCreateDummy()
    
    Local $aAccelKeys[2][2] = [["^q", $hDM_ForceQuit], ["^d", $hDM_Debug]]
    GUISetAccelerators($aAccelKeys)
    ;--------------------------------------------------------
    
    Global $hTb_Main = GUICtrlGetHandle(GUICtrlCreateTab(0, 0, 400, 380, $TCS_TOOLTIPS+$WS_TABSTOP+$WS_CLIPSIBLINGS+$TCS_FIXEDWIDTH))
    _GUICtrlTab_SetItemSize($hTb_Main, 100, 18)

;################################################## SCRIPT TAB ##################################################
    GUICtrlCreateTabItem("Script")

    GUISetFont(11)
    Global $idLbl_Scripts = GUICtrlCreateLabel("Select a script:", 50, 32, 96)
    GUISetFont(8.5)

    Global $hCmb_Scripts = GUICtrlGetHandle(GUICtrlCreateCombo("_Config", 146, 30, 150, -1, $CBS_DROPDOWNLIST))
    Local $aScriptList[0] ;Will contain script list
    If FileExists(@ScriptDir & "\bin\local\scriptlist.txt") = True Then
        Local $t_aScriptList = StringSplit(FileRead(@ScriptDir & "\bin\local\scriptlist.txt"), @CRLF, $STR_NOCOUNT)
        For $sScript In $t_aScriptList
            If StringIsSpace($sScript) = False Then _ArrayAdd($aScriptList, $sScript)
        Next
    Else
        $aScriptList = $g_aScriptList
    EndIf
    
    For $sScript In $aScriptList
        _GUICtrlComboBox_AddString($hCmb_Scripts, $sScript)
    Next

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

    Global $hLV_Stat = GUICtrlGetHandle(GUICtrlCreateListView("", 20, 86, 357, 160, $LVS_REPORT+$LVS_SINGLESEL+$LVS_NOSORTHEADER))
    _GUICtrlListView_SetExtendedListViewStyle($hLV_Stat, $LVS_EX_FULLROWSELECT+$LVS_EX_GRIDLINES)
    _GUICtrlListView_AddColumn($hLV_Stat, "Stat", 116, 0)
    _GUICtrlListView_AddColumn($hLV_Stat, "Value", 240, 0)

    Global $idBtn_Detach = GUICtrlCreateButton("Detach", 308, 246, 60, 23)

    Global $idCkb_Information = GUICtrlCreateCheckbox("Info", 34, 246, 60, 23)
    GUICtrlSetState(-1, $GUI_CHECKED)
    Global $idCkb_Error = GUICtrlCreateCheckbox("Error", 94, 246, 60, 23)
    GUICtrlSetState(-1, $GUI_CHECKED)
    Global $idCkb_Process = GUICtrlCreateCheckbox("Process", 154, 246, 60, 23)
    GUICtrlSetState(-1, $GUI_CHECKED)
    Global $idCkb_Debug = GUICtrlCreateCheckbox("Debug", 224, 246, 60, 23)
    GUICtrlSetState(-1, $GUI_UNCHECKED)

    Global $hLV_Log = GUICtrlGetHandle(GUICtrlCreateListView("", 20, 270, 360, 100, $LVS_REPORT+$LVS_NOSORTHEADER))
    _GUICtrlListView_SetExtendedListViewStyle($hLV_Log, $LVS_EX_FULLROWSELECT+$LVS_EX_GRIDLINES)
    _GUICtrlListView_AddColumn($hLV_Log, "Time", 76, 0)
    _GUICtrlListView_AddColumn($hLV_Log, "Text", 300, 0)
    _GUICtrlListView_AddColumn($hLV_Log, "Type", 100, 0)
    _GUICtrlListView_AddColumn($hLV_Log, "Function", 100, 0)
    _GUICtrlListView_AddColumn($hLV_Log, "Location", 100, 0)
    _GUICtrlListView_AddColumn($hLV_Log, "Level", 100, 0)
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

Func UpdateStatus()
    If _WinAPI_IsInternetConnected() = False Then Return ""

    Local $sUpdate = ""
    Local $t_aVersion[0] ;Will contain [Major,Minor,Build]
    Local $t_sRaw = StringSplit(BinaryToString(INetRead("https://raw.githubusercontent.com/GkevinOD/msl-bot/v3.0/msl-bot/msl-bot.au3", $INET_FORCERELOAD)), @CRLF, $STR_NOCOUNT)[0]
    If StringInStr($t_sRaw, "[") And StringInStr($t_sRaw, "]") Then
        Local $t_sRaw2 = StringSplit(StringStripWS($t_sRaw, $STR_STRIPALL), "[", $STR_NOCOUNT)[1]
        Local $t_sRaw3 = StringSplit($t_sRaw2, "]", $STR_NOCOUNT)[0]
        $t_aVersion = StringSplit($t_sRaw3, ",", $STR_NOCOUNT)
    EndIf

    If (UBound($t_aVersion) <> 3) Or ($t_aVersion[0] > $aVersion[0]) Or ($t_aVersion[1] > $aVersion[1]) Or (($t_aVersion[1] = $aVersion[1]) And ($t_aVersion[2] > $aVersion[2])) Then
        If @Compiled = False Then
            If MsgBox($MB_ICONINFORMATION+$MB_YESNO, "MSL Bot Update", "MSL Bot version " & $t_aVersion[0] & "." & $t_aVersion[1] & "." & $t_aVersion[2] _
            & " is available. Would you like to update now?") = $IDYES Then Update()
        Else
            MsgBox($MB_ICONINFORMATION+$MB_OK, "MSL Bot Update", "MSL Bot version " & $t_aVersion[0] & "." & $t_aVersion[1] & "." & $t_aVersion[2] _
            & " is available. Updater is only available with the uncompiled version (msl-bot.au3).")
        EndIf
        
        $sUpdate = " (Out-of-date)"
    EndIf

    Return $sUpdate
EndFunc

Func Update()
    If _WinAPI_IsInternetConnected() = False Then 
        MsgBox($MB_ICONERROR+$MB_OK, "Not connected.", "Not connected to the internet.")
        Return 0
    EndIf

    Local $hFile = InetGet("https://raw.githubusercontent.com/GkevinOD/msl-bot/version-check/msl-bot/msl-bot-update.au3", @ScriptDir & "\msl-bot-update.au3", 0, $INET_DOWNLOADBACKGROUND)
    While InetGetInfo($hFile, $INET_DOWNLOADCOMPLETE) = False
        Sleep(100)
    WEnd

    If InetGetInfo($hFile, $INET_DOWNLOADSUCCESS) = True Then
        MsgBox($MB_ICONINFORMATION, "MSL Bot Update", "Auto update will begin shortly.", 3)
        InetClose($hFile)
        RunWait('"' & @AutoItExe & '" /AutoIt3ExecuteScript "' & @ScriptDir & '\msl-bot-update.au3" -hwnd ' & String($hParent) & " -ldir @ScriptDir -list https://raw.githubusercontent.com/GkevinOD/msl-bot/version-check/msl-bot/update-files.txt -rdir https://raw.githubusercontent.com/GkevinOD/msl-bot/v3.0/msl-bot/ -sd" & '"')
    Else
        MsgBox($MB_ICONERROR, "MSL Bot Update", "Could not download update file.")
    EndIf
EndFunc