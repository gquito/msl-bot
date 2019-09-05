#include-once

#cs 
    Function: Sell gems in manage screen.
    Parameters:
        $aGrades: List of grades to sell from 1-5
    Returns:
        Success: True
        Failure: False 
#ce
Func sellGems($aGrades)
    Log_Level_Add("sellGems")
    Log_Add("Selling gems.")

    Local $bOutput = False
    
    While True
        If navigate("manage", False, 3) Then
            Log_Add("Selling grades: " & $aGrades & ".", $LOG_INFORMATION)
            For $iGrade in StringSplit($aGrades, ",", $STR_NOCOUNT)
                clickPoint(getPointArg("manage-grade" & $iGrade))
                If _Sleep(200) Then ExitLoop(2)
            Next

            If clickUntil(getPointArg("manage-sell-selected"), "isLocation", "sell-gems-confirm", 3, 500) Then
                If clickWhile(getPointArg("manage-sell-confirm"), "isLocation", "sell-gems-confirm", 3, 500) Then 
                    navigate("map")
                EndIf
            EndIf
        Else
            Log_Add("Could not navigate to manage.", $LOG_ERROR)
            ExitLoop
        EndIf

        $bOutput = True
        ExitLoop
    WEnd

    Log_Add("Sell gems result: " & $bOutput & ".", $LOG_DEBUG)
    Log_Level_Remove()
    Return $bOutput
EndFunc