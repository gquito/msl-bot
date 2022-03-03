#include-once

Func Farm_Starstone($bParam = True, $aStats = Null) 
    If $bParam > 0 Then Config_CreateGlobals(formatArgs(Script_DataByName("Farm_Starstone")[2]), "Farm_Starstone")
    ;Runs, Dungeon Type, Dungeon Level, Special Dungeon, Stone Element, High Stones, Mid Stones, Low Stones, Refill, Target Boss

    If StringIsInt($Farm_Starstone_Refill) = False Or Int($Farm_Starstone_Refill) < -1 Then
        Log_Add("Error: Refill is invalid: " & $Farm_Starstone_Refill, $LOG_ERROR)
        Return -1
    Else
        If $g_iMaxRefill = Null Then $g_iMaxRefill = Int($Farm_Starstone_Refill)
    EndIf

    Log_Level_Add("Farm_Starstone")
    Global $Status, $Runs, $Win_Rate, $Average_Time, $Astrogems_Used, $High_Stones, $Mid_Stones, $Low_Stones, $Eggs_Found
    Stats_Add(  CreateArr( _
                    CreateArr("Text",       "Status"), _
                    CreateArr("Text",       "Location"), _
                    CreateArr("Ratio",      "Runs",             "Farm_Starstone_Runs"), _
                    CreateArr("Percent",    "Win_Rate",         "Runs"), _
                    CreateArr("Time",       "Average_Time",     "Runs"), _
                    CreateArr("Ratio",      "Astrogems_Used",   "Farm_Starstone_Refill"), _
                    CreateArr("Ratio",      "High_Stones",      "Farm_Starstone_High_Stones"), _
                    CreateArr("Ratio",      "Mid_Stones",       "Farm_Starstone_Mid_Stones"), _
                    CreateArr("Ratio",      "Low_Stones",       "Farm_Starstone_Low_Stones"), _
                    CreateArr("Number",     "Eggs_Found") _
                ))
    If $aStats <> Null Then
        For $i = 0 To UBound($aStats)-1
            Assign($aStats[$i][0], $aStats[$i][1])
        Next
    EndIf

    Status("Farm Starstone has started.", $LOG_INFORMATION)

    Local $hAverage = Null
    navigate("map", True)
    While $g_bRunning = True
        If _Sleep($Delay_Script_Loop) Then ExitLoop
        Local $sLocation = getLocation()
        Common_Stuck($sLocation)

        Switch $sLocation
            Case "map"
                If $Farm_Starstone_Runs <> 0 And $Runs >= $Farm_Starstone_Runs Then ExitLoop
                If (($Farm_Starstone_High_Stones = 0 And $Farm_Starstone_Mid_Stones = 0) And $Farm_Starstone_Low_Stones = 0) = 0 Then
                    If $Farm_Starstone_High_Stones = 0 Or $High_Stones >= $Farm_Starstone_High_Stones Then
                        If $Farm_Starstone_Mid_Stones = 0 Or $Mid_Stones >= $Farm_Starstone_Mid_Stones Then
                            If $Farm_Starstone_Low_Stones = 0 Or $Low_Stones >= $Farm_Starstone_Low_Stones Then
                                ExitLoop
                            EndIf
                        EndIf
                    EndIf
                EndIf

                Local $sType = $Farm_Starstone_Dungeon_Type="Normal"?"starstone":"elemental"
                Status(StringFormat("Looking for %s dungeons.", $sType))
                navigate($sType & "-dungeons")
            Case "starstone-dungeons", "elemental-dungeons"
                Status("Searching for dungeon level.")
                Local $aLevel = findBLevel($Farm_Starstone_Dungeon_Level)
                If isArray($aLevel) > 0 Then 
                    clickPoint($aLevel)
                    waitLocation("map-battle", 10)
                Else
                    clickDrag($g_aSwipeDown)
                    If _Sleep(500) Then ExitLoop
                EndIf
            Case "map-battle", "battle-end"
                If $Farm_Starstone_Runs <> 0 And $Runs >= $Farm_Starstone_Runs Then ExitLoop
                If (($Farm_Starstone_High_Stones = 0 And $Farm_Starstone_Mid_Stones = 0) And $Farm_Starstone_Low_Stones = 0) = 0 Then
                    If $Farm_Starstone_High_Stones = 0 Or $High_Stones >= $Farm_Starstone_High_Stones Then
                        If $Farm_Starstone_Mid_Stones = 0 Or $Mid_Stones >= $Farm_Starstone_Mid_Stones Then
                            If $Farm_Starstone_Low_Stones = 0 Or $Low_Stones >= $Farm_Starstone_Low_Stones Then
                                ExitLoop
                            EndIf
                        EndIf
                    EndIf
                EndIf

                Status("Entering battle x" & $Runs+1, $LOG_PROCESS)
                If enterBattle() > 0 Then
                    $hAverage = TimerInit()
                    $Win_Rate += 1
                    $Runs += 1
                    Cumulative_AddNum("Runs (Farm Starstone)", 1)
                EndIf
            Case "defeat"
                $Average_Time += (($hAverage<>Null)?Int(TimerDiff($hAverage)/1000):0)
                $hAverage = Null

                $Win_Rate -= 1
                Status("You have been defeated.", $LOG_INFORMATION)
                navigate("battle-end", True)
            Case "refill"
                Status("Refilling energy.")

                doRefill()
                Switch @error
                    Case $REFILL_ERROR_INSUFFICIENT
                        Log_Add("Insufficient astrogems for refill, exiting script.", $LOG_INFORMATION)
                        ExitLoop
                    Case $REFILL_ERROR_LIMIT_REACHED
                        Log_Add("Refill limit has been reached, exiting script.", $LOG_INFORMATION)
                        ExitLoop
                EndSwitch
            Case "battle", "battle-auto"
                Status("Currently in battle.")
                If $sLocation == "battle" And waitLocation("battle-auto", 0.3) <= 0 Then clickBattle()
            Case "battle-boss"
                If $Farm_Starstone_Target_Boss > 0 Then
                    Status("Targeting boss.")
                    waitLocation("battle,battle-auto", 2)
                    If _Sleep($Delay_Target_Boss_Delay) Then ExitLoop
                    clickPoint(getPointArg("boss"))
                EndIf
            Case "pause"
                Status("In pause screen, unpausing.")
                clickPoint(getPointArg("battle-continue"))
            Case "battle-end-exp"
                $Average_Time += (($hAverage<>Null)?Int(TimerDiff($hAverage)/1000):0)
                $hAverage = Null

                Status("Going to check stone.")
                clickUntil(getPointArg("battle-sell-item-second"), "isLocation", "battle-sell-item,battle-end", 300, 100)
            Case "battle-sell"
                Status("Clicking third item.")
                clickPoint(getPointArg("battle-sell-item-third"))
            Case "battle-sell-item"
                Status("Capturing stone data.")
                Local $aStone = getStone()
                If $aStone <> -1 Then
                    Switch $aStone[0]
                        Case "gold"
                            clickPoint(getPointArg("battle-sell-item-okay"))
                            If _Sleep(200) Then ExitLoop
                            Status("Clicking third item.")
                            clickPoint(getPointArg("battle-sell-item-third"))
                            ContinueLoop
                        Case "egg"
                            $Eggs_Found += 1
                            Status("Found egg x" & $Eggs_Found)
                            Cumulative_AddNum("Resource Collected (Egg)", 1)
                        Case Else
                            Local $sElement = StringLower($Farm_Starstone_Stone_Element)
                            If $sElement == "any" Or $sElement = $aStone[0] Then
                                Assign($aStone[1] & "_Stones", Eval($aStone[1] & "_Stones")+$aStone[2])
                            EndIf
                            Log_Add(StringFormat("Found %s %s x%s.", $aStone[1], $aStone[0], $aStone[2]), $LOG_INFORMATION)
                            Cumulative_AddNum("Resource Collected (" & _StringProper($aStone[1]) & " " & _StringProper($aStone[0]) & ")", $aStone[2])
                    EndSwitch
                Else
                    Status("Error: could not detect stone.", $LOG_ERROR)
                EndIf
                
                navigate("battle-end", True)
            Case "battle-gem-full", "map-gem-full"
                If $General_Sell_Gems == "" Then
                    Status("Gem inventory is full, stopping script.", $LOG_INFORMATION)
                    ExitLoop
                Else
                    Status("Gem inventory is full, selling gems: " & $General_Sell_Gems, $LOG_INFORMATION)
                    sellGems($General_Sell_Gems)
                EndIf
            Case Else
                If HandleCommonLocations($sLocation) = 0 And $sLocation <> "unknown" Then 
                    If waitLocation("battle,battle-auto,battle-boss", 5) = 0 Then
                        Status("Proceeding to Farm Starstone.")
                        navigate("map", True)
                    EndIf
                EndIf
        EndSwitch
    WEnd

    Status("Farm Starstone has ended.", $LOG_INFORMATION)
    Log_Level_Remove()
    Return Stats_GetValues($g_aStats)
EndFunc
