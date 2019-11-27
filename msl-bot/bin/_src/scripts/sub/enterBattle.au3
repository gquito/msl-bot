#include-once

Func enterBattle()
	Local $t_bScheduleBusy = $g_bScheduleBusy
	$g_bScheduleBusy = True

	Log_Level_Add("enterBattle")
	
	Local $bOutput = False
	Local $hTimer = TimerInit()
	While TimerDiff($hTimer) < 60000
		If _Sleep(300) Then ExitLoop
		Local $sLocation = getLocation()
		Switch $sLocation
			Case "map-battle"
				clickPoint(getPointArg("map-battle-play"))
				waitLocation("loading,unknown,refill", 5)
			Case "battle-end"
				Local $aRestart = findImage("misc-restart")
				If isArray($aRestart) = True Then 
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