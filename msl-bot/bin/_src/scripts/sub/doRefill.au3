#include-once
#include "../../imports.au3"

#cs 
    Function: Peform refill
    Returns: 1 on success, error code on fail.
        Error codes:
        -1: Took too long to refill.
        -2: Not enough gems for refill
#ce
Func doRefill($bSkip = False, $sScript = "")
	Local $iOutput = $REFILL_TIMEOUT
    Log_Level_Add("doRefill")
    Log_Add("Refilling energy.")
    Local $iResult = 0
	If (checkCanRefill($iResult, $bSkip)) Then
		While True
			If (Not(isLocation("refill"))) Then ExitLoop

			;refill only once and closes the window
			If (clickUntil(getPointArg("refill"), "isLocation", "refill-confirm")) Then
				Local $t_hTimer = TimerInit()
				clickWhile(getPointArg("refill-confirm"), "isLocation", "refill-confirm")

				;Checks for no gems left or success
				Switch getLocation()
					Case "refill"
						Stat_Increment($g_aStats, "Astrogems spent", 30)
						Local $t_hTimer = TimerInit()
						While isLocation("refill") And TimerDiff($t_hTimer) < 5000
							If (isLocation("buy-gold,buy-gem")) Then ContinueCase
							If (Not(closeWindow())) Then navigate("map")
						Wend

						If (Not(enterBattle())) Then 
							If (isLocation("map-gem-full,battle-gem-full")) Then 
								$iOutput = 1
								ExitLoop
							EndIf
							If (isLocation("buy-gold,buy-gem")) Then ContinueCase
						EndIf
					Case "buy-gold", "buy-gem"
						Log_Add("Not enough gems for refill.", $LOG_ERROR)
						$iOutput = $REFILL_NOGEMS
						ExitLoop
					Case "refill-confirm", "popup-window"
						Log_Add("Could not confirm refill.", $LOG_ERROR)
						$iOutput = $REFILL_TIMEOUT
						ExitLoop
				EndSwitch
			EndIf
			
			$iOutput = 1
			ExitLoop
		WEnd

		If ($iOutput = $REFILL_NOGEMS) Then
			Log_Add("No gems left. Ending Script", $LOG_INFORMATION)
		Else
			Data_Increment("Refill", 30)
			Data_Increment("Runs")
			Data_Increment("Victory")

			If ($sScript = "Farm_Golem") Then Stat_Increment($g_aStats, "Golem runs")

			Log_Add("Refilled energy " & Data_Get("Refill"), $LOG_INFORMATION)
		EndIf
	Else
		If ($iResult = 1) Then 
			Log_Add("Refilled at max. Ending Script", $LOG_INFORMATION)
			$iOutput = -3
		EndIf
	EndIf
    Log_Add("Refill energy result: " & getRefillOutput($iOutput), $LOG_DEBUG)
    Log_Level_Remove()
    Return $iOutput
EndFunc

Func getRefillOutput($iOutput)
	Switch $iOutput
	Case -3
		Return "Refill at max."
	Case -2
		Return "Not enough gems"
	Case -1
		Return "Refill took too long"
	Case Else
		Return "Refilled"
	EndSwitch
EndFunc

Func checkCanRefill(ByRef $iOutResult, $bSkip = False)
	If ($bSkip) Then Return True

	Local $sDataName = "Refill"
	Local $iDataType = Data_Get_Type($sDataName)
	If ($iDataType <> -1) Then
		Switch $iDataType
			Case $DATA_NUMBER
				Return True
			Case $DATA_RATIO
				Local $dRefill = Data_Get($sDataName, True)
				If (isArray($dRefill)) Then
					If ($dRefill[1] = 0 Or ($dRefill[1] <> 0 And Data_Get_Ratio($sDataName) < 1)) Then Return True
					If (Data_Get_Ratio($sDataName) >= 1) Then $iOutResult = 1
				EndIf
		EndSwitch
	EndIf

	Return False
EndFunc