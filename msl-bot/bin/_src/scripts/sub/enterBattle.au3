#include-once
#include "../../imports.au3"

#cs
	Function: Tries to enter battle from battle-end and or map-battle locations.
	Return: True if successful, false if something happened.
#ce
Func enterBattle($iRound = 0)
	Local $bOutput = False
	Log_Level_Add("enterBattle")
	Log_Add("Entering battle")
	
	Local $sLocation = getLocation()
	Switch $sLocation
		Case "battle-end"
			Local $battleEndClickPoint = getPointArg("quick-restart")
			If ($iRound = 4) Then $battleEndClickPoint = getPointArg("play-again")
			If (clickWhile($battleEndClickPoint, "isLocation", "battle-end", 10, 1000)) Then
				Switch waitLocation("battle-auto,battle,refill,map-battle,map-gem-full,battle-gem-full,map-astromon-full,astromon-full,buy-gem,gold-dungeons,guardian-dungeons,special-guardian-dungeons,toc-mon-info,autobattle-prompt,dragon-sigils-empty,dragon-astral-essence,buy-gold", 120, 200, False)
					Case "battle-auto", "battle"
						$bOutput = True
					Case "map-battle"
						$bOutput = enterBattle()
					Case "toc-mon-info", "autobattle-prompt", "popup-window"
						closeWindow()
						$bOutput = enterBattle()
				EndSwitch
			EndIf
		Case "map-battle"
			If (clickWhile(getPointArg("map-battle-play"), "islocation", "map-battle,unknown", 10, 1000)) Then
				Switch waitLocation("astroleague-refill,map-battle-autofill,loading,battle-auto,battle,refill,map-gem-full,battle-gem-full,map-astromon-full,astromon-full,buy-gem,toc-mon-info,no-astrochips-proceed,autobattle-prompt,dragon-sigils-empty,buy-gold", 120, 200, False)
					Case "battle", "battle-auto", "loading"
						$bOutput = True
					Case "toc-mon-info", "autobattle-prompt", "popup-window"
						closeWindow()
						$bOutput = enterBattle()
					Case "no-astrochips-proceed"
						If (clickUntil(getPointArg("no-astrochips-refill"),"isLocation","refill-astrochips-popup", 10, 500)) Then $bOutput = enterBattle()
					Case "map-battle-autofill"
						If clickUntil(getPointArg("map-battle-autofill"), "isLocation", "map-battle", 10, 500) Then
							$bOutput = enterBattle()
						EndIf
				EndSwitch
			EndIf
		Case "refill-astrochips-popup"
			If (clickUntil(getPointArg("astrochips-popup-refill"), "isLocation", "map-battle", 10, 500)) Then $bOutput = enterBattle()
		Case "no-astrochips-proceed"
			If (clickUntil(getPointArg("no-astrochips-refill"),"isLocation","refill-astrochips-popup", 10, 500)) Then $bOutput = enterBattle()
		Case "autobattle-prompt", "popup-window"
			closeWindow()
			$bOutput = enterBattle()
	EndSwitch

	Log_Add("Entering battle result: " & $bOutput & ". Location: " & getLocation(), $LOG_DEBUG)
	Log_Level_Remove()
	Return $bOutput
EndFunc