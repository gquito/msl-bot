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
                                                GUICtrlCreateMenuItem("", $Menu_General)
    Global $M_General_Toggle_Hidden =           GUICtrlCreateMenuItem("Toggle Hidden", $Menu_General)                                          

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

    Global $Menu_Gem =                  GUICtrlCreateMenu("Gem")
    Global $M_Gem_Gem_Window =              GUICtrlCreateMenuItem("Gem Window...", $Menu_Gem)

    Global $Menu_Pixel =                    GUICtrlCreateMenu("Pixel", $Menu_Debug)
    Global $M_Pixel_Check_Pixel =               GUICtrlCreateMenuItem("Check Pixel...", $Menu_Pixel)
    Global $M_Pixel_Set_Pixel =                 GUICtrlCreateMenuItem("Set Pixel...", $Menu_Pixel)
    Global $M_Pixel_Get_Color =                 GUICtrlCreateMenuItem("Get Color...", $Menu_Pixel)
    
    Global $Menu_Scripts =              GUICtrlCreateMenu("Scripts")
    Global $M_Scripts_Hourly =              GUICtrlCreateMenuItem("Hourly", $Menu_Scripts)
    Global $M_Scripts_Expedition =          GUICtrlCreateMenuItem("Expedition", $Menu_Scripts)
    Global $M_Scripts_Collect_Quest =       GUICtrlCreateMenuItem("Collect Quest", $Menu_Scripts)
    Global $M_Scripts_Collect_Inbox =       GUICtrlCreateMenuItem("Collect Inbox", $Menu_Scripts)
    Global $M_Scripts_Guardian_Dungeon =    GUICtrlCreateMenuItem("Guardian Dungeon", $Menu_Scripts)
                                            GUICtrlCreateMenuItem("", $Menu_Scripts)
    Global $M_Scripts_Titans_Fast =         GUICtrlCreateMenuItem("Toggle Titans Fast", $Menu_Scripts)


    Global $Menu_Capture =              GUICtrlCreateMenu("Capture")
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
    _GUICtrlListView_AddColumn($g_hLV_ScriptConfig, "Setting", 170, 0)
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

;################################################## VIEW TAB ##################################################
    GUICtrlCreateTabItem("Vision")

    $g_idPic = GUICtrlCreatePic("", 5, 55, 389, 389*(69/100), BitOR($GUI_SS_DEFAULT_PIC, $WS_BORDER))
    $g_hPic = GUICtrlGetHandle($g_idPic)

    $g_idBtn_CaptureRegion = GUICtrlCreateButton("Capture Region", 310, 25, -1, -1)
    $g_hBtn_CaptureRegion = GUICtrlGetHandle($g_idBtn_CaptureRegion)

    $g_idLbl_BotView = GUICtrlCreateLabel("Bot Vision:" & $g_sScript, 15, 32, 400, -1, $SS_LEFT)

    GUICtrlSetResizing($g_idLbl_BotView, $GUI_DOCKTOP+$GUI_DOCKLEFT)
    GUICtrlSetResizing($g_idBtn_CaptureRegion, $GUI_DOCKTOP+$GUI_DOCKRIGHT+$GUI_DOCKSIZE)
    GUICtrlSetResizing($g_idPic, $GUI_DOCKTOP+$GUI_DOCKLEFT+$GUI_DOCKRIGHT+$GUI_DOCKSIZE)

;################################################## END DONATE TAB ##################################################

;################################################## DONATE TAB ##################################################
    GUICtrlCreateTabItem("Donate")

    GUISetFont(10, 700)
    $g_idLbl_Donate = GUICtrlCreateLabel("Support me at: https://paypal.me/GkevinOD/10", 0, 50, 400, -1, $SS_CENTER+$WS_BORDER)
    GUICtrlSetCursor(-1, 0)
    GUISetFont(8.5, 0)

    GUICtrlCreateLabel("Those who donate a cumulative value of 10.00 USD will receive access to an exclusive donator version with extra features. ", 0, 80, 400, 40, $SS_CENTER)
    GUICtrlCreateLabel("Donating this amount will grant you a role in the community discord and access to the exclusive version through the role permissions.", 25, 120, 350, 40, $SS_CENTER)

    $g_idLbl_Discord = GUICtrlCreateLabel("For any questions contact me at: gkevinod@gmail.com" & @CRLF & "or private message via discord: https://discord.gg/UQGRnwf", 25, 160, 350, 40, $SS_CENTER)
    GUICtrlSetCursor(-1, 0)

    GUISetFont(10, 500)
    $g_idLbl_List = GUICtrlCreateLabel("Donator Features:" & @CRLF & @CRLF & "- AutoPVP" & @CRLF & "- Complete Dailies" & @CRLF & "- Complete Bingo" & @CRLF & "- Guided Auto" & @CRLF & "( click for complete list )", 0, 200, 400, -1, $SS_CENTER)
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

    WinMove($g_hParent, "", (@DesktopWidth / 2)-200, (@DesktopHeight / 2)-200, 438, 585)
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

