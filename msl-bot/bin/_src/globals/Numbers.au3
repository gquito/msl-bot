#include-once

Global $g_iExtended = 0 ;More info for functions

Global $g_bRunning = False ;If any scripts are running
Global $g_bPaused = False ;If any scripts are paused

Global $g_bAdbWorking = False ;If ADB is available for client.

Global $g_bAntiStuck = True ;To allow another device checking to ignore the antistuck feature

Global $g_iEditConfig = Null ;Index for the item being edited

Global $bOutput = False

;Log Info
Global $g_iLOG_Processed = 0 ;Number of log items processed for display
Global $g_iLogInfoLimit = 1000 ;Limit for number of information log
Global $g_iLogTotalLimit = 5000 ;Number of log before forcing a clear.
Global $g_bLogEnabled = True ;Allows for Log_Add if enabled

Global $g_bRestarting = False

Global $g_bSellGems = False
Global $g_aGemsToSell = Null

Global $g_iLocationIndex = -1 ;Location map index

Global $g_aStatsCD = TimerInit() ;Cooldown timer handle for updating stats listview