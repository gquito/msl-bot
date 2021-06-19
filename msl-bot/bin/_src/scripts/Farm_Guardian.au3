#include-once

Func Farm_Guardian($bParam = True, $aStats = Null) 
    If $bParam > 0 Then Config_CreateGlobals(formatArgs(Script_DataByName("Farm_Guardian")[2]), "Farm_Guardian")
    ;Mode, Refill, Idle Time, Target Boss

    Log_Level_Add("Farm_Guardian")

    Global $Status, $Guardians, $Astrogems_Used
    Stats_Add(  CreateArr( _
                    CreateArr("Text",       "Status"), _
                    CreateArr("Text",       "Location"), _
                    CreateArr("Number",     "Guardians"), _
                    CreateArr("Ratio",      "Astrogems_Used",       "Farm_Guardian_Refill") _
                ))
    If $aStats <> Null Then
        For $i = 0 To UBound($aStats)-1
            Assign($aStats[$i][0], $aStats[$i][1])
        Next
    EndIf

    Status("Farm Guardian has started.", $LOG_INFORMATION)

    Local $bIdle = False
    Local $hIdle = Null

    Local $bScrolled = False

    navigate("guardian-dungeons", True)
    While $g_bRunning = True
        If _Sleep($Delay_Script_Loop) Then ExitLoop

        If $bIdle > 0 Then
            If $Farm_Guardian_Idle_Time = 0 Then ExitLoop

            $g_hTimerLocation = Null
            If getLocation() <> "village" Then navigate("village")

            If $Farm_Guardian_Idle_Time = 0 Then ExitLoop
            If $hIdle = Null Then $hIdle = TimerInit()

            Local $iSeconds = $Farm_Guardian_Idle_Time*60 - Int((TimerDiff($hIdle)/1000))
            Status("Currently idling for " & Int($iSeconds/60) & " minutes.")
            If $iSeconds <= 0 Then
                $bIdle = False
                $hIdle = Null
            EndIf

            ContinueLoop
        EndIf

        Local $sLocation = getLocation()
        Common_Stuck($sLocation)

        If $sLocation <> "guardian-dungeons" Then $bScrolled = False
        Switch $sLocation
            Case "guardian-dungeons"
                Status("Searching for dungeons.")
                If $bScrolled = False Then
                    $bScrolled = True
                    clickPoint($g_aSwipeUpFast)
                    If _Sleep(1000) Then ExitLoop
                    clickDrag($g_aSwipeUpFast)
                    If _Sleep(2000) Then ExitLoop
                EndIf

				Local $aPoint = findGuardian($Farm_Guardian_Mode)
                If isArray($aPoint) > 0 Then
                    clickPoint($aPoint)
                    If waitLocation("map-battle,unknown", 5, False) == "unknown" Then 
                        navigate("map") ;Prevent stuck when dungeon is expired
                    EndIf
                Else
                    ;Check for more dungeons
                    Local $iFirst = GetPixelSum(CaptureRegion(), 1, 572, 270, 593-572, 478-270)
                    clickDrag($g_aSwipeDown)
                        If _Sleep(1000) Then ExitLoop
                    Local $iSecond = GetPixelSum(CaptureRegion(), 1, 572, 270, 593-572, 478-270)
                        If $iFirst = $iSecond Then
                            Log_Add("No guardian dungeons remaining.")
                        $bIdle = True
                        EndIf
                EndIf
            Case "map-battle"
                If enterBattle() > 0 Then
                    Cumulative_AddNum("Runs (Farm Guardian)", 1)
                    $Guardians += 1
                EndIf
            Case "battle-end"
                Status("Searching for more guardian dungeons.")

                clickPoint(getPointArg("battle-end-exit"))
                waitLocation("guardian-dungeons", 10)
            Case "defeat"
                Status("You have been defeated.", $LOG_INFORMATION)
                navigate("battle-end", True)
            Case "refill"
                If $Farm_Guardian_Refill <> 0 And $Astrogems_Used+30 > $Farm_Guardian_Refill Then ExitLoop
                Status("Refilling energy.")

                Local $iRefill = doRefill()
                If $iRefill = -1 Then
                    $bIdle = True
                    ContinueLoop
                EndIf
                If $iRefill = 1 Then $Astrogems_Used += 30
            Case "battle", "battle-auto"
                Status("Currently in battle.")
                If $sLocation == "battle" And waitLocation("battle-auto", 0.3) <= 0 Then clickBattle()
            Case "pause"
                Status("In pause screen, unpausing.")
                clickPoint(getPointArg("battle-continue"))
            Case "battle-end-exp", "battle-sell", "battle-sell-item"
                navigate("battle-end")
            Case "battle-boss"
                If $Farm_Guardian_Target_Boss > 0 Then
                    Status("Targeting boss.")
                    waitLocation("battle,battle-auto", 2)
                    If _Sleep($Delay_Target_Boss_Delay) Then ExitLoop
                    clickPoint(getPointArg("boss"))
                EndIf
            Case "map-gem-full", "battle-gem-full"
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
                        Status("Proceeding to Farm Guardian.")
                        navigate("guardian-dungeons", True)
                    EndIf
                EndIf
        EndSwitch
    WEnd

    Status("Farm Guardian has ended.", $LOG_INFORMATION)
    Log_Level_Remove()
    Return Stats_GetValues($g_aStats)
EndFunc