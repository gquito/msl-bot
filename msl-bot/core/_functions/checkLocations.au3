#cs ----------------------------------------------------------------------------
 Function: checkLocations
 Checks if location is one of the elements in the set of location

 Parameters:
	strLoc: An array of location or String of location with format: "loc1, loc2, loc3..."

 Returns:
	If found returns location
	If not found returns empty string
#ce ----------------------------------------------------------------------------

Func checkLocations($strLoc)
	$strLoc = StringStripWS($strLoc, 8)
	If Not isArray($strLoc) Then
		$strLoc = StringSplit($strLoc, ",", 2)
	EndIf

	$currLocation = getLocation()
	For $find In $strLoc
		If $find = $currLocation Then Return $find
	Next

	Return ""
EndFunc