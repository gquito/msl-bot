#include-once
#include "../../imports.au3"

#cs
	Function: Returns a 2D array of the location of a specified map
	Parameters:
		- $map: String of the map, case sensitive.
	Return:
		- A 2D array: [x, y]
		*On error or not found, returns -1
	Pre-condition:
		- Global variable, $g_aCoorMaps, should be defined. [[MAP, MARK, X-DISPLACE, Y-DISPLACE], [...], [...]]
#ce
Func getMapCoor($map)
	Local $arrMarks = _getMapMarks() ;[["A", 0, 0], [...], [...]]
	Local $pointDisplacement ;Creates final coordination of map with sum of the mark

	;Returns early if there are no marks found
	If UBound($arrMarks) = 0 Then Return -1

	;Checking if $map exists in $coorMaps
	For $i = 0 To UBound($g_aCoorMaps, $UBOUND_ROWS)-1
		If $g_aCoorMaps[$i][0] = $map Then
			;Checking if the mark exists on $arrMarks.
			For $x = 0 To UBound($arrMarks, $UBOUND_ROWS)-1
				Local $myMark = $arrMarks[$x]

				If $g_aCoorMaps[$i][1] = $myMark[0] Then
                    Local $pointDisplacement = [$g_aCoorMaps[$i][2], $g_aCoorMaps[$i][3]]

					ExitLoop(2)
				Else
					ContinueLoop
				EndIf
			Next
		EndIf
	Next

	;Returns early if $map does not exist or $mark does not exist
	If isArray($pointDisplacement) = False Then Return -2

	Local $finalX = $myMark[1] + $pointDisplacement[0]
	Local $finalY = $myMark[2] + $pointDisplacement[1]

	;Returns early if final coordinations are out of bounds.
	If ($finalX < 0) Or ($finalX > $g_aControlSize[0]) Or ($finalY < 0) Or ($finalY > $g_aControlSize[1]) Then
		Return -3
	EndIf

	;Output
	Local $returnPoint = [$finalX, $finalY]
	Return $returnPoint
EndFunc

#cs
	Function: Helper function for getMapCoor. Retrieves an array of visible marks and their points.
	Return:
		- An array of string and point. [[STRING, X, Y], [...], [...]]
		*Returns empty array if nothing is found.
	Pre-condition:
		- Global variable, $g_aImageMarks, must be defined. [STRING, STRING, ...]
#ce
Func _getMapMarks()
	Local $finalArr[0] ;Empty array for marks.

	;Adding marks that are found in map
	For $myMark In $g_aImageMarks
		Local $imageCoor = findImage($myMark, 100)

		;If image found then it adds a mark into $finalArr
		If isArray($imageCoor) Then
			Local $newMark = [$myMark, $imageCoor[0], $imageCoor[1]]
			_ArrayAdd($finalArr, $newMark, 0, default, default, 1) ;Force as single item
		EndIf
	Next

	;Output
	Return $finalArr
EndFunc
