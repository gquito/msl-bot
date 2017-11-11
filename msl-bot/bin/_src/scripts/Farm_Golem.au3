#include-once
#include "../imports.au3"

Func Farm_Golem($iRuns, $iLevel, $sFilter, $iGems, $bQuests, $bHourly)
    Local Const $aLocations = ["defeat", "battle", "battle-boss", "battle-auto", "battle-end", "battle-sell", "battle-end-exp", "battle-sell-item", "map", "refill", "defeat", "pause", "battle-gem-full", "map-gem-full", "unknown"]

    ;Variables
    Local $aData[8][2] = [["Runs", "0/" & $iRuns], ["Win_Rate", "0%"], ["Average_Time", "0M 00S"], ["Estimated_Finish", "00H 00M 00S"], ["Refill", "0/" & $iGems], ["Gems_Kept", "0"], ["Eggs", "0"], ["Sell_Profit", "0"]]
    
    Local $hEstimated = Null ;Timer for estimated finish
    Local $iCurEstimated = Null ;Current estimated in milliseconds
    Local $iLongestEstimated = Null ;Current longest estimated

    Local $hUnknownTimer = Null ;Timer for when the location is not known.
    Local $iDefeat = 0 ;Number of defeats
    Local $iUsedGems = 0 ;Number of gems used since script has started.
    Local $bBossSelected = False ;Resets every new round
    Local $bPerformHourly = False ;Boolean that signifies whether to do hourly or not. Decides on battle ends
    Local $iEggs = 0 ;Number of eggs kept
    Local $iGemsKept = 0 ;Number of gems kept
    Local $iSellProfit = 0 ;Gold profit from selling gems. Does not include the round bonuses
    Local $iRun = 0 ;Current run

    ; Main script loop
    $g_hScriptTimer = TimerInit()
    addLog($g_aLog, "```Farm Golem script has started.")

    If isLocation($aLocations, False) = "" Then navigate("map")
    While ($iRuns = 0) Or ($iRun < $iRuns+1)
        ;Settings data-----------------------------------------------------
        If $iRuns <> 0 Then
            setArg($aData, "Runs", $iRun & "/" & $iRuns)
        Else   
            setArg($aData, "Runs", $iRun)
        EndIf

        ;Handles time finish estimation and progressbar
        Local $iEstimated = ($iCurEstimated - TimerDiff($hEstimated))/1000 ;Estimated time left in seconds
        Local $iDenom = ($iCurEstimated/1000)
        If $iLongestEstimated < $iDenom Or $iLongestEstimated = 0 Or $iLongestEstimated = Null Then $iLongestEstimated = $iDenom
        If ($iRun <> 0) And ($iRuns <> 0) And ($iEstimated >= 0) Then 
            If $iRun > 2 Then 
                setArg($aData, "Estimated_Finish", getTimeString($iEstimated))
                GUICtrlSetData($idPB_Progress, 100 - ($iEstimated/$iLongestEstimated*100))
            Else
                setArg($aData, "Estimated_Finish", "Need more data.")
            EndIf
        Else
            If $iRuns = 0 Then
                setArg($aData, "Estimated_Finish", "Not available.")
            EndIf
        EndIf

        If $iRun <> 0 Then setArg($aData, "Win_Rate", StringFormat("%.2f", (($iRun-$iDefeat)/$iRun*100)) & "%")
        If $iRun <> 0 Then setArg($aData, "Average_Time", getTimeString(TimerDiff($g_hScriptTimer)/$iRun/1000))
        setArg($aData, "Refill", $iUsedGems & "/" & $iGems)
        setArg($aData, "Gems_Kept", $iGemsKept)
        setArg($aData, "Eggs", $iEggs)
        setArg($aData, "Sell_Profit", $iSellProfit)

        displayData($aData, $hLV_Stat)
        ;--------------------------------------------------------------------

        If _Sleep(500) then ExitLoop
        Local $sLocation = isLocation($aLocations, False)
        If $sLocation <> "" And $sLocation <> "unknown" Then $hUnknownTimer = Null

        Switch $sLocation
            Case "battle-end-exp", "battle-sell", "battle-sell-item"
                ;Clicks 2nd position just in case. Stop
                clickUntil("229,234", "isLocation", "battle-sell,battle-sell-item", 10, 500)

                ;Going into battle-sell-item location.
                Local $t_sLoc = getLocation($g_aLocations, False)
                If $t_sLoc = "battle-sell" Then
                    Local $aGem = findColor("400,236", "-250,1", 0xFDF876, 10, -1)
                    If isArray($aGem) = True Then
                        clickUntil($aGem, "isLocation", "battle-sell-item")
                        $t_sLoc = "battle-sell-item"
                    EndIf
                EndIf

                If $t_sLoc = "battle-sell-item" Then
                    ;Actual filtering
                    Local $aGem = getGemData()
                    If $aGem[0] = "-" Then
                        addLog($g_aLog, "Could not identify gem/egg.", $LOG_ERROR)
                        If clickWhile(getArg($g_aPoints, "battle-sell-item-cancel"), "isLocation", "battle-sell-item,battle-sell", 10, 200) = False Then
                            clickWhile(getArg($g_aPoints, "battle-sell-item-okay"), "isLocation", "battle-sell-item,battle-sell", 10, 200)
                        EndIf
                    ElseIf $aGem[0] = "EGG" Then
                        $iEggs += 1
                        addLog($g_aLog, "Found an egg.", $LOG_NORMAL)
                        clickWhile(getArg($g_aPoints, "battle-sell-item-okay"), "isLocation", "battle-sell-item,battle-sell", 10, 200)
                    Else 
                        ;Actual gem
                        Local $sStatus = "" ;Status whether gem is sold or kept, for log.
                        If filterGem($aGem) = False Then
                            ;Selling gem
                            $sStatus = "Sold"
                            $iSellProfit += Int($aGem[5])

                            clickWhile(getArg($g_aPoints, "battle-sell-item-sell"), "isLocation", "battle-sell-item,battle-sell", 10, 200)
                        Else 
                            ;Keeping gem
                            $sStatus = "Kept"
                            $iGemsKept += 1

                            clickWhile(getArg($g_aPoints, "battle-sell-item-cancel"), "isLocation", "battle-sell-item,battle-sell", 10, 200)
                        EndIf

                        ;Display info and setting data
                        addLog($g_aLog, $sStatus & ": " & stringGem($aGem), $LOG_NORMAL)
                    EndIf
                EndIf
            Case "refill"
                ;Refill function handles starting the quickrestart and or the start battle from map-battle. Also handles the error messages
                If $iUsedGems+30 <= $iGems Then
                    If doRefill() = True Then
                        $iUsedGems+=30
                        addLog($g_aLog, "Refill " & $iUsedGems & "/" & $iGems, $LOG_NORMAL)
                    Else
                        ExitLoop
                    EndIf
                Else
                    addLog($g_aLog, "Gems used has exceeded max gems.", $LOG_NORMAL)
                    ExitLoop
                EndIf
            Case "battle-end"
                ;if the quests notification with red pixel shows up
                If ($bQuests = "Enabled") And (isPixel(getArg($g_aPixels, "battle-end-quest")) = True) Then collectQuest()

                ;Hourly will only be done in specific times. Refer to the function.
                If ($bHourly = "Enabled") Then doHourly()

                ;If still in battle-end location then clicks quick restarts. Usually if collectQuest or doHourly has been called then not in battle-end
                If getLocation() = "battle-end" Then 
                    $bBossSelected = False
                    If $iRun >= $iRuns Then ExitLoop
                    If clickUntil(getArg($g_aPoints, "quick-restart"), "isLocation", "unknown,battle-auto,battle,map-battle") Then 
                        If waitLocation("map-battle", 5) = True Then
                            ;Happens when coming from defeat
                            If clickUntil(getArg($g_aPoints, "map-battle-play"), "isLocation", "unknown,refill,battle,battle-auto", 5, 500) = True Then $iRun += 1
                        Else
                            $iRun += 1
                        EndIf
                    EndIf

                    $iCurEstimated = (TimerDiff($g_hScriptTimer)/$iRun)*(($iRuns+1)-$iRun)
                    $hEstimated = TimerInit()
                EndIf
            Case "battle"
                ;toggles the auto mode to on.
                clickPoint(getArg($g_aPoints, "battle-auto"))
            Case "map"
                $bBossSelected = False
                If $iRun >= $iRuns+1 Then ExitLoop

                ;Navigate to golems
                If navigate("golem-dungeons") Then
                    ;Select golem level
                    addLog($g_aLog, "Entering golem B" & $iLevel & ".", $LOG_NORMAL)
                    If clickUntil(getArg($g_aPoints, "golem-dungeons-b" & $iLevel), "isLocation", "map-battle", 5, 500) = False Then
                        addLog($g_aLog, "Could not enter golem B" & $iLevel & ".", $LOG_NORMAL)
                    Else
                        ;Enter into battle
                        If clickUntil(getArg($g_aPoints, "map-battle-play"), "isLocation", "unknown,refill,battle,battle-auto", 5, 500) = True Then $iRun += 1
                        If waitLocation("battle,battle-auto", 30) = True Then
                            addLog($g_aLog, "In battle.")
                            
                                $iCurEstimated = (TimerDiff($g_hScriptTimer)/$iRun)*(($iRuns+1)-$iRun)
                                $hEstimated = TimerInit()
                        EndIf
                    EndIf
                Else
                    ContinueLoop
                EndIf
            Case "pause"
                clickPoint(getArg($g_aPoints, "battle-continue"))
            Case "defeat"
                If clickUntil(getArg($g_aPoints, "battle-give-up"), "isLocation", "unknown,battle-end-exp,battle-sell,battle-sell-item,battle-end") = True Then
                    $iDefeat += 1
                    addLog($g_aLog, "You have been defeated.", $LOG_NORMAL)
                EndIf
            Case "battle-boss"
                If $bBossSelected = False Then
                    If _Sleep(1000) Then ExitLoop
                    clickPoint(getArg($g_aPoints, "boss"))

                    $bBossSelected = True
                EndIf
            Case "unknown", "battle-auto"
                Local $aRound = getRound()
                If ((isArray($aRound) = True) And ($aRound[0] = $aRound[1]) And ($bBossSelected = False)) Or ($sLocation = "battle-boss") Then
                    Local $t_iTimerInit = TimerInit()
                    While (isLocation("battle-auto,battle") = "") Or TimerDiff($t_iTimerInit) < 3000
                        If _Sleep(10) Then ExitLoop
                    WEnd
                    clickPoint(getArg($g_aPoints, "boss"))

                    $bBossSelected = True
                EndIf

                If (isArray($aRound) = False) And ($sLocation = "unknown") then 
                    ContinueCase
                Else
                    $hUnknownTimer = Null
                Endif
            Case ""
                ;Waits 20 seconds before knowing that it is stuck in an unspecified location.
                If _Sleep(10) Then ExitLoop
                
                If $hUnknownTimer = Null Then 
                    $hUnknownTimer = TimerInit()
                Else
                    If TimerDiff($hUnknownTimer) >= 20000 Then
                        If navigate("map", True) = False Then
                            addLog($g_aLog, "Something went wrong!", $LOG_ERROR)
                        EndIf
                        $hUnknownTimer = Null
                    EndIf
                EndIf
        EndSwitch
    WEnd
    addLog($g_aLog, "Farm Golem script has stopped.```")

    Stop()
EndFunc