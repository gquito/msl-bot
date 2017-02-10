#cs ----------------------------------------------------------------------------

 Function: recordGem

 Parameters:

	strName - Text file name to save data to.

	arrayData - Array of gem data.

 Returns:

	On success - Return 1

	On error - Returns 0

#ce ----------------------------------------------------------------------------

Func recordGem($strName, $arrayData)
	Local $strData = $arrayData[0] & "," & $arrayData[1] & "," & $arrayData[2] & "," & $arrayData[3] & $arrayData[4] & "," & $arrayData[5]
	Return FileWriteLine(@ScriptDir & "\MSLBot\data\" & $strName & ".txt", $strData)
EndFunc