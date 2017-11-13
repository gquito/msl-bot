#include-once
#include "../imports.au3"

Func Farm_Rare($iRuns, $sMap, $sDifficulty, $sStage, $aCapture, $aGemGrade, $iGems, $bBoss, $bQuests, $bHourly)
    Local Const $aLocations = ["battle", "battle-auto", "map-gem-full", "battle-gem-full", "catch-mode", "pause", "battle-end", "battle-end-exp", "battle-sell", "map", "refill", "defeat", "unknown", "battle-boss"]

    Local $iRun = 0 ;Current run

    ; Main script loop
    $g_hScriptTimer = TimerInit()
    addLog($g_aLog, "```Farm Rare script has started.")

    If isLocation($aLocations, False) = "" Then navigate("map")
    While ($iRuns = 0) Or ($iRun < $iRuns+1)
        If _Sleep(500) Then ExitLoop

        Local $sLocation = isLocation($aLocations, False)
        Switch $sLocation
        Case "map"
            enterStage($sMap, $sDifficulty, $sStage)
        EndSwitch
    WEnd
EndFunc