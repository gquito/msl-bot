#include-once
#include "../imports.au3"

#cs
    Function: Sleep that accounts for script state
    Parameters:
        $iDuration: Amount of time to sleep in milliseconds
    Returns: True if script needs to be stopped.
#ce
Global $bScheduled = False
Func _Sleep($iDuration)
    Local $vTimerInit = TimerInit()
    While TimerDiff($vTimerInit) < $iDuration
        Switch getMinute()
            Case "00"
                If $bScheduled = False Then 
                    $g_bPerformHourly = True
                    $g_bPerformGuardian = True

                    Log_Save($g_aLog, getArg(formatArgs(getScriptData($g_aScripts, "_Config")[2]), "Profile_Name"), (UBound($g_aLog) > 1000))
                EndIf

                $bScheduled = True
            Case "30"
                If $bScheduled = False Then $g_bPerformGuardian = True
                
                $bScheduled = True
            Case Else
                $bScheduled = False
        EndSwitch
        If ($g_bRunning = True) And ($g_hScriptTimer <> Null) Then
            WinSetTitle($hParent, "", $g_sAppTitle & ": " & StringReplace($g_sScript, "_", "") & " - " & getTimeString(TimerDiff($g_hScriptTimer)/1000))

            ;Data update sequence
            Data_Display()

            ;AntiStuck sequence
            If $g_iRestartTime <> 0 Then
                If ($g_hTimerLocation <> Null) And (TimerDiff($g_hTimerLocation) > (60000*$g_iRestartTime)) Then ;10 minute anti-stuck
                    $g_hTimerLocation = Null
                    Log_Level_Add("_Sleep")
                    Log_Add("AntiStuck: Stuck for 10 minutes, restarting nox.", $LOG_ERROR)
                    RestartNox()
                    Log_Level_Remove()
                EndIf
            EndIf
        EndIf
        
        While $g_bPaused = True
            $g_hTimerLocation = Null
            GUI_HANDLE()
        WEnd

        If $g_bRunning = False Then 
            $g_hTimerLocation = Null
            Return True
        EndIf

        GUI_HANDLE()
    WEnd
    Return False
EndFunc

#cs 
    Function: Displays global debug variable.
    Parameter:
        $vDebug: Data containing debug information.
#ce
Func DisplayDebug($vDebug = $g_vDebug)
    If isArray($vDebug) = True Then
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
    For $i = 0 To UBound($aLines, $UBOUND_ROWS)-1
        If $aLines[$i] = "" Then ContinueLoop
        Local $sResult = Execute($aLines[$i])
        If (isArray($sResult) = False) And (String($sResult) = "") Then $sResult = "N/A"

        If isArray($sResult) = True Then
            _ArrayDisplay($sResult)
            Log_Add("{Array} <= " & $aLines[$i], $LOG_INFORMATION)
        Else
            Log_Add(String($sResult) & " <= " & $aLines[$i], $LOG_INFORMATION)
        EndIf
        
    Next

    Log_Add("Debug Input has stopped.")
    Log_Level_Remove()
    Stop()
EndFunc