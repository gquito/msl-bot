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

Global Const $g_sSCHEDULE_DATE_PROMPTS = ["Schedule Name", "$Action", "Month (MM)", "Day (DD)", "Hour (HH)", "Minute (MM)", "Second (SS)", "Number of Iterations", "!Flags", "!Cooldown", "!Enabled"]
Global Const $g_sSCHEDULE_DATE_PRESET = ["[Example Date]", 'SwitchScript("Farm Gem")', "1", "1", 12, 00, "*", 1, "0:RS|1:RI|2:RBA|3:RI+RBI|4:DND|5:RI+DND|6:RBA+DND|7:RI+RBA+DND", "0|1|2|3|4|5", "True|False"]
Global Const $g_sSCHEDULE_DATE_HELP =   "==Action==" & @CRLF & _
                                        "Each line can have one expression. Test action in Debug Input." & @CRLF & _
                                        "==========" & @CRLF & @CRLF & _
                                        "==Month (MM)==" & @CRLF & _
                                        "Choose which month from 1 - 12." & @CRLF & _
                                        "'*' means any month." & @CRLF & _
                                        "==============" & @CRLF & @CRLF & _
                                        "==Day (DD)==" & @CRLF & _
                                        "Choose which day from 1 - 31." & @CRLF & _
                                        "'*' means any day." & @CRLF & _
                                        "============" & @CRLF & @CRLF & _
                                        "==Hour (HH)==" & @CRLF & _
                                        "Choose which hour from 00 - 24." & @CRLF & _
                                        "'*' means any hour." & @CRLF & _
                                        "=============" & @CRLF & @CRLF & _
                                        "==Minute (MM)==" & @CRLF & _
                                        "Choose which minute from 00 - 59." & @CRLF & _
                                        "'*' means any minute." & @CRLF & _
                                        "===============" & @CRLF & @CRLF & _
                                        "==Second (SS)==" & @CRLF & _
                                        "Choose which second from 00 - 59." & @CRLF & _
                                        "'*' means any second." & @CRLF & _
                                        "===============" & @CRLF & @CRLF & _
                                        "==Number of Iterations==" & @CRLF & _
                                        "Number of times schedule will run." & @CRLF & _
                                        "Each trigger will decrease iteration by 1." & @CRLF & _
                                        "'*' means infinite." & @CRLF & _
                                        "========================" & @CRLF & @CRLF & _
                                        "==Flags==" & @CRLF & _
                                        "0: Run Safe [Default]... Do action after battles or when in Map or Village location." & @CRLF & @CRLF & _
                                        "1: Run Immediately... Do action anywhere." & @CRLF & @CRLF & _
                                        "2: Restart Before Action... Calls Emulator_RestartGame() before doing action." & @CRLF & @CRLF & _
                                        "3: Run Immediately + Restart Before Action" & @CRLF & @CRLF & _
                                        "4: Do Not Delete... Does not delete schedule from list after iteration hits 0." & @CRLF & @CRLF & _
                                        "5: Run Immediately + Do Not Delete" & @CRLF & @CRLF & _
                                        "6: Restart Before Action + Do Not Delete" & @CRLF & @CRLF & _
                                        "7: Run Immediately + Restart Before Action + Do Not Delete" & @CRLF & _
                                        "=========" & @CRLF & @CRLF & _
                                        "==Cooldown==" & @CRLF & _
                                        "Number of seconds before each iteration." & @CRLF & _
                                        "============" & @CRLF & @CRLF & _
                                        "==Enabled==" & @CRLF & _
                                        "Enable or disable schedule." & @CRLF & _
                                        "==========="

