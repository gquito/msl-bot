#cs ----------------------------------------------------------------------------
 Function: waitLocation
 Sleep for a duration until location is met.

 Parameters:
	strLocation - (array/string) Locations to look for; String format: "loc1, loc2, loc3..."
	intWaitDuration - (int) How long to wait in Milliseconds

 Returns:
	If found returns location
	If not found returns empty string
#ce ----------------------------------------------------------------------------

Func waitLocation($strLocation, $intWaitDuration = 3000)
	$startTime = TimerInit()
	While TimerDiff($startTime) < $intWaitDuration
		If _Sleep(100) Then Return
		Local $location = checkLocations($strLocation)
		If Not $location = "" Then Return $location
	WEnd

	Return 0
EndFunc