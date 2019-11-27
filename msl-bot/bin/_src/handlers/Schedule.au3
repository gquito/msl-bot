#include-once

Func Schedule_Handle()
    If TimerDiff($g_hScheduleCooldown) < 250 Or $g_bScheduleHandleBusy = True Then Return
    $g_hScheduleCooldown = TimerInit()

    $g_bScheduleHandleBusy = True
    For $i = $g_iSchedulesSize-1 To 0 Step -1
        If GUICtrlRead($g_idCheck_Enable) <> $GUI_CHECKED And StringLeft($g_aSchedules[$i][$SCHEDULE_NAME], 1) <> "_" Then ContinueLoop

        If $g_aSchedules[$i][$SCHEDULE_ENABLED] = True Then
            If TimerDiff($g_aSchedules[$i][$SCHEDULE_COOLDOWNHANDLE]) > $g_aSchedules[$i][$SCHEDULE_COOLDOWN]*1000 Then
                If $g_aSchedules[$i][$SCHEDULE_ITERATIONS] > 0 Or String($g_aSchedules[$i][$SCHEDULE_ITERATIONS]) = "*" Then
                    Switch $g_aSchedules[$i][$SCHEDULE_TYPE]
                        Case $SCHEDULE_TYPE_DATE
                            Schedule_HandleDate($i)
                        Case $SCHEDULE_TYPE_DAY
                            Schedule_HandleDay($i)
                        Case $SCHEDULE_TYPE_TIMER
                            Schedule_HandleTimer($i)
                        Case $SCHEDULE_TYPE_CONDITION
                            Schedule_HandleCondition($i)
                    EndSwitch
                EndIf
            EndIf
        EndIf
    Next
    If $g_bScheduleBusy = False Then Schedule_HandleQueue()
    $g_bScheduleHandleBusy = False
EndFunc

Func Schedule_HandleQueue()
    If $g_bScheduleBusy = True Then Return

    For $i = $g_iSchedulesQueueSize-1 To 0 Step -1
        If $g_bScheduleBusy = True Then ExitLoop
        Local $iFlag = $g_aSchedulesQueue[$i][$SCHEDULE_QUEUE_FLAG]

        If BitAND($iFlag, $SCHEDULE_FLAG_RunImmediately) And $g_bRunning = False Then
            Schedule_PerformAction($i)
        Else
            If isLocation("battle-end,village,map") Then 
                Schedule_PerformAction($i)
            EndIf
        EndIf
    Next
EndFunc

Func Schedule_AddQueue(ByRef $iScheduleIndex)
    Local $aQueueData = _ 
          [$g_aSchedules[$iScheduleIndex][$SCHEDULE_ACTION], _
           $g_aSchedules[$iScheduleIndex][$SCHEDULE_FLAG]]

    _ArrayAdd($g_aSchedulesQueue, "")
    $g_aSchedulesQueue[$g_iSchedulesQueueSize][0] = $aQueueData[0]
    $g_aSchedulesQueue[$g_iSchedulesQueueSize][1] = $aQueueData[1]

    $g_iSchedulesQueueSize += 1
EndFunc

Func Schedule_RemoveQueue($iQueueIndex)
    If UBound($g_aSchedulesQueue) < $iQueueIndex Then Return False

    _ArrayDelete($g_aSchedulesQueue, $iQueueIndex)
    $g_iSchedulesQueueSize -= 1
    
    Return True
EndFunc

Func Schedule_PerformAction(ByRef $iQueueIndex)
    Log_Level_Add("SCHEDULE")
    $g_bScheduleBusy = True
    Local $aAction = $g_aSchedulesQueue[$iQueueIndex][$SCHEDULE_QUEUE_ACTION]
    Local $iFlag = $g_aSchedulesQueue[$iQueueIndex][$SCHEDULE_QUEUE_FLAG]
    Schedule_RemoveQueue($iQueueIndex)

    Local $hCooldown = TimerInit()
    If BitAND($iFlag, $SCHEDULE_FLAG_RestartBeforeAction) Then RestartGame()
    
    _ProcessLines($aAction, False, False)
    If TimerDiff($hCooldown) < 1000 Then _Sleep(1000-TimerDiff($hCooldown))

    $g_bScheduleBusy = False
    Log_Level_Remove()
