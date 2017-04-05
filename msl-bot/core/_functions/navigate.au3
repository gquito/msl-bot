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
			If _Sleep(50) Then Return
			Local $currLocation = getLocation()

			Switch $currLocation
				Case $strMainLocation, $strLocation
					ExitLoop
				Case "battle"
					If $forceGiveUp = False Then Return -1
					While waitLocation("pause", 1000) = 0
						ControlSend($hWindow, "", "", "{ESC}")
					WEnd

					clickPoint($battle_coorGiveUp)
					clickPoint($battle_coorGiveUpConfirm)
				Case "dialogue"
					clickPoint($game_coorDialogueSkip)
				Case "unknown"
					clickPoint($game_coorTap)

					Local $closePoint = findImage("misc-close", 30)
					If isArray($closePoint) Then
						clickPoint($closePoint) ;to close any windows open
					EndIf
				Case "battle-end-exp"
					clickUntil($game_coorTap, "battle-end", 100, 100)
			EndSwitch

			Switch $strMainLocation
				Case "village"
					Switch $currLocation
						Case "battle-end"
							clickPoint($battle_coorAirship)
						Case "map", "map-stage", "astroleague", "association", "clan"
							clickPoint($game_pixelBack)
						Case Else
							ControlSend($hWindow, "", "", "{ESC}")
					EndSwitch
				Case "map"
					Switch $currLocation
						Case "battle-end"
							clickPoint($battle_coorMap)
						Case "village"
							clickPoint($village_coorPlay)
						Case "astroleague", "map-stage", "map-battle", "association", "clan"
							clickPoint($game_pixelBack)
						Case "unknown"
							clickPoint($game_coorTap)

							Local $closePoint = findImage("misc-close", 30)
							If isArray($closePoint) Then
								clickPoint($closePoint) ;to close any windows open
							EndIf
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