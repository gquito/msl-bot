#cs ----------------------------------------------------------------------------

 Function: enterStage

 Algorithm for entering a stage in the maps.

 Parameters:

	strImage - Image name of the map.

	intMode - Modes include: Normal(1), Hard(2), Extreme(3).

	boolAuto - Boolean for autobattle mode.

 Returns:

	On success - Returns 1

	On fail - Returns 0

#ce ----------------------------------------------------------------------------

Func enterStage($strImage, $intMode = 1, $boolAuto = False, $boolLog = True)
	If waitLocation("map") = 1 Then
		Local $errorCounter = 0
		While findImageWait($strImage, 2, 100) = False
			If _Sleep(100) Then Return

			If checkLocations("astroleague", "map-stage", "association") = 1 Then ControlSend($hWindow, "", "", "{ESC}")

			If $errorCounter > 20 Then
				Return 0
			EndIf

			ControlSend($hWindow, "", "", "{LEFT}")
			$errorCounter+=1
		WEnd

		;clicking map list and selecting difficulty
		clickImage($strImage, 100)
		Switch $intMode
			Case 1 ;Normal
				If $boolLog Then setLog("Entering " & _StringProper(StringReplace($strImage, "-", " ")) & " on Normal.")
				clickPoint($map_coorMode)
				clickPoint($map_coorNormal)
			Case 2 ;Hard
				If $boolLog Then setLog("Entering " & _StringProper(StringReplace($strImage, "-", " ")) & " on Hard.")
				clickPoint($map_coorMode)
				clickPoint($map_coorHard)
			Case 3 ;Extreme
				If $boolLog Then setLog("Entering " & _StringProper(StringReplace($strImage, "-", " ")) & " on Extreme.")
				clickPoint($map_coorMode)
				clickPoint($map_coorExtreme)
			Case Else
				If $boolLog Then setLog("Input error: " & $intMode & " not within 1-3 modes.")
				Return 0
		EndSwitch

		;selecting a stage (not yet complete)
		clickPoint(findImageWait("stage-energy", 5, 100))

		;applying autobattle mode
		If $boolAuto = True Then
			clickPointWait($map_pixelAutoBattle20xUnchecked, "map-battle", 5)
			clickPoint($map_coorConfirmAutoBattle)
		EndIf

		;launching stage
		clickPoint($map_coorBattle, 3, 1000)

		If checkLocations("map-gem-full", "battle-gem-full") = 1 Then Return 0

		Return waitLocation("battle", 10)
	Else
		Return 0
	EndIf
EndFunc