#include-once
#include "../../imports.au3"

#cs 
    Function: Based on _Hourly settings, perform hourly tasks
    Parameter: _Hourly config, formatted arguments.
    Returns:
        Success: True
        Failure: False 
#ce
Func doHourly()
    Log_Level_Add("doHourly")
    Log_Add("Performing hourly tasks.")
    Local $bOutput = False
    Local $HourlyDone = 0
    Local $iPos = GetAirshipPosition()
    While $HourlyDone < 10
        if ($iPos = -1) Then 
            Log_Add("Hourly failed. Unable to find ship position. Exiting", $LOG_INFORMATION)
            ExitLoop
        EndIf

        If ($HourlyDone < 6) Then
            If isLocation("village") = False Then 
                If navigate("village", True, 2) = False Then ExitLoop
            EndIf
        EndIf
        If _Sleep(200) Then ExitLoop

        Switch($HourlyDone)
            Case 0
                If (getHourlyArg("Collect_Hiddens")) Then
                    If (Not(Collect_Hiddens($iPos))) Then ExitLoop
                EndIf
                $HourlyDone +=1
                Log_add("Completed Hiddens", $LOG_DEBUG)
            Case 1
                If (getHourlyArg("Click_Nezz")) Then Collect_Nezz($iPos)
                $HourlyDone +=1
                Log_add("Completed Nezz ", $LOG_DEBUG)
            Case Else
                ExitLoop
        EndSwitch
    WEnd

    navigate("map")
    $g_bPerformHourly = Not($bOutput)

    Log_Add("Performing hourly result: " & $bOutput, $LOG_DEBUG)
    Log_Level_Remove()
    Return $bOutput
EndFunc

Func CloseVillagePopups()
    Log_Add("Closing village interfaces.", $LOG_DEBUG)
    Local $t_hTimer = TimerInit()
    While (TimerDiff($t_hTimer) < 5000)
        If (Not($g_bRunning)) Then ExitLoop
        If (Not(IsLocation("village"))) Then navigate("village")
        If (IsPixel(getPixelArg("village-missions-popup"))) Then
            clickPoint(getPointArg("village-missions-popup-close"))
            If _Sleep(500) Then ExitLoop
            If (Not(IsPixel(getPixelArg("village-missions-popup")))) Then ExitLoop
        Else
            If (TimerDiff($t_hTimer) > 3000) Then ExitLoop
        EndIf
    Wend
    If (IsPixel(getPixelArg("village-events"))) Then
        clickPoint(getPointArg("village-events-close"), 4, 500)
    EndIf
    If (IsPixel(getPixelArg("village-pack"))) Then
        clickPoint(getPointArg("village-pack-close"), 4, 500)
    EndIf
EndFunc

Func FindAirshipPosition($iPosition)
    Local $iPos = GetAirshipPosition()
    While $iPos <> $iPosition
        $iPos = GetAirshipPosition()
    WEnd
EndFunc

Func TestVillagePopupClose($iAttempts=1)
    For $i = 1 To $iAttempts
        navigate("map")
        CloseVillagePopups()
    Next
EndFunc

Func testhiddenclick($sPoint, $iDelay = 200)
    clickPoint($sPoint)
    _Sleep($iDelay)
    takeScreenShot()
EndFunc

Func Collect_Hiddens($iPos)
    Log_Add("Collecting hidden rewards.")
    Local $aPoints = StringSplit($g_aVillageTrees[$iPos], "|", 2) ;format: {"#,#", "#,#"..}
    For $i = 0 To UBound($aPoints)-2 ;collecting the rewards
        Log_Add("Collecting hidden #" & $i+1)
        Stat_Increment($g_aStats, "Hidden rewards")

        Local $t_hTimer = TimerInit()
        While (Not(isLocation("hourly-reward"))) And (TimerDiff($t_hTimer) < 5000)
            If (_Sleep(100)) Then 
                ExitLoop(2)
                Return False
            EndIf
            clickPoint($aPoints[$i], 3, 200)
            If (Not(isLocation("village"))) Then navigate("village")
        WEnd

    Next
    Return True
EndFunc

Func Collect_Nezz($iPos)
    Local $aNezzLoc = getArg($g_aNezzPos, "village-pos" & $iPos)
    If ($aNezzLoc <> -1) Then
        Log_Add("Attempting to click nezz.")
        For $aNezz In StringSplit($aNezzLoc, "|", $STR_NOCOUNT)
            clickPoint($aNezz, 1, 200)
            If (Not(isLocation("village"))) Then 
                If (isLocation("dialogue-skip")) Then Stat_Increment($g_aStats, "Nezz found")
                navigate("village")
            EndIf
        Next
    EndIf
EndFunc

Func testColors($sAreaStrings)
    Local $sReturnString = ""
    Local $aOrPixelStrings = StringSplit($sAreaStrings,"/")
    Local $aAndPixelString[$aOrPixelStrings[0]+1]
    $aAndPixelString[0] = $aOrPixelStrings[0]
    For $i = 1 To $aOrPixelStrings[0]
        $aAndPixelString[$i] = splitPixelString($aOrPixelStrings[$i])
    Next
    For $i = 1 To $aAndPixelString[0]
        If (Not(isPixel($aAndPixelString[$i]))) Then
            Local $color = getColor($aAndPixelString[$i][0],$aAndPixelString[$i][1])
            If ($color <> $aAndPixelString[$i][2]) Then $sReturnString &= $aAndPixelString[$i][0] & "," & $aAndPixelString[$i][1] & "," & $aAndPixelString[$i][2] & " <> " & $color
            $sReturnString &= "|"
        EndIf
    Next
    If (StringRight($sReturnString,1) = "|") Then $sReturnString = StringLeft($sReturnString,StringLen($sReturnString)-1)
    If ($sReturnString = "") Then $sReturnString = "Matched"
    return $sReturnString
EndFunc

Func getHourlyArg($sName, $bReturnBool = True)
    Local $tHourlyArg = getArg($g_aHourlySettings, $sName)
    
    If ($bReturnBool) Then Return ($tHourlyArg = "Enabled")
    return $tHourlyArg
EndFunc

Func getAirshipPosition()
    Local $iPos = -1; The village position
    Local $iTries = 0
    navigate("map")
    navigate("village")
    While $iPos = -1 And $iTries < 5
        CloseVillagePopups()
        _Sleep(200)

        $iPos = getVillagePos()
        If ($iPos = -1) Then
            Log_Add("Airship position not found. Reloading village.", $LOG_ERROR)
            navigate("map")
            navigate("village")
            CloseVillagePopups()
        Else
            Log_Add("Airship position detected: " & $iPos & ".", $LOG_DEBUG)
        EndIf
        $iTries += 1
    WEnd
	Return $iPos
EndFunc

