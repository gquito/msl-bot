#cs
    Functions here handle the creating and modifying settings for script data displayed on the ListView.
        Data will be hosted on a global variable to have easy access between different script functions.
        Some data will be shared such as Refill. Any common names will be merged.
        Data will be updated through sleep function.
        Any data names not in the Order array will be pushed at the end of the list.
#ce ====================================================================================================

Global Const $DATA_TEXT = 0, $DATA_NUMBER = 1, $DATA_PERCENT = 2, $DATA_RATIO = 3, $DATA_LIST = 4, $DATA_TIME = 5, $DATA_TIMEAVG = 6

Global $g_aData[0] ;Structure of the array is as follows:
Global $g_aOrder[0] ;Order of the array, based on name.

#cs ----Start structure here: 
    [
        ["name", "type", "value"],
        ["name", "type", "value"],
        ["name", "type", "value"],
        ...
    ]

    Type list:
        - text (ex. "Just a text.") => Can't be incremented
        - number (ex. "1")
        - percent (ex. 100%) (Must use 2 number data) ex ("Runs/Defeat")
        - ratio (ex. "1/10")
        - list (ex. "a:1, s:2, b:3")
        - time (ex. "1 H 10 M 23 S") => Can't be incremented
        - timeavg (format: time/number)

    Merge:
        - number: Data will be added together
        - ratio: If denominator is the same, the numerator will be added together.
        - list: All equal items will be added together.

    Note: Those with the same name and type will be merged based on the type.
#ce ----End structure



#cs 
    Function: Add data to the global list $g_aData
    Parameters:
        sName: Name of the data to create.
        iType: Type of data. Look at Type list above.
        vValue: Value of the data.
        bMerge: If data with same name exists, the data will be merged based on notes above.
    Returns: True if success, False if fail.
#ce
Func Data_Add($sName, $iType, $vValue, $bMerge = False)
    Log_Level_Add("Data_Add")
    Local $sValue = $vValue
    If isArray($sValue) = True Then $sValue = _ArrayToString($sValue)
    Log_Add("Data add '" & $sName & "' as Type:" & $iType & " with value: " & $sValue, $LOG_DEBUG)

    ;Formatting data
    Switch $iType
        Case $DATA_RATIO, $DATA_PERCENT, $DATA_TIMEAVG
            If isArray($vValue) = False Then
                Local $t_aValue = StringSplit($vValue, "/", $STR_NOCOUNT)
                $vValue = $t_aValue
            EndIf
        
        Case $DATA_LIST
            If isArray($vValue) = False Then $vValue = formatArgs($vValue, ",", ":")
    EndSwitch

    Local $vResult = Data_Get($sName, True)
    If $vResult <> -1 Then
        ;Data already exists:
        If $bMerge = True Then
            Switch $iType
                Case $DATA_NUMBER
                    $vValue += $vResult
                Case $DATA_RATIO
                    If ($vValue[1] = $vResult[1]) Then $vValue[0] += $vResult[0]
                Case $DATA_LIST
                    For $i = 0 To UBound($vValue)-1
                        $vValue[$i][1] += getArg($vResult, $vValue[$i][0])
                    Next
            EndSwitch
        EndIf

        Data_Set($sName, $vValue)
    Else
        ;Data does not exist
        Local $aSub[3] = [$sName, $iType, $vValue]
        ReDim $g_aData[UBound($g_aData)+1]
        $g_aData[UBound($g_aData)-1] = $aSub
    EndIf

    Log_Level_Remove()
    Return True
EndFunc


#cs 
    Function: Will remove data from list
    Parameters:
        sName: Data name to remove.
#ce
Func Data_Remove($sName)
    Local $iSize = 0 ;Size of new array.
    Local $aNew[$iSize] ;Stores new data with specified item removed
    For $aSub In $g_aData
        If $aSub[0] <> $sName Then
            $iSize += 1
            ReDim $aNew[$iSize]
            $aNew[$iSize-1] = $aSub
        EndIf
    Next

    $g_aData = $aNew
EndFunc


#cs 
    Function: Retrieve data in the form of string.
    Parameters:
        sName: Data name to retrieve.
        bRaw: If true, will return raw data and not string format.
    Returns: String (if bRaw is true, variant based on type)
