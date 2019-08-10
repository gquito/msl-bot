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
EndFunc

Func GUI_HANDLE() 
    Local $iCode = GUIGetMsg(1)
    GUI_HANDLE_MESSAGE($iCode)
EndFunc

Func GUI_HANDLE_MESSAGE($iCode)
    Switch $iCode[1]
        Case $g_hParent
            Switch $iCode[0]
                Case $g_idLbl_Donate
                    ShellExecute("https://paypal.me/GkevinOD/10")
                Case $g_idLbl_Discord
                    ShellExecute("https://discord.gg/UQGRnwf")
                 Case $idLbl_List
                    MsgBox($MB_ICONINFORMATION+$MB_OK, "MSL Donator Features", "Completed: " & @CRLF & "- Auto PvP, Guided Auto, Daily Quest, Complete Bingo, Farm Forever, TOC, Gold Dungeon" & @CRLF & @CRLF & "In Progress: " & @CRLF & "- Buy Items, Script Schedule, Colossal, Hatch Eggs, Dragons")
                Case $g_idCkb_Information, $g_idCkb_Error, $g_idCkb_Process, $g_idCkb_Debug
                    Local $sFilter = ""
                    If (BitAND(GUICtrlRead($g_idCkb_Information), $GUI_CHECKED) = $GUI_CHECKED) Then $sFilter &= "Information,"
                    If (BitAND(GUICtrlRead($g_idCkb_Error), $GUI_CHECKED) = $GUI_CHECKED) Then $sFilter &= "Error,"
                    If (BitAND(GUICtrlRead($g_idCkb_Process), $GUI_CHECKED) = $GUI_CHECKED) Then $sFilter &= "Process,"
                    If (BitAND(GUICtrlRead($g_idCkb_Debug), $GUI_CHECKED) = $GUI_CHECKED) Then $sFilter &= "Debug,"

                    $g_sLogFilter = $sFilter
                    Log_Display_Reset()
                Case $g_idBtn_Detach
                    $g_aLogSize = ControlGetPos("","",$g_hLV_Log)
                    _GUICtrlListView_Destroy($g_hLV_Log)
                    GUICtrlDelete($g_idBtn_Detach)
                    GUICtrlDelete($g_idCkb_Information)
                    GUICtrlDelete($g_idCkb_Error)
                    GUICtrlDelete($g_idCkb_Process)
                    GUICtrlDelete($g_idCkb_Debug)

                    Local $aWinPos = WinGetPos($g_sAppTitle)
                    _WinMove($g_sAppTitle, "", $aWinPos[0], $aWinPos[1], 400, 420)
                    Local $aControlPos = ControlGetPos("","",$g_hLV_Stat)
                    _ControlMove("", "", $g_hLV_Stat, $aControlPos[0], $aControlPos[1], $aControlPos[2], 240)
                    GUICtrlSetResizing($g_idLV_Stat, $GUI_DOCKTOP+$GUI_DOCKBOTTOM)
                    _WinMove($g_sAppTitle, "", $aWinPos[0], $aWinPos[1])

                    CreateLogWindow()
                Case $g_hM_DebugInput
                    If ($g_hEditConfig <> Null) Then _endEdit()
                    Debug()
                Case $g_hM_ScriptTest
                    RunMenuItem("ScriptTest")
                Case $g_hM_GetAdbDevices
                    RunMenuItem("ADB_GetDevices")
                Case $g_hM_RestartNox
                    RunMenuItem("RestartNox")
                Case $g_hM_RestartGame
                    RunMenuItem("RestartGame")
                Case $g_hM_GetLocation
                    RunMenuItem("GetLocation")
                Case $g_hM_SetLocation
                    RunMenuItem("SetLocation")
                Case $g_hM_SetNewLocation
                    RunMenuItem("SetNewLocation")
                Case $g_hM_TestLocation
                    RunMenuItem("TestLocation")
                Case $g_hM_IsGameRunning
                    RunMenuItem("IsGameRunning")
                Case $g_hM_IsAdbWorking
                    RunMenuItem("ADB_isWorking")
                Case $g_hM_isPixel
                    RunMenuItem("IsPixel")
                Case $g_hM_SetPixel
                    RunMenuItem("SetPixel")
                Case $g_hM_Navigate
                    RunMenuItem("Navigate")
                Case $g_hM_getColor
                    RunMenuItem("GetColor")
                Case $g_hM_DoHourly
                    RunMenuItem("DoHourly")
                Case $g_hM_FullScreenshot
                    RunMenuItem("takeScreenshot")
                Case $g_hM_PartialScreenshot
                    RunMenuItem("PartialScreenshot")
                Case $g_hM_OpenScreenshotFolder
                    RunMenuItem("openScreenshotFolder")
                Case $g_hM_GetAirshipPosition
                    RunMenuItem("GetAirshipPosition")
                Case $g_idBtn_Stop, $g_hM_StopScript
                    If ($g_bRunning) Then Stop()
                Case $g_hM_PauseScript
                    If ($g_bRunning) Then Pause()
                Case $GUI_EVENT_CLOSE, $g_hM_ForceQuit
                    GUISetState(@SW_HIDE, $g_hParent)
                    CloseApp()
                Case Else
                    ;Handles the combo config contextmenu
                    handleCombo($iCode[0], $g_hLV_ScriptConfig)
            EndSwitch
        Case $g_hLogWindow
            Switch $iCode[0]
                Case $GUI_EVENT_CLOSE
                    GUISwitch($g_hParent)
                    _GUICtrlTab_ClickTab($g_hTb_Main, 1)

                    Local $aWinPos = WinGetPos($g_sAppTitle)
                    _WinMove($g_sAppTitle, "", $aWinPos[0], $aWinPos[1], 400, 420)

                    GUIDelete($g_hLogWindow)
                    
                    BuildLogArea(True)

                    _GUICtrlTab_ClickTab($g_hTb_Main, 0)
                    _GUICtrlTab_ClickTab($g_hTb_Main, 1)

                    _WinMove($g_sAppTitle, "", $aWinPos[0], $aWinPos[1], $aWinPos[2], $aWinPos[3])
                    
                    If ($g_hLV_FunctionLevels <> Null) Then
                        GUICtrlDelete($g_hLV_FunctionLevels)
                        $g_hLV_FunctionLevels = Null
                    EndIf
                    If ($g_idLV_FunctionLevels <> Null) Then $g_idLV_FunctionLevels = Null

                    $g_sLogFilter = "Information,Process,Error"
                    Log_Display_Reset()
                Case $g_idCkb_Information, $g_idCkb_Error, $g_idCkb_Process, $g_idCkb_Debug
                    Local $sFilter = ""
                    If (BitAND(GUICtrlRead($g_idCkb_Information), $GUI_CHECKED) = $GUI_CHECKED) Then $sFilter &= "Information,"
                    If (BitAND(GUICtrlRead($g_idCkb_Error), $GUI_CHECKED) = $GUI_CHECKED) Then $sFilter &= "Error,"
                    If (BitAND(GUICtrlRead($g_idCkb_Process), $GUI_CHECKED) = $GUI_CHECKED) Then $sFilter &= "Process,"
                    If (BitAND(GUICtrlRead($g_idCkb_Debug), $GUI_CHECKED) = $GUI_CHECKED) Then $sFilter &= "Debug,"

                    $g_sLogFilter = $sFilter
                    Log_Display_Reset()
            EndSwitch
        Case $g_hMessageBox
            Switch $iCode[0]
                Case $GUI_EVENT_CLOSE
                    $g_hMessageBox
                    GUIDelete($g_hMessageBox)
            EndSwitch
    EndSwitch
