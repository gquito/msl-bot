Opt("GUIOnEventMode", 1)
#Region ### START Koda GUI section ### Form=
Global $frmMain = GUICreate($botName & " " & $botVersion, 286, 300, 392, 427, -1, $WS_EX_WINDOWEDGE)
GUISetOnEvent($GUI_EVENT_CLOSE, "frmMainClose")

Global $textOutput = GUICtrlCreateEdit("", 2, 185, 282, 113, BitOR($ES_WANTRETURN, $WS_VSCROLL, $ES_AUTOVSCROLL))
_GUICtrlEdit_SetLimitText($textOutput, 100000000)
GUICtrlSetData(-1, "• Thanks for using MSL-Bot!" & @CRLF & "• This is an open-source project so you are allowed to modify and create codes that fit your needs." & @CRLF & "• If you find any bugs/issues or want to say Hi join our Discord, link in the 'About' page." & @CRLF & "• If you find this bot useful, consider supporting me by donating! Link in the 'About' tab." & @CRLF)

Global $Tab1 = GUICtrlCreateTab(0, 0, 284, 161)
GUICtrlSetState(-1, $GUI_FOCUS)

GUICtrlCreateTabItem("Scripts")
Global $cmbLoad = GUICtrlCreateCombo( "Select a script..", 4, 28, 150, 25 )
GUICtrlSetFont(-1, 8, 400, 0, "Arial")
GUICtrlSetOnEvent(-1, "cmbLoadClick")
Global $listScript = GUICtrlCreateList("", 4, 53, 276, 104, BitOR($WS_BORDER, $WS_VSCROLL))
GUICtrlSetData(-1, "")
GUICtrlSetFont(-1, 8, 400, 0, "Arial")
Global $btnEdit = GUICtrlCreateButton("Edit", 228, 28, 43, 25)
GUICtrlSetFont(-1, 8, 400, 0, "Arial")
GUICtrlSetOnEvent(-1, "btnEditClick")


Global $TabSheet2 = GUICtrlCreateTabItem("Config")
GUICtrlCreateGroup("", 4, 21, 274, 134)
GUICtrlSetFont(-1, 10, 400, 0, "Arial")
Global $textConfig = GUICtrlCreateInput("config.ini", 12, 36, 80, 22)
GUICtrlSetFont(-1, 10, 400, 0, "Arial")
Global $btnSetConfig = GUICtrlCreateButton("Set", 96, 34, 43, 25)
GUICtrlSetFont(-1, 8, 400, 0, "Arial")
GUICtrlSetOnEvent(-1, "btnSetConfig")
Global $listConfig = GUICtrlCreateList("", 9, 60, 263, 96, BitOR($WS_BORDER, $WS_VSCROLL))
GUICtrlSetData(-1, "")
GUICtrlSetFont(-1, 8, 400, 0, "Arial")
Global $btnConfigEdit = GUICtrlCreateButton("Edit", 228, 34, 43, 25)
GUICtrlSetFont(-1, 8, 400, 0, "Arial")
GUICtrlSetOnEvent(-1, "btnConfigEdit")
GUICtrlCreateGroup("", -99, -99, 1, 1)


