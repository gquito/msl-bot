#cs ----------------------------------------------------------------------------

 Function: sellGems

 Select all unwanted gems and sell them.

 Parameters:

	arraySet - Set of String corresponding to gem grade.

 Returns:

	on sell - Returns 1

#ce ----------------------------------------------------------------------------

Func sellGems($arraySet)
	If getLocation() = "manage" Then
		For $grade in $arraySet
			Local $coorPoint = StringSplit(Eval("village_coor" & $grade & "Star"), ",", 2)
			clickPoint($coorPoint)
		Next

		clickPoint($village_coorSell)
		clickPoint($village_coorSellConfirm)

		Return 1
	EndIf
EndFunc