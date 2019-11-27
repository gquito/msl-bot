#include-once


Func doHourly()
    Log_Level_Add("doHourly")
    Log_Add("Performing hourly tasks")
    
    Local $hTimer = TimerInit()
    Local $aTurn = ["Collect_Hiddens", "Click_Nezz"]
    For $i = 0 To UBound($aTurn)-1
        If _Sleep(100) Then ExitLoop
        If Eval("Hourly_" & $aTurn[$i]) = False Then ContinueLoop
        Local $bResult = Call("Hourly_" & $aTurn[$i])
        Log_Add($aTurn[$i] & " result: " & $bResult, $LOG_DEBUG)
    Next

    Cumulative_AddNum("Collected (Hourly)", 1)

    Log_Level_Remove()
    Return True
EndFunc

;----------------------------------------------
;Helper functions

Func Hourly_Close_Village_Interface()
    If getLocation() <> "village" Then Return False
    If clickWhile(getPointArg("village-missions-popup-close"), "isPixel", CreateArr(getPixelArg("village-missions-popup")), 5, 200, "CaptureRegion()") = False Then Return False
    If clickWhile(getPointArg("village-events-close"), "isPixel", CreateArr(getPixelArg("village-events")), 5, 200, "CaptureRegion()") = False Then Return False
    If clickWhile(getPointArg("village-pack-close"), "isPixel", CreateArr(getPixelArg("village-pack")), 5, 200, "CaptureRegion()") = False Then Return False
    Return True
EndFunc

Func Hourly_Get_Village_Pos()
    Local $iPos = -1
    Local $iTries = 0

    If getLocation() <> "village" Then navigate("village")
    While $iPos = -1 And $iTries < 5
        Hourly_Close_Village_Interface()

        $iPos = getVillagePos()
        If ($iPos = -1) Then

            Log_Add("Airship position not found. Reloading village.", $LOG_ERROR)

            navigate("map")
            navigate("village")

            If _Sleep(2000) Then ExitLoop
            Hourly_Close_Village_Interface()
        Else
            Log_Add("Airship position detected: " & $iPos & ".", $LOG_DEBUG)
        EndIf
        $iTries += 1
    WEnd
	Return $iPos
EndFunc

;----------------------------------------------

Func Hourly_Collect_Hiddens()
    If isLocation("village,quests,monsters,monsters-evolution") = True Then navigate("map")
    Local $iPos = Hourly_Get_Village_Pos()
    If $iPos = -1 Then Return False

    Log_Add("Collecting hidden rewards.")
    Local $aPoints = StringSplit($g_aVillageTrees[$iPos], "|", 2)
    For $i = 0 To UBound($aPoints)-2
        If _Sleep(100) Then Return False

        Log_Add("Collecting hidden #" & $i+1)

        Local $hTimer = TimerInit()

        Local $bLog = $g_bLogEnabled
        $g_bLogEnabled = False
        While TimerDiff($hTimer) < 5000
            If _Sleep(200) Then Return False
            Switch getLocation()
                Case "village"
                    Hourly_Close_Village_Interface()
                    clickPoint($aPoints[$i])
                Case "hourly-reward"
                    Cumulative_AddNum("Collected (Hidden Trees)", 1)
                    navigate("village")
                    ExitLoop
                Case Else
                    If navigate("village", False, 3) = False Then Return False
            EndSwitch
        WEnd
        $g_bLogEnabled = $bLog
    Next
    Return True
EndFunc

Func Hourly_Click_Nezz()
    Local $iPos = Hourly_Get_Village_Pos()
    If $iPos = -1 Then Return False

    Local $aNezzLoc = getArg($g_aNezzPos, "village-pos" & $iPos)
    If ($aNezzLoc <> -1) Then
        Log_Add("Attempting to click nezz.")
        For $aNezz In StringSplit($aNezzLoc, "|", $STR_NOCOUNT)
            clickPoint($aNezz, 1)

            If _Sleep(500) Then Return False

            Local $sLocation = getLocation()
            If $sLocation <> "village" Then 

                If $sLocation = "dialogue-skip" Then
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