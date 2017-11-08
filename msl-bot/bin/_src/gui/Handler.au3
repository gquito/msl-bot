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
    Local $iCode = GUIGetMsg()
    Switch $iCode 
        Case $GUI_EVENT_CLOSE
            GUISetState(@SW_HIDE, $hParent)
            CloseApp()
        Case Else
            ;Handles the combo config contextmenu
            handleCombo($iCode, $hLV_ScriptConfig)
    EndSwitch
EndFunc

Func WM_COMMAND($hWnd, $iMsg, $wParam, $lParam)
    #forceref $hWnd, $iMsg, $wParam
    Local $nNotifyCode = BitShift($wParam, 16)
    Local $nID = BitAND($wParam, 0x0000FFFF)
    Local $hCtrl = $lParam

    Switch $hCtrl
        Case $hBtn_Start
            If $nNotifycode = $BN_CLICKED Then
                Start()
            EndIf
        Case $hBtn_Stop
            If $nNotifyCode = $BN_CLICKED Then
                Stop()
            EndIf
        Case $hBtn_Pause
            If $nNotifyCode = $BN_CLICKED Then
                Pause()
            EndIf
        Case $hCmb_Scripts
            If $nNotifyCode = $CBN_SELCHANGE Then 
                ;Change listview display for script configs
                Local $sItem ;Stores selected item text
                _GUICtrlComboBox_GetLBText($hCmb_Scripts, _GUICtrlComboBox_GetCurSel($hCmb_Scripts), $sItem)
                $sItem = StringReplace($sItem, " ", "_")

                Local $aScript = getScriptData($g_aScripts, $sItem)
                If isArray($aScript) Then
                    displayScriptData($hLV_ScriptConfig, $aScript)
                    GUICtrlSetData($hLbl_ScriptDescription, $aScript[1])
                EndIf
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
        Case $hLV_ScriptConfig
            Switch $iCode
                Case $LVN_ITEMCHANGED, $NM_CLICK
                    ;handles edit updates 
                    If $g_hEditConfig <> Null Then handleEdit($g_hEditConfig, $g_iEditConfig, $hLV_ScriptConfig)

                    ;Switches config description label
                    $tScriptConfigInfo = DLLStructCreate($tagNMITEMACTIVATE, $lparam)

                    Local $iIndex = DLLStructGetData($tScriptConfigInfo, "Index")
                    Local $sText = _GUICtrlListView_GetItemText($hLV_ScriptConfig, $iIndex, 2)

                    If $sText = "" Then
                        GUICtrlSetData($hLbl_ConfigDescription, "Click on a setting for a description.")
                    Else
                        GUICtrlSetData($hLbl_ConfigDescription, $sText)
                    EndIf
                Case $LV_DBLCLK, $LV_RCLICK
                    ;Handles changes in the listview
                    $tScriptConfigInfo = DLLStructCreate($tagNMITEMACTIVATE, $lparam)

                    Local $iIndex = DLLStructGetData($tScriptConfigInfo, "Index")
                    Local $sType = _GUICtrlListView_GetItemText($hLV_ScriptConfig, $iIndex, 3)
                    Local $sTypeValues = _GUICtrlListView_GetItemText($hLV_ScriptConfig, $iIndex, 4)

                    ;Handles edits for settings
                    Switch $sType
                        Case "Combo"
                            ;Creating context menu from items specified by the combo type.
                            Local $t_aItems = StringSplit($sTypeValues, ",", $STR_NOCOUNT)
                            createComboMenu($g_aComboMenu, $t_aItems)  

                            ;Displays a context menu to choose an item from.
                            ShowMenu($hParent, $g_aComboMenu[0])
                        Case "Text"
                            ;Shows edit in the position.
                            createEdit($g_hEditConfig, $g_iEditConfig, $hLV_ScriptConfig)
                        Case "List"
                            createListEditor($hParent, $hLV_ScriptConfig, $iIndex)
                        Case "Custom"

                    EndSwitch
            EndSwitch
    EndSwitch
    Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_NOTIFY

; Handles script and closing app
Func CloseApp()
    _GDIPlus_Shutdown()
    Exit
EndFunc

Func Start()
;Initializing variables
    _GUICtrlComboBox_GetLBText($hCmb_Scripts, _GUICtrlComboBox_GetCurSel($hCmb_Scripts), $g_sScript)

    Local $t_aScriptArgs[_GUICtrlListView_GetItemCount($hLV_ScriptConfig)+1] ;Contains script args
    $t_aScriptArgs[0] = "CallArgArray"
    For $i = 1 To UBound($t_aScriptArgs, $UBOUND_ROWS)-1
        ;Retrieves the values column for each setting
        $t_aScriptArgs[$i] = _GUICtrlListView_GetItemText($hLV_ScriptConfig, $i-1, 1) 
    Next

