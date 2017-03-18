#cs ----------------------------------------------------------------------------

 Function: sellGems

 Select all unwanted gems and sell them.

 Parameters:

	arraySet - Set of images corresponding to gem grade.

 Returns:

	on error - Returns -1

	on sell - Returns # of Gems Sold

#ce ----------------------------------------------------------------------------

Func sellGems($arraySet)
	If checkLocations("manage") = 1 Then
		Local $gemCounter = 0

		While isArray(findImages($arraySet, 100)) = True
			For $imageGem In $arraySet
				Local $arrayGem = findImage($imageGem, 100)
				While isArray($arrayGem) = True
					$gemCounter += 1
					clickPoint($arrayGem, 1, 100)
					_CaptureRegion()
					$arrayGem = findImage($arraySet, 100)
				WEnd
			Next

			If $gemCounter > 0 Then
				clickPoint($village_coorSell)
				clickPoint($village_coorSellConfirm)
			EndIf

			waitLocation("manage")
			_CaptureRegion()
		WEnd

		Return $gemCounter
	EndIf

	Return -1
EndFunc