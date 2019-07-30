#include-once
#include "../imports.au3"

#cs
    Function: Sleep that accounts for script state
    Parameters:
        $iDuration: Amount of time to sleep in milliseconds
    Returns: True if script needs to be stopped.
#ce
Func _Sleep($iDuration = 0)
    ;Log_Add("_Sleep for " & $iDuration & " seconds.", $LOG_DEBUG)
    If ($iDuration = 0) Then 
        If (Not($g_bRunning)) Then 
            $g_hTimerLocation = Null
            Return True
        Else
            If (Not($g_bRestarting)) Then Return Not(_AntiStuck())
        EndIf
    EndIf

    Local $vTimerInit = TimerInit()
    While TimerDiff($vTimerInit) < $iDuration
        If (UBound($g_alog) > $g_iLOG_Processed) Then Log_Display()
        
        If (Not($g_bRunning)) Then 
            $g_hTimerLocation = Null
            Return True
        EndIf

        Switch getMinute()
            Case "00"
                If (Not($g_bScheduled)) Then 
                    $g_bPerformHourly = True
                    $g_bPerformGuardian = True
                EndIf

                $g_bScheduled = True
            Case "30"
                If (getHour() = "00") Then 
                    $g_bCleanLogFiles = False
                EndIf

                If (Not($g_bScheduled)) Then $g_bPerformGuardian = True
                $g_bScheduled = True
            Case Else
                $g_bScheduled = False
        EndSwitch

        If (Not($g_bCleanLogFiles)) Then 
            cleanOldLogFiles()
            $g_bCleanLogFiles = True
        EndIf

        If ($g_bRunning And $g_hScriptTimer <> Null) Then
            Local $sTime = getTimeString(TimerDiff($g_hScriptTimer)/1000)
            If Not(BitAND(WinGetState($g_hParent), $WIN_STATE_MINIMIZED)) And ($sTime <> $g_sOldTime) Then
                Data_Display()
                GUICtrlSetData($g_idLbl_ScriptTime, "Time: " & $sTime)
                $g_sOldTime = $sTime
            EndIf    

            ;AntiStuck sequence
            If (Not($g_bRestarting)) Then _AntiStuck()
        EndIf
        
        While $g_bPaused
            If ($g_hTimeSpent <> "/Paused") Then 
                _Stat_Calculated($g_aStats)
                Stat_Save($g_aStats)
                $g_hTimeSpent = "/Paused"
            EndIf
            
            $g_hTimerLocation = Null
            GUI_HANDLE()
        WEnd
        If ($g_hTimeSpent = "/Paused") Then $g_hTimeSpent = TimerInit()

        GUI_HANDLE()
    WEnd
    Return False
EndFunc

Func _AntiStuck()
    Local $b_Output = True
    If ($g_bDisableAntiStuck) Then Return True
    Log_Level_Add("_AntiStuck")
    ;Check if game is running every 30 seconds
    If ($g_bADBWorking And Mod(Int(TimerDiff($g_hScriptTimer)/1000)+1, 30) = 0 And TimerDiff($g_hGameCheckCD) > 2000) Then
        $g_hGameCheckCD = TimerInit()

        If (Not(isGameRunning())) Then

            Log_Add("AntiStuck: Game is not running. Restarting Game.", $LOG_ERROR)
            takeErrorScreenshot("Common_Stuck")
            If (Not(RestartGame())) Then 
                If (Not(RestartNox(2))) Then
                    Log_Add("AntiStuck: Could not restart nox.", $LOG_ERROR)
                    Stop()
                    $b_Output = False
                EndIf
            EndIf
        EndIf
    EndIf

    ;AntiStuck sequence
    If ($b_Output And $g_iRestartTime <> 0) Then
        If ($g_hTimerLocation <> Null And TimerDiff($g_hTimerLocation) > 60000 * $g_iRestartTime) Then 
            $g_hTimerLocation = Null
            
            Log_Add("AntiStuck: Stuck for " & $g_iRestartTime & " minutes, restarting game.", $LOG_ERROR)
            takeErrorScreenshot("Common_Stuck")
            If (Not(RestartGame())) Then 
                If (Not(RestartNox(2))) Then
                    Log_Add("AntiStuck: Could not restart nox.", $LOG_ERROR)
                    Stop()
                    $b_Output = False
                EndIf
            EndIf
        EndIf
    EndIf

    Log_Level_Remove()
    Return $b_Output
