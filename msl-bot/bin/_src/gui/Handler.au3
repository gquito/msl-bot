#include-once
#include "../imports.au3"

#cs ##########################################
	Control Event Handling
#ce ##########################################

Func GUIMain()
	While True
		GUI_HANDLE()
		MSLMain()
	WEnd
EndFunc   ;==>GUIMain

Func GUI_HANDLE()
	Local $iCode = GUIGetMsg(1)
	Switch $iCode[1]
		Case $hParent
			Switch $iCode[0]
				Case $idLbl_Donate
					ShellExecute("https://paypal.me/GkevinOD/10")
				Case $idLbl_Discord
					ShellExecute("https://discord.gg/UQGRnwf")
				Case $idLbl_List
					MsgBox($MB_ICONINFORMATION + $MB_OK, "MSL Donator Features", "Completed: " & @CRLF & "- Auto PvP, Guided Auto, Daily Quest, Complete Bingo, Farm Forever, TOC, Gold Dungeon" & @CRLF & @CRLF & "In Progress: " & @CRLF & "- Buy Items, Script Schedule, Colossal, Hatch Eggs, Dragons")
				Case $idCkb_Information, $idCkb_Error, $idCkb_Process, $idCkb_Debug
					Local $sFilter = ""
					If BitAND(GUICtrlRead($idCkb_Information), $GUI_CHECKED) = $GUI_CHECKED Then $sFilter &= "Information,"
					If BitAND(GUICtrlRead($idCkb_Error), $GUI_CHECKED) = $GUI_CHECKED Then $sFilter &= "Error,"
					If BitAND(GUICtrlRead($idCkb_Process), $GUI_CHECKED) = $GUI_CHECKED Then $sFilter &= "Process,"
					If BitAND(GUICtrlRead($idCkb_Debug), $GUI_CHECKED) = $GUI_CHECKED Then $sFilter &= "Debug,"

					$g_sLogFilter = $sFilter
					Log_Display_Reset()
				Case $idBtn_Detach
					_GUICtrlListView_Destroy($hLV_Log)
					GUICtrlDelete($idBtn_Detach)
					GUICtrlDelete($idCkb_Information)
					GUICtrlDelete($idCkb_Error)
					GUICtrlDelete($idCkb_Process)
					GUICtrlDelete($idCkb_Debug)

					Local $aWinPos = WinGetPos($g_sAppTitle)
					WinMove($g_sAppTitle, "", $aWinPos[0], $aWinPos[1], 400, 400)

					ControlMove("", "", $hLV_Stat, 20, 86, 357, 270)
					GUICtrlSetResizing($idLV_Stat, $GUI_DOCKTOP + $GUI_DOCKBOTTOM)
					WinMove($g_sAppTitle, "", $aWinPos[0], $aWinPos[1], $aWinPos[2], $aWinPos[3])

					CreateLogWindow()

				Case $hDM_Debug
					If $g_hEditConfig <> Null Then _endEdit()
					Debug()
				Case $hDM_ScriptTest
					If $g_bRunning = False Then
						$g_bRunning = True
						ScriptTest()
						$g_bRunning = False
					EndIf
				Case $idBtn_Stop
					Stop()
				Case $GUI_EVENT_CLOSE, $hDM_ForceQuit
					GUISetState(@SW_HIDE, $hParent)
					CloseApp()
				Case Else
					;Handles the combo config contextmenu
					handleCombo($iCode[0], $hLV_ScriptConfig)
			EndSwitch
		Case $hLogWindow
			Switch $iCode[0]
				Case $GUI_EVENT_CLOSE
					GUISwitch($hParent)
					_GUICtrlTab_ClickTab($hTb_Main, 1)

					Local $aWinPos = WinGetPos($g_sAppTitle)
					WinMove($g_sAppTitle, "", $aWinPos[0], $aWinPos[1], 400, 400)

					ControlMove("", "", $hLV_Stat, 20, 86, 357, 145)
					$idBtn_Detach = GUICtrlCreateButton("Detach", 308, 231, 60, 23)

					$idCkb_Information = GUICtrlCreateCheckbox("Info", 34, 231, 60, 23)
					GUICtrlSetState(-1, $GUI_CHECKED)
					$idCkb_Error = GUICtrlCreateCheckbox("Error", 94, 231, 60, 23)
					GUICtrlSetState(-1, $GUI_CHECKED)
					$idCkb_Process = GUICtrlCreateCheckbox("Process", 154, 231, 60, 23)
					GUICtrlSetState(-1, $GUI_CHECKED)
					$idCkb_Debug = GUICtrlCreateCheckbox("Debug", 224, 231, 60, 23)
					GUICtrlSetState(-1, $GUI_UNCHECKED)

					$idLV_Log = GUICtrlCreateListView("", 20, 255, 360, 100, $LVS_REPORT + $LVS_NOSORTHEADER)
					$hLV_Log = GUICtrlGetHandle($idLV_Log)

					_GUICtrlListView_SetExtendedListViewStyle($hLV_Log, $LVS_EX_FULLROWSELECT + $LVS_EX_GRIDLINES)
					_GUICtrlListView_AddColumn($hLV_Log, "Time", 76, 0)
					_GUICtrlListView_AddColumn($hLV_Log, "Text", 300, 0)
					_GUICtrlListView_AddColumn($hLV_Log, "Type", 100, 0)
					_GUICtrlListView_AddColumn($hLV_Log, "Function", 100, 0)
					_GUICtrlListView_AddColumn($hLV_Log, "Location", 100, 0)
					_GUICtrlListView_AddColumn($hLV_Log, "Level", 100, 0)
					_GUICtrlListView_JustifyColumn($hLV_Log, 0, 0)
					_GUICtrlListView_JustifyColumn($hLV_Log, 1, 0)

					_GUICtrlTab_ClickTab($hTb_Main, 0)
					_GUICtrlTab_ClickTab($hTb_Main, 1)

					GUICtrlSetResizing($idLV_Stat, $GUI_DOCKTOP + $GUI_DOCKBOTTOM)

					GUICtrlSetResizing($idBtn_Detach, $GUI_DOCKBOTTOM + $GUI_DOCKHEIGHT)
					GUICtrlSetResizing($idCkb_Information, $GUI_DOCKBOTTOM + $GUI_DOCKHEIGHT)
					GUICtrlSetResizing($idCkb_Error, $GUI_DOCKBOTTOM + $GUI_DOCKHEIGHT)
					GUICtrlSetResizing($idCkb_Process, $GUI_DOCKBOTTOM + $GUI_DOCKHEIGHT)
					GUICtrlSetResizing($idCkb_Debug, $GUI_DOCKBOTTOM + $GUI_DOCKHEIGHT)

					GUICtrlSetResizing($idLV_Log, $GUI_DOCKBOTTOM + $GUI_DOCKHEIGHT)

					WinMove($g_sAppTitle, "", $aWinPos[0], $aWinPos[1], $aWinPos[2], $aWinPos[3])

					GUIDelete($hLogWindow)
					GUICtrlDelete($hLV_FunctionLevels)

					$idLV_FunctionLevels = Null
					$hLV_FunctionLevels = Null

					$g_sLogFilter = "Information,Process,Error"
					Log_Display_Reset()
				Case $idCkb_Information, $idCkb_Error, $idCkb_Process, $idCkb_Debug
					Local $sFilter = ""
					If BitAND(GUICtrlRead($idCkb_Information), $GUI_CHECKED) = $GUI_CHECKED Then $sFilter &= "Information,"
					If BitAND(GUICtrlRead($idCkb_Error), $GUI_CHECKED) = $GUI_CHECKED Then $sFilter &= "Error,"
					If BitAND(GUICtrlRead($idCkb_Process), $GUI_CHECKED) = $GUI_CHECKED Then $sFilter &= "Process,"
					If BitAND(GUICtrlRead($idCkb_Debug), $GUI_CHECKED) = $GUI_CHECKED Then $sFilter &= "Debug,"

					$g_sLogFilter = $sFilter
					Log_Display_Reset()
			EndSwitch
	EndSwitch
