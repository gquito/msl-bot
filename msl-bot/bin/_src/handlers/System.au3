#include-once

#cs
    Function: Sleep that accounts for script state
    Parameters:
        $iDuration: Amount of time to sleep in milliseconds
    Returns: True if script needs to be stopped.
#ce
Func _Sleep($iDuration = 0)
    Local $hTimer = TimerInit()
    Do 
        If (UBound($g_aLog) > $g_iLOG_Processed) Then Log_Display()

        If $g_bRunning = True Then
            If $iDuration = 0 And $g_bRestarting = False Then ExitLoop
            If $g_hScriptTimer <> Null Then
                Local $sTime = getTimeString(TimerDiff($g_hScriptTimer)/1000)
                If $sTime <> $g_sOldTime And Not(WinGetState($g_hParent) = 0x16) Then ;$WIN_STATE_MINIMIZED
                    $g_sOldTime = $sTime

                    GUICtrlSetData($g_idLbl_ScriptTime, "Time: " & $sTime)
                EndIf    

                If $g_bRestarting = False Then _AntiStuck()
            EndIf

            While $g_bPaused
                If ($g_hTimeSpent <> "/Paused") Then 
                    _Cumulative_Calculated($g_aCumulative)
                    Cumulative_Save($g_aCumulative)
                    $g_hTimeSpent = "/Paused"
                EndIf
                
                $g_hTimerLocation = Null
                GUI_HANDLE()
            WEnd
            If ($g_hTimeSpent = "/Paused") Then $g_hTimeSpent = TimerInit()

            GUI_HANDLE()
        Else
            $g_hTimerLocation = Null
            Return True
        EndIf
    Until (TimerDiff($hTimer) > $iDuration)
    Return False
EndFunc

Func _AntiStuck()
    If $g_bAntiStuck = False Then Return True
    Log_Level_Add("_AntiStuck")
    Local $bOutput = False

    If (Mod(Int(TimerDiff($g_hScriptTimer)/1000)+1, 30) = 0 And TimerDiff($g_hGameCheckCD) > 2000) Then
        $g_hGameCheckCD = TimerInit()

        If getLocation() = "crash" Then
            Log_Add("AntiStuck: Game is not running. Restarting Game.", $LOG_ERROR)

            $bOutput =_AntiStuck_Restart()
            If $bOutput = False Then Stop()

        EndIf
    EndIf

    ;AntiStuck sequence
    If $Config_Location_Stuck_Timeout > 0 Then
        If $g_hTimerLocation <> Null And TimerDiff($g_hTimerLocation) > (60000 * $Config_Location_Stuck_Timeout) Then 
            $g_hTimerLocation = Null
            
            Log_Add("AntiStuck: Stuck for " & $Config_Location_Stuck_Timeout & " minutes, restarting game.", $LOG_ERROR)
            If navigate("map", True) = False Then
                $bOutput =_AntiStuck_Restart()
                If $bOutput = False Then Stop()
            EndIf

        EndIf
    EndIf

    Log_Level_Remove()
    Return $bOutput
EndFunc

Func _AntiStuck_Restart()
    Local $bOutput = True
    If RestartGame() = False Then 
        If RestartNox(2, "") = False Then
            Log_Add("AntiStuck: Could not restart nox.", $LOG_ERROR)
            $bOutput = False
        EndIf
    EndIf
    Return $bOutput
EndFunc


;===============================================================================
;
; Name...........: _HighPrecisionSleep()
; Description ...: Sleeps down to 0.1 microseconds
; Syntax.........: _HighPrecisionSleep( $iMicroSeconds, $hDll=False)
; Parameters ....:  $iMicroSeconds      - Amount of microseconds to sleep
;                  $hDll  - Can be supplied so the UDF doesn't have to re-open the dll all the time.
; Return values .: None
; Author ........: Andreas Karlsson (monoceres)
; Modified.......:
; Remarks .......: Even though this has high precision you need to take into consideration that it will take some time for autoit to call the function.
; Related .......:
; Link ..........; 
; Example .......; No
;
;;==========================================================================================
Func _HighPrecisionSleep($iMicroSeconds,$hDll=False)
    Local $hStruct, $bLoaded
    If Not $hDll Then
        $hDll=DllOpen("ntdll.dll")
        $bLoaded=True
    EndIf
    $hStruct=DllStructCreate("int64 time;")
    DllStructSetData($hStruct,"time",-1*($iMicroSeconds*10))
    DllCall($hDll,"dword","ZwDelayExecution","int",0,"ptr",DllStructGetPtr($hStruct))
    ;If $bLoaded Then DllClose($hDll)
EndFunc

#cs 
    Function: Displays global debug variable.
    Parameter:
        $vDebug: Data containing debug information.
#ce
Func DisplayDebug($vDebug = $g_vDebug)
    If isArray($vDebug = True) Then
        _ArrayDisplay($vDebug)
        MsgBox(0, "MSL Bot DEBUG", "Error Message:" & @CRLF & $g_sErrorMessage)
    Else   
        MsgBox(0, "MSL Bot DEBUG", $vDebug & @CRLF & "Error Message:" & @CRLF & $g_sErrorMessage)
    EndIf
EndFunc

;calls for debug prompt
Func Debug()
    If $g_bRunning = False Then
        $g_sScript = "_Debug"
        Start()
    EndIf
EndFunc

Func _Debug()
    Log_Level_Add("_Debug")
    Log_Add("Debug Input has started.")
    
    ;Prompting for code
    Local $aLines = StringSplit(InputBox("Debug Input", "Enter an expression: " & @CRLF & "- Lines of expressions can be separated by '~' delimeter.", default, default, default, 150), "~", $STR_NOCOUNT)
    
    $g_bAntiStuck = False
    _ProcessLines($aLines)
    $g_bAntiStuck = True

    Log_Add("Debug Input has stopped.")
    Log_Level_Remove()
    Stop()
EndFunc

Func _ProcessLines($aLines, $bDisplayArray = True, $bLog = True)
    For $i = 0 To UBound($aLines)-1
        If ($aLines[$i] = "") Then ContinueLoop
        Local $sResult = Execute($aLines[$i])

        If (@error) Then
            If $bLog Then Log_Add("ERROR <= " & $aLines[$i], $LOG_INFORMATION)
            ContinueLoop
        EndIf

        If (Not(isArray($sResult)) And String($sResult) = "") Then $sResult = "N/A"

        If (isArray($sResult)) Then
            If $bDisplayArray = True Then _ArrayDisplay($sResult)
            If $bLog Then Log_Add("{Array} <= " & $aLines[$i], $LOG_INFORMATION)
        Else
            If $bLog Then Log_Add(String($sResult) & " <= " & $aLines[$i], $LOG_INFORMATION)
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
    If $g_bRunning = False Then
        $g_sScript = "_DebugFunction"

        Start()
        ;Start test here:
        RestartNox()
        ;End TEST
    EndIf
EndFunc

Func Custom_Function()
    While _Sleep(100) = False
    WEnd
EndFunc