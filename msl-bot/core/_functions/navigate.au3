#cs ----------------------------------------------------------------------------

 Function: navigate

 Navigate through GUI in the game.

 Parameter:

	strMainLocation - Main location to navigate to sub location.

	strLocation - Sub location to navigate to

 Returns:

	On success - Returns 1

	On fail - Returns 0

	If in battle and ForceGiveUp = false then - Returns -1

 See Also:

	<getLocation>

#ce ----------------------------------------------------------------------------

Func navigate($strMainLocation, $strLocation = "", $forceGiveUp = False)
	Local $strCurrentLocation = getLocation()

	If $strLocation = $strCurrentLocation Then Return 1
	If $strCurrentLocation = $strMainLocation Then
		Switch $strLocation
			;village
			Case "manage"
				clickUntil($village_coorMonsters, "monsters")
				clickUntil($village_coorManage, "manage")
			Case "quests"
				clickUntil($village_coorQuests, "quests")
			;map
			Case "guardian-dungeons"
				clickUntil(findImage("map-dungeons", 50), "starstone-dungeons")
				clickUntil($map_coorGuardianDungeons, "guardian-dungeons")
			Case "golem-dungeons"
				clickUntil(findImage("map-dungeons", 50), "starstone-dungeons")
				clickUntil($map_coorGolemDungeons, "golem-dungeons")
			;battle
			Case "catch-mode"
				If checkPixel($battle_pixelUnavailable) = True Then Return 0
				clickUntil($battle_pixelUnavailable, "catch-mode", 100, 100)
			Case ""
				Return 1
			Case Else
				MsgBox(0, $botName & " " & $botVersion, "Unknown location.")
		EndSwitch

		Return waitLocation($strLocation)
	Else
		While True
			If _Sleep(2000) Then Return
			Local $currLocation = getLocation()

			Switch $currLocation
				Case $strMainLocation, $strLocation
					ExitLoop
				Case "battle", "battle-auto"
					If $forceGiveUp = False Then Return -1
					clickUntil($battle_coorPause, "pause")

					clickPoint($battle_coorGiveUp)
					clickPoint($battle_coorGiveUpConfirm)
				Case "dialogue"
					clickPoint($game_coorDialogueSkip)
				Case "unknown"
					clickPoint($game_coorTap)
					clickPoint(findImage("misc-close", 30)) ;to close any windows open
				Case "battle-end-exp"
					clickUntil($game_coorTap, "battle-end", 100, 100)
			EndSwitch

			Switch $strMainLocation
				Case "village"
					Switch $currLocation
						Case "battle-end"
							clickUntil($battle_coorAirship, "unknown")
							waitLocation("map", 10000)
						Case "unknown", "inbox", "monsters", "manage", "shop", "map", "astroleague", "map-stage", "clan", "association", "starstone-dungeons", "map-battle"
							clickPoint($game_pixelBack)
							clickPoint(findImage("misc-close", 30), 5) ;to close any windows open
						Case Else
							ControlSend($hWindow, "", "", "{ESC}")
					EndSwitch
					waitLocation("village", 3000)
				Case "map"
					Switch $currLocation
						Case "battle-end"
							clickUntil($battle_coorMap, "unknown")
							waitLocation("map", 10000)
						Case "village"
							clickUntil($village_coorPlay, "unknown")
							clickPoint(findImage("misc-close", 30)) ;to close any windows open
							waitLocation("map", 10000)
						Case "astroleague", "map-battle", "association", "clan"
							clickPoint($game_pixelBack)
							waitLocation("map", 2000)
						Case "map-stage"
							clickPoint(findImage("misc-close", 30)) ;to close any windows open
							waitLocation("map", 2000)
						Case "unknown"
							clickPoint($game_pixelBack)
							clickPoint(findImage("misc-close", 30)) ;to close any windows open
						Case Else
							ControlSend($hWindow, "", "", "{ESC}")
					EndSwitch
				Case "battle"
					Return waitLocation("battle", 8000)
				Case Else
					setLog("Unknown main location: " & $strMainLocation & ".")
			EndSwitch
		WEnd
		navigate($strMainLocation, $strLocation)
	EndIf

	If $strLocation = "" And $strMainLocation = getLocation() Then Return 1
	If $strLocation = getLocation() Then Return 1
EndFunc