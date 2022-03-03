#include-once

Func doExpedition()
    Log_Level_Add("doExpedition")
    Local $bResult = False

    Local $iCounter = 1
    Local $hTimer = TimerInit()
    While TimerDiff($hTimer) < 120000
        If _Sleep($Delay_Script_Loop) Then ExitLoop
        Local $sLocation = getLocation()
        Switch $sLocation
            Case "expedition"
                Local $isCompleted = isPixel(getPixelArg("expedition-completed"))
                If $isCompleted = False Then
                    Status("Exploring all expeditions.", $LOG_INFORMATION)
                    clickPoint(getPointArg("expedition-explore"))
                Else
                    $bResult = True
                    Status("Finished expedition.", $LOG_PROCESS)
                    ExitLoop
                EndIf
            Case "expedition-reward"
                clickPoint(getPointArg("expedition-reward"))
            Case "expedition-confirm"
                clickPoint(getPointArg("expedition-confirm"))
            Case "refill"
                If doRefill() = False Then
                    Log_Add("Could not refill energy.", $LOG_INFORMATION)
                    ExitLoop
                EndIf
            Case "map"
                navigate("expedition", True)
            Case Else
                If HandleCommonLocations($sLocation) = 0 And $sLocation <> "unknown" Then
                    If waitLocation("expedition", 2) = 0 Then
                        If navigate("expedition", True, 2) = 0 Then
                            ExitLoop
                        EndIf
                    EndIf
                EndIf
        EndSwitch
    WEnd
    navigate("village")

    Log_Level_Remove()
    Return $bResult
EndFunc