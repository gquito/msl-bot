#include-once

Func enterBattle()
	Local $t_bScheduleBusy = $g_bScheduleBusy
	$g_bScheduleBusy = True

	Log_Level_Add("enterBattle")
	
	Local $bOutput = False
	Local $hTimer = TimerInit()
	While TimerDiff($hTimer) < 60000
		If _Sleep($Delay_Script_Loop) Then ExitLoop
		Local $sLocation = getLocation()
		Switch $sLocation
			Case "map-battle"
				clickPoint(getPointArg("map-battle-play"))
				waitLocation("loading,unknown,refill", 5)
			Case "battle-end"
				If $General_Collect_Quests = True And isPixel(getPixelArg("battle-end-quest"), 10) Then
					If $General_Collect_Quests == "Only On Capture" Then
						If $g_bCaptureQuest = True Then
							$g_bCaptureQuest = False
							
							Log_Add("Capture and quest detected, collecting quests.", $LOG_INFORMATION)
							collectQuest()
							ExitLoop
						EndIf
					Else
						Log_Add("Completed quests detected, collecting quests.", $LOG_INFORMATION)
						collectQuest()
						ExitLoop
					EndIf
				EndIf

				If TimerDiff($hTimer) > 15000 Then
					clickPoint("99,261")
					If _Sleep(500) Then ExitLoop
					ADB_SendESC(2)
				EndIf

				CaptureRegion()
				Local $aRestart = findImage("misc-restart")
				If isArray($aRestart) > 0 Then 
					clickPoint($aRestart, 3)
					waitLocation("loading,unknown,refill", 5)
				EndIf
			Case "unknown", "loading"
			Case "battle", "battle-auto"
				$bOutput = True
				ExitLoop
			Case Else
				ExitLoop
		EndSwitch
	WEnd

	Log_Add("Entering battle result: " & $bOutput & ". Location: " & getLocation(), $LOG_DEBUG)
	Log_Level_Remove()

	$g_bScheduleBusy = $t_bScheduleBusy
	Return $bOutput
EndFunc