#include-once

Func CreateGUI()
    Local $GUI_FONTSIZE = 11
    $g_hParent = GUICreate($g_sAppTitle, 400, 420, -9999, -9999, $WS_SIZEBOX+$WS_MAXIMIZEBOX+$WS_MINIMIZEBOX)
    WinSetTitle($g_hParent, "", $g_sAppTitle & UpdateStatus())
    GUISetBkColor(0xFFFFFF)

    GUISetFont(8.5)
    GUISetState(@SW_SHOW, $g_hParent)
    _WINAPI_Setfocus($g_hParent)

    ;--------------------------------------------------------
    
    $g_idTb_Main = GUICtrlCreateTab(0, 0, 400, 380, $TCS_TOOLTIPS+$WS_TABSTOP+$WS_CLIPSIBLINGS+$TCS_FIXEDWIDTH)
    $g_hTb_Main = GUICtrlGetHandle($g_idTb_Main)
    _GUICtrlTab_SetItemSize($g_hTb_Main, 60, 18)

    GUICtrlSetResizing($g_idTb_Main, $GUI_DOCKBORDERS)

;################################################## BEGIN MENU ##################################################

    Global $Menu_File =                 GUICtrlCreateMenu("File")
    Global $M_File_Check_Version =          GUICtrlCreateMenuItem("Check Version", $Menu_File)
    Global $M_File_View_Hotkeys =           GUICtrlCreateMenuItem("View Hotkeys", $Menu_File)
    Global $M_File_Open_Log_Folder =        GUICtrlCreateMenuItem("Open Log Folder", $Menu_File)
                                            GUICtrlCreateMenuItem("", $Menu_File)
    Global $M_File_Quit =                   GUICtrlCreateMenuItem("Quit", $Menu_File)

    Global $Menu_Script =               GUICtrlCreateMenu("Script")
    Global $M_Script_Start =                GUICtrlCreateMenuItem("Start...", $Menu_Script)
    Global $M_Script_Pause =                GUICtrlCreateMenuItem("Pause", $Menu_Script)
    Global $M_Script_Stop =                 GUICtrlCreateMenuItem("Stop", $Menu_Script)

    Global $Menu_Debug =                GUICtrlCreateMenu("Debug")
    Global $Menu_General =                  GUICtrlCreateMenu("General", $Menu_Debug)
    Global $M_General_Restart_Emulator =        GUICtrlCreateMenuItem("Restart Emulator", $Menu_General)
    Global $M_General_Restart_Game =            GUICtrlCreateMenuItem("Restart Game", $Menu_General)
                                                GUICtrlCreateMenuItem("", $Menu_General)
    Global $M_General_Debug_Input =             GUICtrlCreateMenuItem("Debug Input...", $Menu_General)
    Global $M_General_Compatibility_Test =      GUICtrlCreateMenuItem("Compatibility Test...", $Menu_General)

    Global $Menu_ADB =                      GUICtrlCreateMenu("ADB", $Menu_Debug)
    Global $M_ADB_Run_Command =                 GUICtrlCreateMenuItem("Run Command...", $Menu_ADB)
    Global $M_ADB_Device_List =                 GUICtrlCreateMenuItem("Device List", $Menu_ADB)
    Global $M_ADB_Status =                      GUICtrlCreateMenuItem("Status", $Menu_ADB)
    Global $M_ADB_Game_Status =                 GUICtrlCreateMenuItem("Game Status", $Menu_ADB)

    Global $Menu_Location =                 GUICtrlCreateMenu("Location", $Menu_Debug)
    Global $M_Location_Navigate =               GUICtrlCreateMenuItem("Navigate...", $Menu_Location)
    Global $M_Location_Get_Location =           GUICtrlCreateMenuItem("Get Location", $Menu_Location)
    Global $M_Location_Set_Location =           GUICtrlCreateMenuItem("Set Location...", $Menu_Location)
    Global $M_Location_Test_Location =          GUICtrlCreateMenuItem("Test Location", $Menu_Location)

    Global $Menu_Pixel =                    GUICtrlCreateMenu("Pixel", $Menu_Debug)
    Global $M_Pixel_Check_Pixel =               GUICtrlCreateMenuItem("Check Pixel...", $Menu_Pixel)
    Global $M_Pixel_Set_Pixel =                 GUICtrlCreateMenuItem("Set Pixel...", $Menu_Pixel)
    Global $M_Pixel_Get_Color =                 GUICtrlCreateMenuItem("Get Color...", $Menu_Pixel)
    
    Global $Menu_Scripts =              GUICtrlCreateMenu("Scripts")
    Global $M_Scripts_Hourly =              GUICtrlCreateMenuItem("Hourly", $Menu_Scripts)
    Global $M_Scripts_Collect_Quest =       GUICtrlCreateMenuItem("Collect Quest", $Menu_Scripts)
    Global $M_Scripts_Guardian_Dungeon =    GUICtrlCreateMenuItem("Guardian Dungeon", $Menu_Scripts)

    Global $Menu_Capture =              GuiCtrlCreateMenu("Capture")
    Global $M_Capture_Full_Screenshot =     GUICtrlCreateMenuItem("Full Screenshot", $Menu_Capture)
    Global $M_Capture_Partial_Screenshot =  GUICtrlCreateMenuItem("Partial Screenshot...", $Menu_Capture)
    Global $M_Capture_Open_Folder =         GUICtrlCreateMenuItem("Open Folder...", $Menu_Capture)

    Global $Dummy_Test_Function = GUICtrlCreateDummy()
    Local $aAccelKeys[4][2] = [ _
        ["^q", $M_File_Quit], _
        ["^d", $M_General_Debug_Input], _
        ["^t", $M_General_Compatibility_Test], _
        ["^w", $Dummy_Test_Function]]
    GUISetAccelerators($aAccelKeys)
