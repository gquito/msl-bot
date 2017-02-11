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
	If(GUICtrlGetState($chkBackGround) = 80) Then
		IniWrite(@ScriptDir & "/config.ini", "general", "background-mode", 1)
	Else
		IniWrite(@ScriptDir & "/config.ini", "general", "background-mode", 0)
	EndIf
EndFunc

;function: chkOutputClick()
;-Overwrites config.ini file and updates new data.
;author: GkevinOD (2017)
Func chkOutputClick()
	If(GUICtrlGetState($chkOutput) = 80) Then
		IniWrite(@ScriptDir & "/config.ini", "general", "output-all-process", 1)
	Else
		IniWrite(@ScriptDir & "/config.ini", "general", "output-all-process", 0)
	EndIf
EndFunc

;function: chkDebugFindImageClick()
;-Intervals of 2 seconds, tries to find image within bluestacks window
;pre:
;	-must not have script running
;	-image file exist
;post:
;	-edit the lblDebugFindImage to result
;author: GkevinOD (2017)
Func chkDebugFindImageClick()
	While(GUICtrlRead($chkDebugFindImage) = 1) ;if it is checked
		Dim $strImage = GUICtrlRead($textDebugImage)

		;first check if file exist
		If Not FileExists($strImageDir & $strImage) Then
			GUICtrlSetData($lblDebugImage, "Found: 0")
			Return
		EndIf

		;process
		_CaptureRegion()
		Dim $arrayPoints = findImage(StringReplace($strImage, ".bmp", ""))

		GUICtrlSetData($lblDebugImage, "Found: " & $arrayPoints[0] & ", " & $arrayPoints[1])
		_Sleep(2000)
	WEnd
EndFunc

Func chkDebugLocationClick()

EndFunc

