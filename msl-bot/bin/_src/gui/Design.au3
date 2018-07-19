#include-once
#include "../imports.au3"

Func CreateGUI()
    Local Const $GUI_FONTSIZE = 11
    Global $hParent = GUICreate($g_sAppTitle, 400, 400, -9999, -9999, $WS_SIZEBOX+$WS_MAXIMIZEBOX+$WS_MINIMIZEBOX)
    Global $hLogWindow ;Will contain log window
    WinSetTitle($hParent, "", $g_sAppTitle & UpdateStatus())
    GUISetBkColor(0xFFFFFF)
    GUISetFont(8.5)
    GUISetState(@SW_SHOW, $hParent)
    _WINAPI_Setfocus($hParent)

    ;--------------------------------------------------------
    Global $hDM_ForceQuit = GUICtrlCreateDummy()
    Global $hDM_Debug = GUICtrlCreateDummy()
    Global $hDM_ScriptTest = GUICtrlCreateDummy()
    
    Local $aAccelKeys[3][2] = [["^q", $hDM_ForceQuit], ["^d", $hDM_Debug], ["^t", $hDM_ScriptTest]]
    GUISetAccelerators($aAccelKeys)
    ;--------------------------------------------------------
    
    Global $idTb_Main = GUICtrlCreateTab(0, 0, 400, 380, $TCS_TOOLTIPS+$WS_TABSTOP+$WS_CLIPSIBLINGS+$TCS_FIXEDWIDTH)
    Global $hTb_Main = GUICtrlGetHandle($idTb_Main)
    _GUICtrlTab_SetItemSize($hTb_Main, 95, 18)

    GUICtrlSetResizing($idTb_Main, $GUI_DOCKBORDERS)
;################################################## SCRIPT TAB ##################################################
    GUICtrlCreateTabItem("Script")

    GUISetFont(11)
    Global $idLbl_Scripts = GUICtrlCreateLabel("Select a script:", 50, 32, 96)
    GUISetFont(8.5)

    Global $idCmb_Scripts = GUICtrlCreateCombo("_Config", 146, 30, 150, -1, $CBS_DROPDOWNLIST)
    Global $hCmb_Scripts = GUICtrlGetHandle($idCmb_Scripts)
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

    Global $idBtn_Start = GUICtrlCreateButton("Start", 298, 29, 50, 23)
    Global $hBtn_Start = GUICtrlGetHandle($idBtn_Start)
    ControlDisable("", "", $hBtn_Start)

    Global $hLbl_ScriptDescription = GUICtrlCreateLabel("Select a script for a description of the process", 20, 56, 360, 46, $WS_BORDER+$SS_CENTER)

    Global $idLV_ScriptConfig = GUICtrlCreateListView("", 20, 106, 360, 200, $LVS_REPORT+$LVS_SINGLESEL+$LVS_NOSORTHEADER)
    Global $hLV_ScriptConfig = GUICtrlGetHandle($idLV_ScriptConfig)
    _GUICtrlListView_SetExtendedListViewStyle($hLV_ScriptConfig, $LVS_EX_FULLROWSELECT+$LVS_EX_GRIDLINES)
    _GUICtrlListView_AddColumn($hLV_ScriptConfig, "Setting", 116, 0)
    _GUICtrlListView_AddColumn($hLV_ScriptConfig, "Value (Double click to edit)", 500, 0)
    ;hidden
    _GUICtrlListView_AddColumn($hLV_ScriptConfig, "Description", 0) 
    _GUICtrlListView_AddColumn($hLV_ScriptConfig, "Type", 0) 
    _GUICtrlListView_AddColumn($hLV_ScriptConfig, "Type Values", 0) 
    ;end hidden
    ;ControlDisable("", "", HWnd(_GUICtrlListView_GetHeader($hLV_ScriptConfig))) ;Prevents changing column size

    Global $hLbl_ConfigDescription = GUICtrlCreateLabel("Click on a setting for a description.", 20, 310, 360, 56, $WS_BORDER+$SS_CENTER)

    GUICtrlSetResizing($idLbl_Scripts, $GUI_DOCKTOP+$GUI_DOCKHCENTER+$GUI_DOCKVCENTER+$GUI_DOCKSIZE)
    GUICtrlSetResizing($idCmb_Scripts, $GUI_DOCKTOP+$GUI_DOCKHCENTER+$GUI_DOCKVCENTER+$GUI_DOCKSIZE)
    GUICtrlSetResizing($idBtn_Start, $GUI_DOCKTOP+$GUI_DOCKHCENTER+$GUI_DOCKVCENTER+$GUI_DOCKSIZE)

    GUICtrlSetResizing($hLbl_ScriptDescription, $GUI_DOCKTOP+$GUI_DOCKHEIGHT)
    GUICtrlSetResizing($idLV_ScriptConfig, $GUI_DOCKTOP+$GUI_DOCKBOTTOM)
    GUICtrlSetResizing($hLbl_ConfigDescription, $GUI_DOCKBOTTOM+$GUI_DOCKHEIGHT)