EndFunc

Func WM_COMMAND($hWnd, $iMsg, $wParam, $lParam)
    #forceref $hWnd, $iMsg, $wParam
    Local $nNotifyCode = BitShift($wParam, 16)
    Local $nID = BitAND($wParam, 0xFFFF)
    Local $hCtrl = $lParam

    Switch $hCtrl
        
        Case $g_hBtn_Start
            If ($nNotifycode = $BN_CLICKED) Then
                If ($g_hEditConfig <> Null) Then _endEdit()
                Start()
            EndIf
        Case $g_hBtn_Pause
            If ($nNotifyCode = $BN_CLICKED) Then
                Pause()
            EndIf
        Case $g_hBtn_StatReset
            If ($nNotifyCode = $BN_CLICKED) Then
                If (MsgBox($MB_YESNO+$MB_ICONQUESTION, "Reset Confirmation", "Are you sure you wish to reset the stats?", 30) = $IDYES) Then
                    Stat_Reset($g_aStats, $g_hLV_OverallStats)
                EndIf
            EndIf
        Case $g_hCmb_Scripts
            If ($nNotifyCode = $CBN_SELCHANGE) Then
                If ($g_hEditConfig <> Null) Then _endEdit()
                ChangeScript()
            EndIf
    EndSwitch
    Return $GUI_RUNDEFMSG
EndFunc 

Local Const $LV_DBLCLK = -114
Local Const $LV_RCLICK = -5
Func WM_NOTIFY($hWnd, $iMsg, $wParam, $lParam)
    #forceref $hWnd, $iMsg, $wParam
    Local $hWndFrom, $iCode, $tNMHDR, $tInfo

    $tNMHDR = DllStructCreate($tagNMHDR, $lParam)
    $hWndFrom = HWnd(DllStructGetData($tNMHDR, "hWndFrom"))
    $iCode = DllStructGetData($tNMHDR, "Code")

    Switch $hWndFrom
        Case $g_hLV_ScriptConfig
            Switch $iCode
                Case $LVN_ITEMCHANGED, $NM_CLICK
                    ;handles edit updates 
                    If ($g_hEditConfig <> Null) Then endEdit()

                    ;Switches config description label
                    Local $tScriptConfigInfo = DLLStructCreate($tagNMITEMACTIVATE, $lParam)

                    Local $iIndex = DLLStructGetData($tScriptConfigInfo, "Index")
                    Local $sText = _GUICtrlListView_GetItemText($g_hLV_ScriptConfig, $iIndex, 2)

                    If ($sText = "") Then
                        GUICtrlSetData($g_hLbl_ConfigDescription, "Click on a setting for a description.")
                    Else
                        GUICtrlSetData($g_hLbl_ConfigDescription, $sText)
                    EndIf
                Case $LV_DBLCLK, $LV_RCLICK
                    ;Handles changes in the listview
                    Local $tScriptConfigInfo = DLLStructCreate($tagNMITEMACTIVATE, $lparam)

                    Local $iIndex = DLLStructGetData($tScriptConfigInfo, "Index")
                    Local $sType = _GUICtrlListView_GetItemText($g_hLV_ScriptConfig, $iIndex, 3)
                    Local $sTypeValues = _GUICtrlListView_GetItemText($g_hLV_ScriptConfig, $iIndex, 4)

                    ;Handles edits for settings
                    Switch $sType
                        Case "combo"
                            ;Creating context menu from items specified by the combo type.
                            Local $t_aItems = StringSplit($sTypeValues, ",", $STR_NOCOUNT)
                            createComboMenu($g_aComboMenu, $t_aItems)  

                            ;Displays a context menu to choose an item from.
                            ShowMenu($g_hParent, $g_aComboMenu[0])
                        Case "text"
                            ;Shows edit in the position.
                            createEdit($g_hEditConfig, $g_iEditConfig, $g_hLV_ScriptConfig)
                        Case "list"
                            createListEditor($g_hParent, $g_hLV_ScriptConfig, $iIndex)
                        Case "setting"
                            Local $sText = _GUICtrlListView_GetItemText($g_hLV_ScriptConfig, $iIndex, 1)
                            Local $iScriptIndex = _GUICtrlComboBox_FindString($g_hCmb_Scripts, $sText)
                            If ($iScriptIndex <> -1) Then 
                                _GUICtrlComboBox_SetCurSel($g_hCmb_Scripts, $iScriptIndex)
                                ChangeScript()
                            EndIf
                    EndSwitch
            EndSwitch
        Case $g_hLV_Log
            Switch $iCode
                Case $NM_RCLICK
                    Local $item = _GUICtrlListView_SubItemHitTest($g_hLV_Log)
                    If ($item[0] <> -1) Then ClipPut(_GUICtrlListView_GetItemText($g_hLV_Log,$item[0],1))
            EndSwitch
    EndSwitch
    Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_NOTIFY

;Some helper functions for handling controls----

