#include-once
#include "../../_src/global.au3"

; enum _STATS_STRINGS
Global Const $STAT_COMMON_BOSS_TARGETED = "Common Boss Targeted", $STAT_IN_BOSS = "In Boss", $STAT_REFILL = "Refill", $STAT_STATUS = "Status", $STAT_RUNS = "Runs", _
             $STAT_VICTORY = "Victory", $STAT_SCRIPT_TIME = "Script Time", $STAT_WIN_RATE = "Win Rate", $STAT_AVG_TIME = "Average Time", $STAT_AVG_WIN_RUN_TIME = "Avg Win Run Time", _
             $STAT_GEMS_KEPT = "Gems Kept", $STAT_SOLD_PROFIT = "Sold Profit", $STAT_EGGS = "Eggs", $STAT_GUARDIANS = "Guardians", $STAT_ACTUAL_RUNS = "Actual Runs"
; enum _STATUS_COMMON_MESSAGES
Global Const $STATUS_IN_BATTLE = "In battle.", $STATUS_AUTO_BATTLE_ON = "Toggling auto battle on.", $STATUS_ATTACKING_BOSS = "Attacking boss.", $STATUS_CLICKING_ITEM = "Clicking Item.", _
             $STATUS_RETRIEVING_GEM = "Retrieving gem.", $STATUS_GOLD_DETECTED = "Gold detected.", $STATUS_EGG_DETECTED = "Egg detected.", $STATUS_FILTERING_GEM = "Filtering gem.", _
             $STATUS_OUT_OF_CHIPS = "Out of astrochips, restarting match.", $STATUS_RESTART_BATTLE = "Restarting battle."
; enum _LOG_MSG_TYPE
Global Const $LOG_INFORMATION = "Information", $LOG_ERROR = "Error", $LOG_PROCESS = "Process", $LOG_DEBUG = "Debug"