GUICtrlCreateTabItem("Debug")
GUICtrlCreateLabel("Debugging tools:", 8, 29, 100, 17)
GUICtrlSetFont(-1, 10, 400, 0, "Arial")
Global $chkDebugLocation = GUICtrlCreateCheckbox("Location: not started", 88, 49, 200, 17)
GUICtrlSetFont(-1, 8, 400, 0, "Arial")
GUICtrlSetOnEvent(-1, "chkDebugLocationClick")
Global $btnSet = GUICtrlCreateButton("Set Location", 12, 48, 70, 20)
GUICtrlSetFont(-1, 8, 400, 0, "Arial")
GUICtrlSetOnEvent(-1, "btnSetClick")
Global $chkDebugFindImage = GUICtrlCreateCheckbox("Find Image:", 12, 73, 73, 17)
GUICtrlSetFont(-1, 8, 400, 0, "Arial")
GUICtrlSetOnEvent(-1, "chkDebugFindImageClick")
Global $lblDebugImage = GUICtrlCreateLabel("Found: 0" & @CRLF & "Size: 0", 180, 68, 100, 34)
GUICtrlSetFont(-1, 8, 400, 0, "Arial")
Global $textDebugImage = GUICtrlCreateInput("", 88, 71, 90, 22)
GUICtrlSetFont(-1, 8, 400, 0, "Arial")
Global $btnDebugTestCode = GUICtrlCreateButton("Test Code:", 11, 97, 59, 25)
GUICtrlSetOnEvent(-1, "btnDebugTestCodeClick")
Global $textDebugTestCode = GUICtrlCreateInput("", 76, 99, 201, 22)
GUICtrlSetFont(-1, 8, 400, 0, "Arial")
Global $btnSaveImage = GUICtrlCreateButton("Save As Image: ", 11, 127, 100, 25)
GUICtrlSetOnEvent(-1, "btnSaveImage")
Global $lblDebugCoordinations = GUICtrlCreateLabel("F6: (?, ?) | F7: (?, ?)", 120, 131, 265, 17)
GUICtrlSetFont(-1, 9, 400, 0, "Arial")


GUICtrlCreateTabItem("About")
GUICtrlCreateLabel("This is an open-sourced Monster Super League bot programmed to gain experience and because of the enjoyment of coding.", 8, 29, 250, 38, 0x01)
GUICtrlSetFont(-1, 8, 400, 0, "Arial")
Global $lblAuthor = GUICtrlCreateLabel("Author: GkevinOD (gkevinod@gmail.com)", 12, 77, 250, 17)
GUICtrlSetFont(-1, 8, 400, 0, "Arial")
Global $lblVersion = GUICtrlCreateLabel("Current version: ", 12, 90, 250, 17)
GUICtrlSetFont(-1, 8, 400, 0, "Arial")
Global $lblDiscord = GUICtrlCreateLabel("Discord: https://discord.gg/UQGRnwf", 12, 103, 250, 17)
GUICtrlSetFont(-1, 8, 400, 0, "Arial")
GUICtrlSetCursor(-1, 0)
GuiCtrlSetOnEvent(-1, "lblDiscordClick")
Global $lblDonate = GUICtrlCreateLabel("Donate: https://www.paypal.me/gkevinod", 12, 129, 250, 17)
GUICtrlSetFont(-1, 8, 400, 0, "Arial")
GUICtrlSetCursor(-1, 0)
GuiCtrlSetOnEvent(-1, "lblDonateClick")


GUICtrlCreateTabItem("")
Global $btnRun = GUICtrlCreateButton("Start", 8, 160, 75, 25)
GUICtrlSetOnEvent(-1, "btnRunClick")
Global $btnClear = GUICtrlCreateButton("Clear", 202, 160, 75, 25)
GUICtrlSetOnEvent(-1, "btnClearClick")
Global $btnPause = GUICtrlCreateButton("Pause", 105, 160, 75, 25)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSetOnEvent(-1, "btnPauseClick")
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

;gui for boolean input
Func getBoolean()
	Opt("GUIOnEventMode", 0)
	Local $frmBoolean = GUICreate("Select a new value:", 190, 45, -1, -1, BitOR($WS_POPUPWINDOW, $WS_SYSMENU, $WS_CAPTION))
	Local $btnTrue = GUICtrlCreateButton("True", 10, 10, 50, 25)
	Local $btnFalse = GUICtrlCreateButton("False", 70, 10, 50, 25)
	Local $btnCancel = GUICtrlCreateButton("Cancel", 130, 10, 50, 25)

	GUISetState(@SW_SHOW, $frmBoolean)
	Local $result = null
	While $result = null
		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE, $btnCancel
				$result = -1
			Case $btnTrue
				$result = 1
			Case $btnFalse
				$result = 0
		EndSwitch

		Sleep(10)
	WEnd

	GUIDelete($frmBoolean)
	Opt("GUIOnEventMode", 1)
	Return $result
EndFunc

