#include-once
#include "../imports.au3"

Func Farm_Golem($iRuns, $iLevel, $sFilter, $iGems, $bQuests, $bHourly)
    Local Const $aLocations = ["battle", "battle-boss", "battle-auto", "battle-end", "battle-sell", "battle-end-exp", "battle-sell-item", "map", "refill", "defeat", "pause", "battle-gem-full", "map-gem-full", "unknown"]

    ;Variables
    Local $iUsedGems = 0 ;Number of gems used since script has started.
    Local $bBossSelected = False ;Resets every new round
    Local $bPerformHourly = False ;Boolean that signifies whether to do hourly or not. Decides on battle ends
    Local $iRun = 0 ;Current run

    ; Main script loop
    addLog($g_aLog, "```Farm Golem script has started.")
    While ($iRuns = 0) Or ($iRun < $iRuns)
        If _Sleep(500) then ExitLoop
        
        Local $sLocation = isLocation($aLocations, False)
        Switch $sLocation
            Case "battle-end-exp", "battle-sell", "battle-sell-item"
                clickPoint(getArg($g_aPoints, "tap"))
            Case "refill"
                If $iUsedGems+30 <= $iGems Then
                    $iUsedGems+=30
                    doRefill()
                    
                    addLog($g_aLog, "Refill " & $iUsedGems & "/" & $iGems, $LOG_NORMAL)
                Else
                    addLog($g_aLog, "Gems used has exceeded max gems.", $LOG_NORMAL)
                    ExitLoop
                EndIf
            Case "battle-end"
                ;if the quests notification with red pixel shows up
                If ($bQuests = "Enabled") And (isPixel(getArg($g_aPixels, "battle-end-quest")) = True) Then collectQuest()

                ;$bPerformHourly is calculated every main loop
                If ($bHourly = "Enabled") And ($bPerformHourly = True) Then
                    doHourly()
                    $bPerformHourly = False
                EndIf

                ;If still in battle-end location then clicks quick restarts. Usually if collectQuest or doHourly has been called then not in battle-end
                If getLocation() = "battle-end" Then 
                    $bBossSelected = False
                    If clickUntil(getArg($g_aPoints, "quick-restart"), "isLocation", "unknown,battle-auto,battle") Then $iRun += 1
                EndIf
            Case "battle"
                ;toggles the auto mode to on.
                clickPoint(getArg($g_aPoints, "battle-auto"))
            Case "unknown", "battle-auto"
                Local $aRound = getRound()
                If ((isArray($aRound) = True) And ($aRound[0] = $aRound[1]) And ($bBossSelected = False)) Or ($sLocation = "battle-boss") Then
                    Local $t_iTimerInit = TimerInit()
                    While (isLocation("battle-auto,battle") = "") Or TimerDiff($t_iTimerInit) < 3000
                        If _Sleep(10) Then Return -2
                    WEnd
                    clickPoint(getArg($g_aPoints, "boss"))

                    $bBossSelected = True
                EndIf
            Case "battle-boss"
                If $bBossSelected = False Then
                    If _Sleep(1000) Then Return -2
                    clickPoint(getArg($g_aPoints, "boss"))

                    $bBossSelected = True
                EndIf
            Case "map"
                $bBossSelected = False

                ;Navigate to golems
                If navigate("golem-dungeons") Then
                    ;Select golem level
                    addLog($g_aLog, "Entering golem B" & $iLevel & ".", $LOG_NORMAL)
                    If clickUntil(getArg($g_aPoints, "golem-dungeons-b" & $iLevel), "isLocation", "map-battle", 5, 500) = False Then
                        addLog($g_aLog, "Could not enter golem B" & $iLevel & ".", $LOG_NORMAL)
                    Else
                        ;Enter into battle
                        If clickUntil(getArg($g_aPoints, "map-battle-play"), "isLocation", "unknown,battle,battle-auto", 5, 500) = True Then $iRun += 1
                        If waitLocation("battle,battle-auto", 30) = True Then
                            addLog($g_aLog, "In battle.")
                        EndIf
                    EndIf
                Else
                    ContinueLoop
                EndIf
                
            Case ""
                If _Sleep(3000) Then Return -2
                If isLocation($aLocations) = "" Then
                    If navigate("map", True) = False Then
                        addLog($g_aLog, "Something went wrong!", $LOG_ERROR)
                    EndIf
                EndIf
        EndSwitch
    WEnd
    addLog($g_aLog, "Farm Golem script has stopped.```")

    Stop()
EndFunc