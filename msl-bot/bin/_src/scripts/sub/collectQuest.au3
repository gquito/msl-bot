#include-once

Func collectQuest($iAttempt = 1)
	Log_Level_Add("collectQuest")
	Log_Add("Collecting quests rewards")
	Local $bOutput = False
	Local $hTimer = TimerInit()
	While TimerDiff($hTimer) < 30000
		If _Sleep(500) Then ExitLoop
		Local $sLocation = getLocation()
		Switch $sLocation
			Case "quests"
				CaptureRegion()
				Local $aTab = findColor("747,116", "-600,1", 0xDA101B, 20, -1, 1) 
				If isArray($aTab) = False Then
					$bOutput = True
					ExitLoop
				EndIf

				clickPoint($aTab, 3)
				If ($aTab[0] < 400) Then ;capture, challenges
					If isPixel(getPixelArg("quest-new"), 10, CaptureRegion()) Then
						navigate("village")
						ContinueLoop
					EndIf
					clickPoint("729,190")
				Else ;monthly, weekly, daily
					clickPoint("570,190")
					clickPoint("712,444") ;the top get reward
				EndIf
			Case Else
				If HandleCommonLocations($sLocation) = False And navigate("quests", False, 3) = False Then ExitLoop
		EndSwitch
	WEnd
	navigate("village")

	Log_Add("Collecting quest result: " & $bOutput, $LOG_DEBUG)
	Log_Level_Remove()
	If $iAttempt > 1 And $bOutput = False Then collectQuest($iAttempt-1)
	Return $bOutput 
EndFunc