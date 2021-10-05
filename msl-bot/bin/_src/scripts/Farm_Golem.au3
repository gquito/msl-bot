#include-once

Func Farm_Golem($bParam = True, $aStats = Null) 
    If $bParam > 0 Then Config_CreateGlobals(formatArgs(Script_DataByName("Farm_Golem")[2]), "Farm_Golem")
    ;Runs, Dungeon Level, Filter, Refill, Gold Goal, Target Boss

    Log_Level_Add("Farm_Golem")

    Global $Status, $Runs, $Win_Rate, $Average_Time, $Astrogems_Used, $Gold_Earned, $Gems_Kept, $Eggs_Found
    Stats_Add(  CreateArr( _
                    CreateArr("Text",       "Status"), _
                    CreateArr("Text",       "Location"), _
                    CreateArr("Ratio",      "Runs",             "Farm_Golem_Runs"), _
                    CreateArr("Percent",    "Win_Rate",         "Runs"), _
                    CreateArr("Time",       "Average_Time",     "Runs"), _
                    CreateArr("Ratio",      "Astrogems_Used",   "Farm_Golem_Refill"), _
                    CreateArr("Ratio",      "Gold_Earned",      "Farm_Golem_Gold_Goal"), _
                    CreateArr("Number",     "Gems_Kept"), _
                    CreateArr("Number",     "Eggs_Found") _
                ))
    If $aStats <> Null Then
        For $i = 0 To UBound($aStats)-1
            Assign($aStats[$i][0], $aStats[$i][1])
        Next
    EndIf

    Status("Farm Golem has started.", $LOG_INFORMATION)

    Local $hAverage = Null
    navigate("map", True)
    While $g_bRunning = True
        If _Sleep($Delay_Script_Loop) Then ExitLoop
        Local $sLocation = getLocation()
        Common_Stuck($sLocation)

        Switch $sLocation
            Case "map"
                If $Farm_Golem_Runs <> 0 And $Runs >= $Farm_Golem_Runs Then ExitLoop
                If $Farm_Golem_Gold_Goal <> 0 And $Gold_Earned >= $Farm_Golem_Gold_Goal Then ExitLoop

                Status("Looking for golem dungeons.")
                navigate("golem-dungeons")
            Case "golem-dungeons"
                Status("Searching for golem level.")
                Local $aLevel = findBLevel($Farm_Golem_Dungeon_Level)
                If isArray($aLevel) > 0 Then 
                    clickPoint($aLevel)
                    waitLocation("map-battle", 10)
                Else
                    clickDrag($g_aSwipeDown)
                    If _Sleep(500) Then ExitLoop
                EndIf
            Case "map-battle", "battle-end"
                If $Farm_Golem_Runs <> 0 And $Runs >= $Farm_Golem_Runs Then ExitLoop
                If $Farm_Golem_Gold_Goal <> 0 And $Gold_Earned >= $Farm_Golem_Gold_Goal Then ExitLoop

                Status("Entering battle x" & $Runs+1, $LOG_PROCESS)
                If enterBattle() > 0 Then
                    $hAverage = TimerInit()
                    $Win_Rate += 1
                    $Runs += 1
                    Cumulative_AddNum("Runs (Farm Golem)", 1)
                EndIf
            Case "defeat"
                $Average_Time += (($hAverage<>Null)?Int(TimerDiff($hAverage)/1000):0)
                $hAverage = Null

                $Win_Rate -= 1
                Status("You have been defeated.", $LOG_INFORMATION)
                navigate("battle-end", True)
            Case "refill"
                If $Farm_Golem_Refill <> 0 And $Astrogems_Used+30 > $Farm_Golem_Refill Then ExitLoop
                Status("Refilling energy.")

                Local $iRefill = doRefill()
                If $iRefill = -1 Then ExitLoop
                If $iRefill = 1 Then $Astrogems_Used += 30
            Case "battle", "battle-auto"
                Status("Currently in battle.")
                If $sLocation == "battle" Then clickBattle()
            Case "pause"
                Status("In pause screen, unpausing.")
                clickPoint(getPointArg("battle-continue"))
            Case "battle-end-exp"
                $Average_Time += (($hAverage<>Null)?Int(TimerDiff($hAverage)/1000):0)
                $hAverage = Null

                Status("Going to check gem.")
                clickUntil(getPointArg("battle-sell-item-second"), "isLocation", "battle-sell-item,battle-end", 300, 100)
            Case "battle-sell"
                Status("Clicking third item.")
                clickPoint(getPointArg("battle-sell-item-third"))
            Case "battle-sell-item"
                Status("Capturing gem data.")
                Local $aGem = getGemData()
                If $aGem <> -1 Then
                    Local $bSold = False
                    Switch $aGem[0]
                        Case "GOLD"
                            clickPoint(getPointArg("battle-sell-item-okay"))
                            If _Sleep(200) Then ExitLoop
                            Status("Clicking third item.")
                            clickPoint(getPointArg("battle-sell-item-third"))
                            ContinueLoop
                        Case "EGG"
                            $Eggs_Found += 1
                            Status("Found egg x" & $Eggs_Found)
                            Cumulative_AddNum("Resource Collected (Egg)", 1)
                        Case Else
                            Local $sFilter = filterGem($aGem, $Farm_Golem_Filter)
                            If $sFilter = False Then
                                $bSold = True
                                clickPoint(getPointArg("battle-sell-item-sell"))
                                _GemWindow_AddFound($aGem, "Sold")
                            Else
                                _GemWindow_AddFound($aGem, "Kept (" & $sFilter & ")")
                            EndIf

                            If $bSold = 0 Then 
                                $Gems_Kept += 1
                                Cumulative_AddNum("Resource Collected (Gem)", 1)
                            Else
                                $Gold_Earned += getGemPrice($aGem)
                                Cumulative_AddNum("Resource Earned (Gold)", getGemPrice($aGem))
                            EndIf
                            Log_Add(($bSold?"Sold":"Kept") & ": " & stringGem($aGem), $LOG_INFORMATION)
                    EndSwitch
                Else
                    Status("Error: could not detect gem.", $LOG_ERROR)
                EndIf
                
                navigate("battle-end", True)
            Case "battle-boss"
                If $Farm_Golem_Target_Boss > 0 Then
                    Status("Targeting boss.")
                    waitLocation("battle,battle-auto", 2)
                    If _Sleep($Delay_Target_Boss_Delay) Then ExitLoop
                    clickPoint(getPointArg("boss"))
                EndIf
            Case "map-gem-full", "battle-gem-full"
                If $General_Sell_Gems == "" Then
                    Status("Gem inventory is full, stopping script.", $LOG_INFORMATION)
                    ExitLoop
                Else
                    Status("Gem inventory is full, selling gems: " & $General_Sell_Gems, $LOG_INFORMATION)
                    sellGems($General_Sell_Gems)
                EndIf
            Case "buy-gem", "buy-gold"
                Status("Not enough astrogems, stopping script.", $LOG_ERROR)
                ExitLoop
            Case Else
                If HandleCommonLocations($sLocation) = 0 And $sLocation <> "unknown" Then 
                    If waitLocation("battle,battle-auto,battle-boss", 5) = 0 Then
                        Status("Proceeding to Farm Golem.")
                        navigate("map", True)
                    EndIf
                EndIf
        EndSwitch
    WEnd

    Status("Farm Golem has ended.", $LOG_INFORMATION)
    Log_Level_Remove()
    Return Stats_GetValues($g_aStats)
EndFunc
