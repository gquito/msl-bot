#include-once

Global $g_hScriptTimer = Null ;Timer for script
Global $g_hBitmap = Null ;WINAPI bitmap handle.
Global $g_aMap = Null ;Image color map
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

Global $g_hScheduleAdd = Null
Global $g_hScheduleAdd_Cancel = Null
Global $g_idScheduleAdd_Date = Null
Global $g_idScheduleAdd_Day = Null
Global $g_idScheduleAdd_Timer = Null
Global $g_idScheduleAdd_Condition = Null
Global $g_idScheduleAdd_Cancel = Null
Global $g_idScheduleAdd_Preset = Null
Global $g_iScheduleType = Null

Global $g_hMessageBox = Null
Global $g_idEditMessage = Null

Global $g_hCurrentEdit = Null

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
Global $g_idLbl_Schedule = Null
Global $g_idBtn_Add = Null
Global $g_hBtn_Add = Null
Global $g_idBtn_Edit = Null
Global $g_hBtn_Edit = Null
Global $g_iEdit_Index = Null
Global $g_idBtn_Remove = Null
Global $g_hBtn_Remove = Null
Global $g_idBtn_Save = Null
Global $g_hBtn_Save = Null
Global $g_idCheck_Enable = Null
Global $g_idLV_Schedule = Null
Global $g_hLV_Schedule = Null

Global $g_hLV_FunctionLevels = Null
Global $g_idLV_FunctionLevels = Null
Global $g_old_hControl = Null

Global $g_idPic = Null
Global $g_hPic = Null
Global $g_idLbl_BotView = Null
Global $g_idBtn_CaptureRegion = Null
Global $g_hBtn_CaptureRegion = Null

;Timer Handles
Global $g_hTimerLocation = Null ;Global timer for location. Used for antiStuck
Global $g_hGetLocationCoolDown = TimerInit() ;Cooldown for getLocation function
Global $g_hTimerScheduledRestart = Null ;Global timer for schedules restart.

Global $g_hGameCheckCD = TimerInit()

;ADB Shell
Global $g_iADBShellPID = Null
Global $g_sADBSerial = "" ;ADB Serial Number