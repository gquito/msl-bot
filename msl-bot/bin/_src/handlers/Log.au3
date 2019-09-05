#include-once

#cs 
    Log system will be based on the function processes and their steps.
#ce
#cs ----Log structure
    [
        ["TimeStamp", "Text", "Type", "Function", "Location", "Level"],
        ["TimeStamp", "Text", "Type", "Function", "Location", "Level"],
        ["TimeStamp", "Text", "Type", "Function", "Location", "Level"],
        ...
    ]

    - TimeStamps reference to Time.au3
    - Text is the message.
    - Function is where the log takes place.
    - Location is what location the log was added in.
    - Level is the layer of function calls. For example, if you start a script, the level is 0 and when
        another function is called that has the logging system, the level will be 1. If another function is called
        within the level 1 function, the function called will be level 2.
    - Type: 
        - Information: Normal information, usually result of a process.
        - Error: An error in the process.
        - Process: Steps within a process.
        - Debug: Steps within the steps of the process, usually for developer.
            - Debug logs are usually in functions that are called often such as getLocation()
#ce

Func Log_Add($sText, $sType = $LOG_PROCESS, $iTimeStamp = NowTimeStamp(), $sFunction = "", $iLevel = $g_aLOG_Function[0])
    If ($Config_Log_Debug = False And $sType = $LOG_DEBUG) Or ($g_bLogEnabled = False) Then Return 0
    If $sFunction = "" Then
        If $g_aLOG_Function[0] > 1 Then
            $sFunction = $g_aLOG_Function[$g_aLOG_Function[0]] & " <- " & $g_aLOG_Function[$g_aLOG_Function[0]-1]
        Else
            $sFunction = $g_aLOG_Function[$g_aLOG_Function[0]]
        EndIf
    EndIf

    Local $iSize = UBound($g_aLog)
    ReDim $g_aLog[$iSize+1][6]
    $g_aLog[$iSize][0] = $iTimeStamp
    $g_aLog[$iSize][1] = $sText
    $g_aLog[$iSize][2] = $sType
    $g_aLog[$iSize][3] = $sFunction
    $g_aLog[$iSize][4] = $g_sLocation
    $g_aLog[$iSize][5] = $iLevel

    Log_WriteLine($iSize,($iSize > $g_iLogTotalLimit))
    Log_Display()
EndFunc

Func Log_Level_Add($sFunction)
    Local $iSize = UBound($g_aLOG_Function)
    ReDim $g_aLOG_Function[$iSize+1]

    $g_aLOG_Function[0] += 1
    $g_aLOG_Function[$g_aLOG_Function[0]] = $sFunction

    If ($g_hLV_FunctionLevels <> Null) Then
        Local $iItemCount = _GUICtrlListView_GetItemCount($g_hLV_FunctionLevels)
        $iSize = UBound($g_aLOG_Function)

        If ($iItemCount <> $iSize-1) Then
            _GUICtrlListView_DeleteAllItems($g_hLV_FunctionLevels)
            For $i = 1 To $iSize-1
                _GUICtrlListView_AddItem($g_hLV_FunctionLevels, $i)
                _GUICtrlListView_AddSubItem($g_hLV_FunctionLevels, $i-1, $g_aLOG_Function[$i], 1)
            Next
        Else
            _GUICtrlListView_AddItem($g_hLV_FunctionLevels, $iItemCount)
            _GUICtrlListView_AddSubItem($g_hLV_FunctionLevels, $iItemCount-1, $sFunction, 1)
        EndIf
    EndIf
EndFunc

Func Log_Level_Clear()
    Local $iSize = UBound($g_aLOG_Function)
    If ($iSize > 1) Then
        For $i = 0 to $iSize
            Log_Level_Remove()
        Next
    EndIf
EndFunc

