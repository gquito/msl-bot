#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\..\favicon.ico
#AutoIt3Wrapper_Outfile=msl-bot v1.7.exe
#AutoIt3Wrapper_UseX64=n
#AutoIt3Wrapper_Res_Description=An open-sourced Monster Super League bot
#AutoIt3Wrapper_Res_Fileversion=1.7.6.0
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

;Initialize Bot
Global $botVersion = IniRead(@ScriptDir & "/config.ini", "general", "version", "")
Global $botVersionComplex = IniRead(@ScriptDir & "/config.ini", "general", "version-complex", "")
Global $botName = IniRead(@ScriptDir & "/config.ini", "general", "title", "MSL Bot")
Global $arrayScripts = StringSplit(IniRead(@ScriptDir & "/config.ini", "general", "scripts", ""), ",", 2)

;defining globals
Global $strScript = "" ;script section
Global $strConfig = "" ;all keys

Global $iniBackground = IniRead(@ScriptDir & "/config.ini", "general", "background-mode", 1) ;checkbox, declare first to remove warning
Global $iniRealMouse =  IniRead(@ScriptDir & "/config.ini", "general", "real-mouse-mode", 1);^
Global $iniOutput = IniRead(@ScriptDir & "/config.ini", "general", "output-all-process", 1);^

#include "core/imports.au3"
#include "core/gui.au3"

_GDIPlus_Startup()
GUICtrlSetData($lblVersion, "Current version: " & $botVersionComplex)
GUICtrlSetData($cmbLoad, StringReplace(IniRead(@ScriptDir & "/config.ini", "general", "scripts", "There are no scripts available."), ",", "|"))

Dim $arrayKeys = StringSplit(IniRead(@ScriptDir & "/config.ini", "general", "keys", ""), ",", 2)
Dim $generalConfig = ""
For $key In $arrayKeys
	$generalConfig &= $key & "=" & IniRead(@ScriptDir & "/config.ini", "general", $key, "???") & "|"
Next
GUICtrlSetData($listConfig, $generalConfig)

;importing scripts
#include "script/imports.au3"

;Hotkeys =====================================
HotKeySet("{END}", "hotkeyStopBot")
HotKeySet("{F6}", "debugPoint1")
HotKeySet("{F7}", "debugPoint2")

Func debugPoint1()
	$hControl = ControlGetHandle("BlueStacks App Player", "", "[CLASS:BlueStacksApp; INSTANCE:1]")

	$pointDebug1[0] = MouseGetPos(0) - WinGetPos($hControl)[0]
	$pointDebug1[1] = MouseGetPos(1) - WinGetPos($hControl)[1]
	If $pointDebug1[0] > 800 Or $pointDebug1[0] < 0 Or $pointDebug1[1] > 600 Or $pointDebug1[1] < 0 Then
		$pointDebug1[0] = "?"
		$pointDebug1[1] = "?"
	EndIf

	GUICtrlSetData($lblDebugCoordinations, "F6: (" & $pointDebug1[0] & ", " & $pointDebug1[1] & ") | F7: (" & $pointDebug2[0] & ", " & $pointDebug2[1] & ")")
EndFunc

Func debugPoint2()
	$hControl = ControlGetHandle("BlueStacks App Player", "", "[CLASS:BlueStacksApp; INSTANCE:1]")

	$pointDebug2[0] = MouseGetPos(0) - WinGetPos($hControl)[0]
	$pointDebug2[1] = MouseGetPos(1) - WinGetPos($hControl)[1]
	If $pointDebug2[0] > 800 Or $pointDebug2[0] < 0 Or $pointDebug2[1] > 600 Or $pointDebug2[1] < 0 Then
		$pointDebug2[0] = "?"
		$pointDebug2[1] = "?"
	EndIf

	GUICtrlSetData($lblDebugCoordinations, "F6: (" & $pointDebug1[0] & ", " & $pointDebug1[1] & ") | F7: (" & $pointDebug2[0] & ", " & $pointDebug2[1] & ")")
EndFunc

Func hotkeyStopBot()
	$boolRunning = False
	GUICtrlSetData($btnRun, "Start")
EndFunc

;main loop
While True
	If $boolRunning = True Then
		If Not $strScript = "" Then ;check if script is set
			Call(IniRead(@ScriptDir & "/config.ini", $strScript, "function", ""))
			If @error = 0xDEAD And @extended = 0xBEEF Then MsgBox($MB_OK, $botName & " " & $botVersion, "Script function does not exist.")
			$boolRunning = False
			GUICtrlSetData($btnRun, "Start")
		Else
			MsgBox($MB_OK, $botName & " " & $botVersion, "Load a script before starting.")
			$boolRunning = False
			GUICtrlSetData($btnRun, "Start")
		EndIf
	EndIf
	Sleep(10)
