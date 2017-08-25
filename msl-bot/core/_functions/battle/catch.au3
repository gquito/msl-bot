#cs ----------------------------------------------------------------------------
 Function: catch
 Algorithm for catching a certain astromons

 Parameters:
	varImages - Set of images to search for specific astromons.
	boolOneAstromon - Stop after one astromon.
	boolRareAstromon - If astromon has the rare icon on it. For checking if caught or not

 Returns:
	Array with format: ["!Miseed", "Caught", "Caught"]

#ce ----------------------------------------------------------------------------

Func catch($varImages, $boolOneAstromon = False, $boolRareAstromon = True)
	Local $astromons[0]
	If getLocation() = "catch-mode" Then
		If setLogReplace("Catching astromons... Locating", 1) Then Return -1
		Local $pointArray = 0
		If isArray($varImages) Then ;finding astromon within list
			$pointArray = findImages($varImages, 100, 1000, 0, 263, 800, 473)
		Else
			$pointArray = findImage($varImages, 100, 1000, 0, 263, 800, 473)
		EndIf

		If isArray($pointArray) = True Then ;found
			Local $strGrade = _StringProper(StringRegExpReplace($pointArray[3], ".*catch-(.+)(\D)(\d+?|\d?)\.bmp", "$1$2"))
			If setLogReplace("Catching astromons... Found " & $strGrade & "!", 1) Then Return -1
			$pointArray[1] -= 50

			;catching astromons
			clickPoint($pointArray, 5, 100)

			_Sleep(500)
			ControlSend($hWindow, "", "", "{ESC}")
			_Sleep(100)
			ControlSend($hWindow, "", "", "{ESC}")
			clickPoint($battle_coorContinue, 3, 100)

			clickUntil($pointArray, "catch-success,battle,battle-astromon-full", 500, 100)

			If getLocation() = "battle-astromon-full" Then
				If setLogReplace("Catching astromons... Astromon bag full!", 1) Then Return -1
				logUpdate()
				Return $astromons
			EndIf

			;waiting for success location or battle location
			Local $boolCaught = False
			Switch waitLocation("catch-success,battle", 5000)
				Case "catch-success" ;only shows up for normal astromons, not rares
					$boolCaught = True
				Case "battle"
					If _Sleep(3000) Then Return -1
					_CaptureRegion()

					If checkPixel($battle_pixelUnavailable) = False Then
						$boolCaught = True
					Else
						If setLogReplace("Catching astromons... Could not detect success, checking if caught", 1) Then Return -1
						If ($boolRareAstromon = True) And (isArray(findImage("battle-" & StringLower($strGrade), 100, 5000)) = False) Then $boolCaught = True
					EndIf
			EndSwitch

			If $boolCaught = True Then
				If setLogReplace("Catching astromons... Caught " & $strGrade & "!", 1) Then Return -1
				_ArrayAdd($astromons, $strGrade)
				logUpdate()

				waitLocation("battle,battle-auto", 10000)
				If $boolOneAstromon = False And checkPixel($battle_pixelUnavailable) = False Then ;recursion to catch more astromons
					While checkPixel($battle_pixelUnavailable) = False
						If setLogReplace("Catching astromons... Checking for more astromons", 1) Then Return -1

						If navigate("battle", "catch-mode") = True Then
							Local $catch = catch($varImages, True)
							If UBound($catch) = 0 Then ExitLoop

							_ArrayAdd($astromons, $catch)
						Else
							If waitLocation("battle", 5000) = "" Then
								If setLogReplace("Catching astromons... Could not check for more astromons.", 1) Then Return -1
								ExitLoop
							EndIf
						EndIf

						waitLocation("battle,battle-auto", 10000)
					WEnd
				EndIf
			Else ;not caught
				If setLogReplace("Catching astromons... Failed to catch " & $strGrade & ".", 1) Then Return -1
				_ArrayAdd($astromons, "!" & $strGrade)
			EndIf
		Else ;not found
			If setLogReplace("Catching astromons... Not found.", 1) Then Return -1
			clickUntil($battle_coorCatchCancel, "battle")
		EndIf

		logUpdate()
	EndIf

	Return $astromons
EndFunc


Func findChips()

	Local $astrochipIcon = [700, 285, 0x4D1515]
	
	If checkPixel($astrochipIcon) Then
		If checkPixel($battle_Chips1) Then Return 1
		If checkPixel($battle_Chips2) Then Return 2
		If checkPixel($battle_Chips3) Then Return 3
		Return 0
	EndIf
	Return -1
EndFunc