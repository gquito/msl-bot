#cs ----------------------------------------------------------------------------

 Function: catch

 Algorithm for catching a certain astromons

 Parameters:

	varImages - Set of images to search for specific astromons.

 Returns:

	String of type of astromon caught

	On astromon bag full - Returns -1


#ce ----------------------------------------------------------------------------

Func catch($varImages, $boolLog = True)
	Local $strCaught = ""
	Local $strAstromonGrade = ""
	Local $boolTried = False

	While True
		While True
			If Not $boolTried Then setLogReplace("Locating astromon...")
			If isArray($varImages) Then ;finding astromon within list
				_CaptureRegion()
				Local $pointArray = findImagesWait($varImages, 3, 100)
			Else
				_CaptureRegion()
				Local $pointArray = findImage($varImages, 100)
			EndIf
		
			If isArray($pointArray) = True Then ;if found
				setLog("Found the astromon, attempting to catch...", 1)
				While Not(getLocation() = "battle") 
					$boolTried = True ;indicate that catching was attempted
					If getLocation() = "battle-astromon-full" Then Return -1

					Local $checkCatch = findImages($imagesCatch, 50) ;checking if caught
					If isArray($checkCatch) = True Then ;if caught
						$strAstromonGrade = _StringProper(StringRegExpReplace(StringReplace(StringReplace(StringReplace($varImages[$pointArray[2]], "catch-", ""), "battle-", ""), "-", " "), "[0-9]", ""))
						$strCaught &= $strAstromonGrade

						If $boolLog = True Then setLog("*Caught: " & $strAstromonGrade & "!")
						waitLocation("battle")
					EndIf

					If _Sleep(100) Then Return
					clickPoint($pointArray, 1, 0)
				WEnd

				If checkPixel($battle_pixelUnavailable) = False Then ;if there is more astrochips
					navigate("battle", "catch-mode")
					ExitLoop ;going back to inner loop to check for more astromon
				Else
					setLog("No more astromon chips!", 1)
					Return $strCaught
				EndIf
			Else
				If $boolTried = False Then ;if astromon was not recognized
					Local $tempInt = 0
					While(FileExists(@ScriptDir & "/NotRecognized" & $tempInt & ".bmp"))
						$tempInt += 1
					WEnd

					setLog("Could not recognize astromon."
					setLog("Saving to NotRecognized" & $tempInt & ".bmp")
					_CaptureRegion("NotRecognized" & $tempInt & ".bmp")

					Return ""
				EndIf

				If $strCaught = "" Then setLog("Missed a " & $strAstromonGrade & ".") ;if missed astromon

				While Not(getLocation() = "battle") ;exit catch mode
					If _Sleep(200) Then Return
					clickPoint($battle_coorCatchCancel)
				WEnd
			EndIf

			Return $strCaught
		WEnd
	WEnd
EndFunc