EndFunc

Func Schedule_HandleDate(ByRef $iIndex)
    Local $aDateStructure = $g_aSchedules[$iIndex][$SCHEDULE_STRUCTURE]

    Local $aRaw = StringSplit(_NowCalc(), " ", $STR_NOCOUNT)

    Local $aCurrentTime = StringSplit($aRaw[1], ":", $STR_NOCOUNT)
    Local $aCurrentDay = StringSplit($aRaw[0], "/", $STR_NOCOUNT)
    Local $aDateTime = $aDateStructure[$SCHEDULE_DATE_TIME]

    If  (Int($aDateTime[0]) = Int($aCurrentDay[1]) OR $aDateTime[0] = "*") And _
        (Int($aDateTime[1]) = Int($aCurrentDay[2]) OR $aDateTime[1] = "*") And _
        (Int($aDateTime[2]) = Int($aCurrentTime[0]) OR $aDateTime[2] = "*") And _
        (Int($aDateTime[3]) = Int($aCurrentTime[1]) OR $aDateTime[3] = "*") And _
        (Int($aDateTime[4]) = Int($aCurrentTime[2]) OR $aDateTime[4] = "*") Then

        Schedule_AddQueue($iIndex)
        _Schedule_HandleIteration($iIndex)
    EndIf
EndFunc

Func Schedule_HandleDay(ByRef $iIndex)
    Local $aDayStructure = $g_aSchedules[$iIndex][$SCHEDULE_STRUCTURE]

    Local $aCurrentTime = StringSplit(_NowTime(5), ":", $STR_NOCOUNT)
    Local $aCurrentDay = @WDAY

    Local $aTime = $aDayStructure[$SCHEDULE_DAY_TIME]
    Local $aDay = $aDayStructure[$SCHEDULE_DAY_DAYOFTHEWEEK]

    If  $aDay = $aCurrentDay And _
        ($aCurrentTime[0] = $aTime[0] Or $aTime[0] = "*") And _
        ($aCurrentTime[1] = $aTime[1] Or $aTime[1] = "*") And _
        ($aCurrentTime[2] = $aTime[2] Or $aTime[2] = "*") Then

        Schedule_AddQueue($iIndex)
        _Schedule_HandleIteration($iIndex)
    EndIf
EndFunc

Func Schedule_HandleTimer(ByRef $iIndex)
    Local $aTimerStructure = $g_aSchedules[$iIndex][$SCHEDULE_STRUCTURE]

    Local $iSeconds = Int($aTimerStructure[$SCHEDULE_TIMER_INTERVAL])
    Local $iTimeDifference = Int(TimerDiff($aTimerStructure[$SCHEDULE_TIMER_TIMEHANDLE])/1000)
    Local $iItem = Schedule_LVIndexByName($g_aSchedules[$iIndex][$SCHEDULE_NAME])
    If $iItem <> -1 Then _GUICtrlListView_SetItemText($g_hLV_Schedule, $iItem, "[Time Left: " & getTimeString($iSeconds - $iTimeDifference) & "]", 4)
    
    If $iSeconds - $iTimeDifference <= 0 Then
        $aTimerStructure[$SCHEDULE_TIMER_TIMEHANDLE] = TimerInit()
        $g_aSchedules[$iIndex][$SCHEDULE_STRUCTURE] = $aTimerStructure

        Schedule_AddQueue($iIndex)
        _Schedule_HandleIteration($iIndex)
    EndIf
EndFunc

