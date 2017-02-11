Global $setLogOld = ""

#cs ----------------------------------------------------------------------------

 Function: setLog

 Sets the text for the title of the GUI and Sets Log

#ce ----------------------------------------------------------------------------

Func setLog($strStatus, $option = 0) ;0 is normal, 1 is unimportant
	If GUICtrlRead($chkOutput) = 1 Then ;check for output all
		If $option = 1 Then Return
	EndIf
	
	_GUICtrlEdit_AppendText($textOutput, "[" & _NowTime(5) & "] " & $strStatus & @CRLF)
	$setLogOld = GUICtrlRead($textOutput)
	_Sleep(100)
EndFunc

#cs ----------------------------------------------------------------------------

 Function: setLogReplace

 Replaces most recent line to a new setlog

#ce ----------------------------------------------------------------------------

Func setLogReplace($strStatus)
	_GUICtrlEdit_SetText($textOutput, "")
	_GUICtrlEdit_AppendText($textOutput, $setLogOld & "[" & _NowTime(5) & "] " & $strStatus & @CRLF)
	_Sleep(100)
EndFunc