Func CreateLogWindow()
    Local $aPos = WinGetPos($g_sAppTitle)

    $g_hLogWindow = GUICreate($g_sAppTitle & " Log Window", $aPos[2]-15, $aPos[3]-15, $aPos[0]+$aPos[2]-15, $aPos[1], $WS_SIZEBOX+$WS_MAXIMIZEBOX+$WS_MINIMIZEBOX, -1)
    GUISetState(@SW_SHOW, $g_hLogWindow)

    $g_idCkb_Information = _GUICtrlCreateCheckbox("Info", 10, 4, 60, 23)
    GUICtrlSetState(-1, $GUI_CHECKED)
    $g_idCkb_Error = _GUICtrlCreateCheckbox("Error", 70, 4, 60, 23)
    GUICtrlSetState(-1, $GUI_CHECKED)
    $g_idCkb_Process = _GUICtrlCreateCheckbox("Process", 130, 4, 60, 23)
    GUICtrlSetState(-1, $GUI_CHECKED)
    $g_idCkb_Debug = _GUICtrlCreateCheckbox("Debug", 200, 4, 60, 23)
    GUICtrlSetState(-1, $GUI_UNCHECKED)

    ;REMOVE COMMENT FOR DEBUG
    ;$g_idLV_FunctionLevels = _GUICtrlCreateListView("", $aPos[2]-129, 30, 110, $aPos[3]-73, $LVS_REPORT+$LVS_NOSORTHEADER)
    ;$g_hLV_FunctionLevels = GUICtrlGetHandle($g_idLV_FunctionLevels)
    ;__GUICtrlListView_AddColumn($g_hLV_FunctionLevels, "#", 20, 0)
    ;__GUICtrlListView_AddColumn($g_hLV_FunctionLevels, "Functions", 150, 0)

    $g_idLV_Log = _GUICtrlCreateListView("", 3, 30, $aPos[2]-23, $aPos[3]-73, $LVS_REPORT+$LVS_NOSORTHEADER) ;-133 WIDTH FOR DEBUG -23 WIDTH FOR NONDEBUG
    $g_hLV_Log = GUICtrlGetHandle($g_idLV_Log)
    _GUICtrlListView_SetExtendedListViewStyle($g_hLV_Log, $LVS_EX_FULLROWSELECT+$LVS_EX_GRIDLINES)
    __GUICtrlListView_AddColumn($g_hLV_Log, "Time", 76, 0)
    __GUICtrlListView_AddColumn($g_hLV_Log, "Text", 312, 0)
    __GUICtrlListView_AddColumn($g_hLV_Log, "Type", 100, 0)
    __GUICtrlListView_AddColumn($g_hLV_Log, "Function", 100, 0)
    __GUICtrlListView_AddColumn($g_hLV_Log, "Location", 100, 0)
    __GUICtrlListView_AddColumn($g_hLV_Log, "Level", 100, 0)
    _GUICtrlListView_JustifyColumn($g_hLV_Log, 0, 0)
    _GUICtrlListView_JustifyColumn($g_hLV_Log, 1, 0)

    GUICtrlSetResizing($g_idLV_Log, $GUI_DOCKTOP+$GUI_DOCKBOTTOM+$GUI_DOCKLEFT+$GUI_DOCKRIGHT)
    GUICtrlSetResizing($g_idLV_FunctionLevels, $GUI_DOCKTOP+$GUI_DOCKBOTTOM+$GUI_DOCKRIGHT+$GUI_DOCKWIDTH)
    GUICtrlSetResizing($g_idCkb_Information, $GUI_DOCKALL)
    GUICtrlSetResizing($g_idCkb_Error, $GUI_DOCKALL)
    GUICtrlSetResizing($g_idCkb_Process, $GUI_DOCKALL)
    GUICtrlSetResizing($g_idCkb_Debug, $GUI_DOCKALL)

    $g_sLogFilter = "Information,Process,Error"
    Log_Display_Reset()
EndFunc

;Handles the combo config contextmenu
Func handleCombo(ByRef $iCode, ByRef $hListView)
    If (Not(isArray($g_aComboMenu))) Then Return
    For $i = 1 To UBound($g_aComboMenu, $UBOUND_ROWS)-1
        Local $aContext = $g_aComboMenu[$i] ;Hold [idContext, "name"]
        If ($iCode = $aContext[0]) Then
            ;Replaced text from the listview
            _GUICtrlListView_SetItemText($hListView, _GUICTrlListView_GetSelectedIndices($hListView, True)[1], $aContext[1], 1)
            _saveSettings()

            $g_aComboMenu = Null
            Return 0
        EndIf
    Next
EndFunc

;For context menu for type combo configs
Func createComboMenu(ByRef $aContextMenu, $aItems)
    Local $hDM_BooleanDummy = GUICtrlCreateDummy()
    Local $t_aContextMenu[UBound($aItems)+1]

    ;Creates an array: [idContextMenu, [idContext, "name"], [idContext, "name"]...]
    $t_aContextMenu[0] = GUICtrlCreateContextMenu($hDM_BooleanDummy)
    For $i = 1 To UBound($t_aContextMenu)-1
        Local $t_aContext = [GUICtrlCreateMenuItem($aItems[$i-1], $t_aContextMenu[0]), $aItems[$i-1]]
        $t_aContextMenu[$i] = $t_aContext
    Next

    $aContextMenu = $t_aContextMenu
EndFunc

;Takes text from edit and sets subitem (in Value column) from listview
Func handleEdit(ByRef $hEdit, ByRef $iIndex, $hListView)
    ;Handles changes to the config setting.
    Local $sNew = _GUICtrlEdit_GetText($hEdit)
    If ($sNew <> "") Then _GUICtrlListView_SetItemText($hListView, $iIndex, $sNew, 1)
    _GUICtrlEdit_Destroy($hEdit)

    If (_GUICtrlListView_GetItemText($hListView, $iIndex) = "Profile Name") Then
        SwitchProfile($sNew)
    Else
        _saveSettings()
    EndIf

    UpdateSettings()
    $hEdit = Null
    $iIndex = Null
EndFunc

Func SwitchProfile($sNew)
    $g_sProfilePath = $g_sProfileFolder & $sNew & "\"

    ;Updating cumulative stats
    _GUICtrlListView_DeleteAllItems($g_hLV_OverallStats)

    Stat_Read($g_aStats)
    Stat_Update($g_aStats, $g_hLV_OverallStats)

    Local $t_sScripts[0] ;Reset global script
    $g_aScripts = $t_sScripts

    setScripts($g_aScripts, $g_sLocalFolder &  $g_sScriptsSettings)
    setScripts($g_aScripts, $g_sLocalCacheFolder & $g_sScriptsSettings)

    For $i = 0 To UBound($g_aScripts, $UBOUND_ROWS)-1
        Local $aScript = $g_aScripts[$i]
        If (FileExists($g_sProfilePath & $aScript[0])) Then getConfigsFromFile($g_aScripts, $aScript[0])
    Next

    If (FileExists($g_sProfilePath & "_Config")) Then getConfigsFromFile($g_aScripts, "_Config", $g_sProfilePath)

    Local $t_aScripts ;Will store _Config
    Local $index = 0 ;Stores index of _Config
    For $i = 0 To UBound($g_aScripts)-1
        $t_aScripts = $g_aScripts[$i]
        If ($t_aScripts[0] = "_Config") Then
            $index = $i
            ExitLoop
        EndIf
    Next

    Local $t_aScript = $t_aScripts[2]
    Local $t_aConfig = $t_aScript[0]

    $t_aConfig[1] = $sNew
    $t_aScript[0] = $t_aConfig
    $t_aScripts[2] = $t_aScript
    $g_aScripts[$index] = $t_aScripts

    ChangeScript()
