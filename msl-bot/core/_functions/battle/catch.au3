#cs ----------------------------------------------------------------------------
 Function: catch
 Algorithm for catching a certain astromons

 Parameters:
	varImages - Set of images to search for specific astromons.
	boolOneAstromon - Stop after one astromon.

 Returns:
	Array with format: ["!Miseed", "Caught", "Caught"]

#ce ----------------------------------------------------------------------------

Func catch($varImages, $boolOneAstromon = False)
	Local $astromons[0]
	If getLocation() = "catch-mode" Then
		If setLogReplace("Catching astromons... Locating", 1) Then Return -1
		If isArray($varImages) Then ;finding astromon within list
			Local $pointArray = findImages($varImages, 100, 1000, 0, 263, 800, 473)
		Else
			Local $pointArray = findImage($varImages, 100, 1000, 0, 263, 800, 473)
		EndIf

		If isArray($pointArray) = True Then ;found
			Local $strGrade = _StringProper(StringRegExpReplace($pointArray[3], ".*catch-(.+)(\D)(\d+?|\d?)\.bmp", "$1$2"))
			If setLogReplace("Catching astromons... Found " & $strGrade & "!", 1) Then Return -1
			$pointArray[1] -= 50

			;catching astromons
			clickUntil($pointArray, "unknown", 500, 100)

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
				Case "catch-success"
					$boolCaught = True
				Case "battle" ; This is for when the script cannot detect the success banner when caught
					If checkPixel($battle_pixelUnavailable) = False Then
						$boolCaught = True
					Else
						If setLogReplace("Catching astromons... Could not detect success, checking if caught", 1) Then Return -1
						If isArray(findImages("battle-" & StringLower($strGrade), 100, 3000)) Then $boolCaught = True
					EndIf
			EndSwitch

			If $boolCaught = True Then
				If setLogReplace("Catching astromons... Caught " & $strGrade & "!", 1) Then Return -1
				_ArrayAdd($astromons, $strGrade)
				logUpdate()

				waitLocation("battle", 10000)
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

	waitLocation("battle", 10000)
	Return $astromons
EndFunc