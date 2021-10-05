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
                Log_Add("Searching for an expedition.")
                Local $aPoint = Expedition_FindExplore()
                If isArray($aPoint) > 0 Then
                    clickPoint($aPoint)
                    waitLocation("expedition-explore", 5)
                Else
                    Log_Add("Expedition Complete.")
                    $bResult = True
                    ExitLoop
                EndIf
            Case "expedition-cancel"
                closeWindow()
            Case "expedition-explore"
                Select
                    Case findImage("expedition-complete", 90, 0, 609, 399, 180, 132) <> -1
                        clickPoint("702,463")
                    Case findImage("expedition-unknown") <> -1
                        clickPoint("705,401")
                    Case findImage("expedition-explore", 90, 0, 609, 399, 180, 132) <> -1
                        If isPixel("399,248,0x7D624D") > 0 Then clickPoint(getPointArg("expedition-autoselect"))

                        clickPoint(getPointArg("expedition-explore"))
                        If _Sleep(2000) Then ExitLoop
                    Case findImage("expedition-exploring", 90, 0, 609, 399, 180, 132) <> -1
                        Cumulative_AddNum("Collected (Expedition)", 1)
                        Log_Add("Explored expedition x" & $iCounter, $LOG_INFORMATION)
                        $iCounter += 1

                        navigate("expedition")
                    Case Else
                        clickPoint("705,401")
                EndSelect
            Case "refill"
                doRefill()
            Case "map"
                navigate("expedition", True)
            Case "unknown"
                If waitLocation("expedition,expedition-explore", 2) <= 0 And isPixel("399,109,0xBBB6E5/357,142,0xF5DE06", 10, CaptureRegion()) > 0 Then
                    clickPoint("698,380")
                Else
                    ContinueCase                
                EndIf
            Case Else
                If HandleCommonLocations($sLocation) = 0 And $sLocation <> "unknown" Then
                    If waitLocation("expedition,expedition-explore", 2) = 0 Then
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

Func Expedition_FindExplore()
    Local $aOutput = -1 ;End with point for explore/complete button
    Local Const $SWIPE = [675,169,375,169] ;Swipe Left

    If getLocation() <> "expedition" Then 
        If navigate("expedition", True, 2) = 0 Then Return $aOutput
    EndIf

    Local $hTimer = TimerInit()
    Local $aPoint[2] = [Null, Null]
    While TimerDiff($hTimer) < 20000
        CaptureRegion()
        Local $aPoints = findImageMultiple("expedition-explored", 90, 10, 10, 3, 185, 427, 615, 100, False)
        If $aPoints <> -1 Then
            For $i = 0 To UBound($aPoints)-1
                If isPixel(CreateArr($aPoints[$i][0], 364, 0x203909), 5, CaptureRegion()) = 0 Then
                    $aPoint[0] = $aPoints[$i][0]
                    $aPoint[1] = $aPoints[$i][1]
                    ExitLoop(2)
                EndIf
            Next
        EndIf

        If findImage("expedition-end", 90, 0, 404, 147, 400, 50) <> -1 Then ExitLoop
        clickDrag($SWIPE)
        If _Sleep(1500) Then ExitLoop
    WEnd

    If $aPoint[0] <> Null Then $aOutput = $aPoint

    Return $aOutput
EndFunc