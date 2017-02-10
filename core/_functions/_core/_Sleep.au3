#cs ----------------------------------------------------------------------------

 Function: _Sleep

 Sleep and checks bot state.

 Parameters:

	intDuration - Duration of sleep in milliseconds

#ce ----------------------------------------------------------------------------

Func _Sleep($intDuration)
	Local $iBegin = TimerInit()
	While TimerDiff($iBegin) < $intDuration
		If $boolRunning = False Then Return True
		Sleep(50)
	WEnd
	Return False
EndFunc