EndFunc   ;==>GUI_HANDLE

Func WM_COMMAND($hWnd, $iMsg, $wParam, $lParam)
	#forceref $hWnd, $iMsg, $wParam
	Local $nNotifyCode = BitShift($wParam, 16)
	Local $nID = BitAND($wParam, 0x0000FFFF)
	Local $hCtrl = $lParam

	Switch $hCtrl
		Case $hBtn_Start
			If $nNotifyCode = $BN_CLICKED Then
				If $g_hEditConfig <> Null Then _endEdit()
				Start()
			EndIf
		Case $hBtn_Pause
			If $nNotifyCode = $BN_CLICKED Then
				Pause()
			EndIf
		Case $hBtn_StatReset
			If $nNotifyCode = $BN_CLICKED Then
				If MsgBox($MB_YESNO + $MB_ICONQUESTION, "Reset Confirmation", "Are you sure you wish to reset the stats?", 30) = $IDYES Then
					Stat_Reset($g_aStats, $hLV_OverallStats)
				EndIf
			EndIf
		Case $hCmb_Scripts
			If $nNotifyCode = $CBN_SELCHANGE Then
				If $g_hEditConfig <> Null Then _endEdit()
				ChangeScript()
			EndIf
	EndSwitch
	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_COMMAND

Local Const $LV_DBLCLK = -114
Local Const $LV_RCLICK = -5
Func WM_NOTIFY($hWnd, $iMsg, $wParam, $lParam)
	#forceref $hWnd, $iMsg, $wParam
	Local $hWndFrom, $iCode, $tNMHDR, $tInfo

	$tNMHDR = DllStructCreate($tagNMHDR, $lParam)
	$hWndFrom = HWnd(DllStructGetData($tNMHDR, "hWndFrom"))
	$iCode = DllStructGetData($tNMHDR, "Code")

	Switch $hWndFrom
		Case $hLV_ScriptConfig
			Switch $iCode
				Case $LVN_ITEMCHANGED, $NM_CLICK
					;handles edit updates
					If $g_hEditConfig <> Null Then endEdit()

					;Switches config description label
					$tScriptConfigInfo = DllStructCreate($tagNMITEMACTIVATE, $lParam)

					Local $iIndex = DllStructGetData($tScriptConfigInfo, "Index")
					Local $sText = _GUICtrlListView_GetItemText($hLV_ScriptConfig, $iIndex, 2)

					If $sText = "" Then
						GUICtrlSetData($hLbl_ConfigDescription, "Click on a setting for a description.")
					Else
						GUICtrlSetData($hLbl_ConfigDescription, $sText)
					EndIf
				Case $LV_DBLCLK, $LV_RCLICK
					;Handles changes in the listview
					$tScriptConfigInfo = DllStructCreate($tagNMITEMACTIVATE, $lParam)

					Local $iIndex = DllStructGetData($tScriptConfigInfo, "Index")
					Local $sType = _GUICtrlListView_GetItemText($hLV_ScriptConfig, $iIndex, 3)
					Local $sTypeValues = _GUICtrlListView_GetItemText($hLV_ScriptConfig, $iIndex, 4)

					;Handles edits for settings
					Switch $sType
						Case "combo"
							;Creating context menu from items specified by the combo type.
							Local $t_aItems = StringSplit($sTypeValues, ",", $STR_NOCOUNT)
							createComboMenu($g_aComboMenu, $t_aItems)

							;Displays a context menu to choose an item from.
							ShowMenu($hParent, $g_aComboMenu[0])
						Case "text"
							;Shows edit in the position.
							createEdit($g_hEditConfig, $g_iEditConfig, $hLV_ScriptConfig)
						Case "list"
							createListEditor($hParent, $hLV_ScriptConfig, $iIndex)
						Case "setting"
							Local $sText = _GUICtrlListView_GetItemText($hLV_ScriptConfig, $iIndex, 1)
							Local $iScriptIndex = _GUICtrlComboBox_FindString($hCmb_Scripts, $sText)
							If $iScriptIndex <> -1 Then
								_GUICtrlComboBox_SetCurSel($hCmb_Scripts, $iScriptIndex)
								ChangeScript()
							EndIf
					EndSwitch
			EndSwitch
	EndSwitch
	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_NOTIFY

