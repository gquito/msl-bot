#include-once
#include "../imports.au3"

Func CreateGUI()
    Local $GUI_FONTSIZE = 11
    $g_hParent = GUICreate($g_sAppTitle, 400, 420, -9999, -9999, $WS_SIZEBOX+$WS_MAXIMIZEBOX+$WS_MINIMIZEBOX)
    WinSetTitle($g_hParent, "", $g_sAppTitle & UpdateStatus())
    GUISetBkColor(0xFFFFFF)

    $g_aDpiSettings = getScreenScaling()

    _GUISetFont(8.5)
    GUISetState(@SW_SHOW, $g_hParent)
    _WINAPI_Setfocus($g_hParent)

    BuildNavBarMenus()
    ;--------------------------------------------------------
    
    $g_idTb_Main = _GUICtrlCreateTab(0, 0, 400, 380, $TCS_TOOLTIPS+$WS_TABSTOP+$WS_CLIPSIBLINGS+$TCS_FIXEDWIDTH)
    $g_hTb_Main = GUICtrlGetHandle($g_idTb_Main)
    __GUICtrlTab_SetItemSize($g_hTb_Main, 60, 18)

    GUICtrlSetResizing($g_idTb_Main, $GUI_DOCKBORDERS)
;################################################## SCRIPT TAB ##################################################
    GUICtrlCreateTabItem("Script")

    GUISetFont(11)
    $g_idLbl_Scripts = _GUICtrlCreateLabel("Select a script:", 50, 32, 96)
    GUISetFont(8.5)

    $g_idCmb_Scripts = _GUICtrlCreateCombo("_Config", 146, 30, 150, -1, $CBS_DROPDOWNLIST)
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

    $g_idBtn_Start = _GUICtrlCreateButton("Start", 298, 29, 50, 23)
    $g_hBtn_Start = GUICtrlGetHandle($g_idBtn_Start)
    ControlDisable("", "", $g_hBtn_Start)

    $g_hLbl_ScriptDescription = _GUICtrlCreateLabel("Select a script for a description of the process", 20, 56, 360, 46, $WS_BORDER+$SS_CENTER)

    $g_idLV_ScriptConfig = _GUICtrlCreateListView("", 20, 106, 360, 200, $LVS_REPORT+$LVS_SINGLESEL+$LVS_NOSORTHEADER)
    $g_hLV_ScriptConfig = GUICtrlGetHandle($g_idLV_ScriptConfig)
    _GUICtrlListView_SetExtendedListViewStyle($g_hLV_ScriptConfig, $LVS_EX_FULLROWSELECT+$LVS_EX_GRIDLINES)
    __GUICtrlListView_AddColumn($g_hLV_ScriptConfig, "Setting", 116, 0)
    __GUICtrlListView_AddColumn($g_hLV_ScriptConfig, "Value (Double click to edit)", 244, 0)
    ;hidden
    __GUICtrlListView_AddColumn($g_hLV_ScriptConfig, "Description", 0) 
    __GUICtrlListView_AddColumn($g_hLV_ScriptConfig, "Type", 0) 
    __GUICtrlListView_AddColumn($g_hLV_ScriptConfig, "Type Values", 0) 
    ;end hidden
    ;ControlDisable("", "", HWnd(_GUICtrlListView_GetHeader($g_hLV_ScriptConfig))) ;Prevents changing column size

    $g_hLbl_ConfigDescription = _GUICtrlCreateLabel("Click on a setting for a description.", 20, 310, 360, 54, $WS_BORDER+$SS_CENTER)

    GUICtrlSetResizing($g_idLbl_Scripts, $GUI_DOCKTOP+$GUI_DOCKHCENTER+$GUI_DOCKVCENTER+$GUI_DOCKSIZE)
    GUICtrlSetResizing($g_idCmb_Scripts, $GUI_DOCKTOP+$GUI_DOCKHCENTER+$GUI_DOCKVCENTER+$GUI_DOCKSIZE)
    GUICtrlSetResizing($g_idBtn_Start, $GUI_DOCKTOP+$GUI_DOCKHCENTER+$GUI_DOCKVCENTER+$GUI_DOCKSIZE)

    GUICtrlSetResizing($g_hLbl_ScriptDescription, $GUI_DOCKTOP+$GUI_DOCKHEIGHT)
    GUICtrlSetResizing($g_idLV_ScriptConfig, $GUI_DOCKTOP+$GUI_DOCKBOTTOM)
    GUICtrlSetResizing($g_hLbl_ConfigDescription, $GUI_DOCKBOTTOM+$GUI_DOCKHEIGHT)