Global $g_aPoint_UpdatePicture_Cache = Null
Func UpdatePicture($aCursor = $g_aPoint_UpdatePicture_Cache)
    If $g_hBitmap = 0 Or $g_hBitmap = Null Then Return -1
    If BitAnd(WinGetState($g_hParent), $WIN_STATE_MINIMIZED) = False And _GUICtrlTab_GetCurSel($g_hTb_Main) = 4 Then
        Local $aSize = ControlGetPos("", "", $g_hPic)
        Local $tagSize = _WinAPI_GetBitmapDimension($g_hBitmap)
        Local $aImageSize = [DllStructGetData($tagSize, 'X'), DllStructGetData($tagSize, 'Y')]
        If $aImageSize[0] = 0 Or $aImageSize[1] = 0 Then Return -1

        Local $hBitmap = _WinAPI_AdjustBitmap($g_hBitmap, $aSize[2]-2, ($aSize[2])*($aImageSize[1]/$aImageSize[0])-2)

        GUICtrlSetPos($g_idPic, $aSize[0], $aSize[1], $aSize[2], ($aSize[2])*($aImageSize[1]/$aImageSize[0]))
        _WinAPI_DeleteObject(GUICtrlSendMsg($g_idPic, $STM_SETIMAGE, $IMAGE_BITMAP, $hBitmap))
        _WinAPI_DeleteObject($hBitmap)

        Local $aPointer[2] = [0, 0]
        If isArray($aCursor) = True And isArray($aImageSize) = True Then
            $g_aPoint_UpdatePicture_Cache = $aCursor
            Local $iScaleX = $aImageSize[0]/($aSize[2]-2)
            Local $iScaleY = $aImageSize[1]/($aSize[3]-2)
            $aPointer[0] = Int(($aCursor[0]-($aSize[0]+1)) * $iScaleX)
            $aPointer[1] = Int(($aCursor[1]-($aSize[1]+1)) * $iScaleY)
        EndIf

        Local $iColor = getColor($aPointer[0], $aPointer[1])
        GUICtrlSetData($g_idLbl_BotView, "Bot Vision: (Control Handle: " & $g_hControl & _
                                         ", Location: " & getLocation(False, True) & _
                                         ", Size: " & $aImageSize[0] & "x" & $aImageSize[1] & _
                                         ", Cursor:" & $aPointer[0] & "," & $aPointer[1] & _
                                         ", Color: " & $iColor & ")")
        
        Local $aResult = CreateArr($aPointer[0], $aPointer[1], $iColor)
        ;ClipPut(_ArrayToString($aResult, ",")) ;DEBUG
        Return $aResult
    EndIf
EndFunc