Global Const $g_sSCHEDULE_TIMER_PROMPTS = ["Schedule Name", "$Action", "Hour (HH)", "Minute (MM)", "Second (SS)", "Number of Iterations", "!Flags", "!Cooldown", "!Enabled"]
Global Const $g_sSCHEDULE_TIMER_PRESET = ["[Example Timer]", 'SwitchScript("Farm Rare")', 1, 0, 0, "1", "0:RS|1:RI|2:RBA|3:RI+RBI|4:DND|5:RI+DND|6:RBA+DND|7:RI+RBA+DND", "0|1|2|3|4|5", "True|False"]
Global Const $g_sSCHEDULE_TIMER_HELP =  "==Action==" & @CRLF & _
                                        "Each line can have one expression. Test action in Debug Input." & @CRLF & _
                                        "==========" & @CRLF & @CRLF & _
                                        "==Hour (HH)==" & @CRLF & _
                                        "Number of hours per interval." & @CRLF & _
                                        "=============" & @CRLF & @CRLF & _
                                        "==Minute (MM)==" & @CRLF & _
                                        "Number of minutes per interval." & @CRLF & _
                                        "===============" & @CRLF & @CRLF & _
                                        "==Second (SS)==" & @CRLF & _
                                        "Number of seconds per interval." & @CRLF & _
                                        "===============" & @CRLF & @CRLF & _
                                        "==Number of Iterations==" & @CRLF & _
                                        "Number of times schedule will run." & @CRLF & _
                                        "Each trigger will decrease iteration by 1." & @CRLF & _
                                        "'*' means infinite." & @CRLF & _
                                        "========================" & @CRLF & @CRLF & _
                                        "==Flags==" & @CRLF & _
                                        "0: Run Safe [Default]... Do action after battles or when in Map or Village location." & @CRLF & @CRLF & _
                                        "1: Run Immediately... Do action anywhere." & @CRLF & @CRLF & _
                                        "2: Restart Before Action... Calls Emulator_RestartGame() before doing action." & @CRLF & @CRLF & _
                                        "3: Run Immediately + Restart Before Action" & _
                                        "4: Do Not Delete... Does not delete schedule from list after iteration hits 0." & @CRLF & @CRLF & _
                                        "5: Run Immediately + Do Not Delete" & @CRLF & @CRLF & _
                                        "6: Restart Before Action + Do Not Delete" & @CRLF & @CRLF & _
                                        "7: Run Immediately + Restart Before Action + Do Not Delete" & @CRLF & _
                                        "=========" & @CRLF & @CRLF & _
                                        "==Cooldown==" & @CRLF & _
                                        "Number of seconds before each iteration." & @CRLF & _
                                        "============" & @CRLF & @CRLF & _
                                        "==Enabled==" & @CRLF & _
                                        "Enable or disable schedule." & @CRLF & _
                                        "==========="

Global Const $g_sSCHEDULE_DAY_PROMPTS = ["Schedule Name", "$Action", "!Day", "Hour (HH)", "Minute (MM)", "Second (SS)", "Number of Iterations", "!Flags", "!Cooldown", "!Enabled"]
Global Const $g_sSCHEDULE_DAY_PRESET = ["[Example Day]", 'EditScript("Farm Rare", "Map", "Pagos Coast")' & @CRLF & 'SwitchScript("Farm Rare")', "Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday", "11", "00", "00", "1", "0:RS|1:RI|2:RBA|3:RI+RBI|4:DND|5:RI+DND|6:RBA+DND|7:RI+RBA+DND", "0|1|2|3|4|5", "True|False"]
Global Const $g_sSCHEDULE_DAY_HELP =   "==Action==" & @CRLF & _
                                        "Each line can have one expression. Test action in Debug Input." & @CRLF & _
                                        "==========" & @CRLF & @CRLF & _
                                        "==Day==" & @CRLF & _
                                        "Choose which day of the week to trigger." & @CRLF & _
                                        "=======" & @CRLF & @CRLF & _
                                        "==Hour (HH)==" & @CRLF & _
                                        "Choose which hour from 00 - 24." & @CRLF & _
                                        "'*' means any hour." & @CRLF & _
                                        "=============" & @CRLF & @CRLF & _
                                        "==Minute (MM)==" & @CRLF & _
                                        "Choose which minute from 00 - 59." & @CRLF & _
                                        "'*' means any minute." & @CRLF & _
                                        "===============" & @CRLF & @CRLF & _
                                        "==Second (SS)==" & @CRLF & _
                                        "Choose which second from 00 - 59." & @CRLF & _
                                        "'*' means any second." & @CRLF & _
                                        "===============" & @CRLF & @CRLF & _
                                        "==Number of Iterations==" & @CRLF & _
                                        "Number of times schedule will run." & @CRLF & _
                                        "Each trigger will decrease iteration by 1." & @CRLF & _
                                        "'*' means infinite." & @CRLF & _
                                        "========================" & @CRLF & @CRLF & _
                                        "==Flags==" & @CRLF & _
                                        "0: Run Safe [Default]... Do action after battles or when in Map or Village location." & @CRLF & @CRLF & _
                                        "1: Run Immediately... Do action anywhere." & @CRLF & @CRLF & _
                                        "2: Restart Before Action... Calls Emulator_RestartGame() before doing action." & @CRLF & @CRLF & _
                                        "3: Run Immediately + Restart Before Action" & _
                                        "4: Do Not Delete... Does not delete schedule from list after iteration hits 0." & @CRLF & @CRLF & _
                                        "5: Run Immediately + Do Not Delete" & @CRLF & @CRLF & _
                                        "6: Restart Before Action + Do Not Delete" & @CRLF & @CRLF & _
                                        "7: Run Immediately + Restart Before Action + Do Not Delete" & @CRLF & _
                                        "=========" & @CRLF & @CRLF & _
                                        "==Cooldown==" & @CRLF & _
                                        "Number of seconds before each iteration." & @CRLF & _
                                        "============" & @CRLF & @CRLF & _
                                        "==Enabled==" & @CRLF & _
                                        "Enable or disable schedule." & @CRLF & _
                                        "==========="

