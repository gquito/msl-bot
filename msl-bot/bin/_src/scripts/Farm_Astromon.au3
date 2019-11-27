#include-once

Func Farm_Astromon($bParam = True, $aStats = Null)
    If $bParam = True Then Config_CreateGlobals(formatArgs(Script_DataByName("Farm_Astromon")[2]), "Farm_Astromon")
    ;Amount, Astromon, Finish Round, Final Round, Map, Difficulty, Stage Level, Capture, Refill

    Log_Level_Add("Farm_Astromon")

    If $Farm_Astromon_Final_Round = True Then $Farm_Astromon_Finish_Round = True
    $Farm_Astromon_Capture = StringSplit($Farm_Astromon_Capture, ",", 2)
    
    Global $Status, $Runs, $Astrogems_Used, $Legendary, $Super_Rare, $Exotic, $Rare, $Variant, $Total_Legendary, $Total_Super_Rare, $Total_Exotic, $Total_Rare, $Total_Variant
    Stats_Add(  CreateArr( _
                    CreateArr("Text",       "Status"), _
                    CreateArr("Number",     "Runs"), _
                    CreateArr("Ratio",      "Astrogems_Used",                                   "Farm_Astromon_Refill"), _
                    CreateArr("Ratio",      StringReplace($Farm_Astromon_Astromon, "-", "_"),   "Farm_Astromon_Amount"), _
                    CreateArr("Ratio",      "Legendary",                                        "Total_Legendary"), _
                    CreateArr("Ratio",      "Super_Rare",                                       "Total_Super_Rare"), _
                    CreateArr("Ratio",      "Exotic",                                           "Total_Exotic"), _
                    CreateArr("Ratio",      "Rare",                                             "Total_Rare"), _
                    CreateArr("Ratio",      "Variant",                                          "Total_Variant"), _
                    CreateArr("Invisible",  "Total_Legendary"), _
                    CreateArr("Invisible",  "Total_Super_Rare"), _
                    CreateArr("Invisible",  "Total_Exotic"), _
                    CreateArr("Invisible",  "Total_Rare"), _
                    CreateArr("Invisible",  "Total_Variant") _
                ))
    If $aStats <> Null Then Stats_Values_Set($aStats)

    Local $bCatch = True
    Local $iSkip = 0
    Status("Farm Astromon has started", $LOG_INFORMATION)

    navigate("map", True)
    While $g_bRunning
        If _Sleep(200) Then ExitLoop

        Local $sLocation = getLocation()
        Common_Stuck($sLocation)

        Local $aRound = getRound()
        Switch $sLocation
            Case "map"
                If $Farm_Astromon_Amount <> 0 And Eval(StringReplace($Farm_Astromon_Astromon, "-", "_")) >= $Farm_Astromon_Amount Then ExitLoop
                Status(StringFormat("Looking for %s on Level %s %s.", $Farm_Astromon_Map, $Farm_Astromon_Stage_Level, $Farm_Astromon_Difficulty))
                If enterStage($Farm_Astromon_Map, $Farm_Astromon_Difficulty, $Farm_Astromon_Stage_Level) = True Then
                    $iSkip = 0
                    $bCatch = True
                    $Runs += 1
                    Cumulative_AddNum("Runs (Farm Astromon)", 1)
                EndIf
            Case "battle-end"
                If $Farm_Astromon_Amount <> 0 And Eval(StringReplace($Farm_Astromon_Astromon, "-", "_")) >= $Farm_Astromon_Amount Then ExitLoop

                Status("Restarting the match.")
                If enterBattle() = True Then
                    $iSkip = 0
                    $bCatch = True
                    $Runs += 1
                    Cumulative_AddNum("Runs (Farm Astromon)", 1)
                EndIf
            Case "battle-auto"
                Local $iNumCurr = Eval(StringReplace($Farm_Astromon_Astromon, "-", "_"))
                Local $iNeed = $Farm_Astromon_Amount - $iNumCurr

                If inBattle(200) = True Then ContinueCase
                If isArray($aRound) = False Or ($bCatch = False Or $iSkip = $aRound[0]) Then ContinueLoop
                If $Farm_Astromon_Finish_Round = False Then 
                    If ($iNeed = 0 Or $bCatch = False) Or isArray(findImage("misc-no-astrochips", 90, 200)) = True Then
                        navigate("battle-end", true)
                        ContinueLoop
                    EndIf
                EndIf
                
                If $Farm_Astromon_Final_Round = False Then
                    If ($bCatch = True And $iNeed <> 0) And navigate("catch-mode") = False Then $bCatch = False
                    ContinueLoop
                Else
                    If $aRound[0] = $aRound[1] And ($bCatch = True And $iNeed <> 0) Then
                        If $bCatch = True And navigate("catch-mode") = False Then $bCatch = False
                        ContinueLoop
                    EndIf
                EndIf
            Case "battle"
                Local $iNumCurr = Eval(StringReplace($Farm_Astromon_Astromon, "-", "_"))
                Local $iNeed = $Farm_Astromon_Amount - $iNumCurr
                If isArray($aRound) = False Or inBattle(200) = False Then ContinueLoop

                If $Farm_Astromon_Finish_Round = False Then 
                    If ($iNeed = 0 Or $bCatch = False) Or isArray(findImage("misc-no-astrochips", 90, 200)) = True Then
                        navigate("battle-end", true)
                        ContinueLoop
                    EndIf
                EndIf

                If $iSkip = $aRound[0] Then 
                    clickBattle()
                    ContinueLoop
                EndIf

                If $bCatch = True And navigate("catch-mode") = False Then 
                    $bCatch = False
                    clickBattle()
                EndIf

                If $bCatch = False And inBattle(200) = True Then
                    clickBattle()
                EndIf
                
            Case "catch-mode"
                If isArray($aRound) = False Then ContinueLoop

                Status("Looking for astromons.")
                Local $aResult = catch($Farm_Astromon_Capture, $General_Max_Exotic_Chips)
                For $i = 0 To UBound($aResult)-1
                    Local $sVariable = StringReplace($aResult[$i], "-", "_")
                    If StringLeft($sVariable, 1) = "_" Then $sVariable = StringMid($sVariable, 2)
                    Assign("Total_" & $sVariable, Eval("Total_" & $sVariable)+1)

                    If StringLeft($aResult[$i], 1) <> "-" Then
                        Assign($sVariable, Eval($sVariable)+1)
                        Status(StringFormat("Caught %s x%s.", _StringProper($sVariable), Eval($sVariable)), $LOG_INFORMATION)
                    Else
                        Status(StringFormat("Failed to catch %s", _StringProper($sVariable)), $LOG_INFORMATION)
                    EndIf
                Next

                If $Farm_Astromon_Final_Round = False Or ($Farm_Astromon_Final_Round = True And $aRound[0] = $aRound[1]) Then 
                    Local $iNumCurr = Eval(StringReplace($Farm_Astromon_Astromon, "-", "_"))
                    Local $iNeed = $Farm_Astromon_Amount - $iNumCurr
                    If $iNeed <> 0 Then 
                        $aResult = catch(CreateArr($Farm_Astromon_Astromon), -1, $iNeed, False)
                        For $i = 0 To UBound($aResult)-1
                            Assign(StringReplace($Farm_Astromon_Astromon, "-", "_"), Eval(StringReplace($Farm_Astromon_Astromon, "-", "_"))+1)
                            Status(StringFormat("Caught %s x%s.", _StringProper($Farm_Astromon_Astromon), Eval(StringReplace($Farm_Astromon_Astromon, "-", "_"))), $LOG_INFORMATION)
                        Next
                    EndIf
                EndIf

                $iSkip = $aRound[0]
                If getLocation() = "catch-mode" Then 
                    clickPoint(getPointArg("catch-mode-cancel"), 3)
                    waitLocation("battle,battle-auto", 5)
                EndIf
            Case "refill"
                If $Farm_Astromon_Refill <> 0 And $Astrogems_Used+30 > $Farm_Astromon_Refill Then ExitLoop

                Status("Refilling energy.")
                Local $iRefill = doRefill()
                If $iRefill = -1 Then ExitLoop
                If $iRefill = 1 Then $Astrogems_Used += 30
            Case "buy-gem", "buy-gold"
                Status("Not enough astrogems, stopping script.", $LOG_ERROR)
                ExitLoop
            Case "battle-astromon-full", "map-astromon-full", "astromon-full"
                Status("Astromon inventory is full, stopping script.")
                ExitLoop
            Case "pause"
                Status("In pause screen, unpausing.")
                clickPoint(getPointArg("battle-continue"))
            Case "defeat"
                $Win_Rate -= 1
                Status("You have been defeated.", $LOG_INFORMATION)
                navigate("battle-end", True)
            Case "battle-sell", "battle-end-exp", "battle-sell-item"        
                Status("Match has ended, going to battle-end")
                navigate("battle-end")
            Case "battle-gem-full", "map-gem-full"
                If $General_Sell_Gems = "" Then
                    Status("Gem inventory is full, stopping script.", $LOG_INFORMATION)
                    ExitLoop
                Else
                    Status("Gem inventory is full, selling gems: " & $General_Sell_Gems, $LOG_INFORMATION)
                    sellGems($General_Sell_Gems)
                EndIf
            Case Else
                If HandleCommonLocations($sLocation) = False And $sLocation <> "unknown" Then
                    If waitLocation("battle,battle-auto,battle-boss", 5) = False Then
                        Status("Proceeding to Farm Astromon.")
                        navigate("map", True)
                    EndIf
                EndIf   
        EndSwitch
    WEnd

    Status("Farm Astromon has ended.", $LOG_INFORMATION)
    Log_Level_Remove()
    Return Stats_GetValues($g_aStats)
EndFunc