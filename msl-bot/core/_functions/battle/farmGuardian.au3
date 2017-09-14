#cs
	Function: farmGuardian
		Farms guardian dungeon monsters selectively.

	Parameters:
		-idMon: 0 for first astromon, 1 for right astromon, 2 for both astromon

	Return:
		Number of guardian dungeon runs.
		*On error returns -1
#ce

Func farmGuardian($idMon)
	setLog("Starting to farm guardian dungeons.")
	navigate("map")

	Local $numRuns = 0 ;Total number of dungeon runs

	While True
		If _Sleep(10) Then Return -1
		Switch checkLocations("battle-boss,unknown,battle,battle-auto,pause,battle-end-exp,battle-sell,battle-end,guardian-dungeons,refill,map-battle")
			Case "" ;For locations that are not part of farming dungeons
				Local $tempTimer = TimerInit()
				While TimerDiff($tempTimer) < 300000 ;five minutes
					If navigate("map", "guardian-dungeons") = True Then ExitLoop
					If _Sleep(5000) Then Return -1
				WEnd

				;Returns early if cannot navigate within 5 minutes
				If TimerDiff($tempTimer) >= 300000 Then ExitLoop

			Case "guardian-dungeons"
				;Finding available astromon within 10 seconds
				Local $monPoint ;Point of an available astromon

				Local $tempTimer = TimerInit()
				While TimerDiff($tempTimer) < 10000 ;10 seconds
					$monPoint = _getGuardianMon($idMon)
					If $monPoint[0] <> "" Then ExitLoop

					ControlSend($hWindow, "", "", "{UP}") ;Tries to check for other mons by scrolling up
					If _Sleep(500) Then Return -1
				WEnd

				;End farm guardian if dungeon not longer found
				If TimerDiff($tempTimer) >= 10000 Then ExitLoop

				;Enter into map-battle location and lets the case for map battle take over
				If clickUntil($monPoint, "map-battle") = True Then
					$numRuns += 1
					setLogReplace("Found dungeon, attacking x" & $numRuns)
				Else
					ExitLoop
				EndIf
			Case "battle-end"
				clickUntil("400, 260", "unknown,guardian-dungeons")

			Case "map-battle"
				clickUntil($map_coorBattle, "battle-auto,battle,unknown")

			Case "battle"
				clickUntil($battle_coorAuto, "battle-auto", 3, 2000)

			Case "battle-end-exp", "battle-sell"
				clickUntil($game_coorTap, "battle-end", 20, 500)

			Case "battle-end"
				clickUntil("400,250", "unknown,guardian-dungeons")

			Case "pause"
				clickUntil($battle_coorContinue, "battle,battle-auto")

			Case "refill"
				ExitLoop
		EndSwitch
	WEnd

	setLog("Finished farming guardian dungeons.")

	navigate("map")
	Return $numRuns
EndFunc

#cs
	Function: _getGuardianMon
		Helper function for farmGuardian. Searches for an available monster on the 'guardian-dungeons' location

	Parameters:
		- $idMon: 0 for first astromon, 1 for right astromon, 2 for both astromon

	Return:
		2D array of the energy location of the monster found.
		*Empty string on not found.
		*On error returns -1
#ce

Func _getGuardianMon($idMon)
	_CaptureRegion()

	Local $foundMon[2] ;[x, y]

	Switch $idMon
		Case 0 To 1
			Local $colorSet[10] ;10 colors of the selected astromon icon

			For $i = 0 To 9
				$colorSet[$i] = "0x" & Hex(_GDIPlus_BitmapGetPixel($hBitmap, 346+(62*$idMon), 195+$i), 6)
			Next

			;Check for first pixel and then check for other 4 pixels relative to the first pixel
				Local $yDisplace = 0

				Do
					Local $foundPixel = _findColor("577," & 265+$yDisplace, "1," & 150-$yDisplace, $colorSet[0], 30)

					If isArray($foundPixel) = True Then
						;Add in coordinations with color for checkPixels
						Local $pixelSet[10]
						For $i = 0 to 9
							$pixelSet[$i] = $foundPixel[0] & "," & $foundPixel[1]+$i & "," & $colorSet[$i]
						Next

						;Counting correct pixels within the sequence
						Local $correctPixels = 0
						For $i = 0 To 9
							If checkPixel($pixelSet[$i], 30) = True Then $correctPixels += 1
						Next

						If $correctPixels >= 5 Then ;50% of pixels are correct
							$foundMon = $foundPixel
							$foundMon[0] += 50
							ExitLoop
						EndIf

						$yDisplace = $foundPixel[1]-264
					EndIf
				Until isArray($foundPixel) = False
		Case 2
			;Only looks for energy since all monsters are to be selected
			Local $tempPoint = _findColor("678,265", "1,210", 0xFACF27, 10)
			If isArray($tempPoint) = True Then $foundMon = $tempPoint
	EndSwitch

	Return $foundMon
EndFunc