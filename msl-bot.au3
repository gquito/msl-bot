#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\..\favicon.ico
#AutoIt3Wrapper_Outfile=msl-bot v1.8.exe
#AutoIt3Wrapper_UseX64=n
#AutoIt3Wrapper_Res_Description=An open-sourced Monster Super League bot
#AutoIt3Wrapper_Res_Fileversion=1.8.4.0
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
			GUICtrlSetData($lblDebugImage, "Found: Non-Existent" & @CRLF & "Size: 0")
		Else
			_CaptureRegion()
			Local $arrayPoints = findImage($strImage, 30)
			If Not isArray($arrayPoints) Then ;if not found
				GUICtrlSetData($lblDebugImage, "Found: 0" & @CRLF & "Size: 0")
			Else
				Local $hImage = _GDIPlus_ImageLoadFromFile($strImageDir & $dirImage & ".bmp")
				GUICtrlSetData($lblDebugImage, "Found: " & $arrayPoints[0] & ", " & $arrayPoints[1] & @CRLF & "Size: " & _GDIPlus_ImageGetWidth($hImage) & ", " & _GDIPlus_ImageGetHeight($hImage))
			EndIf
		EndIf

		Sleep(500);
	WEnd
EndFunc

;function: btnSetClick()
;-If in debug, location is 'unknown' this button can set the location of the unknown.
;pre:
;	-location must be unknown.
; 	-location input must exist.
;post:
;	-create an image to be the new location or alternative location
;author: GkevinOD (2017)
Func btnSetClick()
	Local $strLocation = "unknown"
	While $strLocation = "unknown"
		$strLocation = InputBox($botName & " " & $botVersion, "Enter CURRENT location:" & @CRLF & @CRLF & "You are limited to: " & StringReplace($strKnownLocation, ",", ", "), "", default, default, 300)
		If $strLocation = "" Then Return

		For $element In StringSplit($strKnownLocation, ",", 2)
			If $element = $strLocation Then ExitLoop(2)
		Next
		$strLocation = "unknown"
	WEnd

	Local $dim_location = StringSplit(Eval("dim_" & $strLocation), ",", 2)
	Local $fileDir = "core\images\location\location-" & StringReplace($strLocation, "_", "-") ;no '.bmp'
	Local $fileCounter = 2; to check if there is already alt file that exist

	Local $intLeft = Int($dim_location[0]) - Int(Int($dim_location[2])/2)
	Local $intTop = Int($dim_location[1]) - Ceiling(Int($dim_location[3])/2)
	If FileExists($fileDir & ".bmp") Then
		While FileExists($fileDir & $fileCounter & ".bmp")
			$fileCounter += 1 ;increment and check if alt exists
		WEnd
		_CaptureRegion($fileDir & $fileCounter & ".bmp", $intLeft, $intTop, $intLeft+Int($dim_location[2]), $intTop+Int($dim_location[3]))
		MsgBox(0, "", $fileDir & $fileCounter & ".bmp")
	Else
		_CaptureRegion($fileDir & ".bmp", $intLeft, $intTop, $intLeft+Int($dim_location[2]), $intTop+Int($dim_location[3]))
	EndIf

	MsgBox($MB_ICONINFORMATION, $botName & " " & $botVersion, "New location has been added. Test using the debug 'Location' to see if it worked.")
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
		GUICtrlSetState($btnSet, $GUI_DISABLE)
		GUICtrlSetData($chkDebugLocation, "Location: " & getLocation())
		Sleep(500);
	WEnd

	If getLocation() = "unknown" Then
		GUICtrlSetState($btnSet, $GUI_ENABLE)
	Else
		GUICtrlSetState($btnSet, $GUI_DISABLE)
	EndIf
EndFunc

;function: btnSaveImage()
;-Save Image using the points given
;post:
;	-create an image using points
;author: GkevinOD (2017)
Func btnSaveImage()
	Local $strImage = "unknown"
	While $strImage = "unknown"
		Local $strAvailableFolders = "battle,catch,gem,location,manage,map,misc"
		$strImage = InputBox($botName & " " & $botVersion, "Enter image name:" & @CRLF & @CRLF & "The folder is limited to (FOLDER-IMAGENAME): " & StringReplace($strAvailableFolders, ",", ", "))
		If $strImage = "" Then Return

		For $element In StringSplit($strAvailableFolders, ",", 2)
			If StringSplit($strImage, "-", 2)[0] = $element Then ExitLoop(2)
		Next
		$strImage = "unknown"
	WEnd

	Local $fileDir = "core\images\" & StringSplit($strImage, "-", 2)[0] & "\" & $strImage
	If FileExists($fileDir & ".bmp") Then
		#Region --- CodeWizard generated code Start ---
		;MsgBox features: Title=Yes, Text=Yes, Buttons=Yes, No, and Cancel, Icon=Warning, Modality=System Modal
		If Not IsDeclared("iMsgBoxAnswer") Then Local $iMsgBoxAnswer
		$iMsgBoxAnswer = MsgBox(4147, $botName & " " & $botVersion, ' "' & $strImage & '" already exist! Do you want to make an alternative image?')
		Select
			Case $iMsgBoxAnswer = 6 ;Yes
				Local $fileCounter = 2
				While FileExists($fileDir & $fileCounter & ".bmp")
					$fileCounter += 1 ;increment until file does not exist
				WEnd
				$fileDir = $fileDir & $fileCounter
			Case $iMsgBoxAnswer = 7 ;No
				Return null
			Case $iMsgBoxAnswer = 2 ;Cancel
				Return null
		EndSelect
		#EndRegion --- CodeWizard generated code End ---
	EndIf
	_CaptureRegion($fileDir & ".bmp", $pointDebug1[0], $pointDebug1[1], $pointDebug2[0], $pointDebug2[1])
	MsgBox($MB_ICONINFORMATION, $botName & " " & $botVersion, "The image has been saved to: " & @CRLF & $fileDir & ".bmp")
EndFunc