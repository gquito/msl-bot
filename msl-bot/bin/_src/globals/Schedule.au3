#include-once

Global $g_hScheduleCooldown = TimerInit()
Global $g_aSchedules[0][9] 
Global $g_iSchedulesSize = 0

Global $g_aSchedulesQueue[0][2] 
Global $g_iSchedulesQueueSize = 0
Global $g_bScheduleBusy = False

Global $g_bScheduleHandleBusy = False

Global Const $SCHEDULE_FLAG_RunSafe = 0
Global Const $SCHEDULE_FLAG_RunImmediately = 1 
Global Const $SCHEDULE_FLAG_RestartBeforeAction = 2
Global Const $SCHEDULE_FLAG_DoNotDelete = 4

Global Const $SCHEDULE_NAME = 0
Global Const $SCHEDULE_ACTION = 1
Global Const $SCHEDULE_TYPE = 2
Global Const $SCHEDULE_ITERATIONS = 3
Global Const $SCHEDULE_STRUCTURE = 4
Global Const $SCHEDULE_FLAG = 5
Global Const $SCHEDULE_COOLDOWN = 6
Global Const $SCHEDULE_COOLDOWNHANDLE = 7
Global Const $SCHEDULE_ENABLED = 8

Global Const $SCHEDULE_TYPE_DATE = 0
Global Const $SCHEDULE_TYPE_TIMER = 1
Global Const $SCHEDULE_TYPE_CONDITION = 2
Global Const $SCHEDULE_TYPE_DAY = 3

Global Const $SCHEDULE_DATE_TIME = 0

Global Const $SCHEDULE_DAY_TIME = 0
Global Const $SCHEDULE_DAY_DAYOFTHEWEEK = 1

Global Const $SCHEDULE_TIMER_TIMEHANDLE = 0
Global Const $SCHEDULE_TIMER_INTERVAL = 1

Global Const $SCHEDULE_CONDITION_ARRAY = 0
Global Const $SCHEDULE_CONDITION_RESULT = 1

Global Const $SCHEDULE_QUEUE_ACTION = 0
Global Const $SCHEDULE_QUEUE_FLAG = 1