;################################################## END SCRIPT TAB ##################################################

;################################################## LOG TAB ##################################################
    GUICtrlCreateTabItem("Log")

    _GUISetFont(11)
    $g_idLbl_RunningScript = _GUICtrlCreateLabel("Running Script: " & $g_sScript, 0, 32, 400, -1, $SS_CENTER)
    $g_idLbl_ScriptTime = _GUICtrlCreateLabel("Time: ", 34, 55, 242, 21, $WS_BORDER+$SS_CENTER)
    _GUISetFont(8.5)

    $g_idBtn_Stop = _GUICtrlCreateButton("Stop", 278, 54, 40, 23)
    $g_hBtn_Stop = GUICtrlGetHandle($g_idBtn_Stop)
    $g_idBtn_Pause = _GUICtrlCreateButton("Pause", 318, 54, 50, 23)
    $g_hBtn_Pause = GUICtrlGetHandle($g_idBtn_Pause)
    ControlDisable("", "", $g_hBtn_Pause)
    ControlDisable("", "", $g_hBtn_Stop)

    $g_idLV_Stat = _GUICtrlCreateListView("", 20, 86, 357, 140, $LVS_REPORT+$LVS_SINGLESEL+$LVS_NOSORTHEADER)
    $g_hLV_Stat = GUICtrlGetHandle($g_idLV_Stat)
    _GUICtrlListView_SetExtendedListViewStyle($g_hLV_Stat, $LVS_EX_FULLROWSELECT+$LVS_EX_GRIDLINES)
    __GUICtrlListView_AddColumn($g_hLV_Stat, "Stat", 116, 0)
    __GUICtrlListView_AddColumn($g_hLV_Stat, "Value", 241, 0)

    BuildLogArea()

    GUICtrlSetResizing($g_idLbl_RunningScript, $GUI_DOCKTOP+$GUI_DOCKHCENTER+$GUI_DOCKSIZE)

    GUICtrlSetResizing($g_idLbl_ScriptTime, $GUI_DOCKTOP+$GUI_DOCKHCENTER+$GUI_DOCKVCENTER+$GUI_DOCKSIZE)
    GUICtrlSetResizing($g_idBtn_Stop, $GUI_DOCKTOP+$GUI_DOCKHCENTER+$GUI_DOCKVCENTER+$GUI_DOCKSIZE)
    GUICtrlSetResizing($g_idBtn_Pause, $GUI_DOCKTOP+$GUI_DOCKHCENTER+$GUI_DOCKVCENTER+$GUI_DOCKSIZE)

;################################################## END LOG TAB ##################################################

;################################################## STATS TAB ##################################################
    GUICtrlCreateTabItem("Stats")

    $g_idBtn_StatReset = _GUICtrlCreateButton("Reset", 320, 25, 70, 23)
    $g_hBtn_StatReset = GUICtrlGetHandle($g_idBtn_StatReset)

    _GUISetFont(10)
    $g_idLbl_Stat = _GUICtrlCreateLabel("Cumulative stats (Last reset: Never)", 10, 27, 400, 23)
    _GUISetFont(8.5)

    $g_idLV_OverallStats = _GUICtrlCreateListview("", 5, 50, 389, 300)
    $g_hLV_OverallStats = GUICtrlGetHandle($g_idLV_OverallStats)
    _GUICtrlListView_SetExtendedListViewStyle($g_hLV_OverallStats, $LVS_EX_FULLROWSELECT+$LVS_EX_GRIDLINES)
    __GUICtrlListView_AddColumn($g_hLV_OverallStats, "Stat", 250, 0)
    __GUICtrlListView_AddColumn($g_hLV_OverallStats, "Value", 145, 0)

    ;Updating cumulative stats
    Stat_Read($g_aStats)
    Stat_Update($g_aStats, $g_hLV_OverallStats)

    ;Global $hLbl_StatMessage = GUICtrlCreateLabel("Support MSL Bot by donating! For more details click on the Donate tab.", 5, 355, 389, 17, $WS_BORDER+$SS_CENTER)

    GuiCtrlSetResizing($g_idLbl_Stat, $GUI_DOCKTOP+$GUI_DOCKLEFT+$GUI_DOCKSIZE)
    GUICtrlSetResizing($g_idBtn_StatReset, $GUI_DOCKTOP+$GUI_DOCKRIGHT+$GUI_DOCKSIZE)
    GUICtrlSetResizing($g_idLV_OverallStats, $GUI_DOCKBORDERS)

    ;GUICtrlSetResizing($hLbl_StatMessage, $GUI_DOCKBOTTOM+$GUI_DOCKHEIGHT)

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
    _GUICtrlTab_ActivateTab($g_hTb_Main, 0)

    ;Register WM_COMMAND and WM_NOTIFY for UDF controls
    GUIRegisterMsg($WM_COMMAND, "WM_COMMAND")
    GUIRegisterMsg($WM_NOTIFY, "WM_NOTIFY")

    _WinMove($g_hParent, "", (@DesktopWidth / 2)-200, (@DesktopHeight / 2)-200, 400, 420)
    GUIMain()
