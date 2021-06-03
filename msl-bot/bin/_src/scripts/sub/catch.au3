#include-once

Func catch($aImages, $iAstrochips = -1, $iMaxCatch = -1, $bSaveMissed = True)
    Log_Level_Add("catch")
    Local $aOutput[0]

    Local $CATCH = ["legendary", "super-rare", "exotic", "rare", "variant"]
    If isArray($aImages) = 0 Then $aImages = StringSplit($aImages, ",", 2)
    For $i = 0 To UBound($aImages)-1
        $aImages[$i] = StringReplace($aImages[$i], " ", "-")
        If _ArraySearch($CATCH, $aImages[$i]) = -1 Then
            _ArrayAdd($CATCH, $aImages[$i])
        EndIf
    Next

    Local $iCurrent = -1
    Local $iNumCatch = 0
    Local $aPoints[0]
    Local $hTimer = TimerInit()
    Log_Add("Trying to catch " & _ArrayToString($aImages, ",") & (($iMaxCatch <> -1)?", Max: " & $iMaxCatch & ".":"."), $LOG_DEBUG)
    While TimerDiff($hTimer) < 60000
        If _Sleep(100) Then ExitLoop

        Local $sLocation = getLocation()
        Switch $sLocation
            Case "catch-mode"
                If UBound($aPoints) = 0 Then
                    CaptureRegion()
                    For $x = 0 To UBound($CATCH)-1
                        Local $aFound = findImageMultiple("catch-" & $CATCH[$x], 90, 20, 20, 4, 0, 312, 800, 457-312, False)
                        If isArray($aFound) > 0 Then
                            For $i = 0 To UBound($aFound)-1
                                _ArrayAdd($aPoints, CreateArr($aFound[$i][0], $aFound[$i][1], $CATCH[$x]), 0, "|", @CRLF, 1)
                            Next
                        EndIf
                    Next
                EndIf

                If $iCurrent = -1 Then
                    For $i = 0 To UBound($aPoints)-1
                        If _ArraySearch($aImages, ($aPoints[$i])[2]) <> -1 Then
                            $iCurrent = $i
                            ExitLoop
                        EndIf
                    Next
                EndIf

                If isArray($aPoints) > 0 And $iCurrent <> -1 Then
                    Log_Add(StringFormat("Catching astromon: %s at (%s)", ($aPoints[$iCurrent])[2], _ArrayToString($aPoints[$iCurrent], ",", 0, 1)), $LOG_DEBUG)

                    clickPoint($aPoints[$iCurrent], 3)
                    If waitLocation("unknown", 5) > 0 Then
                        If $iAstrochips > 1 Then $iAstrochips -= 1
                        If _Sleep(300) Then ExitLoop

                        SendBack(2, 100)
                        clickPoint(getPointArg("battle-continue"), 3, 200)
                        clickUntil(getPointArg("tap"), "isLocation", "catch-mode,catch-success,battle-auto,battle", 50, 100)
                    Else
                        Log_Add("Could not detect catch status", $LOG_ERROR)
                        _ArrayDelete($aPoints, $iCurrent)
                        $iCurrent = -1
                    EndIf
                Else
                    Log_Add("Astromons not found.", $LOG_DEBUG)
                    ExitLoop
                EndIf
            Case "catch-success"
                Log_Add("Successfully caught a " & ($aPoints[$iCurrent])[2] & ".", $LOG_DEBUG)

                _ArrayAdd($aOutput, ($aPoints[$iCurrent])[2])
                _ArrayDelete($aPoints, $iCurrent)
                $iNumCatch += 1
                $iCurrent = -1

                If $iMaxCatch <> -1 And $iNumCatch = $iMaxCatch Then ExitLoop
                waitLocation("catch-mode,battle-auto,battle", 10)
            Case "battle-auto", "battle"
                If $iCurrent <> -1 Then
                    Log_Add("Failed to catch " & ($aPoints[$iCurrent])[2] & ".", $LOG_DEBUG)

                    If $bSaveMissed > 0 Then _ArrayAdd($aOutput, "-" & ($aPoints[$iCurrent])[2])
                    _ArrayDelete($aPoints, $iCurrent)
                    $iCurrent = -1
                EndIf

                If $iAstrochips <> -1 And $iAstrochips = 0 Then
                    If $iCurrent <> -1 Then
                        Log_Add("Failed to catch " & ($aPoints[$iCurrent])[2] & ".", $LOG_DEBUG)
                        
                        If $bSaveMissed > 0 Then _ArrayAdd($aOutput, "-" & ($aPoints[$iCurrent])[2])
                        _ArrayDelete($aPoints, $iCurrent)
                        $iCurrent = -1
                    EndIf 
                    ExitLoop
                EndIf

                If UBound($aPoints) <= 0 Then ExitLoop

                clickPoint(getPointArg("battle-catch"), 2, 100)
                If _Sleep(200) Then ExitLoop
                If isPixel(getPixelArg("catch-mode-unavailable"), 20, CaptureRegion()) > 0 Then ExitLoop
            Case "battle-end-exp", "battle-sell", "battle-sell-item", "battle-end"
                ExitLoop
            Case "pause"
                clickPoint(getPointArg("battle-continue"))
            Case "unknown"
                clickPoint(getPointArg("tap"))
                If _Sleep(200) Then ExitLoop
            Case Else
                If waitLocation("unknown,catch-success,catch-mode,battle-auto,battle", 3) > 0 Then ContinueLoop
                Log_Add("Not in catch mode. Current location: " & getLocation(), $LOG_ERROR)
                ExitLoop
        EndSwitch
    WEnd

    If $bSaveMissed > 0 And UBound($aPoints) > 0 Then
        For $i = 0 To UBound($aPoints)-1
            _ArrayAdd($aOutput, "-" & ($aPoints[$i])[2])
        Next
    EndIf

    For $i = 0 To UBound($aOutput)-1
        If StringLeft($aOutput[$i], 1) == "-" Then
            Cumulative_SubRatio("Caught (" & _StringProper(StringReplace(StringMid($aOutput[$i], 2), "_", " ")) & ")")
        Else
            Cumulative_AddRatio("Caught (" & _StringProper(StringReplace($aOutput[$i], "_", " ")) & ")")
        EndIf
    Next

    Log_Add("Catch result: " & _ArrayToString($aOutput, ","), $LOG_DEBUG)
    Log_Level_Remove()
    Return $aOutput
EndFunc