Func Schedule_HandleCondition(ByRef $iIndex)
    Local $aConditionStructure = $g_aSchedules[$iIndex][$SCHEDULE_STRUCTURE]

    Local $aOr = $aConditionStructure[$SCHEDULE_CONDITION_ARRAY]
    Local $bResult_Or = False
    For $i = 0 To UBound($aOr)-1
        If isArray($aOr[$i]) Then
            Local $aAnd = $aOr[$i]
            Local $bResult_And = True
            For $x = 0 To UBound($aAnd)-1
                Local $result = Execute($aAnd[$x])
                If $result = False Or $result = 0 Then
                    $bResult_And = False
                    ExitLoop
                EndIf
            Next
            If $bResult_And = True Then $bResult_Or = True
        Else
            Local $result = Execute($aOr[$i])
            If $result = True Or $result = 1 Then $bResult_Or = True
        EndIf
        If $bResult_Or = True Then ExitLoop
    Next

    If $bResult_Or = True Then
        Schedule_AddQueue($iIndex)
        _Schedule_HandleIteration($iIndex)
    EndIf
EndFunc
;========

Func _Schedule_HandleIteration(ByRef $iIndex)
    $g_aSchedules[$iIndex][$SCHEDULE_COOLDOWNHANDLE] = TimerInit()

    If String($g_aSchedules[$iIndex][$SCHEDULE_ITERATIONS]) <> "*" Then
        $g_aSchedules[$iIndex][$SCHEDULE_ITERATIONS] -= 1
        
        Local $iItem = Schedule_LVIndexByName($g_aSchedules[$iIndex][$SCHEDULE_NAME])
        If $iItem <> -1 Then  _GUICtrlListView_SetItemText($g_hLV_Schedule, $iItem, $g_aSchedules[$iIndex][$SCHEDULE_ITERATIONS], 3)
       
        If $g_aSchedules[$iIndex][$SCHEDULE_ITERATIONS] = 0 And Not(BitAND($g_aSchedules[$iIndex][$SCHEDULE_FLAG], $SCHEDULE_FLAG_DoNotDelete)) Then
            Schedule_Remove($iIndex)
        EndIf
    EndIf
EndFunc

Func Schedule_Add($sName, $aAction, $iType, $iIteration, $aStructure, $iFlag = $SCHEDULE_FLAG_RunSafe, $iCooldown = 0, $bEnabled = True, $bDisplay = True)
    Local $iIndex = UBound($g_aSchedules)
    _ArrayAdd($g_aSchedules, "")
    For $i = UBound($aAction)-1 To 0 Step -1
        If $aAction[$i] = "" Then _ArrayDelete($aAction, $i)
    Next
    $g_aSchedules[$iIndex][$SCHEDULE_NAME] = $sName
    $g_aSchedules[$iIndex][$SCHEDULE_ACTION] = $aAction
    $g_aSchedules[$iIndex][$SCHEDULE_TYPE] = $iType
    $g_aSchedules[$iIndex][$SCHEDULE_ITERATIONS] = $iIteration
    $g_aSchedules[$iIndex][$SCHEDULE_STRUCTURE] = $aStructure
    $g_aSchedules[$iIndex][$SCHEDULE_FLAG] = $iFlag
    $g_aSchedules[$iIndex][$SCHEDULE_COOLDOWN] = Int($iCooldown)
    $g_aSchedules[$iIndex][$SCHEDULE_COOLDOWNHANDLE] = TimerInit()
    $g_aSchedules[$iIndex][$SCHEDULE_ENABLED] = $bEnabled
    $g_iSchedulesSize += 1

    If $bDisplay = True Then
        $iIndex = _GUICtrlListView_AddItem($g_hLV_Schedule, "[" & ($bEnabled = "True" ? "ON" : "OFF") & "] " & $sName)
        _GUICtrlListView_AddSubItem($g_hLV_Schedule, $iIndex, _ArrayToString($aAction), 1)
        Local $sType = _Schedule_GetTypeString($iType)
        _GUICtrlListView_AddSubItem($g_hLV_Schedule, $iIndex, $sType, 2)
        _GUICtrlListView_AddSubItem($g_hLV_Schedule, $iIndex, $iIteration, 3)
        Local $sStructure = _Schedule_GetStructureString($aStructure, $iType)
        _GUICtrlListView_AddSubItem($g_hLV_Schedule, $iIndex, $sStructure, 4)
    EndIf
EndFunc