;Some helper functions for handling controls----

Func CreateLogWindow()
	Local $aPos = WinGetPos($g_sAppTitle)

	Global $hLogWindow = GUICreate($g_sAppTitle & " Log Window", $aPos[2] - 15, $aPos[3] - 15, $aPos[0] + $aPos[2] - 15, $aPos[1], $WS_SIZEBOX + $WS_MAXIMIZEBOX + $WS_MINIMIZEBOX, -1)
	GUISetState(@SW_SHOW, $hLogWindow)

	$idCkb_Information = GUICtrlCreateCheckbox("Info", 10, 4, 60, 23)
	GUICtrlSetState(-1, $GUI_CHECKED)
	$idCkb_Error = GUICtrlCreateCheckbox("Error", 70, 4, 60, 23)
	GUICtrlSetState(-1, $GUI_CHECKED)
	$idCkb_Process = GUICtrlCreateCheckbox("Process", 130, 4, 60, 23)
	GUICtrlSetState(-1, $GUI_CHECKED)
	$idCkb_Debug = GUICtrlCreateCheckbox("Debug", 200, 4, 60, 23)
	GUICtrlSetState(-1, $GUI_UNCHECKED)

	Global $idLV_FunctionLevels = GUICtrlCreateListView("", $aPos[2] - 129, 30, 110, $aPos[3] - 73, $LVS_REPORT + $LVS_NOSORTHEADER)
	Global $hLV_FunctionLevels = GUICtrlGetHandle($idLV_FunctionLevels)
	_GUICtrlListView_AddColumn($hLV_FunctionLevels, "#", 20, 0)
	_GUICtrlListView_AddColumn($hLV_FunctionLevels, "Functions", 150, 0)

	$idLV_Log = GUICtrlCreateListView("", 3, 30, $aPos[2] - 133, $aPos[3] - 73, $LVS_REPORT + $LVS_NOSORTHEADER)
	$hLV_Log = GUICtrlGetHandle($idLV_Log)
	_GUICtrlListView_SetExtendedListViewStyle($hLV_Log, $LVS_EX_FULLROWSELECT + $LVS_EX_GRIDLINES)
	_GUICtrlListView_AddColumn($hLV_Log, "Time", 76, 0)
	_GUICtrlListView_AddColumn($hLV_Log, "Text", 312, 0)
	_GUICtrlListView_AddColumn($hLV_Log, "Type", 100, 0)
	_GUICtrlListView_AddColumn($hLV_Log, "Function", 100, 0)
	_GUICtrlListView_AddColumn($hLV_Log, "Location", 100, 0)
	_GUICtrlListView_AddColumn($hLV_Log, "Level", 100, 0)
	_GUICtrlListView_JustifyColumn($hLV_Log, 0, 0)
	_GUICtrlListView_JustifyColumn($hLV_Log, 1, 0)

	GUICtrlSetResizing($idLV_Log, $GUI_DOCKTOP + $GUI_DOCKBOTTOM + $GUI_DOCKLEFT + $GUI_DOCKRIGHT)
	GUICtrlSetResizing($idLV_FunctionLevels, $GUI_DOCKTOP + $GUI_DOCKBOTTOM + $GUI_DOCKRIGHT + $GUI_DOCKWIDTH)
	GUICtrlSetResizing($idCkb_Information, $GUI_DOCKALL)
	GUICtrlSetResizing($idCkb_Error, $GUI_DOCKALL)
	GUICtrlSetResizing($idCkb_Process, $GUI_DOCKALL)
	GUICtrlSetResizing($idCkb_Debug, $GUI_DOCKALL)

	$g_sLogFilter = "Information,Process,Error"
	Log_Display_Reset()
EndFunc   ;==>CreateLogWindow

;Handles the combo config contextmenu
Func handleCombo(ByRef $iCode, ByRef $hListView)
	If IsArray($g_aComboMenu) = False Then Return
	For $i = 1 To UBound($g_aComboMenu, $UBOUND_ROWS) - 1
		Local $aContext = $g_aComboMenu[$i] ;Hold [idContext, "name"]
		If $iCode = $aContext[0] Then
			;Replaced text from the listview
			_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetSelectedIndices($hListView, True)[1], $aContext[1], 1)
			_saveSettings()

			$g_aComboMenu = Null
			Return 0
		EndIf
	Next
EndFunc   ;==>handleCombo

;For context menu for type combo configs
Func createComboMenu(ByRef $aContextMenu, $aItems)
	Local $hDM_BooleanDummy = GUICtrlCreateDummy()
	Local $t_aContextMenu[UBound($aItems) + 1]

	;Creates an array: [idContextMenu, [idContext, "name"], [idContext, "name"]...]
	$t_aContextMenu[0] = GUICtrlCreateContextMenu($hDM_BooleanDummy)
	For $i = 1 To UBound($t_aContextMenu) - 1
		Local $t_aContext = [GUICtrlCreateMenuItem($aItems[$i - 1], $t_aContextMenu[0]), $aItems[$i - 1]]
		$t_aContextMenu[$i] = $t_aContext
	Next

	$aContextMenu = $t_aContextMenu
EndFunc   ;==>createComboMenu