EndFunc

Func BuildNavBarMenus()

    $g_hM_FileMenu = GUICtrlCreateMenu("File")
    ;$g_hM_RebootBot = GUICtrlCreateMenuItem("Reboot Bot", $g_hM_FileMenu)
    $g_hM_RestartNox = GUICtrlCreateMenuItem("Restart Nox", $g_hM_FileMenu)
    $g_hM_RestartGame = GUICtrlCreateMenuItem("Restart Game", $g_hM_FileMenu)
    GUICtrlCreateMenuItem("", $g_hM_FileMenu)
    $g_hM_ForceQuit = GUICtrlCreateMenuItem("Quit (Ctrl+Q)", $g_hM_FileMenu)

    $g_hM_ScriptMenu = GUICtrlCreateMenu("Script Control")
    $g_hM_PauseScript = GUICtrlCreateMenuItem("Pause Script ({Pause})", $g_hM_ScriptMenu)
    $g_hM_StopScript = GUICtrlCreateMenuItem("Stop Script (Shift+{Pause})", $g_hM_ScriptMenu)

    $g_hM_DebugMenu = GUICtrlCreateMenu("Debug")
    $g_hM_GeneralMenu = GUICtrlCreateMenu("General Functions", $g_hM_DebugMenu)
    $g_hM_DebugInput = GUICtrlCreateMenuItem("Debug Input (Ctrl+D)", $g_hM_GeneralMenu)
    $g_hM_ScriptTest = GUICtrlCreateMenuItem("Run Compatibility Test (Ctrl+T)", $g_hM_GeneralMenu)
    $g_hM_GetAdbDevices = GUICtrlCreateMenuItem("Get Adb Device List", $g_hM_GeneralMenu)
    $g_hM_IsGameRunning = GUICtrlCreateMenuItem("Is Game Running", $g_hM_GeneralMenu)
    $g_hM_IsAdbWorking = GUICtrlCreateMenuItem("Is ADB Working", $g_hM_GeneralMenu)
    $g_hM_LocationMenu = GUICtrlCreateMenu("Location Functions", $g_hM_DebugMenu)
    $g_hM_Navigate = GUICtrlCreateMenuItem("Navigate To", $g_hM_LocationMenu)
    $g_hM_GetLocation = GUICtrlCreateMenuItem("Get Location", $g_hM_LocationMenu)
    $g_hM_SetLocation = GUICtrlCreateMenuItem("Update Location", $g_hM_LocationMenu)
    $g_hM_SetNewLocation = GUICtrlCreateMenuItem("Set New Location", $g_hM_LocationMenu)
    $g_hM_TestLocation = GUICtrlCreateMenuItem("Test Location", $g_hM_LocationMenu)
    $g_hM_PixelMenu = GUICtrlCreateMenu("Pixel Functions", $g_hM_DebugMenu)
    $g_hM_isPixel = GUICtrlCreateMenuItem("Is Pixel", $g_hM_PixelMenu)
    $g_hM_SetPixel = GUICtrlCreateMenuItem("Set Pixel", $g_hM_PixelMenu)
    $g_hM_getColor = GUICtrlCreateMenuItem("Get Color", $g_hM_PixelMenu)
    
    $g_hM_RunScriptsMenu = GUICtrlCreateMenu("Run Scripts")
    $g_hM_Evolve3 = GUICtrlCreateMenuItem("Run Evolve3", $g_hM_RunScriptsMenu)
    GUICtrlCreateMenuItem("",$g_hM_RunScriptsMenu)
    $g_hM_HourlyMenu = GUICtrlCreateMenu("Hourly Scripts", $g_hM_RunScriptsMenu)
    $g_hM_GetAirshipPosition = GUICtrlCreateMenuItem("Get Airship Position (Ctrl+P)",$g_hM_HourlyMenu)
    $g_hM_DoHourly = GUICtrlCreateMenuItem("Run Hourly Script (Ctrl+H)",$g_hM_HourlyMenu)
    
    $g_hM_CaptureMenu = GuiCtrlCreateMenu("Capture")
    $g_hM_FullScreenshot = GUICtrlCreateMenuItem("Full Screenshot", $g_hM_CaptureMenu)
    $g_hM_PartialScreenshot = GUICtrlCreateMenuItem("Partial Screenshot", $g_hM_CaptureMenu)
    $g_hM_OpenScreenshotFolder = GUICtrlCreateMenuItem("Open Screenshots Folder", $g_hM_CaptureMenu)
    
    Local $aAccelKeys[12][2] = [ _
        ["^q", $g_hM_ForceQuit], _
        ["^d", $g_hM_DebugInput], _
        ["^t", $g_hM_ScriptTest], _
        ["^h", $g_hM_DoHourly], _
        ["+^c", $g_hM_FullScreenshot], _
        ["!^c", $g_hM_PartialScreenshot], _
        ["{PAUSE}", $g_hM_PauseScript], _
        ["+{PAUSE}", $g_hM_StopScript], _
        ["^p", $g_hM_GetAirshipPosition], _
        ["^n", $g_hM_Navigate], _
        ["+^r", $g_hM_RestartNox], _
        ["!^r", $g_hM_RestartGame] _
        ]
    GUISetAccelerators($aAccelKeys)
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

