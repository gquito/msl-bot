#include-once
#include "../imports.au3"

Func Farm_Rare($iRuns, $sMap, $sDifficulty, $sStage, $aCapture, $aGemGrade, $iGems, $sGuardianMode, $bBoss, $bQuests, $bHourly, $t_aData = Null, $aDataPre = Null, $aDataPost = Null)
    Local Const $aLocations = ["loading", "battle", "battle-auto", "map-gem-full", "battle-gem-full", "catch-mode", "pause", "battle-end", "battle-end-exp", "battle-sell", "map", "refill", "defeat", "unknown", "battle-boss"]
    
    ;Variables
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

    If isArray($t_aData) = True Then
        Local $t_Var = Int(StringSplit(getArg($t_aData, "Runs"), "/", $STR_NOCOUNT)[0])
        If $t_Var <> "-1" Then $iRun = $t_Var

        Local $t_Var = Int(StringSplit(getArg($t_aData, "Refill"), "/", $STR_NOCOUNT)[0])
        If $t_Var <> "-1" Then $iUsedGems = $t_Var
    
        Local $t_Var = formatArgs(StringStripWS(getArg($t_aData, "Caught"), $STR_STRIPALL), ";", ":")
        If $t_Var <> "-1" Then $aCaught = $t_Var

        Local $t_Var = formatArgs(StringStripWS(getArg($t_aData, "Missed"), $STR_STRIPALL), ";", ":")
        If $t_Var <> "-1" Then $aMissed = $t_Var
    EndIf

    ; Main script loop
    Local $aData[7][2] = [["Runs", ""], ["Win_Rate", ""], ["Average_Time", ""], ["Estimated_Finish", ""], ["Refill", ""], ["Caught", ""], ["Missed", ""]]
    
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

        displayData($aData, $hLV_Stat, $aDataPre, $aDataPost)
        ;--------------------------------------------------------------------

        If _Sleep(500) Then ExitLoop

        Local $sLocation = isLocation($aLocations, False)
        Switch $sLocation
            Case "", "unknown"
                $hUnknownTimer = Null
            Case "battle-end", "map", "map-battle", "refill"
                $iAstrochips = 3
        EndSwitch

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
                    Else
                        ContinueLoop
                    EndIf
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
                ;Guardian dungeon will be done at the start of the script and every 30 minutes
                If ($sGuardianMode <> "Disabled") And ($g_bPerformGuardian = True) Then
                    $aDataPost = Farm_Guardian($sGuardianMode, $iUsedGems-$iGems, False, True, $bQuests, $bHourly, $aDataPost, $aData)
                    $iUsedGems += Int(getArg($g_vExtended, "Refill"))
                EndIf

                $bBossSelected = False
                If ($iRun >= $iRuns) And ($iRuns <> 0) Then ExitLoop

                ;Navigate to stage
                If enterStage($sMap, $sDifficulty, $sStage) = True Then
                    $iRun += 1

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
            Case "battle-sell", "battle-end-exp", "battle-sell-item"
                clickUntil(getArg($g_aPoints, "tap"), "isLocation", "battle-end", 30, 200)
            Case "astromon-full"
                addLog($g_aLog, "Astromon bag is full.", $LOG_ERROR)
                navigate("village", True)
                ExitLoop
            Case "battle-gem-full", "map-gem-full"
                addLog($g_aLog, "Gem box is full, selling gems.")
                If navigate("manage") = True Then
                    addLog($g_aLog, "Selling grades: " & $aGemGrade & ".", $LOG_NORMAL)
                    For $iGrade in StringSplit($aGemGrade, ",", $STR_NOCOUNT)
                        clickPoint(getArg($g_aPoints, "manage-grade" & $iGrade), 1, 0, Null)
                        If _Sleep(500) Then Return False
                    Next

                    For $i = 0 To 3 
                        clickPoint(getArg($g_aPoints, "manage-sell-selected"), 3, 100)
                        clickPoint(getArg($g_aPoints, "manage-sell-confirm"), 3, 100, Null)
                    Next

                    addLog($g_aLog, "Finished selling gems.", $LOG_NORMAL)
                    navigate("map", False, False)
                Else
                    addLog($g_aLog, "Could not navigate to manage.", $LOG_ERROR)
                EndIf
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

    Return $aData
EndFunc