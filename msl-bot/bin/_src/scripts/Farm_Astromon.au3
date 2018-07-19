#include-once
#include "../imports.au3"

Func Farm_Astromon($Number_To_Farm, $Catch_Image, $Finish_Round, $Final_Round, $Map, $Difficulty, $Stage_Level, $Capture, $Gems_To_Sell, $Usable_Astrogems, $Guardian_Mode, $Collect_Quests, $Hourly_Script)
    Log_Level_Add("Farm_Astromon")
    Log_Add("Farm Astromon has started.")
    
    ;Override Finish_Round
    If $Final_Round = "Enabled" Then $Finish_Round = "Enabled"

    ;Declaring variables and data
    Local Const $aLocations = _
    ["lost-connection", "loading", "battle", "battle-auto", "astromon-full", "map-gem-full", _
     "battle-gem-full", "catch-mode", "pause", "battle-end", "battle-end-exp", "battle-sell", _
     "map", "refill", "defeat", "unknown", "battle-boss"]

    Local $aRound ;Stores round

    Local $aList = StringSplit($Capture, ",", $STR_NOCOUNT)
    Local $sList = ""
    For $sCur In $aList
        $sList &= "," & StringLeft($sCur, 2) & ":0"
    Next
    $sList = StringMid($sList, 2)

    $Capture &= "," & $Catch_Image

    Data_Add("Status", $DATA_TEXT, "")
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
    Data_Order_Insert("Status", 0)
    Data_Order_Insert($Catch_Image, 1)
    Data_Order_Insert("Runs", 2)
    Data_Order_Insert("Win Rate", 3)
    Data_Order_Insert("Caught", 4)
    Data_Order_Insert("Missed", 5)
    Data_Order_Insert("Refill", 6)
    If $Guardian_Mode <> "Disabled" Then Data_Order_Insert("Guardians", 7)

    Data_Display_Update()
    ;pre process
    Switch isLocation($aLocations, False)
        Case "battle", "battle-auto", "battle-end-exp", "battle-end", "battle-sell", "battle-sell-item", "pause", ""
            Data_Set("Status", "Navigating to map.")
            navigate("map", True)
    EndSwitch

    ;Script Process
    #cs 
        Script will catch astromons until $Number_To_Farm, usually called by Farm Gem script.
    #ce
    While (Data_Get($Catch_Image, True)[1] = 0) Or (Data_Get_Ratio($Catch_Image) < 1)
        If _Sleep(100) Then ExitLoop

        $sLocation = isLocation($aLocations, False)
        Switch $sLocation
            Case "battle-end", "battle-sell", "battle-end-exp", "loading", "map-battle", "village", "refill"
                Data_Set("Skip Round", "0")
        EndSwitch

        #Region Common functions
            If $Collect_Quests = "Enabled" Then Common_Quests($sLocation)
            If $Guardian_Mode <> "Disabled" Then Common_Guardian($sLocation, $Guardian_Mode, $Usable_Astrogems, "Enabled", $Collect_Quests, $Hourly_Script)
            If $Hourly_Script = "Enabled" Then Common_Hourly($sLocation)
            Common_Stuck($sLocation)
        #EndRegion
        If _Sleep(10) Then ExitLoop

        $aRound = getRound()
        Switch $sLocation
            Case "battle", "battle-auto"
                If isArray($aRound) = False Then ContinueLoop

                If $aRound[0] = $aRound[1] Then
                    ; ==Final Round Stuff==
                    If Data_Get("Skip Round") = $aRound[0] Or Data_Get("Astrochips") = 0  Then
                        If $sLocation = "battle" Then clickUntil(getArg($g_aPoints, "battle-auto"), "isLocation", "battle-auto", 3, 250)
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
                            
                            clickUntil(getArg($g_aPoints, "battle-auto"), "isLocation", "battle-auto", 3, 250)
                        EndIf
                        ContinueLoop
                    EndIf

                    If $Finish_Round = "Enabled" And Data_Get("Astrochips") = 0 Then
                        If $sLocation = "battle" Then clickUntil(getArg($g_aPoints, "battle-auto"), "isLocation", "battle-auto", 3, 250)
                        ContinueLoop
                    EndIf

                    If Data_Get("Skip Round") = $aRound[0] Then
                        If $sLocation = "battle" Then clickUntil(getArg($g_aPoints, "battle-auto"), "isLocation", "battle-auto", 3, 250)
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
                    clickUntil(getArg($g_aPoints, "battle-auto"), "isLocation", "battle-auto", 3, 250)
                    $Capture &= "," & $Catch_Image
                EndIf

            Case "catch-mode"
                clickPoint(getArg($g_aPoints, "catch-mode-cancel"))

            Case "battle-end"
                If (Data_Get($Catch_Image, True)[1] <> 0) And (Data_Get_Ratio($Catch_Image) >= 1) Then ExitLoop
                Data_Set("Status", "Restarting battle.")

                If enterBattle() Then 
                    Data_Increment("Runs")
                    Data_Increment("Victory")
                EndIf

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

            Case "map"
                If (Data_Get($Catch_Image, True)[1] <> 0) And (Data_Get_Ratio($Catch_Image) >= 1) Then ExitLoop
                
                Log_Add("Going into battle.")
                Data_Set("Status", "Going to battle.")
                
                If enterStage($Map, $Difficulty, $Stage_Level) = True Then 
                    Data_Increment("Runs")
                    Data_Increment("Victory")
                EndIf

            Case "pause"
                Log_Add("Unpausing.")
                Data_Set("Status", "Unpausing.")

                clickPoint(getArg($g_aPoints, "battle-continue"))

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
                ExitLoop

            Case "battle-gem-full", "map-gem-full"
                Data_Set("Status", "Selling gems.")
                sellGems($Gems_To_Sell)

        EndSwitch
    WEnd

    ;Handles finish round.
    If getLocation() <> "map" Then
        If $Finish_Round = "Enabled" Then
            Local $hTimer = TimerInit()
            While isLocation("catch-mode,catch-success,battle,battle-auto,pause", True)
                If _Sleep(200) Then ExitLoop
                If TimerDiff($hTimer) > 120000 Then
                    Log_Add("Battle took too long to finish.", $LOG_ERROR)
                    navigate("map", True, 2)
                    ExitLoop
                EndIf

                If getLocation($g_aLocations, False) = "battle" Then clickUntil(getArg($g_aPoints, "battle-auto"), "isLocation", "battle-auto")
                If isLocation("battle-end-exp,battle-end,battle-sell,battle-sell-item", True) Then
                    navigate("map", True, 2)
                    ExitLoop
                EndIf
            WEnd
        Else
            navigate("map", True, 2)
        EndIf
    EndIf

    ;End script
    Log_Add("Farm Astromon has ended.")
    Log_Level_Remove()
EndFunc