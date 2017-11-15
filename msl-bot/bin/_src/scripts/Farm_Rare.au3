#include-once
#include "../imports.au3"

Func Farm_Rare($iRuns, $sMap, $sDifficulty, $sStage, $aCapture, $aGemGrade, $iGems, $bBoss, $bQuests, $bHourly)
    Local Const $aLocations = ["battle", "battle-auto", "map-gem-full", "battle-gem-full", "catch-mode", "pause", "battle-end", "battle-end-exp", "battle-sell", "map", "refill", "defeat", "unknown", "battle-boss"]
    
    ;Variables
    Local $aData[7][2] = [["Runs", "0/" & $iRuns], ["Win_Rate", "0%"], ["Average_Time", "0M 00S"], ["Estimated_Finish", "00H 00M 00S"], ["Refill", "0/" & $iGems], ["Caught", ""], ["Missed", ""]]
    
    $aCapture = StringSplit($aCapture, ",", $STR_NOCOUNT)
    Local $iSize = UBound($aCapture)
    Local $aCaught[$iSize][2]; Data for caught and missed astromons
    Local $aMissed[$iSize][2]; Missed data
    For $i = 0 To $iSize-1
        $aCaught[$i][0] = StringLeft($aCapture[$i], 2)
        $aMissed[$i][0] = StringLeft($aCapture[$i], 2)

        $aCaught[$i][1] = 0
        $aMissed[$i][1] = 0
    Next

    Local $hEstimated = Null ;Timer for estimated finish
    Local $iCurEstimated = Null ;Current estimated in milliseconds
    Local $iLongestEstimated = Null ;Current longest estimated

    Local $iRun = 0 ;Current run
    Local $iAstrochips = 3 ;Current number of available astrochips
    Local $hUnknownTimer = Null ;Timer for when the location is not known.
    Local $iDefeat = 0 ;Number of defeats
    Local $iUsedGems = 0 ;Number of gems used since script has started.
    Local $bBossSelected = False ;Resets every new round
    Local $bPerformHourly = False ;Boolean that signifies whether to do hourly or not. Decides on battle ends

    ; Main script loop
    addLog($g_aLog, "```Farm Rare script has started.")

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

        Local $sCaught = ""
        Local $sMissed = ""
        For $i = 0 To $iSize-1
            $sCaught &= "; " & $aCaught[$i][0] & ": " & $aCaught[$i][1] 
            $sMissed &= "; " & $aMissed[$i][0] & ": " & $aMissed[$i][1]
        Next
        setArg($aData, "Caught", StringMid($sCaught, 2))
        setArg($aData, "Missed", StringMid($sMissed, 2))

        displayData($aData, $hLV_Stat)
        ;--------------------------------------------------------------------

        If _Sleep(500) Then ExitLoop

        Local $sLocation = isLocation($aLocations, False)
        If $sLocation <> "" And $sLocation <> "unknown" Then $hUnknownTimer = Null

        Switch $sLocation
            Case "battle"
                While $iAstrochips > 0 ;Loop for checking for more than 1 rare
                    If _Sleep(10) Then ExitLoop(2)
                    If navigate("catch-mode", False, False) = False Then ExitLoop

                    Local $sResult = catch($aCapture, $iAstrochips, False)
                    If $sResult <> "" Then
                        ;Found and catch status
                        If StringLeft($sResult, 1) <> "!" Then
                            ;Successfully caught
                            addLog($g_aLog, "-Caught a(n) " & $sResult & ".", $LOG_NORMAL)
                            setArg($aCaught, StringLeft($sResult, 2), Int(getArg($aCaught, StringLeft($sResult, 2))+1))
                        Else
                            ;Not caught
                            addLog($g_aLog, "-Failed to catch " & StringMid($sResult, 2) & ".", $LOG_NORMAL)
                            setArg($aMissed, StringLeft(StringMid($sResult, 2), 2), Int(getArg($aMissed, StringLeft(StringMid($sResult, 2), 2))+1))
                        EndIf
                    Else
                        ;Nothing found.
                        clickPoint(getArg($g_aPoints, "catch-mode-cancel"))
                        ExitLoop
                    EndIf
                WEnd
                clickUntil(getArg($g_aPoints, "battle-auto"), "isLocation", "battle-auto", 5, 1000)
            Case "catch-mode"
                clickPoint(getArg($g_aPoints, "catch-mode-cancel"))
            Case "battle-end"
                ;if the quests notification with red pixel shows up
                If ($bQuests = "Enabled") And (isPixel(getArg($g_aPixels, "battle-end-quest")) = True) Then collectQuest()

                ;Hourly will only be done in specific times. Refer to the function.
                If ($bHourly = "Enabled") Then doHourly()

                ;If still in battle-end location then clicks quick restarts. Usually if collectQuest or doHourly has been called then not in battle-end
                If getLocation() = "battle-end" Then 
                    $bBossSelected = False
                    If ($iRun >= $iRuns) And ($iRuns <> 0) Then ExitLoop
                    If clickUntil(getArg($g_aPoints, "quick-restart"), "isLocation", "unknown,battle-auto,battle,map-battle") Then 
                        If waitLocation("map-battle", 5) = True Then
                            ;Happens when coming from defeat
                            If clickUntil(getArg($g_aPoints, "map-battle-play"), "isLocation", "unknown,refill,battle,battle-auto", 5, 500) = True Then $iRun += 1
                        Else
                            $iRun += 1
                        EndIf
                    EndIf

                    $iAstrochips = 3
                    $iCurEstimated = (TimerDiff($g_hScriptTimer)/$iRun)*(($iRuns+1)-$iRun)
                    $hEstimated = TimerInit()
                Else
                    navigate("map", False, False)
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
            Case "map"
                $bBossSelected = False
                If ($iRun >= $iRuns) And ($iRuns <> 0) Then ExitLoop

                ;Navigate to stage
                If enterStage($sMap, $sDifficulty, $sStage) = True Then
                    $iRun += 1
                    $iAstrochips = 3
                    $iCurEstimated = (TimerDiff($g_hScriptTimer)/$iRun)*(($iRuns+1)-$iRun)
                    $hEstimated = TimerInit()
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
            Case "astromon-full"
                addLog($g_aLog, "Astromon bag is full.", $LOG_ERROR)
                navigate("village")
                ExitLoop
            Case "battle-sell", "battle-end-exp", "battle-sell-item"
                ;Clicks 2nd position just in case. Stop
                clickUntil("229,234", "isLocation", "battle-sell,battle-sell-item", 30, 500)

                ;Going into battle-sell-item location.
                Local $t_sLoc = getLocation($g_aLocations, False)
                If $t_sLoc = "battle-sell" Then
                    Local $aGem = findColor("755,236", "-600,1", 0xFDF876, 10, -1)
                    If isArray($aGem) = True Then
                        clickUntil($aGem, "isLocation", "battle-sell-item")
                        $t_sLoc = "battle-sell-item"
                    Else
                        clickUntil("229,234", "isLocation", "battle-sell-item", 30, 500)
                    EndIf
                EndIf

                If $t_sLoc = "battle-sell-item" Then
                    If isPixel(getArg($g_aPixels, "battle-sell-item-gold"), 10) = True Then
                        ;Tries to avoid gold bonus
                        clickPoint(getArg($g_aPoints, "battle-sell-item-okay"), 1, 0)
                        ContinueLoop
                    EndIf

                    ;Actual filtering
                    Local $aGem = getGemData()
                    If $aGem[0] = "-" Then
                        If clickWhile(getArg($g_aPoints, "battle-sell-item-cancel"), "isLocation", "battle-sell-item,battle-sell", 10, 200) = False Then
                            clickWhile(getArg($g_aPoints, "battle-sell-item-okay"), "isLocation", "battle-sell-item,battle-sell", 10, 200)
                        EndIf
                    Else 
                        ;Actual gem
                        If StringInStr($aGemGrade, $aGem[0]) Then
                            If clickWhile(getArg($g_aPoints, "battle-sell-item-sell"), "isLocation", "battle-sell-item", 10, 200) = False Then
                                Local $t_hTimer = TimerInit()
                                While (isLocation("batte-end") = "") And ($t_hTimer < 5000)
                                    clickPoint(getArg($g_aPoints, "battle-sell-item-cancel"))
                                    If _Sleep(100) Then ExitLoop
                                WEnd
                            EndIf
                        EndIf
                    EndIf
                EndIf

                If clickWhile(getArg($g_aPoints, "battle-sell-item-cancel"), "isLocation", "battle-sell-item,battle-sell", 10, 200) = False Then
                    clickWhile(getArg($g_aPoints, "battle-sell-item-okay"), "isLocation", "battle-sell-item,battle-sell", 10, 200)
                EndIf
                clickUntil(getArg($g_aPoints, "tap"), "isLocation", "battle-end", 20, 200)
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
    addLog($g_aLog, "Farm Rare script has stopped.```")

    Stop()
EndFunc