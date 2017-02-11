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

;function: btnClearClick()
;-Clears the output.
;-author: GkevinOD (2017)
Func btnClearClick()
	GUICtrlSetData($textOutput, "")
EndFunc

;function: btnDebugTestCodeClick
;-Runs a line of code and performs it.
;pre:
;	-must be a call to function
;	-no script must be running
;-author: GkevinOD (2017)
Func btnDebugTestCodeClick()
	;running line of code using execute
	Execute(GUICtrlRead($textDebugTestCode))
EndFunc

;function: cmbLoadClick
;-Load a script from the list of scripts written in the config
;pre:
;	-configs must be set
;	-no script must be running
;author: GkevinOD (2017)
Func cmbLoadClick()
	;pre
	If GUICtrlRead($cmbLoad) = "Select a script.." Then Return

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

;functon: btnEditClick
;-Modify a config of the selected config from the $listScript
;pre:
;	-something selected for $listScript
;	-no script must be running
;author: GkevinOD (2017)
Func btnEditClick()
	;initial variables
	Dim $strRaw = GUICtrlRead($listScript)
	Dim $arrayRaw = StringSplit($strRaw, "=", 2)

	If UBound($arrayRaw) = 1 Then ;check if no config selected
		MsgBox(0, $botName & " " & $botVersion, "No config selected.")
		Return
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

;function: chkBackgroundClick()
;-Overwrites config.ini file and updates new data.
;author: GkevinOD (2017)
Func chkBackgroundClick()
	IniWrite(@ScriptDir & "/config.ini", "general", "background-mode"), GUICtrlGetState($chkBackGround))
EndFunc

;function: chkOutputClick()
;-Overwrites config.ini file and updates new data.
;author: GkevinOD (2017)
Func chkOutputClick()
	IniWrite(@ScriptDir & "/config.ini", "general", "output-all-process"), GUICtrlGetState($chkBackGround))
EndFunc

Func chkDebugFindImageClick()

EndFunc

Func chkDebugLocationClick()

EndFunc

