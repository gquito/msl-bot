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

                ;handles if in map-battle
                If getLocation() = "map-battle" Then
                    clickUntil(getArg($g_aPoints, "map-battle-play"), "isLocation", "unknown,battle,battle-auto", 5, 500)
                    If waitLocation("battle,battle-auto", 30) = True Then
                        addLog($g_aLog, "In battle.")
                    EndIf
                Else
                    If getLocation($g_aLocations, False) = "battle-end" Then 
                        clickUntil(getArg($g_aPoints, "battle-quick-restart"), "isLocation", "unknown,battle,battle-auto", 5, 500)
                    Else
                        navigate("map", True)
                    EndIf
                EndIf

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