;################################################## END MENU ##################################################

;################################################## SCRIPT TAB ##################################################
    GUICtrlCreateTabItem("Script")

    GUISetFont(11)
    $g_idLbl_Scripts = GUICtrlCreateLabel("Select a script:", 50, 32, 96)
    GUISetFont(8.5)

    $g_idCmb_Scripts = GUICtrlCreateCombo("_Config", 146, 30, 150, -1, $CBS_DROPDOWNLIST)
    $g_hCmb_Scripts = GUICtrlGetHandle($g_idCmb_Scripts)
    Local $aScriptList[0] ;Will contain script list
    If (FileExists($g_sScriptListFile)) Then
        Local $t_aScriptList = StringSplit(FileRead($g_sScriptListFile), @CRLF, $STR_NOCOUNT)
        For $sScript In $t_aScriptList
            If (Not(StringIsSpace($sScript))) Then _ArrayAdd($aScriptList, $sScript)
        Next
    Else
        $aScriptList = $g_aScriptList
    EndIf
    
    For $sScript In $aScriptList
        _GUICtrlComboBox_AddString($g_hCmb_Scripts, $sScript)
    Next

    $g_idBtn_Start = GUICtrlCreateButton("Start", 298, 29, 50, 23)
    $g_hBtn_Start = GUICtrlGetHandle($g_idBtn_Start)
    ControlDisable("", "", $g_hBtn_Start)

    $g_hLbl_ScriptDescription = GUICtrlCreateLabel("Select a script for a description of the process", 20, 56, 360, 46, $WS_BORDER+$SS_CENTER)

    $g_idLV_ScriptConfig = GUICtrlCreateListView("", 20, 106, 360, 200, $LVS_REPORT+$LVS_SINGLESEL+$LVS_NOSORTHEADER)
    $g_hLV_ScriptConfig = GUICtrlGetHandle($g_idLV_ScriptConfig)
    _GUICtrlListView_SetExtendedListViewStyle($g_hLV_ScriptConfig, $LVS_EX_FULLROWSELECT+$LVS_EX_GRIDLINES)
    _GUICtrlListView_AddColumn($g_hLV_ScriptConfig, "Setting", 116, 0)
    _GUICtrlListView_AddColumn($g_hLV_ScriptConfig, "Value (Double click to edit)", 244, 0)
    ;hidden
    _GUICtrlListView_AddColumn($g_hLV_ScriptConfig, "Description", 0) 
    _GUICtrlListView_AddColumn($g_hLV_ScriptConfig, "Type", 0) 
    _GUICtrlListView_AddColumn($g_hLV_ScriptConfig, "Type Values", 0) 
    ;end hidden
    ;ControlDisable("", "", HWnd(_GUICtrlListView_GetHeader($g_hLV_ScriptConfig))) ;Prevents changing column size

    $g_hLbl_ConfigDescription = GUICtrlCreateLabel("Click on a setting for a description.", 20, 310, 360, 54, $WS_BORDER+$SS_CENTER)

    GUICtrlSetResizing($g_idLbl_Scripts, $GUI_DOCKTOP+$GUI_DOCKHCENTER+$GUI_DOCKVCENTER+$GUI_DOCKSIZE)
    GUICtrlSetResizing($g_idCmb_Scripts, $GUI_DOCKTOP+$GUI_DOCKHCENTER+$GUI_DOCKVCENTER+$GUI_DOCKSIZE)
    GUICtrlSetResizing($g_idBtn_Start, $GUI_DOCKTOP+$GUI_DOCKHCENTER+$GUI_DOCKVCENTER+$GUI_DOCKSIZE)

    GUICtrlSetResizing($g_hLbl_ScriptDescription, $GUI_DOCKTOP+$GUI_DOCKHEIGHT)
    GUICtrlSetResizing($g_idLV_ScriptConfig, $GUI_DOCKTOP+$GUI_DOCKBOTTOM)
    GUICtrlSetResizing($g_hLbl_ConfigDescription, $GUI_DOCKBOTTOM+$GUI_DOCKHEIGHT)