EndFunc

;For context menu for text combo configs
Func createEdit(ByRef $hEdit, ByRef $iIndex, $hListView, $bNumber = False)
    If ($iIndex = Null) Then $iIndex = _GUICtrlListView_GetSelectedIndices($hListView, True)[1]
    Local $sText = _GUICtrlListView_GetItemText($hListView, $iIndex, 1)
    Local $aSize = _GUICtrlListView_GetSubItemRect($hListView, $iIndex, 1)

    Local $aDim = [$aSize[0], $aSize[1], $aSize[2]-$aSize[0], $aSize[3]-$aSize[1]]
    Local $iStyle = $WS_VISIBLE+$ES_AUTOHSCROLL
    If ($bNumber) Then $iStyle+=$ES_NUMBER

    $hEdit = _GUICtrlEdit_Create($g_hLV_ScriptConfig, $sText, $aDim[0], $aDim[1], $aDim[2], $aDim[3], $iStyle)
    _GUICtrlEdit_SetLimitText($hEdit, 99999)
    
    _GUICtrlEdit_SetSel($hEdit, 0, -1)
    _WinAPI_SetFocus($hEdit)

    HotKeySet("{ENTER}", "endEdit")
EndFunc

;When enter is pressed acts as unfocus and runs the handle edit
Func endEdit()
    handleEdit($g_hEditConfig, $g_iEditConfig, $g_hLV_ScriptConfig)
    HotKeySet("{ENTER}")
EndFunc

Func _endEdit()
    _GUICtrlEdit_Destroy($g_hEditConfig)
    HotKeySet("{ENTER}")
EndFunc

Func createListEditor($g_hParent, $hListView, $iIndex)
    Opt("GUIOnEventMode", 1)
    ; [gui handle, listview inside gui, combo handle, combo values, parent handle, listview handle, item index]
    Local $aCurrent = StringSplit(_GUICtrlListView_GetItemText($hListView, $iIndex, 1), ",", $STR_NOCOUNT)
    Local $aDefault = StringSplit(_GUICtrlListView_GetItemText($hListView, $iIndex, 4), ",", $STR_NOCOUNT)

    Local $t_aListEditor[7] ;Holds the array items from comment above.
    Local $t_aPos = WinGetPos($g_hParent)
    $t_aListEditor[0] = _GUICreate("Edit List", 150, 182, $t_aPos[0]+(($t_aPos[2]-150)/2), $t_aPos[1]+(($t_aPos[3]-150)/2), -1, $WS_EX_TOPMOST, $g_hParent)
    $t_aListEditor[1] = _GUICtrlCreateListView("", 2, 2, 146, 100, $LVS_SINGLESEL+$LVS_REPORT+$LVS_NOSORTHEADER+$WS_BORDER)
    Local $t_hListView = GUICtrlGetHandle($t_aListEditor[1])

    _GUICtrlListView_SetExtendedListViewStyle($t_hListView, $LVS_EX_DOUBLEBUFFER+$LVS_EX_FULLROWSELECT+$LVS_EX_GRIDLINES)
    __GUICtrlListView_AddColumn($t_hListView, "-Included Values-", 125, 2)
    ControlDisable("", "", HWnd(_GUICtrlListView_GetHeader($t_hListView))) ;Prevents changing column size

    ;adding current items.
    For $i = 0 To UBound($aCurrent, $UBOUND_ROWS)-1
        If ($aCurrent[$i] <> "") Then _GUICtrlListView_AddItem($t_hListView, $aCurrent[$i])

        ;Removing existing values from default to add those non exisiting in a combo later.
        For $j = 0 To UBound($aDefault, $UBOUND_ROWS)-1
            If ($aDefault[$j] = $aCurrent[$i]) Then $aDefault[$j] = Null
        Next
    Next

    $t_aListEditor[4] = $g_hParent
    $t_aListEditor[5] = $hListView
    $t_aListEditor[6] = $iIndex

    _GUICtrlCreateButton("Move up", 2, 104, 72)
    GUICtrlSetOnEvent(-1, "ListEditor_btnMoveUp")
    _GUICtrlCreateButton("Move down", 75, 104, 72)
    GUICtrlSetOnEvent(-1, "ListEditor_btnMoveDown")

    _GUICtrlCreateButton("Remove", 2, 129, 145)
    GUICtrlSetOnEvent(-1, "ListEditor_btnRemove")

    _GUICtrlCreateButton("Add", 2, 154, 42)
    GUICtrlSetOnEvent(-1, "ListEditor_btnAdd")

    $t_aListEditor[2] = _GUICtrlCreateCombo("", 46, 155, 100, -1, $CBS_DROPDOWNLIST)
    _GUICtrlComboBox_SetItemHeight(GUICtrlGetHandle($t_aListEditor[2]), 17)

    Local $sComboItems = "" ;stores excluded items in combo item format.
    For $i = 0 To UBound($aDefault, $UBOUND_ROWS)-1
        If ($aDefault[$i] <> Null) Then $sComboItems &= "|" & $aDefault[$i]
    Next
    $sComboItems = StringMid($sComboItems, 2)
    GUICtrlSetData($t_aListEditor[2], $sComboItems)
    If ($sComboItems <> "") Then _GUICtrlComboBox_SetCurSel(GUICtrlGetHandle($t_aListEditor[2]), 0)

    $t_aListEditor[3] = $sComboItems

    $g_aListEditor = $t_aListEditor
    GUISetOnEvent($GUI_EVENT_CLOSE, "ListEditor_Close", $g_aListEditor[0])

    GUISetState(@SW_SHOW, $g_aListEditor[0])
    GUISetState(@SW_DISABLE, $g_aListEditor[4])

    _WinAPI_SetFocus($g_aListEditor[0])
EndFunc

