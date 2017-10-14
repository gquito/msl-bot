#cs
	Function: enterStage
		Algorithm for entering a stage in the maps.

	Parameters:
		strImage - Image name of the map.
		strMode - Modes include: normal, hard, extreme
		strStage - Level number. If not available, looks top-most visible stage. Bonus stages: "gold", "exp"
		boolAuto - Boolean for autobattle mode.

	Returns: (boolean) On success returns true, fail return false
#ce

Func enterStage($strImage, $strMode = "normal", $levelStage = "exp", $boolAuto = False)
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
					If setLog("*Could not select stage.") Then Return -1
					If setLog("Going back to village.") Then Return -1

					navigate("village")
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
							If setLog("*Could not change difficulty.") Then Return -1
					EndSwitch

					;Selecting stage level (Probably recode in the future to not use images.'
					If setLog("-Searching for stage level.") Then Return -1

					Local $arrayStage ;Point to go into map-battle
					If StringIsDigit($levelStage) = True Then
						$arrayStage = findLevel($levelStage)

						If isArray($arrayStage) = False Then
							If setLog("*Could not go into a stage level.") Then Return -1
							Return False
						EndIf
					Else
						;Finding gold/exp stages
						Local $tempTimer = TimerInit()
						While isArray($arrayStage) = False
							If TimerDiff($tempTimer) > 20000 Then
								If setLog("*Could not go into a stage level.") Then Return -1
								Return False
							EndIf

							Switch $levelStage
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
								ControlSend($hWindow, "", "", "{DOWN}")
								If getLocation() <> "map-stage" Then ContinueLoop(2) ;Goes back to main loop if misclick happens
							EndIf

							If _Sleep(1000) Then Return -1
						WEnd
					EndIf

					If setLog(StringStripWS("-Entering stage " &  $levelStage & ".", 4)) Then Return -1
					clickWhile($arrayStage, "map-stage")
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
					If setLog("*Could not go into battle.") Then Return -1
					Return False
				Else
					If setLog("Finished entering stage.") Then Return -1
					Return True
				EndIf
		EndSwitch
	WEnd

	Return False ;If time runs out
EndFunc

#cs
	Function: findLevel
		Algorithm uses stored pixel record of level to locate level in map-stage location.

	Parameters:
		- level: Level to find. Must exist in the pixel records.

	Return:
		Returns point array if location found.
		*False if not found or Error.
#ce
Func findLevel($level)
	If getLocation() <> "map-stage" Then Return False

	Local $pixRec = getPixelRecord("LEVEL;" & $level)
	If $pixRec <> Null Then
		Local $x = 426 ;X starting point of the level.

		Local $tempTimer = TimerInit()
		While TimerDiff($tempTimer) < 30000 ;30 seconds to perform scrolling
			For $y = 480 To 240 Step -35
				Local $foundPoint = _findColor(744 & "," & $y, "1,-60", 0xFAD028, 30, 1, -1)
				If isArray($foundPoint) = False Then ContinueLoop

				Local $_y = $foundPoint[1] - 14 ;Locates the marker which is the first yellow pixel on the energy number.
				If $_y = -1 Then ContinueLoop ;ignores if marker not found

				;setLog("-Found point: " & $x & ", " & $_y)

				;Checks y with difference of +-1 due to sometimes incorrect detection in starting position.
				Local $recordStatus[3]
				$recordStatus[0] = checkPixelRecord($pixRec, $x & "," & $_y-1)
				$recordStatus[1] = checkPixelRecord($pixRec, $x & "," & $_y)
				$recordStatus[2] = checkPixelRecord($pixRec, $x & "," & $_y+1)

				;setLog("--Status (-1): " & $recordStatus[0])
				;setLog("--Status (0): " & $recordStatus[1])
				;setLog("--Status (+1): " & $recordStatus[2])

				For $stat in $recordStatus
					If $stat = 0 Then ExitLoop ;Caused by no pixels match or 0/0 error

					If $stat > 95 Then ;Returns if pixel record matches over 95% of the pixels
						Local $returnPoint[2] = [$x+300, $_y]
						Return $returnPoint
					EndIf
				Next
			Next

			If getLocation() <> "map-stage" Then Return False
			ControlSend($hWindow, "", "", "{DOWN}")
			If _Sleep(200) Then Return -1
		WEnd

		Local $tempTimer = TimerInit()
		While TimerDiff($tempTimer) < 30000 ;30 seconds to perform scrolling
			For $y = 480 To 240 Step -35
				Local $foundPoint = _findColor(744 & "," & $y, "1,-60", 0xFAD028, 30, 1, -1)
				If isArray($foundPoint) = False Then ContinueLoop

				Local $_y = $foundPoint[1] - 14 ;Locates the marker which is the first yellow pixel on the energy number.
				If $_y = -1 Then ContinueLoop ;ignores if marker not found

				;setLog("-Found point: " & $x & ", " & $_y)

				;Checks y with difference of +-1 due to sometimes incorrect detection in starting position.
				Local $recordStatus[3]
				$recordStatus[0] = checkPixelRecord($pixRec, $x & "," & $_y-1)
				$recordStatus[1] = checkPixelRecord($pixRec, $x & "," & $_y)
				$recordStatus[2] = checkPixelRecord($pixRec, $x & "," & $_y+1)

				;setLog("--Status (-1): " & $recordStatus[0])
				;setLog("--Status (0): " & $recordStatus[1])
				;setLog("--Status (+1): " & $recordStatus[2])

				For $stat in $recordStatus
					If $stat = 0 Then ExitLoop ;Caused by no pixels match or 0/0 error

					If $stat > 95 Then ;Returns if pixel record matches over 95% of the pixels
						Local $returnPoint[2] = [$x+300, $_y]
						Return $returnPoint
					EndIf
				Next
			Next

			If getLocation() <> "map-stage" Then Return False
			ControlSend($hWindow, "", "", "{UP}")
			If _Sleep(200) Then Return -1
		WEnd
	EndIf

	Return False
EndFunc

#cs
	Function: recordLevel
		Finds the starting pxiel of the stage level and stores as a pixel record.

	Parameters:
		- level: The level of the stage to be stored.

	Returns: (boolean) On success returns true, fail return false
#ce

Func recordLevel($level)
	Local $desktopCoor = WinGetPos($hControl) ;Used for calculating control mouse position.
	Local $x = 426 ;Left side of the level
	Local $y = 0 ;Y position of the number, to be calculated

	If setLog("Click below energy number...") Then Return -1
	While _IsPressed(01) = False
		If _Sleep(5) Then Return -1
	WEnd

	;Converting mouse position from windows to nox control.
	Local $initialPos = MouseGetPos()
	$initialPos[0] -= $desktopCoor[0]
	$initialPos[1] -= $desktopCoor[1]
	If setLog("-Got click at (" & $initialPos[0] & "," & $initialPos[1] & ").") Then Return -1

	setLog("-Finding starting point.")
	$y = _findColor(744 & "," & $initialPos[1], "1,-60", 0xFAD028, 30, 1, -1)[1] - 14 ;Locates the marker which is the first yellow pixel on the energy number.
	If $y = -1 Then Return False

	setLog("-Starting point: " & $x & ", " & $y)
	;Stores pixel record in default pixel-records-extra.txt
	recordPixel("LEVEL;"& $level, $x & "," & $y, 18, 12)

	setLog("Complete.")
	Return True
EndFunc

;~ Func _findLevel($level)
;~ 	Local $pixRec = getPixelRecord("LEVEL;" & $level)
;~ 	If $pixRec <> Null Then
;~ 		Local $desktopCoor = WinGetPos($hControl)

;~ 		Local $x = 426
;~ 		Local $y = 0

;~ 		setLog("Click below energy number...")
;~ 		While _IsPressed(01) = False
;~ 			If _Sleep(10) Then Return -1
;~ 		WEnd

;~ 		Local $initialPos = MouseGetPos()
;~ 		$initialPos[0] -= $desktopCoor[0]
;~ 		$initialPos[1] -= $desktopCoor[1]
;~ 		setLog("-Got click at (" & $initialPos[0] & "," & $initialPos[1] & ").")

;~ 		setLog("-Finding starting point.")
;~ 		Local $foundPoint = _findColor(744 & "," & $y, "1,-60", 0xFAD028, 30, 1, -1)
;~ 		If isArray($foundPoint) = False Then ContinueLoop
;~
;~ 		$y = $foundPoint[1] - 14 ;Locates the marker which is the first yellow pixel on the energy number.

;~ 		setLog("-Starting point: " & $x & ", " & $y)
;~ 		Local $recordStatus[3]
;~ 		$recordStatus[0] = checkPixelRecord($pixRec, $x & "," & $y-1, "0x3A2923,10")
;~ 		$recordStatus[1] = checkPixelRecord($pixRec, $x & "," & $y, "0x3A2923,10")
;~ 		$recordStatus[2] = checkPixelRecord($pixRec, $x & "," & $y+1, "0x3A2923,10")
;~ 		setLog("-Status (-1): " & $recordStatus[0])
;~ 		setLog("-Status (0): " & $recordStatus[1])
;~ 		setLog("-Status (+1): " & $recordStatus[2])

;~ 		setLog("Complete.")
;~ 	EndIf
;~ EndFunc
