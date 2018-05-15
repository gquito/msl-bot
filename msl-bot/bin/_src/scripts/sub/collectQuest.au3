#include-once
#include "../../imports.au3"

Func collectQuest()
	Log_Level_Add("collectQuest")
	Log_Add("Collecting quests rewards.")
	Local $bOutput = False

	While True
		If navigate("quests", False, 3) = True Then
			;Locates quest notification indicating there is a quest available for collecting
			CaptureRegion()
			Local $aTab = findColor("747,116", "-600,1", 0xDA101B, 20, -1, 1) 

			Local $hTimer = TimerInit()
			While isArray($aTab)
				If TimerDiff($hTimer) > 30000 Then 
					Log_Add("Took too long to collect quests.", $LOG_ERROR)
					ExitLoop(2)
				EndIf

				clickPoint($aTab, 3, 50)
				If $aTab[0] < 400 Then ;capture, challenges
					clickPoint("729,190")
				Else ;monthly, weekly, daily
					clickPoint("570,190")
					clickPoint("712,444") ;the top get reward
				EndIf

				If _Sleep(500) Then ExitLoop(2)

				If Not(getLocation() = "quests") Then
					If closeWindow() = False Then
						navigate("quests")
					EndIf
				EndIf

				CaptureRegion()
				$aTab = findColor("747,116", "-600,1", 0xDA101B, 20, -1, 1) 
			WEnd
		Else
			Log_Add("Could not navigate to quest location.", $LOG_ERROR)
			ExitLoop
		EndIf

		$bOutput = True
		ExitLoop
	WEnd
	navigate("village")

	Log_Add("Collecting quest result: " & $bOutput, $LOG_DEBUG)
	Log_Level_Remove()
	Return $bOutput 
EndFunc