#ce
Func Data_Get($sName, $bRaw = False)
    For $aSub In $g_aData
        If $aSub[0] = $sName Then
            If $bRaw = True Then Return $aSub[2]
            Switch $aSub[1]
                Case $DATA_TEXT, $DATA_NUMBER
                    Return $aSub[2]
                Case $DATA_RATIO
                    Local $vResult = $aSub[2]
                    If $vResult[1] = 0 Then Return $vResult[0]
                    Return $vResult[0] & "/" & $vResult[1]

                Case $DATA_PERCENT
                    Local $vResult = $aSub[2]
                    If (Data_Get($vResult[0]) = -1) Or (Data_Get($vResult[1]) = -1) Then Return -1

                    If Data_Get($vResult[1]) = 0 Then Return StringFormat("%.2f", 0) & "%"
                    Return StringFormat("%.2f", (Int(Data_Get($vResult[0]))  /  Int(Data_Get($vResult[1]))) * 100) & "%"

                Case $DATA_TIME
                    Return getTimeString(TimerDiff($aSub[2])/1000)

                Case $DATA_TIMEAVG
                    Local $vResult = $aSub[2]

                    Local $iSeconds = TimerDiff(Data_Get($vResult[0], True))/1000
                    Local $iDenom = Data_Get($vResult[1], True)

                    If isArray($iDenom) = True Then $iDenom = $iDenom[0]
                    
                    If $iSeconds = 0 Or $iDenom = 0 Then Return getTimeString(0)
                    Return getTimeString($iSeconds/$iDenom)

                Case $DATA_LIST
                    Local $vResult = $aSub[2]
                    Local $sResult = "" ;Stores list data in string form.
                    For $i = 0 To UBound($vResult)-1
                        $sResult &= ", " & $vResult[$i][0] & ": " & $vResult[$i][1]
                    Next

                    Return StringMid($sResult, 3)
            EndSwitch
        EndIf
    Next

    Return -1
EndFunc

#cs 
    Function: Retrieve calculated quotient of the ratio.
    Parameters:
        sName: Data name to retrieve.
    Returns: A double. 
#ce
Func Data_Get_Ratio($sName)
For $aSub In $g_aData
        If $aSub[0] = $sName Then
            Switch $aSub[1]
                Case $DATA_RATIO
                    Local $vResult = $aSub[2]
                    If $vResult[1] = 0 Then Return 1
                    Return Int($vResult[0]) / Int($vResult[1])
            EndSwitch
        EndIf
    Next

    Return 1
EndFunc

#cs 
    Function: Changes value of an existing data.
    Parameters:
        sName: Data name to modify.
        vValue: Variant value based on type.
    Returns:
        If data does not exist, false.
        If data has been changed, true. 
#ce
Func Data_Set($sName, $vValue)
    Log_Level_Add("Data_Set")

    Local $aSub = Null ;Will store sub data
    Local $iIndex = 0 ;Index of sub data

    For $t_aSub In $g_aData
        If $t_aSub[0] = $sName Then
            $aSub = $t_aSub
            ExitLoop
        EndIf

        $iIndex += 1
    Next

    If Data_Get($sName) <> $vValue And Data_Get($sName, True) <> $vValue Then 
        Local $sValue = $vValue
        If isArray($sValue) = True Then $sValue = _ArrayToString($vValue)
        Log_Add("Setting data '" & $sName & "' To: " & $vValue, $LOG_DEBUG)
    EndIf

    Local $bOutput = False
    While True 
        If $aSub = Null Then ExitLoop

        ;Formatting data
        Switch $aSub[1]
            Case $DATA_RATIO, $DATA_PERCENT, $DATA_TIMEAVG
                If isArray($vValue) = False Then
                    Local $t_aValue = StringSplit(vValue, "/", $STR_NOCOUNT)
                    $vValue = $t_aValue
                EndIf
            
            Case $DATA_LIST
                If isArray($vValue) = False Then $vValue = formatArgs($vValue, ",", ":")
        EndSwitch

        $aSub[2] = $vValue
        $g_aData[$iIndex] = $aSub

        $bOutput = True
        ExitLoop
    WEnd

    Log_Level_Remove()
    Return $bOutput
EndFunc


#cs 
    Function: Increments values of specific types
    Parameters:
        sName: Data name to increment.
        iAmount: Amount to increment value.
        sListItem: Increment specific item in list type.
    Returns:
        If data does not exist, false.
        If data has been changed, true. 