;Takes text from edit and sets subitem (in Value column) from listview
Func handleEdit(ByRef $hEdit, ByRef $iIndex, $hListView)
	;Handles changes to the config setting.
	Local $sNew = _GUICtrlEdit_GetText($hEdit)
	If $sNew <> "" Then _GUICtrlListView_SetItemText($hListView, $iIndex, $sNew, 1)
	_GUICtrlEdit_Destroy($hEdit)

	If _GUICtrlListView_GetItemText($hListView, $iIndex) = "Profile Name" Then
		$g_sProfilePath = @ScriptDir & "\profiles\" & $sNew & "\"

		;Updating cumulative stats
		_GUICtrlListView_DeleteAllItems($hLV_OverallStats)

		Stat_Read($g_aStats)
		Stat_Update($g_aStats, $hLV_OverallStats)

		Local $t_sScripts[0] ;Reset global script
		$g_ascripts = $t_sScripts

		setScripts($g_ascripts, $g_sScriptsLocal)
		setScripts($g_ascripts, $g_sScriptsLocalCache)

		For $i = 0 To UBound($g_ascripts, $UBOUND_ROWS) - 1
			Local $aScript = $g_ascripts[$i]
			If FileExists($g_sProfilePath & $aScript[0]) = True Then
				getConfigsFromFile($g_ascripts, $aScript[0])
			EndIf
		Next

		If FileExists($g_sProfilePath & "_Config") = True Then
			getConfigsFromFile($g_ascripts, "_Config", $g_sProfilePath)
		EndIf

		Local $t_aScripts ;Will store _Config
		Local $index = 0 ;Stores index of _Config
		For $i = 0 To UBound($g_ascripts) - 1
			$t_aScripts = $g_ascripts[$i]
			If $t_aScripts[0] = "_Config" Then
				$index = $i
				ExitLoop
			EndIf
		Next

		Local $t_aScript = $t_aScripts[2]
		Local $t_aConfig = $t_aScript[0]

		$t_aConfig[1] = $sNew
		$t_aScript[0] = $t_aConfig
		$t_aScripts[2] = $t_aScript
		$g_ascripts[$index] = $t_aScripts

		ChangeScript()
	Else
		_saveSettings()
	EndIf

	UpdateSettings()
	$hEdit = Null
	$iIndex = Null
EndFunc   ;==>handleEdit

;For context menu for text combo configs
Func createEdit(ByRef $hEdit, ByRef $iIndex, $hListView, $bNumber = False)
	If $iIndex = Null Then $iIndex = _GUICtrlListView_GetSelectedIndices($hListView, True)[1]
	Local $sText = _GUICtrlListView_GetItemText($hListView, $iIndex, 1)
	Local $aSize = _GUICtrlListView_GetSubItemRect($hListView, $iIndex, 1)

	Local $aDim = [$aSize[0], $aSize[1], $aSize[2] - $aSize[0], $aSize[3] - $aSize[1]]
	Local $iStyle = $WS_VISIBLE + $ES_AUTOHSCROLL
	If $bNumber = True Then $iStyle += $ES_NUMBER

	$hEdit = _GUICtrlEdit_Create($hLV_ScriptConfig, $sText, $aDim[0], $aDim[1], $aDim[2], $aDim[3], $iStyle)
	_GUICtrlEdit_SetLimitText($hEdit, 99999)

	_GUICtrlEdit_SetSel($hEdit, 0, -1)
	_WinAPI_SetFocus($hEdit)

	HotKeySet("{ENTER}", "endEdit")
EndFunc   ;==>createEdit

;When enter is pressed acts as unfocus and runs the handle edit
Func endEdit()
	handleEdit($g_hEditConfig, $g_iEditConfig, $hLV_ScriptConfig)
	HotKeySet("{ENTER}")
EndFunc   ;==>endEdit

Func _endEdit()
	_GUICtrlEdit_Destroy($g_hEditConfig)
	HotKeySet("{ENTER}")
EndFunc   ;==>_endEdit

Func createListEditor($hParent, $hListView, $iIndex)
	Opt("GUIOnEventMode", 1)
	; [gui handle, listview inside gui, combo handle, combo values, parent handle, listview handle, item index]
	Local $aCurrent = StringSplit(_GUICtrlListView_GetItemText($hListView, $iIndex, 1), ",", $STR_NOCOUNT)
	Local $aDefault = StringSplit(_GUICtrlListView_GetItemText($hListView, $iIndex, 4), ",", $STR_NOCOUNT)

	Local $t_aListEditor[7] ;Holds the array items from comment above.
	Local $t_aPos = WinGetPos($hParent)
	$t_aListEditor[0] = GUICreate("Edit List", 150, 182, $t_aPos[0] + (($t_aPos[2] - 150) / 2), $t_aPos[1] + (($t_aPos[3] - 150) / 2), -1, $WS_EX_TOPMOST, $hParent)
	$t_aListEditor[1] = GUICtrlCreateListView("", 2, 2, 146, 100, $LVS_SINGLESEL + $LVS_REPORT + $LVS_NOSORTHEADER + $WS_BORDER)
	Local $t_hListView = GUICtrlGetHandle($t_aListEditor[1])

	_GUICtrlListView_SetExtendedListViewStyle($t_hListView, $LVS_EX_DOUBLEBUFFER + $LVS_EX_FULLROWSELECT + $LVS_EX_GRIDLINES)
	_GUICtrlListView_AddColumn($t_hListView, "-Included Values-", 125, 2)
	ControlDisable("", "", HWnd(_GUICtrlListView_GetHeader($t_hListView))) ;Prevents changing column size

	;adding current items.
	For $i = 0 To UBound($aCurrent, $UBOUND_ROWS) - 1
		If $aCurrent[$i] <> "" Then _GUICtrlListView_AddItem($t_hListView, $aCurrent[$i])

		;Removing existing values from default to add those non exisiting in a combo later.
		For $j = 0 To UBound($aDefault, $UBOUND_ROWS) - 1
			If $aDefault[$j] = $aCurrent[$i] Then
				$aDefault[$j] = Null
			EndIf
		Next
	Next

	$t_aListEditor[4] = $hParent
	$t_aListEditor[5] = $hListView
	$t_aListEditor[6] = $iIndex

	GUICtrlCreateButton("Move up", 2, 104, 72)
	GUICtrlSetOnEvent(-1, "ListEditor_btnMoveUp")
	GUICtrlCreateButton("Move down", 75, 104, 72)
	GUICtrlSetOnEvent(-1, "ListEditor_btnMoveDown")

	GUICtrlCreateButton("Remove", 2, 129, 145)
	GUICtrlSetOnEvent(-1, "ListEditor_btnRemove")

	GUICtrlCreateButton("Add", 2, 154, 42)
	GUICtrlSetOnEvent(-1, "ListEditor_btnAdd")

	$t_aListEditor[2] = GUICtrlCreateCombo("", 46, 155, 100, -1, $CBS_DROPDOWNLIST)
	_GUICtrlComboBox_SetItemHeight(GUICtrlGetHandle($t_aListEditor[2]), 17)

	Local $sComboItems = "" ;stores excluded items in combo item format.
	For $i = 0 To UBound($aDefault, $UBOUND_ROWS) - 1
		If $aDefault[$i] <> Null Then $sComboItems &= "|" & $aDefault[$i]
	Next
	$sComboItems = StringMid($sComboItems, 2)
	GUICtrlSetData($t_aListEditor[2], $sComboItems)
	If $sComboItems <> "" Then _GUICtrlComboBox_SetCurSel(GUICtrlGetHandle($t_aListEditor[2]), 0)

	$t_aListEditor[3] = $sComboItems

	$g_aListEditor = $t_aListEditor
	GUISetOnEvent($GUI_EVENT_CLOSE, "ListEditor_Close", $g_aListEditor[0])

	GUISetState(@SW_SHOW, $g_aListEditor[0])
	GUISetState(@SW_DISABLE, $g_aListEditor[4])

	_WinAPI_SetFocus($g_aListEditor[0])
