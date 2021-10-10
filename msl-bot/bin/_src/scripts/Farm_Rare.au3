#include-once

Func Farm_Rare($bParam = True, $aStats = Null)
    If $bParam > 0 Then Config_CreateGlobals(formatArgs(Script_DataByName("Farm_Rare")[2]), "Farm_Rare")
    ;Runs, Map, Difficulty, Stage Level, Capture, Refill, Target Boss

    Log_Level_Add("Farm_Rare")
    Local $aCapture = StringSplit($Farm_Rare_Capture, ",", 2)

    Global $Status, $Runs, $Win_Rate, $Average_Time, $Astrogems_Used, $Legendary, $Super_Rare, $Exotic, $Rare, $Variant, $Total_Legendary, $Total_Super_Rare, $Total_Exotic, $Total_Rare, $Total_Variant
    Stats_Add(  CreateArr( _
                    CreateArr("Text",       "Status"), _
                    CreateArr("Text",       "Location"), _
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
    Local $aRound[2] ; Store current rounds
    While $g_bRunning = True
        If _Sleep($Delay_Script_Loop) Then ExitLoop
        Local $sLocation = getLocation()
        Common_Stuck($sLocation)

        Local $aCurrRound = getRound(False)
        If isArray($aCurrRound) = True Then
            If $aCurrRound[1] <> $aRound[1] Or _
               $aCurrRound[0] <> $aRound[0] Then

                $aRound = $aCurrRound
            EndIf
        EndIf

        Switch $sLocation
            Case "battle-auto"
                Local $aPixel = getPixelArg("battle-catch-exotic")
                If isPixel($aPixel, 15) Then
                    navigate("catch-mode", False, 3)
                    ContinueLoop
                EndIf

                Status("Current round: " & $aRound[0] & "/" & $aRound[1], $LOG_DEBUG)
            Case "battle"
                If waitLocation("battle-auto", 1) <= 0 Then 
                    If navigate("catch-mode") <= 0 Then clickBattle()
                EndIf
                
            Case "battle-boss"
                If $Farm_Rare_Target_Boss > 0 Then
                    Status("Targeting boss.")
                    waitLocation("battle,battle-auto", 2)
                    If _Sleep($Delay_Target_Boss_Delay) Then ExitLoop
                    clickPoint(getPointArg("boss"))
                EndIf
            Case "catch-mode"
                    Local $aResult = catch($aCapture, ($General_Max_Exotic_Chips < 3)?$General_Max_Exotic_Chips:3)
                    Local $iSize = UBound($aResult)

                    For $i = 0 To $iSize-1
                        Local $sMonster = StringReplace($aResult[$i], "-", "_")
                        If StringLeft($sMonster, 1) == "_" Then $sMonster = StringMid($sMonster, 2)
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

                    If $iSize = 0 Or $bSkip > 0 Then
                        If getLocation() == "catch-mode" Then clickPoint(getPointArg("catch-mode-cancel"), 3)
                        waitLocation("battle,battle-auto", 5)
                        clickBattle()

                        $bSkip = False
                    EndIf
            Case "map-battle", "battle-end"
                If $Farm_Rare_Runs <> 0 And $Runs >= $Farm_Rare_Runs Then ExitLoop

                Status("Entering battle x" & $Runs+1, $LOG_PROCESS)
                If enterBattle() > 0 Then
                    $hAverage = TimerInit()
                    $Win_Rate += 1
                    $Runs += 1
                    Cumulative_AddNum("Runs (Farm Rare)", 1)
                EndIf
            Case "map"
                Status(StringFormat("Looking for %s on Level %s %s.", $Farm_Rare_Map, $Farm_Rare_Stage_Level, $Farm_Rare_Difficulty))
                If enterStage($Farm_Rare_Map, $Farm_Rare_Difficulty, $Farm_Rare_Stage_Level) > 0 Then
                    $hAverage = TimerInit()
                    $Win_Rate += 1
                    $Runs += 1
                    Cumulative_AddNum("Runs (Farm Rare)", 1)
                EndIf
            Case "refill"
                If $Farm_Rare_Refill <> 0 And $Astrogems_Used+30 > $Farm_Rare_Refill Then ExitLoop
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
            Case "astromon-full"
                Status("Astromon inventory is full, stopping script.")
                ExitLoop
            Case "battle-gem-full", "map-gem-full"
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