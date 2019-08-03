#include-once
#include "../../imports.au3"

#cs 
    Function: Selects boss during battle-boss location or last round.
    Parameter: Reference to current location of the script.
#ce
Func Common_Boss(ByRef $sLocation, $bDoAutoClick = False, $bStoryFarm = False)
    If (Data_Get("Common Boss Targeted") = -1) Then Data_Add("Common Boss Targeted", $DATA_TEXT, "False")

    If (Data_Get("Common Boss Targeted") = "False") Then
        Switch $sLocation
            Case "battle-auto", "battle", "unknown"
                Local $aRound = getRound()
                If (isArray($aRound)) Then
                    If ((Not($bStoryFarm) And $aRound[0] = $aRound[1]) Or ($bStoryFarm And $aRound[0] = 4)) Then 
                        waitLocation("unknown,battle-boss", 3, 10)
                        ContinueCase
                    EndIf
                EndIf

                Return 0
            Case "battle-boss"
                If (_Sleep(100)) Then Return 0

                waitLocation("battle-auto,battle", 5, 10)

                If (_Sleep($g_iTargetBossDelay)) Then Return 0

                Data_Set("Status", "Targeting boss.")
                Log_Add("Targeting boss.")
                Data_Set("Common Boss Targeted", "True")

                clickPoint(getPointArg("boss"))
                If ($bDoAutoClick) Then 
                    clickBattle("until", "battle-auto", 5, 200)
                EndIf
                $sLocation = $g_sLocation
        EndSwitch
    Else
        Switch $sLocation
            Case "battle-end", "battle-end-exp", "battle-sell", "map", "village"
                Data_Set("Common Boss Targeted", "False")
        EndSwitch
    EndIf
EndFunc

#cs 
    Function: Collect quest from battle-end location.
    Parameter: Reference to current location of the script.
#ce
Func Common_Quests(ByRef $sLocation)
    If ($sLocation = "battle-end") And isPixel("%battle-end-quest") Then
        If (Data_Get("In Boss") <> -1) Then Data_Set("In Boss", "False")
        Data_Set("Status", "Collecting quests.")
        collectQuest()

        $sLocation = getLocation()
    EndIf
EndFunc

#cs 
    Function: Attacks guardian dungeons by running Farm_Guardian() script, usually once every 30 minutes
    Parameters:
        $sLocation: Reference to current location of the script.
        *Other parameters include settings for Farm_Guardian excluding $Loop
#ce
Func Common_Guardian(ByRef $sLocation, $Mode, $Usable_Astrogems, $Target_Boss, $Collect_Quests, $Hourly_Script)
    If $g_bPerformGuardian = True Then
        Switch $sLocation
            Case "battle-end", "map", "village"
                Local $aFarmGuardian = formatArgs(getScriptData($g_aScripts, "Farm_Guardian")[2])
                Local $aArgs = [$Mode, $Usable_Astrogems, "Disabled", getArg($aFarmGuardian,"Guided_Auto"), $Target_Boss, $Collect_Quests, $Hourly_Script]
                _RunScript("Farm_Guardian", $aArgs, True, "Guardians,Refill", "Guardians,Refill")
                $g_bPerformGuardian = False

                $sLocation = getLocation()
        EndSwitch
    EndIf
EndFunc


Func setGuardianTrue()
    $g_bPerformGuardian = True
EndFunc
#cs 
    Function: Perform hourly functions as per scheduled time.
    Parameters: Reference to currentl ocation of the script.
#ce
Func Common_Hourly(ByRef $sLocation)
    If ($g_bPerformHourly) Then
        Switch $sLocation
            Case "battle-end", "map", "village"
                doHourly()
        EndSwitch

        $sLocation = getLocation()
    EndIf
EndFunc

#cs 
    Function: Prevents getting stuck at an unknown/unspecified location for a script.
    Parameter: Reference to current location of the script.