EndFunc   ;==>createListEditor

;Moves selected item up index
Func ListEditor_btnMoveUp()
	Local $aData = _GUICtrlListView_GetSelectedIndices($g_aListEditor[1], True)
	If $aData[0] > 0 Then
		If $aData[1] > 0 Then
			Local $sTemp = _GUICtrlListView_GetItemText($g_aListEditor[1], $aData[1] - 1)
			_GUICtrlListView_SetItemText($g_aListEditor[1], $aData[1] - 1, _GUICtrlListView_GetItemText($g_aListEditor[1], $aData[1]))
			_GUICtrlListView_SetItemText($g_aListEditor[1], $aData[1], $sTemp)

			_GUICtrlListView_SetItemSelected($g_aListEditor[1], $aData[1] - 1, True, True)
			_WinAPI_SetFocus(GUICtrlGetHandle($g_aListEditor[1]))
		Else
			_GUICtrlListView_SetItemSelected($g_aListEditor[1], $aData[1], True, True)
			_WinAPI_SetFocus(GUICtrlGetHandle($g_aListEditor[1]))
		EndIf
	EndIf
EndFunc   ;==>ListEditor_btnMoveUp

;Moves selected item down in index
Func ListEditor_btnMoveDown()
	Local $aData = _GUICtrlListView_GetSelectedIndices($g_aListEditor[1], True)
	If $aData[0] > 0 Then
		If $aData[1] < _GUICtrlListView_GetItemCount($g_aListEditor[1]) - 1 Then
			Local $sTemp = _GUICtrlListView_GetItemText($g_aListEditor[1], $aData[1] + 1)
			_GUICtrlListView_SetItemText($g_aListEditor[1], $aData[1] + 1, _GUICtrlListView_GetItemText($g_aListEditor[1], $aData[1]))
			_GUICtrlListView_SetItemText($g_aListEditor[1], $aData[1], $sTemp)

			_GUICtrlListView_SetItemSelected($g_aListEditor[1], $aData[1] + 1, True, True)
			_WinAPI_SetFocus(GUICtrlGetHandle($g_aListEditor[1]))
		Else
			_GUICtrlListView_SetItemSelected($g_aListEditor[1], $aData[1], True, True)
			_WinAPI_SetFocus(GUICtrlGetHandle($g_aListEditor[1]))
		EndIf
	EndIf
EndFunc   ;==>ListEditor_btnMoveDown

;Removes item selected from listview and adds to combobox
Func ListEditor_btnRemove()
	Local $aData = _GUICtrlListView_GetSelectedIndices($g_aListEditor[1], True)
	If $aData[0] > 0 Then
		$g_aListEditor[3] &= "|" & _GUICtrlListView_GetItemText($g_aListEditor[1], $aData[1])

		If StringMid($g_aListEditor[3], 1, 1) = "|" Then $g_aListEditor[3] = StringMid($g_aListEditor[3], 2)

		GUICtrlSetData($g_aListEditor[2], "")
		GUICtrlSetData($g_aListEditor[2], $g_aListEditor[3])

		_GUICtrlListView_DeleteItemsSelected($g_aListEditor[1])
		_GUICtrlComboBox_SetCurSel(GUICtrlGetHandle($g_aListEditor[2]), 0)
	EndIf
EndFunc   ;==>ListEditor_btnRemove

;Adds item from combobox to listview
Func ListEditor_btnAdd()
	Local $sText = GUICtrlRead($g_aListEditor[2])
	If $sText <> "" Then
		_GUICtrlListView_AddItem($g_aListEditor[1], $sText)

		$g_aListEditor[3] = StringReplace(StringReplace($g_aListEditor[3], $sText, ""), "||", "|")
		GUICtrlSetData($g_aListEditor[2], "")
		GUICtrlSetData($g_aListEditor[2], $g_aListEditor[3])
		_GUICtrlComboBox_SetCurSel(GUICtrlGetHandle($g_aListEditor[2]), 0)
	EndIf
EndFunc   ;==>ListEditor_btnAdd

;Destroys Window and saves data into listview item
Func ListEditor_Close()
	Opt("GUIOnEventMode", 0)
	; Saves changed settings to the listview.
	Local $sNew = "" ;
	Local $iSize = _GUICtrlListView_GetItemCount($g_aListEditor[1])
	For $i = 0 To $iSize - 1
		$sNew &= "," & _GUICtrlListView_GetItemText($g_aListEditor[1], $i)
	Next
	$sNew = StringMid($sNew, 2)

	_GUICtrlListView_SetItemText($g_aListEditor[5], $g_aListEditor[6], $sNew, 1)

	_WinAPI_DestroyWindow($g_aListEditor[0])
	GUISetState(@SW_ENABLE, $g_aListEditor[4])

	_GUICtrlListView_SetItemSelected($g_aListEditor[5], $g_aListEditor[6], True, True)
	_WinAPI_SetFocus($g_aListEditor[5])

	_saveSettings()
