Global $setLogOld = ""

#cs ----------------------------------------------------------------------------

 Function: setLog

 Sets the text for the title of the GUI and Sets Log

#ce ----------------------------------------------------------------------------

Func setLog($strStatus)
	WinSetTitle(@GUI_WinHandle, "", "MSLBot v3 - " & $strStatus)
	_GUICtrlEdit_AppendText($textOutput, "[" & _NowTime(5) & "] " & $strStatus & @CRLF)
	$setLogOld = GUICtrlRead($textOutput)
	If _Sleep(100) Then Return True
EndFunc

#cs ----------------------------------------------------------------------------

 Function: setLogReplace

 Replaces most recent line to a new setlog

#ce ----------------------------------------------------------------------------

Func setLogReplace($strStatus)
	WinSetTitle(@GUI_WinHandle, "", "MSLBot v3 - " & $strStatus)
	_GUICtrlEdit_SetText($textOutput, "")
	_GUICtrlEdit_AppendText($textOutput, $setLogOld & "[" & _NowTime(5) & "] " & $strStatus & @CRLF)
	If _Sleep(100) Then Return True
EndFunc