#cs ----------------------------------------------------------------------------

 Function: catch

 Algorithm for catching a certain astromons

 Parameters:

	varImages - Set of images to search for specific astromons.
	boolLog - To log or not to log catches.
	boolCreateIMG - If not recognized, create image or not.
	boolOneAstromon - Stop after one astromon or not.

 Returns:

	String of type of astromon caught

	On astromon bag full - Returns -1

	On not tried - Returns -2


#ce ----------------------------------------------------------------------------

Func catch($varImages, $boolLog = True, $boolCreateIMG = True, $boolOneAstromon = False, $boolCheckTried = True)
	Local $strCaught = ""
	Local $strAstromonGrade = ""
	Local $boolTried = False

	While True
		While True
			If Not checkLocations("catch-mode") = 1 Then Return ""
			If Not $boolTried Then setLogReplace("Locating astromon...", 1)
			If isArray($varImages) Then ;finding astromon within list
				_CaptureRegion()
				Local $pointArray = findImagesWait($varImages, 3, 100)
			Else
				_CaptureRegion()
				Local $pointArray = findImage($varImages, 100)
			EndIf
			If getLocation() = "battle-astromon-full" Then Return -1

			If isArray($pointArray) = True Then ;if found
				setLogReplace("Locating astromon... Found!", 1)
				$strAstromonGrade = _StringProper(StringRegExpReplace(StringReplace(StringReplace(StringReplace($varImages[$pointArray[2]], "catch-", ""), "battle-", ""), "-", " "), "[0-9]", ""))
				While checkLocations("battle") = 0
					$boolTried = True ;indicate that catching was attempted
					If checkLocations("battle-astromon-full") = 1 Then Return -1
					If checkLocations("battle-end-exp", "battle-sell", "battle-end") = 1 Then Return $strCaught

					If _Sleep(100) Then Return
					clickPoint($pointArray, 1, 0)
				WEnd

				If checkPixel($battle_pixelUnavailable) = False Then ;if there is more astrochips
					$strCaught &= StringMid($strAstromonGrade, 1, 2)
					If $boolLog = True Then setLog("Astromon Caught: " & $strAstromonGrade & "!")
					If $boolOneAstromon Then Return $strCaught ;stops after one catch or no catch

					If $boolLog = True Then setLog("Checking for more astromons..", 1)
					navigate("battle", "catch-mode")
					ExitLoop ;going back to inner loop to check for more astromon
				Else
					If $boolLog = True Then setLog("Checking if caught...", 1)
					If IsArray(findImagesWait($imagesRareAstromon, 10, 100)) Then
						If $boolLog = True Then setLog("Out of astromon chips!", 1)
						If $boolLog = True Then setLog("Missed a " & $strAstromonGrade & ".", 1) ;if missed astromon
					Else
						$strCaught &= StringMid($strAstromonGrade, 1, 2)
						If $boolLog = True Then setLog("Astromon Caught: " & $strAstromonGrade & "!")
						If $boolOneAstromon Then Return $strCaught ;stops after one catch or no catch
					EndIf

					Return $strCaught
				EndIf
			Else
				If ($boolCheckTried = True) And ($boolTried = False) Then ;if astromon was not recognized
					If $boolLog = True Then setLog("Could not recognize astromon.", 1)
					If $boolCreateIMG = True Then
						Local $tempInt = 0
						While(FileExists(@ScriptDir & "/NotRecognized" & $tempInt & ".bmp"))
							$tempInt += 1
						WEnd

						If $boolLog = True Then setLog("Saving to NotRecognized" & $tempInt & ".bmp", 1)
						_CaptureRegion("NotRecognized" & $tempInt & ".bmp")
					EndIf

					Return -2
				EndIf

				setLogReplace("Locating astromon... Not found.", 1)
				While checkLocations("battle") = 0 ;exit catch mode
					If _Sleep(200) Then Return
					clickPoint($battle_coorCatchCancel)
				WEnd
			EndIf

			Return $strCaught
		WEnd
	WEnd
EndFunc