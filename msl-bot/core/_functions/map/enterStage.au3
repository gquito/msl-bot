#cs
	Function: enterStage
		Algorithm for entering a stage in the maps.

	Parameters:
		strImage - Image name of the map.
		strMode - Modes include: normal, hard, extreme
		strBonus - Bonus include: exp, gold, any
		boolAuto - Boolean for autobattle mode.

	Returns: (boolean) On success returns true, fail return false
#ce

Func enterStage($strImage, $strMode = "normal", $strBonus = "gold", $boolAuto = False)
	setLog("Beginning to enter stage.")

	Local $stageFound = False

	Local $scriptTimer = TimerInit()
	While TimerDiff($scriptTimer) < 300000 ;5 Minutes

		Switch checkLocations("map,map-stage,map-battle,battle-gem-full,unknown")
			Case ""
				;Goes into map if location is not within list above
				Local $tempTimer = TimerInit()
				While navigate("map") = False
					If TimerDiff($tempTimer) > 120000 Then ;2 minutes
						If setLog("Could not enter map location.") Then Return -1
						Return False
					EndIf
				WEnd
			Case "map"
				;Looks for stage
				Local $strMap = StringReplace(_StringProper(StringReplace($strImage, "-", " ")), "Map ", "") ;Proper map name: "map-phantom-forest" -> "Phantom Forest"
				If setLog("-Searching for " & $strMap & ".") Then Return -1

				Local $mapPoint = getMapCoor($strMap) ;Coordinates of found map.

				Local $tempTimer = TimerInit()
				While isArray($mapPoint) = False
					If TimerDiff($tempTimer) > 120000 Then ; two minutes
						If setLog("Could not find stage.") Then Return -1
						Return False
					EndIf

					;If a map has not been found scrolls left
					ControlSend($hWindow, "", "", "{LEFT}")
					If _Sleep(500) Then Return -1

					If getLocation() <> "map" Then ContinueLoop(2) ;Goes back to main loop if misclick happens

					$mapPoint = getMapCoor($strMap)
				WEnd

				$stageFound = True
				If clickUntil($mapPoint, "map-stage", 5, 1500) = False Then
					If setLog("Could not select stage.") Then Return -1
					Return False
				EndIf

			Case "map-stage"
				If $stageFound = True Then
					;Selecting difficulty
					If setLog("-Changing difficulty to " & $strMode & ".") Then Return -1
					clickPoint($map_coorMode, 1, 500, False)

					Switch $strMode
						Case "normal"
							clickPoint($map_coorNormal, 1, 500, False)
						Case "hard"
							clickPoint($map_coorHard, 1, 500, False)
						Case "extreme"
							clickPoint($map_coorExtreme, 1, 500, False)
						Case Else
							If setLog("Could not change difficulty.") Then Return -1
					EndSwitch

					;Selecting stage level (Probably recode in the future to not use images.'
					If setLog("-Searching for stage level.") Then Return -1

					Local $arrayStage ;Point to go into map-battle

					Local $tempTimer = TimerInit()
					While isArray($arrayStage) = False
						If TimerDiff($tempTimer) > 20000 Then
							If setLog("Could not go into a stage level.") Then Return -1
							Return False
						EndIf

						Switch $strBonus
							Case "gold"
								$arrayStage = findImage("misc-gold-bonus", 50)
							Case "exp"
								$arrayStage = findImage("misc-exp-bonus", 50)
							Case Else
								$arrayStage = findImage("misc-stage-energy", 100)
						EndSwitch

						If isArray($arrayStage) = True Then
							ExitLoop
						Else
							ControlSend($hWindow, "", "", "{LEFT}")
							If getLocation() <> "map-stage" Then ContinueLoop(2) ) ;Goes back to main loop if misclick happens
						EndIf

						If _Sleep(1000) Then Return -1
					WEnd

					If setLog(StringStripWS("-Entering " & $strBonus & " stage.", 4)) Then Return -1
					clickUntil($arrayStage, "map-battle", 5, 2000)
				Else
					;Happens when accidentally clicked a map during scroll sequence
					navigate("map")
				EndIf

			Case "map-battle"
				;Applying autobattle mode.
				If $boolAuto = True Then
					If setLog("-Enabling autobattle mode.") Then Return -1
					clickUntil($map_pixelAutoBattle20xUnchecked, "autobattle-prompt")
					clickWhile($map_coorConfirmAutoBattle, "autobattle-prompt")
				EndIf

				If waitLocation("map-battle,autobattle-prompt") = "autobattle-prompt" Then
					clickUntil("496, 327", "map-battle")
				EndIf

				;Starting battle
				If setLog("-Going into battle.") Then Return -1
				clickUntil($map_coorBattle, "battle-auto,battle,unknown")

				;Return early if cannot go into battle. Usually means full gems or full inventory
				If checkLocations("battle-auto,battle,unknown") = "" Then
					If setLog("Could not go into battle.") Then Return -1
					Return False
				Else
					If setLog("Finished entering stage.") Then Return -1
					Return True
				EndIf
		EndSwitch
	WEnd

	Return False ;If time runs out
EndFunc