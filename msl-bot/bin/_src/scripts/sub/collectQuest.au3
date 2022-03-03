#include-once

; Returns number of normal quest claimed.
; Extended set as 1 for slime quest limit.
Func collectQuest($iAttempt = 1)
	If $iAttempt <= 0 Then Return SetError(1, 0, 0)

	Log_Level_Add("collectQuest")
	Log_Add("Collecting quests rewards")
	Local $iOutput = 0
	Local $hTimer = TimerInit()
	Local $iExtended = 0 ; Handles evolving quest limit.

	$iAttempt -= 1
	While TimerDiff($hTimer) < 30000
		If _Sleep($Delay_Script_Loop) Then ExitLoop

		Local $sLocation = getLocation()
		Switch $sLocation
			Case "quests-limit"
				$iExtended = 1
				SendBack()
			Case "quests"
				CaptureRegion()
				Local $aTab = findColor("747,116", "-600,1", 0xDA101B, 20, -1, 1) 
				If isArray($aTab) = False Then ExitLoop

				clickPoint($aTab, 3)
				If ($aTab[0] < 400) Then ;capture, challenges
					If isPixel(getPixelArg("quest-new"), 10, CaptureRegion()) Then
						navigate("village")
						ContinueLoop
					EndIf
					clickPoint("729,190")

					$iOutput += 1
					Cumulative_AddNum("Collected (Quests)", 1)
				Else ;monthly, weekly, daily
					clickPoint("570,190")
					clickPoint("712,444") ;the top get reward
				EndIf
			Case Else
				closeWindow()
				If HandleCommonLocations($sLocation) = 0 And navigate("quests", False, 3) = 0 Then ExitLoop
		EndSwitch
	WEnd
	navigate("village")

	Log_Add("Collecting quest result: " & $iOutput, $LOG_DEBUG)
	Log_Level_Remove()

	If $iOutput = 0 And $iAttempt > 0 Then 
		Return SetExtended($iExtended, collectQuest($iAttempt-1))
	EndIf

	Return SetExtended($iExtended, $iOutput)
EndFunc