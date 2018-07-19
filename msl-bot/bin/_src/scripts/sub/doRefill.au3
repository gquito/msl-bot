#include-once
#include "../../imports.au3"

#cs 
    Function: Peform refill
    Returns: 1 on success, error code on fail.
        Error codes:
        -1: Took too long to refill.
        -2: Not enough gems for refill
#ce
Global Const $REFILL_NOREFILL = -1, $REFILL_NOGEMS = -2
Func doRefill()
    Log_Level_Add("doRefill")
    Log_Add("Refilling energy.")

    Local $iOutput = -1
    While True
        If getLocation() = "refill" Then
            ;refill only once and closes the window
            If clickWhile(getArg($g_aPoints, "refill"), "isLocation", "refill") = True Then
                Local $t_hTimer = TimerInit()
                Local $sCurLocation = isLocation("refill,buy-gem,buy-gold", False)
                While $sCurLocation = ""
                    If TimerDiff($t_hTimer) > 10000 Then ExitLoop(2)
                    clickPoint(getArg($g_aPoints, "refill-confirm"))

                    $sCurLocation = isLocation("refill,buy-gem,buy-gold", False)
                WEnd

                ;Checks for no gems left or success
                Switch $sCurLocation
                Case "refill"
                    Stat_Increment($g_aStats, "Astrogems spent", 30)
                    If closeWindow() = False Then
                        navigate("map")
                    EndIf
                    
                    enterBattle()
                Case "buy-gold", "buy-gem"
                    Log_Add("Not enough gems for refill.", $LOG_ERROR)
                    $iOutput = -2
                    ExitLoop
                EndSwitch
            EndIf
        Else
            ExitLoop
        EndIf

        $iOutput = 1
        ExitLoop
    WEnd

    Log_Add("Refill energy result: " & $iOutput, $LOG_DEBUG)
    Log_Level_Remove()
    Return $iOutput
EndFunc