;################################################## END SCRIPT TAB ##################################################

;################################################## LOG TAB ##################################################
    GUICtrlCreateTabItem("Log")

    GUISetFont(11)
    $g_idLbl_RunningScript = GUICtrlCreateLabel("Running Script: " & $g_sScript, 0, 32, 400, -1, $SS_CENTER)
    $g_idLbl_ScriptTime = GUICtrlCreateLabel("Time: ", 34, 55, 242, 21, $WS_BORDER+$SS_CENTER)
    GUISetFont(8.5)

    $g_idBtn_Stop = GUICtrlCreateButton("Stop", 278, 54, 40, 23)
    $g_hBtn_Stop = GUICtrlGetHandle($g_idBtn_Stop)
    $g_idBtn_Pause = GUICtrlCreateButton("Pause", 318, 54, 50, 23)
    $g_hBtn_Pause = GUICtrlGetHandle($g_idBtn_Pause)
    ControlDisable("", "", $g_hBtn_Pause)
    ControlDisable("", "", $g_hBtn_Stop)

    $g_idLV_Stat = GUICtrlCreateListView("", 20, 86, 357, 140, $LVS_REPORT+$LVS_SINGLESEL+$LVS_NOSORTHEADER)
    $g_hLV_Stat = GUICtrlGetHandle($g_idLV_Stat)
    _GUICtrlListView_SetExtendedListViewStyle($g_hLV_Stat, $LVS_EX_FULLROWSELECT+$LVS_EX_GRIDLINES)
    _GUICtrlListView_AddColumn($g_hLV_Stat, "Stat", 116, 0)
    _GUICtrlListView_AddColumn($g_hLV_Stat, "Value", 241, 0)

    BuildLogArea()

    GUICtrlSetResizing($g_idLbl_RunningScript, $GUI_DOCKTOP+$GUI_DOCKHCENTER+$GUI_DOCKSIZE)

    GUICtrlSetResizing($g_idLbl_ScriptTime, $GUI_DOCKTOP+$GUI_DOCKHCENTER+$GUI_DOCKVCENTER+$GUI_DOCKSIZE)
    GUICtrlSetResizing($g_idBtn_Stop, $GUI_DOCKTOP+$GUI_DOCKHCENTER+$GUI_DOCKVCENTER+$GUI_DOCKSIZE)
    GUICtrlSetResizing($g_idBtn_Pause, $GUI_DOCKTOP+$GUI_DOCKHCENTER+$GUI_DOCKVCENTER+$GUI_DOCKSIZE)

;################################################## END LOG TAB ##################################################