;Moves selected item up index
Func ListEditor_btnMoveUp()
    Local $aData = _GUICtrlListView_GetSelectedIndices($g_aListEditor[1], True)
    If ($aData[0] > 0) Then
        If ($aData[1] > 0) Then
            Local $sTemp = _GUICtrlListView_GetItemText($g_aListEditor[1], $aData[1]-1)
            _GUICtrlListView_SetItemText($g_aListEditor[1], $aData[1]-1, _GUICtrlListView_GetItemText($g_aListEditor[1], $aData[1]))
            _GUICtrlListView_SetItemText($g_aListEditor[1], $aData[1], $sTemp)
            
            _GUICtrlListView_SetItemSelected($g_aListEditor[1], $aData[1]-1, True, True)
            _WinAPI_SetFocus(GUICtrlGetHandle($g_aLIstEditor[1]))
        Else
            _GUICtrlListView_SetItemSelected($g_aListEditor[1], $aData[1], True, True)
            _WinAPI_SetFocus(GUICtrlGetHandle($g_aLIstEditor[1]))
        EndIf
    EndIf
EndFunc

;Moves selected item down in index
Func ListEditor_btnMoveDown()
    Local $aData = _GUICtrlListView_GetSelectedIndices($g_aListEditor[1], True)
    If ($aData[0] > 0) Then
        If ($aData[1] < _GUICtrlListView_GetItemCount($g_aListEditor[1]) - 1) Then
            Local $sTemp = _GUICtrlListView_GetItemText($g_aListEditor[1], $aData[1]+1)
            _GUICtrlListView_SetItemText($g_aListEditor[1], $aData[1]+1, _GUICtrlListView_GetItemText($g_aListEditor[1], $aData[1]))
            _GUICtrlListView_SetItemText($g_aListEditor[1], $aData[1], $sTemp)
            
            _GUICtrlListView_SetItemSelected($g_aListEditor[1], $aData[1]+1, True, True)
            _WinAPI_SetFocus(GUICtrlGetHandle($g_aListEditor[1]))
        Else
            _GUICtrlListView_SetItemSelected($g_aListEditor[1], $aData[1], True, True)
            _WinAPI_SetFocus(GUICtrlGetHandle($g_aLIstEditor[1]))
        EndIf
    EndIf
EndFunc

;Removes item selected from listview and adds to combobox
Func ListEditor_btnRemove()
    Local $aData = _GUICtrlListView_GetSelectedIndices($g_aListEditor[1], True)
    If ($aData[0] > 0) Then
        $g_aListEditor[3] &= "|" &  _GUICtrlListView_GetItemText($g_aListEditor[1], $aData[1])

        If (StringMid($g_aListEditor[3], 1, 1) = "|") Then $g_aListEditor[3] = StringMid($g_aListEditor[3], 2)

        GUICtrlSetData($g_aListEditor[2], "")
        GUICtrlSetData($g_aListEditor[2], $g_aListEditor[3])

        _GUICtrlListView_DeleteItemsSelected($g_aListEditor[1])
        _GUICtrlComboBox_SetCurSel(GUICtrlGetHandle($g_aListEditor[2]), 0)
    EndIf
EndFunc

;Adds item from combobox to listview 
Func ListEditor_btnAdd()
    Local $sText = GUICtrlRead($g_aListEditor[2])
    If ($sText <> "") Then
        _GUICtrlListView_AddItem($g_aListEditor[1], $sText)

        $g_aListEditor[3] = StringReplace(StringReplace($g_aListEditor[3], $sText, ""), "||", "|")
        GUICtrlSetData($g_aListEditor[2], "")
        GUICtrlSetData($g_aListEditor[2], $g_aListEditor[3])
        _GUICtrlComboBox_SetCurSel(GUICtrlGetHandle($g_aListEditor[2]), 0)
    EndIf
EndFunc

;Destroys Window and saves data into listview item
Func ListEditor_Close()
    Opt("GUIOnEventMode", 0)
    ; Saves changed settings to the listview.
    Local $sNew = "";
    Local $iSize = _GUICtrlListView_GetItemCount($g_aListEditor[1])
    For $i = 0 To $iSize-1
        $sNew &= "," & _GUICtrlListView_GetItemText($g_aListEditor[1], $i)
    Next
    $sNew = StringMid($sNew, 2) 

    _GUICtrlListView_SetItemText($g_aListEditor[5], $g_aListEditor[6], $sNew, 1)

    _WinAPI_DestroyWindow($g_aListEditor[0])
    GUISetState(@SW_ENABLE, $g_aListEditor[4])

    _GUICtrlListView_SetItemSelected($g_aListEditor[5], $g_aListEditor[6], True, True)
    _WinAPI_SetFocus($g_aListEditor[5])

    _saveSettings()
EndFunc

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
    _GUICtrlComboBox_GetLBText($g_hCmb_Scripts, _GUICtrlComboBox_GetCurSel($g_hCmb_Scripts), $sItem)

    If (StringLeft($sItem, 1) = "_") Then
        ControlDisable("", "", $g_hBtn_Start)
    Else
        ControlEnable("", "", $g_hBtn_Start)
    EndIf

    $sItem = StringReplace($sItem, " ", "_")

    Local $aScript = getScriptData($g_aScripts, $sItem)
    If (isArray($aScript)) Then
        displayScriptData($g_hLV_ScriptConfig, $aScript)
        GUICtrlSetData($g_hLbl_ScriptDescription, $aScript[1])
    EndIf
EndFunc

;Script data [[script, description, [[config, value, description], [..., ..., ...]]], ...]
Func setScripts(ByRef $aScripts, $sPath, $sCachePath = "")
    Local $sData ;Contains unparsed data
    If (FileExists($sPath)) Then
        $sData = FileRead($sPath)
    Else
        $sData = BinaryToString(InetRead($sPath, $INET_FORCERELOAD))
        If ($sCachePath <> "") Then
            Local $hFile = FileOpen($sCachePath, $FO_OVERWRITE+$FO_CREATEPATH)
            FileWrite($hFile, $sData)
            FileClose($hFile)
        EndIf
    EndIf
    If ($sData = "") Then Return -1

    Local $c = StringSplit($sData, "", $STR_NOCOUNT)

    Local $t_aScripts = $g_aScripts ;Temporarily stores script data
    Local $t_aScript[3] ;Stores single script

    Local $t_aConfig[5] 
    Local $t_aConfigs[0] 

    Local $bScript = False
    For $i = -1 To UBound($c)-1
        If (nextValidChar($c, $i) = -1) Then ExitLoop
        If (Not($bScript)) Then
            If ($c[$i] = "[") Then
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

                            If ($c[$i] = "]") Then
                                ReDim $t_aConfigs[UBound($t_aConfigs)+1]
                                $t_aConfigs[UBound($t_aConfigs)-1] = $t_aConfig
                            EndIf
                    EndSwitch
                Case "]"
                    $t_aScript[2] = $t_aConfigs
                    Local $t_aNewConfig[0]
                    $t_aConfigs = $t_aNewConfig

                    If (getScriptIndex($t_aScripts, $t_aScript[0]) = -1) Then
                        ReDim $t_aScripts[UBound($t_aScripts)+1]
                        $t_aScripts[UBound($t_aScripts)-1] = $t_aScript
                    EndIf
                    
                    $bScript = False
            EndSwitch

        EndIf
    Next

    $aScripts = $t_aScripts