EndFunc

#cs 
    Function: Displays global debug variable.
    Parameter:
        $vDebug: Data containing debug information.
#ce
Func DisplayDebug($vDebug = $g_vDebug)
    If (isArray($vDebug)) Then
        _ArrayDisplay($vDebug)
        MsgBox(0, "MSL Bot DEBUG", "Error Message:" & @CRLF & $g_sErrorMessage)
    Else   
        MsgBox(0, "MSL Bot DEBUG", $vDebug & @CRLF & "Error Message:" & @CRLF & $g_sErrorMessage)
    EndIf
EndFunc

;calls for debug prompt
Func Debug()
    If (Not($g_bRunning)) Then
        $g_sScript = "_Debug"
        $g_aScriptArgs = Null

        Start()
    EndIf
EndFunc

Func _Debug()
    Log_Level_Add("_Debug")
    Log_Add("Debug Input has started.")
    
    ;Prompting for code
    Local $aLines = StringSplit(InputBox("Debug Input", "Enter an expression: " & @CRLF & "- Lines of expressions can be separated by '~' delimeter.", default, default, default, 150), "~", $STR_NOCOUNT)

    ;Process each line of code
    _ProcessLines($aLines)

    Log_Add("Debug Input has stopped.")
    Log_Level_Remove()
    Stop()
EndFunc

Func _ProcessLines($aLines, $bDisplayArray = True)
    For $i = 0 To UBound($aLines, $UBOUND_ROWS)-1
        If ($aLines[$i] = "") Then ContinueLoop
        Local $sResult = Execute($aLines[$i])

        If (@error) Then
            Log_Add("ERROR <= " & $aLines[$i], $LOG_INFORMATION)
            ContinueLoop
        EndIf

        If (Not(isArray($sResult)) And String($sResult) = "") Then $sResult = "N/A"

        If (isArray($sResult)) Then
            If $bDisplayArray = True Then _ArrayDisplay($sResult)
            Log_Add("{Array} <= " & $aLines[$i], $LOG_INFORMATION)
        Else
            Log_Add(String($sResult) & " <= " & $aLines[$i], $LOG_INFORMATION)
        EndIf
    Next
EndFunc

Func RunDebug($sCommand, $sLogLevel)
    Log_Level_Add($sLogLevel)
    Log_Add("Running command: " & $sCommand)
    _GUICtrlTab_ClickTab($g_hTb_Main, 1)
    Local $aLines = StringSplit($sCommand, "~", $STR_NOCOUNT)
    For $i = 0 To UBound($aLines, $UBOUND_ROWS)-1
        If ($aLines[$i] = "") Then ContinueLoop
        Local $sResult = Execute($aLines[$i])
        If (Not(isArray($sResult)) And String($sResult) = "") Then $sResult = "N/A"

        If (isArray($sResult)) Then
            _ArrayDisplay($sResult)
            Log_Add("{Array} <= " & $aLines[$i], $LOG_INFORMATION)
        Else
            Log_Add(String($sResult) & " <= " & $aLines[$i], $LOG_INFORMATION)
        EndIf
        
    Next
    Log_Add("Command " & $sCommand & " finished")
    Log_Level_Remove()
    Stop()
EndFunc

Func _DebugFunction()
    If (Not($g_bRunning)) Then
        $g_sScript = "_DebugFunction"
        $g_aScriptArgs = Null

        Start()
        ;Start test here:
        RestartNox()
        ;End TEST
    EndIf
EndFunc