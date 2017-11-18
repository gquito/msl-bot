#include-once
#include "../imports.au3"

Func Farm_Astromon($iCount, $sAstromon, $bFinishRound, $bFinalRound, $sMap, $sDifficulty, $sStage, $aCapture, $aGemGrade, $iGems, $bBoss, $bQuests, $bHourly, $aDataPre = Null, $aDataPost = Null)
    Local Const $aLocations = ["battle", "battle-auto", "map-gem-full", "battle-gem-full", "catch-mode", "pause", "battle-end", "battle-end-exp", "battle-sell", "map", "refill", "defeat", "unknown", "battle-boss"]
    
    ;Variables
    If $bFinalRound = "Enabled" Then $bFinishRound = "Enabled"
    Local $aData[5][2] = [["Astromon_Caught", "0"], ["Runs", "0"], ["Refill", "0/" & $iGems], ["Rare_Caught", ""], ["Rare_Missed", ""]]

    $aCapture &= "," & $sAstromon
    $aCapture = StringSplit($aCapture, ",", $STR_NOCOUNT)
    Local $iSize = UBound($aCapture)-1
    Local $aCaught[$iSize][2]; Data for caught and missed astromons
    Local $aMissed[$iSize][2]; Missed data
    For $i = 0 To $iSize-1
        $aCaught[$i][0] = StringLeft($aCapture[$i], 2)
        $aMissed[$i][0] = StringLeft($aCapture[$i], 2)

        $aCaught[$i][1] = 0
        $aMissed[$i][1] = 0
    Next

    Local $iRun = 0 ;Number of runs 
    Local $iDefeat = 0 ;Number of defeat
    Local $iCaught = 0 ;Number of normal astromons caught
    Local $iAstrochips = 3 ;Current number of available astrochips
    Local $hUnknownTimer = Null ;Timer for when the location is not known.
    Local $iUsedGems = 0 ;Number of gems used since script has started.
    Local $bBossSelected = False ;Resets every new round
    Local $bPerformHourly = False ;Boolean that signifies whether to do hourly or not. Decides on battle ends
    Local $aRound = [0, 0] ;Rounds
    Local $iCurRound = 1 ;Current round
    Local $iSkipRound = -1 ;Skips if the round is this.
    $g_sExtended = "Success"

    ; Main script loop
    addLog($g_aLog, "```Farm Astromon script has started.")

    If isLocation($aLocations, False) = "" Then navigate("map")
    While $iCaught < $iCount
        ;Settings data-----------------------------------------------------
        setArg($aData, "Runs", $iRun)
        setArg($aData, "Astromon_Caught", $iCaught & "/" & $iCount)
        setArg($aData, "Refill", $iUsedGems & "/" & $iGems)

        Local $sCaught = ""
        Local $sMissed = ""
        For $i = 0 To $iSize-1
            $sCaught &= "; " & $aCaught[$i][0] & ": " & $aCaught[$i][1] 
            $sMissed &= "; " & $aMissed[$i][0] & ": " & $aMissed[$i][1]
        Next
        setArg($aData, "Rare_Caught", StringMid($sCaught, 2))
        setArg($aData, "Rare_Missed", StringMid($sMissed, 2))

        displayData($aData, $hLV_Stat, $aDataPre, $aDataPost)
        ;--------------------------------------------------------------------

        If _Sleep(500) Then ExitLoop

        Local $sLocation = isLocation($aLocations, False)
        If $sLocation <> "" And $sLocation <> "unknown" Then $hUnknownTimer = Null
        $aRound = getRound()
        If isArray($aRound) = True Then $iCurRound = $aRound[0]

        Switch $sLocation
            Case "catch-mode"
                If $iSkipRound <> $iCurRound Then 
                    ContinueCase
                EndIf
                addLog($g_aLog, "No more astromons found, skipping round.", $LOG_NORMAL)
                clickPoint(getArg($g_aPoints, "catch-mode-cancel"))
            Case "battle"
                If $bFinalRound = "Enabled" Then
                    If isArray($aRound) And ($aRound[0] <> $aRound[1]) Then
                        $iSkipRound = $iCurRound
                    EndIf
                EndIf

                If ($iSkipRound <> $iCurRound) Then
                    While ($iAstrochips > 0) And ($iCaught < $iCount)
                        If _Sleep(10) Then ExitLoop(2)
                        Local $t_hTimer = TimerInit()
                        If getLocation($g_aLocations, False) <> "catch-mode" Then
                            While isLocation("battle,battle-auto") = False 
                                If TimerDiff($t_hTimer) > 10000 Then ExitLoop(2)
                                If _Sleep(100) Then ExitLoop(3)
                            WEnd
                            If navigate("catch-mode", False, True) = False Then
                                $iAstrochips = 0
                                ExitLoop
                            EndIf
                        EndIf

                        Local $sResult = catch($aCapture, $iAstrochips, True)
                        If $sResult = -1 Then
                            addLog($g_aLog, "Astromon bag full.", $LOG_ERROR)
                            $g_sExtended = "Error"
                            ExitLoop(2)
                        EndIf
                        If $sResult <> "" Then
                            ;Found and catch status
                            If StringLeft($sResult, 1) <> "!" Then
                                ;Successfully caught
                                If $sResult = $sAstromon Then
                                    $iCaught += 1
                                    setArg($aData, "Astromon_Caught", $iCaught & "/" & $iCount)
                                Else
                                    setArg($aCaught, StringLeft($sResult, 2), Int(getArg($aCaught, StringLeft($sResult, 2))+1))
                                EndIf
                            Else
                                ;Not caught
                                If $sResult <> $sAstromon Then
                                    setArg($aMissed, StringLeft(StringMid($sResult, 2), 2), Int(getArg($aMissed, StringLeft(StringMid($sResult, 2), 2))+1))
                                EndIf
                            EndIf
                            displayData($aData, $hLV_Stat, $aDataPre, $aDataPost)
                        Else
                            ;Nothing found.
                            $iSkipRound = $iCurRound
                            clickPoint(getArg($g_aPoints, "catch-mode-cancel"))
                            ContinueLoop(2)
                        EndIf
                    WEnd

                    If ($iCaught >= $iCount) Then ExitLoop
                    If ($bFinishRound = "Disabled") And ($iAstrochips = 0) Then
                        addLog($g_aLog, "Surrendering and restarting.", $LOG_NORMAL)
                        If (FileExists($g_sAdbPath) = True) And (StringInStr(adbCommand("get-state"), "error") = False) Then
                            adbCommand("shell input keyevent ESCAPE")
                        Else
                            waitLocation("battle-auto,battle,battle-end-exp", 30)
                        EndIf

                        If navigate("battle-end", True, False) = True Then
                            Local $t_hTimer = TimerInit()
                            Do
                                If _Sleep(500) Then ExitLoop(2)
                                If TimerDiff($t_hTimer) > 30000 Then ExitLoop
                                clickPoint(getArg($g_aPoints, "play-again"), 1, 0, Null)
                            Until getLocation() = "map-battle" 

                            If getLocation($g_aLocations, False) = "map-battle" Then
                                If clickUntil(getArg($g_aPoints, "map-battle-play"), "isLocation", "battle-auto,battle,refill,unknown", 10, 200) = True Then
                                    $iRun += 1
                                    $iAstrochips = 3
                                    $iSkipRound = -1
                                EndIf
                            EndIf

                        EndIf
                    EndIf
                    
                EndIf
                clickUntil(getArg($g_aPoints, "battle-auto"), "isLocation", "battle-auto", 5, 1000)
            Case "battle-end"
                ;if the quests notification with red pixel shows up
                If ($bQuests = "Enabled") And (isPixel(getArg($g_aPixels, "battle-end-quest")) = True) Then collectQuest()

                ;Hourly will only be done in specific times. Refer to the function.
                If ($bHourly = "Enabled") Then doHourly()

                ;If still in battle-end location then clicks quick restarts. Usually if collectQuest or doHourly has been called then not in battle-end
                If getLocation() = "battle-end" Then 
                    $bBossSelected = False
                    If ($iCaught >= $iCount) Then ExitLoop
                    If clickUntil(getArg($g_aPoints, "quick-restart"), "isLocation", "unknown,battle-auto,battle,map-battle") Then 
                        If waitLocation("map-battle", 5) = True Then
                            ;Happens when coming from defeat
                            If clickUntil(getArg($g_aPoints, "map-battle-play"), "isLocation", "unknown,refill,battle,battle-auto", 5, 500) = True Then $iRun += 1
                        Else
                            $iRun += 1
                        EndIf
                    EndIf

                    $iAstrochips = 3
                    $iSkipRound = -1
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
                        $g_sExtended = "error"
                        ExitLoop
                    EndIf
                Else
                    addLog($g_aLog, "Gems used has exceeded max gems.", $LOG_NORMAL)
                    $g_sExtended = "gem-full"
                    ExitLoop
                EndIf
            Case "map"
                $bBossSelected = False
                If ($iCaught >= $iCount) Then ExitLoop

                ;Navigate to stage
                If enterStage($sMap, $sDifficulty, $sStage) = True Then
                    $iRun += 1
                    $iAstrochips = 3
                    $iCurEstimated = (TimerDiff($g_hScriptTimer)/$iCaught)*(($iCount+1)-$iCaught)
                    $hEstimated = TimerInit()

                    If waitLocation("battle,battle-auto", 45) = True Then
                        addLog($g_aLog, "In battle.")
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
            Case "battle-sell", "battle-end-exp", "battle-sell-item"
                clickUntil(getArg($g_aPoints, "tap"), "isLocation", "battle-end", 30, 200)
            Case "astromon-full"
                addLog($g_aLog, "Astromon bag is full.", $LOG_ERROR)
                navigate("village", True)
                $g_sExtended = "bag-full"
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
                If isArray($aRound) And ($bFinalRound = "Disabled") Then
                    If ($iAstrochips > 0) And ($iSkipRound <> $iCurRound) Then
                        waitLocation("unknown,battle-auto,battle", 3)
                        If navigate("catch-mode") = True Then ContinueLoop
                    EndIf
                Else
                    If isArray($aRound) And ($iSkipRound <> $iCurRound) And ($aRound[0] = $aRound[1]) Then
                        waitLocation("unknown,battle-auto,battle", 3)
                        If ($iAstrochips > 0)  And (navigate("catch-mode") = True) Then ContinueLoop
                    EndIf
                EndIf

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
    addLog($g_aLog, "Farm Astromon script has stopped.```")

    Return $aData
EndFunc