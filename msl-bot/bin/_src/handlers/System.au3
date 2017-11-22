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
        EndIf
        
        displayLog($g_aLog, $hLV_Log)
        While $g_bPaused = True
            displayLog($g_aLog, $hLV_Log)
            GUI_HANDLE()
        WEnd

        If $g_bRunning = False Then Return True 
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
    ;Prompting for code
    Local $aLines = StringSplit(InputBox("Debug Input", "Enter an expression: " & @CRLF & "- Lines of expressions can be separated by '|' character.", default, default, default, 150), "|", $STR_NOCOUNT)

    addLog($g_aLog, "```Debug script has started.", $LOG_NORMAL)
    ;Process each line of code
    For $i = 0 To UBound($aLines, $UBOUND_ROWS)-1
        If $aLines[$i] = "" Then ContinueLoop
        Local $sResult = Execute($aLines[$i])
        If String($sResult) = "" Then $sResult = "N/A"

        If isArray($sResult) Then
            _ArrayDisplay($sResult)
            addLog($g_aLog, "{Array} <= " & $aLines[$i], $LOG_NORMAL)
        Else
            addLog($g_aLog, String($sResult) & " <= " & $aLines[$i], $LOG_NORMAL)
        EndIf
        
    Next

    ;Exit
    addLog($g_aLog, "Debug script has stopped.```")
    Stop()
EndFunc