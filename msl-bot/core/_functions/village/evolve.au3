#cs ----------------------------------------------------------------------------
 Function: evolve
 Evolve an astromon to evo3 assuming all evo1 materials are available.

 Pre: Must have all other 15 evo1 to feed.

 Parameters:
 monster: Image of evo1 monster.

 Return: (Boolean) On error return False. Success return True
 Author: GkevinOD (2017)
#ce ----------------------------------------------------------------------------

Func evolve($monster)
	If setLogReplace("Evolving astromon...", 2) Then Return -1
	If navigate("village", "monsters", True) = False Then
		setLog("Error: Could not go into monsters!", 2)
		Return False
	EndIf

	;setting up recent and icon list
	clickPoint("133, 22")
	clickPoint("265, 469")

	;starting to evolve
	For $selectMon = 0 To 3
		If setLogReplace("Evolving astromon...Finding astromon", 2) Then Return -1

		Local $timerStart = TimerInit()
		Local $monEvo = findImage($monster, 130, 1000, 9, 101, 292, 449)
		While isArray($monEvo) = False
			ControlSend($hWindow, "", "", "{RIGHT}")
			If _Sleep(1000) Then Return -1

			If TimerDiff($timerStart) > 300000 Then Return False;5 minutes
			$monEvo = findImage($monster, 130, 1000, 9, 101, 292, 449)
		WEnd
		If setLogReplace("Evolving astromon...Found!", 2) Then Return -1
		clickPoint($monEvo, 3) ;click monster

		clickUntil("600, 391", "monsters-evolution")

		If setLogReplace("Evolving astromon...Ascending", 2) Then Return -1

		Local $empty3rdSlot = [583, 182, 0x7D624D]
		Local $evoSlime = findImage($monster, 130, 1000, 314, 298, 772, 363)
		While isArray($evoSlime)
			clickPoint($evoSlime) ;click to awaken
			clickPoint("574, 223", 3, 50) ;click ex just in case it is already awakened

			_CaptureRegion()
			If checkPixel($empty3rdSlot) = False Then ExitLoop
			$evoSlime = findImage($monster, 130, 1000, 314, 298, 772, 363)
		WEnd

		;awakening and evolving
		clickUntil("424, 394", "monsters-awaken")

		If getLocation() = "buy-gold" Then
			setLog("Error: Out of gold!", 2)
			Return
		EndIf

		If setLogReplace("Evolving astromon...Evolving", 2) Then Return -1
		clickUntil("308, 316", "monsters-evolution")
		clickUntil("657, 394", "monsters-evolve")

		If getLocation() = "buy-gold" Then
			setLog("Error: Out of gold!", 2)
			Return
		EndIf

		clickUntil("308, 316", "unknown")
		clickPoint($game_coorTap, 10, 500)
		logUpdate()

		getQuest() ;collecting quest
		navigate("village", "monsters") ;going back to monsters
	Next

	;for evo2 -> evo3
	If setLog("Evolving astromon...Evolving to Evolution 3", 2) Then Return -1
	clickPoint("53, 152", 3) ;click monster
	clickUntil("600, 391", "monsters-evolution")

	Local $empty3rdSlot = [583, 182, 0x7D624D]
	Local $evoSlime = findImage($monster & "x", 130, 1000, 314, 298, 772, 363)
	While isArray($evoSlime)
		clickPoint($evoSlime) ;click to awaken
		clickPoint("574, 223", 3, 50) ;click ex just in case it is already awakened

		_CaptureRegion()
		If checkPixel($empty3rdSlot) = False Then ExitLoop
		$evoSlime = findImage($monster & "x", 130, 1000, 314, 298, 772, 363)
	WEnd

	;awakening and evolving
	clickUntil("424, 394", "monsters-awaken")

	If getLocation() = "buy-gold" Then
		setLog("Error: Out of gold!", 2)
		Return
	EndIf

	clickUntil("308, 316", "monsters-evolution")
	clickUntil("657, 394", "monsters-evolve")

	If getLocation() = "buy-gold" Then
		setLog("Error: Out of gold!", 2)
		Return
	EndIf

	clickUntil("308, 316", "unknown")
	clickPoint($game_coorTap, 10, 500)

	getQuest() ;collecting quest
	navigate("village")
	If setLogReplace("Evolving astromon...Done!", 2) Then Return -1
	Return True
EndFunc