#include-once

Func Farm_Rare($bParam = True, $aStats = Null)
    If $bParam = True Then Config_CreateGlobals(formatArgs(Script_DataByName("Farm_Rare")[2]), "Farm_Rare")
    ;Runs, Map, Difficulty, Stage Level, Capture, Refill, Target Boss

    Log_Level_Add("Farm_Rare")

    $Farm_Rare_Capture = StringSplit($Farm_Rare_Capture, ",", 2)

    Global $Status, $Runs, $Win_Rate, $Average_Time, $Astrogems_Used, $Legendary, $Super_Rare, $Exotic, $Rare, $Variant, $Total_Legendary, $Total_Super_Rare, $Total_Exotic, $Total_Rare, $Total_Variant
    Stats_Add(  CreateArr( _
                    CreateArr("Text",       "Status"), _
                    CreateArr("Ratio",      "Runs",                     "Farm_Rare_Runs"), _
                    CreateArr("Percent",    "Win_Rate",                 "Runs"), _
                    CreateArr("Time",       "Average_Time",             "Runs"), _
                    CreateArr("Ratio",      "Astrogems_Used",           "Farm_Rare_Refill"), _
                    CreateArr("Ratio",      "Legendary",                "Total_Legendary"), _
                    CreateArr("Ratio",      "Super_Rare",               "Total_Super_Rare"), _
                    CreateArr("Ratio",      "Exotic",                   "Total_Exotic"), _
                    CreateArr("Ratio",      "Rare",                     "Total_Rare"), _
                    CreateArr("Ratio",      "Variant",                  "Total_Variant"), _
                    CreateArr("Invisible",  "Total_Legendary"), _
                    CreateArr("Invisible",  "Total_Super_Rare"), _
                    CreateArr("Invisible",  "Total_Exotic"), _
                    CreateArr("Invisible",  "Total_Rare"), _
                    CreateArr("Invisible",  "Total_Variant") _
                ))
    If $aStats <> Null Then
        For $i = 0 To UBound($aStats)-1
            Assign($aStats[$i][0], $aStats[$i][1])
        Next
    EndIf

    Status("Farm Rare has started.", $LOG_INFORMATION)

    Local $hAverage = Null
    Local $bSkip = False

    navigate("map", True)
    While $g_bRunning = True
        If _Sleep(200) Then ExitLoop
        Local $sLocation = getLocation()
        Common_Stuck($sLocation)

        Switch $sLocation
            Case "battle", "battle-auto"
                If $sLocation = "battle-auto" Then
                    Status("Currently in battle.")
                    ContinueLoop
                EndIf

                If inBattle(500) = True And navigate("catch-mode") = False Then clickBattle()
            Case "catch-mode"
                    Local $aResult = catch($Farm_Rare_Capture, $General_Max_Exotic_Chips)
                    Local $iSize = UBound($aResult)

                    For $i = 0 To $iSize-1
                        Local $sMonster = StringReplace($aResult[$i], "-", "_")
                        If StringLeft($sMonster, 1) = "_" Then $sMonster = StringMid($sMonster, 2)
                        Local $iMonster = Eval($sMonster)

                        Assign("Total_" & $sMonster, Eval("Total_" & $sMonster)+1)
                        If StringLeft($aResult[$i], 1) <> "-" Then
                            Assign($sMonster, $iMonster+1)
                            Status(StringFormat("Caught %s x%s.", $sMonster, $iMonster+1), $LOG_INFORMATION)
                        Else
                            Status(StringFormat("Failed to catch %s", $sMonster), $LOG_INFORMATION)
                            $bSkip = True
                        EndIf
                    Next

                    If $iSize = 0 Or $bSkip = True Then
                        If getLocation() = "catch-mode" Then clickPoint(getPointArg("catch-mode-cancel"), 3)
                        waitLocation("battle,battle-auto", 5)
                        clickBattle()

                        $bSkip = False
                    EndIf
            Case "map-battle", "battle-end"
                If $Farm_Rare_Runs <> 0 And $Runs >= $Farm_Rare_Runs Then ExitLoop
                If $Farm_Rare_Refill <> 0 And $Astrogems_Used >= $Farm_Rare_Refill Then ExitLoop

                Status("Entering battle x" & $Runs+1, $LOG_PROCESS)
                If enterBattle() = True Then
                    $hAverage = TimerInit()
                    $Win_Rate += 1
                    $Runs += 1
                EndIf
            Case "map"
                Status(StringFormat("Looking for %s on Level %s %s.", $Farm_Rare_Map, $Farm_Rare_Stage_Level, $Farm_Rare_Difficulty))
                If enterStage($Farm_Rare_Map, $Farm_Rare_Difficulty, $Farm_Rare_Stage_Level) = True Then
                    $hAverage = TimerInit()
                    $Win_Rate += 1
                    $Runs += 1
                EndIf
            Case "refill"
                Status("Refilling energy.")
                Local $iRefill = doRefill()
                If $iRefill = -1 Then ExitLoop
                If $iRefill = 1 Then $Astrogems_Used += 30
            Case "pause"
                Status("In pause screen, unpausing.")
                clickPoint(getPointArg("battle-continue"))
            Case "defeat"
                $Average_Time += (($hAverage<>Null)?Int(TimerDiff($hAverage)/1000):0)
                $hAverage = Null

                $Win_Rate -= 1
                Status("You have been defeated.", $LOG_INFORMATION)
                navigate("battle-end", True)
            Case "battle-sell", "battle-end-exp", "battle-sell-item"
                $Average_Time += (($hAverage<>Null)?Int(TimerDiff($hAverage)/1000):0)
                $hAverage = Null
                
                Status("Match has ended, going to battle-end")
                navigate("battle-end")
            Case "battle-boss"
                If $Farm_Rare_Target_Boss = True Then
                    Status("Targeting boss.")
                    waitLocation("battle,battle-auto", 2)
                    If _Sleep($Delay_Target_Boss_Delay) Then ExitLoop
                    clickPoint("395, 317")
                EndIf
            Case "astromon-full"
                Status("Astromon inventory is full, stopping script.")
                ExitLoop
            Case "battle-gem-full", "map-gem-full"
                If $General_Sell_Gems = "" Then
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
                If HandleCommonLocations($sLocation) = False And $sLocation <> "unknown" Then 
                    If waitLocation("battle,battle-auto,battle-boss", 5) = False Then
                        Status("Proceeding to Farm Rare.")
                        navigate("map", True)
                    EndIf
                EndIf
        EndSwitch
    WEnd

    Status("Farm Rare has ended.", $LOG_INFORMATION)
    Log_Level_Remove()
    Return Stats_GetValues($g_aStats)
EndFunc