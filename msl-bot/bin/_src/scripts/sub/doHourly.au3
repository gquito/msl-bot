#include-once
#include "../../imports.au3"

#cs 
    Function: Based on _Hourly settings, perform hourly tasks
    Parameter: _Hourly config, formatted arguments.
    Returns:
        Success: True
        Failure: False 
#ce
Func doHourly($aHourlyConfig = formatArgs(getScriptData($g_aScripts, "_Hourly")[2]))
    Log_Level_Add("doHourly")
    Log_Add("Performing hourly tasks.")

    Local $bOutput = False
    While True
        ;Check if all settings are disabled
        If (getArg($aHourlyConfig, "Collect_Hiddens") = "Disabled") And (getArg($aHourlyConfig, "Click_Nezz") = "Disabled") Then
            $bOutput = True
            ExitLoop
        EndIf

        If navigate("village") = True Then
            If _Sleep(5000) Then ExitLoop
            Local $iPos = -1; The village position

            ;Tries to close some GUI in-game that blocks the hourly rewards.
            Log_Add("Closing village interfaces.", $LOG_DEBUG)
            clickPoint("74,333", 2, 500, Null)
            clickPoint("744,72", 2, 500, Null)
            clickPoint("779,108", 2, 500, Null)

            If getLocation() <> "village" Then navigate("village")
            $iPos = getVillagePos()
            Log_Add("Airship position detected: " & $iPos & ".", $LOG_DEBUG)
            If $iPos = -1 Then ExitLoop
            If getLocation() <> "village" Then navigate("village")

            If getArg($aHourlyConfig, "Collect_Hiddens") = "Enabled" = True Then
                Log_Add("Collecting hidden rewards.")
                Local $aPoints = StringSplit($g_aVillageTrees[$iPos], "|", 2) ;format: {"#,#", "#,#"..}
                For $i = 0 To UBound($aPoints)-2 ;collecting the rewards
                    Log_Add("Collecting hidden #" & $i+1)

                    Local $t_hTimer = TimerInit()
                    While (getLocation() <> "hourly-reward") And (TimerDiff($t_hTimer) < 5000)
                        If _Sleep(100) Then ExitLoop(3)
                        clickPoint($aPoints[$i], 3, 200, Null)
                        If getLocation() <> "village" Then navigate("village")
                    WEnd
                    
                    If getLocation() <> "village" Then navigate("village")
                Next
            EndIf
            
            If getLocation() <> "village" Then navigate("village")
            If _Sleep(10) Then ExitLoop

            If getArg($aHourlyConfig, "Click_Nezz") = "Enabled" = True Then
                Local $aNezzLoc = getArg($g_aNezzPos, "village-pos" & $iPos)
                If $aNezzLoc <> -1 Then
                    Log_Add("Attempting to click nezz.")
                    For $aNezz In StringSplit($aNezzLoc, "|", $STR_NOCOUNT)
                        clickPoint($aNezz, 1, 200, Null)
                        If getLocation() <> "village" Then navigate("village")
                    Next
                EndIf
            EndIf
        Else
            ExitLoop
        EndIf

        $bOutput = True
        ExitLoop
    WEnd

    navigate("map")
    $g_bPerformHourly = Not($bOutput)

    Log_Add("Performing hourly result: " & $bOutput, $LOG_DEBUG)
    Log_Level_Remove()
    Return $bOutput
EndFunc