;################################################## END SCRIPT TAB ##################################################

;################################################## LOG TAB ##################################################
    GUICtrlCreateTabItem("Log")

    GUISetFont(11)
    Global $idLbl_RunningScript = GUICtrlCreateLabel("Running Script: " & $g_sScript, 0, 32, 400, -1, $SS_CENTER)
    Global $idLbl_ScriptTime = GUICtrlCreateLabel("Time: ", 34, 55, 242, 21, $WS_BORDER+$SS_CENTER)
    GUISetFont(8.5)

    Global $idBtn_Stop = GUICtrlCreateButton("Stop", 278, 54, 40, 23)
    Global $hBtn_Stop = GUICtrlGetHandle($idBtn_Stop)
    Global $idBtn_Pause = GUICtrlCreateButton("Pause", 318, 54, 50, 23)
    Global $hBtn_Pause = GUICtrlGetHandle($idBtn_Pause)
    ControlDisable("", "", $hBtn_Pause)
    ControlDisable("", "", $hBtn_Stop)

    Global $idLV_Stat = GUICtrlCreateListView("", 20, 86, 357, 160, $LVS_REPORT+$LVS_SINGLESEL+$LVS_NOSORTHEADER)
    Global $hLV_Stat = GUICtrlGetHandle($idLV_Stat)
    _GUICtrlListView_SetExtendedListViewStyle($hLV_Stat, $LVS_EX_FULLROWSELECT+$LVS_EX_GRIDLINES)
    _GUICtrlListView_AddColumn($hLV_Stat, "Stat", 116, 0)
    _GUICtrlListView_AddColumn($hLV_Stat, "Value", 500, 0)

    Global $idBtn_Detach = GUICtrlCreateButton("Detach", 308, 246, 60, 23)

    Global $idCkb_Information = GUICtrlCreateCheckbox("Info", 34, 246, 60, 23)
    GUICtrlSetState(-1, $GUI_CHECKED)
    Global $idCkb_Error = GUICtrlCreateCheckbox("Error", 94, 246, 60, 23)
    GUICtrlSetState(-1, $GUI_CHECKED)
    Global $idCkb_Process = GUICtrlCreateCheckbox("Process", 154, 246, 60, 23)
    GUICtrlSetState(-1, $GUI_CHECKED)
    Global $idCkb_Debug = GUICtrlCreateCheckbox("Debug", 224, 246, 60, 23)
    GUICtrlSetState(-1, $GUI_UNCHECKED)

    Global $idLV_Log = GUICtrlCreateListView("", 20, 270, 360, 100, $LVS_REPORT+$LVS_NOSORTHEADER)
    Global $hLV_Log = GUICtrlGetHandle($idLV_Log)
    _GUICtrlListView_SetExtendedListViewStyle($hLV_Log, $LVS_EX_FULLROWSELECT+$LVS_EX_GRIDLINES)
    _GUICtrlListView_AddColumn($hLV_Log, "Time", 76, 0)
    _GUICtrlListView_AddColumn($hLV_Log, "Text", 300, 0)
    _GUICtrlListView_AddColumn($hLV_Log, "Type", 100, 0)
    _GUICtrlListView_AddColumn($hLV_Log, "Function", 100, 0)
    _GUICtrlListView_AddColumn($hLV_Log, "Location", 100, 0)
    _GUICtrlListView_AddColumn($hLV_Log, "Level", 100, 0)
    _GUICtrlListView_JustifyColumn($hLV_Log, 0, 0)
    _GUICtrlListView_JustifyColumn($hLV_Log, 1, 0)

    GUICtrlSetResizing($idLbl_RunningScript, $GUI_DOCKTOP+$GUI_DOCKHCENTER+$GUI_DOCKSIZE)

    GUICtrlSetResizing($idLbl_ScriptTime, $GUI_DOCKTOP+$GUI_DOCKHCENTER+$GUI_DOCKVCENTER+$GUI_DOCKSIZE)
    GUICtrlSetResizing($idBtn_Stop, $GUI_DOCKTOP+$GUI_DOCKHCENTER+$GUI_DOCKVCENTER+$GUI_DOCKSIZE)
    GUICtrlSetResizing($idBtn_Pause, $GUI_DOCKTOP+$GUI_DOCKHCENTER+$GUI_DOCKVCENTER+$GUI_DOCKSIZE)

    GUICtrlSetResizing($idLV_Stat, $GUI_DOCKTOP+$GUI_DOCKBOTTOM)

    GUICtrlSetResizing($idBtn_Detach, $GUI_DOCKBOTTOM+$GUI_DOCKHEIGHT)
    GUICtrlSetResizing($idCkb_Information, $GUI_DOCKBOTTOM+$GUI_DOCKHEIGHT)
    GUICtrlSetResizing($idCkb_Error, $GUI_DOCKBOTTOM+$GUI_DOCKHEIGHT)
    GUICtrlSetResizing($idCkb_Process, $GUI_DOCKBOTTOM+$GUI_DOCKHEIGHT)
    GUICtrlSetResizing($idCkb_Debug, $GUI_DOCKBOTTOM+$GUI_DOCKHEIGHT)
    
    GUICtrlSetResizing($idLV_Log, $GUI_DOCKBOTTOM+$GUI_DOCKHEIGHT)

