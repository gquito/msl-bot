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
		setLog("Error: Could not go into monsters!", 1)
		Return False
	EndIf

	;setting up recent and icon list
	clickPoint("133, 22", 3, 100)
	clickPoint("265, 469", 3, 100)

	;starting to evolve
	For $selectMon = 0 To 3
		evolveClickMon($monster)

		If Not (getLocation() = "monsters-evolution") Then
			clickUntil("600, 391", "monsters-evolution")
		EndIf

		If setLogReplace("Evolving astromon...Awakening", 1) Then Return -1

		Local $empty3rdSlot = [583, 182, 0x7D624D]

		_CaptureRegion()
		While checkPixel($empty3rdSlot) = True
			Local $evoSlime = findImage($monster, 130, 100, 314, 298, 772, 363)
			While isArray($evoSlime)
				If _Sleep(10) Then Return -1
				clickPoint($evoSlime) ;click to awaken
				clickPoint("574, 223", 3, 50) ;click ex just in case it is already awakened

				_CaptureRegion()
				If checkPixel($empty3rdSlot) = False Then ExitLoop(2)
				$evoSlime = findImage($monster, 130, 100, 314, 298, 772, 363)
			WEnd

			_CaptureRegion()
			If checkPixel($empty3rdSlot) Then ;not enough astromons
				If setLogReplace("Evolving astromon...Missing an astromon!") Then Return -1
				Local $needCatch = 1
				Local $tempGemUsed = 0
				farmGemCatching($needCatch, $tempGemUsed, 30)
				Local $tempTimer = TimerInit()
				While navigate("village", "monsters", True) = False
					If TimerDiff($tempTimer) > 300000 Then ;5 minutes
						If setLog("Error: Could not go into inventory!", 1) Then Return -1
						Return False
					EndIf
				WEnd
				evolveClickMon($monster)
			EndIf

			_CaptureRegion()
		WEnd

		;awakening and evolving
		If _Sleep(10) Then Return -1
		clickUntil("424, 394", "monsters-awaken", 20, 500)

		If getLocation() = "buy-gold" Then
			setLog("Error: Out of gold!", 2)
			Return False
		EndIf

		If setLogReplace("Evolving astromon...Evolving", 2) Then Return -1
		If _Sleep(10) Then Return -1
		clickUntil("308, 316", "monsters-evolution", 20, 500)
		If _Sleep(10) Then Return -1
		clickUntil("657, 394", "monsters-evolve", 20, 500)

		If getLocation() = "buy-gold" Then
			setLog("Error: Out of gold!", 1)
			Return False
		EndIf

		If _Sleep(10) Then Return -1
		clickUntil("308, 316", "unknown", 20, 500)
		If _Sleep(10) Then Return -1
		clickPoint($game_coorTap, 10, 500)
		logUpdate()

		getQuest() ;collecting quest
		If _Sleep(10) Then Return -1
		navigate("village", "monsters") ;going back to monsters
	Next

	;for evo2 -> evo3--------------------------------------------
	If setLog("Evolving astromon...Evolving to Evolution 3", 1) Then Return -1
	clickPoint("53, 152", 3, 100) ;click monster
	clickUntil("600, 391", "monsters-evolution")

	Local $empty3rdSlot = [583, 182, 0x7D624D]
	Local $evoSlime = findImage($monster & "x", 130, 100, 314, 298, 772, 363)
	While isArray($evoSlime)
		If _Sleep(10) Then Return -1
		clickPoint($evoSlime) ;click to awaken
		clickPoint("574, 223", 3, 50) ;click ex just in case it is already awakened

		_CaptureRegion()
		If checkPixel($empty3rdSlot) = False Then ExitLoop
		$evoSlime = findImage($monster & "x", 130, 100, 314, 298, 772, 363)
	WEnd

	;awakening and evolving
	If _Sleep(10) Then Return -1
	clickUntil("424, 394", "monsters-awaken", 20, 500)

	If getLocation() = "buy-gold" Then
		setLog("Error: Out of gold!", 1)
		Return False
	EndIf

	If _Sleep(10) Then Return -1
	clickUntil("308, 316", "monsters-evolution", 20, 500)
	If _Sleep(10) Then Return -1
	clickUntil("657, 394", "monsters-evolve", 20, 500)

	If getLocation() = "buy-gold" Then
		setLog("Error: Out of gold!", 1)
		Return False
	EndIf

	If _Sleep(10) Then Return -1
	clickUntil("308, 316", "unknown")
	clickPoint($game_coorTap, 10, 500)

	;releasing slime--
	navigate("village", "monsters")
	If _Sleep(10) Then Return -1

	clickPoint("776, 111", 3) ;click x
	If _Sleep(100) Then Return -1

	_CaptureRegion()
	If checkPixels("356,131,0xCEC9C5|357,127,0xD9D4D0|357,124,0xA09D9A|360,129,0xDDD9D4") = True Then
		If setLogReplace("Evolving astromon...Releasing slime", 1) Then Return -1
		clickUntil("647,459", "unknown")
		clickUntil("319,334", "monsters")
	Else
		If setLog("Could not detect evo3 slime, not releasing slime.", 1) Then Return -1
	EndIf
	;--

	getQuest() ;collecting quest
	navigate("village")
	If setLogReplace("Evolving astromon...Done!", 1) Then Return -1
	Return True
EndFunc

Func evolveClickMon($monster)
	If setLogReplace("Evolving astromon...Finding astromon", 1) Then Return -1

	Local $timerStart = TimerInit()
	Local $monEvo = findImage($monster, 130, 1000, 9, 101, 292, 449)
	If _Sleep(10) Then Return -1
	While isArray($monEvo) = False
		ControlSend($hWindow, "", "", "{RIGHT}")
		If _Sleep(500) Then Return -1

		If TimerDiff($timerStart) > 60000 Then Return False;1 minutes
		$monEvo = findImage($monster, 130, 500, 9, 101, 292, 449)
	WEnd
	If setLogReplace("Evolving astromon...Found!", 1) Then Return -1
	clickPoint($monEvo, 3, 100) ;click monster
	If _Sleep(10) Then Return -1
	clickUntil("600, 391", "monsters-evolution")
EndFunc
