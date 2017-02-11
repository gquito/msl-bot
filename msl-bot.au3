;Initialize Bot
Global $botVersion = IniRead(@ScriptDir & "/config.ini", "general", "version", "")
Global $botName = IniRead(@ScriptDir & "/config.ini", "general", "title", "MSL Bot")
Global $strScript = ""
Global $strconfig = ""

#include "core/imports.au3"
#include "core/gui.au3"

GUICtrlSetState($chkBackground, IniRead(@ScriptDir & "/config.ini", "general", "background-mode", 1)) 
GUICtrlSetState($chkOutput, IniRead(@ScriptDir & "/config.ini", "general", "output-all-process", 1)) 
GUICtrlSetData($cmbLoad, StringReplace(IniRead(@ScriptDir & "/config.ini", "general", "scripts", "There are no scripts available."), ",", "|"))

While 1
	Sleep(100)
WEnd

Func frmMainClose()
	Exit 0
EndFunc

Func btnClearClick()

EndFunc

Func btnDebugTestCodeClick()

EndFunc

Func cmbLoadClick()
	;clearing data
	GUICtrlSetData($listScript, "")

	;process of getting info
	$strScript = GUICtrlRead($cmbLoad)

	Dim $arrayKeys = StringSplit(IniRead(@ScriptDir & "/config.ini", $strScript, "keys", ""), ",", 2)
	$strConfig = ""
	For $key In $arrayKeys
		$strConfig &= $key & "=" & IniRead(@ScriptDir & "/config.ini", $strScript, $key, "???") & "|"
	Next

	;final
	GUICtrlSetData($listScript, $strConfig)
EndFunc

Func btnEditClick()
	;initial variables
	Dim $strRaw = GUICtrlRead($listScript)
	Dim $arrayRaw = StringSplit($strRaw, "=", 2)

	If UBound($arrayRaw) = 0 Then ;check if no config selected
		MsgBox($botName & " " & $botVersion, 0, "No config selected.")
		Return 0
	EndIf
	
	;getting keys and values to modify
	Dim $key = $arrayRaw[0]
	Dim $value = $arrayRaw[1]

	$value = InputBox($botName & " " & $botVersion, "Enter new value for '" & $key & "'")
	If $value = "" Then $value = $arrayRaw[1]

	IniWrite(@ScriptDir & "/config.ini", $strScript, $key, $value)	;write to config file

	GUICtrlSetData($listScript, "") ;clear data
	GUICtrlSetData($listScript, StringReplace($strConfig, $strRaw, $key & "=" & $value)) ;input new data
EndFunc

Func btnRunClick()

EndFunc

Func btnAdjustClick()

EndFunc

Func chkBackgroundClick()

EndFunc

Func chkDebugFindImageClick()

EndFunc

Func chkDebugLocationClick()

EndFunc

Func chkOutputClick()

EndFunc