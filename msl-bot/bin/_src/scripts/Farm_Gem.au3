#include-once
#include "../imports.au3"

Func Farm_Gem($iGemsToFarm, $sAstromon, $bFinishRound, $bFinalRound, $sMap, $sDifficulty, $sStage, $aCapture, $aGemGrade, $iGems, $sGuardianMode, $bBoss, $bQuests, $bHourly, $t_aData = Null, $aDataPre = Null, $aDataPost = Null)
    ;Variables
    Local $aFarmAstromonData = Null
    Local $iFarmedGems = 0 ;Number of gems farmed since script has started.
    Local $iUsedGems = 0 ;Number of gems used since script has started.
    Local $iNeedCatch = 16 ;Number of astromon to catch
    Local $iNeedEvo2 = 4 ;Number of evo2 needed for an evo3

    If isArray($t_aData) = True Then
        Local $t_Var = Int(StringSplit(getArg($t_aData, "Refill"), "/", $STR_NOCOUNT)[0])
        If $t_Var <> "-1" Then $iUsedGems = $t_Var
    EndIf

    ; Main script loop
    Local $aData[1][2] = [["Gems_Farmed", "0/" & $iGemsToFarm]]

    addLog($g_aLog, "```Farm Gem script has started.")

    While $iFarmedGems < $iGemsToFarm
        If ($bHourly = "Enabled") And ($g_bPerformHourly = True) Then doHourly()

        If _Sleep(10) Then ExitLoop(2)
        displayData($aData, $hLV_Stat, $aDataPre, $aDataPost)

        While $iNeedCatch > 0
            Local $t_aResults = Farm_Astromon($iNeedCatch, $sAstromon, $bFinishRound, $bFinalRound, $sMap, $sDifficulty, $sStage, $aCapture, $aGemGrade, $iGems-$iUsedGems, $sGuardianMode, $bBoss, $bQuests, $bHourly, $aDataPost, $aData)
            $aDataPost = $t_aResults
            If _Sleep(10) Then ExitLoop(2)
            Switch $g_vExtended
                Case "bag-full"
                    addLog($g_aLog, "Cannot continue to farm astromons because astromon bag became full.", $LOG_ERROR)
                    ExitLoop(2)
                Case "gem-full"
                    addLog($g_aLog, "Cannot continue to farm astromons because gem box is full.", $LOG_ERROR)
                    ExitLoop(2)
                Case "error"
                    addLog($g_aLog, "Something went wrong with farming astromons.", $LOG_ERROR)
                    ExitLoop(2)
            EndSwitch

            $iNeedCatch -= Int(getArg($t_aResults, "Astromon_Caught"))
            $iUsedGems += Int(StringSplit(getArg($t_aResults, "Refill"), "/", $STR_NOCOUNT)[0])

            setArg($aData, "Gems_Farmed", $iFarmedGems & "/" & $iGemsToFarm)
            displayData($aData, $hLV_Stat, $aDataPre, $aDataPost)
        WEnd

        Local $t_iCount = 0
        While navigate("monsters", True) = False
            If _Sleep(10) Then ExitLoop(2)
            $t_iCount += 1
            If $t_iCount > 5 Then 
                addLog($g_aLog, "Could not navigate to monsters.", $LOG_ERROR)
                ExitLoop(2)
            EndIf
        WEnd

        While $iNeedEvo2 > 0
            If _Sleep(10) Then ExitLoop(2)
            addLog($g_aLog, "Evolving slime x" & 5-$iNeedEvo2 & ".", $LOG_NORMAL)

            Local $aSlime = findImage("evolve-" & StringLower($sAstromon), 100, 0, 12, 105, 280, 340)
            If isArray($aSlime = False) Then
                addLog($g_aLog, "Could not detect an astromon.", $LOG_ERROR)
                ExitLoop(2)
            EndIf

            clickPoint($aSlime, 5, 100, Null) ;Clicks slime
            If clickUntil("604,392", "isLocation", "monsters-evolution", 10, 200, Null) = True Then ;Click Evolve
                If _Sleep(10) Then ExitLoop(2)
                If isPixel("585,182,0x7D624D", 20) = True Then ;The third empty slot pixel
                    Local $t_hTimer = TimerInit()
                    For $x = 0 To 6
                        If TimerDiff($t_hTimer) > 60000 Then
                            addLog($g_aLog, "Something went wrong with the awakening process.", $LOG_ERROR)
                            ExitLoop(2)
                        EndIf
                        ;click the astromons
                        If getLocation() = "monsters-evolution" Then
                            If isPixel("585,182,0x7D624D", 10) = False Then ExitLoop
                            closeWindow()

                            clickPoint(351+($x*65) & ",330", 1, 0, Null)
                        EndIf

                        If getLocation() <> "monsters-evolution" Then 
                            clickPoint("542, 313", 1, 0, Null) ;Clicks cancel
                            $x -= 1
                        EndIf
                    Next
                    If _Sleep(10) Then ExitLoop(2)

                    CaptureRegion()
                    If isPixel("585,182,0x7D624D", 10) = True Then
                        ;Incomplete slime.
                        addLog($g_aLog, "Not enough slimes. Farming 4 new slimes.", $LOG_NORMAL)

                        $iNeedCatch += 4
                        ContinueLoop(2)
                    EndIf
                EndIf

                If _Sleep(10) Then ExitLoop(2)
                ;Awakening/evolving
                Local $t_hTimer = TimerInit()
                While getLocation() = "monsters-evolution"
                    If TimerDiff($t_hTimer) > 60000 Then
                        addLog($g_aLog, "Something went wrong with the evolving process.", $LOG_ERROR)
                        ExitLoop(2)
                    EndIf
                    If _Sleep(10) Then ExitLoop(2)
                    If isPixel("425,394,0xF5E448", 10) = True Then ;The awaken pixel
                        If clickUntil("425,395", "isLocation", "monsters-awaken", 10, 100) = True Then
                            clickPoint("303,312", 10, 200) ;awaken/evolve confirm
                        EndIf
                    Else
                        If isPixel("657,395,0xEBC83D", 10) = True Then
                            If clickUntil("656,394", "isLocation", "monsters-evolve", 10, 100) = True Then
                                If clickUntil("303,312", "isLocation", "unknown", 10, 200) Then ;awaken/evolve confirm
                                    clickUntil(getArg($g_aPoints, "tap"), "isLocation", "monsters-astromon", 10, 500)
                                EndIf 
                            EndIf
                        EndIf
                    EndIf
                WEnd
                $iNeedEvo2 -=1
                If $iNeedEvo2 <> 0 Then
                    If _Sleep(10) Then ExitLoop(2)
                    collectQuest()
                    Local $t_iCount = 0
                    While navigate("monsters", True) = False
                        If _Sleep(10) Then ExitLoop(2)
                        $t_iCount += 1
                        If $t_iCount > 5 Then 
                            addLog($g_aLog, "Could not navigate to monsters.", $LOG_ERROR)
                            ExitLoop(2)
                        EndIf
                    WEnd
                Else
                    closeWindow()
                EndIf
            EndIf
        WEnd

        If _Sleep(10) Then ExitLoop(2)
        addLog($g_aLog, "Evolving to evo3.", $LOG_NORMAL)
        Local $aSlime = findImage("evolve-" & StringLower($sAstromon) & "x", 100, 0, 12, 105, 280, 340)
        clickPoint($aSlime, 10, 100, Null) ;Clicks slime
        If clickUntil("604,392", "isLocation", "monsters-evolution", 10, 200, Null) = True Then ;Click Evolve
            If isPixel("585,182,0x7D624D", 20) = True Then ;The third empty slot pixel
                Local $t_hTimer = TimerInit()
                For $x = 0 To 6
                    If TimerDiff($t_hTimer) > 60000 Then
                        addLog($g_aLog, "Something went wrong with the awakening process.", $LOG_ERROR)
                        ExitLoop(2)
                    EndIf
                    ;click the astromons
                    If getLocation() = "monsters-evolution" Then
                        clickPoint(351+($x*65) & ",330", 1, 0, Null)
                        CaptureRegion()
                        If isPixel("585,182,0x7D624D", 10) = False Then ExitLoop

                        closeWindow()
                    Else 
                        clickPoint("494,312", 1, 0, Null)
                    EndIf
                Next

                CaptureRegion()
                If isPixel("585,182,0x7D624D", 10) = True Then
                    ;Incomplete slime.
                    addLog($g_aLog, "Not enough slimes. Farming 4 new slimes.", $LOG_NORMAL)
                    $iNeedCatch += 4
                    $iNeedEvo2 += 1
                    
                    ContinueLoop
                EndIf
            EndIf

            Local $t_hTimer = TimerInit()
            While getLocation() = "monsters-evolution"
                If TimerDiff($t_hTimer) > 60000 Then
                    addLog($g_aLog, "Something went wrong with the evolving process.", $LOG_ERROR)
                    ExitLoop(2)
                EndIf
                If isPixel("425,394,0xF5E448", 10) = True Then ;The awaken pixel
                    If clickUntil("425,395", "isLocation", "monsters-awaken", 10, 100) = True Then
                        clickPoint("303,312", 10, 200) ;awaken/evolve confirm
                    EndIf
                Else
                    If isPixel("657,395,0xEBC83D", 10) = True Then
                        If clickUntil("656,394", "isLocation", "monsters-evolve", 10, 100) = True Then
                            If clickUntil("303,312", "isLocation", "unknown", 10, 200) Then ;awaken/evolve confirm
                                clickUntil(getArg($g_aPoints, "tap"), "isLocation", "monsters-astromon", 10, 500)
                            EndIf 
                        EndIf
                    EndIf
                EndIf
            WEnd

            closeWindow()
            addLog($g_aLog, "Successfully evolved to evo3.", $LOG_NORMAL)
            CaptureRegion()
            
            addLog($g_aLog, "Cleaning up.", $LOG_NORMAL)

            clickPoint("51,152", 3, 100) ;Clicks king slime
            clickUntil("776,110", "isLocation", "monsters", 5, 100)
            If clickWhile("648, 459", "isLocation", "monsters,monsters-evolution", 10, 100) = True Then
                clickPoint("311, 331", 20, 200)
            EndIf
            
            $iFarmedGems += 100
            $iNeedCatch = 16
            $iNeedEvo2 = 4

            setArg($aData, "Gems_Farmed", $iFarmedGems & "/" & $iGemsToFarm)
            displayData($aData, $hLV_Stat, $aDataPre, $aDataPost)
        EndIf
        collectQuest()
    WEnd
    addLog($g_aLog, "Farm Astromon script has stopped.```")

    Local $t_vExtended[1][2] = [["Refill", $iUsedGems]]
    $g_vExtended = $t_vExtended

    Return $aData
EndFunc