;################################################## SCHEDULE TAB ##################################################
    GUICtrlCreateTabItem("Schedule")
    GUISetFont(11)
    $g_idLbl_Schedule = GUICtrlCreateLabel("Schedule List (Note: time uses 24h system)", 0, 28, 400, -1, $SS_CENTER)
    GUISetFont(8.5)

    $g_idCheck_Enable = GUICtrlCreateCheckbox("Enable", 20, 50, 70, 23)

    $g_idBtn_Add = GUICtrlCreateButton("Add...", 104, 50, 70, 23)
    $g_hBtn_Add = GUICtrlGetHandle($g_idBtn_Add)

    $g_idBtn_Save = GUICtrlCreateButton("Save...", 177, 50, 70, 23)
    $g_hBtn_Save = GUICtrlGetHandle($g_idBtn_Save)

    $g_idBtn_Edit = GUICtrlCreateButton("Edit...", 250, 50, 70, 23)
    $g_hBtn_Edit = GUICtrlGetHandle($g_idBtn_Edit)

    $g_idBtn_Remove = GUICtrlCreateButton("Remove", 323, 50, 70, 23)
    $g_hBtn_Remove = GUICtrlGetHandle($g_idBtn_Remove)

    $g_idLV_Schedule = GUICtrlCreateListview("", 5, 75, 389, 295, $LVS_SHOWSELALWAYS)
    $g_hLV_Schedule = GUICtrlGetHandle($g_idLV_Schedule)
    _GUICtrlListView_SetExtendedListViewStyle($g_hLV_Schedule, $LVS_EX_FULLROWSELECT+$LVS_EX_GRIDLINES)
    _GUICtrlListView_AddColumn($g_hLV_Schedule, "Name", 100, 0)
    _GUICtrlListView_AddColumn($g_hLV_Schedule, "Action", 100, 0)
    _GUICtrlListView_AddColumn($g_hLV_Schedule, "Type", 50, 0)
    _GUICtrlListView_AddColumn($g_hLV_Schedule, "Interation", 50, 0)
    _GUICtrlListView_AddColumn($g_hLV_Schedule, "Structure", 1000, 0)

    GUICtrlSetResizing($g_idLbl_Schedule, $GUI_DOCKTOP+$GUI_DOCKHCENTER+$GUI_DOCKSIZE)

    GUICtrlSetResizing($g_idCheck_Enable, $GUI_DOCKTOP+$GUI_DOCKLEFT+$GUI_DOCKSIZE)
    GUICtrlSetResizing($g_idBtn_Add, $GUI_DOCKTOP+$GUI_DOCKRIGHT+$GUI_DOCKSIZE)
    GUICtrlSetResizing($g_idBtn_Save, $GUI_DOCKTOP+$GUI_DOCKRIGHT+$GUI_DOCKSIZE)
    GUICtrlSetResizing($g_idBtn_Edit, $GUI_DOCKTOP+$GUI_DOCKRIGHT+$GUI_DOCKSIZE)
    GUICtrlSetResizing($g_idBtn_Remove, $GUI_DOCKTOP+$GUI_DOCKRIGHT+$GUI_DOCKSIZE)

    GUICtrlSetResizing($g_idLV_Schedule, $GUI_DOCKBORDERS)

;################################################## END SCHEDULE TAB ##################################################

;################################################## STATS TAB ##################################################
    GUICtrlCreateTabItem("Stats")

    $g_idBtn_StatReset = GUICtrlCreateButton("Reset", 320, 25, 70, 23)
    $g_hBtn_StatReset = GUICtrlGetHandle($g_idBtn_StatReset)

    GUISetFont(10)
    $g_idLbl_Stat = GUICtrlCreateLabel("Cumulative stats (Last reset: Never)", 10, 27, 400, 23)
    GUISetFont(8.5)

    $g_idLV_OverallStats = GUICtrlCreateListView("", 5, 50, 389, 300)
    $g_hLV_OverallStats = GUICtrlGetHandle($g_idLV_OverallStats)
    _GUICtrlListView_SetExtendedListViewStyle($g_hLV_OverallStats, $LVS_EX_FULLROWSELECT+$LVS_EX_GRIDLINES)
    _GUICtrlListView_AddColumn($g_hLV_OverallStats, "Stat", 250, 0)
    _GUICtrlListView_AddColumn($g_hLV_OverallStats, "Value", 145, 0)

    Global $hLbl_StatMessage = GUICtrlCreateLabel("Support MSL Bot by donating! For more details click on the Donate tab.", 5, 355, 389, 17, $WS_BORDER+$SS_CENTER)

    GuiCtrlSetResizing($g_idLbl_Stat, $GUI_DOCKTOP+$GUI_DOCKLEFT+$GUI_DOCKSIZE)
    GUICtrlSetResizing($g_idBtn_StatReset, $GUI_DOCKTOP+$GUI_DOCKRIGHT+$GUI_DOCKSIZE)
    GUICtrlSetResizing($g_idLV_OverallStats, $GUI_DOCKBORDERS)

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

    Script_ChangeConfig()
    _GUICtrlTab_ActivateTab($g_hTb_Main, 0)

    ;Register WM_COMMAND and WM_NOTIFY for UDF controls
    GUIRegisterMsg($WM_COMMAND, "WM_COMMAND")
    GUIRegisterMsg($WM_NOTIFY, "WM_NOTIFY")

    WinMove($g_hParent, "", (@DesktopWidth / 2)-200, (@DesktopHeight / 2)-200, 400, 420)
    Cumulative_Load()
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
        If $Config_Ask_For_Updates = True Then
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
        RunWait('"' & @AutoItExe & '" /AutoIt3ExecuteScript "' & @ScriptDir & '\msl-bot-update.au3" -hwnd ' & String($g_hParent) & " -sd")
    Else
        MsgBox($MB_ICONERROR, "MSL Bot Update", "Could not download update file.")
    EndIf
