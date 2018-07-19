#include-once
#include "../imports.au3"

Func Farm_Golem($Runs, $Dungeon_Level, $Gem_Filter, $Usable_Astrogems, $Guardian_Mode, $Target_Boss, $Collect_Quests, $Hourly_Script)
    Log_Level_Add("Farm_Golem")
    Log_Add("Farm Golem has started.")
    
    ;Declaring variables and data
    Local Const $aLocations = _
        ["lost-connection", "loading", "unknown", "battle", "battle-auto", "battle-sell", "battle-sell-item", _
        "battle-end-exp", "battle-end", "map", "pause", "battle-boss", "refill", "defeat", "village"]

    Data_Add("Status", $DATA_TEXT, "")
    Data_Add("Runs", $DATA_RATIO, "0/" & $Runs)
    Data_Add("Win Rate", $DATA_PERCENT, "Victory/Runs")
    Data_Add("Average Time", $DATA_TIMEAVG, "Script Time/Runs")
    Data_Add("Gems Kept", $DATA_NUMBER, "0")
    Data_Add("Sold Profit", $DATA_NUMBER, "0")

    Data_Add("Eggs", $DATA_NUMBER, "0", True)
    Data_Add("Refill", $DATA_RATIO, "0/" & $Usable_Astrogems, True)
    Data_Add("Guardians", $DATA_NUMBER, "0", True)

    Data_Add("Script Time", $DATA_TIME, TimerInit())
    Data_Add("Victory", $DATA_NUMBER, "0")
    Data_Add("In Boss", $DATA_TEXT, "False")

    ;Adding to display order
    Data_Order_Insert("Status", 0)
    Data_Order_Insert("Runs", 1)
    Data_Order_Insert("Win Rate", 2)
    Data_Order_Insert("Average Time", 3)
    Data_Order_Insert("Gems Kept", 4)
    Data_Order_Insert("Sold Profit", 5)
    Data_Order_Insert("Eggs", 6)
    Data_Order_Insert("Refill", 7)
    If $Guardian_Mode <> "Disabled" Then Data_Order_Insert("Guardians", 8)

    Data_Display_Update()
    ;pre process
    Switch isLocation($aLocations, False)
        Case "battle", "battle-auto", "battle-end-exp", "battle-end", "battle-sell", "battle-sell-item", "pause", ""
            Data_Set("Status", "Navigating to map.")
            navigate("map", True)
    EndSwitch

    ;Script Process
    ;Script will run golem dungeons and filter out the gems
    While (Data_Get("Runs", True)[1] = 0) Or (Data_Get_Ratio("Runs") < 1)
        If _Sleep(100) Then ExitLoop

        $sLocation = isLocation($aLocations, False)
        #Region Common functions
            If $Target_Boss = "Enabled" Then Common_Boss($sLocation)
            If $Collect_Quests = "Enabled" Then Common_Quests($sLocation)
            If $Guardian_Mode <> "Disabled" Then Common_Guardian($sLocation, $Guardian_Mode, $Usable_Astrogems, $Target_Boss, $Collect_Quests, $Hourly_Script)
            If $Hourly_Script = "Enabled" Then Common_Hourly($sLocation)
            Common_Stuck($sLocation)
        #EndRegion

        ;Checking current round for boss.
        CaptureRegion()
        Local $aRound = getRound()
        If isArray($aRound) = True And $aRound[0] = $aRound[1] Then
            Data_Set("In Boss", "True")
        EndIf

        If _Sleep(0) Then ExitLoop
        Switch $sLocation
            Case "battle-end-exp", "battle-sell"
                Log_Add("Clicking on second item position.")
                Data_Set("Status", "Clicking Item.")

                ;Clicks 2nd item
                If clickWhile("229,234", "isLocation", "battle-end-exp,battle-sell,unknown", 300, 100) = True Then
                    If getLocation() = "battle-sell-item" Then ContinueCase
                EndIf
            Case "battle-sell-item"
                Log_Add("Retrieving gem data.")
                Data_Set("Status", "Retrieving gem.")

                Local $aGem = getGemData()
                If $aGem <> -1 Then
                    Switch $aGem[0]
                        Case "GOLD"
                            ;Clicks 3rd item
                            Log_Add("Gold detected, clicking on 3rd item.")
                            Data_Set("Status", "Gold detected.")

                            clickPoint(getArg($g_aPoints, "battle-sell-item-okay"))
                            If _Sleep(200) Then ExitLoop
                            clickPoint("329,234")

                            ContinueLoop
                        Case "EGG"
                            Data_Set("Status", "Egg detected.")
                            Data_Increment("Eggs")
                            Stat_Increment($g_aStats, "Eggs found")

                            Log_Add("Found an egg.", $LOG_INFORMATION)
                        Case Else
                            Data_Set("Status", "Filtering gem.")

                            ;Actual gem
                            Local $sStatus = "" ;Status whether gem is sold or kept, for log.
                            If filterGem($aGem) = False Then
                                $sStatus = "Sold"
                                If clickWhile(getArg($g_aPoints, "battle-sell-item-sell"), "isLocation", "battle-sell-item", 10, 200) = False Then
                                    $sStatus = "Unknown" ;If could not sell because got stuck in battle-sell-item
                                    Local $t_hTimer = TimerInit()
                                    While getLocation() <> "battle-end" And ($t_hTimer < 5000)
                                        clickPoint(getArg($g_aPoints, "battle-sell-item-cancel"))
                                        If _Sleep(100) Then ExitLoop
                                    WEnd
                                Else
                                    Data_Increment("Sold Profit", Int($aGem[5]))
                                    Stat_Increment($g_aStats, "Gold profit", Int($aGem[5]))
                                    Stat_Increment($g_aStats, "Gems sold")

                                EndIf
                            Else
                                Data_Increment("Gems Kept")
                                Stat_Increment($g_aStats, "Gems kept")

                                $sStatus = "Kept"
                                clickUntil(getArg($g_aPoints, "battle-sell-item-cancel"), "isLocation", "battle-end", 6, 400)
                            EndIf

                            ;Display info and setting data
                            Log_Add($sStatus & ": " & stringGem($aGem), $LOG_INFORMATION)
                    EndSwitch
                Else
                    ;Could not detect gem.
                    Log_Add("Could not retrieve gem data.")
                    Data_Set("Status", "Could not get data.")
                EndIf

                Data_Set("Status", "Navigating to battle-end.")
                navigate("battle-end", True, 3)

            Case "refill"
                Data_Set("Status", "Refill energy.")
                If (Data_Get_Ratio("Refill") >= 1) Or (Data_Get("Refill", True)[1] = 0) Or (doRefill() = $REFILL_NOGEMS) Then
                    ExitLoop
                Else
                    Data_Increment("Refill", 30)

                    Data_Increment("Runs")
                    Data_Increment("Victory")
                    Stat_Increment($g_aStats, "Golem runs")
                EndIf

                Log_Add("Refilled energy " & Data_Get("Refill"), $LOG_INFORMATION)

            Case "battle-end"
                Data_Set("In Boss", "False")

                If (Data_Get("Runs", True)[1] <> 0) And (Data_Get_Ratio("Runs") >= 1) Then ExitLoop
                Data_Set("Status", "Quick restart.")

                If enterBattle() = True Then 
                    Data_Increment("Runs")
                    Data_Increment("Victory")

                    Stat_Increment($g_aStats, "Golem runs")
                EndIf

            Case "map"
                If (Data_Get("Runs", True)[1] <> 0) And (Data_Get_Ratio("Runs") >= 1) Then ExitLoop

                Log_Add("Going into battle.")
                Data_Set("Status", "Navigating to dungeons.")

                If navigate("golem-dungeons", True) = True Then
                    Data_Set("Status", "Selecting dungeon level.")
					Local $aPoint ;Store point to go into dungeon map-battle
                    If $Dungeon_Level < 7 Then
                        For $i = 0 To 7
                            clickDrag($g_aSwipeDown)
                            If _Sleep(50) Then ExitLoop(2)
                        Next
						
						For $i = 2 To $Dungeon_Level
							clickDrag($g_aSwipeUp)
							_Sleep(50)
						Next
						
                        $aPoint = getArg($g_aPoints, "golem-dungeons-top")
                    Else
                        $aPoint = getArg($g_aPoints, "golem-dungeons-b" & $Dungeon_Level)
                    EndIf
						
					If clickWhile($aPoint, "isLocation", "golem-dungeons", 10, 1000) = True Then

						Data_Set("Status", "Entering battle.")
						If enterBattle() Then 
							Data_Increment("Runs")
							Stat_Increment($g_aStats, "Golem runs")

							Data_Increment("Victory")
						EndIf
					EndIf
                EndIf

            Case "pause"
                Log_Add("Unpausing.")
                Data_Set("Status", "Unpausing.")

                clickPoint(getArg($g_aPoints, "battle-continue"))

            Case "village"
                navigate("map")

            Case "defeat"
                Log_Add("You have been defeated.")
                Data_Set("Status", "Defeat detected, navigating to battle-end.")

                Data_Increment("Victory", -1)
                navigate("battle-end", True)

            Case "battle-gem-full", "map-gem-full"
                Log_Add("Gem inventory is full.", $LOG_ERROR)
                navigate("map", True)
                ExitLoop

            Case "battle-auto"
                    Data_Set("Status", "In battle.")
            EndSwitch
    WEnd

    ;End script
    Log_Add("Farm Golem has ended.")
    Log_Level_Remove()
EndFunc