;Setting control states
    GUICtrlSetData($idLbl_RunningScript, "Running Script: " & $g_sScript)
    ControlDisable("", "", $hCmb_Scripts)
    ControlDisable("", "", $hLV_ScriptConfig)
    ControlDisable("", "", $hBtn_Start)
    ControlEnable("", "", $hBtn_Stop)
    ControlEnable("", "", $hBtn_Pause)

    _GUICtrlTab_ClickTab($hTb_Main, 1)

;Calls to runs scripts
    $g_aScriptArgs = $t_aScriptArgs
    $g_bRunning = True
EndFunc

Func Stop()
;Resets variables
    $g_aScriptArgs = Null
    $g_sScript = ""

;Setting control states
    GUICtrlSetData($idLbl_RunningScript, "Running Script: ")
    ControlEnable("", "", $hCmb_Scripts)
    ControlEnable("", "", $hLV_ScriptConfig)
    ControlEnable("", "", $hBtn_Start)
    ControlDisable("", "", $hBtn_Stop)
    ControlDisable("", "", $hBtn_Pause)

    _GUICtrlTab_ClickTab($hTb_Main, 0)

;Calls to stop scripts
    $g_bRunning = False
EndFunc

Func Pause()
    $g_bPaused = Not($g_bPaused)

    If $g_bPaused = True Then
        ;From not being paused to being paused
        _GUICtrlButton_SetText($hBtn_Pause, "Unpause")
        ControlDisable("", "", $hBtn_Stop)
    Else
        ;From being paused to being unpaused
        _GUICtrlButton_SetText($hBtn_Pause, "Pause")
        ControlEnable("", "", $hBtn_Stop)
    EndIf
EndFunc

;Some helper functions for handling controls----

;Handles the combo config contextmenu
Func handleCombo(ByRef $iCode, ByRef $hListView)
    If isArray($g_aComboMenu) = False Then Return
    For $i = 1 To UBound($g_aComboMenu, $UBOUND_ROWS)-1
        Local $aContext = $g_aComboMenu[$i] ;Hold [idContext, "name"]
        If $iCode = $aContext[0] Then
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
    _GUICtrlListView_SetItemText($hListView, $iIndex, $sNew, 1)
    _GUICtrlEdit_Destroy($hEdit)

    $hEdit = Null
    $iIndex = Null

    _saveSettings()
EndFunc

;For context menu for text combo configs
Func createEdit(ByRef $hEdit, ByRef $iIndex, $hListView, $bNumber = True)
    If $iIndex = Null Then $iIndex = _GUICtrlListView_GetSelectedIndices($hListView, True)[1]
    Local $sText = _GUICtrlListView_GetItemText($hListView, $iIndex, 1)
    Local $aSize = _GUICtrlListView_GetSubItemRect($hListView, $iIndex, 1)

    Local $aDim = [$aSize[0], $aSize[1], $aSize[2]-$aSize[0], $aSize[3]-$aSize[1]]
    Local $iStyle = $WS_VISIBLE+$ES_WANTRETURN+$ES_CENTER
    If $bNumber = True Then $iStyle+=$ES_NUMBER

    $hEdit = _GUICtrlEdit_Create($hLV_ScriptConfig, $sText, $aDim[0], $aDim[1], $aDim[2], $aDim[3], $iStyle)
    
    _GUICtrlEdit_SetSel($hEdit, 0, -1)
    _WinAPI_SetFocus($hEdit)

    HotKeySet("{ENTER}", "endEdit")
EndFunc

;When enter is pressed acts as unfocus and runs the handle edit
Func endEdit()
    handleEdit($g_hEditConfig, $g_iEditConfig, $hLV_ScriptConfig)
    HotKeySet("{ENTER}")
EndFunc

