#include-once
#include "../imports.au3"

#cs ##########################################
    Control Event Handling
#ce ##########################################

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
        
                displayScriptData($hLV_ScriptConfig, getScriptData($hLV_ScriptConfig, $sItem))
            EndIf
        Case $hBtn_Start
            Switch $nNotifyCode
                Case $BN_CLICKED
                    _GUICtrlListView_SetItemText($hLV_ScriptConfig, 0, "Row 1: Edited!")
            EndSwitch
    EndSwitch
    Return $GUI_RUNDEFMSG
EndFunc 

Func WM_NOTIFY($hWnd, $iMsg, $wParam, $lParam)
    #forceref $hWnd, $iMsg, $wParam
    Local $hWndFrom, $iCode, $tNMHDR, $tInfo

    $tNMHDR = DllStructCreate($tagNMHDR, $lParam)
    $hWndFrom = HWnd(DllStructGetData($tNMHDR, "hWndFrom"))
    $iCode = DllStructGetData($tNMHDR, "Code")

    Switch $hWndFrom
        Case ""
        Case Else
            If $iCode = $TCN_SELCHANGE Then TabUpdate($g_aTabGroup)
    EndSwitch
    Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_NOTIFY

#cs ##########################################
    Functions for changing control data and display
#ce ##########################################

#cs 
    Function: Retrieves script data with specified script name
    Parameters:
        $aScripts: [[script, [[config, value], [..., ...]]], ...]
        $sScript: The script text to find.
    Returns: The array of the script
    `Empty string on not found.
#ce
Func getScriptData(ByRef $aScripts, $sScript)
    Local $iSize = UBound($aScripts, "")
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
        _GUICtrlListView_AddItem($hListView, $aConfig[0])
        _GUICtrlListView_AddSubItem($hListView, $i, $aConfig[1], 1)
        _GUICtrlListView_AddSubItem($hListView, $i, $aConfig[2], 2) ;This is hidden
    Next
EndFunc