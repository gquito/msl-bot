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

        Switch evolve($sAstromon, $iNeedEvo2)
            Case "not-enough-astromon"
                $iNeedCatch += 4
            Case "not-enough-astromon-evo2"
                $iNeedEvo2 += 1
                $iNeedCatch += 4
            Case "success"
                $iFarmedGems += 100
                $iNeedCatch = 16
                $iNeedEvo2 = 4
            Case Else
                ExitLoop
        EndSwitch
        $iNeedEvo2 = $g_vExtended

        setArg($aData, "Gems_Farmed", $iFarmedGems & "/" & $iGemsToFarm)
        displayData($aData, $hLV_Stat, $aDataPre, $aDataPost)
    WEnd
    addLog($g_aLog, "Farm Astromon script has stopped.```")

    Local $t_vExtended[1][2] = [["Refill", $iUsedGems]]
    $g_vExtended = $t_vExtended

    Return $aData
EndFunc

Func evolve($sAstromon, $iNeedEvo2 = 4)
    $g_vExtended = $iNeedEvo2

    Local $t_iCount = 0
    While navigate("monsters", True) = False
        If _Sleep(10) Then Return False
        $t_iCount += 1
        If $t_iCount > 5 Then 
            addLog($g_aLog, "Could not navigate to monsters.", $LOG_ERROR)
            Return False
        EndIf
    WEnd

    While $iNeedEvo2 > 0
        If _Sleep(10) Then Return False
        addLog($g_aLog, "Evolving astromon x" & 5-$iNeedEvo2 & ".", $LOG_NORMAL)

        Local $aAstromon = findImage("evolve-" & StringLower($sAstromon), 100, 0, 12, 105, 280, 340)
        If isArray($aAstromon = False) Then
            addLog($g_aLog, "Could not detect an astromon.", $LOG_ERROR)
            Return False
        EndIf

        clickPoint($aAstromon, 5, 100, Null) ;Clicks astromon
        If clickUntil("604,392", "isLocation", "monsters-evolution", 10, 200, Null) = True Then ;Click Evolve
            If _Sleep(10) Then Return False
            If isPixel("585,182,0x7D624D", 20) = True Then ;The third empty slot pixel
                Local $t_hTimer = TimerInit()
                For $x = 0 To 6
                    If TimerDiff($t_hTimer) > 60000 Then
                        addLog($g_aLog, "Something went wrong with the awakening process.", $LOG_ERROR)
                        Return False
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
                If _Sleep(10) Then Return False

                CaptureRegion()
                If isPixel("585,182,0x7D624D", 10) = True Then
                    ;Incomplete astromon.
                    addLog($g_aLog, "Not enough astromons.", $LOG_NORMAL)
                    Return "not-enough-astromon"
                EndIf
            EndIf

            If _Sleep(10) Then Return False
            ;Awakening/evolving
            Local $t_hTimer = TimerInit()
            While getLocation() = "monsters-evolution"
                If TimerDiff($t_hTimer) > 60000 Then
                    addLog($g_aLog, "Something went wrong with the evolving process.", $LOG_ERROR)
                    Return False
                EndIf
                If _Sleep(10) Then Return False
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
            $g_vExtended = $iNeedEvo2
            If $iNeedEvo2 <> 0 Then
                If _Sleep(10) Then Return False
                collectQuest()
                Local $t_iCount = 0
                While navigate("monsters", True) = False
                    If _Sleep(10) Then Return False
                    $t_iCount += 1
                    If $t_iCount > 5 Then 
                        addLog($g_aLog, "Could not navigate to monsters.", $LOG_ERROR)
                        Return False
                    EndIf
                WEnd
            Else
                Local $t_hTimer = TimerInit()
                While (getLocation() <> "monsters")
                    If _Sleep(10) Then Return False
                    If TimerDiff($t_hTimer) > 5000 Then ExitLoop
                    closeWindow()
                    clickPoint("773,113", 1, 0, Null)
                WEnd
            EndIf
        EndIf
    WEnd

    If _Sleep(10) Then Return False
    addLog($g_aLog, "Evolving to evo3.", $LOG_NORMAL)
    Local $aAstromon = findImage("evolve-" & StringLower($sAstromon) & "x", 100, 0, 12, 105, 280, 340)
    clickPoint($aAstromon, 10, 100, Null) ;Clicks astromon
    If clickUntil("604,392", "isLocation", "monsters-evolution", 10, 200, Null) = True Then ;Click Evolve
        If isPixel("585,182,0x7D624D", 20) = True Then ;The third empty slot pixel
            Local $t_hTimer = TimerInit()
            For $x = 0 To 6
                If TimerDiff($t_hTimer) > 60000 Then
                    addLog($g_aLog, "Something went wrong with the awakening process.", $LOG_ERROR)
                    Return False
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
                ;Incomplete astromon.
                addLog($g_aLog, "Not enough astromons. Farming 4 new astromons.", $LOG_NORMAL)
                Return "not-enough-astromon-evo2"
            EndIf
        EndIf

        Local $t_hTimer = TimerInit()
        While getLocation() = "monsters-evolution"
            If TimerDiff($t_hTimer) > 60000 Then
                addLog($g_aLog, "Something went wrong with the evolving process.", $LOG_ERROR)
                Return False
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

        clickPoint("51,152", 3, 100) ;Clicks evo3 astromon
        clickUntil("776,110", "isLocation", "monsters", 5, 100)
        If clickWhile("649, 513", "isLocation", "monsters,monsters-evolution", 10, 100) = True Then
            clickPoint("311, 331", 20, 200)
        EndIf
        
        Return "success"
    EndIf
    collectQuest()
EndFunc