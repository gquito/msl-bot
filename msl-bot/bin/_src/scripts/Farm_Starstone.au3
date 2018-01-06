#include-once
#include "../imports.au3"

Func Farm_Starstone($Dungeon_Type, $Dungeon_Level, $Stone_Element, $High_Stones, $Mid_Stones, $Low_Stones, $Usable_Astrogems, $Guardian_Mode, $Target_Boss, $Collect_Quests, $Hourly_Script)
    Log_Level_Add("Farm_Starstone")
    Log_Add("Farm Starstone has started.")
    
    ;Declaring variables and data
    Local Const $aLocations = _
        ["lost-connection", "loading", "unknown", "battle", "battle-auto", "battle-sell", "battle-sell-item", _
        "battle-end-exp", "battle-end", "map", "pause", "battle-boss", "refill", "defeat", "village"]

    Local $sDungeon = "starstone-dungeons";stores navigate dungeon string
    If $Dungeon_Type = "Elemental" Then $sDungeon = "elemental-dungeons"

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

    ;Adding to display order
    Data_Order_Insert("Status", 0)
    Data_Order_Insert("Runs", 1)
    Data_Order_Insert("Win Rate", 2)
    Data_Order_Insert("High Stones", 3)
    Data_Order_Insert("Mid Stones", 4)
    Data_Order_Insert("Low Stones", 5)
    Data_Order_Insert("Eggs", 6)
    Data_Order_Insert("Refill", 7)
    If $Guardian_Mode <> "Disabled" Then Data_Order_Insert("Guardians", 8)

    Data_Display_Update()
    ;pre process
    Switch isLocation($aLocations, False)
        Case "battle", "battle-auto", "battle-end-exp", "battle-end", "battle-sell", "battle-sell-item", "pause", ""
            Data_Set("Status", "Navigating to map.")
            navigate("map", True)
    EndSwitch

    ;Script process 
    #cs 
        Script will keep running while the high, mid, and low stones ratio are all less than 1.
    #ce
    While (Data_Get_Ratio("High Stones") < 1) Or (Data_Get_Ratio("Mid Stones") < 1) Or (Data_Get_Ratio("Low Stones") < 1)
        If _Sleep(100) Then ExitLoop

        $sLocation = isLocation($aLocations, False)
        #Region Common functions
            If $Target_Boss = "Enabled" Then Common_Boss($sLocation)
            If $Collect_Quests = "Enabled" Then Common_Quests($sLocation)
            If $Guardian_Mode <> "Disabled" Then Common_Guardian($sLocation, $Guardian_Mode, $Usable_Astrogems, $Target_Boss, $Collect_Quests, $Hourly_Script)
            If $Hourly_Script = "Enabled" Then Common_Hourly($sLocation)
            Common_Stuck($sLocation)
        #EndRegion

        If _Sleep(10) Then ExitLoop
        Switch $sLocation
            Case "battle-end-exp", "battle-sell"
                Log_Add("Clicking on second item position.")
                Data_Set("Status", "Clicking Item.")

                ;Clicks 2nd item
                If clickWhile("229,234", "isLocation", "battle-end-exp,battle-sell,unknown", 30, 1000) = True Then
                    If getLocation() = "battle-sell-item" Then ContinueCase
                EndIf
            Case "battle-sell-item"
                Log_Add("Retrieving stone data.")
                Data_Set("Status", "Retrieving stone.")

                Local $aStone = getStone()
                If $aStone <> -1 Then
                    If $aStone[0] <> "gold" Then
                        Log_Add("Element: " & _StringProper($aStone[0]) & ", Grade: " & _StringProper($aStone[1]) & ", Quantity: " & $aStone[2], $LOG_INFORMATION)
                    EndIf
                    
                    Switch $aStone[0]
                        Case "gold"
                            ;Clicks 3rd item
                            Log_Add("Gold detected, clicking on 3rd item.")
                            Data_Set("Status", "Gold detected.")

                            clickPoint(getArg($g_aPoints, "battle-sell-item-okay"))
                            If _Sleep(200) Then ExitLoop
                            clickPoint("329,234")

                            ContinueLoop
                        Case "egg"
                            Data_Set("Status", "Egg detected.")
                            Data_Increment("Eggs")
                        Case Else
                            Data_Set("Status", "Stone detected.")

                            Local $sElement = StringLower($Stone_Element)
                            Switch $sElement
                                Case "any"
                                    Data_Increment(_StringProper($aStone[1]) & " Stones", $aStone[2])
                                Case Else
                                    If $sElement = $aStone[0] Then 
                                        Data_Increment(_StringProper($aStone[1]) & " Stones", $aStone[2])
                                    EndIf
                            EndSwitch
                    EndSwitch
                Else
                    ;Could not detect stone.
                    Log_Add("Could not retrieve stone data.")
                    Data_Set("Status", "Could not get data.")
                EndIf

                Data_Set("Status", "Navigating to battle-end.")
                navigate("battle-end", True)

            Case "battle-end"
                Data_Set("Status", "Quick restart.")

                If enterBattle() Then 
                    Data_Increment("Runs")
                    Data_Increment("Victory")
                EndIf

            Case "defeat"
                Data_Log("You have been defeated.")
                Data_Set("Status", "Defeat detected, navigating to battle-end.")

                Data_Increment("Victory", -1)
                navigate("battle-end", True)

            Case "village"
                navigate("map")

            Case "map"
                Log_Add("Going into battle.")
                Data_Set("Status", "Navigating to dungeons.")
                If navigate($sDungeon, True) = True Then
                    Data_Set("Status", "Selecting dungeon level.")
                    If clickWhile(getArg($g_aPoints, "golem-dungeons-b" & $Dungeon_Level), "isLocation", $sDungeon, 10, 1000) = True Then
                        Data_Set("Status", "Entering battle.")

                        waitLocation("battle-end", 3)
                        If enterBattle() Then 
                            Data_Increment("Runs")
                            Data_Increment("Victory")
                        EndIf
                    EndIf
                EndIf

            Case "refill"
                Data_Increment("Refill", 30)

                Log_Add("Refilling energy " & Data_Get("Refill"), $LOG_INFORMATION)
                Data_Set("Status", "Refill energy.")

                If (Data_Get_Ratio("Refill") > 1) Or (doRefill() = $REFILL_NOGEMS) Then
                    ExitLoop
                EndIf

            Case "battle"
                Log_Add("Toggling auto battle on.")
                Data_Set("Status", "Toggling auto battle on.")

                clickPoint(getArg($g_aPoints, "battle-auto"))

            Case "pause"
                Log_Add("Unpausing.")
                Data_Set("Status", "Unpausing.")

                clickPoint(getArg($g_aPoints, "battle-continue"))

            Case "battle-auto"
                Data_Set("Status", "In battle.")
        EndSwitch
    WEnd

    ;End script
    Log_Add("Farm Starstone has ended.")
    Log_Level_Remove()
EndFunc