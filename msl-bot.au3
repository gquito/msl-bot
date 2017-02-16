#AutoIt3Wrapper_UseX64=n

;Initialize Bot
Global $botVersion = IniRead(@ScriptDir & "/config.ini", "general", "version", "")
Global $botName = IniRead(@ScriptDir & "/config.ini", "general", "title", "MSL Bot")
Global $arrayScripts = StringSplit(IniRead(@ScriptDir & "/config.ini", "general", "scripts", ""), ",", 2)

;defining globals
Global $chkBackground ;checkbox, declare first to remove warning
Global $chkMouse ;^
Global $chkOutput ;^
Global $strScript = "" ;script section
Global $strConfig = "" ;all keys

#include "core/imports.au3"
#include "core/gui.au3"

_GDIPlus_Startup()
GUICtrlSetState($chkBackground, IniRead(@ScriptDir & "/config.ini", "general", "background-mode", 1))
GUICtrlSetState($chkOutput, IniRead(@ScriptDir & "/config.ini", "general", "output-all-process", 1))
GUICtrlSetState($chkMouse, IniRead(@ScriptDir & "/config.ini", "general", "real-mouse-mode", 1))
GUICtrlSetData($cmbLoad, StringReplace(IniRead(@ScriptDir & "/config.ini", "general", "scripts", "There are no scripts available."), ",", "|"))

;importing scripts
$tempFile = FileOpen(@ScriptDir & "/script/imports.au3", $FO_OVERWRITE + $FO_CREATEPATH)
$tempVar = ""
For $tempScript In $arrayScripts
	$tempVar = '#include "' & $tempScript & '.au3"' & @CRLF
Next
FileWrite($tempFile, $tempVar)
FileClose($tempFile)

#include "script/imports.au3"

;Hotkeys =====================================
HotKeySet("{END}", "hotkeyStopBot")

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
		Else
			MsgBox($MB_OK, $botName & " " & $botVersion, "Load a script before starting.")
			btnRunClick()
		EndIf
	EndIf
	Sleep(10)
WEnd

;function: btnRunClick
Func btnRunClick()
	$hWindow = WinGetHandle("BlueStacks App Player")
	$hControl = ControlGetHandle("BlueStacks App Player", "", "[CLASS:BlueStacksApp; INSTANCE:1]")

	If $boolRunning = False Then ;starting bot
		If GUICtrlRead($chkMouse) = 1 Then MsgBox($MB_ICONINFORMATION, $botName & " " & $botVersion, "You have real mouse on! You will not be able to use your mouse. To stop script press End key.")
		$boolRunning = True

		GUICtrlSetData($btnRun, "Stop")
	Else ;ending bot
		$boolRunning = False

		GUICtrlSetData($btnRun, "Start")
	EndIf
EndFunc

;function: btnAdjustClick()
;-Adjusts most images for optimization for certain computers
;pre:
;	-no script must be running
;post:
;	-new images will be generated or replaced
;author: GkevinOD(2017)
Func btnAdjustClick()
	MsgBox($MB_SYSTEMMODAL, $botName & " " & $botVersion, "Adjust is currently being worked on.")
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
	If GUICtrlRead($cmbLoad) = "Select a script.." Then
		GUICtrlSetData($listScript, "") ;reset list
		Return
	EndIf

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

;function: chkBackgroundClick()
;-Overwrites config.ini file and updates new data.
;author: GkevinOD (2017)
Func chkBackgroundClick()
	IniWrite(@ScriptDir & "/config.ini", "general", "background-mode", StringReplace(GUICtrlRead($chkBackGround), "4", "0"))
EndFunc

;function: chkOutputClick()
;-Overwrites config.ini file and updates new data.
;author: GkevinOD (2017)
Func chkOutputClick()
	IniWrite(@ScriptDir & "/config.ini", "general", "output-all-process", StringReplace(GUICtrlRead($chkOutput), "4", "0"))
EndFunc

;function: chkMouse()
;-Overwrites config.ini file and updates new data.
;author: GkevinOD (2017)
Func chkMouse()
	IniWrite(@ScriptDir & "/config.ini", "general", "real-mouse-mode", StringReplace(GUICtrlRead($chkMouse), "4", "0"))
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

		;first check if file exist
		If Not FileExists($strImageDir & $strImage) Then
			GUICtrlSetData($lblDebugImage, "Found: 0")
			ExitLoop
		EndIf

		;process
		_CaptureRegion()
		Dim $arrayPoints = findImage(StringReplace($strImage, ".bmp", ""), 50)
		If Not isArray($arrayPoints) Then ;if not found
			GUICtrlSetData($lblDebugImage, "Found: 0")
			ExitLoop
		EndIf

		GUICtrlSetData($lblDebugImage, "Found: " & $arrayPoints[0] & ", " & $arrayPoints[1])
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

