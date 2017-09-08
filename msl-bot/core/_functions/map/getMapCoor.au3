#cs
	Function: getMapCoor
		- Returns a 2D array of the location of a specified map

	Parameters:
		- $map: String of the map, case sensitive.

	Return:
		- A 2D array: [x, y]
		*On error or not found, returns -1

	Pre-condition:
		- Global variable, $coorMaps, should be defined. [[MAP, MARK, X-DISPLACE, Y-DISPLACE], [...], [...]]
#ce

Func getMapCoor($map)
	;Returns if not in map
	If getLocation() <> "map" Then Return -1

	Local $arrMarks = _getMapMarks() ;[["A", 0, 0], [...], [...]]
	Local $pointDisplacement[2] ;Creates final coordination of map with sum of the mark

	;Returns early if there are no marks found
	If UBound($arrMarks) = 0 Then Return -1

	;Checking if $map exists in $coorMaps
	For $i = 0 To UBound($coorMaps)-1
		If $coorMaps[$i][0] = $map Then
			;Checking if the mark exists on $arrMarks.
			For $x = 0 To UBound($arrMarks)-1
				Local $myMark = $arrMarks[$x]

				If $coorMaps[$i][1] = $myMark[0] Then
					$pointDisplacement[0] = $coorMaps[$i][2]
					$pointDisplacement[1] = $coorMaps[$i][3]

					ExitLoop(2)
				Else
					ContinueLoop
				EndIf
			Next
		EndIf
	Next

	;Returns early if $map does not exist or $mark does not exist
	If $pointDisplacement[0] = "" Then Return -1

	Local $finalX = $myMark[1] + $pointDisplacement[0]
	Local $finalY = $myMark[2] + $pointDisplacement[1]

	;Returns early if final coordinations are out of bounds.
	If ($finalX < 0) Or ($finalX > 800) Or ($finalY < 0) Or ($finalY > 552) Then
		Return -1
	EndIf

	;Output
	Local $returnPoint = [$finalX, $finalY]
	Return $returnPoint
EndFunc

#cs
	Function: _getMapMarks
		- Helper function for getMapCoor. Retrieves an array of visible marks and their points.

	Return:
		- An array of string and point. [[STRING, X, Y], [...], [...]]
		*Returns empty array if nothing is found.

	Pre-condition:
		- Global variable, $imageMarks, must be defined. [STRING, STRING, ...]
#ce

Func _getMapMarks()
	Local $finalArr[0] ;Empty array for marks.

	;Adding marks that are found in map
	For $myMark In $imageMarks
		Local $imageCoor = findImage($myMark, 50)

		;If image found then it adds a mark into $finalArr
		If isArray($imageCoor) Then
			Local $newMark = [$myMark, $imageCoor[0], $imageCoor[1]]
			_ArrayAdd($finalArr, $newMark, 0, default, default, 1) ;Force as single item
		EndIf
	Next

	;Output
	Return $finalArr
EndFunc
