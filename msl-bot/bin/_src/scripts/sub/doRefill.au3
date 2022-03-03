#include-once
Global Const $REFILL_ERROR_INSUFFICIENT = 1
Global Const $REFILL_ERROR_INVALID_LOCATION = 2
Global Const $REFILL_ERROR_LIMIT_REACHED = 3

Global $g_iMaxRefill = Null
Func doRefill($bLimit = True)
	Log_Level_Add("doRefill")

	Local $bOutput = False
	Local $hTimer = TimerInit()

	Local $iError = 0
	Local $iExtended = 0
	While TimerDiff($hTimer) < 10000
		If _Sleep($Delay_Script_Loop) Then ExitLoop
		If $iError Or $bOutput Then ExitLoop

		Local $sLocation = getLocation()
		Switch $sLocation
			Case "refill"
				If $bLimit = True And $g_iMaxRefill > -1 Then
					If isDeclared("Astrogems_Used") = True Then
						If (($Astrogems_Used + 30) > $g_iMaxRefill) Or ($g_iMaxRefill = 0) Then
							Log_Add("Refill limit has been reached.", $LOG_INFORMATION)

							$iError = 3
							ExitLoop
						EndIf
					EndIf
				EndIf

				If $bOutput = False Then
					clickPoint(getPointArg("refill"))
				EndIf
			Case "refill-confirm"
				Local $sRatio = "Limit not set."
				If isDeclared("Astrogems_Used") = True Then
					$Astrogems_Used += 30
					$sRatio = $Astrogems_Used
					If $g_iMaxRefill >= 30 Then
						$sRatio &= "/" & $g_iMaxRefill
					EndIf
				EndIf

				Log_Add("Confirming Refill: " & $sRatio, $LOG_INFORMATION)
				clickPoint(getPointArg("refill-confirm"))
				$bOutput = True
			Case "buy-gem", "buy-gold"
				$bOutput = False
				$iError = 1
			Case Else
				$bOutput = False
				$iError = 2
		EndSwitch
	WEnd

	If $bOutput = True Then 
		If $iExtended = 0 Then
			Cumulative_AddNum("Resource Used (Astrogems)", 30)
		EndIf
		closeWindow()
	EndIf
	
	Log_Add("Refill result: " & $bOutput & " (" & $iExtended & "," & $iError & ")", $LOG_DEBUG)
	Log_Level_Remove()
	Return SetError($iError, $iExtended, $bOutput)
EndFunc