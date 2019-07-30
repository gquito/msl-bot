#include-once
#include "../../_src/global.au3"

Global $g_hScriptTimer = Null ;Timer for script
Global $g_hHBitmap = Null ;WINAPI bitmap handle.
Global $g_hBitmap = Null ;GDIPlus bitmap handle.
Global $g_hWindow = Null ;Handle for emulator window
Global $g_hControl = Null ;Handle for control window
Global $g_hLogWindow = Null
Global $g_hParent = Null

Global $g_hPromptsWindow = Null
Global $g_idPromptsWindow_Done = Null
Global $g_idPromptsWindow_Cancel = Null
Global $g_idPromptsWindow_Help = Null
Global $g_hPromptsWindow_HelpWindow = Null
Global $g_hPromptsWindow_Parent = Null
GLOBAL CONST $PROMPTWINDOW_CLOSE = 133742069

Global $g_aPromptsWindow_txtPrompts = Null
Global $g_aPromptsWindow_Answers = Null
Global $g_iPromptsWindow_AnswersID = Null
Global $g_sPromptsWindow_Help = Null

Global $g_hMessageBox = Null
Global $g_idEditMessage = Null

Global $g_hCurrentEdit = Null

;Menu Handles
Global $g_hM_FileMenu = Null
    Global $g_hM_RebootBot = Null
    Global $g_hM_RestartNox = Null
    Global $g_hM_RestartGame = Null
    Global $g_hM_ForceQuit = Null

Global $g_hM_DebugMenu = Null
    Global $g_hM_GeneralMenu = Null
        Global $g_hM_GetAdbDevices = Null
        Global $g_hM_IsGameRunning = Null
        Global $g_hM_IsAdbWorking = Null
        Global $g_hM_DebugInput = Null
        Global $g_hM_ScriptTest = Null
    Global $g_hM_LocationMenu = Null
        Global $g_hM_GetLocation = Null
        Global $g_hM_SetLocation = Null
        Global $g_hM_SetNewLocation = Null
        Global $g_hM_TestLocation = Null
        Global $g_hM_Navigate = Null
    Global $g_hM_PixelMenu = Null
        Global $g_hM_isPixel = Null
        Global $g_hM_SetPixel = Null
        Global $g_hM_getColor = Null

Global $g_hM_ScriptMenu = Null
    Global $g_hM_PauseScript = Null
    Global $g_hM_StopScript = Null
    
Global $g_hM_RunScriptsMenu = Null
    Global $g_hM_DoDailies = Null
    Global $g_hM_Evolve3 = Null
    Global $g_hM_HourlyMenu = Null
        Global $g_hM_GetAirshipPosition = Null
        Global $g_hM_DoHourly = Null

Global $g_hM_CaptureMenu = Null
    Global $g_hM_FullScreenshot = Null
    Global $g_hM_PartialScreenshot = Null
    Global $g_hM_OpenScreenshotFolder = Null

;UI Handles
Global $g_idTb_Main = Null
Global $g_hTb_Main = Null
Global $g_idLbl_Scripts = Null
Global $g_idCmb_Scripts = Null
Global $g_hCmb_Scripts = Null
Global $g_idBtn_Start = Null
Global $g_hBtn_Start = Null
Global $g_hLbl_ScriptDescription = Null

Global $g_idLV_ScriptConfig = Null
Global $g_hLV_ScriptConfig = Null
Global $g_hLbl_ConfigDescription = Null
Global $g_idLbl_RunningScript = Null
Global $g_idLbl_ScriptTime = Null
Global $g_idBtn_Stop = Null
Global $g_hBtn_Stop = Null
Global $g_idBtn_Pause = Null
Global $g_hBtn_Pause = Null
Global $g_idLV_Stat = Null
Global $g_hLV_Stat = Null
Global $g_idBtn_Detach = Null
Global $g_idCkb_Information = Null
Global $g_idCkb_Error = Null
Global $g_idCkb_Process = Null
Global $g_idCkb_Debug = Null
Global $g_idLV_Log = Null
Global $g_idBtn_StatReset = Null
Global $g_hBtn_StatReset = Null
Global $g_idLbl_Stat = Null
Global $g_idLV_OverallStats = Null
Global $g_hLV_OverallStats = Null
Global $g_idLbl_Donate = Null
Global $g_idLbl_Discord = Null
Global $g_hLV_Log = Null ;Log Listview Handle
Global $g_hLV_Stat = Null ;Stats Listview Handle
Global $g_hEditConfig = Null ;Handle for the edit control created when editing a setting.

Global $g_hLV_FunctionLevels = Null
Global $g_idLV_FunctionLevels = Null
Global $g_old_hControl = Null

;Timer Handles
Global $g_hTimerLocation = Null ;Global timer for location. Used for antiStuck
Global $g_hGetLocationCoolDown = TimerInit() ;Cooldown for getLocation function
Global $g_hTimeSpent = Null ;Time spent. Will be reset everytime it is saved into the cumulative stats.

Global $g_hGameCheckCD = TimerInit()

Global $g_hImageWindow = Null
Global $g_hImageControl = Null
Global $g_hChosenPointsListView = Null
Global $g_hChosenPointsListViewId = Null
Global $g_hImageOkay = Null
Global $g_hImageCancel = Null
Global $g_hBckBitmap = Null

Global $g_hUnknownBattle = Null ;Stuck location when in battle and unknown location
Global $g_hBattleStuck = Null ;Stuck location for battle-auto location