#include-once
#include "../imports.au3"

#cs
    Function: Sleep that accounts for script state
    Parameters:
        $iDuration: Amount of time to sleep in milliseconds
    Returns: True if script needs to be stopped.
#ce
Func _Sleep($iDuration)
    Local $vTimerInit = TimerInit()
    While TimerDiff($vTimerInit) < $iDuration
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