Func Schedule_Edit(ByRef $iIndex, $sName, $aAction, $iType, $iIteration, $aStructure, $iFlag, $iCooldown, $bEnabled)
    Local $sOldName = $g_aSchedules[$iIndex][$SCHEDULE_NAME]

    $g_aSchedules[$iIndex][0] = $sName
    For $i = UBound($aAction)-1 To 0 Step -1
        If $aAction[$i] = "" Then _ArrayDelete($aAction, $i)
    Next
    $g_aSchedules[$iIndex][$SCHEDULE_ACTION] = $aAction
    $g_aSchedules[$iIndex][$SCHEDULE_TYPE] = $iType
    $g_aSchedules[$iIndex][$SCHEDULE_ITERATIONS] = $iIteration
    $g_aSchedules[$iIndex][$SCHEDULE_STRUCTURE] = $aStructure
    $g_aSchedules[$iIndex][$SCHEDULE_FLAG] = $iFlag
    $g_aSchedules[$iIndex][$SCHEDULE_COOLDOWN] = Int($iCooldown)
    $g_aSchedules[$iIndex][$SCHEDULE_COOLDOWNHANDLE] = TimerInit()
    $g_aSchedules[$iIndex][$SCHEDULE_ENABLED] = $bEnabled

    $iIndex = Schedule_LVIndexByName($sOldName)
    If $iIndex <> -1 Then
        _GUICtrlListView_SetItemText($g_hLV_Schedule, $iIndex, "[" & ($bEnabled = "True" ? "ON" : "OFF") & "] " & $sName)
        _GUICtrlListView_SetItemText($g_hLV_Schedule, $iIndex, _ArrayToString($aAction), 1)
        Local $sType = _Schedule_GetTypeString($iType)
        _GUICtrlListView_SetItemText($g_hLV_Schedule, $iIndex, $sType, 2)
        _GUICtrlListView_SetItemText($g_hLV_Schedule, $iIndex, $iIteration, 3)
        Local $sStructure = _Schedule_GetStructureString($aStructure, $iType)
        _GUICtrlListView_SetItemText($g_hLV_Schedule, $iIndex, $sStructure, 4)
    EndIf
EndFunc

Func Schedule_Remove(ByRef $iIndex)
    Local $iItem = Schedule_LVIndexByName($g_aSchedules[$iIndex][$SCHEDULE_NAME])
    _GUICtrlListView_DeleteItem($g_hLV_Schedule, $iItem)
    _ArrayDelete($g_aSchedules, $iIndex)
    $g_iSchedulesSize -= 1
EndFunc

Func Schedule_RemoveByName($sString)
    For $i = 0 To $g_iSchedulesSize-1
        If $g_aSchedules[$i][0] = $sString Then
            Schedule_Remove($i)
            Return True
        EndIf
    Next

    Return False
EndFunc

Func Schedule_IndexByName($sString)
    For $i = 0 To $g_iSchedulesSize-1
        If $g_aSchedules[$i][0] = $sString Then
            Return $i
        EndIf
    Next

    Return -1
EndFunc

Func Schedule_LVIndexByName($sString)
    For $i = 0 To _GUICtrlListView_GetItemCount($g_hLV_Schedule)-1
        Local $sName = StringReplace(StringReplace(_GUICtrlListView_GetItemText($g_hLV_Schedule, $i), "[ON] ", ""), "[OFF] ", "")
        If $sName = $sString Then
            Return $i
        EndIf
    Next

    Return -1
EndFunc

Func Schedule_Enable($sString)
    For $i = 0 To $g_iSchedulesSize-1
        If $g_aSchedules[$i][$SCHEDULE_NAME] = $sString Then
            $g_aSchedules[$i][$SCHEDULE_COOLDOWNHANDLE] = TimerInit()
            $g_aSchedules[$i][$SCHEDULE_ENABLED] = True
            _GUICtrlListView_SetItemText($g_hLV_Schedule, $i, "[ON] " & $sString)
            _GUICtrlListView_EndUpdate($g_hLV_Schedule)
            Return True
        EndIf
    Next

    Return False
EndFunc

Func Schedule_Disable($sString)
    For $i = 0 To $g_iSchedulesSize-1
        If $g_aSchedules[$i][$SCHEDULE_NAME] = $sString Then
            $g_aSchedules[$i][$SCHEDULE_ENABLED] = False
            _GUICtrlListView_SetItemText($g_hLV_Schedule, $i, "[OFF] " & $sString)
            Return True
        EndIf
    Next

    Return False
