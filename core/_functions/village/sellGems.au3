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
		Local $x1 = 317
		Local $y1 = 177
		Local $x2 = 380
		Local $y2 = 241

		_CaptureRegion()
		While isArray(findImages($arraySet, 100)) = True
			For $b = 0 To 136 Step 66
				For $a = 0 To 460 Step 66
					_CaptureRegion("", $x1+$a, $y1+$b, $x2+$a, $y2+$b)
					If isArray(findImages($arraySet, 100)) = True Then
						$gemCounter += 1
						Local $point[2]
						$point[0] = $x1+20+$a
						$point[1] = $y1+20+$b

						clickPoint($point, 1, 100)
					Else
						ExitLoop(2)
					EndIf
				Next
			Next

			If $gemCounter > 0 Then
				clickPoint($village_coorSell)
				clickPoint($village_coorSellConfirm)
			EndIf
			_CaptureRegion()
		WEnd

		Return $gemCounter
	EndIf

	Return -1
EndFunc