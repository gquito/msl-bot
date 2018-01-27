#include-once
#include "../../imports.au3"

#cs
	Function: Tries to enter battle from battle-end and or map-battle locations.
	Return: True if successful, false if something happened.
#ce
Func enterBattle()
	Log_Level_Add("enterBattle")
	Log_Add("Entering battle")

	Local $bOutput = False

	While True
		Local $sLocation = getLocation()
		Switch $sLocation
			Case "battle-end"
				If clickWhile(getArg($g_aPoints, "quick-restart"), "isLocation", "battle-end", 10, 100) = True Then
					Switch waitLocation("battle-auto,battle,refill,map-battle,map-gem-full,battle-gem-full,map-astromon-full,astromon-full,buy-gem", 120, False)
						Case "battle-auto", "battle"
						Case "map-battle"
							$bOutput = enterBattle()
							ExitLoop
						Case Else
							ExitLoop
					EndSwitch
				Else
					ExitLoop
				EndIf
			Case "map-battle"
				If clickWhile(getArg($g_aPoints, "map-battle-play"), "islocation", "map-battle", 10, 100) = True Then
					Switch waitLocation("loading,battle-auto,battle,refill,map-gem-full,battle-gem-full,map-astromon-full,astromon-full", 120, False)
						Case "battle", "battle-auto", "loading"
						Case Else
							ExitLoop
					EndSwitch
				EndIf
			Case Else
				ExitLoop
		EndSwitch

		$bOutput = True
		ExitLoop
	WEnd

	Log_Add("Entering battle result: " & $bOutput, $LOG_DEBUG)
	Log_Level_Remove()
	Return $bOutput
EndFunc