EndFunc   ;==>ListEditor_Close

; Show a menu in a given GUI window which belongs to a given GUI ctrl
Func ShowMenu($hWnd, $idContext)
	Local $aPos, $x, $y
	Local $hMenu = GUICtrlGetHandle($idContext)

	$aPos = MouseGetPos()

	$x = $aPos[0]
	$y = $aPos[1]

	TrackPopupMenu($hWnd, $hMenu, $x, $y)
EndFunc   ;==>ShowMenu

; Show at the given coordinates (x, y) the popup menu (hMenu) which belongs to a given GUI window (hWnd)
Func TrackPopupMenu($hWnd, $hMenu, $x, $y)
	DllCall("user32.dll", "int", "TrackPopupMenuEx", "hwnd", $hMenu, "int", 0, "int", $x, "int", $y, "hwnd", $hWnd, "ptr", 0)
EndFunc   ;==>TrackPopupMenu

#cs ##########################################
	Functions for changing control data and display
#ce ##########################################

Func ChangeScript()
	;Change listview display for script configs
	Local $sItem ;Stores selected item text
	_GUICtrlComboBox_GetLBText($hCmb_Scripts, _GUICtrlComboBox_GetCurSel($hCmb_Scripts), $sItem)

	If StringLeft($sItem, 1) = "_" Then
		ControlDisable("", "", $hBtn_Start)
	Else
		ControlEnable("", "", $hBtn_Start)
	EndIf

	$sItem = StringReplace($sItem, " ", "_")

	Local $aScript = getScriptData($g_ascripts, $sItem)
	If IsArray($aScript) Then
		displayScriptData($hLV_ScriptConfig, $aScript)
		GUICtrlSetData($hLbl_ScriptDescription, $aScript[1])
	EndIf
EndFunc   ;==>ChangeScript

;Script data [[script, description, [[config, value, description], [..., ..., ...]]], ...]
Func setScripts(ByRef $aScripts, $sPath, $sCachePath = "")
	Local $sData ;Contains unparsed data
	If FileExists($sPath) = True Then
		$sData = FileRead($sPath)
	Else
		$sData = BinaryToString(InetRead($sPath, $INET_FORCERELOAD))
		If $sCachePath <> "" Then
			Local $hFile = FileOpen($sCachePath, $FO_OVERWRITE + $FO_CREATEPATH)
			FileWrite($hFile, $sData)
			FileClose($hFile)
		EndIf
	EndIf
	If $sData = "" Then
		Return -1
	EndIf

	Local $c = StringSplit($sData, "", $STR_NOCOUNT)

	Local $t_aScripts = $g_ascripts ;Temporarily stores script data
	Local $t_aScript[3] ;Stores single script

	Local $t_aConfig[5]
	Local $t_aConfigs[0]

	Local $bScript = False
	For $i = -1 To UBound($c) - 1
		If nextValidChar($c, $i) = -1 Then ExitLoop
		If $bScript = False Then
			If $c[$i] = "[" Then
				nextValidChar($c, $i)
				$t_aScript[0] = getNextField($c, $i)
				$bScript = True
			EndIf
		Else
			Switch $c[$i]
				Case "[" ;field
					nextValidChar($c, $i)
					Local $cur_sField = getNextField($c, $i)
					Switch $cur_sField
						Case "description"
							$t_aScript[1] = getNextString($c, $i)
						Case "text", "combo", "setting", "list"
							$t_aConfig[3] = $cur_sField
							While $c[$i] <> "]"
								nextValidChar($c, $i)
								Local $sField = getNextField($c, $i)
								Switch $sField
									Case "name"
										$t_aConfig[0] = StringReplace(getNextString($c, $i), " ", "_")
									Case "description"
										$t_aConfig[2] = getNextString($c, $i)
									Case "default"
										$t_aConfig[1] = getNextString($c, $i)
									Case "data"
										$t_aConfig[4] = getNextString($c, $i)
									Case Else
										MsgBox(0, "", "Unknown field: " & $sField)
										Return -1
								EndSwitch
							WEnd

							If $c[$i] = "]" Then
								ReDim $t_aConfigs[UBound($t_aConfigs) + 1]
								$t_aConfigs[UBound($t_aConfigs) - 1] = $t_aConfig
							EndIf
					EndSwitch
				Case "]"
					$t_aScript[2] = $t_aConfigs
					Local $t_aNewConfig[0]
					$t_aConfigs = $t_aNewConfig

					If getScriptIndex($t_aScripts, $t_aScript[0]) = -1 Then
						ReDim $t_aScripts[UBound($t_aScripts) + 1]
						$t_aScripts[UBound($t_aScripts) - 1] = $t_aScript
					EndIf

					$bScript = False
			EndSwitch

		EndIf
	Next

	$aScripts = $t_aScripts
EndFunc   ;==>setScripts

Func getNextString($aChar, ByRef $iIndex)
	Local $sText = ""
	While $aChar[$iIndex] <> '"'
		nextValidChar($aChar, $iIndex)
	WEnd

	nextValidChar($aChar, $iIndex)
	While $aChar[$iIndex] <> '"'
		$sText &= $aChar[$iIndex]
		$iIndex += 1
	WEnd

	nextValidChar($aChar, $iIndex)
	Return $sText
EndFunc   ;==>getNextString

Func getNextField($aChar, ByRef $iIndex)
	Local $sText = ""

	While $aChar[$iIndex] <> ':'
		If StringIsSpace($aChar[$iIndex]) = False Then $sText &= $aChar[$iIndex]
		$iIndex += 1
	WEnd

	Return $sText