Func createListEditor($hParent, $hListView, $iIndex)
    Opt("GUIOnEventMode", 1)
    ; [gui handle, listview inside gui, combo handle, combo values, parent handle, listview handle, item index]
    Local $aCurrent = StringSplit(_GUICtrlListView_GetItemText($hListView, $iIndex, 1), ",", $STR_NOCOUNT)
    Local $aDefault = StringSplit(_GUICtrlListView_GetItemText($hListView, $iIndex, 4), ",", $STR_NOCOUNT)

    Local $t_aListEditor[7] ;Holds the array items from comment above.
    Local $t_aPos = WinGetPos($hParent)
    $t_aListEditor[0] = GUICreate("Edit List", 150, 182, $t_aPos[0]+(($t_aPos[2]-150)/2), $t_aPos[1]+(($t_aPos[3]-150)/2), -1, $WS_EX_TOPMOST, $hParent)
    $t_aListEditor[1] = GUICtrlCreateListView("", 2, 2, 146, 100, $LVS_SINGLESEL+$LVS_REPORT+$LVS_NOSORTHEADER+$WS_BORDER)
    Local $t_hListView = GUICtrlGetHandle($t_aListEditor[1])

    _GUICtrlListView_SetExtendedListViewStyle($t_hListView, $LVS_EX_DOUBLEBUFFER+$LVS_EX_FULLROWSELECT+$LVS_EX_GRIDLINES)
    _GUICtrlListView_AddColumn($t_hListView, "-Included Values-", 125, 2)
    ControlDisable("", "", HWnd(_GUICtrlListView_GetHeader($t_hListView))) ;Prevents changing column size

    ;adding current items.
    For $i = 0 To UBound($aCurrent, $UBOUND_ROWS)-1
        If $aCurrent[$i] <> "" Then _GUICtrlListView_AddItem($t_hListView, $aCurrent[$i])

        ;Removing existing values from default to add those non exisiting in a combo later.
        For $j = 0 To UBound($aDefault, $UBOUND_ROWS)-1
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
    For $i = 0 To UBound($aDefault, $UBOUND_ROWS)-1
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
EndFunc

;Moves selected item up index
Func ListEditor_btnMoveUp()
    Local $aData = _GUICtrlListView_GetSelectedIndices($g_aListEditor[1], True)
    If $aData[0] > 0 Then
        If $aData[1] > 0 Then
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
    If $aData[0] > 0 Then
        If $aData[1] < _GUICtrlListView_GetItemCount($g_aListEditor[1])-1 Then
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
    If $aData[0] > 0 Then
        $g_aListEditor[3] &= "|" &  _GUICtrlListView_GetItemText($g_aListEditor[1], $aData[1])

        If StringMid($g_aListEditor[3], 1, 1) = "|" Then $g_aListEditor[3] = StringMid($g_aListEditor[3], 2)

        GUICtrlSetData($g_aListEditor[2], "")
        GUICtrlSetData($g_aListEditor[2], $g_aListEditor[3])

        _GUICtrlListView_DeleteItemsSelected($g_aListEditor[1])
        _GUICtrlComboBox_SetCurSel(GUICtrlGetHandle($g_aListEditor[2]), 0)
    EndIf
EndFunc

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

#cs ##########################################
    Functions for changing control data and display
#ce ##########################################

;[[script, description, [[config, value, description], [..., ..., ...]]], ...]
Func getScriptsFromUrl(ByRef $aScripts, $sUrl)
    ;https://raw.githubusercontent.com/GkevinOD/msl-bot/version-check/msl-bot/scripts.txt
    Local $aRawScripts = getArgsFromURL($sUrl, ">", ":") ;[[script, 'description:"",config:"value|description"']]
    Local $iNumScripts = UBound($aRawScripts, $UBOUND_ROWS)

    Local $t_aScripts[0] ;Temporarily stores script data

    For $i = 0 To $iNumScripts-1
        Local $aRawScript = [$aRawScripts[$i][0], $aRawScripts[$i][1]] ;[script, 'description:"",config:"value|description"']
        Local $aScript[3] ;stores a single script [script, description, []]
        
        $aScript[0] = $aRawScript[0]
        If $aScript[0] = "" Then ContinueLoop

        ;getting description and then configs
        Local $aRawConfigList = formatArgs(StringReplace($aRawScript[1], "'", '"'), ",", ":") ;[[description, ""], [config, "value|description"]]
        Local $iRawConfigListSize = UBound($aRawConfigList, $UBOUND_ROWS)

        Local $aScriptDescription = [$aRawConfigList[0][0], $aRawConfigList[0][1]] ;[description, ""]
        $aScript[1] = $aScriptDescription[1]

        Local $aConfigList[$iRawConfigListSize-1] ;stores all config in format [config, value, description]
        For $j = 1 To $iRawConfigListSize-1 ;skips the script description
            Local $aRawConfig = [$aRawConfigList[$j][0], $aRawConfigList[$j][1]] ; [config, "value|description"]
            Local $aFormatedConfig[5] ;Stores [config, value, description, type, hidden value]

            $aFormatedConfig[0] = $aRawConfig[0]

            Local $aSplitValueDescription = StringSplit($aRawConfig[1], "|", $STR_NOCOUNT)
            ;_ArrayDisplay($aSplitValueDescription) ;Debug the values

            $aFormatedConfig[1] = $aSplitValueDescription[0]
            $aFormatedConfig[2] = $aSplitValueDescription[1]
            $aFormatedConfig[3] = $aSplitValueDescription[2]
            $aFormatedConfig[4] = $aSplitValueDescription[3]

            $aConfigList[$j-1] = $aFormatedConfig
        Next

        $aScript[2] = $aConfigList
        ReDim $t_aScripts[$i+1]
        $t_aScripts[$i] = $aScript
    Next

    $aScripts = $t_aScripts
