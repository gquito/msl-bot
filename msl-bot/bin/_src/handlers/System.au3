#include-once

#cs
    Function: Sleep that accounts for script state
    Parameters:
        $iDuration: Amount of time to sleep in milliseconds
    Returns: True if script needs to be stopped.
#ce
Global $g_hTimer_TimeLabel = TimerInit()
Func _Sleep($iDuration = 0)
    Local $hTimer = TimerInit()
    Do
        If (UBound($g_aLog) > $g_iLOG_Processed) Then Log_Display()

        If $g_bRunning > 0 Then
            If $iDuration = 0 And $g_bRestarting = 0 Then ExitLoop
            If $g_hScriptTimer <> Null Then
                If (BitAnd(WinGetState($g_hParent), $WIN_STATE_MINIMIZED) = False And TimerDiff($g_hTimer_TimeLabel) > 1000) And _GUICtrlTab_GetCurSel($g_hTb_Main) = 1 Then
                    GUICtrlSetData($g_idLbl_ScriptTime, "Time: " & getTimeString(TimerDiff($g_hScriptTimer)/1000))
                    $g_hTimer_TimeLabel = TimerInit()
                EndIf

                If $g_bRestarting = 0 Then _AntiStuck()
            EndIf

            While $g_bPaused
                $g_hTimerLocation = Null
                GUI_HANDLE()
            WEnd

            GUI_HANDLE()
        Else
            $g_hTimerLocation = Null
            Return True
        EndIf
        Sleep(50)
    Until (TimerDiff($hTimer) > $iDuration)
    Return False
EndFunc

Func _AntiStuck()
    If $g_bAntiStuck = 0 Then Return True
    Log_Level_Add("_AntiStuck")
    Local $bOutput = False

    If $Config_Screen_Frozen_Check > 0 Then
        If Mod(Int(TimerDiff($g_hScriptTimer)/1000)+1, $Config_Screen_Frozen_Check) = 0 And TimerDiff($g_hGameCheckCD) > 2000 Then
            $g_hGameCheckCD = TimerInit()
            If _AntiStuck_Frozen() = True Then
                Log_Add("AntiStuck: Game is frozen. Restarting Game.", $LOG_ERROR)
    
                $bOutput =_AntiStuck_Restart()
                If $bOutput <= 0 Then Stop()
            EndIf
        EndIf
    EndIf
    
    ;If Mod(Int(TimerDiff($g_hScriptTimer)/1000)+1, 30) = 0 And TimerDiff($g_hGameCheckCD) > 2000 Then
    ;    $g_hGameCheckCD = TimerInit()
    ;    If ADB_isWorking() > 0 And ADB_IsGameRunning() <= 0 Then
    ;        Log_Add("AntiStuck: Game is not running. Restarting Game.", $LOG_ERROR);

    ;        $bOutput =_AntiStuck_Restart()
    ;        If $bOutput <= 0 Then Stop()
    ;    EndIf

    ;EndIf

    ;AntiStuck sequence
    If $Config_Location_Stuck_Timeout > 0 Then
        If $g_hTimerLocation <> Null Then
            If TimerDiff($g_hTimerLocation) > (60000 * $Config_Location_Stuck_Timeout) Then
                $g_hTimerLocation = Null

                Log_Add("AntiStuck: Stuck for " & $Config_Location_Stuck_Timeout & " minutes, restarting game.", $LOG_ERROR)
                If navigate("map", True) = 0 Then
                    $bOutput =_AntiStuck_Restart()
                    If $bOutput = 0 Then Stop()
                EndIf
            EndIf
        EndIf
    EndIf

    Log_Level_Remove()
    Return $bOutput
EndFunc

Global $_AntiStuck_Frozen = Null
Func _AntiStuck_Frozen()
    If $_AntiStuck_Frozen = Null Then
        CaptureRegion()
        $_AntiStuck_Frozen = GetPixelSum()
        If @error Then $_AntiStuck_Frozen = Null

        Return False
    EndIf

    CaptureRegion()
    Local $iSum = GetPixelSum()
    If @error Then Return False

    Local $iResult = ($_AntiStuck_Frozen = $iSum)
    $_AntiStuck_Frozen = Null

    Return $iResult
EndFunc

Func _AntiStuck_Restart()
    Local $bOutput = True
    If Emulator_RestartGame(3) <= 0 Then
        If Emulator_Restart(3) <= 0 Then
            Log_Add("AntiStuck: Could not restart emulator.", $LOG_ERROR)
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
    If isArray($vDebug > 0) Then
        _ArrayDisplay($vDebug)
        MsgBox(0, "MSL Bot DEBUG", "Error Message:" & @CRLF & $g_sErrorMessage)
    Else
        MsgBox(0, "MSL Bot DEBUG", $vDebug & @CRLF & "Error Message:" & @CRLF & $g_sErrorMessage)
    EndIf
EndFunc

;calls for debug prompt
Func Debug()
    If $g_bRunning = 0 Then
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
        If ($aLines[$i] == "") Then ContinueLoop
        Local $sResult = Execute($aLines[$i])

        If (@error) Then
            If $bLog Then Log_Add("ERROR <= " & $aLines[$i], $LOG_INFORMATION)
            ContinueLoop
        EndIf

        If (Not(isArray($sResult)) And String($sResult) == "") Then $sResult = "N/A"

        If (isArray($sResult)) Then
            If $bDisplayArray > 0 Then _ArrayDisplay($sResult)
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
        If ($aLines[$i] == "") Then ContinueLoop
        Local $sResult = Execute($aLines[$i])
        If (Not(isArray($sResult)) And String($sResult) == "") Then $sResult = "N/A"

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
    If $g_bRunning = 0 Then
        $g_sScript = "_DebugFunction"

        Start()
        ;Start test here:
        Emulator_Restart()
        ;End TEST
    EndIf
EndFunc

Func Custom_Function()
    While Sleep(50)
        CaptureRegion()
    WEnd
EndFunc