EndFunc   ;==>getNextField

Func nextValidChar($aChar, ByRef $iIndex)
	$iIndex += 1
	While ($iIndex < UBound($aChar)) And StringIsSpace($aChar[$iIndex])
		$iIndex += 1
	WEnd

	If $iIndex >= UBound($aChar) Then Return -1
EndFunc   ;==>nextValidChar

;Replaces values in script list with values saved in profile
Func getConfigsFromFile(ByRef $aScripts, $sScript, $sProfilePath = $g_sProfilePath)
	$sScript = StringReplace($sScript, " ", "_")
	Local $iIndex = getScriptIndex($aScripts, $sScript)
	If $iIndex = -1 Then
		$g_sErrorMessage = "getConfigsFromFile() => Could not find script data."
		Return -1
	EndIf

	Local $t_aRawConfig = getArgsFromFile($sProfilePath & "\" & $sScript)

	;Creates temporary variables to access the nested arrays and values.
	Local $t_aScript = $aScripts[$iIndex] ;[script, description, [[config, value, description], [..., ..., ...]]]
	Local $t_aConfigs = $t_aScript[2] ;[[config, value, description], [..., ..., ...]]

	For $i = 0 To UBound($t_aConfigs) - 1
		Local $t_aConfig = $t_aConfigs[$i]
		Local $sValue = getArg($t_aRawConfig, $t_aConfig[0])
		If $sValue <> -1 Then $t_aConfig[1] = $sValue

		;save new config value
		$t_aConfigs[$i] = $t_aConfig
	Next

	;save new configs to script
	$t_aScript[2] = $t_aConfigs

	;save to script list
	$aScripts[$iIndex] = $t_aScript
EndFunc   ;==>getConfigsFromFile

#cs
	Function: Retrieves script data with specified script name
	Parameters:
	$aScripts: [[script, description, [[config, value, description], [..., ..., ...]]], ...]
	$sScript: The script text to find.
	Returns: The array of the script
	`Empty string on not found.
#ce
Func getScriptData($aScripts, $sScript)
	Local $iSize = UBound($aScripts, $UBOUND_ROWS)
	For $i = 0 To $iSize - 1
		;Looks at first element of each array. The script in: [script, description, [[config, value, description], [..., ..., ...]]]
		Local $aScript = $aScripts[$i]
		If $aScript[0] = $sScript Then Return $aScript
	Next

	Return ""
EndFunc   ;==>getScriptData

#cs
	Function: Retrieves script data with specified script name
	Parameters:
	$aScripts: [[script, description, [[config, value, description], [..., ..., ...]]], ...]
	$sScript: The script text to find.
	Returns: Index of the script
	`-1 if not found.
#ce
Func getScriptIndex(ByRef $aScripts, $sScript)
	Local $iSize = UBound($aScripts, $UBOUND_ROWS)
	For $i = 0 To $iSize - 1
		;Looks at first element of each array. The script in: [script, description, [[config, value, description], [..., ..., ...]]]
		Local $aScript = $aScripts[$i]
		If $aScript[0] = $sScript Then Return $i
	Next

	Return -1
EndFunc   ;==>getScriptIndex

#cs
	Function: Display script data to a listview control
	Parameters:
	$hListView: Reference to listview control handle
	$aScript: [script, description, [[config, value, description], [..., ..., ...]]]
#ce
Func displayScriptData(ByRef $hListView, $aScript)
	;Must be in format: [script, description, [[config, value, description], [..., ..., ...]]]
	If IsArray($aScript) = False Then
		$g_sErrorMessage = "displayScriptData() => Argument is not an array."
		Return -1
	EndIf

	If UBound($aScript, $UBOUND_ROWS) <> 3 Then
		$g_sErrorMessage = "displayScriptData() => Incorrect argument format"
		Return -1
	EndIf

	Local $aConfigList = $aScript[2] ;[[config, value, description], [..., ..., ...]]
	Local $iSize = UBound($aConfigList, $UBOUND_ROWS)

	;Reset ListView:
	_GUICtrlListView_DeleteAllItems($hListView)
	For $i = 0 To $iSize - 1
		Local $aConfig = $aConfigList[$i] ;[config, value, description]
		_GUICtrlListView_AddItem($hListView, StringReplace($aConfig[0], "_", " "))
		_GUICtrlListView_AddSubItem($hListView, $i, $aConfig[1], 1)

		;hidden values
		_GUICtrlListView_AddSubItem($hListView, $i, $aConfig[2], 2) ;description
		_GUICtrlListView_AddSubItem($hListView, $i, $aConfig[3], 3) ;type
		_GUICtrlListView_AddSubItem($hListView, $i, $aConfig[4], 4) ;type values
	Next
EndFunc   ;==>displayScriptData

#cs
	Function: Saves script data to list of scripts
	Parameters:
	$aScripts: [[script, description, [[config, value, description], [..., ..., ...]]], ...]
	$sScript: The script text to save to.
	$hListView: Listview will contain script data. C1:Config Name, C2: Value. C3:Description, C4:Type, C5:Type Values
	$sFilePath: File path to save data to. If empty string then does not save.
#ce
Func saveSettings(ByRef $aScripts, $sScript, $hListView, $sFilePath = $g_sProfilePath & "\" & StringReplace($sScript, " ", "_"))
	$sScript = StringReplace($sScript, " ", "_")
	Local $iIndex = getScriptIndex($aScripts, $sScript)
	If $iIndex = -1 Then
		$g_sErrorMessage = "saveSettings() => Script not found in database. Could not save."
		Return -1
	EndIf

	;Creates temporary variables to access the nested arrays and values.
	Local $t_aScript = $aScripts[$iIndex] ;[script, description, [[config, value, description], [..., ..., ...]]]
	Local $t_aConfigs = $t_aScript[2] ;[[config, value, description], [..., ..., ...]]

	;Going through listview column 2 items
	Local Const $eColumn = 1 ;The listview column with the values
	For $i = 0 To UBound($t_aConfigs) - 1 ;Assumes the listview has the same number of rows as the number of configs
		Local $t_aConfig = $t_aConfigs[$i] ;[config, value, description]
		$t_aConfig[1] = _GUICtrlListView_GetItemText($hListView, $i, $eColumn)

		;save new config value
		$t_aConfigs[$i] = $t_aConfig

	Next

	;save new configs to script
	$t_aScript[2] = $t_aConfigs

	;save to script list
	$aScripts[$iIndex] = $t_aScript

	;save to file
	If $sFilePath <> "" Then
		Local $sConfigData = ""
		For $i = 0 To UBound($t_aConfigs) - 1
			Local $t_aConfig = $t_aConfigs[$i] ;[config, value, description]
			$sConfigData &= @CRLF & $t_aConfig[0] & ':"' & $t_aConfig[1] & '"'
		Next
		$sConfigData = StringMid($sConfigData, 2)

		FileOpen($sFilePath, $FO_OVERWRITE + $FO_CREATEPATH)
		FileWrite($sFilePath, $sConfigData)
		FileClose($sFilePath)
	EndIf

	UpdateSettings()
EndFunc   ;==>saveSettings

;saveSettings for main GUI
Func _saveSettings()
	Local $sScriptName ;Holds current script name
	_GUICtrlComboBox_GetLBText($hCmb_Scripts, _GUICtrlComboBox_GetCurSel($hCmb_Scripts), $sScriptName)
	saveSettings($g_ascripts, $sScriptName, $hLV_ScriptConfig)
EndFunc   ;==>_saveSettings

;updates global variables
Func UpdateSettings()
	Local $aScriptData = getScriptData($g_ascripts, "_Config")
	If IsArray($aScriptData) = False Then
		MsgBox($MB_ICONERROR + $MB_OK, "Could not update script data.", "Unable to retrieve _Config data, using default configs. Try re-downloading all the files manually.")
		Return 0
	EndIf

	Local $aConfig = formatArgs($aScriptData[2]) ;This is the list of configs

	;[script, description, [[config, value, description], [..., ..., ...]]]
	$g_sProfilePath = @ScriptDir & "\profiles\" & getArg($aConfig, "Profile_Name") & "\"

	Local $t_sAdbPath = getArg($aConfig, "ADB_Path")
	Local $t_sAdbDevice = getArg($aConfig, "ADB_Device")
	Local $t_sAdbMethod = getArg($aConfig, "ADB_Method")
	Local $t_sEmuSharedFolder[2] = [getArg($aConfig, "ADB_Shared_Folder1"), getArg($aConfig, "ADB_Shared_Folder2")]
	Local $t_sWindowTitle = getArg($aConfig, "Emulator_Title")
	Local $t_sControlInstance = "[CLASS:" & getArg($aConfig, "Emulator_Class") & "; INSTANCE:" & getArg($aConfig, "Emulator_Instance") & "]"
	$g_iBackgroundMode = Execute("$BKGD_" & StringUpper(getArg($aConfig, "Capture_Mode")))
	$g_iMouseMode = Execute("$MOUSE_" & StringUpper(getArg($aConfig, "Mouse_Mode")))
	$g_iSwipeMode = Execute("$SWIPE_" & StringUpper(getArg($aConfig, "Swipe_Mode")))
	Switch getArg($aConfig, "Restart_Time")
		Case "Never"
			$g_iRestartTime = 0
		Case "10 Minutes"
			$g_iRestartTime = 10
		Case "20 Minutes"
			$g_iRestartTime = 20
		Case "30 Minutes"
			$g_iRestartTime = 30
		Case "40 Minutes"
			$g_iRestartTime = 40
		Case "50 Minutes"
			$g_iRestartTime = 50
		Case "60 Minutes"
			$g_iRestartTime = 60
	EndSwitch
	$g_bSaveDebug = (getArg($aConfig, "Save_Debug_Log") = "Enabled")
	$g_bLogClicks = (getArg($aConfig, "Log_Clicks") = "Enabled")
	$g_iDesktopScaling = getArg($aConfig, "Desktop_Scaling")

	;handles default settings
	If StringLeft($g_iDesktopScaling, 1) = "~" Then
		$g_iDesktopScaling = $d_iDesktopScaling
	EndIf

	If StringLeft($t_sAdbPath, 1) <> "~" Then
		$g_sAdbPath = $t_sAdbPath
	Else
		$g_sAdbPath = $d_sAdbPath
	EndIf

	If StringLeft($t_sAdbDevice, 1) <> "~" Then
		$g_sAdbDevice = $t_sAdbDevice
	Else
		$g_sAdbDevice = $d_sAdbDevice
	EndIf

	If StringLeft($t_sEmuSharedFolder[0], 1) <> "~" Then
		$g_sEmuSharedFolder[0] = $t_sEmuSharedFolder[0]
	Else
		$g_sEmuSharedFolder[0] = $d_sEmuSharedFolder[0]
	EndIf

	If StringLeft($t_sEmuSharedFolder[1], 1) <> "~" Then
		$g_sEmuSharedFolder[1] = $t_sEmuSharedFolder[1]
	Else
		$g_sEmuSharedFolder[1] = $d_sEmuSharedFolder[1]
	EndIf

	If StringLeft($t_sAdbMethod, 1) <> "~" Then
		$g_sAdbMethod = $t_sAdbMethod
	Else
		$g_sAdbMethod = $d_sAdbMethod
	EndIf

	If StringLeft($t_sWindowTitle, 1) <> "~" Then
		$g_sWindowTitle = $t_sWindowTitle
	Else
		$g_sWindowTitle = $d_sWindowTitle
	EndIf

	If StringLeft($t_sControlInstance, 1) <> "~" Then
		$g_sControlInstance = $t_sControlInstance
	Else
		$g_sControlInstance = $d_sControlInstance
	EndIf

	$g_hWindow = WinGetHandle($g_sWindowTitle)
	$g_hControl = ControlGetHandle($g_hWindow, "", $g_sControlInstance)
EndFunc   ;==>UpdateSettings