WEnd

;function: btnRunClick
Func btnRunClick()
	$hWindow = WinGetHandle("BlueStacks App Player")
	$hControl = ControlGetHandle("BlueStacks App Player", "", "[CLASS:BlueStacksApp; INSTANCE:1]")

	If $boolRunning = False Then ;starting bot
		If $iniRealMouse = 1 Then MsgBox($MB_ICONINFORMATION, $botName & " " & $botVersion, "You have real mouse on! You will not be able to use your mouse. To stop script press End key.")
		$boolRunning = True

		GUICtrlSetData($btnRun, "Stop")
	Else ;ending bot
		$boolRunning = False

		GUICtrlSetData($btnRun, "Start")
	EndIf
EndFunc

;function: frmMainClose
;-Exits application and saves the log
;author: GkevinOD (2017)
Func frmMainClose()
	Dim $strOutput = GUICtrlRead($textOutput)
	If Not $strOutput = "" Then FileWrite(@ScriptDir & "/core/data/logs/" & StringReplace(_NowDate(), "/", "."), $strOutput)
	_GDIPlus_Shutdown()
	Exit 0
EndFunc

;function: btnClearClick()
;-Clears the output and saves it to a file.
;author: GkevinOD (2017)
Func btnClearClick()
	Dim $strOutput = GUICtrlRead($textOutput)
	If Not $strOutput = "" Then FileWrite(@ScriptDir & "/core/data/logs/" & StringReplace(_NowDate(), "/", "."), $strOutput)
	GUICtrlSetData($textOutput, "")
EndFunc

;function: btnDebugTestCodeClick
;-Runs a line of code and performs it.
;pre:
;	-must be a call to function
;	-no script must be running
;author: GkevinOD (2017)
Func btnDebugTestCodeClick()
	;running line of code using execute
	$boolRunning = True
	Execute(GUICtrlRead($textDebugTestCode))
	$boolRunning = False
EndFunc

;functon: btnConfigEdit
;-Modify a config of the general config
;pre:
;	-no script must be running
;author: GkevinOD (2017)
Func btnConfigEdit()
	;initial variables
	Dim $strRaw = GUICtrlRead($listConfig)
	Dim $arrayRaw = StringSplit($strRaw, "=", 2)

	If UBound($arrayRaw) = 1 Then ;check if no config selected
		MsgBox(0, $botName & " " & $botVersion, "No config selected.")
		Return
	EndIf

	;getting keys and values to modify
	Dim $key = $arrayRaw[0]
	Dim $value = "!" ;temp value
	Dim $boolPass = False ;if meets restriction

	Dim $rawRestrictions = IniRead(@ScriptDir & "/config.ini", "general", $key & "-restrictions", "")
	If Not $rawRestrictions = "" Then
		Dim $restrictions = StringSplit($rawRestrictions, ",", 2)

		While $value = "!"
			$value = InputBox($botName & " " & $botVersion, "Enter new value for '" & $key & "'" & @CRLF & "You are limited to: " & StringReplace($rawRestrictions, ",", ", "))
			If $value = "" Then $value = $arrayRaw[1]

			For $element In $restrictions
				If $element = $value Then ExitLoop(2)
			Next
			$value = "!"
		WEnd
	Else
		$value = InputBox($botName & " " & $botVersion, "Enter new value for '" & $key & "'")
		If $value = "" Then $value = $arrayRaw[1]
	EndIf

	;overwrite file
	IniWrite(@ScriptDir & "/config.ini", "general", $key, $value)	;write to config file

	Dim $arrayKeys = StringSplit(IniRead(@ScriptDir & "/config.ini", "general", "keys", ""), ",", 2)
	Dim $generalConfig = ""
	For $key In $arrayKeys
		$generalConfig &= $key & "=" & IniRead(@ScriptDir & "/config.ini", "general", $key, "???") & "|"
	Next

	$iniBackground = IniRead(@ScriptDir & "/config.ini", "general", "background-mode", 1) ;checkbox, declare first to remove warning
	$iniRealMouse =  IniRead(@ScriptDir & "/config.ini", "general", "real-mouse-mode", 1);^
	$iniOutput = IniRead(@ScriptDir & "/config.ini", "general", "output-all-process", 1);^

	GUICtrlSetData($listConfig, "")
	GUICtrlSetData($listConfig, $generalConfig)
