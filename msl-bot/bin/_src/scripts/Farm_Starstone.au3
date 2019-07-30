#include-once
#include "../imports.au3"

Global $Dungeon_Type, $Dungeon_Level, $Stone_Element, $High_Stones, $Mid_Stones, $Low_Stones, $Usable_Astrogems, $Guardian_Mode, $Target_Boss, $Collect_Quests, $Hourly_Script
Func Farm_Starstone($Dungeon_Type, $Dungeon_Level, $Stone_Element, $High_Stones, $Mid_Stones, $Low_Stones, $Usable_Astrogems, $Guardian_Mode, $Target_Boss, $Collect_Quests, $Hourly_Script)
    Log_Level_Add("Farm_Starstone")
    Log_Add("Farm Starstone has started.")
    
    ;Declaring variables and data
    Local Const $sLocations = "lost-connection,loading,unknown,map,refill,defeat"

    Local $sDungeon = "starstone-dungeons";stores navigate dungeon string
    If ($Dungeon_Type = "Elemental") Then $sDungeon = "elemental-dungeons"

    Data_Add("Status", $DATA_TEXT, "")
    Data_Add("Runs", $DATA_NUMBER, "0")
    Data_Add("Win Rate", $DATA_PERCENT, "Victory/Runs")

    Data_Add("High Stones", $DATA_RATIO, "0/" & $High_Stones)
    Data_Add("Mid Stones", $DATA_RATIO, "0/" & $Mid_Stones)
    Data_Add("Low Stones", $DATA_RATIO, "0/" & $Low_Stones)

    Data_Add("Eggs", $DATA_NUMBER, "0", True)
    Data_Add("Refill", $DATA_RATIO, "0/" & $Usable_Astrogems, True)
    Data_Add("Guardians", $DATA_NUMBER, "0", True)

    Data_Add("Victory", $DATA_NUMBER, "0")
    Data_Add("In Boss", $DATA_TEXT, "False")

    ;Adding to display order
    Data_Order_Insert("Status", 0)
    Data_Order_Insert("Runs", 1)
    Data_Order_Insert("Win Rate", 2)
    Data_Order_Insert("High Stones", 3)
    Data_Order_Insert("Mid Stones", 4)
    Data_Order_Insert("Low Stones", 5)
    Data_Order_Insert("Eggs", 6)
    Data_Order_Insert("Refill", 7)
    If ($Guardian_Mode <> "Disabled") Then Data_Order_Insert("Guardians", 8)

    Data_Display_Update()
    ;pre process
    Common_Navigate($sLocations)

    Local $bConstantRun = False
    If ($High_Stones = 0 And $Mid_Stones = 0 And $Low_Stones = 0) Then $bConstantRun = True

    ;Script process 
    #cs 
        Script will keep running while the high, mid, and low stones ratio are all less than 1.
    #ce
    While ($bConstantRun) Or (Data_Get_Ratio("High Stones") < 1) Or (Data_Get_Ratio("Mid Stones") < 1) Or (Data_Get_Ratio("Low Stones") < 1)
        If _Sleep(200) Then ExitLoop

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
        If isArray($aRound) = True Then
            $iCurrRound = $aRound[0]
            if ($iCurrRound = $aRound[1]) Then Data_Set("In Boss", "True")
        EndIf

        If _Sleep(0) Then ExitLoop
        Switch $sLocation
            Case "battle-gem-full", "map-gem-full"
                Log_Add("Gem inventory is full.", $LOG_ERROR)
                If ($g_bSellGems) Then sellGems($g_aGemsToSell)
            Case "battle-end-exp", "battle-sell"
                Log_Add("Clicking on second item position.")
                Data_Set("Status", "Clicking Item.")

                ;Clicks 2nd item
                If (clickWhile(getPointArg("battle-sell-item-second"), "isLocation", "battle-end-exp,battle-sell,unknown", 30, 1000)) Then
                    If (isLocation("battle-sell-item")) Then ContinueCase
                EndIf
            Case "battle-sell-item"
                Log_Add("Retrieving stone data.")
                Data_Set("Status", "Retrieving stone.")

                Local $aStone = getStone()
                If (isArray($aStone)) Then
                    If ($aStone[0] <> "gold") Then Log_Add("Element: " & _StringProper($aStone[0]) & ", Grade: " & _StringProper($aStone[1]) & ", Quantity: " & $aStone[2], $LOG_INFORMATION)
                    
                    Switch $aStone[0]
                        Case "gold"
                            ;Clicks 3rd item
                            Log_Add("Gold detected, clicking on 3rd item.")
                            Data_Set("Status", "Gold detected.")

                            clickPoint(getPointArg("battle-sell-item-okay"))
                            If (_Sleep(200)) Then ExitLoop
                            clickPoint(getPointArg("battle-sell-item-third"))

                            ContinueLoop
                        Case "egg"
                            Data_Set("Status", "Egg detected.")
                            Data_Increment("Eggs")
                        Case Else
                            Data_Set("Status", "Stone detected.")

                            Local $sElement = StringLower($Stone_Element)
                            If ($sElement = $aStone[0] Or $sElement = "any") Then Data_Increment(_StringProper($aStone[1]) & " Stones", $aStone[2])
                    EndSwitch
                Else
                    ;Could not detect stone.
                    Log_Add("Could not retrieve stone data.")
                    Data_Set("Status", "Could not get data.")
                EndIf

                Data_Set("Status", "Navigating to battle-end.")
                navigate("battle-end", True)

            Case "battle-end"
                Data_Set("In Boss", "False")
                Data_Set("Status", "Quick restart.")

                If (enterBattle()) Then 
                    Data_Increment("Runs")
                    Data_Increment("Victory")
                EndIf

            Case "defeat"
                Log_Add("You have been defeated.")
                Data_Set("Status", "Defeat detected, navigating to battle-end.")

                Data_Increment("Victory", -1)
                navigate("battle-end", True)

            Case "village"
                Data_Set("Status", "Navigating to map.")
                navigate("map", True)
            Case "map"
                Log_Add("Going into battle.")
                Data_Set("Status", "Navigating to dungeons.")
                If (navigate($sDungeon, True)) Then
                    Data_Set("Status", "Selecting dungeon level.")
                    Local $aStage = findBLevel($Dungeon_Level, $sDungeon) ;Point to go into map-battle

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
                        
                        $aStage = findBLevel($Dungeon_Level, $sDungeon)
                    WEnd

                    If (clickWhile($aStage, "isLocation", $sDungeon, 10, 1000)) Then
                        Data_Set("Status", "Entering battle.")

                        If (enterBattle()) Then 
                            Data_Increment("Runs")
                            Data_Increment("Victory")
                        EndIf
                    EndIf
                
                EndIf

            Case "refill"
                Data_Set("Status", "Refill energy.")
                Local $iRefillResult = doRefill(($Usable_Astrogems = "Gold" ? True : False))
                If ($iRefillResult < -1) Then ExitLoop

            Case "pause"
                Log_Add("Unpausing.")
                Data_Set("Status", "Unpausing.")

                clickPoint(getPointArg("battle-continue"))
            Case "guardian-dungeons"
                Data_Set("Status", "Navigating to map")
                navigate("map")
            Case "map-battle"
                closeWindow()
                ContinueLoop
            Case "battle-auto"
                Data_Set($STAT_STATUS, "In battle.")

            Case "battle"
                If inBattle() = False Then ContinueLoop

                Data_Set($STAT_STATUS, "Toggling auto battle on.")
                clickWhile(getPointArg("battle-auto"), "inBattle") ;to battle-auto

            Case Else
                HandleCommonLocations($sLocation)
        EndSwitch
    WEnd

    ;End script
    Log_Add("Farm Starstone has ended.")
    Log_Level_Remove()
EndFunc