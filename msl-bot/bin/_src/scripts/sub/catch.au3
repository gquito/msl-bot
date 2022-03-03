#include-once
Global Const $CATCH_X = 0
Global Const $CATCH_Y = 1
Global Const $CATCH_NAME = 2
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

    ;Local $bScreenshot = False

    Local $iCurrent = -1
    Local $iNumCatch = 0
    Local $aCatching[0][3] ; Catching astromon list
    Local $iCatchingSize = 0

    Local $hTimer = TimerInit()
    Log_Add("Trying to catch " & _ArrayToString($aImages, ",") & (($iMaxCatch <> -1)?", Max: " & $iMaxCatch & ".":"."), $LOG_DEBUG)

    While TimerDiff($hTimer) < 60000
        If _Sleep(100) Then ExitLoop

        Local $sLocation = getLocation()
        Switch $sLocation
            Case "catch-mode"
                If $iCatchingSize = 0 Then
                    CaptureRegion()
                    For $x = 0 To UBound($CATCH) - 1
                        Local $sCurrentAstromon = $CATCH[$x]
                        Local $aFound = findImageMultiple("catch-" & $sCurrentAstromon, 90, 20, 20, 4, 0, 312, 800, 457-312, False)
                        If isArray($aFound) = True Then
                            For $i = 0 To UBound($aFound) - 1
                                ; Check if there is already a match in that area
                                Local $bOverlap = False
                                For $j = 0 To $iCatchingSize - 1
                                    Local $iX1 = $aFound[$i][0]
                                    Local $iY1 = $aFound[$i][1]
                                    Local $iX2 = $aCatching[$j][$CATCH_X]
                                    Local $iY2 = $aCatching[$j][$CATCH_Y]

                                    Local $iPixelDistance = Sqrt(($iX1 - $iX2) ^ 2 + ($iY1 - $iY2) ^ 2)
                                    If $iPixelDistance < 100 Then
                                        $bOverlap = True

                                        ; If overlap is exotic contains exotic then astromon is exotic
                                        If $aCatching[$j][$CATCH_NAME] <> "exotic" And $sCurrentAstromon == "exotic" Then
                                            Log_Add("Exotic overlap detected, replacing " & $aCatching[$j][$CATCH_NAME] & " with exotic.", $LOG_DEBUG)
                                            $aCatching[$j][$CATCH_X] = $aFound[$i][0]
                                            $aCatching[$j][$CATCH_Y] = $aFound[$i][1]
                                            $aCatching[$j][$CATCH_NAME] = $sCurrentAstromon
                                        EndIf
                                        
                                        ExitLoop
                                    EndIf
                                Next

                                If $bOverlap = False Then ; No overlap with existing match
                                    Local $aAdd[1][3] = [[$aFound[$i][0], $aFound[$i][1], $sCurrentAstromon]]
                                    _ArrayAdd($aCatching, $aAdd)
                                    $iCatchingSize += 1
                                EndIf
                            Next
                        EndIf
                    Next
                EndIf

                If $iCurrent = -1 Then
                    For $i = 0 To $iCatchingSize - 1
                        If _ArraySearch($aImages, $aCatching[$i][$CATCH_NAME]) <> -1 Then
                            $iCurrent = $i
                            ExitLoop
                        EndIf
                    Next
                EndIf

                If $iCurrent <> -1 And $iCurrent < $iCatchingSize Then
                    Local $aPoint = CreateArr($aCatching[$iCurrent][$CATCH_X], $aCatching[$iCurrent][$CATCH_Y])
                    Status(StringFormat("Attempting to catch astromon: %s at (%s)", $aCatching[$iCurrent][$CATCH_NAME], $aPoint[0] & "," & $aPoint[1]), $LOG_DEBUG)

                    If clickUntil($aPoint, "isLocation", "unknown", 5, 1000) Then
                        If $iAstrochips > 1 Then $iAstrochips -= 1

                        If _Sleep(300) Then ExitLoop

                        SendBack(2, 100) ; Fast animation
                        $g_bLogEnabled = False
                        clickPoint(getPointArg("battle-continue"), 3, 200) ; Prevents stuck from fast animation
                        $g_bLogEnabled = True

                        Local $hTempTimer = TimerInit()
                        While(isLocation("catch-mode,catch-success,battle-auto,battle") = False)
                            $g_bLogEnabled = False
                            clickPoint(getPointArg("tap"))
                            $g_bLogEnabled = True

                            If _Sleep(100) Then ExitLoop(2)
                            If TimerDiff($hTempTimer) > 7000 Then ExitLoop
                        WEnd
                    Else
                        Log_Add("Could not detect catch status", $LOG_ERROR)

                        _ArrayDelete($aCatching, $iCurrent)
                        $iCatchingSize -= 1 

                        $iCurrent = -1
                    EndIf
                Else
                    Log_Add("Astromons not found.", $LOG_DEBUG)
                    ExitLoop
                EndIf
            Case "catch-success"
                If $iCurrent <> -1 And $iCurrent < $iCatchingSize Then
                    Log_Add("Successfully caught a " & $aCatching[$iCurrent][$CATCH_NAME] & ".", $LOG_DEBUG)
                    $g_bCaptureQuest = True ; Trigger quest

                    _ArrayAdd($aOutput, $aCatching[$iCurrent][$CATCH_NAME])

                    _ArrayDelete($aCatching, $iCurrent)
                    $iCatchingSize -= 1 

                    $iNumCatch += 1
                    $iCurrent = -1

                    If $iMaxCatch <> -1 And $iNumCatch = $iMaxCatch Then ExitLoop
                    waitLocation("catch-mode,battle-auto,battle", 10)
                EndIf
            Case "battle-auto", "battle"
                Local $bCheckNormalRare = False

                If $iCurrent <> -1 And $iCurrent < $iCatchingSize Then
                    Local $sName = $aCatching[$iCurrent][$CATCH_NAME]
                    If $sName == "exotic" Then $bCheckNormalRare = True

                    Log_Add("Failed to catch " & $sName & ".", $LOG_DEBUG)
                    If $bSaveMissed > 0 Then _ArrayAdd($aOutput, "-" & $aCatching[$iCurrent][$CATCH_NAME])

                    _ArrayDelete($aCatching, $iCurrent)
                    $iCatchingSize -= 1

                    $iCurrent = -1
                EndIf

                If $iAstrochips <> -1 And $iAstrochips = 0 Then
                    If $iCurrent <> -1 And $iCurrent < $iCatchingSize Then
                        Log_Add("Failed to catch " & $aCatching[$iCurrent][$CATCH_NAME] & ".", $LOG_DEBUG)
                        
                        If $bSaveMissed > 0 Then _ArrayAdd($aOutput, "-" & $aCatching[$iCurrent][$CATCH_NAME]

                        _ArrayDelete($aCatching, $iCurrent)
                        $iCatchingSize -= 1

                        $iCurrent = -1
                    EndIf

                    ExitLoop
                EndIf
                
                ; Handle check for regular rares after exotic
                Local $aCheckAstromon = findImage("catch-guided-rare", 70, 0, 183, 0, 626-183, 222)
                Local $bCheckAstromon = (isArray($aCheckAstromon) = True And $bCheckNormalRare = True)
                If $iCatchingSize = 0 And $bCheckAstromon = False Then ExitLoop

                clickPoint(getPointArg("battle-catch"), 2, 100)
                If _Sleep(200) Then ExitLoop
                
                If isPixel(getPixelArg("catch-mode-unavailable"), 20, CaptureRegion()) = True Then ExitLoop
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

    If $bSaveMissed > 0 And $iCatchingSize > 0 Then
        For $i = 0 To $iCatchingSize - 1
            _ArrayAdd($aOutput, "-" & $aCatching[$i][$CATCH_NAME])
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