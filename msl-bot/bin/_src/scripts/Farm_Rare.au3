#include-once
#include "../imports.au3"

Global $Runs, $Map, $Difficulty, $Stage_Level, $Capture, $Gems_To_Sell, $Usable_Astrogems, $Guardian_Mode, $Target_Boss, $Collect_Quests, $Hourly_Script
Func Farm_Rare($Runs, $Map, $Difficulty, $Stage_Level, $Capture, $Gems_To_Sell, $Usable_Astrogems, $Guardian_Mode, $Target_Boss, $Collect_Quests, $Hourly_Script)
    Log_Level_Add("Farm_Rare")
    Log_Add("Farm Rare has started.")

    ;Declaring variables and data
    Local Const $sLocations = "lost-connection,loading,map-gem-full,battle-gem-full,catch-mode,map,refill,defeat,unknown,astromon-full"

    Local $aList = StringSplit($Capture, ",", $STR_NOCOUNT)
    Local $sList = ""
    For $sCur In $aList
        $sList &= "," & StringLeft($sCur, 2) & ":0"
    Next
    $sList = StringMid($sList, 2)

    Data_Add("Status", $DATA_TEXT, "")
    Data_Add("Runs", $DATA_RATIO, "0/" & $Runs)
    Data_Add("Win Rate", $DATA_PERCENT, "Victory/Runs")
    Data_Add("Average Time", $DATA_TIMEAVG, "Script Time/Runs")

    Data_Add("Caught", $DATA_LIST, $sList, True)
    Data_Add("Missed", $DATA_LIST, $sList, True)
    Data_Add("Refill", $DATA_RATIO, "0/" & $Usable_Astrogems, True)
    Data_Add("Guardians", $DATA_NUMBER, "0", True)
    
    Data_Add("Script Time", $DATA_TIME, TimerInit())
    Data_Add("Victory", $DATA_NUMBER, "0")
    Data_Add("Astrochips", $DATA_NUMBER, "3")

    ;Adding to display order
    Data_Order_Insert("Status", 0)
    Data_Order_Insert("Runs", 1)
    Data_Order_Insert("Win Rate", 2)
    Data_Order_Insert("Average Time", 3)
    Data_Order_Insert("Caught", 4)
    Data_Order_Insert("Missed", 5)
    Data_Order_Insert("Refill", 6)
    If $Guardian_Mode <> "Disabled" Then Data_Order_Insert("Guardians", 7)

    Data_Display_Update()
    ;pre process
    Common_Navigate($sLocations)

    ;Script process 
    #cs 
        Script will run story mode and capture rare astromons.
    #ce
    While ($Runs = 0) Or (Data_Get_Ratio("Runs") <= 1)
        $g_bSellGems = True
        $g_aGemsToSell = $Gems_to_Sell

        If _Sleep(200) Then ExitLoop

        Local $sLocation = getLocation()
        #Region Common functions
            If ($Collect_Quests = "Enabled") Then Common_Quests($sLocation)
            If ($Guardian_Mode <> "Disabled") Then Common_Guardian($sLocation, $Guardian_Mode, $Usable_Astrogems, $Target_Boss, $Collect_Quests, $Hourly_Script)
            If ($Hourly_Script = "Enabled") Then Common_Hourly($sLocation)
            If ($Target_Boss = "Enabled") Then Common_Boss($sLocation, False, True)
            Common_Stuck($sLocation)
        #EndRegion

        If _Sleep(0) Then ExitLoop
        Switch $sLocation
            Case "village"
                Data_Set("Status", "Navigating to map.")
                navigate("map", True)

            Case "battle"
                If inBattle() = False Then ContinueLoop

                While Data_Get("Astrochips") > 0 ;Loop for checking for more than 1 rare
                    If (_Sleep(10)) Then ExitLoop(2)
                    If (Not(navigate("catch-mode", False))) Then ExitLoop
                    
                    Local $iAstrochips = Data_Get("Astrochips")
                    Local $sResult = catch($Capture, $iAstrochips)
                    Data_Set("Astrochips", $iAstrochips)

                    If ($sResult <> "") Then
                        ;Found and catch status
                        If (StringLeft($sResult, 1) <> "!") Then
                            ;Successfully caught
                            Data_Increment("Caught", 1, StringLeft($sResult, 2))
                        Else
                            ;Not caught
                            Data_Increment("Missed", 1, StringLeft(StringMid($sResult, 2), 2))
                        EndIf
                    Else
                        ;Nothing found.
                        clickWhile(getPointArg("catch-mode-cancel"), "isLocation", "catch-mode", 5, 1000)
                        ExitLoop
                    EndIf
                WEnd

                Log_Add("Turning auto battle on.")
                navigateToBattleAuto($sLocation)
            Case "catch-mode"
                clickWhile(getPointArg("catch-mode-cancel"), "isLocation", "catch-mode", 5, 1000)
            Case "battle-end"
                If (Data_Get("Runs", True)[1] <> 0 And Data_Get_Ratio("Runs") >= 1) Then ExitLoop
                Data_Set("Status", "Quick restart.")

                If (enterBattle()) Then 
                    Data_Increment("Runs")
                    Data_Increment("Victory")
                EndIf

            Case "map"
                If (Data_Get("Runs", True)[1] <> 0 And Data_Get_Ratio("Runs") >= 1) Then ExitLoop
                
                Log_Add("Going into battle.")
                Data_Set("Status", "Going to battle.")
                
                If (enterStage($Map, $Difficulty, $Stage_Level)) Then 
                    Data_Increment("Runs")
                    Data_Increment("Victory")
                EndIf

            Case "refill"
                Data_Set("Status", "Refill energy.")
                Local $iRefillResult = doRefill(($Usable_Astrogems = "Gold" ? True : False))
                If ($iRefillResult < -1) Then ExitLoop

            Case "pause"
                Log_Add("Unpausing.")
                Data_Set("Status", "Unpausing.")

                clickPoint(getPointArg("battle-continue"))

            Case "battle-auto"
                Data_Set("Status", "In battle.")

            Case "defeat"
                Log_Add("You have been defeated.")
                Data_Set("Status", "Defeat detected, navigating to battle-end.")

                Data_Increment("Victory", -1)
                navigate("battle-end", True)

            Case "battle-sell", "battle-end-exp", "battle-sell-item"
                Data_Set("Status", "Going to battle-end.")
                navigate("battle-end")
                
            Case "astromon-full"
                Log_Add("Astromon bag is full.", $LOG_ERROR)
                navigate("map")
                ExitLoop

            Case "battle-gem-full", "map-gem-full"
                Data_Set("Status", "Selling gems.")
                sellGems($Gems_To_Sell)

            Case "guardian-dungeons"
                Data_Set("Status", "Navigating to map")
                navigate("map")
            Case Else
                HandleCommonLocations($sLocation)
        EndSwitch
    WEnd

    $g_bSellGems = False
    $g_aGemsToSell = Null

    ;End script
    Log_Add("Farm Rare has ended.")
    Log_Level_Remove()
EndFunc