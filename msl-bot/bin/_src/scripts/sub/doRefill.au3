#include-once

Func doRefill()
	Log_Level_Add("doRefill")

	Local $bOutput = 0
	Local $hTimer = TimerInit()
	While TimerDiff($hTimer) < 10000
		If $bOutput <> 0 Or _Sleep(300) Then ExitLoop
		Switch getLocation()
			Case "refill"
				If $bOutput = 0 Then clickPoint(getPointArg("refill"), 3, 50)
			Case "refill-confirm"
				clickPoint(getPointArg("refill-confirm"), 3, 50)
				$bOutput = 1
			Case "buy-gem", "buy-gold"
				$bOutput = -1
			Case Else
				$bOutput = -2
		EndSwitch
	WEnd
	If $bOutput = 1 Then 
		Cumulative_AddNum("Resource Used (Astrogems)", 30)
		closeWindow()
	EndIf
	
	Log_Add("Refill result: " & $bOutput, $LOG_DEBUG)
	Log_Level_Remove()
	Return $bOutput
EndFunc