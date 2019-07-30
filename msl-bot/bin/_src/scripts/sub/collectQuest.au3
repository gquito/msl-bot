#include-once
#include "../../imports.au3"

Func collectQuest()
	Log_Level_Add("collectQuest")
	Log_Add("Collecting quests rewards.")
	Local $bOutput = False
	If (_Sleep(100)) Then 
		Log_Level_Remove()
		return $bOutput
	EndIf
	
	While True
		If (navigate("quests", False, 3)) Then
			;Locates quest notification indicating there is a quest available for collecting
			CaptureRegion()
			Local $aTab = findColor("747,116", "-600,1", 0xDA101B, 20, -1, 1) 

			Local $hTimer = TimerInit()
			While isArray($aTab)
				Stat_Increment($g_aStats, "Quest collected")
				If (TimerDiff($hTimer) > 30000) Then 
					Log_Add("Took too long to collect quests.", $LOG_ERROR)
					ExitLoop(2)
				EndIf

				clickPoint($aTab, 3, 50)
				If ($aTab[0] < 400) Then ;capture, challenges
					If(IsPixel(getPixelArg("quest-new"))) Then
						navigate("village")
						ExitLoop
					EndIf
					clickPoint("729,190")
				Else ;monthly, weekly, daily
					clickPoint("570,190")
					clickPoint("712,444") ;the top get reward
				EndIf

				If (_Sleep(500)) Then ExitLoop(2)

				If Not(isLocation("quests")) Then
					If (Not(closeWindow())) Then navigate("quests")
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