EndFunc

;== Other functions ==
Func _Schedule_GetTypeString($iType)
    Local $sType = ""
    Switch $iType
        Case $SCHEDULE_TYPE_DATE
            $sType = "Date"
        Case $SCHEDULE_TYPE_TIMER
            $sType = "Timer"
        Case $SCHEDULE_TYPE_DAY
            $sType = "Day"
        Case $SCHEDULE_TYPE_CONDITION
            $sType = "Condition"
    EndSwitch
    Return $sType
EndFunc

Func _Schedule_GetStructureString(ByRef $aStructure, ByRef $iType)
    Local $sStructure = ""
    Switch $iType
        Case $SCHEDULE_TYPE_DATE
            Local $aDate = $aStructure[0]
            $sStructure = "[Trigger on: " & @YEAR & "/" & $aDate[0] & "/" & $aDate[1] & " " & $aDate[2] & ":" & $aDate[3] & ":" & $aDate[4] & "]"
        Case $SCHEDULE_TYPE_TIMER
            $sStructure = "[Time Left: " & getTimeString($aStructure[1] - Int(TimerDiff($aStructure[0])/1000)) & "]"
        Case $SCHEDULE_TYPE_DAY
            $sStructure = "[Trigger on: " & _DateDayOfWeek($aStructure[$SCHEDULE_DAY_DAYOFTHEWEEK]) & " " & _ArrayToString($aStructure[$SCHEDULE_DAY_TIME], ":") & "]"
        Case $SCHEDULE_TYPE_CONDITION
            Local $sCondition = ""
            Local $aOr = $aStructure[0]
            For $i = 0 To UBound($aOr)-1
                $sCondition &= " OR ("
                If isArray($aOr[$i]) = True Then
                    $sCondition &= _ArrayToString($aOr[$i], " AND ")
                Else
                    $sCondition &= $aOr[$i]
                EndIf
                $sCondition &= ")"
            Next
            $sCondition = StringMid($sCondition, 5)
            $sStructure = "[If (" & $sCondition & ") = " & $aStructure[1] & "]"
    EndSwitch
    Return $sStructure
EndFunc

