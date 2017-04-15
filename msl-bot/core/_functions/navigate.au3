#cs ----------------------------------------------------------------------------
 Function: navigate
 Navigate through GUI in the game.

 Parameter:
	strMainLocation - Main location to navigate to sub location.
	strLocation - Sub location to navigate to

 Returns: (boolean) If success return True, if fail return False
#ce ----------------------------------------------------------------------------

Func navigate($strMainLocation, $strLocation = "", $forceGiveUp = False)
	Local $strCurrentLocation = getLocation()

	If $strCurrentLocation = "battle-auto" Then $strCurrentLocation = "battle"

	If $strLocation = $strCurrentLocation Then Return True
	If $strCurrentLocation = $strMainLocation Then
		Switch $strLocation
			;village
			Case "shop"
				If isArray(findImage("misc-village-pos1", 50)) Then
					clickUntil(StringSplit($village_coorHourly[0], "|", 2)[3], "shop")
				ElseIf isArray(findImage("misc-village-pos2", 50)) Then
					clickUntil(StringSplit($village_coorHourly[1], "|", 2)[3], "shop")
				ElseIf isArray(findImage("misc-village-pos3", 50)) Then
					clickUntil(StringSplit($village_coorHourly[2], "|", 2)[3], "shop")
				EndIf

				If Not(getLocation() = "shop") Then
					Local $shadyShop = findImage("misc-shop", 50, 100)
					If isArray($shadyShop) = True Then clickUntil($shadyShop, "shop")
				EndIf
			Case "manage"
				clickUntil($village_coorMonsters, "monsters")
				clickUntil($village_coorManage, "manage")
			Case "monsters"
				clickUntil($village_coorMonsters, "monsters")
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
				If checkPixel($battle_pixelUnavailable) Then Return False
				clickUntil($battle_pixelUnavailable, "catch-mode,unknown", 10, 1000)
			Case ""
				Return True
			Case Else
				MsgBox(0, $botName & " " & $botVersion, "Unknown location.")
		EndSwitch

		Return waitLocation($strLocation)
	Else
		While True
			Local $currLocation = getLocation()

			Switch $currLocation
				Case $strMainLocation, $strLocation
					ExitLoop
				Case "battle", "battle-auto"
					If $forceGiveUp = False Then Return False
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
							If waitLocation("village", 10000) Then ExitLoop
						Case "monsters", "manage", "map"
							clickUntil($game_pixelBack, "village")
							If waitLocation("village", 10000) Then ExitLoop
						Case "unknown", "inbox", "monsters", "shop", "astroleague", "map-stage", "clan", "association", "starstone-dungeons", "map-battle"
							If checkPixel($game_pixelBack) = True Then clickPoint($game_pixelBack)
							clickPoint(findImage("misc-close", 30), 3, 100) ;to close any windows open
						Case Else
							ControlSend($hWindow, "", "", "{ESC}")
					EndSwitch
					waitLocation("village", 10000)

					#cs
						Local $villagePos = 0
						If isArray(findImage("misc-village-pos1", 50)) Then
							$villagePos = 0
						ElseIf isArray(findImage("misc-village-pos2", 50)) Then
							$villagePos = 1
						ElseIf isArray(findImage("misc-village-pos3", 50)) Then
							$villagePos = 2
						EndIf

						For $coord In StringSplit($village_coorNezz[$villagePos], "|", 2)
							clickPoint($coord, 2, 50)
						Next
					#ce
				Case "map"
					Switch $currLocation
						Case "battle-end"
							clickUntil($battle_coorMap, "unknown")
							If waitLocation("map", 10000) = "map" Then ExitLoop
						Case "village"
							clickWhile($village_coorPlay, "village")
							Switch waitLocation("unknown,dialogue", 3000)
								Case "unknown"
									If isArray(findImage("misc-close", 100)) = True Then
										clickPoint(findImage("misc-close", 30), 3, 100) ;to close any windows open
										clickWhile($village_coorPlay, "village")
									EndIf
								Case "dialogue"
									clickPoint($game_coorDialogueSkip, 3, 100)
									If isArray(findImage("misc-close", 100)) = True Then
										clickPoint(findImage("misc-close", 30), 3, 100) ;to close any windows open
										clickWhile($village_coorPlay, "village")
									EndIf
							EndSwitch
							If waitLocation("map", 10000) = "map" Then ExitLoop
						Case "astroleague", "map-battle", "association", "clan"
							If checkPixel($game_pixelBack) = True Then clickPoint($game_pixelBack)
							waitLocation("map", 2000)
						Case "map-stage"
							clickPoint(findImage("misc-close", 30)) ;to close any windows open
							If waitLocation("map", 2000) = "map" Then ExitLoop
						Case "unknown"
							If checkPixel($game_pixelBack) = True Then clickPoint($game_pixelBack)
							clickPoint(findImage("misc-close", 30)) ;to close any windows open
						Case Else
							ControlSend($hWindow, "", "", "{ESC}")
					EndSwitch
				Case "battle", "battle-auto"
					If Not(waitLocation("battle,battle-auto", 8000)) = "" Then ExitLoop
				Case Else
					setLog("Unknown main location: " & $strMainLocation & ".")
			EndSwitch
			If _Sleep(100) Then Return -1
		WEnd
		navigate($strMainLocation, $strLocation)
	EndIf

	If $strLocation = "" And $strMainLocation = getLocation() Then Return True
	If $strLocation = getLocation() Then Return True
EndFunc