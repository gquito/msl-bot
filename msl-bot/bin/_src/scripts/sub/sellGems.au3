#include-once
#include "../../imports.au3"

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
        If navigate("manage") = True Then
            Log_Add("Selling grades: " & $aGrades & ".")
            For $iGrade in StringSplit($aGrades, ",", $STR_NOCOUNT)
                clickPoint(getArg($g_aPoints, "manage-grade" & $iGrade), 1, 0, Null)
                If _Sleep(500) Then ExitLoop(2)
            Next

            For $i = 0 To 3 
                clickPoint(getArg($g_aPoints, "manage-sell-selected"), 3, 200)
                clickPoint(getArg($g_aPoints, "manage-sell-confirm"), 3, 200, Null)
            Next

            navigate("map")
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