Func Log_Level_Remove()
    Local $iSize = UBound($g_aLOG_Function)
    If ($iSize > 1) Then
        ReDim $g_aLOG_Function[$iSize-1]
        $g_aLOG_Function[0] -= 1

        If ($g_hLV_FunctionLevels <> Null) Then
            _GUICtrlListView_DeleteItem($g_hLV_FunctionLevels, _GUICtrlListView_GetItemCount($g_hLV_FunctionLevels)-1)
        EndIf
    EndIf
EndFunc

Func Log_Display($sFilter = $g_sLogFilter, $aLog = $g_aLog, $hListView = $g_hLV_Log)
    Local $iSize = UBound($aLog)
    If (($iSize - $g_iLOG_Processed) > 10) Then _GUICtrlListView_BeginUpdate($g_hLV_Log)

    Local $iCountProcessed = 0
    While $iSize > $g_iLOG_Processed
        If ($g_bRunning And $iCountProcessed > 100) Then ExitLoop

        If (StringInStr($sFilter, $aLog[$g_iLOG_Processed][2]) Or $sFilter = $aLog[$g_iLOG_Processed][2]) Then
            Local $sTime = $aLog[$g_iLOG_Processed][0]
            If (StringLeft($sTime, 1) = ".") Then $sTime = StringMid($sTime, 2)
            _GUICtrlListView_InsertItem($hListView, formatTime($sTime) & "      (" & _GUICtrlListView_GetItemCount($hListView)+1 & ")", 0)
            
            Local $sLevel = ""
            Local $sDebug = ""
            If ($aLog[$g_iLOG_Processed][2] = "Debug") Then $sDebug = " \\ "
            For $i = 2 To $aLog[$g_iLOG_Processed][5]
                $sLevel &= ">"
            Next
            $sLevel &= " "

            _GUICtrlListView_SetItemText($hListView, 0, $sLevel & $sDebug & $aLog[$g_iLOG_Processed][1], 1)
            _GUICtrlListView_SetItemText($hListView, 0, $aLog[$g_iLOG_Processed][2], 2)
            _GUICtrlListView_SetItemText($hListView, 0, $aLog[$g_iLOG_Processed][3], 3)
            _GUICtrlListView_SetItemText($hListView, 0, $aLog[$g_iLOG_Processed][4], 4)
            _GUICtrlListView_SetItemText($hListView, 0, $aLog[$g_iLOG_Processed][5], 5)
        EndIf

        $g_iLOG_Processed += 1
        $iCountProcessed += 1
    WEnd

    _GUICtrlListView_EndUpdate($g_hLV_Log)
EndFunc

Func Log_Display_Reset($sFilter = $g_sLogFilter, $hListView = $g_hLV_Log)
    $g_iLOG_Processed = 0
    _GUICtrlListView_DeleteAllItems($hListView)

    Log_Display($sFilter)
EndFunc