Global $g_hCompatibilityTest = Null
Func ScriptTest_CreateGui($sMessage, ByRef $hBitmap)
    If $g_hCompatibilityTest <> Null Then Return SetError(1, 0, False)
    $g_hCompatibilityTest = GUICreate("MSL-Bot Compatibility Test", 823, 367, -1, -1, -1, -1, $g_hParent)
    Global $g_idCompatibilityTest_editMain = GUICtrlCreateEdit($sMessage, 10, 10, 296, 307, $WS_VSCROLL, -1)
    Global $g_idCompatibilityTest_picMain = GUICtrlCreatePic("", 309, 10, 507, 350, -1, -1)
    Global $g_idCompatibilityTest_btnClose = GUICtrlCreateButton("Close", 260, 330, 46, 30, -1, -1)
    Global $g_idCompatibilityTest_btnCopyText = GUICtrlCreateButton("Copy Text", 10, 330, 80, 30, -1, -1)
    Global $g_idCompatibilityTest_btnCopyImage = GUICtrlCreateButton("Copy as Image", 96, 330, 160, 30, -1, -1)
    
    GUISetState(@SW_SHOW, $g_hCompatibilityTest)

    Local $tagSize = _WinAPI_GetBitmapDimension($hBitmap)
    Local $aImageSize = [DllStructGetData($tagSize, 'X'), DllStructGetData($tagSize, 'Y')]
    If $aImageSize[0] = 0 Or $aImageSize[1] = 0 Then Return SetError(2, 0, False)

    Local $hAdjusted = _WinAPI_AdjustBitmap($hBitmap, 507, 350)

    _WinAPI_DeleteObject(GUICtrlSendMsg($g_idCompatibilityTest_picMain, $STM_SETIMAGE, $IMAGE_BITMAP, $hAdjusted))
    _WinAPI_DeleteObject($hAdjusted)

    Return $g_hCompatibilityTest
EndFunc