;gui for text input
Func getText($default = "")
	Opt("GUIOnEventMode", 0)
	Local $frmBoolean = GUICreate("Select a new value:", 190, 70, -1, -1, BitOR($WS_POPUPWINDOW, $WS_SYSMENU, $WS_CAPTION))
	Local $textInput = GUICtrlCreateInput($default, 10, 10, 170, 20, BitOr($ES_CENTER, $ES_AUTOHSCROLL))

	Local $btnOkay = GUICtrlCreateButton("Okay", 10, 35, 50, 25)
	Local $btnCancel = GUICtrlCreateButton("Cancel", 130, 35, 50, 25)

	GUISetState(@SW_SHOW, $frmBoolean)
	Local $result = null
	While $result = null
		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE, $btnCancel
				$result = -1
			Case $btnOkay
				$result = GUICtrlRead($textInput)
		EndSwitch

		Sleep(10)
	WEnd

	GUIDelete($frmBoolean)
	Opt("GUIOnEventMode", 1)
	Return $result
EndFunc

;gui for combo input
Func getCombo($strItems, $default = "")
	Opt("GUIOnEventMode", 0)
	$strItems = StringReplace($strItems, ", ", ",")

	Local $frmBoolean = GUICreate("Select a new value:", 190, 70, -1, -1, BitOR($WS_POPUPWINDOW, $WS_SYSMENU, $WS_CAPTION))
	Local $cmbItems = GUICtrlCreateCombo($default, 10, 10, 170, 20, BitOR($CBS_DROPDOWNLIST, $CBS_SORT))
	GUICtrlSetData($cmbItems, StringRegExpReplace(StringReplace($strItems, ",", "|"), "(" & $default & "\|?|\|" & $default & ")", ""))

	Local $btnOkay = GUICtrlCreateButton("Okay", 10, 35, 50, 25)
	Local $btnCancel = GUICtrlCreateButton("Cancel", 130, 35, 50, 25)

	GUISetState(@SW_SHOW, $frmBoolean)
	Local $result = null
	While $result = null
		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE, $btnCancel
				$result = -1
			Case $btnOkay
				$result = GUICtrlRead($cmbItems)
		EndSwitch

		Sleep(10)
	WEnd

	GUIDelete($frmBoolean)
	Opt("GUIOnEventMode", 1)
	Return $result
EndFunc

;gui for combo input
Func getList($strList, $strChecked = "")
	Opt("GUIOnEventMode", 0)
	$strList = StringReplace($strList, ", ", ",")
	$strChecked = StringReplace($strChecked, ", ", ",")

	Local $arrayList = StringSplit($strList, ",", 2)
	For $i = 0 To UBound($arrayList)-1
		For $checked In StringSplit($strChecked, ",", 2)
			If $checked = $arrayList[$i] Then
				$arrayList[$i] = "*" & $checked
			EndIf
		Next
	Next

	_ArraySort($arrayList)

	Local $frmBoolean = GUICreate("Select a new values:", 250, 40+(Int(UBound($arrayList)/ 3)*26)+40, -1, -1, BitOR($WS_POPUPWINDOW, $WS_SYSMENU, $WS_CAPTION))

	For $i = 0 To UBound($arrayList)-1
		Local $color = 0xB00000
		If StringLeft($arrayList[$i], 1) = "*" Then
			$color = 0x008300
		EndIf
		$arrayList[$i] = GUICtrlCreateButton($arrayList[$i], 5+(Mod($i, 3)*80), 10+(Int($i/3)*25), 78, 25)
		GUICtrlSetBkColor($arrayList[$i], $color)
	Next

	Local $btnSave = GUICtrlCreateButton("Save", 10, 40+(Int(UBound($arrayList)/ 3)*26)+5, 50, 25)
	Local $btnCancel = GUICtrlCreateButton("Cancel", 190, 40+(Int(UBound($arrayList)/ 3)*26)+5, 50, 25)

	GUISetState(@SW_SHOW, $frmBoolean)
	Local $result = null
	While $result = null
		Local $btnMsg = GUIGetMsg()
		Switch $btnMsg
			Case $GUI_EVENT_CLOSE, $btnCancel
				$result = -1
			Case $btnSave
				For $element In $arrayList
					If StringLeft(GUICtrlRead($element), 1) = "*" Then
						$result &= "," & StringMid(GUICtrlRead($element), 2)
					EndIf
				Next
				$result = StringMid($result, 2)
			Case Else
				For $button In $arrayList
					If $btnMsg = $button Then
						If StringLeft(GUICtrlRead($button), 1) = "*" Then
							GUICtrlSetData($button, StringMid(GUICtrlRead($button), 2))
							Local $color = 0xB00000
						Else
							GUICtrlSetData($button, "*" & GUICtrlRead($button))
							Local $color = 0x008300
						EndIf

						GUICtrlSetBkColor($button, $color)
						ExitLoop
					EndIf
				Next
		EndSwitch

		Sleep(10)
	WEnd

	GUIDelete($frmBoolean)
	Opt("GUIOnEventMode", 1)
	Return $result
