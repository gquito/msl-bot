#cs ----------------------------------------------------------------------------

 Function: checkLocations

 Checks if location is one of the elements in the set of location

 Parameters:

	strLoc[1-10] - Set of string of locations.

 Returns:

	If found - Returns 1

	If not found - Returns 0

#ce ----------------------------------------------------------------------------

Func checkLocations($strLoc1, $strLoc2 = "", $strLoc3 = "", $strLoc4 = "", $strLoc5 = "", $strLoc6 = "", $strLoc7 = "", $strLoc8 = "", $strLoc9 = "", $strLoc10 = "")
	;traverse through parameters
	For $intLoc = 1 To 10
		If getLocation() = Eval("strLoc" & $intLoc) Then Return 1
		If Eval("strLoc" & $intLoc) = "" Then Return 0
	Next
	Return 0
EndFunc