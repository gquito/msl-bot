#include-once
#include "../../imports.au3"

Func doRefill()
    If getLocation() = "refill" Then
        ;refill only once and closes the window
        If clickWhile(getArg($g_aPoints, "refill"), "isLocation", "refill") = True Then
            Local $t_hTimer = TimerInit()
            Local $sCurLocation = isLocation("refill,buy-gem,buy-gold", False)
            While $sCurLocation = ""
                If TimerDiff($t_hTimer) > 10000 Then Return False
                clickPoint(getArg($g_aPoints, "refill-confirm"))

                $sCurLocation = isLocation("refill,buy-gem,buy-gold", False)
            WEnd

            ;Checks for no gems left or success
            Switch $sCurLocation
            Case "refill"
                If closeWindow() = False Then
                    addLog($g_aLog, "Could not close refill window, navigating to map.", $LOG_ERROR)
                    navigate("map")
                EndIf

                enterBattle()
                Return True
            Case "buy-gold", "buy-gem"
                addLog($g_aLog, "Not enough gems for refill.", $LOG_ERROR)
                Return False
            EndSwitch
        EndIf
    EndIf

    addLog($g_aLog, "Could not refill.", $LOG_ERROR)
    Return False
EndFunc