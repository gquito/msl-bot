#cs ----------------------------------------------------------------------------
 Function: enterStage
 Algorithm for entering a stage in the maps.

 Parameters:
	strImage - Image name of the map.
	strMode - Modes include: normal, hard, extreme
	strBonus - Bonus include: exp, gold, any
	boolAuto - Boolean for autobattle mode.

 Returns: (boolean) On success returns true, fail return false
	-1 on Bot Stop
#ce ----------------------------------------------------------------------------

Func enterStage($strImage, $strMode = "normal", $strBonus = "gold", $boolAuto = False)
	If Not(waitLocation("map") = "") Then
		Local $strMap = StringReplace(_StringProper(StringReplace($strImage, "-", " ")), "Map ", "")
		If setLogReplace("Entering " & $strMap & "..Searching", 1) Then Return -1

		Local $errorCounter = 0
		Local $imgPoint = findImage($strImage, 50)
		While Not isArray($imgPoint)
			If setLogReplace("Entering " & $strMap & "..Swiping", 1) Then Return -1
			ControlSend($hWindow, "", "", "{LEFT}")

			$errorCounter+=1
			If $errorCounter > 30 Then Return False

			If _Sleep(2000) Then Return -1

			If Not checkLocations("astroleague, map-stage, association") = "" Then ControlSend($hWindow, "", "", "{ESC}")

			_CaptureRegion()
			$imgPoint = findImage($strImage, 50)
		WEnd
		If setLogReplace("Entering " & $strMap & "..Stage Found.", 1) Then Return -1

		;clicking map list and selecting difficulty
		clickPoint($imgPoint, 1, 2000, False)

		If Not getLocation() = "map-stage" Then Return False
		Switch $strMode
			Case "normal" ;Normal
				If setLogReplace("Entering " & $strMap & "..Mode: Normal", 1) Then Return -1
				clickPoint($map_coorMode, 1, 500, False)
				clickPoint($map_coorNormal, 1, 500, False)
			Case "hard" ;Hard
				If setLogReplace("Entering " & $strMap & "..Mode: Hard", 1) Then Return -1
				clickPoint($map_coorMode, 1, 500, False)
				clickPoint($map_coorHard, 1, 500, False)
			Case "extreme" ;Extreme
				If setLogReplace("Entering " & $strMap & "..Mode: Expert", 1) Then Return -1
				clickPoint($map_coorMode, 1, 500, False)
				clickPoint($map_coorExtreme, 1, 500, False)
			Case Else
				If setLog("Input error: " & $strMode & " not within 1-3 modes.", 1) Then Return -1
				Return 0
		EndSwitch

		;selecting a stage
		Local $startTimer = TimerInit()
		Switch $strBonus
			Case "gold"
				Local $arrayStage = findImage("misc-gold-bonus", 30)
				While isArray($arrayStage) = False
					ControlSend($hWindow, "", "", "{LEFT}")
					If _Sleep(500) Then Return -1

					$arrayStage = findImage("misc-gold-bonus", 30)
					If TimerDiff($startTimer) > 20000 Then ExitLoop
				WEnd
				If setLogReplace("Entering " & $strMap & "..Entering gold stage", 1) Then Return -1
			Case "exp"
				Local $arrayStage = findImage("misc-exp-bonus", 30)
				While isArray($arrayStage) = False
					ControlSend($hWindow, "", "", "{LEFT}")
					If _Sleep(500) Then Return -1

					$arrayStage = findImage("misc-exp-bonus", 30)
					If TimerDiff($startTimer) > 20000 Then ExitLoop
				WEnd
				If setLogReplace("Entering " & $strMap & "..Entering exp stage", 1) Then Return -1
			Case Else
				If setLogReplace("Entering " & $strMap & "..Entering random stage", 1) Then Return -1
				Local $arrayStage = findImage("misc-stage-energy", 100, 5000)
		EndSwitch

		If Not isArray($arrayStage) Then Return -1
		clickPoint($arrayStage)

		;applying autobattle mode
		If $boolAuto = True Then
			If setLogReplace("Entering " & $strMap & "..Autobattle Mode", 1) Then Return -1
			clickUntil($map_pixelAutoBattle20xUnchecked, "autobattle-prompt")
			clickWhile($map_coorConfirmAutoBattle, "autobattle-prompt")
		EndIf

		;launching stage
		clickWhile($map_coorBattle, "map-battle")
		If Not checkLocations("map-gem-full, battle-gem-full") = "" Then
			If setLogReplace("Entering " & $strMap & "..Gem box full!", 1) Then Return -1
			Return False
		EndIf

		Return Not(waitLocation("battle,unknown,battle-auto", 10000) = "")
	EndIf

	Return False
EndFunc