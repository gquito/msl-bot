#include-once
#include "../imports.au3"

#cs ##########################################
    Tab UDF: Create UDF tabs easily while easily managing 
        the components and controls in a tab.
#ce ##########################################

#cs 
    Function: Creates a tab control using Tab UDF
    Parameters:
        $hParent: The parent of the tab being made.
        $iX, $iY: X and Y Position relative to parent.
        $iWidth, $iHeight: Tab width and height. Default fills parent.
    Return: A Tab array structure=[TAB_HANDLE, TAB_CURRENT_TAB_SELECTED, [TAB CONTROLS ARRAY], [TAB CONTROLS ARRAY]...]
#ce
Func TabCreate($hParent, $iX, $iY, $iWidth = -1, $iHeight = -1)
    If $iWidth = -1 Then $iWidth = ControlGetPos("", "", $hParent)[2]-$iX
    If $iHeight = -1 Then $iHeight = ControlGetPos("", "", $hParent)[3]-$iY
    ;Creating tab array: [handle, oldtab, [], [], []] => each [] is a tab hosting control handles
    Local $aTab[2] = [_GUICtrlTab_Create($hParent, $iX, $iY, $iWidth, $iHeight, $TCS_FOCUSNEVER+$TCS_FIXEDWIDTH), 0]

    Return $aTab
EndFunc

#cs 
    Function: Creates an item for a tab control
    Parameters:
        $aTab: Reference to Tab array structure. See TabCreate()
        $sText: Text of the item.
        $iWidth, $iHeight: Width defaults to fill parent, height is 20.
        $iImage: Index of the image from the imagelist of the tab control.
    Return: Index of tab. New tab is appended to end of the existing tabs.
#ce
Func TabCreateItem(ByRef $aTab, $sText, $iWidth = -1, $iHeight = 20, $iImage = -1)
    If $iWidth = -1 Then $iWidth = StringLen($sText)*10+10

    Local Const $iIndexOffset = 2 ;Control arrays start at index +2
    Local $hTabHandle = $aTab[0]
    Local $iSize = UBound($aTab, $UBOUND_ROWS)

    _GUICtrlTab_InsertItem($hTabHandle, $iSize-$iIndexOffset, $sText, $iImage)
    _GUICtrlTab_SetItemSize($hTabHandle, $iWidth, $iHeight)

    ;Inserting control to tab array reference
    ReDim $aTab[$iSize+1]
    Local $t_aArray = []
    $aTab[$iSize] = $t_aArray ;Last element

    Return $iSize-2 ;Index of item
Endfunc

#cs 
    Function: Adds to Tab control array. Keeps track of the controls to handle when switching tabs.
    Parameters:
        $aTab: Reference to Tab array structure. See TabCreate()
        $iIndex: Tab item index. Also returned from TabCreateItem()
        $hControl: Control handle to add to the tab control array.
        $hParent: A bit complicated here. Usually parent is the Tab control, but handle of GUICreate fixes errors.
#ce
Func TabAddControl(ByRef $aTab, $iIndex, $hControl, $hParent = Null)
    ;Setting default parent
    If $hParent = Null Then $hParent = $aTab[0]

    ;Hiding control if not within current tab
    If $iIndex <> $aTab[1] Then ControlHide("", "", $hControl)

    ;Moving control relative to tab control
    Do
        Local $aOriginalPos = ControlGetPos("", "", $hControl)
        Local $aPosTabRel = _GUICtrlTab_GetDisplayRect($aTab[0])
        Local $aParentPos = ControlGetPos("", "", $hParent)
    Until isArray($aOriginalPos) And isArray($aPosTabRel) And isArray($aParentPos)
    
    ControlMove("", "", $hControl, $aParentPos[0]+$aOriginalPos[0]+$aPosTabRel[0]-4, $aParentPos[1]+$aOriginalPos[1]+$aPosTabRel[1]-2)
    GUICtrlSetPos($hControl, $aParentPos[0]+$aOriginalPos[0]+$aPosTabRel[0]-4, $aParentPos[1]+$aOriginalPos[1]+$aPosTabRel[1]-2)

    Local Const $iIndexOffset = 2 ;control arrays start at index +2
    Local $aControls = $aTab[$iIndex+$iIndexOffset]
    Local $iSize = UBound($aControls, $UBOUND_ROWS)

    ;Adding to array
    ReDim $aControls[$iSize+1]
    $aControls[$iSize] = $hControl

    ;Replacing old array with new one
    $aTab[$iIndex+$iIndexOffset] = $aControls
EndFunc

#cs
    Function: Finds the index of the tab item with the specified text.
    Parameters:
        $aTab: Reference to Tab array structure. See TabCreate()
        $sText: Tab item text to search for.
    Returns: Index of the found item.
        `-1 if not found.
#ce
Func TabIndexOf(ByRef $aTab, $sText)
    Local Const $iIndexOffset = 2 ;control arrays start at index +2
    Local $hTabHandle = $aTab[0]
    Local $iSize = UBound($aTab, $UBOUND_ROWS)

    ;checking for the name
    For $i = 0 To $iSize-$iIndexOffset-1
        If _GUICtrlTab_GetItemText($hTabHandle, $i) = $sText Then Return $i
    Next

    Return -1
EndFunc

#cs 
    Function: Handles hiding and showing controls within a group of array. Usually run when one of the tabs are switched or within mainloop.
    Parameter:
        $aTabGroup: The heirarchy of the nested tabs.
            `Format: [[parent, child, child..] ,[...]]