EndFunc

;function: cmbLoadClick
;-Load a script from the list of scripts written in the config
;pre:
;	-configs must be set
;	-no script must be running
;author: GkevinOD (2017)
Func cmbLoadClick()
	;pre
	If GUICtrlRead($cmbLoad) = "Select a script.." Then
		GUICtrlSetData($listScript, "") ;reset list
		Return
	EndIf

	;clearing data
	GUICtrlSetData($listScript, "")

	;process of getting info
	$strScript = GUICtrlRead($cmbLoad)
	If $strScript = "null" Then $strScript = ""

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
	Dim $value = "!" ;temp value
	Dim $boolPass = False ;if meets restriction

	Dim $rawRestrictions = IniRead(@ScriptDir & "/config.ini", $strScript, $key & "-restrictions", "")
	If Not $rawRestrictions = "" Then
		Dim $restrictions = StringSplit($rawRestrictions, ",", 2)

		While $value = "!"
			$value = InputBox($botName & " " & $botVersion, "Enter new value for '" & $key & "'" & @CRLF & "You are limited to: " & StringReplace($rawRestrictions, ",", ", "))
			If $value = "" Then $value = $arrayRaw[1]

			For $element In $restrictions
				If $element = $value Then ExitLoop(2)
			Next
			$value = "!"
		WEnd
	Else
		$value = InputBox($botName & " " & $botVersion, "Enter new value for '" & $key & "'")
		If $value = "" Then $value = $arrayRaw[1]
	EndIf

	;overwrite file
	IniWrite(@ScriptDir & "/config.ini", $strScript, $key, $value)	;write to config file

	cmbLoadClick()
EndFunc

;function: chkDebugFindImageClick()
;-Intervals of 1/2 seconds, tries to find image within bluestacks window
;pre:
;	-must not have script running
;	-image file exist
;post:
;	-edit the lblDebugFindImage to result
;author: GkevinOD (2017)
Func chkDebugFindImageClick()
	$hWindow = WinGetHandle("BlueStacks App Player")
	$hControl = ControlGetHandle("BlueStacks App Player", "", "[CLASS:BlueStacksApp; INSTANCE:1]")
	While(GUICtrlRead($chkDebugFindImage) = 1) ;if it is checked
		Dim $strImage = GUICtrlRead($textDebugImage)
		Dim $dirImage = ""
		;first check if file exist
		If StringInStr($strImage, "-") Then ;image with specified folder
			$dirImage = StringSplit($strImage, "-", 2)[0] & "\" & $strImage
		EndIf

		;process
		If Not FileExists($strImageDir & $dirImage & ".bmp") Then
			GUICtrlSetData($lblDebugImage, "Found: Non-Existent")
		Else
			_CaptureRegion()
			Local $arrayPoints = findImage($strImage, 30)
			If Not isArray($arrayPoints) Then ;if not found
				GUICtrlSetData($lblDebugImage, "Found: 0")
			Else
				GUICtrlSetData($lblDebugImage, "Found: " & $arrayPoints[0] & ", " & $arrayPoints[1])
			EndIf
		EndIf

		Sleep(500);
	WEnd
EndFunc

;function: chkDebugLocationClick()
;-Intervals of 1/2 seconds, tries to find the location of the game
;pre:
;	-must not have script running
;	-image file exist
;post:
;	-edit the lblDebugLocation to result
;author: GkevinOD (2017)
Func chkDebugLocationClick()
	$hWindow = WinGetHandle("BlueStacks App Player")
	$hControl = ControlGetHandle("BlueStacks App Player", "", "[CLASS:BlueStacksApp; INSTANCE:1]")
	While(GUICtrlRead($chkDebugLocation) = 1) ;if it is checked
		GUICtrlSetData($chkDebugLocation, "Location: " & getLocation())
		Sleep(500);
	WEnd
EndFunc

;function: btnCopyPointsClick()
;-Copying points from lblDebugCoordinations to the Clipboard
;post:
;	-clipboard will change to coordinations of 0,0,0,0 (based on lblDebugCoordinations)
;author: GkevinOD (2017)
Func btnCopyPointsClick()
	ClipPut($pointDebug1[0] & "," & $pointDebug1[1] & "," & $pointDebug2[0] & "," & $pointDebug2[1])
	MsgBox($MB_OK, $botName & " " & $botVersion, "The coordinations have been saved to your Clipboard.")
EndFunc