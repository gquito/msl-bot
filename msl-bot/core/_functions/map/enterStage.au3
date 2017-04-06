#cs ----------------------------------------------------------------------------
 Function: enterStage
 Algorithm for entering a stage in the maps.

 Parameters:
	strImage - Image name of the map.
	strMode - Modes include: normal, hard, extreme
	boolAuto - Boolean for autobattle mode.

 Returns:
	On success - Returns 1
	On fail - Returns 0
#ce ----------------------------------------------------------------------------

Func enterStage($strImage, $strMode = "normal", $boolAuto = False)
	If waitLocation("map") = 1 Then
		Local $strMap = StringReplace(_StringProper(StringReplace($strImage, "-", " ")), "Map ", "")
		If setLogReplace("Entering " & $strMap & "..Searching", 1) Then Return 0

		Local $errorCounter = 0
		Local $imgPoint = findImage($strImage, 50)
		While Not isArray($imgPoint)
			If setLogReplace("Entering " & $strMap & "..Swiping", 1) Then Return 0
			ControlSend($hWindow, "", "", "{LEFT}")

			$errorCounter+=1
			If $errorCounter > 30 Then Return 0

			If _Sleep(2000) Then Return

			If checkLocations("astroleague", "map-stage", "association") = 1 Then ControlSend($hWindow, "", "", "{ESC}")

			_CaptureRegion()
			$imgPoint = findImage($strImage, 50)
		WEnd
		If setLogReplace("Entering " & $strMap & "..Stage Found.", 1) Then Return 0

		;clicking map list and selecting difficulty
		clickPoint($imgPoint, 1, 2000, False)

		If checkLocations("map-stage") = 0 Then Return 0
		Switch $strMode
			Case "normal" ;Normal
				If setLogReplace("Entering " & $strMap & "..Mode: Normal", 1) Then Return 0
				clickPoint($map_coorMode, 1, 500, False)
				clickPoint($map_coorNormal, 1, 500, False)
			Case "hard" ;Hard
				If setLogReplace("Entering " & $strMap & "..Mode: Hard", 1) Then Return 0
				clickPoint($map_coorMode, 1, 500, False)
				clickPoint($map_coorHard, 1, 500, False)
			Case "extreme" ;Extreme
				If setLogReplace("Entering " & $strMap & "..Mode: Expert", 1) Then Return 0
				clickPoint($map_coorMode, 1, 500, False)
				clickPoint($map_coorExtreme, 1, 500, False)
			Case Else
				If setLog("Input error: " & $strMode & " not within 1-3 modes.", 1) Then Return 0
				Return 0
		EndSwitch

		;selecting a stage (not yet complete)
		Dim $arrayEnergy = findImage("misc-stage-energy", 100, 5000)
		If Not isArray($arrayEnergy) Then Return 0

		clickPoint($arrayEnergy)

		;applying autobattle mode
		If $boolAuto = True Then
			If setLogReplace("Entering " & $strMap & "..Autobattle Mode", 1) Then Return 0
			clickUntil($map_pixelAutoBattle20xUnchecked, "autobattle-prompt")
			clickWhile($map_coorConfirmAutoBattle, "autobattle-prompt")
		EndIf

		;launching stage
		clickWhile($map_coorBattle, "map-battle")
		If checkLocations("map-gem-full", "battle-gem-full") = 1 Then
			If setLogReplace("Entering " & $strMap & "..Gem box full!", 1) Then Return 0
			Return 0
		EndIf

		Return waitLocation("battle,unknown,battle-auto", 10000)
	Else
		Return 0
	EndIf
EndFunc