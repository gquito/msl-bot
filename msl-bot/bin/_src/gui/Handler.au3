#include-once
#include "../imports.au3"

#cs ##########################################
    Control Event Handling
#ce ##########################################

Func GUIMainLoop()
    While True
        Local $iCode = GUIGetMsg()
        Switch $iCode 
            Case $GUI_EVENT_CLOSE
                ExitLoop
            Case Else
                ;Handles the combo config contextmenu
                handleCombo($iCode, $hLV_ScriptConfig)
        EndSwitch
    WEnd
EndFunc

Func WM_COMMAND($hWnd, $iMsg, $wParam, $lParam)
    #forceref $hWnd, $iMsg, $wParam
    Local $nNotifyCode = BitShift($wParam, 16)
    Local $nID = BitAND($wParam, 0x0000FFFF)
    Local $hCtrl = $lParam

    Switch $hCtrl
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
        Case $g_hEditConfig
            ;handles editing type Text of the listview configs
            If $nNotifyCode = $EN_KILLFOCUS Then 
                handleEdit($g_hEditConfig, $g_iEditConfig, $hLV_ScriptConfig)
            EndIf

            WinSetTitle($hParent, "", $nNotifyCode)
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
                            
                        Case "Custom"

                    EndSwitch
                Case Else
                    ;WinSetTitle($hParent, "", $iCode)
            EndSwitch
        Case Else
            If $iCode = $TCN_SELCHANGE Then TabUpdate($g_aTabGroup)
    EndSwitch
    Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_NOTIFY

;Some helper functions for handling controls----

;Handles the combo config contextmenu
Func handleCombo(ByRef $iCode, ByRef $hListView)
    For $i = 1 To UBound($g_aComboMenu, $UBOUND_ROWS)-1
        Local $aContext = $g_aComboMenu[$i] ;Hold [idContext, "name"]
        If $iCode = $aContext[0] Then
            ;Replaced text from the listview
            _GUICtrlListView_SetItemText($hListView, _GUICTrlListView_GetSelectedIndices($hListView, True)[1], $aContext[1], 1)
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
EndFunc

;For context menu for text combo configs
Func createEdit(ByRef $hEdit, ByRef $iIndex, $hListView, $bNumber = True)
    If $iIndex = Null Then $iIndex = _GUICtrlListView_GetSelectedIndices($hListView, True)[1]
    Local $sText = _GUICtrlListView_GetItemText($hListView, $iIndex, 1)

    Local Const $iX_Offset = 21, $iY_Offset = 130
    Local $aSize = _GUICtrlListView_GetSubItemRect($hListView, $iIndex, 1)

    Local $aDim = [$aSize[0]+$iX_Offset, $aSize[1]+$iY_Offset, $aSize[2]-$aSize[0]-1, $aSize[3]-$aSize[1]]
    Local $iStyle = $WS_CHILD+$WS_VISIBLE+$ES_WANTRETURN+$ES_CENTER
    If $bNumber = True Then $iStyle+=$ES_NUMBER

    $hEdit = _GUICtrlEdit_Create($hParent, $sText, $aDim[0], $aDim[1], $aDim[2], $aDim[3], $iStyle)
    
    _GUICtrlEdit_SetSel($hEdit, 0, -1)
    _WinAPI_SetFocus($hEdit)

    HotKeySet("{ENTER}", "endEdit")
EndFunc

;When enter is pressed acts as unfocus and runs the handle edit
Func endEdit()
    handleEdit($g_hEditConfig, $g_iEditConfig, $hLV_ScriptConfig)
    HotKeySet("{ENTER}")
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

Func getScriptsFromFile(ByRef $aScripts, $sPath)
    Local $aRawScripts = getArgsFromFile($sPath, ">", ":") ;[[script, 'description:"",config:"value|description"']]
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
            _ArrayDisplay($aSplitValueDescription) ;Debug the values

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

#cs 
    Function: Retrieves script data with specified script name
    Parameters:
        $aScripts: [[script, [[config, value], [..., ...]]], ...]
        $sScript: The script text to find.
    Returns: The array of the script
    `Empty string on not found.
#ce
Func getScriptData(ByRef $aScripts, $sScript)
    Local $iSize = UBound($aScripts, $UBOUND_ROWS)
    For $i = 0 To $iSize-1
        ;Looks at first element of each array. The script in: [script, description, [[config, value, description], [..., ..., ...]]]
        Local $aScript = $aScripts[$i]
        If $aScript[0] = $sScript Then Return $aScript
    Next

    Return ""
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