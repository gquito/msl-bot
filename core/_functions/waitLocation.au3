#cs ----------------------------------------------------------------------------

 Function: waitLocation

 Sleep for a duration until location is met.

 Parameters:

	strLocation - Location to wait for.

	intWaitDuration - Duration to wait for.

 Returns:

	On location found - Returns 1

	On location not found - Returns 0

 See Also:

	<getLocation>
#ce ----------------------------------------------------------------------------

Func waitLocation($strLocation, $intWaitDuration = 2000)
	$startTime = TimerInit()
	While TimerDiff($startTime) < $intWaitDuration
		If _Sleep(100) Then Return
		If StringInStr($strLocation, getLocation()) Then Return 1
	WEnd

	Return 0
EndFunc