;################################################## END LOG TAB ##################################################

;################################################## STATS TAB ##################################################
    GUICtrlCreateTabItem("Stats")

    Global $idBtn_StatReset = GUICtrlCreateButton("Reset", 320, 25, 70, 23)
    Global $hBtn_StatReset = GUICtrlGetHandle($idBtn_StatReset)

    GUISetFont(10)
    Global $idLbl_Stat = GUICtrlCreateLabel("Cumulative stats (Last reset: Never)", 10, 27, 400, 23)
    GUISetFont(8.5)

    Global $idLV_OverallStats = GUICtrlCreateListview("", 5, 50, 389, 300)
    Global $hLV_OverallStats = GUICtrlGetHandle($idLV_OverallStats)
    _GUICtrlListView_SetExtendedListViewStyle($hLV_OverallStats, $LVS_EX_FULLROWSELECT+$LVS_EX_GRIDLINES)
    _GUICtrlListView_AddColumn($hLV_OverallStats, "Stat", 250, 0)
    _GUICtrlListView_AddColumn($hLV_OverallStats, "Value", 145, 0)

    ;Updating cumulative stats
    Stat_Read($g_aStats)
    Stat_Update($g_aStats, $hLV_OverallStats)

    Global $hLbl_StatMessage = GUICtrlCreateLabel("Support MSL Bot by donating! For more details click on the Donate tab.", 5, 355, 389, 17, $WS_BORDER+$SS_CENTER)

    GuiCtrlSetResizing($idLbl_Stat, $GUI_DOCKTOP+$GUI_DOCKLEFT+$GUI_DOCKSIZE)
    GUICtrlSetResizing($idbtn_StatReset, $GUI_DOCKTOP+$GUI_DOCKRIGHT+$GUI_DOCKSIZE)
    GUICtrlSetResizing($idLV_OverallStats, $GUI_DOCKBORDERS)

    GUICtrlSetResizing($hLbl_StatMessage, $GUI_DOCKBOTTOM+$GUI_DOCKHEIGHT)

;################################################## END STATS TAB ##################################################