EndFunc

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
EndFunc

Func getNextField($aChar, ByRef $iIndex)
    Local $sText = ""

    While $aChar[$iIndex] <> ':'
        If (Not(StringIsSpace($aChar[$iIndex]))) Then $sText &= $aChar[$iIndex]
        $iIndex += 1
    WEnd

    Return $sText
EndFunc

Func nextValidChar($aChar, ByRef $iIndex)
    $iIndex += 1
    While ($iIndex < UBound($aChar)) And StringIsSpace($aChar[$iIndex])
        $iIndex += 1
    WEnd

    If ($iIndex >= UBound($aChar)) Then Return -1
EndFunc

;Replaces values in script list with values saved in profile
Func getConfigsFromFile(ByRef $aScripts, $sScript, $sProfilePath = $g_sProfilePath)
    $sScript = StringReplace($sScript, " ", "_")
    Local $iIndex = getScriptIndex($aScripts, $sScript)
    If ($iIndex = -1) Then
        $g_sErrorMessage = "getConfigsFromFile() => Could not find script data."
        Return -1
    EndIf

    Local $t_aRawConfig = getArgsFromFile($sProfilePath & "\" & $sScript)

    ;Creates temporary variables to access the nested arrays and values.
    Local $t_aScript = $aScripts[$iIndex] ;[script, description, [[config, value, description], [..., ..., ...]]]
    Local $t_aConfigs = $t_aScript[2] ;[[config, value, description], [..., ..., ...]]

    For $i = 0 To UBound($t_aConfigs)-1 
        Local $t_aConfig = $t_aConfigs[$i] 
        Local $sValue = getArg($t_aRawConfig, $t_aConfig[0])
        If ($sValue <> -1) Then $t_aConfig[1] = $sValue

        ;save new config value
        $t_aConfigs[$i] = $t_aConfig
    Next
    
    ;save new configs to script
    $t_aScript[2] = $t_aConfigs

    ;save to script list
    $aScripts[$iIndex] = $t_aScript
EndFunc

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
    For $i = 0 To $iSize-1
        ;Looks at first element of each array. The script in: [script, description, [[config, value, description], [..., ..., ...]]]
        Local $aScript = $aScripts[$i]
        If ($aScript[0] = $sScript) Then Return $aScript
    Next

    Return ""
EndFunc

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
    For $i = 0 To $iSize-1
        ;Looks at first element of each array. The script in: [script, description, [[config, value, description], [..., ..., ...]]]
        Local $aScript = $aScripts[$i]
        If ($aScript[0] = $sScript) Then Return $i
    Next

    Return -1
EndFunc

#cs 
    Function: Display script data to a listview control
    Parameters:
        $hListView: Reference to listview control handle
        $aScript: [script, description, [[config, value, description], [..., ..., ...]]]
#ce
Func displayScriptData(ByRef $hListView, $aScript)
    ;Must be in format: [script, description, [[config, value, description], [..., ..., ...]]]
    If (Not(isArray($aScript))) Then 
        $g_sErrorMessage = "displayScriptData() => Argument is not an array."
        Return -1
    EndIf

    If (UBound($aScript, $UBOUND_ROWS) <> 3) Then 
        $g_sErrorMessage = "displayScriptData() => Incorrect argument format"
        Return -1
    EndIf

    Local $aConfigList = $aScript[2] ;[[config, value, description], [..., ..., ...]]
    Local $iSize = UBound($aConfigList, $UBOUND_ROWS)

    ;Reset ListView: 
    _GUICtrlListView_DeleteAllItems($hListView)
    For $i = 0 To $iSize-1
        Local $aConfig = $aConfigList[$i] ;[config, value, description]
        _GUICtrlListView_AddItem($hListView, StringReplace($aConfig[0], "_", " "))
        _GUICtrlListView_AddSubItem($hListView, $i, $aConfig[1], 1)

        ;hidden values
        _GUICtrlListView_AddSubItem($hListView, $i, $aConfig[2], 2) ;description
        _GUICtrlListView_AddSubItem($hListView, $i, $aConfig[3], 3) ;type
        _GUICtrlListView_AddSubItem($hListView, $i, $aConfig[4], 4) ;type values
    Next
EndFunc

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
    If ($iIndex = -1) Then
        $g_sErrorMessage = "saveSettings() => Script not found in database. Could not save."
        Return -1
    EndIf

    ;Creates temporary variables to access the nested arrays and values.
    Local $t_aScript = $aScripts[$iIndex] ;[script, description, [[config, value, description], [..., ..., ...]]]
    Local $t_aConfigs = $t_aScript[2] ;[[config, value, description], [..., ..., ...]]

    ;Going through listview column 2 items
    Local Const $eColumn = 1 ;The listview column with the values
    For $i = 0 To UBound($t_aConfigs)-1 ;Assumes the listview has the same number of rows as the number of configs
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
    If ($sFilePath <> "") Then
        Local $sConfigData = ""
        For $i = 0 To UBound($t_aConfigs)-1
            Local $t_aConfig = $t_aConfigs[$i] ;[config, value, description]
            $sConfigData &= @CRLF & $t_aConfig[0] & ':"' & $t_aConfig[1] & '"'
        Next
        $sConfigData = StringMid($sConfigData, 2)

        FileOpen($sFilePath, $FO_OVERWRITE+$FO_CREATEPATH)
        FileWrite($sFilePath, $sConfigData)
        FileClose($sFilePath)
    EndIf

    UpdateSettings()
EndFunc

;saveSettings for main GUI
Func _saveSettings()
    Local $sScriptName ;Holds current script name
    _GUICtrlComboBox_GetLBText($g_hCmb_Scripts, _GUICtrlComboBox_GetCurSel($g_hCmb_Scripts), $sScriptName)
    saveSettings($g_aScripts, $sScriptName, $g_hLV_ScriptConfig)
EndFunc

;updates global variables
Func UpdateSettings()
    $g_aConfigSettings = formatArgs(getScriptData($g_aScripts, "_Config")[2]) ;This is the list of configs
    $g_aDelaySettings = formatArgs(getScriptData($g_aScripts, "_Delays")[2]) ;This is the list of configs
    $g_aGeneralSettings = formatArgs(getScriptData($g_aScripts, "_General")[2])
    $g_aHourlySettings = formatArgs(getScriptData($g_aScripts, "_Hourly")[2])
    $g_aFilterSettings = formatArgs(getScriptData($g_aScripts, "_Filter")[2])

    ;[script, description, [[config, value, description], [..., ..., ...]]]
    $g_sProfileName = getArg($g_aConfigSettings, "Profile_Name")
    $g_sProfilePath = $g_sProfileFolder & $g_sProfileName & "\"
    
    $g_sProfileImagePath = $g_sProfilePath & "images\"
    $g_sProfileImageErrorPath = $g_sProfilePath & "Error\"
    If (Not(FileExists($g_sProfileImagePath))) Then DirCreate($g_sProfileImagePath)
    If (Not(FileExists($g_sProfileImageErrorPath))) Then DirCreate($g_sProfileImageErrorPath)
    $g_sAdbPath = getConfigArg($g_aConfigSettings, "ADB_Path", "~", $d_sAdbPath)
    $g_sAdbDevice = getConfigArg($g_aConfigSettings, "ADB_Device", "~", $d_sAdbDevice)
    $g_sAdbMethod = getConfigArg($g_aConfigSettings, "ADB_Method", "~", $d_sAdbMethod)
    $g_iADB_InputEvent_Version = getConfigArg($g_aConfigSettings, "ADB_Input_Event_Version", "~", $d_iADB_InputEvent_Version)
    $g_sWindowTitle = getConfigArg($g_aConfigSettings, "Emulator_Title", "~", $d_sWindowTitle)    
    $g_sEmuSharedFolder[0] = getConfigArg($g_aConfigSettings, "ADB_Shared_Folder1", "~", $d_sEmuSharedFolder[0])
    $g_sEmuSharedFolder[1] = getConfigArg($g_aConfigSettings, "ADB_Shared_Folder2", "~", $d_sEmuSharedFolder[1])
    $g_iDisplayScaling = getConfigArg($g_aConfigSettings, "Display_Scaling", "~", $d_iDisplayScaling)

    $g_iSwipeDelay = GetArg($g_aDelaySettings, "Swipe_Delay")
    $g_iNavClickDelay = getConfigArg($g_aDelaySettings, "Navigation_Click_Delay", "~", $d_iNavClickDelay)
    $g_iTargetBossDelay = GetArg($g_aDelaySettings, "Target_Boss_Delay")
    $g_iMaintenanceTimeout = Int(StringSplit(GetArg($g_aConfigSettings, "Maintenance_Timeout"), " ", $STR_NOCOUNT)[0])

    Local $t_Emulator_Class = getArg($g_aConfigSettings, "Emulator_Class")
    Local $t_Emulator_Instance = getArg($g_aConfigSettings, "Emulator_Instance")
    If $t_Emulator_Class = "~" Or $t_Emulator_Instance = "~" Then
        $g_sControlInstance = $d_sControlInstance
    Else
        $g_sControlInstance = "[CLASS:" & getArg($g_aConfigSettings, "Emulator_Class") & "; INSTANCE:" & getArg($g_aConfigSettings, "Emulator_Instance") & "]"
    EndIf
    $g_iBackgroundMode = Eval("BKGD_" & StringUpper(getArg($g_aConfigSettings, "Capture_Mode")))
    $g_iMouseMode = Eval("MOUSE_" & StringUpper(getArg($g_aConfigSettings, "Mouse_Mode")))
    $g_iSwipeMode = Eval("SWIPE_" & StringUpper(getArg($g_aConfigSettings, "Swipe_Mode")))
    $g_iBackMode = Eval("BACK_" & StringUpper(getArg($g_aConfigSettings, "Back_Mode")))
    if (getArg($g_aConfigSettings, "Stuck_Restart_Time") = "Never") Then
        $g_iRestartTime = 0
    Else
        Local $a_RestartSplit = StringSplit(getArg($g_aConfigSettings, "Stuck_Restart_Time"), " ", $STR_NOCOUNT)
        $g_iRestartTime = Int($a_RestartSplit[0])
    EndIf
    
    If (getArg($g_aConfigSettings, "Logged_In_Another_Device_Timeout") = "Never") Then
        $g_iLoggedOutTime = -1
    ElseIf (getArg($g_aConfigSettings, "Logged_In_Another_Device_Timeout") = "Immediately") Then
        $g_iLoggedOutTime = 0
    Else
        Local $a_LoggedOutSplit = StringSplit(getArg($g_aConfigSettings, "Logged_In_Another_Device_Timeout"), " ", $STR_NOCOUNT)
        $g_iLoggedOutTime = Int($a_LoggedOutSplit[0])
    EndIf
    
    Local $t_sScheduledRestart = getArg($g_aConfigSettings, "Scheduled_Restart")
    if ($t_sScheduledRestart = "Never") Then
        $g_sScheduledRestartMode = "Never"
        $g_iScheduledRestartTime = 0
    Else
        Local $a_ScheduledRestart = StringSplit($t_sScheduledRestart, ":", $STR_NOCOUNT)
        If (isArray($a_ScheduledRestart)) Then
            $a_ScheduledRestart[1] = Int(StringMid($a_ScheduledRestart[1], 1, StringLen($a_ScheduledRestart[1])-1))
            $g_sScheduledRestartMode = $a_ScheduledRestart[0]
            $g_iScheduledRestartTime = $a_ScheduledRestart[1]
        Else
            $g_sScheduledRestartMode = "Never"
            $g_iScheduledRestartTime = 0
        EndIf
    EndIf
    if (Ubound($aVersion) <=1) Then
        $g_bSaveDebug = (getArg($g_aConfigSettings, "Save_Debug_Log") = "Enabled")
        $g_bSaveLog = (getArg($g_aConfigSettings, "Save_Logs") = "Enabled")
        $g_bLogClicks = (getArg($g_aConfigSettings, "Log_Clicks") = "Enabled")
    Else
        $g_bSaveDebug = True
        $g_bSaveLog = True
        $g_bLogClicks = True
    EndIf

    $g_hWindow = WinGetHandle($g_sWindowTitle)
    $g_hControl = ControlGetHandle($g_hWindow, "", $g_sControlInstance)
    If $g_hWindow <> 0 Then
        Local $t_aPos = WinGetPos($g_hWindow)
        If isArray($t_aPos) = True Then
            $g_hToolbox = WinGetHandle("[TITLE:Form; CLASS:Qt5QWindowToolSaveBits; X:" & ($t_aPos[0]+$t_aPos[2]) & "; Y:" & ($t_aPos[1]) & "]")
        EndIf
    EndIf
EndFunc

Func RunMenuItem($sMenuItem)
    If ($g_bRunning) Then
        MsgBox(16,"Error running function","Unable to run menu item. Script is currently running")
        Return True
    EndIf

    Local $sScript = "RunDebug"
    Local $sScriptArgs[2]
    Switch $sMenuItem 
        Case "DebugInput"
            If ($g_hEditConfig <> Null) Then _endEdit()
            Debug()
        Case "Navigate"
            Local $validInput = False
            Local $sMessage = "Which location do you want to go to?"
            Local $sError = ""
            Local $sSetLocation
            While $validInput = False
                $sSetLocation = InputBox("Navigate to?", $sMessage & $sError, default, default, default, 150)
                If (StringReplace($sSetLocation," ","") = "") Then ExitLoop

                $validInput = True
                $sScriptArgs[0] = 'navigate("' & $sSetLocation & '")'
                $sScriptArgs[1] = $sMenuItem
            WEnd
        Case "SetLocation"
            Local $validInput = False
            Local $sMessage = "Which location do you want to set"
            Local $sError = ""
            Local $sSetLocation
            While $validInput = False
                $sSetLocation = InputBox("Set Location", $sMessage & $sError, default, default, default, 150)
                If (StringReplace($sSetLocation," ","") = "") Then ExitLoop

                If (getLocationArg($sSetLocation) <> -1) Then
                    $validInput = True
                    $sScriptArgs[0] = 'SetLocation("' & $sSetLocation & '")'
                    $sScriptArgs[1] = $sMenuItem
                Else
                    $sError = @CRLF & "Location does not exist. Please try again."
                EndIf
            WEnd
        Case "SetNewLocation"
            Local $validInput = False
            Local $sMessage = "Which location do you want to set"
            Local $sError = ""
            Local $sSetLocation = ""
            Local $sLocationPoints = ""
            While $validInput = False
                $sSetLocation = InputBox("Set Location", $sMessage & $sError, default, default, default, 150)
                If (StringReplace($sSetLocation," ","") = "") Then ExitLoop

                $sMessage = 'Which points do you want to use. Format: "123,123|124,124"' 
                $sLocationPoints = InputBox("Set Location", $sMessage & $sError, default, default, default, 150)
                If (StringReplace($sLocationPoints," ","") = "") Then ExitLoop

                $validInput = True
                $sScriptArgs[0] = 'SetLocation("' & $sSetLocation & '", "' & $sLocationPoints & '")'
                $sScriptArgs[1] = $sMenuItem
                ExitLoop
            WEnd
        Case "SetPixel"
            Local $validInput = False
            Local $sMessage = "Which Pixel value do you want to set"
            Local $sError = ""
            Local $sSetPixel = ""
            Local $sPixelPoints = ""
            While $validInput = False
                $sSetPixel = InputBox("Set Pixel", $sMessage & $sError, default, default, default, 150)
                If (StringReplace($sSetPixel," ","") = "") Then ExitLoop
                
                $sMessage = 'Which points do you want to use. Format: "123,123|124,124"' 
                $sPixelPoints = InputBox("Set Location", $sMessage & $sError, default, default, default, 150)
                if (StringReplace($sPixelPoints," ","") = "") Then ExitLoop

                $validInput = True
                $sScriptArgs[0] = 'SetPixel("' & $sSetPixel & '", "' & $sPixelPoints & '")'
                $sScriptArgs[1] = $sMenuItem
                ExitLoop
            WEnd
        Case "IsPixel"
            Local $sMessage = "Enter Pixel Info to check for:"
            Local $sError = ""
            Local $sIsPixel
            $sIsPixel = InputBox("Is Pixel", $sMessage & $sError, default, default, default, 150)
            If (StringReplace($sIsPixel," ","") <> "") Then
                $sScriptArgs[0] = 'IsPixel("' & $sIsPixel & '")'
                $sScriptArgs[1] = $sMenuItem
            EndIf
        Case "GetColor"
            Local $sMessage = "Enter Location to check the color for:"
            Local $sError = ""
            Local $sGetColor
            $sGetColor = InputBox("Get Color", $sMessage & $sError, default, default, default, 150)
            If (StringReplace($sGetColor," ","") <> "") Then
                $sScriptArgs[0] = 'GetColor(' & $sGetColor & ')'
                $sScriptArgs[1] = $sMenuItem
            EndIf
        Case "Evolve3"
            Local $sMessage = "Enter Astromon to search for (Enter space for default slime):"
            Local $sError = ""
            Local $sEvolveAstromon
            $sEvolveAstromon = InputBox("Evolve Algorithm 3", $sMessage & $sError, default, default, default, 150)
            If (StringReplace($sEvolveAstromon," ","") <> "") Then
                $sScriptArgs[0] = 'evolve3("' & $sEvolveAstromon & '")'
                $sScriptArgs[1] = $sMenuItem
            Else
                If ($sEvolveAstromon = " ") Then 
                    $sScriptArgs[0] = 'evolve3()'
                    $sScriptArgs[1] = $sMenuItem
                EndIf
            EndIf
        Case "PartialScreenshot"
            Local $sMessage = "Enter location and size of screenshot area. Format: x,y,width(optional),height(optional)"
            Local $sError = ""
            Local $sInput = InputBox("Screenshot Location and Size", $sMessage, default, default, default, 150)
            If (StringReplace($sInput," ","") <> "") Then
                Local $aInput = StringSplit($sInput,",")
                Switch $aInput[0]
                    Case 2
                        Local $iWidth = $NOX_WIDTH - $aInput[1]
                        Local $iHeight = $NOX_HEIGHT - $aInput[2]
                        Local $sParams = $aInput[1] & "," & $aInput[2] & "," & $iWidth & "," & $iHeight
                        $sScriptArgs[0] = "takeScreenShot(True," & $sParams & ")"
                        $sScriptArgs[1] = $sMenuItem
                    Case 4
                        $sScriptArgs[0] = "takeScreenShot(True," & $aInput[1] & "," & $aInput[2] & "," & $aInput[3] & "," & $aInput[4] & ")"
                        $sScriptArgs[1] = $sMenuItem
                    Case Else
                        MsgBox(0,"Format Invalid","An invalid format was input. " & $sInput)
                EndSwitch
            EndIf

        Case Else
            $sScriptArgs[0] = $sMenuItem & "()"
            $sScriptArgs[1] = $sMenuItem
    EndSwitch

    If ($sScript <> "") Then
        _ArrayInsert($sScriptArgs, 0, "CallArgArray")
        $g_sScript = $sScript
        $g_aScriptArgs = $sScriptArgs
        Start()
    EndIf
EndFunc