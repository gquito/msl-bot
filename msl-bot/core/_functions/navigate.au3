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

	Switch $strCurrentLocation
		Case "battle-auto"
			$strCurrentLocation = "battle"
		Case "monsters-evolution", ""
			$strCurrentLocation = "monsters"
	EndSwitch

	If $strLocation = $strCurrentLocation Then Return True
	If $strCurrentLocation = $strMainLocation Then
		Switch $strLocation
			;village
			Case "shop"
				Local $villagePos = getVillagePos()
				Switch $villagePos
					Case 0
						clickUntil(StringSplit($village_coorHourly[0], "|", 2)[3], "shop")
					Case 1
						clickUntil(StringSplit($village_coorHourly[1], "|", 2)[3], "shop")
					Case 2
						clickUntil(StringSplit($village_coorHourly[2], "|", 2)[3], "shop")
					Case Else
						If _setLog("The Ship is in an unknown position") Then Return -1
						Return False
				EndSwitch

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
				clickUntil(findImage("map-dungeons", 50), "starstone-dungeons,golem-dungeons")
				clickUntil($map_coorGuardianDungeons, "guardian-dungeons")
			
			Case "golem-dungeons"
				If setLogReplace("Navigating to golems..", 1) Then Return -1

				Local $timerStart = TimerInit()
				Local $imgPoint = findImage("map-golems", 50)
				While Not isArray($imgPoint)
					If setLogReplace("Navigating to golems.. Swiping", 1) Then Return -1
					ControlSend($hWindow, "", "", "{LEFT}")

					If TimerDiff($timerStart) > 120000 Then ;two minutes
						If setLogReplace("Could not find golems!", 1) Then Return -1
						If navigate("village") = True Then
							Return False
						EndIf
					EndIf

					If _Sleep(500) Then Return -1
					If Not checkLocations("astroleague, map-stage, association") = "" Then ControlSend($hWindow, "", "", "{ESC}")

					_CaptureRegion()
					$imgPoint = findImage("map-golems", 50)
				WEnd

				;clicking map list and selecting difficulty
				clickUntil($imgPoint, "golem-dungeons", 3, 3000)

			Case "gold-dungeons"
				clickUntil(findImage("map-dungeons", 50), "gold-dungeons,starstone-dungeons,golem-dungeons")
				clickUntil($map_coorGoldDungeons, "gold-dungeons")
				
			Case "starstone-dungeons"
				clickUntil(findImage("map-dungeons", 50), "starstone-dungeons,golem-dungeons")
				clickUntil($map_coorStarstoneDungeons, "starstone-dungeons")
				
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
						Case "monsters", "manage", "map", "quests"
							clickUntil($game_pixelBack, "village")
							If waitLocation("village", 5000) Then ExitLoop
						Case "unknown", "inbox", "shop", "astroleague", "map-stage", "clan", "association", "starstone-dungeons", "map-battle"
							If checkPixel($game_pixelBack) = True Then clickPoint($game_pixelBack, 3)
							clickUntil(findImage("misc-close", 30), "village", 3, 1000) ;to close any windows open
						Case Else
							ControlSend($hWindow, "", "", "{ESC}")
					EndSwitch

				Case "map"
					Switch $currLocation
						Case "battle-end"
							clickUntil($battle_coorMap, "unknown")
							If waitLocation("map", 10000) = "map" Then ExitLoop
						Case "village"
							clickWhile($village_coorPlay, "village")
							Switch waitLocation("unknown,dialogue", 3000)
								Case "unknown"									
									_Sleep(250)
									If getLocation() == "bingo-play" Then
										playBingo()
										_Sleep(100)
									EndIf
									
									If isArray(findImage("misc-close", 100)) = True Then
										clickUntil(findImage("misc-close", 30), "village", 3, 1000) ;to close any windows open
										clickWhile($village_coorPlay, "village")
									EndIf
									
								Case "dialogue"
									clickWhile($game_coorDialogueSkip, "dialogue")
									_Sleep(100)
									
									If getLocation() == "bingo-play" Then
										playBingo()
										_Sleep(100)
									EndIf
									
									If isArray(findImage("misc-close", 100)) = True Then
										clickUntil(findImage("misc-close", 30), "village", 3, 1000) ;to close any windows open
										clickWhile($village_coorPlay, "village")
									EndIf
									
								Case "bingo-play"
									playBingo()
							
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
					ExitLoop
			EndSwitch
			If _Sleep(100) Then Return -1
		WEnd
		navigate($strMainLocation, $strLocation)
	EndIf

	If $strLocation = "" And $strMainLocation = getLocation() Then Return True
	If $strLocation = getLocation() Then Return True
EndFunc