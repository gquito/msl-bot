#include-once
#include "../imports.au3"

#cs
    Function: Sleep that accounts for script state
    Parameters:
        $iDuration: Amount of time to sleep in milliseconds
        $iDelay: Delay between checking the script state in milliseconds
    Returns: True if script needs to be stopped.
#ce
Func _Sleep($iDuration, $iDelay = 50)
    Local $vTimerInit = TimerInit()
    While TimerDiff($vTimerInit) < $iDuration
        While $g_bPaused = True
            Sleep($iDelay)
        WEnd

        If $g_bRunning = False Then Return True 
        Sleep($iDelay)
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
    Else   
        MsgBox(0, "MSL Bot DEBUG", $vDebug)
    EndIf
EndFunc