Global $setLogOld = ""

#cs ----------------------------------------------------------------------------

 Function: setLog
 Sets the text for the title of the GUI and Sets Log

#ce ----------------------------------------------------------------------------

Func setLog($strStatus, $option = 0) ;0 is normal, 1 is unimportant, 2 is forced
	If (Not $option = 2) And ($boolRunning = False) Then Return True

	If $iniOutput = 0 And $option = 1 Then Return

	_GUICtrlEdit_AppendText($textOutput, "[" & _NowTime(5) & "] " & $strStatus & @CRLF)
	$setLogOld = GUICtrlRead($textOutput)
	_Sleep(100)

	Return False
EndFunc

#cs ----------------------------------------------------------------------------

 Function: setLogReplace
 Replaces most recent line to a new setlog

#ce ----------------------------------------------------------------------------

Func setLogReplace($strStatus, $option = 0) ;0 is normal, 1 is unimportant, 2 is forced
	If (Not $option = 2) And ($boolRunning = False) Then Return True

	If $iniOutput = 0 And $option = 1 Then Return

	_GUICtrlEdit_SetText($textOutput, "")
	_GUICtrlEdit_AppendText($textOutput, $setLogOld & "[" & _NowTime(5) & "] " & $strStatus & @CRLF)
	_Sleep(100)

	Return False
EndFunc

#cs ----------------------------------------------------------------------------

 Function: logUpdate
 Updates old log to new log

#ce ----------------------------------------------------------------------------

Func logUpdate()
	$setLogOld = GUICtrlRead($textOutput)
EndFunc