EndFunc

;gui for edit config
Func editConfig($strConfig)
	Opt("GUIOnEventMode", 0)
	Local $frmBoolean = GUICreate("Edit config: " & $strConfig, 250, 125, -1, -1, BitOR($WS_POPUPWINDOW, $WS_SYSMENU, $WS_CAPTION))

	Local $listEditConfig = GUICtrlCreateList("", 5, 5, 240, 90, BitOR($WS_BORDER, $WS_VSCROLL))

	;clearing data
	GUICtrlSetData($listEditConfig, "")

	;process of getting info
	Local $strLocalScript = $strConfig

	Local $arrayKeys = StringSplit(IniRead($botConfigDir, $strLocalScript, "keys", ""), ",", 2)
	$strConfig = ""
	For $key In $arrayKeys
		$strConfig &= $key & "=" & IniRead($botConfigDir, $strLocalScript, $key, "???") & "|"
	Next

	;final
	GUICtrlSetData($listEditConfig, $strConfig)

	Local $btnOkay = GUICtrlCreateButton("Okay", 10, 95, 50, 25)
	Local $editConfig = GUICtrlCreateButton("Edit", 102, 95, 50, 25)
	Local $btnCancel = GUICtrlCreateButton("Cancel", 190, 95, 50, 25)

	GUISetState(@SW_SHOW, $frmBoolean)
	Local $result = null
	While $result = null
		Opt("GUIOnEventMode", 0)
		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE, $btnCancel
				$result = -1
			Case $editConfig
				;initial variables
				Local $strRaw = GUICtrlRead($listEditConfig)
				Local $arrayRaw = StringSplit($strRaw, "=", 2)

				If UBound($arrayRaw) = 1 Then ;check if no config selected
					MsgBox(0, $botName & " " & $botVersion, "No config selected.")
					ContinueLoop
				EndIf

				;getting keys and values to modify
				Dim $key = $arrayRaw[0]
				Dim $value = "!" ;temp value

				Dim $arrayType = StringSplit(IniRead($botConfigDir, $strLocalScript, $key & "-type", ""), "|", 2)
				Switch $arrayType[0]
					Case "combo"
						$value = getCombo($arrayType[1], IniRead($botConfigDir, $strLocalScript, $key, ""))
					Case "list"
						$value = getList($arrayType[1], IniRead($botConfigDir, $strLocalScript, $key, ""))
					Case "boolean"
						$value = getBoolean()
					Case "config"
						$value = -1
						editConfig($arrayType[1])
					Case Else
						$value = getText(IniRead($botConfigDir, $strLocalScript, $key, ""))
				EndSwitch

				;overwrite file
				If Not($value = -1) Then IniWrite($botConfigDir, $strLocalScript, $key, $value) ;write to config file

				;clearing data
				GUICtrlSetData($listEditConfig, "")

				;process of getting info
				Dim $arrayKeys = StringSplit(IniRead($botConfigDir, $strLocalScript, "keys", ""), ",", 2)
				$strConfig = ""
				For $key In $arrayKeys
					$strConfig &= $key & "=" & IniRead($botConfigDir, $strLocalScript, $key, "???") & "|"
				Next

				;final
				GUICtrlSetData($listEditConfig, $strConfig)
			Case $btnOkay
				$result = 1
		EndSwitch

		Sleep(10)
	WEnd

	GUIDelete($frmBoolean)
	Opt("GUIOnEventMode", 1)
	Return $result
EndFunc