#ce
Func Data_Increment($sName, $iAmount = 1, $sListItem = Null)
    Log_Level_Add("Data_Increment")
    Log_Add("Data Increment '" & $sName & "' by " & $iAmount, $LOG_DEBUG)
    Local $bOutput = False

    While True
        Local $aSub = Null ;Will store sub data
        Local $iIndex = 0 ;Index of sub index

        For $t_aSub In $g_aData
            If $t_aSub[0] = $sName Then
                $aSub = $t_aSub
                ExitLoop
            EndIf

            $iIndex += 1
        Next

        ;Returns early if not found
        If $aSub = Null Then ExitLoop

        ;Increment based on type
        Switch $aSub[1] ;Type
            Case $DATA_NUMBER
                $aSub[2] += $iAmount
            Case $DATA_RATIO
                Local $aRatio = $aSub[2]
                $aRatio[0] += $iAmount

                $aSub[2] = $aRatio
            Case $DATA_LIST
                If $sListItem = Null Then ExitLoop
                Local $vResult = $aSub[2]
                For $i = 0 To UBound($vResult)-1
                    If $vResult[$i][0] = $sListItem Then
                        $vResult[$i][1] += $iAmount
                        ExitLoop
                    EndIf
                Next

                $aSub[2] = $vResult
            Case Else  
                ExitLoop
        EndSwitch

        $g_aData[$iIndex] = $aSub

        $bOutput = True
        ExitLoop
    WEnd

    Log_Level_Remove()
    Return $bOutput
EndFunc

#cs 
    Function: Display data to a ListView control.
    Precondition: Items must already be added using Data_Display_Update function.
    Parameters:
        aOrder: An array with the string of data names to specify the order in which the data is displayed.
        hListView: Listview control to display to.
#ce
Func Data_Display($aOrder = $g_aOrder, $hListView = $hLV_Stat)
    For $i = 0 To UBound($g_aOrder)-1
        Local $sData = Data_Get($g_aOrder[$i])
        If _GUICtrlListView_GetItemText($hListView, $i, 1) <> $sData Then
            _GUICtrlListView_SetItemText($hListView, $i, Data_Get($g_aOrder[$i]), 1)
        EndIf
    Next
EndFunc

#cs 
    Function: Deletes all items in Listview control and adds new items from aOrder list.
    Parameters:
        aOrder: An array with the string of data names to specify the order in which the data is displayed.
        hListView: Listview control to display to.
#ce
Func Data_Display_Update($aOrder = $g_aOrder, $hListView = $hLV_Stat)
    _GUICtrlListView_DeleteAllItems($hListView)
    For $sOrder In $g_aOrder
        Local $iItemIndex = _GUICtrlListView_AddItem($hListView, $sOrder)
        _GUICtrlListView_SetItemText($hListView, $iItemIndex, Data_Get($sOrder), 1)
    Next
EndFunc

#cs 
    Function: Clears the global $g_aData list.
#ce
Func Data_Clear()
    Local $t_aEmpty[0]
    $g_aData = $t_aEmpty
EndFunc

#cs 
    Function: Inserts data name to order in specified index.
    Parameters:
        sName: Data name to insert.
        iIndex: Index to place data name to.
    Returns:
        if index is invalid, false.
        if success, true. 
#ce
Func Data_Order_Insert($sName, $iIndex)
    If $iIndex > UBound($g_aOrder) Then Return False

    Data_Order_Add($sName)
    Local $iSize = 0 ;Stores number of elements in aNew
    Local $aNew[0] ;Will store new data
    For $sOrder In $g_aOrder
        If $iSize = $iIndex Then
            $iSize += 1
            ReDim $aNew[$iSize]
            $aNew[$iSize-1] = $sName
        EndIf

        If $sOrder <> $sName Then
            $iSize += 1
            ReDim $aNew[$iSize]
            $aNew[$iSize-1] = $sOrder
        EndIf
    Next

    $g_aOrder = $aNew
    Return True
EndFunc

#cs 
    Function: Add a data name to order. Any existing/new data names will be pushed to the end.
    Parameters:
        sName: Data name to add to order list.
#ce
Func Data_Order_Add($sName)
    Local $iSize = 0 ;Stores number of elements in aNew
    Local $aNew[$iSize] ;Will store new data
    For $sOrder In $g_aOrder
        If $sOrder <> $sName Then
            $iSize += 1
            ReDim $aNew[$iSize]
            $aNew[$iSize-1] = $sOrder
        EndIf
    Next

    $iSize += 1
    ReDim $aNew[$iSize]
    $aNew[$iSize-1] = $sName

    $g_aOrder = $aNew
EndFunc

#cs 
    Function: Removes data name from list.
    Parameters:
        sName: Data name to remove.
#ce
Func Data_Order_Remove($sName)
    Local $iSize = 0 ;Stores number of elements in aNew
    Local $aNew[0] ;Will store new data
    For $sOrder In $g_aOrder
        If $sOrder <> $sName Then
            $iSize += 1
            ReDim $aNew[$iSize]
            $aNew[$iSize-1] = $sOrder
        EndIf
    Next

    $g_aOrder = $aNew
EndFunc

#cs 
    Function: Clears order list.
#ce
Func Data_Order_Clear()
    Local $aNew[0]
    $g_aOrder = $aNew
EndFunc