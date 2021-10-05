#include-once

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
    Schedule_Handle()
    Stats_Handle()
    Cumulative_Handle()
    
    Local $iCode = GUIGetMsg(1)
    GUI_HANDLE_MESSAGE($iCode)
EndFunc

Func GUI_HANDLE_MESSAGE($iCode)
    Switch $iCode[1]
        Case $g_hParent
            Switch $iCode[0]
                Case $g_idPic
                    AutoItSetOption("MouseCoordMode", 2)
                    Local $aCursor = MouseGetPos()
                    AutoItSetOption("MouseCoordMode", 1)

                    UpdatePicture($aCursor)
                Case $g_idBtn_CaptureRegion
                    ResetHandles()
                    Local $bOldRunning = $g_bRunning
                    $g_bRunning = True
                    CaptureRegion()
                    $g_bRunning = $bOldRunning
                Case $g_idLbl_Donate
                    ShellExecute("https://paypal.me/GkevinOD/10")
                Case $g_idLbl_Discord
                    ShellExecute("https://discord.gg/UQGRnwf")
                Case $g_idLbl_List
                    MsgBox($MB_ICONINFORMATION+$MB_OK, "MSL Donator Features", "Completed: " & @CRLF & "- Astroleague, champion league, daily quests, expedition, bingo, gold dungeon, special dungeon, dragon dungeons, guided auto.")
                Case $g_idCkb_Information, $g_idCkb_Error, $g_idCkb_Process, $g_idCkb_Debug
                    Local $sFilter = ""
                    If GUICtrlRead($g_idCkb_Information) = $GUI_CHECKED Then $sFilter &= "Information,"
                    If GUICtrlRead($g_idCkb_Error) = $GUI_CHECKED Then $sFilter &= "Error,"
                    If GUICtrlRead($g_idCkb_Process) = $GUI_CHECKED Then $sFilter &= "Process,"
                    If GUICtrlRead($g_idCkb_Debug) = $GUI_CHECKED Then $sFilter &= "Debug,"

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
                    WinMove($g_sAppTitle, "", $aWinPos[0], $aWinPos[1], 400, 420)
                    Local $aControlPos = ControlGetPos("","",$g_hLV_Stat)
                    ControlMove("", "", $g_hLV_Stat, $aControlPos[0], $aControlPos[1], $aControlPos[2], 240)
                    GUICtrlSetResizing($g_idLV_Stat, $GUI_DOCKTOP+$GUI_DOCKBOTTOM)
                    WinMove($g_sAppTitle, "", $aWinPos[0], $aWinPos[1], $aWinPos[2], $aWinPos[3])

                    CreateLogWindow()
                Case $g_idBtn_Add
                    ControlDisable("", "", $g_idBtn_Add)
                    ControlDisable("", "", $g_idBtn_Remove)
                    ControlDisable("", "", $g_idBtn_Save)
                    ControlDisable("", "", $g_idBtn_Edit)
                    CreateScheduleAdd()

                Case $g_idBtn_Remove
                    Local $aSelectedIndices = _GUICtrlListView_GetSelectedIndices($g_hLV_Schedule, True)
                    For $i = $aSelectedIndices[0] To 1 Step -1
                        Local $sName = StringReplace(StringReplace(_GUICtrlListView_GetItemText($g_hLV_Schedule, $aSelectedIndices[$i]), "[ON] ", ""), "[OFF] ", "")
						Schedule_RemoveByName($sName)
                    Next
            
                Case $g_idBtn_Edit
                    Local $iIndex = _GUICtrlListView_GetSelectedCount($g_hLV_Schedule)
                    If $iIndex = 1 Then
                        $iIndex = _GUICtrlListView_GetSelectedIndices($g_hLV_Schedule, True)[1] ;LV Index

                        Local $sName = StringReplace(StringReplace(_GUICtrlListView_GetItemText($g_hLV_Schedule, $iIndex), "[ON] ", ""), "[OFF] ", "")
                        $iIndex = Schedule_IndexByName($sName) ;Schedule Array Index

                        $g_iEdit_Index = $iIndex
                        Local $iResult = -1
                        Local $aFlags = _Schedule_GetFlagCombo($iIndex)
                        Local $sCooldown = "|" & $g_aSchedules[$iIndex][$SCHEDULE_COOLDOWN]
                        For $i = 0 To 5
                            If $i <> $g_aSchedules[$iIndex][$SCHEDULE_COOLDOWN] Then
                                $sCooldown &= "|" & $i
                            EndIf
                        Next
                        $sCooldown = StringMid($sCooldown, 2)

                        Switch $g_aSchedules[$iIndex][$SCHEDULE_TYPE]
                            Case $SCHEDULE_TYPE_DATE
                                Local $aDate = ($g_aSchedules[$iIndex][$SCHEDULE_STRUCTURE])[0]
                                Local $aPreset = [$g_aSchedules[$iIndex][$SCHEDULE_NAME], _
                                                  _ArrayToString($g_aSchedules[$iIndex][$SCHEDULE_ACTION], @CRLF), _
                                                  $aDate[0], _
                                                  $aDate[1], _
                                                  $aDate[2], _
                                                  $aDate[3], _
                                                  $aDate[4], _
                                                  $g_aSchedules[$iIndex][$SCHEDULE_ITERATIONS], _
                                                  _ArrayToString($aFlags), _
                                                  $sCooldown, _
                                                  ($g_aSchedules[$iIndex][$SCHEDULE_ENABLED] = "True" ? "True|False" : "False|True")]
                                $g_iScheduleType = $SCHEDULE_TYPE_DATE
                                $iResult = GeneratePromptsWindow($g_hParent, "Schedule Edit Date", $g_sSCHEDULE_DATE_PROMPTS, $aPreset, $g_sSCHEDULE_DATE_HELP, False)
                            Case $SCHEDULE_TYPE_TIMER
                                Local $aTime = StringSplit(getTimeString(($g_aSchedules[$iIndex][$SCHEDULE_STRUCTURE])[1]), " ", $STR_NOCOUNT)
                                Local $iHours = 0
                                Local $iMinutes = 0
                                Local $iSeconds = 0
                                For $i = 0 To UBound($aTime)-1
                                    Switch StringRight($aTime[$i], 1)
                                        Case "D"
                                            $iHours += StringMid($aTime[$i], 1, StringLen($aTime[$i])-1)*24
                                        Case "H"
                                            $iHours += StringMid($aTime[$i], 1, StringLen($aTime[$i])-1)
                                        Case "M"
                                            $iMinutes += StringMid($aTime[$i], 1, StringLen($aTime[$i])-1)
                                        Case "S"
                                            $iSeconds += StringMid($aTime[$i], 1, StringLen($aTime[$i])-1)
                                    EndSwitch
                                Next
                                Local $aPreset = [$g_aSchedules[$iIndex][$SCHEDULE_NAME], _
                                                  _ArrayToString($g_aSchedules[$iIndex][$SCHEDULE_ACTION], @CRLF), _
                                                  $iHours, _
                                                  $iMinutes, _
                                                  $iSeconds, _
                                                  $g_aSchedules[$iIndex][$SCHEDULE_ITERATIONS], _
                                                  _ArrayToString($aFlags), _
                                                  $sCooldown, _
                                                  ($g_aSchedules[$iIndex][$SCHEDULE_ENABLED] = "True" ? "True|False" : "False|True")]

                                $g_iScheduleType = $SCHEDULE_TYPE_TIMER
                                $iResult = GeneratePromptsWindow($g_hParent, "Schedule Edit Timer", $g_sSCHEDULE_TIMER_PROMPTS, $aPreset, $g_sSCHEDULE_TIMER_HELP, False)
                            Case $SCHEDULE_TYPE_DAY
                                Local Const $DAYOFWEEK = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
                                Local $sDayOfWeekCombo = _DateDayOfWeek(($g_aSchedules[$iIndex][$SCHEDULE_STRUCTURE])[1])
                                For $i = 0 To UBound($DAYOFWEEK)-1
                                    If $DAYOFWEEK[$i] <> ($g_aSchedules[$iIndex][$SCHEDULE_STRUCTURE])[1] Then
                                        $sDayOfWeekCombo &= "|" & $DAYOFWEEK[$i]
                                    EndIf
                                Next
                                Local $aTime = ($g_aSchedules[$iIndex][$SCHEDULE_STRUCTURE])[0]
                                Local $aPreset = [$g_aSchedules[$iIndex][$SCHEDULE_NAME], _
                                                  _ArrayToString($g_aSchedules[$iIndex][$SCHEDULE_ACTION], @CRLF), _
                                                  $sDayOfWeekCombo, _
                                                  $aTime[0], _
                                                  $aTime[1], _
                                                  $aTime[2], _
                                                  $g_aSchedules[$iIndex][$SCHEDULE_ITERATIONS], _
                                                  _ArrayToString($aFlags), _
                                                  $sCooldown, _
                                                  ($g_aSchedules[$iIndex][$SCHEDULE_ENABLED] = "True" ? "True|False" : "False|True")]
                                                  
                                $g_iScheduleType = $SCHEDULE_TYPE_DAY
                                $iResult = GeneratePromptsWindow($g_hParent, "Schedule Edit Day", $g_sSCHEDULE_DAY_PROMPTS, $aPreset, $g_sSCHEDULE_DAY_HELP, False)
                            Case $SCHEDULE_TYPE_CONDITION
                                Local $sConditions = __ArrayToString(($g_aSchedules[$iIndex][$SCHEDULE_STRUCTURE])[0])
                                $sConditions = StringReplace($sConditions, "\1", @CRLF, 0)
                                $sConditions = StringReplace($sConditions, "\2", " && ")
                                Local $aPreset = [$g_aSchedules[$iIndex][$SCHEDULE_NAME], _
                                                  _ArrayToString($g_aSchedules[$iIndex][$SCHEDULE_ACTION], @CRLF), _
                                                  $sConditions, _
                                                  (($g_aSchedules[$iIndex][$SCHEDULE_STRUCTURE])[1] = "True" ? "True|False" : "False|True"), _
                                                  $g_aSchedules[$iIndex][$SCHEDULE_ITERATIONS], _
                                                  _ArrayToString($aFlags), _
                                                  $sCooldown, _
                                                  ($g_aSchedules[$iIndex][$SCHEDULE_ENABLED] = "True" ? "True|False" : "False|True")]

                                $g_iScheduleType = $SCHEDULE_TYPE_CONDITION
                                $iResult = GeneratePromptsWindow($g_hParent, "Schedule Edit Condition", $g_sSCHEDULE_CONDITION_PROMPTS, $aPreset, $g_sSCHEDULE_CONDITION_HELP, False)
                        EndSwitch

                        If $iResult = -1 Then
                            Log_Add("Error editing schedule.", $LOG_ERROR)
                            Local $t_iCode = [$GUI_EVENT_CLOSE, $g_hScheduleAdd]
                            GUI_HANDLE_MESSAGE($t_iCode)
                        EndIf
                    Else ;0 or more than 1 selected
                        MsgBox($MB_ICONWARNING, "Schedule Edit", "Select one item.", 5)
                    EndIf
                
                Case $g_idBtn_Save
                    Local $iIndex = _GUICtrlListView_GetSelectedCount($g_hLV_Schedule)
                    If $iIndex > 0 Then
                        Local $aIndexes = _GUICtrlListView_GetSelectedIndices($g_hLV_Schedule, True) ;First item is count

                        ControlDisable("", "", $g_idBtn_Add)
                        ControlDisable("", "", $g_idBtn_Remove)
                        ControlDisable("", "", $g_idBtn_Save)
                        ControlDisable("", "", $g_idBtn_Edit)
                        
                        Local $iScheduleIndex = Schedule_IndexByName(StringRegExpReplace(_GUICtrlListView_GetItemText($g_hLV_Schedule, $aIndexes[1]), "(\[ON\] |\[OFF\] )", ""))
                        If $iScheduleIndex <> -1 Then
                            Local $sNamePreset = $g_aSchedules[$iScheduleIndex][$SCHEDULE_NAME]
                            If $aIndexes[0] > 1 Then
                                Local $iCustomPreset = 1
                                While FileExists($g_sProfileFolder & "\schedule_presets\Multi Preset " & $iCustomPreset & ".json")
                                    $iCustomPreset += 1
                                Wend

                                $sNamePreset = "Multi Preset " & $iCustomPreset
                            EndIf

                            Local $hInput = InputBox("Schedule Save", "Enter schedule preset name." & @CRLF & @CRLF & "Characters must be valid for a filename." & @CRLF & @CRLF & "Preset will be saved in \profiles\schedule_presets\", $sNamePreset, "", -1, -1, Default, Default, 30)
                            Local $hFile = FileOpen($g_sProfileFolder & "\schedule_presets\" & $hInput & ".json", $FO_OVERWRITE+$FO_CREATEPATH)
                            Local $sFinal ;Json file data
                            For $i = 1 To $aIndexes[0] 
                                Local $iTemp = Schedule_IndexByName(StringRegExpReplace(_GUICtrlListView_GetItemText($g_hLV_Schedule, $aIndexes[$i]), "(\[ON\] |\[OFF\] )", ""))
                                $sFinal &= @CRLF & "||" & @CRLF & _Schedule_ToJson($iTemp)
                            Next
                            $sFinal = StringMid($sFinal, 5)
                            Local $iResult = FileWrite($hFile, $sFinal)
                        
                            If $iResult = 0 Or $hInput == "" Then
                                MsgBox($MB_ICONERROR, "Schedule Save", "Could not write to file.", 5)
                            Else
                                MsgBox($MB_ICONINFORMATION, "Schedule Save", "Preset: " & $hInput & " has been created.", 5)
                            EndIf
                        Else
                            MsgBox($MB_ICONWARNING, "Schedule Save", "Could not get listview item index.", 5)
                        EndIf

                        ControlEnable("", "", $g_hBtn_Add)
                        ControlEnable("", "", $g_hBtn_Remove)
                        ControlEnable("", "", $g_hBtn_Save)
                        ControlEnable("", "", $g_hBtn_Edit)
                    Else
                        MsgBox($MB_ICONWARNING, "Schedule Save", "Select at least one item.", 5)
                    EndIf
                Case $PROMPTWINDOW_CLOSE
                    If $g_aPromptsWindow_Answers <> Null Then
                        Local $aScheduleStructure[8]
                        _Schedule_HandleAnswers($aScheduleStructure)
                        Schedule_Edit($g_iEdit_Index, _
                                      $aScheduleStructure[$SCHEDULE_NAME], _
                                      $aScheduleStructure[$SCHEDULE_ACTION], _
                                      $aScheduleStructure[$SCHEDULE_TYPE], _
                                      $aScheduleStructure[$SCHEDULE_ITERATIONS], _
                                      $aScheduleStructure[$SCHEDULE_STRUCTURE], _
                                      Int(StringLeft($aScheduleStructure[$SCHEDULE_FLAG], 1)), _
                                      $aScheduleStructure[$SCHEDULE_COOLDOWN], _
                                      $aScheduleStructure[$SCHEDULE_ENABLED-1])
                    EndIf
                Case $GUI_EVENT_CLOSE, $M_File_Quit
                    GUISetState(@SW_HIDE, $g_hParent)
                    CloseApp()
                Case $g_idBtn_Stop
                    If ($g_bRunning) Then Stop()
                Case Else
                    HandleMenu($iCode[0])
            EndSwitch
        Case $g_hLogWindow
            Switch $iCode[0]
                Case $GUI_EVENT_CLOSE
                    GUISwitch($g_hParent)
                    _GUICtrlTab_ClickTab($g_hTb_Main, 1)

                    Local $aWinPos = WinGetPos($g_sAppTitle)
                    WinMove($g_sAppTitle, "", $aWinPos[0], $aWinPos[1], 400, 420)

                    GUIDelete($g_hLogWindow)
                    $g_hLogWindow = Null
                    
                    BuildLogArea(True)

                    _GUICtrlTab_ClickTab($g_hTb_Main, 0)
                    _GUICtrlTab_ClickTab($g_hTb_Main, 1)

                    WinMove($g_sAppTitle, "", $aWinPos[0], $aWinPos[1], $aWinPos[2], $aWinPos[3])
                    
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
        Case $g_hScheduleAdd
            Switch $iCode[0]
                Case $GUI_EVENT_CLOSE, $g_idScheduleAdd_Cancel
                    GUISwitch($g_hParent)

                    ControlEnable("", "", $g_hBtn_Add)
                    ControlEnable("", "", $g_hBtn_Remove)
                    ControlEnable("", "", $g_hBtn_Save)
                    ControlEnable("", "", $g_hBtn_Edit)

                    GUIDelete($g_hScheduleAdd)
                Case $g_idScheduleAdd_Date
                    Local $iResult = GeneratePromptsWindow($g_hScheduleAdd, "Schedule Add Date", $g_sSCHEDULE_DATE_PROMPTS, $g_sSCHEDULE_DATE_PRESET, $g_sSCHEDULE_DATE_HELP)
                    $g_iPromptsWindow_AnswersID = "Schedule Add"

                    If $iResult = -1 Then
                        Log_Add("Error adding schedule.", $LOG_ERROR)
                        Local $t_iCode = [$GUI_EVENT_CLOSE, $g_hScheduleAdd]
                        GUI_HANDLE_MESSAGE($t_iCode)
                    EndIf

                    $g_iScheduleType = $SCHEDULE_TYPE_DATE

                Case $g_idScheduleAdd_Timer           
                    Local $iResult = GeneratePromptsWindow($g_hScheduleAdd, "Schedule Add Timer", $g_sSCHEDULE_TIMER_PROMPTS, $g_sSCHEDULE_TIMER_PRESET, $g_sSCHEDULE_TIMER_HELP)
                    $g_iPromptsWindow_AnswersID = "Schedule Add"

                    If $iResult = -1 Then
                        Log_Add("Error adding schedule.", $LOG_ERROR)
                        Local $t_iCode = [$GUI_EVENT_CLOSE, $g_hScheduleAdd]
                        GUI_HANDLE_MESSAGE($t_iCode)
                    EndIf

                    $g_iScheduleType = $SCHEDULE_TYPE_TIMER

                Case $g_idScheduleAdd_Day
                    Local $iResult = GeneratePromptsWindow($g_hScheduleAdd, "Schedule Add Day", $g_sSCHEDULE_DAY_PROMPTS, $g_sSCHEDULE_DAY_PRESET, $g_sSCHEDULE_DAY_HELP)
                    $g_iPromptsWindow_AnswersID = "Schedule Add"

                    If $iResult = -1 Then
                        Log_Add("Error adding schedule.", $LOG_ERROR)
                        Local $t_iCode = [$GUI_EVENT_CLOSE, $g_hScheduleAdd]
                        GUI_HANDLE_MESSAGE($t_iCode)
                    EndIf

                    $g_iScheduleType = $SCHEDULE_TYPE_DAY

                Case $g_idScheduleAdd_Condition
                    Local $iResult = GeneratePromptsWindow($g_hScheduleAdd, "Schedule Add Condition", $g_sSCHEDULE_CONDITION_PROMPTS, $g_sSCHEDULE_CONDITION_PRESET, $g_sSCHEDULE_CONDITION_HELP)
                    $g_iPromptsWindow_AnswersID = "Schedule Add"

                    If $iResult = -1 Then
                        Log_Add("Error adding schedule.", $LOG_ERROR)
                        Local $t_iCode = [$GUI_EVENT_CLOSE, $g_hScheduleAdd]
                        GUI_HANDLE_MESSAGE($t_iCode)
                    EndIf

                    $g_iScheduleType = $SCHEDULE_TYPE_CONDITION

                Case $g_idScheduleAdd_Preset
                    Local $aPrompts = ["!Enter preset name"]
                    Local $sHelp = "Presets can be found in:" & @CRLF & $g_sProfileFolder & "\schedule_presets\" & @CRLF & @CRLF
                    Local $aFileList = _FileListToArray($g_sProfileFolder & "\schedule_presets")
                    Local $aPresets[1]

                    If isArray($aFileList) Then
                        _ArrayDelete($aFileList, 0)

                        $sHelp &= "Available preset list:" & @CRLF & _ArrayToString($aFileList, @CRLF)
                        $aPresets[0] = _ArrayToString($aFileList)
                    Else
                        $aPrompts[0] = "Enter preset name"
                    EndIf

                    Local $iResult = GeneratePromptsWindow($g_hScheduleAdd, "Schedule Add Preset", $aPrompts, $aPresets, $sHelp)
                    $g_iPromptsWindow_AnswersID = "Schedule Preset"

                    If $iResult = -1 Then
                        Log_Add("Error adding schedule.", $LOG_ERROR)
                        Local $t_iCode = [$GUI_EVENT_CLOSE, $g_hScheduleAdd]
                        GUI_HANDLE_MESSAGE($t_iCode)
                    EndIf

                Case $PROMPTWINDOW_CLOSE
                    If $g_aPromptsWindow_Answers <> Null Then
                        Switch $g_iPromptsWindow_AnswersID
                            Case "Schedule Add"
                                Local $aScheduleStructure[8]
                                _Schedule_HandleAnswers($aScheduleStructure)
                                Schedule_Add($aScheduleStructure[$SCHEDULE_NAME], _
                                             $aScheduleStructure[$SCHEDULE_ACTION], _
                                             $aScheduleStructure[$SCHEDULE_TYPE], _
                                             $aScheduleStructure[$SCHEDULE_ITERATIONS], _
                                             $aScheduleStructure[$SCHEDULE_STRUCTURE], _
                                             Int(StringLeft($aScheduleStructure[$SCHEDULE_FLAG], 1)), _
                                             $aScheduleStructure[$SCHEDULE_COOLDOWN], _
                                             $aScheduleStructure[$SCHEDULE_ENABLED-1])

                            Case "Schedule Preset"
                                Schedule_AddPreset($g_aPromptsWindow_Answers[0])

                        EndSwitch
                    EndIf
                    $g_iPromptsWindow_AnswersID = Null

                    Local $t_iCode = [$GUI_EVENT_CLOSE, $g_hScheduleAdd]
                    GUI_HANDLE_MESSAGE($t_iCode)
            EndSwitch
        Case $g_hPromptsWindow
            Switch $iCode[0]
                Case $GUI_EVENT_CLOSE, $g_idPromptsWindow_Cancel
                    $g_aPromptsWindow_Answers = Null
                    GUISetState(@SW_SHOW, $g_hPromptsWindow_Parent)

                    If $g_hPromptsWindow_HelpWindow <> Null Then
                        Local $t_iCode = [$GUI_EVENT_CLOSE, $g_hPromptsWindow_HelpWindow]
                        GUI_HANDLE_MESSAGE($t_iCode)
                    EndIf

                    GUIDelete($g_hPromptsWindow)
                Case $g_idPromptsWindow_Done
                    Local $iSize = UBound($g_aPromptsWindow_txtPrompts)
                    Local $t_aAnswers[$iSize]
                    For $i = 0 To $iSize-1
                        Local $hText = $g_aPromptsWindow_txtPrompts[$i]
                        Local $sString = GUICtrlRead($hText)

                        $t_aAnswers[$i] = $sString
                    Next
                    $g_aPromptsWindow_Answers = $t_aAnswers

                    Local $t_iCode = [$PROMPTWINDOW_CLOSE, $g_hPromptsWindow_Parent]
                    GUI_HANDLE_MESSAGE($t_iCode)
                    
                    Local $t_iCode = [$GUI_EVENT_CLOSE, $g_hPromptsWindow]
                    GUI_HANDLE_MESSAGE($t_iCode)
                Case $g_idPromptsWindow_Help
                    If $g_hPromptsWindow_HelpWindow <> Null Then GUIDelete($g_hPromptsWindow_HelpWindow)
                    Local $aWinPos = WinGetPos($g_hPromptsWindow)
                    $g_hPromptsWindow_HelpWindow = CreateMessageBox("Schedule Add Help", $g_sPromptsWindow_Help, 300, 300, $aWinPos[0]+$aWinPos[2], $aWinPos[1]+(($aWinPos[3]-300)/2), $g_hPromptsWindow)
            EndSwitch
        Case $g_hMessageBox
            Switch $iCode[0]
                Case $GUI_EVENT_CLOSE
                    GUIDelete($g_hMessageBox)
            EndSwitch
        Case $g_hCompatibilityTest
            Switch $iCode[0]
                Case $GUI_EVENT_CLOSE, $g_idCompatibilityTest_btnClose
                    GUIDelete($g_hCompatibilityTest)
                    $g_hCompatibilityTest = Null
                Case $g_idCompatibilityTest_btnCopyImage
                    Local $hBitmap = _ScreenCapture_CaptureWnd("", $g_hCompatibilityTest, 0, 0, -1, -1, False)
                    Local $bResult = ClipPut_Bitmap($hBitmap)
                    If @error Then MsgBox($MB_ICONERROR+$MB_OK, "MSL-Bot Compatibility Test", "Could not copy to clipboard.", 10)
                    If $bResult Then MsgBox($MB_ICONINFORMATION+$MB_OK, "MSL-Bot Compatibility Test", "Image copied to clipboard.", 10)
                    _WinAPI_DeleteObject($hBitmap)
                Case $g_idCompatibilityTest_btnCopyText
                    Local $bResult = ClipPut(GUICtrlRead($g_idCompatibilityTest_editMain))
                    If $bResult = False Then MsgBox($MB_ICONERROR+$MB_OK, "MSL-Bot Compatibility Test", "Could not copy to clipboard.", 10)
                    If $bResult Then MsgBox($MB_ICONINFORMATION+$MB_OK, "MSL-Bot Compatibility Test", "Text copied to clipboard.", 10)
            EndSwitch
        Case $g_hDebugInput
            Switch $iCode[0]
                Case $GUI_EVENT_CLOSE
                    GUIDelete($g_hDebugInput)
                    $g_hDebugInput = Null
                Case $g_idDebugInput_btnRun
                    Local $sData = GUICtrlRead($g_idDebugInput_editMain)
                    Local $aExpressions = StringSplit($sData, @CRLF, $STR_NOCOUNT)

                    If UBound($g_aDebugInput_History) = 0 Then
                        _GUICtrlListView_AddItem($g_idDebugInput_listHistory, StringReplace($sData, @CRLF, "|"))
                        _ArrayAdd($g_aDebugInput_History, StringReplace($sData, @CRLF, "|"), 0, "", "", $ARRAYFILL_FORCE_SINGLEITEM)
                    Else
                        If StringReplace($sData, @CRLF, "|") <> $g_aDebugInput_History[0] Then
                            Local $iFind = -1
                            For $i = 1 To UBound($g_aDebugInput_History)-1
                                Local $sExpression = $g_aDebugInput_History[$i]
                                If StringReplace($sData, @CRLF, "|") == $sExpression Then
                                    $iFind = $i
                                    ExitLoop
                                EndIf  
                            Next

                            If $iFind <> -1 Then
                                _GUICtrlListView_DeleteItem($g_idDebugInput_listHistory, $iFind)
                                _ArrayDelete($g_aDebugInput_History, $iFind)
                            EndIf

                            _GUICtrlListView_InsertItem($g_idDebugInput_listHistory, StringReplace($sData, @CRLF, "|"), 0)
                            _ArrayInsert($g_aDebugInput_History, 0, StringReplace($sData, @CRLF, "|"), 0, "", "", $ARRAYFILL_FORCE_SINGLEITEM)
                        EndIf
                    EndIf

                    If $g_bRunning = False Then
                        Start()
                        _ProcessLines($aExpressions)
                        Stop()
                    Else
                        _ProcessLines($aExpressions)
                    EndIf
            EndSwitch
        Case $g_hGemWindow
            Switch $iCode[0]
                Case $GUI_EVENT_CLOSE
                    GUIDelete($g_hGemWindow)
                    $g_hGemWindow = Null
                Case $g_idGemWindow_btnGo ;Action button
                    Switch GUICtrlRead($g_idGemWindow_cmbAction)
                        Case "Create..."
                            Local $sInput = InputBox("Gem Window - Create", "Enter new filter name:", "New Filter")
                            If $sInput <> "" And @error = 0 Then
                                If FileExists($g_sFilterFolder & $sInput) = True Then
                                    MsgBox($MB_ICONWARNING+$MB_OK, "Gem Window - Create", "Filter already exists.")
                                    GUI_HANDLE_MESSAGE($iCode)
                                Else
                                    Local $hFile = FileOpen($g_sFilterFolder & $sInput, $FO_CREATEPATH+$FO_OVERWRITE)
                                    If $hFile <> -1 Then
                                        Local $iResult = FileWrite($hFile, StringFormat("grade:6\r\nshape:any\r\ntype:ruin,valor\r\nstat:any%\r\nsub1:critrate%\r\nsub2:any%\r\nsub3:any\r\nsub4:any"))
                                        If $iResult = 1 Then
                                            GUICtrlSetData($g_idGemWindow_cmbFilter, $sInput, $sInput)
                                            GUI_HANDLE_MESSAGE(CreateArr($g_idGemWindow_cmbFilter, $g_hGemWindow))
                                            MsgBox($MB_ICONINFORMATION+$MB_OK, "Gem Window - Create", "Created new filter: " & $sInput & ".")
                                        Else
                                            MsgBox($MB_ICONERROR+$MB_OK, "Gem Window - Create", "Could not create filter file.")
                                        EndIf
                                        FileClose($hFile)
                                    Else
                                        MsgBox($MB_ICONERROR+$MB_OK, "Gem Window - Create", "Could not create filter file.")
                                    EndIf
                                EndIf
                            EndIf
                        Case "Remove..."
                            Local $sCurrent = GUICtrlRead($g_idGemWindow_cmbFilter)
                            If FileExists($g_sFilterFolder & $sCurrent) = True And $sCurrent <> "" Then
                                Local $iResponse = MsgBox($MB_ICONWARNING+$MB_YESNO, "Gem Window - Remove", "Are you sure you want to delete: " & $sCurrent)
                                If $iResponse = $IDYES Then
                                    If FileDelete($g_sFilterFolder & $sCurrent) = 0 Then
                                        MsgBox($MB_ICONERROR, "Gem Window - Remove", "Could not remove filter.")
                                    Else
                                        _GUICtrlComboBox_DeleteString($g_idGemWindow_cmbFilter, _GUICtrlComboBox_GetCurSel($g_idGemWindow_cmbFilter))
                                        _GUICtrlComboBox_SetCurSel($g_idGemWindow_cmbFilter, -1)
                                        GUICtrlSetData($g_idGemWindow_editFilter, "")
                                    EndIf
                                EndIf
                            Else
                                MsgBox($MB_ICONWARNING+$MB_OK, "Gem Window - Remove", "A filter has not been selected.")
                            EndIf
                        Case "Save..."
                            Local $sCurrent = GUICtrlRead($g_idGemWindow_cmbFilter)
                            If FileExists($g_sFilterFolder & $sCurrent) = True And $sCurrent <> "" Then
                                If $sCurrent == "" Or FileExists($g_sFilterFolder & $sCurrent) = False Then
                                    MsgBox($MB_ICONERROR+$MB_OK, "Gem Window - Save", "Could not save filter.")
                                Else
                                    Local $sContent = GUICtrlRead($g_idGemWindow_editFilter)
                                    Local $bValid = _GemWindow_isValid($sContent)
                                    If $bValid = True Then
                                        Local $hFile = FileOpen($g_sFilterFolder & $sCurrent, $FO_CREATEPATH+$FO_OVERWRITE)
                                        If $hFile <> -1 Then
                                            Local $iResult = FileWrite($hFile, $sContent)
                                            If $iResult = 1 Then
                                                MsgBox($MB_ICONINFORMATION+$MB_OK, "Gem Window - Save", "Filter has been saved: " & $sCurrent)
                                            Else
                                                MsgBox($MB_ICONERROR+$MB_OK, "Gem Window - Save", "Could not write to file.")
                                            EndIf 
                                            FileClose($hFile)
                                        Else
                                            MsgBox($MB_ICONERROR+$MB_OK, "Gem Window - Save", "Could not safe filter.")
                                        EndIf
                                    Else
                                        Local $iError = @error
                                        Local $iExtended = @extended

                                        Local $sError = _GUICtrlEdit_GetLine($g_idGemWindow_editFilter, $iExtended-1)
                                        MsgBox($MB_ICONERROR+$MB_OK, "Gem Window - Save", $sError & @CRLF & @CRLF & "Error in line " & $iExtended & ": '" & $_GemWindow_isValid_ErrorString[$iError] & "'")
                                    EndIf
                                EndIf
                            Else
                                MsgBox($MB_ICONWARNING+$MB_OK, "Gem Window - Save", "A filter has not been selected.")
                            EndIf
                        Case "Help..."
                            Local $iFind = _MessageBox_FindTitle("Gem Window - Help")
                            If $iFind = -1 Then
                                Local $sHelp = FileRead($g_sLocalFolder & "gem_filter.txt")
                                If @error Then 
                                    MsgBox($MB_ICONERROR+$MB_OK, "Gem Window - Help", "Could not open help file.")
                                Else
                                    CreateMessageBox("Gem Window - Help", $sHelp, 400, 600, -1, -1, $iCode[1])
                                EndIf
                            Else
                                WinActivate($g_hMessageBox[$iFind])
                            EndIf
                        Case Else
                            MsgBox($MB_ICONERROR+$MB_OK, "Gem Window - Action", "Invalid action.")
                    EndSwitch
                Case $g_idGemWindow_cmbFilter ;Change current filter
                    Local $sContent = FileRead($g_sFilterFolder & GUICtrlRead($g_idGemWindow_cmbFilter))
                    If @error Then GUICtrlSetData($g_idGemWindow_editFilter, "Error: Could not load filter.")
                    If @error = 0 Then GUICtrlSetData($g_idGemWindow_editFilter, $sContent)
                Case $g_idGemWindow_tabMain
                    If GUICtrlRead($g_idGemWindow_tabMain) = 1 Then ;2nd Tab
                        _GemWindow_UpdateFound($g_iGemWindow_GemsFound)
                    EndIf
                Case $g_idGemWindow_btnNext
                    $g_iGemWindow_GemsFound += 1
                    If $g_iGemWindow_GemsFound >= UBound($g_aGemWindow_GemsFound) Then
                        $g_iGemWindow_GemsFound = 0
                    EndIf
                    _GemWindow_UpdateFound($g_iGemWindow_GemsFound)
                Case $g_idGemWindow_btnPrevious
                    $g_iGemWindow_GemsFound -= 1
                    If $g_iGemWindow_GemsFound < 0 Then
                        $g_iGemWindow_GemsFound = UBound($g_aGemWindow_GemsFound)-1
                    EndIf
                    _GemWindow_UpdateFound($g_iGemWindow_GemsFound)
            EndSwitch
        Case Else
            #Region MessageBox
                For $i = UBound($g_hMessageBox)-1 To 0 Step -1
                    Local $hMessageBox = $g_hMessageBox[$i]
                    If $iCode[1] = $hMessageBox Then
                        If $iCode[0] = $GUI_EVENT_CLOSE Then
                            GUIDelete($hMessageBox)
                            _ArrayDelete($g_hMessageBox, $i)
                        EndIf
                        Return True
                    EndIf
                Next
            #EndRegion

            #Region ListEditor
                If UBound($g_hListEditor) <> UBound($g_hListEditor_Controls) Then
                    MsgBox($MB_ICONERROR+$MB_OK, "ListEditor", "Something went wrong with the List Editor GUI.", 10)
                    Return SetError(1, 0, False)
                EndIf

                For $i = UBound($g_hListEditor)-1 To 0 Step -1
                    Local $hListEditor = $g_hListEditor[$i][0]
                    If $iCode[1] = $hListEditor Then
                        Local $idListEditor_listMain = $g_hListEditor_Controls[$i][0]
                        Local $idListEditor_cmbMain = $g_hListEditor_Controls[$i][5]

                        Switch $iCode[0]
                            Case $GUI_EVENT_CLOSE
                                Local $aItems[0]
                                Local $iSize = _GUICtrlListView_GetItemCount($idListEditor_listMain)
                                For $x = 0 To $iSize-1
                                   _ArrayAdd($aItems, _GUICtrlListView_GetItemText($idListEditor_listMain, $x))
                                Next
                                Call($g_hListEditor[$i][1], (UBound($aItems) > 0)?($aItems):(""))

                                GUIDelete($hListEditor)
                                _ArrayDelete($g_hListEditor, $i)
                                _ArrayDelete($g_hListEditor_Controls, $i)
                            Case $g_hListEditor_Controls[$i][1] ;Button Move Up
                                Local $aData = _GUICtrlListView_GetSelectedIndices($idListEditor_listMain, True)
                                If ($aData[0] > 0) Then
                                    If ($aData[1] > 0) Then
                                        Local $sTemp = _GUICtrlListView_GetItemText($idListEditor_listMain, $aData[1]-1)
                                        _GUICtrlListView_SetItemText($idListEditor_listMain, $aData[1]-1, _GUICtrlListView_GetItemText($idListEditor_listMain, $aData[1]))
                                        _GUICtrlListView_SetItemText($idListEditor_listMain, $aData[1], $sTemp)
                                        
                                        _GUICtrlListView_SetItemSelected($idListEditor_listMain, $aData[1]-1, True, True)
                                        _WinAPI_SetFocus(GUICtrlGetHandle($idListEditor_listMain))
                                    Else
                                        _GUICtrlListView_SetItemSelected($idListEditor_listMain, $aData[1], True, True)
                                        _WinAPI_SetFocus(GUICtrlGetHandle($idListEditor_listMain))
                                    EndIf
                                EndIf
                            Case $g_hListEditor_Controls[$i][2] ;Button Move Down
                                Local $aData = _GUICtrlListView_GetSelectedIndices($idListEditor_listMain, True)
                                If ($aData[0] > 0) Then
                                    If ($aData[1] < _GUICtrlListView_GetItemCount($idListEditor_listMain) - 1) Then
                                        Local $sTemp = _GUICtrlListView_GetItemText($idListEditor_listMain, $aData[1]+1)
                                        _GUICtrlListView_SetItemText($idListEditor_listMain, $aData[1]+1, _GUICtrlListView_GetItemText($idListEditor_listMain, $aData[1]))
                                        _GUICtrlListView_SetItemText($idListEditor_listMain, $aData[1], $sTemp)
                                        
                                        _GUICtrlListView_SetItemSelected($idListEditor_listMain, $aData[1]+1, True, True)
                                        _WinAPI_SetFocus(GUICtrlGetHandle($idListEditor_listMain))
                                    Else
                                        _GUICtrlListView_SetItemSelected($idListEditor_listMain, $aData[1], True, True)
                                        _WinAPI_SetFocus(GUICtrlGetHandle($idListEditor_listMain))
                                    EndIf
                                EndIf
                            Case $g_hListEditor_Controls[$i][3] ;Button Remove
                                Local $aData = _GUICtrlListView_GetSelectedIndices($idListEditor_listMain, True)
                                If ($aData[0] > 0) Then
                                    Local $sSelected = _GUICtrlListView_GetItemText($idListEditor_listMain, $aData[1])
                                    GUICtrlSetData($idListEditor_cmbMain, $sSelected, $sSelected)
                                    _GUICtrlListView_DeleteItemsSelected($idListEditor_listMain)
                                    _GUICtrlListView_SetItemSelected($idListEditor_listMain, $aData[1], True, True)
                                EndIf
                            Case $g_hListEditor_Controls[$i][4] ;Button Add
                                Local $sText = GUICtrlRead($idListEditor_cmbMain)
                                If ($sText <> "") Then
                                    _GUICtrlListView_AddItem($idListEditor_listMain, $sText)

                                    _GUICtrlComboBox_DeleteString($idListEditor_cmbMain, _GUICtrlComboBox_GetCurSel($idListEditor_cmbMain))
                                    _GUICtrlComboBox_SetCurSel($idListEditor_cmbMain, 0)
                                EndIf
                        EndSwitch

                        Return True
                    EndIf
                Next
            #EndRegion
    EndSwitch

    If $g_aComboMenu <> Null Then handleCombo($iCode[0], $g_hLV_ScriptConfig)
    Return True
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
                    Local $t_a[0]
                    $g_aCumulative = $t_a

                    Local $hFile = FileOpen(($g_sProfileFolder & "\" & $Config_Profile_Name & "\Cumulative"), 10)
                    FileWrite($hFile, "")
                    FileClose($hFile)

                    FileSetTime($g_sProfileFolder & "\" & $Config_Profile_Name & "\Cumulative", "", 1)

                    GUICtrlSetData($g_idLbl_Stat, "Cumulative stats (Last reset: " & formatDateTime() & ")")

                    Cumulative_Update($g_hLV_OverallStats)
                EndIf
            EndIf
        Case $g_hCmb_Scripts
            If ($nNotifyCode = $CBN_SELCHANGE) Then
                If ($g_hEditConfig <> Null) Then _endEdit()
                Script_ChangeConfig()
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

                    If ($sText == "") Then
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
                            CreateMenu($g_aComboMenu, $t_aItems)

                            ;Displays a context menu to choose an item from.
                            ShowMenu($g_hParent, $g_aComboMenu[0][0])
                        Case "text"
                            ;Shows edit in the position.
                            createEdit($g_hEditConfig, $g_iEditConfig, $g_hLV_ScriptConfig)
                        Case "list"
                            Local $aCurrent = StringSplit(_GUICtrlListView_GetItemText($g_hLV_ScriptConfig, $iIndex, 1), ",", $STR_NOCOUNT)
                            Local $aDefault = StringSplit(_GUICtrlListView_GetItemText($g_hLV_ScriptConfig, $iIndex, 4), ",", $STR_NOCOUNT)
                            
                            $g_iListEditor_Index = $iIndex
                            GUISetState(@SW_DISABLE, $g_hParent)
                            ListEditor_CreateGui($aCurrent, $aDefault, "_ListEditor_Config_Close")
                        Case "listfunction"
                            Local $aCurrent = StringSplit(_GUICtrlListView_GetItemText($g_hLV_ScriptConfig, $iIndex, 1), ",", $STR_NOCOUNT)
                            Local $sFunction = _GUICtrlListView_GetItemText($g_hLV_ScriptConfig, $iIndex, 4)
                            Local $aDefault = Call($sFunction)
                            If @error = 0xDEAD And @extended = 0xBEEF Then 
                                MsgBox($MB_ICONERROR+$MB_OK, "MSL Bot Config Error", "Function not found: " & $sFunction)
                            Else
                                $g_iListEditor_Index = $iIndex
                                GUISetState(@SW_DISABLE, $g_hParent)
                                ListEditor_CreateGui($aCurrent, $aDefault, "_ListEditor_Config_Close")
                            EndIf
                        Case "setting"
                            Local $sText = _GUICtrlListView_GetItemText($g_hLV_ScriptConfig, $iIndex, 1)
                            Local $iScriptIndex = _GUICtrlComboBox_FindString($g_hCmb_Scripts, $sText)
                            If ($iScriptIndex <> -1) Then 
                                _GUICtrlComboBox_SetCurSel($g_hCmb_Scripts, $iScriptIndex)
                                Script_ChangeConfig()
                            EndIf
                    EndSwitch
            EndSwitch
        Case $g_hLV_Log
            Switch $iCode
                Case $NM_RCLICK
                    Local $item = _GUICtrlListView_SubItemHitTest($g_hLV_Log)
                    If ($item[0] <> -1) Then ClipPut(_GUICtrlListView_GetItemText($g_hLV_Log,$item[0],1))
            EndSwitch
        Case $g_hDebugInput_listHistory
            Switch $iCode
                Case $NM_DBLCLK
                    Local $item = _GUICtrlListView_SubItemHitTest($g_hDebugInput_listHistory)
                    If ($item[0] <> -1) Then GUICtrlSetData($g_idDebugInput_editMain, StringReplace(_GUICtrlListView_GetItemText($g_hDebugInput_listHistory,$item[0], 0), "|", @CRLF))
            EndSwitch
    EndSwitch
    Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_NOTIFY

;Some helper functions for handling controls----

Func CreateLogWindow()
    Local $aPos = WinGetPos($g_sAppTitle)

    $g_hLogWindow = GUICreate($g_sAppTitle & " Log Window", $aPos[2]-15, $aPos[3]-15, $aPos[0]+$aPos[2]-15, $aPos[1], $WS_SIZEBOX+$WS_MAXIMIZEBOX+$WS_MINIMIZEBOX, -1)
    GUISetState(@SW_SHOW, $g_hLogWindow)

    $g_idCkb_Information = GUICtrlCreateCheckbox("Info", 10, 4, 60, 23)
    GUICtrlSetState(-1, $GUI_CHECKED)
    $g_idCkb_Error = GUICtrlCreateCheckbox("Error", 70, 4, 60, 23)
    GUICtrlSetState(-1, $GUI_CHECKED)
    $g_idCkb_Process = GUICtrlCreateCheckbox("Process", 130, 4, 60, 23)
    GUICtrlSetState(-1, $GUI_CHECKED)
    $g_idCkb_Debug = GUICtrlCreateCheckbox("Debug", 200, 4, 60, 23)
    GUICtrlSetState(-1, $GUI_UNCHECKED)

    ;REMOVE COMMENT FOR DEBUG
    ;$g_idLV_FunctionLevels = GUICtrlCreateListView("", $aPos[2]-129, 30, 110, $aPos[3]-73, $LVS_REPORT+$LVS_NOSORTHEADER)
    ;$g_hLV_FunctionLevels = GUICtrlGetHandle($g_idLV_FunctionLevels)
    ;_GUICtrlListView_AddColumn($g_hLV_FunctionLevels, "#", 20, 0)
    ;_GUICtrlListView_AddColumn($g_hLV_FunctionLevels, "Functions", 150, 0)

    $g_idLV_Log = GUICtrlCreateListView("", 3, 30, $aPos[2]-23, $aPos[3]-73, $LVS_REPORT+$LVS_NOSORTHEADER) ;-133 WIDTH FOR DEBUG -23 WIDTH FOR NONDEBUG
    $g_hLV_Log = GUICtrlGetHandle($g_idLV_Log)
    _GUICtrlListView_SetExtendedListViewStyle($g_hLV_Log, $LVS_EX_FULLROWSELECT+$LVS_EX_GRIDLINES)
    _GUICtrlListView_AddColumn($g_hLV_Log, "Time", 76, 0)
    _GUICtrlListView_AddColumn($g_hLV_Log, "Text", 312, 0)
    _GUICtrlListView_AddColumn($g_hLV_Log, "Type", 100, 0)
    _GUICtrlListView_AddColumn($g_hLV_Log, "Function", 100, 0)
    _GUICtrlListView_AddColumn($g_hLV_Log, "Location", 100, 0)
    _GUICtrlListView_AddColumn($g_hLV_Log, "Level", 100, 0)
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

Func CreateScheduleAdd()
    $g_hScheduleAdd = GUICreate("Add Schedule", 335, 50)
    $g_idScheduleAdd_Date = GUICtrlCreateButton("Date", 5, 5, 50, 40)
    $g_idScheduleAdd_Day = GUICtrlCreateButton("Day", 60, 5, 50, 40)
    $g_idScheduleAdd_Timer = GUICtrlCreateButton("Timer", 115, 5, 50, 40)
    $g_idScheduleAdd_Condition = GUICtrlCreateButton("Condition", 170, 5, 50, 40)
    $g_idScheduleAdd_Preset = GUICtrlCreateButton("Preset...", 225, 5, 50, 40)
    $g_idScheduleAdd_Cancel = GUICtrlCreateButton("Cancel", 280, 5, 50, 40)

    GUISetState(@SW_SHOW, $g_hScheduleAdd)
EndFunc

;Generates window for prompts.
;aPrompts and aPreset must have the same number of elements
;To prompt a multiline: Add $ as the first character in the prompt
;To prompt a combobox: Add ! as the first character in the prompt. Preset must be separated by "|"
;Answers are put into $g_aPromptsWindow_Answers
Func GeneratePromptsWindow(ByRef $hParent, $sTitle, $aPrompts, $aPreset, $sHelp = "", $bHide = True)
    If $bHide > 0 Then GUISetState(@SW_HIDE, $hParent)
    $g_hPromptsWindow_Parent = $hParent

    Local $iSize = UBound($aPrompts)
    If $aPreset <> Null Then
        If UBound($aPreset) <> $iSize Then Return -1
    EndIf

    Local $iWindowSize = 0
    For $i = 0 To $iSize-1
        If StringLeft($aPrompts[$i], 1) == "$" Then
            $iWindowSize += 2
        Else
            $iWindowSize += 1
        EndIf
    Next

    $g_hPromptsWindow = GUICreate($sTitle, 300, 33+$iWindowSize*33)

    Local $t_aPrompts[$iSize]
    Local $iOffset = 0
    For $i = 0 To $iSize-1
        Local $sType = StringLeft($aPrompts[$i], 1)

        Local $sLabel = $aPrompts[$i]
        Switch $sType
            Case "!", "$"
                $sLabel = StringMid($aPrompts[$i], 2)
        EndSwitch

        Local $hLabel = GUICtrlGetHandle(GUICtrlCreateLabel($sLabel & ":", 5, 33*($i)+8+$iOffset))

        Switch $sType
            Case "!" ;Combobox
                Local $sPreset = ""
                If $aPreset <> Null Then $sPreset = StringSplit($aPreset[$i], "|", $STR_NOCOUNT)

                $t_aPrompts[$i] = GUICtrlCreateCombo("", ControlGetPos($hLabel, "", "")[2], 33*($i)+5+$iOffset, 295-ControlGetPos($hLabel, "", "")[2], 23, $CBS_DROPDOWNLIST)
                GUICtrlSetData($t_aPrompts[$i], _ArrayToString($sPreset), $sPreset[0])
            Case Else ;Edit
                Local $iFlags = 0
                Local $iMultiline = 0
                If StringLeft($aPrompts[$i], 1) == "$" Then
                    $iFlags = $ES_MULTILINE+$WS_VSCROLL+$ES_WANTRETURN+$ES_AUTOVSCROLL
                    $iMultiline = 33
                EndIf

                Local $sPreset = ""
                If $aPreset <> Null Then $sPreset = $aPreset[$i]
                $t_aPrompts[$i] = GUICtrlCreateEdit($sPreset, ControlGetPos($hLabel, "", "")[2], 33*($i)+5+$iOffset, 295-ControlGetPos($hLabel, "", "")[2], 23+$iMultiline, $iFlags)

                $iOffset += $iMultiline
        EndSwitch
    Next

    $g_idPromptsWindow_Done = GUICtrlCreateButton("Done", 210, 33*($iSize)+2+$iOffset, 40, 23)
    $g_idPromptsWindow_Cancel = GUICtrlCreateButton("Cancel", 255, 33*($iSize)+2+$iOffset, 40, 23)

    If $sHelp <> "" Then
        $g_sPromptsWindow_Help = $sHelp
        $g_idPromptsWindow_Help = GUICtrlCreateButton("Help", 5, 33*($iSize)+2+$iOffset, 40, 23)
    EndIf

    $g_aPromptsWindow_txtPrompts = $t_aPrompts
    GUISetState(@SW_SHOW, $g_hPromptsWindow)
EndFunc

;Returns message handle
Global $g_hMessageBox[0]
Func CreateMessageBox($sTitle, $sMessage, $iWidth = 300, $iHeight = 300, $iX = -1, $iY = -1, $hParent = 0)
    If $hParent <> 0 Then
        Local $aWinPos = WinGetPos($hParent)
        If isArray($aWinPos) = True Then
            If $iX = -1 Then $iX = $aWinPos[0] + $aWinPos[2]
            If $iY = -1 Then $iY = $aWinPos[1] + Int(($aWinPos[3] - $iHeight) / 2)
        EndIf
    EndIf

    Local $hMessageBox = GUICreate($sTitle, $iWidth, $iHeight, $iX, $iY, $WS_SIZEBOX+$WS_MINIMIZEBOX+$WS_MAXIMIZEBOX, -1, $hParent)
    GUISetFont(8.5, 0, 0, "Lucida Console", $hMessageBox)
    Global $g_idEditMessage = GUICtrlCreateEdit($sMessage, 0, 0, $iWidth, $iHeight-25, $ES_READONLY+$WS_VSCROLL)

    GUICtrlSetResizing($g_idEditMessage, $GUI_DOCKBORDERS)
    GUISetState(@SW_SHOW, $hMessageBox)
    _GUICtrlEdit_SetSel($g_idEditMessage, 0, 0)

    _ArrayAdd($g_hMessageBox, $hMessageBox)
    Return $hMessageBox
EndFunc

Func _MessageBox_FindTitle($sTitle)
    For $i = 0 To UBound($g_hMessageBox)-1
        If WinGetTitle($g_hMessageBox[$i]) == $sTitle Then
            Return $i
        EndIf
    Next
    Return -1
EndFunc

;Handles the combo config contextmenu
Func handleCombo($iCode, $hListView)
    Local $iIndex = _ArraySearch($g_aComboMenu, $iCode, 1, 0, 0, 0, 1, 0)
    If $iIndex <> -1 Then
        _GUICtrlListView_SetItemText($hListView, _GUICTrlListView_GetSelectedIndices($hListView, True)[1], $g_aComboMenu[$iIndex][1], 1)
        Config_Save()

        $g_aComboMenu = Null
    EndIf
EndFunc

;For context menu for type combo configs
Func CreateMenu(ByRef $aMenu, $aItems)
    Local $Dummy_Menu = GUICtrlCreateDummy()
    Local $Context[UBound($aItems)+1][2]

    ;Creates an array: [idContextMenu, [idContext, "name"], [idContext, "name"]...]
    $Context[0][0] = GUICtrlCreateContextMenu($Dummy_Menu)
    For $i = 1 To UBound($Context)-1
        $Context[$i][0] = GUICtrlCreateMenuItem($aItems[$i-1], $Context[0][0])
        $Context[$i][1] = $aItems[$i-1]
    Next

    $aMenu = $Context
EndFunc

;Takes text from edit and sets subitem (in Value column) from listview
Func handleEdit(ByRef $hEdit, ByRef $iIndex, $hListView)
    ;Handles changes to the config setting.
    Local $sNew = _GUICtrlEdit_GetText($hEdit)
    If ($sNew <> "") Then _GUICtrlListView_SetItemText($hListView, $iIndex, $sNew, 1)
    _GUICtrlEdit_Destroy($hEdit)

    If _GUICtrlListView_GetItemText($hListView, $iIndex) == "Profile Name" Then
        Script_ChangeProfile($sNew)
    Else
        Config_Save()
    EndIf

    Config_Update()
    $hEdit = Null
    $iIndex = Null
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

;Other Helper Functions ===============================================

; Check if data is valid for use.
Global Const $_GemWindow_isValid_ErrorString = _
    ["No error.", _ 
     "Invalid format.", _ 
     "Duplicate data type.", _ 
     "Empty value.", _
     "Other values being used when 'any' is used in 'grade'.", _ 
     "Other values being used when 'any' is used in 'shape'.", _ 
     "Other values being used when 'any' is used in 'type'.", _ 
     "Invalid data type.", _ 
     "Invalid value.", _ 
     "Duplicate values."]
Func _GemWindow_isValid($sFilter)
    Local $aData = StringSplit($sFilter, @CRLF, $STR_NOCOUNT)
    If isArray($aData) = False Then $aData = CreateArr($aData)

    ;Remove empty entries
    For $i = UBound($aData)-1 To 0 Step -1
        If $aData[$i] == "" Then _ArrayDelete($aData, $i)
    Next

    For $i = 0 To UBound($aData)-1
        Local $sData = $aData[$i]
        $sData = StringStripWS($sData, $STR_STRIPALL)
        $sData = StringLower($sData)

        ;Check data types
        Local $aType = StringSplit($sData, ":", $STR_NOCOUNT)
        If isArray($aType) = False Or UBound($aType) <> 2 Then Return SetError(1, $i+1, False) ;Not valid type

        Local $aDuplicate = _ArrayFindAll($aData, $sData)
        If isArray($aDuplicate) = True And UBound($aDuplicate) <> 1 Then Return SetError(2, $i+1, False) ;Duplicates types

        ;Check values
        If $aType[1] == "" Then Return SetError(3, 0, False) ;Empty value

        Local $aValues = StringSplit($aType[1], ",", $STR_NOCOUNT)
        If isArray($aValues) = False Then $aValues = CreateArr($aType[1])
            
        For $sValue In $aValues
            Local $aFind = Null
            Switch $aType[0]
                Case "grade"
                    If $sValue = "any" And UBound($aValues) > 1 Then Return SetError(4, $i+1, False) ;Used any already
                    $aFind = _ArrayFindAll($g_aGem_Grade, $sValue)
                Case "shape"
                    If $sValue = "any" And UBound($aValues) > 1 Then Return SetError(5, $i+1, False) ;Used any already
                    $aFind = _ArrayFindAll($g_aGem_Shape, $sValue)
                Case "type"
                    If $sValue = "any" And UBound($aValues) > 1 Then Return SetError(6, $i+1, False) ;Used any already
                    $aFind = _ArrayFindAll($g_aGem_Type, $sValue)
                Case "stat", "sub1", "sub2", "sub3", "sub4"
                    If StringRight($sValue, 1) == "%" Or StringRight($sValue, 1) == "+" Then
                        $sValue = StringMid($sValue, 1, StringLen($sValue) - 1)
    EndIf
                    $aFind = _ArrayFindAll($g_aGem_Stat, $sValue)
                Case Else
                    Return SetError(7, $i+1, False)
            EndSwitch

            If isArray($aFind) = False Then Return SetError(8, $i+1, False) ;Not valid value

            $aDuplicate = _ArrayFindAll($aValues, $sValue)
            If isArray($aDuplicate) = True And UBound($aDuplicate) <> 1 Then Return SetError(9, $i+1, False) ;Duplicates values
        Next
    Next
            
    Return True
EndFunc

;Config List Editor
Global $g_iListEditor_Index = -1
Func _ListEditor_Config_Close($aData = "")
    If $g_iListEditor_Index = -1 Then 
        MsgBox($MB_ICONERROR+$MB_OK, "ListEditor Config", "Could not save config.")
        Return SetError(1, 0, False)
    EndIf

    Local $sData = ""
    If isArray($aData) = True And UBound($aData) > 0 Then $sData = _ArrayToString($aData, ",")
    _GUICtrlListView_SetItemText($g_hLV_ScriptConfig, $g_iListEditor_Index, $sData, 1)
    GUISetState(@SW_ENABLE, $g_hParent)

    _GUICtrlListView_SetItemSelected($g_hLV_ScriptConfig, $g_iListEditor_Index, True, True)
    _WinAPI_SetFocus($g_hLV_ScriptConfig)

    Config_Save()
    Return True
EndFunc

;Return list for current available filters
Func _Gem_Filter()
    Local $aFilters = _FileListToArray($g_sFilterFolder)
    If isArray($aFilters) = False Then Return SetError(1, 0, False)
    _ArrayDelete($aFilters, 0) ; Remove count
    _ArrayAdd($aFilters, "_Filter")
    If isArray($aFilters) = False Then $aFilters = CreateArr()
    Return $aFilters
EndFunc

Func _GemWindow_AddFound($aGemData, $sStatus)
    Local $aGem = parseGem($aGemData)
    If @error Then Return SetError(1, @error, False)

    _ArrayInsert($aGem, 0, $sStatus)
    _ArrayAdd($g_aGemWindow_GemsFound, $aGem, 0, "|", @CRLF, $ARRAYFILL_FORCE_SINGLEITEM)

    If $g_hGemWindow <> Null And GUICtrlRead($g_idGemWindow_tabMain) = 1 Then
        _GemWindow_UpdateFound($g_iGemWindow_GemsFound)
    EndIf
EndFunc

Func _GemWindow_UpdateFound($iIndex)
    If isDeclared("g_idGemWindow_editGem") = False Then Return SetError(1, 0, False)

    Local $iSize = UBound($g_aGemWindow_GemsFound)
    If $iIndex < 0 Or $iIndex >= $iSize Then Return SetError(2, 0, False)

    Local $aTexts[9] = ["Status", "Grade", "Shape", "Type", "Stat", "Sub1", "Sub2", "Sub3", "Sub4"]
    Local $aGem = $g_aGemWindow_GemsFound[$iIndex]

    Local $sFinal = "Gem #: " & $iIndex+1 & "/" & $iSize
    For $i = 0 To UBound($aGem)-1
        $sFinal &= @CRLF & $aTexts[$i] & ": " & (($aGem[$i] <> "")?($aGem[$i]):("N/A"))
    Next

    GUICtrlSetData($g_idGemWindow_editGem, $sFinal)
    Return True
EndFunc