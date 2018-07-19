#include-once
#include "../imports.au3"

Func Farm_Guardian($Mode, $Usable_Astrogems, $Loop, $Target_Boss, $Collect_Quests, $Hourly_Script)
    Log_Level_Add("Farm_Guardian")
    Log_Add("Farm Guardian has started.")

    ;Check for guardian dungeon update
    Local $aConfig = formatArgs(getScriptData($g_aScripts, "_Config")[2])
    If getArg($aConfig, "Update_Guardians") = "Enabled" Then updateGuardians()

    ;Declaring variable and data
    Local Const $aLocations = _
    ["loading", "village", "map", "battle-boss", "unknown", "battle", _
     "battle-auto", "pause", "battle-end-exp", "battle-sell", "battle-end", _
    "guardian-dungeons", "refill", "map-battle", "battle-gem-full", "map-gem-full", "defeat"]

    Data_Add("Status", $DATA_TEXT, "")
    Data_Add("Refill", $DATA_RATIO, "0/" & $Usable_Astrogems, True)
    Data_Add("Guardians", $DATA_NUMBER, "0", True)

    Data_Add("Local Guardians", $DATA_NUMBER, "0")
    Data_Add("Guardian Loop", $DATA_TEXT, "False")

    ;Adding to display order
    Data_Order_Insert("Status", 0)
    Data_Order_Insert("Guardians", 1)
    Data_Order_Insert("Refill", 2)

    Data_Display_Update()

    ;pre process
    Switch isLocation($aLocations, False)
        Case "battle", "battle-auto", "battle-end-exp", "battle-end", "battle-sell", "battle-sell-item", "pause", ""
            Data_Set("Status", "Navigating to map.")
            navigate("map", True)
    EndSwitch

    ;Script process
    #cs 
        Script will check for guardian dungeons in the guardian-dungeons location and attack
            dungeons until there are no more dungeons.
    #ce
    While True
        If _Sleep(100) Then ExitLoop

        Local $sLocation = isLocation($aLocations, False)
        #Region Common functions
            If $Target_Boss = "Enabled" Then Common_Boss($sLocation)
            If $Collect_Quests = "Enabled" Then Common_Quests($sLocation)
            If $Hourly_Script = "Enabled" Then Common_Hourly($sLocation)
            Common_Stuck($sLocation)
        #EndRegion

        If _Sleep(10) Then ExitLoop
        Switch $sLocation
            Case "village"
                If ($Loop = True) And (Data_Get("Guardian Loop") = "Enabled") Then
                    Log_Add("Waiting for 5 minutes.")
                    Local $t_hTimer = TimerInit()
                    While TimerDiff($t_hTimer) < 300000 ;5 minutes
                        Log_Set("Status", "Idle for " & 300-Int(TimerDiff($t_hTimer)/1000) & " seconds.")
                        If _Sleep(500) Then ExitLoop(2)
                    WEnd
                    Data_Set("Guardian Loop", "False")
                EndIf
                
                navigate("map")

            Case "map"
                Data_Set("Status", "Navigating to guardian dungeons.")
                If navigate("guardian-dungeons", True) = False Then
                    If Data_Get("Guardian Loop") = "Enabled" Then
                        Data_Set("Guardian Loop", "True")
                        navigate("village")
                    Else
                        Log_Add("Could not navigate to guardian dungeons.", $LOG_ERROR)
                        ExitLoop
                    EndIf
                EndIf

			Case "battle-end"
                Data_Set("Status", "Checking for more dungeons.")
                Log_Add("Status", "Checking for more dungeons.")

                clickPoint(getArg($g_aPoints, "battle-end-exit"))
                waitLocation("guardian-dungeons", 60)

			Case "battle"
                Log_Add("Toggling auto battle on.")
                Data_Set("Status", "Toggling auto battle on.")

				clickPoint(getArg($g_aPoints, "battle-auto"))

            Case "battle-end-exp", "battle-sell", "battle-sell-item"
                navigate("battle-end", True)

            Case "refill"
                Data_Set("Status", "Refill energy.")
                If (Data_Get_Ratio("Refill") >= 1) Or (Data_Get("Refill", True)[1] = 0) Or (doRefill() = $REFILL_NOGEMS) Then
                    ExitLoop
                Else
                    Data_Increment("Refill", 30)
                EndIf

                Log_Add("Refilled energy " & Data_Get("Refill"), $LOG_INFORMATION)

			Case "map-battle"
				enterBattle()

			Case "guardian-dungeons"
				;Finding available astromon within 10 seconds
                Log_Add("Searching for dungeons.")
                Data_Set("Status", "Searching for dungeons.")

                If isPixel(getArg($g_aPixels, "guardian-dungeons-no-found")) = True Then
                    If Data_Get("Guardian Loop") = "Enabled" Then
                        Data_Set("Guardian Loop", "True")
                        navigate("village")
                        ContinueLoop
                    Else
                        ExitLoop
                    EndIf
                EndIf

				Local $aPoint = findGuardian($Mode);Point of an available astromon

				Local $t_hTimer = TimerInit()
				While isArray($aPoint) = False
					clickDrag($g_aSwipeUp) ;Tries to check for other mons by scrolling up
					If _Sleep(1000) Then Return -1

				    $aPoint = findGuardian($Mode)
					If (TimerDiff($t_hTimer) > 10000) Or ($aPoint = -2) Then
                        Log_Add("Could not find anymore dungeons.")
                        If Data_Get("Guardian Loop") = "Enabled" Then
                            Data_Set("Guardian Loop", "True")
                            navigate("village")
                            ContinueLoop(2)
                        Else
                            ExitLoop(2)
                        EndIf
                    EndIf
				WEnd

				;Enter into map-battle location and lets the case for map battle take over
                Log_Add("Entering guardian dungeon.")
				If clickUntil($aPoint, "isLocation", "map-battle", 10, 500) = True Then
					Data_Increment("Guardians")
                    Data_Increment("Local Guardians")
                    Stat_Increment($g_aStats, "Guardian dungeons")

					Log_Add("Found dungeon, attacking x" & Data_Get("Local Guardians"))
				Else
                    Log_Add("Could not enter into map-battle.", $LOG_ERROR)
                    If Data_Get("Guardian Loop") = "Enabled" Then
                        Data_Set("Guardian Loop", "True")
                        navigate("village")
                    Else
                        ExitLoop
                    EndIf
				EndIf

            Case "pause"
                Log_Add("Unpausing.")
                Data_Set("Status", "Unpausing.")

                clickPoint(getArg($g_aPoints, "battle-continue"))

            Case "defeat"
                Log_Add("You have been defeated.")
                Data_Set("Status", "Defeat detected, navigating to battle-end.")

                navigate("battle-end", True)

            Case "battle-gem-full", "map-gem-full"
                Log_Add("Gem inventory is full.", $LOG_ERROR)
                navigate("map")
                ExitLoop
        EndSwitch
    WEnd
    If Data_Get("Local Guardians") > 0 Then Log_Add("Attacked " & Data_Get("Local Guardians") & " guardians.", $LOG_INFORMATION)

    ;End script
    Log_Add("Farm Guardian has ended.")
    Log_Level_Remove()
EndFunc