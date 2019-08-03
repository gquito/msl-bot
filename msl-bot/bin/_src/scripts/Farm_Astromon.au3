#include-once
#include "../imports.au3"

Global $Number_To_Farm, $Catch_Image, $Finish_Round, $Final_Round, $Map, $Difficulty, $Stage_Level, $Capture, $Gems_To_Sell, $Usable_Astrogems, $Guardian_Mode, $Collect_Quests, $Hourly_Script
Func Farm_Astromon($Number_To_Farm, $Catch_Image, $Finish_Round, $Final_Round, $Map, $Difficulty, $Stage_Level, $Capture, $Gems_To_Sell, $Usable_Astrogems, $Guardian_Mode, $Collect_Quests, $Hourly_Script)
    Log_Level_Add("Farm_Astromon")
    Log_Add("Farm Astromon has started")
    
    ;Override Finish_Round
    If (isEnabled($Final_Round)) Then $Finish_Round = "Enabled"

    Local Const $sLocations = "lost-connection,loading,astromon-full,map-gem-full,battle-gem-full,catch-mode,map,refill,defeat,unknown,battle-boss"

    Local $aList = StringSplit($Capture, ",", $STR_NOCOUNT)
    Local $sList = ""
    For $sCur In $aList
        $sList &= "," & StringLeft($sCur, 2) & ":0"
    Next
    $sList = StringMid($sList, 2)

    $Capture &= "," & $Catch_Image

    $g_bSellGems = True
    $g_aGemsToSell = $Gems_to_Sell

    Data_Add($STAT_STATUS, $DATA_TEXT, "")
    Data_Add($Catch_Image, $DATA_RATIO, "0/" & $Number_To_Farm)
    Data_Add("Runs", $DATA_NUMBER, "0")
    Data_Add("Win Rate", $DATA_PERCENT, "Victory/Runs")

    Data_Add("Caught", $DATA_LIST, $sList, True)
    Data_Add("Missed", $DATA_LIST, $sList, True)
    Data_Add("Refill", $DATA_RATIO, "0/" & $Usable_Astrogems, True)
    Data_Add("Guardians", $DATA_NUMBER, "0", True)
    
    Data_Add("Script Time", $DATA_TIME, TimerInit())
    Data_Add("Victory", $DATA_NUMBER, "0")
    Data_Add("Astrochips", $DATA_NUMBER, "3")

    Data_Add("Skip Round", $DATA_NUMBER, "0")

    ;Adding to display order
    Data_Order_Insert($STAT_STATUS, 0)
    Data_Order_Insert($Catch_Image, 1)
    Data_Order_Insert("Runs", 2)
    Data_Order_Insert("Win Rate", 3)
    Data_Order_Insert("Caught", 4)
    Data_Order_Insert("Missed", 5)
    Data_Order_Insert("Refill", 6)
    If (Not(isDisabled($Guardian_Mode))) Then Data_Order_Insert("Guardians", 7)

    Data_Display_Update()

    ;pre process
    Common_Navigate($sLocations)
    Local $bBagFull = False
    Local $bFinishBattle = False
    Local $bRareFound = False
    ;Script Process
    #cs 
        Script will catch astromons until $Number_To_Farm, usually called by Farm Gem script.
    #ce
    While True
        If _Sleep(200) Then ExitLoop

        Local $sLocation = getLocation()
        Switch $sLocation
            Case "battle-end", "battle-sell", "battle-end-exp", "loading", "map-battle", "village", "refill"
                Data_Set("Skip Round","0")
        EndSwitch

        #Region Common functions
            If ($Collect_Quests = "Enabled") Then Common_Quests($sLocation)
            If ($Guardian_Mode <> "Disabled") Then Common_Guardian($sLocation, $Guardian_Mode, $Usable_Astrogems, $Target_Boss, $Collect_Quests, $Hourly_Script)
            If ($Hourly_Script = "Enabled") Then Common_Hourly($sLocation)
            Common_Stuck($sLocation)
        #EndRegion

        If _Sleep(0) Then ExitLoop
        Local $aRound = getRound()
        Switch $sLocation
            Case "battle", "battle-auto"
                If isArray($aRound) = False Then ContinueLoop

                If $aRound[0] = $aRound[1] Then
                    ; ==Final Round Stuff==
                    If Data_Get("Skip Round") = $aRound[0] Or Data_Get("Astrochips") = 0  Then
                        If $sLocation = "battle" Then clickBattle("until", "battle-auto", 5, 200)
                        ContinueLoop
                    EndIf

                    If Data_Get("Astrochips") > 0 Then ContinueCase ;Goes to catch sequence
                Else
                    ; ==Non Final Round Stuff==
                    If $Final_Round = "Enabled" Then
                        If $sLocation = "battle" Then
                            If Data_Get("Astrochips") > 0 Then
                                Log_Add("Checking for rare astromons.")
                                $Capture = StringReplace($Capture, "," & $Catch_Image, "")

                                ContinueCase ;Catch sequence for rare astromons
                            EndIf
                            
                            clickBattle("until", "battle-auto", 5, 200)
                        EndIf
                        ContinueLoop
                    EndIf

                    If $Finish_Round = "Enabled" And Data_Get("Astrochips") = 0 Then
                        If $sLocation = "battle" Then clickBattle("until", "battle-auto", 5, 200)
                        ContinueLoop
                    EndIf

                    If Data_Get("Skip Round") = $aRound[0] Then
                        If $sLocation = "battle" Then clickBattle("until", "battle-auto", 5, 200)
                        ContinueLoop
                    EndIf

                    If Data_Get("Astrochips") = 0 And $Finish_Round = "Disabled" Then
                        ;Fast Restart
                        Data_Set("Status", "Out of astrochips, restarting match.")
                        navigate("battle-end", True, 2)
                        ContinueLoop
                    EndIf

                    If Data_Get("Astrochips") > 0 Then ContinueCase ;Goes to catch sequence
                EndIf
                
            Case "\\CATCH SEQUENCE//"
                While Data_Get("Astrochips") > 0 
                    ; ===END SCRIPT SEQUENCE===
                    If Data_Get_Ratio($Catch_Image) = 1 Then
                        If $Finish_Round = "Enabled" Then ContinueLoop(2)

                        navigate("map", True, 2)
                        ExitLoop(2)
                    EndIf
                    ; =========================

                    ;Try to catch astromons here
                    If _Sleep(0) Then ExitLoop(2)
                    If navigate("catch-mode", False) = False Then ExitLoop

                    Local $iAstrochips = Data_Get("Astrochips")
                    Local $sResult = catch($Capture, $iAstrochips)
                    Data_Set("Astrochips", $iAstrochips)

                    If $sResult <> "" Then
                        ;Found and catch status
                        If StringLeft($sResult, 1) <> "!" Then
                            ;Successfully caught
                            If $sResult = $Catch_Image Then 
                                Data_Increment($Catch_Image)
                            Else
                                Data_Increment("Caught", 1, StringLeft($sResult, 2))
                            EndIf
                        Else
                            ;Not caught
                            Data_Increment("Missed", 1, StringLeft(StringMid($sResult, 2), 2))
                        EndIf
                    Else
                        ;Nothing found.
                        Data_Set("Skip Round", $aRound[0])
                        clickPoint(getArg($g_aPoints, "catch-mode-cancel"))
                        ExitLoop
                    EndIf
                WEnd

                If StringInStr($Capture, "," & $Catch_Image) = False Then
                    clickBattle("until", "battle-auto", 5, 200)
                    $Capture &= "," & $Catch_Image
                EndIf

            Case "village"
                Data_Set("Status", "Navigating to map.")
                navigate("map", True)
                
            Case "catch-mode"
                clickPoint(getPointArg("catch-mode-cancel"))

            Case "battle-end"
               If (Data_Get($Catch_Image, True)[1] <> 0) And (Data_Get_Ratio($Catch_Image) >= 1) Then ExitLoop
                SetStatus($STATUS_RESTART_BATTLE)

                If (enterBattle()) Then 
                    Data_Increment("Runs")
                    Data_Increment("Victory")
                EndIf

            Case "refill"
                Data_Set("Status", "Refill energy.")
                Local $iRefillResult = doRefill(($Usable_Astrogems = "Gold" ? True : False))
                If ($iRefillResult < -1) Then ExitLoop

            Case "map"
                If (Data_Get($Catch_Image, True)[1] <> 0) And (Data_Get_Ratio($Catch_Image) >= 1) Then ExitLoop
                
                Log_Add("Going into battle.")
                Data_Set("Status", "Going to battle.")
                
                If (enterStage($Map, $Difficulty, $Stage_Level)) Then 
                    Data_Increment("Runs")
                    Data_Increment("Victory")
                EndIf

            Case "pause"
                Log_Add("Unpausing.")
                Data_Set("Status", "Unpausing.")

                clickPoint(getPointArg("battle-continue"))

            Case "defeat"
                Log_Add("You have been defeated.")
                Data_Set("Status", "Defeat detected, navigating to battle-end.")

                Data_Increment("Victory", -1)
                navigate("battle-end", True)

            Case "battle-sell", "battle-end-exp", "battle-sell-item"
                Data_Set("Status", "Going to battle-end.")
                navigate("battle-end")

            Case "battle-astromon-full", "map-astromon-full", "astromon-full"
                Log_Add("Astromon bag is full.", $LOG_ERROR)
                If ($sLocation = "battle-astromon-full") Then
                    If (isEnabled($Finish_Round)) Then
                        clickWhile(getPointArg("battle-astromon-full"), "isLocation", "battle-astromon-full", 10, 1000)
                        Data_Set("Skip Round", $aRound[0])
                    EndIf
                Else
                    ExitLoop
                EndIf

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

    ;End script
    Log_Add("Farm Astromon has ended.")
    Log_Level_Remove()
EndFunc