Func Log_WriteLine($iLogLine, $bClear = False)
    If $Config_Save_Logs = False Then 
        If ($bClear) Then Log_Clear($g_aLog)
        Return False
    EndIf
	
    Local $sLogPath = $g_sProfileFolder & "\" & $Config_Profile_Name & "\log\" ;& formatDate() & "\"
    If (Not(FileExists($sLogPath))) Then DirCreate($sLogPath)
    Local $sPath = StringReplace($sLogPath & FormatDateForFile() & ".txt", "\\", "\")
    Local $hFile = FileOpen($sPath, $FO_APPEND+$FO_CREATEPATH)

    If (StringLeft($g_aLog[$iLogLine][0], 1) <> ".") Then
        Local $sLine = ""

        $sLine &= formatTime($g_aLog[$iLogLine][0]) & " "
        $sLine &= formatWidth($g_aLog[$iLogLine][2], 11, $ALIGN_RIGHT) & " "
        $sLine &= formatWidth($g_aLog[$iLogLine][3], 40, $ALIGN_RIGHT) & " "
        $sLine &= formatWidth($g_aLog[$iLogLine][5], 2, $ALIGN_RIGHT) & " "
        $sLine &= formatWidth($g_aLog[$iLogLine][4], 20, $ALIGN_RIGHT) & " "
        $sLine &= '"' & $g_aLog[$iLogLine][1] & '"'

        $g_aLog[$iLogLine][0] = "." & $g_aLog[$iLogLine][0]
        FileWriteLine($hFile, $sLine)
    EndIf

    FileClose($hFile)

    If ($bClear) Then Log_Clear($g_aLog)
EndFunc

Func FormatDateForFile()
    Return StringFormat("%s.%s.%s", getMonth(), getDay(), getYear())
EndFunc

Func Log_Save(ByRef $aLog, $bClear = False)
    If $Config_Save_Logs = False Then 
        If ($bClear) Then Log_Clear($aLog)
        Return False
    EndIf

    ;Defining variables
    Local $iSize = UBound($aLog)
    If ($iSize = 0) Then Return 0
    Local $sLogPath = $g_sProfileFolder & "\" & $Config_Profile_Name & "\log\" ;& formatDate() & "\"
    If (Not(FileExists($sLogPath))) Then DirCreate($sLogPath)
    Local $sPath = StringReplace($sLogPath & FormatDateForFile() & ".txt", "\\", "\")
    Local $hFile = FileOpen($sPath, $FO_APPEND+$FO_CREATEPATH)

    FileWriteLine($hFile, @CRLF & "#### Begin Log Saved: " & _NowCalc() & " ####")
    For $i = 0 To $iSize-1
        If (StringLeft($aLog[$i][0], 1) <> ".") Then
            Local $sLine = ""

            $sLine &= formatTime($aLog[$i][0]) & " "
            $sLine &= formatWidth($aLog[$i][2], 11, $ALIGN_RIGHT) & " "
            $sLine &= formatWidth($aLog[$i][3], 20, $ALIGN_RIGHT) & " "
            $sLine &= formatWidth($aLog[$i][5], 2, $ALIGN_RIGHT) & " "
            $sLine &= formatWidth($aLog[$i][4], 20, $ALIGN_RIGHT) & " "
            $sLine &= '"' & $aLog[$i][1] & '"'

            $aLog[$i][0] = "." & $aLog[$i][0]
            FileWriteLine($hFile, $sLine)
        EndIf
    Next

    FileWriteLine($hFile, "#### End Log Saved: " & _NowCalc() & " ####" & @CRLF)
    FileClose($hFile)

    If ($bClear) Then Log_Clear($aLog)
EndFunc

Func Log_Clear(ByRef $aLog, $bClearInfo = False)
    Local $aEmpty[0][6]
    If (Not($bClearInfo)) Then
        ;Limit for number of information log: 1000 ($g_iLogInfoLimit)
        For $i = 0 To UBound($aLog)-1
            If ($aLog[$i][2] = "Information") Then
                ReDim $aEmpty[UBound($aEmpty)+1][6]
                For $x = 0 To 5
                    $aEmpty[UBound($aEmpty)-1][$x] = $aLog[$i][$x]
                Next
            EndIf
        Next

        If (UBound($aEmpty)+1 > $g_iLogInfoLimit) Then
            Local $iEnd = (UBound($aEmpty)+1)-$g_iLogInfoLimit
            LocaL $sRange = "0-" & $iEnd
            _ArrayDelete($aEmpty, $sRange)
        EndIf
    EndIf

    $aLog = $aEmpty
    Log_Display_Reset()
EndFunc

Func formatWidth($sStr, $iWidth, $iAlign)
    Local $sOutput = ""
    Local $sSpace = ""

    If (StringLen($sStr) >= $iWidth) Then Return $sStr

    For $i = 1 To $iWidth-StringLen($sStr)
        $sSpace &= " "
    Next

    Switch $iAlign
        Case $ALIGN_LEFT
            $sOutput = $sStr & $sSpace
        Case $ALIGN_RIGHT
            $sOutput = $sSpace & $sStr
        Case Else
            $sOutput = $sStr
    EndSwitch

    Return $sOutput
EndFunc