#ce
Func Common_Stuck(ByRef $sLocation)
    If (Data_Get("Common Stuck Timer") = -1) Then Data_Add("Common Stuck Timer", $DATA_TEXT, TimerInit())

    If ($sLocation = "battle-end" Or $sLocation = "map" Or $sLocation = "village") Then
        $g_hBattleStuck = Null
        $g_hUnknownBattle = Null
        
        ;Data resets
        If (Data_Get("Astrochips") <> -1) Then Data_Set("Astrochips", "3")
    EndIf

    Switch $sLocation
        Case "unknown"
            CaptureRegion()
            If (Not(isArray(getRound()))) Then
                If (Data_Get("Unknown Tap") = -1) Then Data_Add("Unknown Tap", $DATA_TEXT, TimerInit())

                If (TimerDiff(Data_Get("Unknown Tap")) > 5000) Then
                    clickPoint(getPointArg("tap"))
                    Data_Set("Unknown Tap", TimerInit())
                EndIf

                ContinueCase
            Else
                ;In battle, but location cannot be found because Auto button is stuck
                $g_hBattleStuck = TimerInit()
                If TimerDiff($g_hUnknownBattle) > 15000 Then $g_hUnknownBattle = TimerInit()
                If TimerDiff($g_hUnknownBattle) > 10000 Then
                    Log_Add("Stuck in battle, trying to unstuck.", $LOG_DEBUG)
                    If clickBattle("until", "battle-auto", 5, 200) = False Then
                        ContinueCase ;In case frozen, proceed with normal stuck
                    EndIf
                    $g_hUnknownBattle = TimerInit()
                EndIf

                Data_Set("Common Stuck Timer", "Null")
            EndIf
        Case "battle-auto", "battle"
                If $sLocation = "unknown" Then ContinueCase

                ;Fixes bug where Auto button is clicked and gets stuck.
                $g_hUnknownBattle = TimerInit()
                If TimerDiff($g_hBattleStuck) > 15000 Then $g_hBattleStuck = TimerInit()
                If TimerDiff($g_hBattleStuck) > 10000 Then
                   ;If isPixel("175,519,0xA9643C|180,519,0xA9643C" & _
                   ;          "/342,519,0xA9653E|350,519,0xA9653E" & _
                   ;          "/510,519,0xAA653F|515,519,0xAA653F" & _
                   ;          "/681,519,0xA9643C|686,519,0xA9643C") And _
                   ;          $sLocation = "battle-auto" Then ;Pixel for when astromons not attacking

                        If inBattle() = True Then
                            Log_Add("Stuck in battle, trying to unstuck.", $LOG_DEBUG)
                            clickBattle()
                        EndIf
                    ;EndIf

                    If $sLocation = "battle" And TimerDiff($g_hBattleStuck) > 60000 Then
                        ContinueCase
                    EndIf
                    
                    $g_hBattleStuck = TimerInit()
                EndIf

        Case "", "lost-connection", "loading"
            If (_Sleep(10)) Then Return 0

            If (Data_Get("Common Stuck Timer") = "Null") Then
                Data_Set("Common Stuck Timer", TimerInit())
            Else
                Switch getLocation()
                    Case "lost-connection"
                        Log_Add("Lost connection detected, retrying.", $LOG_INFORMATION)
                        clickWhile(getPointArg("lost-connection-retry"), "isLocation", "lost-connection")
                        $sLocation = getLocation()
                    Case "another-device"
                        Log_Add("Another device detected!", $LOG_INFORMATION)

                        Switch $g_iLoggedOutTime
                            Case -1
                                Log_Add("Restart time set to Never, Stopping script.", $LOG_INFORMATION)
                                Stop()
                            Case 0
                                Log_Add("Restart time set to Immediately", $LOG_INFORMATION)
                            Case Else
                                Local $iMinutes = $g_iLoggedOutTime
                                Log_Add("Restart time set to " & $iMinutes & " minutes.", $LOG_INFORMATION)
                                
                                Local $hTimer = TimerInit()
                                $g_bDisableAntiStuck = True
                                While TimerDiff($hTimer) < ($iMinutes*60000)
                                    Local $iSeconds = Int(($iMinutes*60) - (TimerDiff($hTimer)/1000))
                                    Data_Set("Status", "Restarting in: " & getTimeString($iSeconds))
                                    If (_Sleep(1000)) Then ExitLoop
                                WEnd
                                $g_bDisableAntiStuck = False
                        EndSwitch
                    Case Else
                        If ($g_iRestartTime <> 0) Then
                            If (TimerDiff(Data_Get("Common Stuck Timer")) > ($g_iRestartTime*60000)) Then
                                If (Not(navigate("map", True))) Then
                                    Log_Add("Stuck at an unspecified location.", $LOG_ERROR)
                                    takeErrorScreenshot("Common_Stuck")
                                    Log_Add("Restarting game.", $LOG_ERROR)
                                    If (Not(RestartGame())) Then RestartNox()
                                    $sLocation = getLocation()
                                EndIf

                                Data_Set("Common Stuck Timer", "Null")
                            EndIf
                        EndIf
                EndSwitch
            EndIf
        Case Else
            If (Data_Get("Common Stuck Timer") <> "Null") Then Data_Set("Common Stuck Timer", "Null")
    EndSwitch
EndFunc

Func Common_Navigate($sExcludedLocations)
    If (Not(isLocation($sExcludedLocations))) Then
        Data_Set("Status", "Navigating to map.")
        navigate("map", True)
    EndIf
EndFunc