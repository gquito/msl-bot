#include-once
#include "../imports.au3"

Func Farm_Gem($iGemsToFarm, $sCatch, $sAstromon, $bFinishRound, $bFinalRound, $sMap, $sDifficulty, $sStage, $aCapture, $aGemGrade, $iGems, $sGuardianMode, $bBoss, $bQuests, $bHourly, $t_aData = Null, $aDataPre = Null, $aDataPost = Null)
    ;Variables
    Local $aFarmAstromonData = Null
    Local $iFarmedGems = 0 ;Number of gems farmed since script has started.
    Local $iUsedGems = 0 ;Number of gems used since script has started.
    Local $iNeedCatch = 0 ;Number of astromon to catch
    Local $iError = 0 ;Counts number of error occuring in evolving process before completely stopping script.

    If isArray($t_aData) = True Then
        Local $t_Var = Int(StringSplit(getArg($t_aData, "Refill"), "/", $STR_NOCOUNT)[0])
        If $t_Var <> "-1" Then $iUsedGems = $t_Var
    EndIf

    ; Main script loop
    Local $aData[1][2] = [["Gems_Farmed", "0/" & $iGemsToFarm]]

    addLog($g_aLog, "```Farm Gem script has started.")

    While $iFarmedGems < $iGemsToFarm
        If ($bHourly = "Enabled") And ($g_bPerformHourly = True) Then doHourly()

        If _Sleep(10) Then ExitLoop
        displayData($aData, $hLV_Stat, $aDataPre, $aDataPost)

        ;Handles catching process
        While $iNeedCatch > 0
            Local $t_aResults = Farm_Astromon($iNeedCatch, $sCatch, $bFinishRound, $bFinalRound, $sMap, $sDifficulty, $sStage, $aCapture, $aGemGrade, $iGems, $sGuardianMode, $bBoss, $bQuests, $bHourly, $aDataPost, $aData)
            $aDataPost = $t_aResults
            If _Sleep(10) Then ExitLoop(2)
            Switch $g_vExtended
                Case "bag-full"
                    $iNeedCatch = 0
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

        ;Handles evolving process
        $vResult = evolve($sAstromon, True)
        Switch $vResult
            Case -1, -2, -3, -4, -6 ;Normal errors.
                addLog($g_aLog, "Could not evolve, error code: " & $vResult, $LOG_ERROR)
                $iError += 1
                If $iError > 5 Then 
                    addLog($g_aLog, "Too many errors has occurred.", $LOG_ERROR)
                    Return -1
                EndIf
            Case -5 ;No currency.
                addLog($g_aLog, "Not enough gold to procceed.", $LOG_ERROR)
                Return -1
            Case Else ;Success
                If $vResult = 0 Then $iFarmedGems += 100
                $iNeedCatch = Int($vResult)
        EndSwitch

        setArg($aData, "Gems_Farmed", $iFarmedGems & "/" & $iGemsToFarm)
        displayData($aData, $hLV_Stat, $aDataPre, $aDataPost)
    WEnd
    addLog($g_aLog, "Farm Astromon script has stopped.```")

    Local $t_vExtended[1][2] = [["Refill", $iUsedGems]]
    $g_vExtended = $t_vExtended

    Return $aData
EndFunc