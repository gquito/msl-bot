#include-once

Func doHourly()
    Log_Level_Add("doHourly")
    Log_Add("Performing hourly tasks")
    
    Local $hTimer = TimerInit()
    Local $aTurn = ["Collect_Hiddens", "Click_Nezz"]
    For $i = 0 To UBound($aTurn)-1
        If _Sleep(100) Then ExitLoop

        Local $sTask = $aTurn[$i]
        If isBool(Eval("Hourly_" & $sTask)) = True And Eval("Hourly_" & $sTask) = False Then ContinueLoop

        Local $bResult = Call($sTask)
        Log_Add($sTask & " result: " & $bResult, $LOG_DEBUG)
    Next

    Cumulative_AddNum("Collected (Hourly)", 1)
    Log_Level_Remove()
    Return True
EndFunc

;----------------------------------------------
;Helper functions

Func Close_Village_Interface()
    CaptureRegion()
    If isPixel(getPixelArg("village-missions-popup")) = True Then clickPoint(getPointArg("village-missions-popup-close"))
    If isPixel(getPixelArg("village-events")) = True Then clickPoint(getPointArg("village-events-close"))
    If isPixel(getPixelArg("village-pack")) = True Then clickPoint(getPointArg("village-pack-close"))
EndFunc

Func Get_Village_Pos()
    Local $iPos = -1
    Local $iTries = 0

    navigate("village")
    While $iPos = -1 And $iTries < 5
        CaptureRegion()
        Close_Village_Interface()

        $iPos = getVillagePos()
        If ($iPos = -1) Then

            Log_Add("Airship position not found. Reloading village.", $LOG_ERROR)

            navigate("map")
            navigate("village")

            If _Sleep(2000) Then ExitLoop
        Else
            Log_Add("Airship position detected: " & $iPos & ".", $LOG_DEBUG)
        EndIf
        $iTries += 1
    WEnd
	Return $iPos
EndFunc

;----------------------------------------------

Func Collect_Hiddens()
    If isLocation("village,quests,monsters,monsters-evolution") > 0 Then navigate("map")
    Local $iPos = Get_Village_Pos()
    If $iPos = -1 Then Return False

    Log_Add("Collecting hidden rewards.")
    Local $aPoints = StringSplit($g_aVillageTrees[$iPos], "|", 2)
    For $i = 0 To UBound($aPoints)-2
        If _Sleep(100) Then Return False

        Log_Add("Collecting hidden #" & $i+1)

        Local $hTimer = TimerInit()

        Local $bLog = $g_bLogEnabled
        $g_bLogEnabled = False
        While TimerDiff($hTimer) < 10000 ;10 seconds max
            If _Sleep(200) Then Return False
            Switch getLocation()
                Case "village"
                    Close_Village_Interface()
                    clickPoint($aPoints[$i])
                Case "hourly-reward"
                    Cumulative_AddNum("Collected (Hidden Trees)", 1)
                    navigate("village")
                    ExitLoop
                Case Else
                    If navigate("village", False, 3) = False Then 
                        $g_bLogEnabled = $bLog
                        Return False
                    EndIf
            EndSwitch
        WEnd
        $g_bLogEnabled = $bLog
    Next
    Return True
EndFunc

Func Click_Nezz()
    Local $iPos = Get_Village_Pos()
    If $iPos = -1 Then Return False

    Local $aNezzLoc = getArg($g_aNezzPos, "village-pos" & $iPos)
    If Not(@error) Then
        Log_Add("Attempting to click nezz.")
        For $aNezz In StringSplit($aNezzLoc, "|", $STR_NOCOUNT)
            clickPoint($aNezz, 1)

            If _Sleep(500) Then Return False

            Local $sLocation = getLocation()
            If $sLocation <> "village" Then 

                If $sLocation == "dialogue-skip" Then
                    Log_Add("Found nezz", $LOG_INFORMATION)
                    Cumulative_AddNum("Collected (Nezz)", 1)
                    navigate("village")
                    Return True
                EndIf

                navigate("village")
            EndIf
        Next
    EndIf

    Return False
EndFunc