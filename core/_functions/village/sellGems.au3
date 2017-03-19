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
		Local $foundGem = findImages($arraySet, 100)
		While isArray($foundGem) = True
			clickPoint(findImages($arraySet, 100), 1, 100)

			clickPoint($village_coorSell)
			clickPoint($village_coorSellConfirm)
			$gemCounter += 1

			waitLocation("manage")
			_CaptureRegion()
			$foundGem = findImages($arraySet, 100)
		WEnd

		Return $gemCounter
	EndIf

	Return -1
EndFunc