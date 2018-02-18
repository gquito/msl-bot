#include-once
#include "../imports.au3"

Func Farm_Astromon($Number_To_Farm, $Catch_Image, $Finish_Round, $Final_Round, $Map, $Difficulty, $Stage_Level, $Capture, $Gems_To_Sell, $Usable_Astrogems, $Guardian_Mode, $Collect_Quests, $Hourly_Script)
    Log_Level_Add("Farm_Astromon")
    Log_Add("Farm Astromon has started.")
    
    ;Declaring variables and data
    Local Const $aLocations = _
    ["lost-connection", "loading", "battle", "battle-auto", "astromon-full", "map-gem-full", _
     "battle-gem-full", "catch-mode", "pause", "battle-end", "battle-end-exp", "battle-sell", _
     "map", "refill", "defeat", "unknown", "battle-boss"]

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

    Data_Add("Round", $DATA_RATIO, "0/0")
    Data_Add("Skip Round", $DATA_NUMBER, "-1")

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
        #Region Common functions
            If $Collect_Quests = "Enabled" Then Common_Quests($sLocation)
            If $Guardian_Mode <> "Disabled" Then Common_Guardian($sLocation, $Guardian_Mode, $Usable_Astrogems, "Enabled", $Collect_Quests, $Hourly_Script)
            If $Hourly_Script = "Enabled" Then Common_Hourly($sLocation)
            Common_Stuck($sLocation)
        #EndRegion
        If _Sleep(10) Then ExitLoop

        CaptureRegion()
        Local $aRound = getRound()
        If isArray($aRound) = True Then
            Data_Set("Round", $aRound[0] & "/" & $aRound[1])

            If $Final_Round = "Enabled" Then
                If $sLocation = "battle-auto" Then
                    If (Data_Get_Ratio("Round") = 1) And (Data_Get("Astrochips") <> 0) And (Data_Get("Skip Round") <> $aRound[0]) Then
                        clickUntil(getArg($g_aPoints, "battle-auto"), "isLocation", "battle", 15, 200, Null)
                    EndIf
                ElseIf $sLocation = "battle" Then
                    If Data_Get("Astrochips") <> 0 Then
                        If (Data_Get_Ratio("Round") = 1) Then
                            If StringInStr($Capture, "," & $Catch_Image) = False Then
                                $Capture &= "," & $Catch_Image
                            EndIf
                        Else
                            $Capture = StringReplace($Capture, "," & $Catch_Image, "")
                        EndIf
                    Else
                        clickUntil(getArg($g_aPoints, "battle-auto"), "isLocation", "battle-auto", 15, 200, Null)
                    EndIf
                EndIf
            Else ;#####################################################################################################################
                If ($sLocation = "battle-auto" Or $sLocation = "battle") And (Data_Get("Astrochips") = 0) Then
                    If $Finish_Round = "Disabled" Then
                        Data_Set("Status", "Out of astrochips, restarting match.")
                        navigate("battle-end", True)
                    EndIf
                Else
                    If $sLocation = "battle-auto" Then
                        If isArray($aRound) = True Then
                            If Data_Get("Skip Round") <> $aRound[0] Then
                                clickUntil(getArg($g_aPoints, "battle-auto"), "isLocation", "battle", 15, 200)
                            EndIf
                        EndIf
                    ElseIf $sLocation = "battle" Then
                        If StringInStr($Capture, "," & $Catch_Image) = False Then
                            $Capture &= "," & $Catch_Image
                        EndIf
                    EndIf
                EndIf
            EndIf
        EndIf

        Switch $sLocation
            Case "battle"
                While (Data_Get("Astrochips") <> 0) And (Data_Get_Ratio($Catch_Image) <> 1) And (isArray($aRound) = True) And (Data_Get("Skip Round") <> $aRound[0]) ;Loop for checking for more than 1 rare
                    Data_Set("Status", "Checking for astromons.")
                    
                    If _Sleep(10) Then ExitLoop(2)
                    If navigate("catch-mode", False) = False Then ExitLoop
                    
                    Local $iAstrochips = Data_Get("Astrochips")
                    Local $sResult = catch($Capture, $iAstrochips)
                    Data_Set("Astrochips", $iAstrochips)

                    If $sResult <> "" Then
                        Data_Set("Status", "Catching astromon.")
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
                        clickPoint(getArg($g_aPoints, "catch-mode-cancel"))
                        ExitLoop
                    EndIf
                WEnd

                If Data_Get("Astrochips") = 0 Then
                    If $Finish_Round = "Disabled" Then
                        Data_Set("Status", "Out of astrochips, restarting match.")
                        navigate("battle-end", True)
                    Else
                        If isArray($aRound) = True Then
                            Data_Set("Skip Round", $aRound[0])
                        EndIf

                        Data_Set("Status", "Turning auto battle on.")
                        clickUntil(getArg($g_aPoints, "battle-auto"), "isLocation", "battle-auto", 5, 1000)
                    EndIf

                Else  
                    If isArray($aRound) = True Then
                        Data_Set("Skip Round", $aRound[0])
                    EndIf
                   
                    Data_Set("Status", "Turning auto battle on.")
                    clickUntil(getArg($g_aPoints, "battle-auto"), "isLocation", "battle-auto", 5, 1000)
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
                Data_Increment("Refill", 30)

                If (Data_Get_Ratio("Refill") > 1) Or (Data_Get("Refill", True)[1] = 0) Or (doRefill() = $REFILL_NOGEMS) Then
                    Data_Increment("Refill", -30)
                    ExitLoop
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

    ;End script
    Log_Add("Farm Astromon has ended.")
    Log_Level_Remove()
EndFunc