EndFunc

;Replaces values in script list with values saved in profile
Func getConfigsFromFile(ByRef $aScripts, $sScript, $sProfilePath = $g_sProfilePath)
    $sScript = StringReplace($sScript, " ", "_")
    Local $iIndex = getScriptIndex($aScripts, $sScript)
    If $iIndex = -1 Then
        $g_sErrorMessage = "saveSettings() => Script not found in database. Could not save."
        Return -1
    EndIf

    Local $t_aRawConfig = getArgsFromFile($sProfilePath & "\" & $sScript)

    ;Creates temporary variables to access the nested arrays and values.
    Local $t_aScript = $aScripts[$iIndex] ;[script, description, [[config, value, description], [..., ..., ...]]]
    Local $t_aConfigs = $t_aScript[2] ;[[config, value, description], [..., ..., ...]]

    For $i = 0 To UBound($t_aConfigs)-1 
        Local $t_aConfig = $t_aConfigs[$i] 
        Local $sValue = getArg($t_aRawConfig, $t_aConfig[0])
        If $svalue <> -1 Then $t_aConfig[1] = $sValue

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
        $aScripts: [[script, [[config, value], [..., ...]]], ...]
        $sScript: The script text to find.
    Returns: The array of the script
    `Empty string on not found.
#ce
Func getScriptData($aScripts, $sScript)
    Local $iSize = UBound($aScripts, $UBOUND_ROWS)
    For $i = 0 To $iSize-1
        ;Looks at first element of each array. The script in: [script, description, [[config, value, description], [..., ..., ...]]]
        Local $aScript = $aScripts[$i]
        If $aScript[0] = $sScript Then Return $aScript
    Next

    Return ""
EndFunc

#cs 
    Function: Retrieves script data with specified script name
    Parameters:
        $aScripts: [[script, [[config, value], [..., ...]]], ...]
        $sScript: The script text to find.
    Returns: Index of the script
    `-1 if not found.
#ce
Func getScriptIndex(ByRef $aScripts, $sScript)
    Local $iSize = UBound($aScripts, $UBOUND_ROWS)
    For $i = 0 To $iSize-1
        ;Looks at first element of each array. The script in: [script, description, [[config, value, description], [..., ..., ...]]]
        Local $aScript = $aScripts[$i]
        If $aScript[0] = $sScript Then Return $i
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
    If isArray($aScript) = False Then 
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
    For $i = 0 To $iSize-1
        Local $aConfig = $aConfigList[$i] ;[config, value, description]
        _GUICtrlListView_AddItem($hListView, StringReplace($aConfig[0], "_", " "))
        _GUICtrlListView_AddSubItem($hListView, $i, StringReplace($aConfig[1], "_", " "), 1)

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
    If $iIndex = -1 Then
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
    If $sFilePath <> "" Then
        Local $sConfigData = ""
        For $i = 0 To UBound($t_aConfigs)-1
            Local $t_aConfig = $t_aConfigs[$i] ;[config, value, description]
            $sConfigData &= @LF & $t_aConfig[0] & ':"' & $t_aConfig[1] & '"'
        Next
        $sConfigData = StringMid($sConfigData, 2)

        FileOpen($sFilePath, $FO_OVERWRITE+$FO_CREATEPATH)
        FileWrite($sFilePath, $sConfigData)
        FileClose($sFilePath)
    EndIf
EndFunc

;saveSettings for main GUI
Func _saveSettings()
    Local $sScriptName
    _GUICtrlComboBox_GetLBText($hCmb_Scripts, _GUICtrlComboBox_GetCurSel($hCmb_Scripts), $sScriptName)
    saveSettings($g_aScripts, $sScriptName, $hLV_ScriptConfig)
EndFunc

;Helper functions

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