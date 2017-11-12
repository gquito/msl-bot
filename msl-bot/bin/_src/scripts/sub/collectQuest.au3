#include-once
#include "../../imports.au3"

Func collectQuest()
	addLog($g_aLog, "Collecting quests.", $LOG_NORMAL)
    addLog($g_aLog, "-Navigating to 'quests.'")
	If navigate("quests", False, False) = True Then
        ;Locates quest notification indicating there is a quest available for collecting
		Local $aTab = findColor("747,116", "-600,1", 0xDA101B, 20, -1, 1) 

        Local $hTimer = TimerInit()
		While isArray($aTab)
            If TimerDiff($hTimer) > 120000 Then ;2 minutes
                addLog($g_aLog, "Took too long to collect quests.", $LOG_ERROR)
                Return False
            EndIf

			clickPoint($aTab, 3, 100)
			If $aTab[0] < 400 Then ;capture, challenges
				clickPoint("729,190")
			Else ;monthly, weekly, daily
				clickPoint("717,247")
				clickPoint("731,194") ;the top get reward
			EndIf

			If _Sleep(500) Then Return -1

			If Not(getLocation() = "quests") Then
				navigate("quests", False)
			EndIf

			CaptureRegion()
			$aTab = findColor("747,116", "-600,1", 0xDA101B, 20, -1, 1) 
		WEnd
	Else
		addLog($g_aLog, "Failed to navigate to 'quests.'", $LOG_ERROR)
		Return False
	EndIf
    
	navigate("village")

    addLog($g_aLog, "Finished collecting quests.", $LOG_NORMAL)
	Return True
EndFunc