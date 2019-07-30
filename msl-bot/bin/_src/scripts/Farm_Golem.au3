#include-once
#include "../imports.au3"

Global $Runs, $Dungeon_Level, $Gem_Filter, $Goal_Type, $Goal_Amount, $Guardian_Mode, $Target_Boss, $Collect_Quests, $Hourly_Script
Func Farm_Golem($Runs, $Dungeon_Level, $Gem_Filter, $Goal_Type, $Goal_Amount, $Guardian_Mode, $Target_Boss, $Collect_Quests, $Hourly_Script)
    Log_Level_Add("Farm_Golem")
    Log_Add("Farm Golem has started.")
    
    ;Declaring variables and data
    Local Const $sLocations = "lost-connection,loading,unknown,map,pause,refill,defeat"

    Data_Add($STAT_STATUS, $DATA_TEXT, "")
    Data_Add($STAT_RUNS, $DATA_RATIO, "0/" & $Runs)
    Data_Add($STAT_WIN_RATE, $DATA_PERCENT, $STAT_VICTORY & "/" & $STAT_RUNS)
    Data_Add($STAT_AVG_TIME, $DATA_TIMEAVG, $STAT_SCRIPT_TIME & "/" & $STAT_RUNS)
    Data_Add($STAT_AVG_WIN_RUN_TIME, $DATA_NUMAVG_TIME, "0/" & $STAT_ACTUAL_RUNS)
    Data_Add($STAT_GEMS_KEPT, $DATA_NUMBER, "0")

    If ($Goal_Type = "Gold") Then
        Data_Add($STAT_SOLD_PROFIT, $DATA_RATIO, "0/" & $Goal_Amount, True)
        Data_Add($STAT_REFILL, $DATA_NUMBER, "0")
    Else
        Data_Add($STAT_SOLD_PROFIT, $DATA_NUMBER, "0")
        Data_Add($STAT_REFILL, $DATA_RATIO, "0/" & $Goal_Amount, True)
    EndIf

    Data_Add($STAT_EGGS, $DATA_NUMBER, "0", True)
    Data_Add($STAT_GUARDIANS, $DATA_NUMBER, "0", True)

    Data_Add($STAT_SCRIPT_TIME, $DATA_TIME, TimerInit())
    Data_Add($STAT_VICTORY, $DATA_NUMBER, "0")
    Data_Add($STAT_IN_BOSS, $DATA_TEXT, "False")
    Data_Add($STAT_ACTUAL_RUNS, $DATA_NUMBER, "0")

    ;Adding to display order
    Data_Order_Insert($STAT_STATUS, 0)
    Data_Order_Insert($STAT_RUNS, 1)
    Data_Order_Insert($STAT_WIN_RATE, 2)
    Data_Order_Insert($STAT_AVG_TIME, 3)
    Data_Order_Insert($STAT_AVG_WIN_RUN_TIME, 4)
    Data_Order_Insert($STAT_GEMS_KEPT, 5)
    Data_Order_Insert($STAT_SOLD_PROFIT, 6)
    Data_Order_Insert($STAT_EGGS, 7)
    Data_Order_Insert($STAT_REFILL, 8)
    If (Not(isDisabled($Guardian_Mode))) Then Data_Order_Insert($STAT_GUARDIANS, 9)

    Data_Display_Update()
    ;pre process
    Common_Navigate($sLocations)

    Local $hAvgRunTimer = Null
    ;Script Process
    ;Script will run golem dungeons and filter out the gems
    While ($Runs = 0) Or (Data_Get_Ratio($STAT_RUNS) < 1)
        If _Sleep(200) Then ExitLoop
		$Usable_Astrogems = ($Goal_Type = "Gold" ? "Gold" : $Goal_Amount)
        
        Local $sLocation = getLocation()
        #Region Common functions
            If ($Collect_Quests = "Enabled") Then Common_Quests($sLocation)
            If ($Guardian_Mode <> "Disabled") Then Common_Guardian($sLocation, $Guardian_Mode, $Usable_Astrogems, $Target_Boss, $Collect_Quests, $Hourly_Script)
            If ($Hourly_Script = "Enabled") Then Common_Hourly($sLocation)
            If ($Target_Boss = "Enabled") Then Common_Boss($sLocation)
            Common_Stuck($sLocation)
        #EndRegion

        ;Checking current round for boss.
        Local $iCurrRound = 0
        Local $aRound = getRound()
        Local $sCBT = Data_Get($STAT_COMMON_BOSS_TARGETED)
        Data_Set_Conditional($STAT_IN_BOSS, $sCBT, $sCBT, True)
        If (isArray($aRound)) Then $iCurrRound = $aRound[0]
        Local $bInBoss = ($sCBT = "True")

        If _Sleep(0) Then ExitLoop
        Switch $sLocation
            Case "battle-auto"
                If ($hAvgRunTimer = Null) Then $hAvgRunTimer = TimerInit()
                Data_Set($STAT_STATUS, "In battle.")

            Case "battle"
                If inBattle() = False Then ContinueLoop

                Data_Set($STAT_STATUS, "Toggling auto battle on.")
                clickWhile(getPointArg("battle-auto"), "inBattle") ;to battle-auto

            Case "battle-end-exp", "battle-sell"
                If ($hAvgRunTimer <> Null) Then 
                    Data_Increment($STAT_AVG_WIN_RUN_TIME, TimerDiff($hAvgRunTimer))
                    Data_Increment($STAT_ACTUAL_RUNS)
                    $hAvgRunTimer = Null
                EndIf
                Log_Add("Clicking on second item position.")
                Data_Set($STAT_STATUS, "Clicking Item.")

                ;Clicks 2nd item
                If (clickWhile(getPointArg("battle-sell-item-second"), "isLocation", "battle-end-exp,battle-sell,unknown", 300, 100)) Then
                    If (isLocation("battle-sell-item")) Then ContinueCase
                EndIf
            Case "battle-sell-item"
                Log_Add("Retrieving gem data.")
                Data_Set($STAT_STATUS, "Retrieving gem.")

                Local $aGem = getGemData()
                If ($aGem <> -1) Then
                    Switch $aGem[0]
                        Case "GOLD"
                            ;Clicks 3rd item
                            Log_Add("Gold detected, clicking on 3rd item.")
                            Data_Set($STAT_STATUS, "Gold detected.")

                            clickPoint(getPointArg("battle-sell-item-okay"))
                            If (_Sleep(200)) Then ExitLoop
                            clickPoint(getPointArg("battle-sell-item-third"))

                            ContinueLoop
                        Case "EGG"
                            Data_Set($STAT_STATUS, "Egg detected.")
                            Data_Increment($STAT_EGGS)
                            Stat_Increment($g_aStats, "Eggs found")

                            Log_Add("Found an egg.", $LOG_INFORMATION)
                        Case Else
                            Data_Set($STAT_STATUS, "Filtering gem.")

                            ;Actual gem
                            Local $sStatus = "" ;Status whether gem is sold or kept, for log.
                            If (Not(filterGem($aGem))) Then
                                $sStatus = "Sold"
                                If (Not(clickWhile(getPointArg("battle-sell-item-sell"), "isLocation", "battle-sell-item", 10, 200))) Then
                                    $sStatus = "Unknown" ;If could not sell because got stuck in battle-sell-item
                                    Local $t_hTimer = TimerInit()
                                    While Not(isLocation("battle-end")) And ($t_hTimer < 5000)
                                        clickPoint(getPointArg("battle-sell-item-cancel"))
                                        If (_Sleep(100)) Then ExitLoop
                                    WEnd
                                Else
                                    Data_Increment($STAT_SOLD_PROFIT, Int($aGem[5]))
                                    Stat_Increment($g_aStats, "Gold profit", Int($aGem[5]))
                                    Stat_Increment($g_aStats, "Gems sold")
                                    If ($Goal_Type = "Gold" And Data_Get($STAT_SOLD_PROFIT,true)[1] <> "0" And Data_Get_Ratio($STAT_SOLD_PROFIT) >= 1) Then
                                        ExitLoop
                                    EndIf
                                EndIf
                            Else
                                Data_Increment($STAT_GEMS_KEPT)
                                Stat_Increment($g_aStats, "Gems kept")

                                $sStatus = "Kept"
                                clickUntil(getPointArg("battle-sell-item-cancel"), "isLocation", "battle-end", 6, 400)
                            EndIf

                            ;Display info and setting data
                            Log_Add($sStatus & ": " & stringGem($aGem), $LOG_INFORMATION)
                    EndSwitch
                Else
                    ;Could not detect gem.
                    Log_Add("Could not retrieve gem data.")
                    Data_Set($STAT_STATUS, "Could not get data.")
                EndIf

                Data_Set($STAT_STATUS, "Navigating to battle-end.")
                navigate("battle-end", True, 3)

            Case "refill"
                Data_Set($STAT_STATUS, "Refill energy.")
                Local $iRefillResult = doRefill(($Goal_Type = "Gold" ? True : False), "Farm_Golem")
                If ($iRefillResult < -1) Then ExitLoop

            Case "battle-end"
                If (Data_Get($STAT_RUNS, True)[1] <> 0 And Data_Get_Ratio($STAT_RUNS) >= 1) Then ExitLoop
                Data_Set($STAT_STATUS, "Quick restart.")

                If (enterBattle()) Then 
                    Data_Increment($STAT_RUNS)
                    Data_Increment($STAT_VICTORY)

                    Stat_Increment($g_aStats, "Golem runs")
                    $bSemiAutoActivated = False
                EndIf

            Case "map"
                If (Data_Get($STAT_RUNS, True)[1] <> 0 And Data_Get_Ratio($STAT_RUNS) >= 1) Then ExitLoop

                Log_Add("Going into battle.")
                Data_Set($STAT_STATUS, "Navigating to dungeons.")

                If (navigate("golem-dungeons")) Then
                    Data_Set($STAT_STATUS, "Selecting dungeon level.")
                    Local $aStage = findBLevel($Dungeon_Level, "golem-dungeons") ;Point to go into map-battle

                    Local $t_hTimer = TimerInit()
                    While Not(isArray($aStage))
                        If ($aStage = -2) Then
                            Log_Add("No longer in map-stage.", $LOG_DEBUG)
                            if (navigate("map-stage")) Then ContinueLoop(2)
                        EndIF
                        If (_Sleep(10)) Then ExitLoop(3)
                        If (TimerDiff($t_hTimer) > 60000) Then 
                            Log_Add("Could not find level.", $LOG_ERROR)
                            ExitLoop(3)
                        EndIf

                        If (Not(isArray($aStage))) Then
                            ;Scrolling up sequence
                            If (Not(clickDrag($g_aSwipeDown))) Then ExitLoop(3)
                        EndIf
                        
                        $aStage = findBLevel($Dungeon_Level, "golem-dungeons")
                    WEnd
						
					If (clickWhile($aStage, "isLocation", "golem-dungeons", 10, 1500)) Then

						Data_Set($STAT_STATUS, "Entering battle.")
						If (enterBattle()) Then 
							Data_Increment($STAT_RUNS)
							Stat_Increment($g_aStats, "Golem runs")

							Data_Increment($STAT_VICTORY)
                            $bSemiAutoActivated = False
						EndIf
					EndIf
                EndIf

            Case "map-battle"
                navigate("map")

            Case "pause"
                Log_Add("Unpausing.")
                Data_Set($STAT_STATUS, "Unpausing.")
                clickPoint(getPointArg("battle-continue"))

            Case "village"
                Data_Set($STAT_STATUS, "Navigating to map.")
                navigate("map", True)

            Case "defeat"
                If ($hAvgRunTimer <> Null) Then $hAvgRunTimer = Null
                Log_Add("You have been defeated.")
                Data_Set($STAT_STATUS, "Defeat detected, navigating to battle-end.")

                Data_Increment($STAT_VICTORY, -1)
                navigate("battle-end", True)

            Case "battle-gem-full", "map-gem-full"
                Log_Add("Gem inventory is full.", $LOG_ERROR)
                navigate("map", True)
                ExitLoop

            Case "guardian-dungeons"
                Data_Set($STAT_STATUS, "Navigating to map")
                navigate("map")

            Case "battle-gem-full", "map-gem-full"
                Log_Add("Gem inventory is full.", $LOG_ERROR)
                If ($g_bSellGems) Then sellGems($g_aGemsToSell)
                
            Case Else
                HandleCommonLocations($sLocation)
        EndSwitch
    WEnd

    ;End script
    Log_Add("Farm Golem has ended.")
    Log_Level_Remove()
EndFunc