#ce
Func TabUpdate(ByRef $aTabGroup)
    Local $iParentCount = UBound($aTabGroup, $UBOUND_ROWS) ;Number of total tab parents

    ;Update each group
    For $i = 0 To $iParentCount-1
        Local $aGroup = $aTabGroup[$i] ;[parent, child, child...]
        Local $iGroupCount = UBound($aGroup, $UBOUND_ROWS)

        Local $aParent = $aGroup[0] ;For accessing 2d array

        _TabUpdate($aParent) 
        For $j = 1 To $iGroupCount-1
            Local $aSubTab = $aGroup[$j] ;For accessing 2d array

            _TabUpdate($aSubTab)
            If _GUICtrlTab_GetCurFocus($aParent[0]) <> TabIndexOfControl($aParent, $aSubTab[0]) Then
                TabHideAll($aSubTab)
            EndIf

            $aGroup[$j] = $aSubTab ;Save changes
        Next

        ;save overall changes to $aTabGroup reference
        $aGroup[0] = $aParent
        $aTabGroup[$i] = $aGroup
    Next
EndFunc

#cs
    Function: Helper to TabUpdate function. Handles individual tabs
    Parameters:
        $aTab: Reference to Tab array structure. See TabCreate()
#ce
Func _TabUpdate(ByRef $aTab)
    Local $iIndexOffset = 2 ;control arrays art at index +2
    Local $iCurTab = _GUICtrlTab_GetCurFocus($aTab[0])

    If $iCurTab <> $aTab[1] Then
        Local $aControlsOld = $aTab[$aTab[1]+$iIndexOffset]
        Local $aControlsCur = $aTab[$iCurTab+$iIndexOffset]

        ;Hide old tab controls
        If $aTab[1] <> -1 Then
            For $i = 0 To UBound($aControlsOld)-1
                If $aControlsOld[$i] <> "" Then ControlHide("", "", $aControlsOld[$i])
            Next
        EndIf

        ;SHow new tab controls
        For $i = 0 To UBound($aControlsCur)-1
            ControlShow("", "", $aControlsCur[$i])
        Next

        $aTab[1] = $iCurTab
    EndIf
EndFunc

#cs
    Function: Hides all controls in a tab.
    Parameters:
        $aTab: Reference to Tab array structure. See TabCreate()
#ce
Func TabHideAll(ByRef $aTab)
    $aTab[1] = -1 ;Resets the selected index to prevent errors.

    For $i = 2 To UBound($aTab)-1
        Local $aControls = $aTab[$i]
        For $hControl In $aControls
            If $hControl <> "" Then ControlHide("", "", $hControl)
        Next
    Next
EndFunc

#cs
    Function: Shows all controls in a tab.
    Parameters:
        $aTab: Reference to Tab array structure. See TabCreate()
#ce
Func TabShowAll(ByRef $aTab)
    $aTab[1] = -1 ;Resets the selected index to prevent errors.

    For $i = 2 To UBound($aTab)-1
        Local $aControls = $aTab[$i]
        For $hControl In $aControls
            If $hControl <> "" Then ControlShow("", "", $hControl)
        Next
    Next
EndFunc


#cs 
    Function: Disables all controls in a tab
    Parameters:
        $aTab: Reference to Tab array structure. See TabCreate()
#ce
Func TabDisableAll(ByRef $aTab)
    $aTab[1] = -1 ;Resets the selected index to prevent errors.

    For $i = 2 To UBound($aTab)-1
        Local $aControls = $aTab[$i]
        For $hControl In $aControls
            If $hControl <> "" Then ControlDisable("", "", $hControl)
        Next
    Next
EndFunc

#cs 
    Function: Enables all controls in a tab
    Parameters:
        $aTab: Reference to Tab array structure. See TabCreate()
#ce
Func TabEnableAll(ByRef $aTab)
    $aTab[1] = -1 ;Resets the selected index to prevent errors.

    For $i = 2 To UBound($aTab)-1
        Local $aControls = $aTab[$i]
        For $hControl In $aControls
            If $hControl <> "" Then ControlEnable("", "", $hControl)
        Next
    Next
EndFunc

#cs
    Function: Finds the index of the tab item with the specified handle.
    Parameters:
        $aTab: Reference to Tab array structure. See TabCreate()
        $hControl: Tab item handle text to search for.
    Returns: Index of the found item.
        `-1 if not found.
#ce
Func TabIndexOfControl(ByRef $aTab, $hControl)
    Local $iSize = UBound($aTab, $UBOUND_ROWS)
    For $i = 2 To $iSize-1
        ;Goes through each control list

        Local $t_aControl = $aTab[$i]
        Local $t_iSize = UBound($t_aControl, $UBOUND_ROWS)

        ;Goes through each control elements
        For $j = 0 To $t_iSize-1
            If $t_aControl[$j] = $hControl Then Return $i-2
        Next
    Next

    Return -1
EndFunc