Func BuildLogArea($bSeperateWindow = False)
    Local $aControlPos = ControlGetPos("","",$g_hLV_Stat)
    If ($bSeperateWindow) Then 
        _ControlMove("", "", $g_hLV_Stat, $aControlPos[0], $aControlPos[1], $aControlPos[2], 130)
    EndIf
    $g_idBtn_Detach = _GUICtrlCreateButton("Detach", 297, 232, 57, 23)

    $g_idCkb_Information = _GUICtrlCreateCheckbox("Info", 32, 232, 57, 23)
    GUICtrlSetState(-1, $GUI_CHECKED)
    $g_idCkb_Error = _GUICtrlCreateCheckbox("Error", 90, 232, 57, 23)
    GUICtrlSetState(-1, $GUI_CHECKED)
    $g_idCkb_Process = _GUICtrlCreateCheckbox("Process", 148, 232, 57, 23)
    GUICtrlSetState(-1, $GUI_CHECKED)
    $g_idCkb_Debug = _GUICtrlCreateCheckbox("Debug", 216, 232, 57, 23)
    GUICtrlSetState(-1, $GUI_UNCHECKED)

    $g_idLV_Log = _GUICtrlCreateListView("", $aControlPos[0], 256, $aControlPos[2], 100, $LVS_REPORT+$LVS_NOSORTHEADER)
    $g_hLV_Log = GUICtrlGetHandle($g_idLV_Log)
    _GUICtrlListView_SetExtendedListViewStyle($g_hLV_Log, $LVS_EX_FULLROWSELECT+$LVS_EX_GRIDLINES)
    __GUICtrlListView_AddColumn($g_hLV_Log, "Time", 76, 0)
    __GUICtrlListView_AddColumn($g_hLV_Log, "Text", 300, 0)
    __GUICtrlListView_AddColumn($g_hLV_Log, "Type", 100, 0)
    __GUICtrlListView_AddColumn($g_hLV_Log, "Function", 100, 0)
    __GUICtrlListView_AddColumn($g_hLV_Log, "Location", 100, 0)
    __GUICtrlListView_AddColumn($g_hLV_Log, "Level", 100, 0)
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