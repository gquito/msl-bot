#include-once
#include "../../_src/global.au3"

Global $g_iExtended = 0 ;More info for functions
Global $g_iBackgroundMode = $BKGD_ADB ;Type of background
Global $g_iMouseMode = $MOUSE_ADB ;Type of mouse control
Global $g_iSwipeMode = $SWIPE_ADB ;Type of swipe control
Global $g_iBackMode = $BACK_ADB ;Type of back control

Global $g_iDisplayScaling = 100 ;Display Scaling percentage. Recommended 100%.
Global $g_iRestartTime = 10 ;Number of minutes until bot app decides to restart from stuck location.
Global $g_iLoggedOutTime = 0 ;Number of minutes until bot app decides to restart from logged out.
Global $g_iScheduledRestartTime = 0 ;Number of minutes until bot app decides to restart from logged out.
Global $g_iStatModify = 0
Global $g_iCurrentMonitor = 0
Global $g_iCurrentDpiRatio = 1

;Delays/Timeouts
Global $g_iMaintenanceTimeout = 5
Global $g_iSwipeDelay = $d_iSwipeDelay
Global $g_iNavClickDelay = $d_iNavClickDelay
Global $g_iTargetBossDelay = $d_iTargetBossDelay
Global $g_iADB_Timeout = $d_iADB_Timeout
Global $g_iRestart_Timeout = $d_iRestart_Timeout

Global $g_iADB_InputEvent_Version = $d_iADB_InputEvent_Version

Global $g_bSaveDebug = False ;Write debug type log to log file.
Global $g_bSaveLog = False ;Write to log file
Global $g_bLogClicks = True ;Log clicks.
Global $g_bAskForUpdates = True ;Whether to prompt for updates or not.
Global $g_bRunning = False ;If any scripts are running
Global $g_bPaused = False ;If any scripts are paused
Global $g_bAdbWorking = False ;If ADB is available for client.
Global $g_bScheduled = False
Global $g_bPerformHourly = False ;Status to do hourly or not.
Global $g_bPerformGuardian = True ;Status to do guardian or not.
Global $g_bDailiesCompleted = False ;Status for dailies
Global $g_bBingoCompleted = False ;Status for bingo
Global $g_bGoldDungeonCompleted = False ;Status for Gold Dungeon
Global $g_bDisableAntiStuck = False ;To allow another device checking to ignore the antistuck feature
Global $g_bCleanLogFiles = False
Global $bOutput = Null

Global $g_iEditConfig = Null ;Index for the item being edited

;Log Info
Global $g_iLOG_Processed = 0 ;Number of log items processed for display
Global $g_iLogInfoLimit = 1000 ;Limit for number of information log
Global $g_iLogTotalLimit = 5000 ;Number of log before forcing a clear.
Global $g_bLogEnabled = True ;Allows for Log_Add if enabled

Global $g_bRestarting = False

Global $g_bSellGems = False
Global $g_aGemsToSell = Null

Global $g_iLocationIndex = -1 ;Location map index