EndFunc

Func BuildLogArea($bSeperateWindow = False)
    Local $aControlPos = ControlGetPos("","",$g_hLV_Stat)
    If ($bSeperateWindow) Then 
        ControlMove("", "", $g_hLV_Stat, $aControlPos[0], $aControlPos[1], $aControlPos[2], 130)
    EndIf
    $g_idBtn_Detach = GUICtrlCreateButton("Detach", 297, 232, 57, 23)

    $g_idCkb_Information = GUICtrlCreateCheckbox("Info", 32, 232, 57, 23)
    GUICtrlSetState(-1, $GUI_CHECKED)
    $g_idCkb_Error = GUICtrlCreateCheckbox("Error", 90, 232, 57, 23)
    GUICtrlSetState(-1, $GUI_CHECKED)
    $g_idCkb_Process = GUICtrlCreateCheckbox("Process", 148, 232, 57, 23)
    GUICtrlSetState(-1, $GUI_CHECKED)
    $g_idCkb_Debug = GUICtrlCreateCheckbox("Debug", 216, 232, 57, 23)
    GUICtrlSetState(-1, $GUI_UNCHECKED)

    $g_idLV_Log = GUICtrlCreateListView("", $aControlPos[0], 256, $aControlPos[2], 100, $LVS_REPORT+$LVS_NOSORTHEADER)
    $g_hLV_Log = GUICtrlGetHandle($g_idLV_Log)
    _GUICtrlListView_SetExtendedListViewStyle($g_hLV_Log, $LVS_EX_FULLROWSELECT+$LVS_EX_GRIDLINES)
    _GUICtrlListView_AddColumn($g_hLV_Log, "Time", 76, 0)
    _GUICtrlListView_AddColumn($g_hLV_Log, "Text", 300, 0)
    _GUICtrlListView_AddColumn($g_hLV_Log, "Type", 100, 0)
    _GUICtrlListView_AddColumn($g_hLV_Log, "Function", 100, 0)
    _GUICtrlListView_AddColumn($g_hLV_Log, "Location", 100, 0)
    _GUICtrlListView_AddColumn($g_hLV_Log, "Level", 100, 0)
    _GUICtrlListView_JustifyColumn($g_hLV_Log, 0, 0)
    _GUICtrlListView_JustifyColumn($g_hLV_Log, 1, 0)

    GUICtrlSetResizing($g_idCkb_Information, $GUI_DOCKBOTTOM+$GUI_DOCKHEIGHT)
    GUICtrlSetResizing($g_idCkb_Error, $GUI_DOCKBOTTOM+$GUI_DOCKHEIGHT)
    GUICtrlSetResizing($g_idCkb_Process, $GUI_DOCKBOTTOM+$GUI_DOCKHEIGHT)
    GUICtrlSetResizing($g_idCkb_Debug, $GUI_DOCKBOTTOM+$GUI_DOCKHEIGHT)
    
    GUICtrlSetResizing($g_idLV_Log, $GUI_DOCKBOTTOM+$GUI_DOCKHEIGHT)
    GUICtrlSetResizing($g_idLV_Stat, $GUI_DOCKTOP+$GUI_DOCKBOTTOM)
    GUICtrlSetResizing($g_idBtn_Detach, $GUI_DOCKBOTTOM+$GUI_DOCKHEIGHT)
EndFunc