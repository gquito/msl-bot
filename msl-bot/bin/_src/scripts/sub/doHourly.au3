#include-once
#include "../../imports.au3"

Func doHourly()
	If navigate("village") = True Then
        If _Sleep(5000) Then Return False
		Local $iPos = -1; The village position

		;Tries to close some GUI in-game that blocks the hourly rewards.
		clickPoint("74,333", 2, 100, Null)
		clickPoint("744,72", 2, 100, Null)
        clickPoint("779,108", 2, 100, Null)

        navigate("village", False, False)
		$iPos = getVillagePos()
		If $iPos = -1 Then
			addLog($g_aLog, "Could not detect airship position.", $LOG_ERROR)
			Return False
		EndIf

	    navigate("village")

		addLog($g_aLog, "Collecting hourly trees.", $LOG_NORMAL)
		Local $aPoints = StringSplit($g_aVillageTrees[$iPos], "|", 2) ;format: {"#,#", "#,#"..}
		For $i = 0 To UBound($aPoints)-2 ;collecting the rewards
            addLog($g_aLog, "Collecting tree #" & $i+1, $LOG_NORMAL)

            Local $t_hTimer = TimerInit()
            While (getLocation() <> "hourly-reward") And (TimerDiff($t_hTimer) < 5000)
                If _Sleep(100) Then Return False
                clickPoint($aPoints[$i], 3, 100, Null)
                navigate("village", False, False)
            WEnd
            
            navigate("village", False, False)
		Next

        navigate("village", False, False)
        If _Sleep(10) Then Return False

        Local $aNezzLoc = getArg($g_aNezzPos, "village-pos" & $iPos)
        If $aNezzLoc <> -1 Then
            addLog($g_aLog, "Attempting to click nezz.", $LOG_NORMAL)
            For $aNezz In StringSplit($aNezzLoc, "|", $STR_NOCOUNT)
                clickPoint($aNezz, 2, 100, Null)
                navigate("village", False, False)
            Next
        EndIf
	EndIf

    $g_bPerformHourly = False
    addLog($g_aLog, "Finished collecting hourly.", $LOG_NORMAL)
	navigate("village")
	Return True
EndFunc