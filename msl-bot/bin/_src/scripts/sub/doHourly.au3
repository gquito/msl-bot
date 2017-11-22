#include-once
#include "../../imports.au3"

Func doHourly()
	If navigate("village") = True Then
        If _Sleep(5000) Then Return False
		Local $iPos = -1; The village position

		;Tries to close some GUI in-game that blocks the hourly rewards.
		clickPoint("74,333", 2, 100)
		clickPoint("744,72", 2, 100)
        clickPoint("779,108", 2, 100)

        navigate("village", False, False)
		$iPos = getVillagePos()
		If $iPos = -1 Then
			addLog($g_aLog, "Could not detect airship position.", $LOG_ERROR)
			Return False
		EndIf

		Local $aPoints = getArg($g_aNezzPos, "village-pos" & $iPos)
        If $aPoints <> -1 Then
            addLog($g_aLog, "Attempting to click nezz.", $LOG_NORMAL)
            For $aPoint In StringSplit($aPoints, "|", $STR_NOCOUNT)
                clickPoint($aPoint, 2, 100)
                navigate("village", False, False)
            Next
        EndIf
        If _Sleep(10) Then Return False

	    navigate("village")

		addLog($g_aLog, "Collecting hourly trees.", $LOG_NORMAL)
		Local $aPoints = StringSplit($g_aVillageTrees[$iPos], "|", 2) ;format: {"#,#", "#,#"..}
		For $i = 0 To UBound($aPoints)-2 ;collecting the rewards
            addLog($g_aLog, "Collecting tree #" & $i+1, $LOG_NORMAL)

            Local $t_hTimer = TimerInit()
            While (getLocation() <> "hourly-reward") And (TimerDiff($t_hTimer) < 5000)
                If _Sleep(100) Then Return False
                clickPoint($aPoints[$i], 3, 100)
                navigate("village", False, False)
            WEnd
            
            navigate("village", False, False)
		Next
	EndIf

    $g_bPerformHourly = False
    addLog($g_aLog, "Finished collecting hourly.", $LOG_NORMAL)
	navigate("village")
	Return True
EndFunc