Global Const $g_sSCHEDULE_CONDITION_PROMPTS = ["Schedule Name", "$Action", "$Conditions", "!Boolean", "Number of Iterations", "!Flags", "!Cooldown", "!Enabled"]
Global Const $g_sSCHEDULE_CONDITION_PRESET = ["[Example Condition]", 'SwitchScript("Farm Forever")', '$g_bRunning = False', "True|False", "1", "0:RS|1:RI|2:RBA|3:RI+RBI|4:DND|5:RI+DND|6:RBA+DND|7:RI+RBA+DND", "0|1|2|3|4|5", "True|False"]
Global Const $g_sSCHEDULE_CONDITION_HELP =  "==Action==" & @CRLF & _
                                        "Each line can have one expression. Test action in Debug Input." & @CRLF & _
                                        "==========" & @CRLF & @CRLF & _
                                        "==Conditions==" & @CRLF & _
                                        "An OR operation will be used for each line." & @CRLF & _
                                        "An AND operation will be used for conditions separated by '&&' within the same line." & @CRLF & _
                                        "Example:" & @CRLF & _
                                        '    1+1=2 && "Example" = "Example"' & @CRLF & _
                                        '    getCurrentLocation() = "village"' & @CRLF & @CRLF & _
                                        'This reads: (((1+1=2) And ("Example" = "Example")) Or (getCurrentLocation() = "village"))' & @CRLF & _
                                        "=============" & @CRLF & @CRLF & _
                                        "==Boolean==" & @CRLF & _
                                        "Result of the condition." & @CRLF & _
                                        "===========" & @CRLF & @CRLF & _
                                        "==Flags==" & @CRLF & _
                                        "0: Run Safe [Default]... Do action after battles or when in Map or Village location." & @CRLF & @CRLF & _
                                        "1: Run Immediately... Do action anywhere." & @CRLF & @CRLF & _
                                        "2: Restart Before Action... Calls Emulator_RestartGame() before doing action." & @CRLF & @CRLF & _
                                        "3: Run Immediately + Restart Before Action" & _
                                        "4: Do Not Delete... Does not delete schedule from list after iteration hits 0." & @CRLF & @CRLF & _
                                        "5: Run Immediately + Do Not Delete" & @CRLF & @CRLF & _
                                        "6: Restart Before Action + Do Not Delete" & @CRLF & @CRLF & _
                                        "7: Run Immediately + Restart Before Action + Do Not Delete" & @CRLF & _
                                        "=========" & @CRLF & @CRLF & _
                                        "==Cooldown==" & @CRLF & _
                                        "Number of seconds before each iteration." & @CRLF & _
                                        "============" & @CRLF & @CRLF & _
                                        "==Enabled==" & @CRLF & _
                                        "Enable or disable schedule." & @CRLF & _
                                        "==========="