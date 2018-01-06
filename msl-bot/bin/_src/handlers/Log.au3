#include-once
#include "../imports.au3"
#cs 
    Log system will be based on the function processes and their steps.
#ce

Global Const $LOG_INFORMATION = "Information", $LOG_ERROR = "Error", $LOG_PROCESS = "Process", $LOG_DEBUG = "Debug"

Global $g_aLog[0][6] ;Stores the log structure
Global $g_sLogFilter = "Information,Error,Process"
Global $g_aLOG_Function[1] = [0] ;Current function and level
Global $g_iLOG_Processed = 0 ;Number of log items processed for display
Global $g_bLogEnabled = True ;Allows for Log_Add if enabled

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

Func Log_Add($sText, $sType = $LOG_PROCESS, $iTimeStamp = NowTimeStamp(), $sFunction = $g_aLOG_Function[$g_aLOG_Function[0]], $iLevel = $g_aLOG_Function[0])
    If $g_bLogEnabled = False Then Return 0
    
    Local $iSize = UBound($g_aLog)
    ReDim $g_aLog[$iSize+1][6]
    $g_aLog[$iSize][0] = $iTimeStamp
    $g_aLog[$iSize][1] = $sText
    $g_aLog[$iSize][2] = $sType
    $g_aLog[$iSize][3] = $sFunction
    $g_aLog[$iSize][4] = $g_sLocation
    $g_aLog[$iSize][5] = $iLevel

    Log_Display()
EndFunc

Func Log_Level_Add($sFunction)
    Local $iSize = UBound($g_aLOG_Function)
    ReDim $g_aLOG_Function[$iSize+1]
    $g_aLOG_Function[0] += 1

    $g_aLOG_Function[$g_aLOG_Function[0]] = $sFunction
EndFunc

Func Log_Level_Remove()
    Local $iSize = UBound($g_aLOG_Function)
    If $iSize > 1 Then
        ReDim $g_aLOG_Function[$iSize-1]
        $g_aLOG_Function[0] -= 1
    EndIf
EndFunc

Func Log_Display($sFilter = $g_sLogFilter, $aLog = $g_aLog, $hListView = $hLV_Log)
    Local $iSize = UBound($aLog)
    If ($iSize - $g_iLOG_Processed) > 10 Then
        _GUICtrlListView_BeginUpdate($hLV_Log)
    EndIf

    While $iSize > $g_iLOG_Processed
        If (StringInStr($sFilter, $aLog[$g_iLOG_Processed][2]) = True) Or ($sFilter = $aLog[$g_iLOG_Processed][2]) Then
            Local $sTime = $aLog[$g_iLOG_Processed][0]
            If StringLeft($sTime, 1) = "." Then $sTime = StringMid($sTime, 2)
            _GUICtrlListView_InsertItem($hListView, formatTime($sTime), 0)
            
            Local $sLevel = ""
            Local $sDebug = ""
            If $aLog[$g_iLOG_Processed][2] = "Debug" Then $sDebug = " \\ "
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
    WEnd

    _GUICtrlListView_EndUpdate($hLV_Log)
EndFunc

Func Log_Display_Reset($sFilter = $g_sLogFilter, $hListView = $hLV_Log)
    $g_iLOG_Processed = 0
    _GUICtrlListView_DeleteAllItems($hListView)

    Log_Display($sFilter)
Endfunc

Func Log_Save(ByRef $aLog, $sProfileName = getArg(formatArgs(getScriptData($g_aScripts, "_Config")[2]), "Profile_Name"), $bClear = False)
    ;Defining variables
    Local $iSize = UBound($aLog)
    If $iSize = 0 Then Return 0
    Local $sPath = StringReplace(@ScriptDir & "\profiles\" & $sProfileName & "\log\" & StringReplace(_NowDate(), "/", ".") & ".txt", "\\", "\")
    Local $hFile = FileOpen($sPath, 9)
    Local $sDate = _NowCalc()

    FileWriteLine($hFile, @CRLF & "#### Begin Log Saved: " & _NowCalc() & " ####")
    For $i = 0 To $iSize-1
        If StringLeft($aLog[$i][0], 1) <> "." Then
            Local $sLine = ""

            $sLine &= formatTime($aLog[$i][0]) & " "
            $sLine &= formatWidth($aLog[$i][2], 11, $ALIGN_RIGHT) & " "
            $sLine &= formatWidth($aLog[$i][3], 20, $ALIGN_RIGHT) & " "
            $sLine &= formatWidth($aLog[$i][5], 2, $ALIGN_RIGHT) & " "
            $sLine &= formatWidth($aLog[$i][4], 20, $ALIGN_RIGHT) & " "
            $sLine &= '"' & $aLog[$i][1] & '"'

            $aLog[$i][0] = "." & $aLog[$i][0]

            If ($g_bSaveDebug = False) And ($aLog[$i][2] = "Debug") Then ContinueLoop
            FileWriteLine($hFile, $sLine)
        EndIf
    Next

    FileWriteLine($hFile, "#### End Log Saved: " & _NowCalc() & " ####" & @CRLF)
    FileClose($hFile)

    If $bClear = True Then
        Log_Clear($aLog)
    EndIf
EndFunc

Func Log_Clear(ByRef $aLog, $bClearInfo = False)
    Local $aEmpty[0][6]
    If $bClearInfo = False Then
        For $i = 0 To UBound($aLog)-1
            If $aLog[$i][2] = "Information" Then
                ReDim $aEmpty[UBound($aEmpty)+1][6]
                For $x = 0 To 5
                    $aEmpty[UBound($aEmpty)-1][$x] = $aLog[$i][$x]
                Next
            EndIf
        Next
    EndIf

    $aLog = $aEmpty
    Log_Display_Reset()
EndFunc

Global Const $ALIGN_LEFT = 0, $ALIGN_RIGHT = 1
Func formatWidth($sStr, $iWidth, $iAlign)
    Local $sOutput = ""
    Local $sSpace = ""

    If StringLen($sStr) < $iWidth Then
        For $i = 1 To $iWidth-StringLen($sStr)
            $sSpace &= " "
        Next
    Else
        Return $sStr
    EndIf

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