Global $g_hGemWindow = Null
Global $g_aGemWindow_GemsFound[0]
Global $g_iGemWindow_GemsFound = 0
Func GemWindow_CreateGui()
    If $g_hGemWindow <> Null Then Return SetError(1, 0, False)
    $g_hGemWindow = GUICreate("Gem Window", 327, 286, -1, -1, -1, -1, $g_hParent)
    Global $g_idGemWindow_tabMain = GUICtrlCreateTab(3, 1, 322, 282)
    GUICtrlSetResizing(-1, $GUI_DOCKAUTO+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
    Global $g_idGemWindow_pageFilter = GUICtrlCreateTabItem("Filter")
    Global $g_idGemWindow_lblAction = GUICtrlCreateLabel("Action:", 16, 33, 37, 17)
    Global $g_idGemWindow_cmbAction = GUICtrlCreateCombo("", 56, 31, 185, 25, BitOR($CBS_DROPDOWNLIST,$CBS_AUTOHSCROLL))
    GUICtrlSetData(-1, "Create...|Remove...|Save...|Help...", "Create...")
    Global $g_idGemWindow_btnGo = GUICtrlCreateButton("Go", 244, 29, 71, 25)
    Global $g_idGemWindow_lblCurrent = GUICtrlCreateLabel("Current Filter:", 16, 64, 66, 17)

    ;Combo items from files in gem_filters
    Global $g_idGemWindow_cmbFilter = GUICtrlCreateCombo("", 84, 62, 230, 25, BitOR($CBS_DROPDOWNLIST,$CBS_AUTOHSCROLL))
    Local $aFiles = _FileListToArray($g_sFilterFolder)
    If isArray($aFiles) = True And $aFiles[0] > 0 Then
        GUICtrlSetData(-1, _ArrayToString($aFiles, "|", 1), $aFiles[1])
    EndIf

    ;Set edit to file contents if it exists
    Local $sCurrent = GUICtrlRead(-1)
    Global $g_idGemWindow_editFilter = GUICtrlCreateEdit("", 10, 88, 306, 188, BitOR($ES_AUTOHSCROLL, $ES_WANTRETURN, $WS_HSCROLL))
    If $sCurrent <> "" Then
        Local $sContent = FileRead($g_sFilterFolder & $sCurrent)
        If @error Then GUICtrlSetData(-1, "Error: Could not load filter.")
        If @error = 0 Then GUICtrlSetData(-1, $sContent)
    EndIf

    GUICtrlSetFont(-1, 12, 400, 0, "MS Reference Sans Serif")
    Global $g_idGemWindow_pageGemsFound = GUICtrlCreateTabItem("Gems Found")
    Global $g_idGemWindow_btnNext = GUICtrlCreateButton("Next", 190, 250, 100, 25)
    Global $g_idGemWindow_btnPrevious = GUICtrlCreateButton("Previous", 37, 250, 100, 25)
    Global $g_idGemWindow_lblGemsFilter = GUICtrlCreateLabel("Filter:", 15, 36, 29, 17)
    Global $g_idGemWindow_inpFilter = GUICtrlCreateInput("Does not work yet", 44, 34, 190, 21)
    GUICtrlSetState(-1, $GUI_DISABLE)
    Global $g_idGemWindow_btnFilter = GUICtrlCreateButton("Filter", 237, 32, 75, 25)
    GUICtrlSetState(-1, $GUI_DISABLE)
    Global $g_idGemWindow_editGem = GUICtrlCreateEdit("", 11, 59, 304, 186, BitOR($ES_READONLY,$ES_WANTRETURN))
    GUICtrlSetData(-1, StringFormat("Gem #: 0/0\r\nStatus: N/A\r\nGrade: N/A\r\nShape: N/A\r\nStat: N/A\r\nSub1: N/A\r\nSub2: N/A\r\nSub3: N/A\r\nSub4: N/A"))
    GUICtrlSetFont(-1, 11, 400, 0, "MS Reference Sans Serif")

    GUISetState(@SW_SHOW)

    Return $g_hGemWindow
EndFunc

; [[handle, close_event_function]]
Global $g_hListEditor[0][2]
; [[listview, btn_moveup, btn_down, btn_remove, btn_add, combo]]
Global $g_hListEditor_Controls[0][6]
Func ListEditor_CreateGui($aCurrent, $aDefault, $sFunction)
    Local $aWinPos = WinGetPos($g_hParent)
    Local $x = -1, $y = -1
    If isArray($aWinPos) = True Then 
        $x = $aWinPos[0]+(($aWinPos[2]-150)/2)
        $y = $aWinPos[1]+(($aWinPos[3]-150)/2)
    EndIf
    Local $hListEditor = GUICreate("Edit List", 150, 182, $x, $y, -1, $WS_EX_TOPMOST, $g_hParent)
    
    Local $idListEditor_listMain = GUICtrlCreateListView("", 2, 2, 146, 100, $LVS_SINGLESEL+$LVS_REPORT+$LVS_NOSORTHEADER+$WS_BORDER, $LVS_EX_DOUBLEBUFFER+$LVS_EX_FULLROWSELECT+$LVS_EX_GRIDLINES)
    _GUICtrlListView_AddColumn($idListEditor_listMain, "-Included Values-", 125, 2)
    ControlDisable("", "", HWnd(_GUICtrlListView_GetHeader($idListEditor_listMain))) ;Prevents changing column size

    Local $idlistEditor_btnMoveUp = GUICtrlCreateButton("Move up", 2, 104, 72)
    Local $idlistEditor_btnMoveDown = GUICtrlCreateButton("Move down", 75, 104, 72)
    Local $idlistEditor_btnRemove = GUICtrlCreateButton("Remove", 2, 129, 145)
    Local $idlistEditor_btnAdd = GUICtrlCreateButton("Add", 2, 154, 42)

    Local $idlistEdit_cmbMain = GUICtrlCreateCombo("", 46, 155, 100, -1, $CBS_DROPDOWNLIST)
    _GUICtrlComboBox_SetItemHeight($idlistEdit_cmbMain, 17)

    ;Set values for listview and combo
    For $i = 0 To UBound($aCurrent)-1
        If ($aCurrent[$i] <> "") Then _GUICtrlListView_AddItem($idListEditor_listMain, $aCurrent[$i])

        ;Removing existing values from default to add those non exisiting in a combo later.
        For $j = UBound($aDefault)-1 To 0 Step -1
            If ($aDefault[$j] = $aCurrent[$i]) Then _ArrayDelete($aDefault, $j)
        Next
    Next

    If isArray($aDefault) Then GUICtrlSetData($idlistEdit_cmbMain, _ArrayToString($aDefault))
    _GUICtrlComboBox_SetCurSel($idlistEdit_cmbMain, 0)

    GUISetState(@SW_SHOW, $hListEditor)

    _WinAPI_SetFocus($hListEditor)
    _ArrayAdd($g_hListEditor, _ArrayToString(CreateArr($hListEditor, $sFunction)))
    _ArrayAdd($g_hListEditor_Controls, _ArrayToString(CreateArr($idListEditor_listMain, $idlistEditor_btnMoveUp, $idlistEditor_btnMoveDown, $idlistEditor_btnRemove, $idlistEditor_btnAdd, $idlistEdit_cmbMain)))
    Return $hListEditor
EndFunc