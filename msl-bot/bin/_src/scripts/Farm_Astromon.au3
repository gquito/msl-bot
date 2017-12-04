#include-once
#include "../imports.au3"

Func Farm_Astromon($iCount, $sAstromon, $bFinishRound, $bFinalRound, $sMap, $sDifficulty, $sStage, $aCapture, $aGemGrade, $iGems, $sGuardianMode, $bBoss, $bQuests, $bHourly, $t_aData = Null, $aDataPre = Null, $aDataPost = Null)
    Local Const $aLocations = ["loading", "battle", "battle-auto", "astromon-full", "map-gem-full", "battle-gem-full", "catch-mode", "pause", "battle-end", "battle-end-exp", "battle-sell", "map", "refill", "defeat", "unknown", "battle-boss"]
    
    ;Variables
    If $bFinalRound = "Enabled" Then $bFinishRound = "Enabled"

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
    Local $aRound = [0, 0] ;Rounds
    Local $iCurRound = 1 ;Current round
    Local $iSkipRound = -1 ;Skips if the round is this.
    $g_vExtended = "success"

    If isArray($t_aData) = True Then
        Local $t_Var = Int(StringSplit(getArg($t_aData, "Runs"), "/", $STR_NOCOUNT)[0])
        If $t_Var <> "-1" Then $iRun = $t_Var

        Local $t_Var = Int(StringSplit(getArg($t_aData, "Refill"), "/", $STR_NOCOUNT)[0])
        If $t_Var <> "-1" Then $iUsedGems = $t_Var
    
        Local $t_Var = formatArgs(StringStripWS(getArg($t_aData, "Rare_Caught"), $STR_STRIPALL), ";", ":")
        If $t_Var <> "-1" Then $aCaught = $t_Var

        Local $t_Var = formatArgs(StringStripWS(getArg($t_aData, "Rare_Missed"), $STR_STRIPALL), ";", ":")
        If $t_Var <> "-1" Then $aMissed = $t_Var
    EndIf

    ; Main script loop
    Local $aData[5][2] = [["Astromon_Caught", ""], ["Runs", ""], ["Refill", ""], ["Rare_Caught", ""], ["Rare_Missed", ""]]

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

        If _Sleep(100) Then ExitLoop

        Local $sLocation = isLocation($aLocations, False)
        $aRound = getRound()
        If isArray($aRound) = True Then $iCurRound = $aRound[0]

        Switch $sLocation
            Case "", "unknown"
            Case "battle-end", "map", "map-battle", "refill"
                $hUnknownTimer = Null
                $iAstrochips = 3
                $iSkipRound = -1
            Case Else
                $hUnknownTimer = Null
        EndSwitch

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
                            $g_vExtended = "Error"
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

                    If ($iCaught >= $iCount) Then ContinueCase ;Goes into exit case sequence 
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

                            If enterBattle() = True Then 
                                $iRun += 1
                                $iSkipRound = -1
                                $iAstrochips = 3
                                ContinueLoop
                            EndIf
                        EndIf
                    EndIf
                    
                EndIf
                clickUntil(getArg($g_aPoints, "battle-auto"), "isLocation", "battle-auto", 5, 1000)
            Case "EXIT SEQUENCE"
                If (FileExists($g_sAdbPath) = True) And (StringInStr(adbCommand("get-state"), "error") = False) Then
                    adbCommand("shell input keyevent ESCAPE")
                Else
                    waitLocation("battle-auto,battle,battle-end-exp", 30)
                EndIf

                navigate("battle-end", True, False)
                ExitLoop
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
                    If ($iCaught >= $iCount) Then ExitLoop
                    If enterBattle() = True Then $iRun += 1
                Else
                    navigate("map", False, False)
                EndIf
            Case "refill"
                ;Refill function handles starting the quickrestart and or the start battle from map-battle. Also handles the error messages
                If $iUsedGems+30 <= $iGems Then
                    If doRefill() = True Then
                        $iRun += 1
                        $iUsedGems+=30
                        addLog($g_aLog, "Refill " & $iUsedGems & "/" & $iGems, $LOG_NORMAL)
                    Else
                        $g_vExtended = "error"
                        ExitLoop
                    EndIf
                Else
                    addLog($g_aLog, "Gems used has exceeded max gems.", $LOG_NORMAL)
                    $g_vExtended = "gem-full"
                    ExitLoop
                EndIf
            Case "map"
                ;Guardian dungeon will be done at the start of the script and every 30 minutes
                If ($sGuardianMode <> "Disabled") And ($g_bPerformGuardian = True) Then
                    $aDataPost = Farm_Guardian($sGuardianMode, $iUsedGems-$iGems, False, True, $bQuests, $bHourly, $aDataPost, $aData)
                    $iUsedGems += Int(getArg($g_vExtended, "Refill"))
                EndIf

                $bBossSelected = False
                If ($iCaught >= $iCount) Then ExitLoop

                ;Navigate to stage
                If enterStage($sMap, $sDifficulty, $sStage) = True Then $iRun += 1
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
                $g_vExtended = "bag-full"
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
                        waitLocation("unknown,battle,battle-auto", 3)
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
                    clickPoint(getArg($g_aPoints, "tap"))
                    If getLocation() <> "unknown" Then ContinueLoop
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