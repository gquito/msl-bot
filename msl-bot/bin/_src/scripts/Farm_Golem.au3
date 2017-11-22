#include-once
#include "../imports.au3"

Func Farm_Golem($iRuns, $iLevel, $sFilter, $iGems, $sGuardianMode, $bBoss, $bQuests, $bHourly, $t_aData = Null, $aDataPre = Null, $aDataPost = Null)
    Local Const $aLocations = ["loading", "defeat", "battle", "battle-boss", "battle-auto", "battle-end", "battle-sell", "battle-end-exp", "battle-sell-item", "map", "refill", "pause", "battle-gem-full", "map-gem-full", "unknown"]

    ;Variables
    Local $hEstimated = Null ;Timer for estimated finish
    Local $iCurEstimated = Null ;Current estimated in milliseconds
    Local $iLongestEstimated = Null ;Current longest estimated

    Local $iRun = 0 ;Current run
    Local $hUnknownTimer = Null ;Timer for when the location is not known.
    Local $iDefeat = 0 ;Number of defeats
    Local $iUsedGems = 0 ;Used gems for refill
    Local $bBossSelected = False ;Resets every new round
    Local $iEggs = 0 ;Number of eggs kept
    Local $iGemsKept = 0 ;Number of gems kept
    Local $iSellProfit = 0 ;Gold profit from selling gems. Does not include the round bonuses

    If isArray($t_aData) = True Then
        Local $t_Var = Int(StringSplit(getArg($t_aData, "Runs"), "/", $STR_NOCOUNT)[0])
        If $t_Var <> "-1" Then $iRun = $t_Var

        Local $t_Var = Int(StringSplit(getArg($t_aData, "Refill"), "/", $STR_NOCOUNT)[0])
        If $t_Var <> "-1" Then $iUsedGems = $t_Var

        Local $t_Var = Int(getArg($t_aData, "Gems_Kept"))
        If $t_Var <> "-1" Then $iGemsKept = $t_Var

        Local $t_Var = Int(getArg($t_aData, "Eggs"))
        If $t_Var <> "-1" Then $iEggs = $t_Var

        Local $t_Var = Int(getArg($t_aData, "Sell_Profit"))
        If $t_Var <> "-1" Then $iSellProfit = $t_Var
    EndIf

    ; Main script loop
    Local $aData[8][2] = [["Runs", ""], ["Win_Rate", ""], ["Average_Time", ""], ["Estimated_Finish", ""], ["Refill", "" & $iGems], ["Gems_Kept", ""], ["Eggs", ""], ["Sell_Profit", ""]]
    
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
        If $iRuns <> 0 Then GUICtrlSetData($idPB_Progress, ($iRun/$iRuns)*100)
        Local $iEstimated = ($iCurEstimated - TimerDiff($hEstimated))/1000 ;Estimated time left in seconds
        Local $iDenom = ($iCurEstimated/1000)
        If $iLongestEstimated < $iDenom Or $iLongestEstimated = 0 Or $iLongestEstimated = Null Then $iLongestEstimated = $iDenom
        If ($iRun <> 0) And ($iRuns <> 0) And ($iEstimated >= 0) Then 
            If $iRun > 2 Then 
                setArg($aData, "Estimated_Finish", getTimeString($iEstimated))
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

        displayData($aData, $hLV_Stat, $aDataPre, $aDataPost)
        ;--------------------------------------------------------------------

        If _Sleep(500) Then ExitLoop
        Local $sLocation = isLocation($aLocations, False)
        If $sLocation <> "" And $sLocation <> "unknown" Then $hUnknownTimer = Null

        Switch $sLocation
            Case "battle-end-exp"
                If clickUntil("229,234", "isLocation", "battle-sell-item", 30, 200) = True Then ContinueCase
            Case "battle-sell"
                If getLocation($g_aLocations, False) = "battle-sell-item" Then ContinueCase 
                Local $aGem = findColor("400,236", "-250,1", 0xFDF876, 10, -1)
                If isArray($aGem) = False Then $aGem = findColor("400,252", "-250,1", 0xF769B9, 10, -1) ;egg pixel
                
                If isArray($aGem) = True Then
                    clickUntil($aGem, "isLocation", "battle-sell-item")
                    ContinueCase
                Else
                    clickUntil("229,234", "isLocation", "battle-sell-item", 30, 500)
                EndIf
            Case "battle-sell-item"
                If isPixel(getArg($g_aPixels, "battle-sell-item-gold"), 10) = True Then
                    ;Tries to avoid gold bonus
                    clickPoint(getArg($g_aPoints, "battle-sell-item-okay"), 1, 0)
                    ContinueLoop
                EndIf

                ;Actual filtering
                Local $aGem = getGemData()
                If ($aGem[0] <> "EGG") And ($aGem[1] = "-") Then
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

                        If clickWhile(getArg($g_aPoints, "battle-sell-item-sell"), "isLocation", "battle-sell-item", 10, 200) = False Then
                            $sStatus = "Unknown" ;If could not sell because got stuck in battle-sell-item
                            Local $t_hTimer = TimerInit()
                            While (isLocation("batte-end") = "") And ($t_hTimer < 5000)
                                clickPoint(getArg($g_aPoints, "battle-sell-item-cancel"))
                                If _Sleep(100) Then ExitLoop
                            WEnd
                        EndIf
                    Else 
                        ;Keeping gem
                        $sStatus = "Kept"
                        $iGemsKept += 1

                        clickWhile(getArg($g_aPoints, "battle-sell-item-cancel"), "isLocation", "battle-sell-item,battle-sell", 10, 200)
                    EndIf

                    ;Display info and setting data
                    addLog($g_aLog, $sStatus & ": " & stringGem($aGem), $LOG_NORMAL)
                    clickUntil(getArg($g_aPoints, "tap"), "isLocation", "battle-end", 20, 200)
                EndIf
            Case "refill"
                ;Refill function handles starting the quickrestart and or the start battle from map-battle. Also handles the error messages
                If $iUsedGems+30 <= $iGems Then
                    If doRefill() = True Then
                        $iUsedGems+=30
                        $iRun += 1

                        $iCurEstimated = (TimerDiff($g_hScriptTimer)/$iRun)*(($iRuns+1)-$iRun)
                        $hEstimated = TimerInit()

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
                If ($bHourly = "Enabled") And ($g_bPerformHourly = True) Then doHourly()

                ;Guardian dungeon will be done at the start of the script and every 30 minutes
                If ($sGuardianMode <> "Disabled") And ($g_bPerformGuardian = True) Then
                    $aDataPost = Farm_Guardian($sGuardianMode, $iUsedGems-$iGems, False, True, $bQuests, $bHourly, $aDataPost, $aData)
                    $iUsedGems += Int(getArg($g_vExtended, "Refill"))
                EndIf

                ;If still in battle-end location then clicks quick restarts. Usually if collectQuest or doHourly has been called then not in battle-end
                If getLocation() = "battle-end" Then 
                    $bBossSelected = False
                    If ($iRun >= $iRuns) And ($iRuns <> 0) Then ExitLoop
                    If enterBattle() = True Then 
                        $iRun += 1
                        $iCurEstimated = (TimerDiff($g_hScriptTimer)/$iRun)*(($iRuns+1)-$iRun)
                        $hEstimated = TimerInit()
                    EndIf
                Else
                    navigate("map", False, False)
                EndIf
            Case "battle"
                ;toggles the auto mode to on.
                clickPoint(getArg($g_aPoints, "battle-auto"))
            Case "map"
                ;Guardian dungeon will be done at the start of the script and every 30 minutes
                If ($sGuardianMode <> "Disabled") And ($g_bPerformGuardian = True) Then
                    $aDataPost = Farm_Guardian($sGuardianMode, $iUsedGems-$iGems, False, True, $bQuests, $bHourly, $aDataPost, $aData)
                    $iUsedGems += Int(getArg($g_vExtended, "Refill"))
                EndIf

                $bBossSelected = False
                If ($iRun >= $iRuns) And ($iRuns <> 0) Then ExitLoop

                ;Navigate to golems
                If navigate("golem-dungeons") = True Then
                    ;Select golem level
                    addLog($g_aLog, "Entering golem B" & $iLevel & ".", $LOG_NORMAL)
                    If clickUntil(getArg($g_aPoints, "golem-dungeons-b" & $iLevel), "isLocation", "map-battle", 5, 500) = False Then
                        addLog($g_aLog, "Could not enter golem B" & $iLevel & ".", $LOG_NORMAL)
                    Else
                        ;Enter into battle
                        If enterBattle() = True Then 
                            $iRun += 1
                            $iCurEstimated = (TimerDiff($g_hScriptTimer)/$iRun)*(($iRuns+1)-$iRun)
                            $hEstimated = TimerInit()
                        Else
                            ContinueLoop
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

            Case "battle-gem-full", "map-gem-full"
                addLog($g_aLog, "Gem inventory is full.", $LOG_ERROR)
                navigate("village")
                ExitLoop

            Case "battle-boss"
                If $bBossSelected = False Then ContinueCase

            Case "unknown", "battle-auto"
                Local $aRound = getRound()
                If ($bBoss = "Enabled") And (($sLocation = "battle-boss") Or (($bBossSelected = False) And ((isArray($aRound) = True) And ($aRound[0] = $aRound[1])))) Then
                    If _Sleep(1000) Then ExitLoop

                    Local $t_iTimerInit = TimerInit()
                    While (isLocation("battle-auto,battle") = "") And (TimerDiff($t_iTimerInit) < 5000)
                        If _Sleep(10) Then ExitLoop(2)
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
                    If TimerDiff($hUnknownTimer) > 20000 Then
                        If navigate("map", True) = False Then
                            addLog($g_aLog, "Something went wrong!", $LOG_ERROR)
                        EndIf
                        $hUnknownTimer = Null
                    EndIf
                EndIf
        EndSwitch
    WEnd
    addLog($g_aLog, "Farm Golem script has stopped.```")

    Return $aData
EndFunc