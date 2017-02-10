#cs ----------------------------------------------------------------------------

 Function: catch

 Algorithm for catching a certain astromons

 Parameters:

	varImages - Set of images to search for specific astromons.

 Returns:

	On at least one caught - Returns #Caught

	On astromon bag full - Returns -1


#ce ----------------------------------------------------------------------------

Func catch($varImages, $boolLog = True)
	Local $intCaught = 0

	While True
		While True
			If isArray($varImages) Then
				_CaptureRegion()
				Local $pointArray = findImagesWait($varImages, 3, 100)
			Else
				_CaptureRegion()
				Local $pointArray = findImage($varImages, 100)
			EndIf

			If isArray($pointArray) = True Then

				While Not(getLocation() = "battle")
					If getLocation() = "battle-astromon-full" Then Return -1

					Local $checkCatch = findImages($imagesCatch, 50)
					If isArray($checkCatch) = True Then
						Local $strAstromonGrade = _StringProper(StringRegExpReplace(StringReplace(StringReplace(StringReplace($varImages[$pointArray[2]], "catch-", ""), "battle-", ""), "-", " "), "[0-9]", ""))
						$intCaught += 1
						If $boolLog = True Then setLog("*Caught: " & $strAstromonGrade & "!")
						waitLocation("battle")
					EndIf

					If _Sleep(100) Then Return
					clickPoint($pointArray, 1, 0)
				WEnd

				If checkPixel($battle_pixelUnavailable) = False Then
					navigate("battle", "catch-mode")
					ExitLoop
				Else
					If $intCaught = 0 Then _CaptureRegion("MSLBot\data\catch\" & StringReplace(_NowTime(), ":", ".") & ".bmp")
				EndIf
			Else
				While Not(getLocation() = "battle")
					If _Sleep(200) Then Return
					clickPoint($battle_coorCatchCancel)
				WEnd

				If isArray(findImagesWait($imagesRareAstromon, 3, 100)) = True Then MsgBox(0, "MSLBot Catch", "Did not recognize astromon!")
			EndIf

			Return $intCaught
		WEnd
	WEnd
EndFunc