;################################################## DONATE TAB ##################################################
    GUICtrlCreateTabItem("Donate")

    GUISetFont(10, 700)
    Global $idLbl_Donate = GUICtrlCreateLabel("Support me at: https://paypal.me/GkevinOD/10", 0, 50, 400, -1, $SS_CENTER+$WS_BORDER)
    GUICtrlSetCursor(-1, 0)
    GUISetFont(8.5, 0)

    GUICtrlCreateLabel("Those who donate a cumulative value of 10.00 USD will receive access to an exclusive donator version with extra features. ", 0, 80, 400, 40, $SS_CENTER)
    GUICtrlCreateLabel("Donating this amount will grant you a role in the community discord and access to the exclusive version through the role permissions.", 25, 120, 350, 40, $SS_CENTER)

    Global $idLbl_Discord = GUICtrlCreateLabel("For any questions contact me at: gkevinod@gmail.com" & @CRLF & "or private message via discord: https://discord.gg/UQGRnwf", 25, 160, 350, 40, $SS_CENTER)
    GUICtrlSetCursor(-1, 0)

    GUISetFont(10, 500)
    Global $idLbl_List = GUICtrlCreateLabel("Donator Features:" & @CRLF & @CRLF & "- AutoPVP" & @CRLF & "- Complete Dailies" & @CRLF & "- Complete Bingo" & @CRLF & "- Guided Auto" & @CRLF & "( click for complete list )", 0, 200, 400, -1, $SS_CENTER)
    GUICtrlSetCursor(-1, 0)
    GUISetFont(8.5, 0)

    GUISetFont(7, 500)
    GUICtrlCreateLabel("Note: List may not be complete or updated.", 0, 350, 400, -1, $SS_CENTER)
    GUISetFont(8.5, 0)

;################################################## END DONATE TAB ##################################################

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
    Local $t_sRaw = StringSplit(BinaryToString(INetRead("https://raw.githubusercontent.com/GkevinOD/msl-bot/release/msl-bot/msl-bot.au3", $INET_FORCERELOAD)), @CRLF, $STR_NOCOUNT)[0]
    If StringInStr($t_sRaw, "[") And StringInStr($t_sRaw, "]") Then
        Local $t_sRaw2 = StringSplit(StringStripWS($t_sRaw, $STR_STRIPALL), "[", $STR_NOCOUNT)[1]
        Local $t_sRaw3 = StringSplit($t_sRaw2, "]", $STR_NOCOUNT)[0]
        $t_aVersion = StringSplit($t_sRaw3, ",", $STR_NOCOUNT)
    EndIf

    Local $t_bUpdate = False 
    If $aVersion[0] < $t_aVersion[0] Then
        $t_bUpdate = True
    ElseIf $aVersion[0] = $t_aVersion[0] Then 
        If $aVersion[1] < $t_aVersion[1] Then
            $t_bUpdate = True
        ElseIf $aVersion[1] = $t_aVersion[1] Then 
            If $aVersion[2] < $t_aVersion[2] Then
                $t_bUpdate = True
            EndIf
        EndIf
    EndIf

    If $t_bUpdate = True Then
        If $g_bAskForUpdates = True Then
            If @Compiled = False Then
                If MsgBox($MB_ICONINFORMATION+$MB_YESNO, "MSL Bot Update", "MSL Bot version " & $t_aVersion[0] & "." & $t_aVersion[1] & "." & $t_aVersion[2] _
                & " is available. Would you like to update now?") = $IDYES Then Update()
            Else
                MsgBox($MB_ICONINFORMATION+$MB_OK, "MSL Bot Update", "MSL Bot version " & $t_aVersion[0] & "." & $t_aVersion[1] & "." & $t_aVersion[2] _
                & " is available. Updater is only available with the uncompiled version (msl-bot.au3).")
            EndIf
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
        RunWait('"' & @AutoItExe & '" /AutoIt3ExecuteScript "' & @ScriptDir & '\msl-bot-update.au3" -hwnd ' & String($hParent) & " -ldir @ScriptDir -list https://raw.githubusercontent.com/GkevinOD/msl-bot/version-check/msl-bot/update-files.txt -rdir https://raw.githubusercontent.com/GkevinOD/msl-bot/release/msl-bot/ -sd" & '"')
    Else
        MsgBox($MB_ICONERROR, "MSL Bot Update", "Could not download update file.")
    EndIf
EndFunc