Func _Schedule_HandleAnswers(ByRef $aScheduleStructure)
    $aScheduleStructure[$SCHEDULE_NAME] = $g_aPromptsWindow_Answers[0]
    $aScheduleStructure[$SCHEDULE_ACTION] = StringSplit($g_aPromptsWindow_Answers[1], @CRLF, $STR_NOCOUNT)
    $aScheduleStructure[$SCHEDULE_TYPE] = $g_iScheduleType
    Switch $g_iScheduleType
        Case $SCHEDULE_TYPE_DATE
            Local $aDateStructure[1]
            Local $aDate[5]
            For $i = 2 To 6
                $aDate[$i-2] = $g_aPromptsWindow_Answers[$i]
            Next
            $aDateStructure[0] = $aDate

            $aScheduleStructure[$SCHEDULE_ITERATIONS] = $g_aPromptsWindow_Answers[7]
            $aScheduleStructure[$SCHEDULE_STRUCTURE] = $aDateStructure
            $aScheduleStructure[$SCHEDULE_FLAG] = $g_aPromptsWindow_Answers[8]
            $aScheduleStructure[$SCHEDULE_COOLDOWN] = $g_aPromptsWindow_Answers[9]
            $aScheduleStructure[$SCHEDULE_ENABLED-1] = $g_aPromptsWindow_Answers[10]

        Case $SCHEDULE_TYPE_TIMER
            Local $aTimerStructure[2]
            $aTimerStructure[0] = TimerInit()
            $aTimerStructure[1] = $g_aPromptsWindow_Answers[2]*60*60 + $g_aPromptsWindow_Answers[3]*60 + $g_aPromptsWindow_Answers[4]
            
            $aScheduleStructure[$SCHEDULE_ITERATIONS] = $g_aPromptsWindow_Answers[5]
            $aScheduleStructure[$SCHEDULE_STRUCTURE] = $aTimerStructure
            $aScheduleStructure[$SCHEDULE_FLAG] = $g_aPromptsWindow_Answers[6]
            $aScheduleStructure[$SCHEDULE_COOLDOWN] = $g_aPromptsWindow_Answers[7]
            $aScheduleStructure[$SCHEDULE_ENABLED-1] = $g_aPromptsWindow_Answers[8]
        
        Case $SCHEDULE_TYPE_DAY
            Local $aDayStructure[2]
            Local $aTime = [$g_aPromptsWindow_Answers[3], $g_aPromptsWindow_Answers[4], $g_aPromptsWindow_Answers[5]]
            $aDayStructure[0] = $aTime
            Switch $g_aPromptsWindow_Answers[2]
                Case "Monday"
                    $aDayStructure[1] = 2
                Case "Tuesday"
                    $aDayStructure[1] = 3
                Case "Wednesday"
                    $aDayStructure[1] = 4
                Case "Thursday"
                    $aDayStructure[1] = 5
                Case "Friday"
                    $aDayStructure[1] = 6
                Case "Saturday"
                    $aDayStructure[1] = 7
                Case "Sunday"
                    $aDayStructure[1] = 1
            EndSwitch
            $aScheduleStructure[$SCHEDULE_ITERATIONS] = $g_aPromptsWindow_Answers[6]
            $aScheduleStructure[$SCHEDULE_STRUCTURE] = $aDayStructure
            $aScheduleStructure[$SCHEDULE_FLAG] = $g_aPromptsWindow_Answers[7]
            $aScheduleStructure[$SCHEDULE_COOLDOWN] = $g_aPromptsWindow_Answers[8]
            $aScheduleStructure[$SCHEDULE_ENABLED-1] = $g_aPromptsWindow_Answers[9]

        Case $SCHEDULE_TYPE_CONDITION
            Local $aConditionStructure[2]

            Local $sConditionRaw = $g_aPromptsWindow_Answers[2]
            Local $aOR = StringSplit($sConditionRaw, @CRLF, $STR_NOCOUNT)
            For $i = UBound($aOR)-1 To 0 Step -1
                If StringStripWS($aOR[$i], $STR_STRIPLEADING+$STR_STRIPTRAILING) = "" Then
                    _ArrayDelete($aOR, $i)
                EndIf
            Next

            Local $aCondition[UBound($aOR)]
            For $i = 0 To UBound($aOR)-1
                If StringInStr($aOR[$i], "&&") Then
                    Local $aAND = StringSplit($aOR[$i], "&&", $STR_NOCOUNT)
                    For $x = UBound($aAND)-1 To 0 Step -1
                        $aAND[$x] = StringStripWS($aAND[$x], $STR_STRIPLEADING+$STR_STRIPTRAILING)
                        If $aAnd[$x] = "" Then _ArrayDelete($aAnd, $x)
                    Next
                    $aCondition[$i] = $aAND
                Else
                    $aCondition[$i] = StringStripWS($aOR[$i], $STR_STRIPLEADING+$STR_STRIPTRAILING)
                EndIf
            Next

            $aConditionStructure[0] = $aCondition
            $aConditionStructure[1] = $g_aPromptsWindow_Answers[3]

            $aScheduleStructure[$SCHEDULE_ITERATIONS] = $g_aPromptsWindow_Answers[4]
            $aScheduleStructure[$SCHEDULE_STRUCTURE] = $aConditionStructure
            $aScheduleStructure[$SCHEDULE_FLAG] = $g_aPromptsWindow_Answers[5]
            $aScheduleStructure[$SCHEDULE_COOLDOWN] = $g_aPromptsWindow_Answers[6]
            $aScheduleStructure[$SCHEDULE_ENABLED-1] = $g_aPromptsWindow_Answers[7]
    EndSwitch

    If $aScheduleStructure[$SCHEDULE_ENABLED-1] = "True" Then 
        $aScheduleStructure[$SCHEDULE_ENABLED-1] = True
    Else
        $aScheduleStructure[$SCHEDULE_ENABLED-1] = False
    EndIf
EndFunc
