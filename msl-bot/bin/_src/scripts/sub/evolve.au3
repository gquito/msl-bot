#cs 
    Function: Script will evolve an astromon to evo3.
    Parameters:
        $sAstromon: The name of the astromon to evo3.
        $bForceEvolve: Even if there are not enough astromons, algorithm will try to evolve as many evo2 as possible.
            - Note: It will not awaken if it cannot evo2.
    Precondition: Pixel must exist in $g_aPixels: evolve-[astromon]
    Returns: 
        - Number of astromons required for the evo3.
            - 0 If successful.
    Error Codes:
        -1: Could not navigate to monsters
        -2: Could not get into evolution screen
        -3: Could go from evolution to monsters screen.
        -4: Could not select an astromon.
        -5: Not enough currency.
        -6: Could not evo3.
#ce
Func evolve($sAstromon, $bForceEvolve = False)
    ;Declaring variables/constants
    Local Const $aOffset = [69, 75] ;Offset between each astromon
    Local Const $aStart = [50, 130] ;First astromon on the grid view

    Local $aAstromons[5][4] ; => '1.#': evo1, '2.#': evo2, '3.0': evo3, '0':Not a valid astromon. (.# represents number of awakens, does not count awakens on evo1 slimes unless 3 slimes)
    Local $iRaw = 0 ;Number of astromons (worth evo1, EX. evo2 = 4)
    Local $iEvo1 = 0 ;Number of evo1 astromons
    Local $iNeedEvo2 = 4 ;Number of evo2 to make

    ;Navigate for 3 attempts
    For $i = 1 To 3
        If navigate("monsters", True) = True Then
            ExitLoop
        EndIf
    Next

    ;exit early if could not navigate
    If getLocation() <> "monsters" Then Return -1

    ;Scan the 20 astromons in the current view.
    addLog($g_aLog, "Counting current astromons.", $LOG_NORMAL)
    For $iRow = 0 To 4
        For $iCol = 0 To 3
            Local $t_aPoint = [$aStart[0]+($aOffset[0]*$iCol), $aStart[1]+($aOffset[1]*$iRow)]
            clickPoint($t_aPoint, 2, 100, Null)
            If _Sleep(100) Then Return -1

            CaptureRegion()
            If isPixel(getArg($g_aPixels, "evolve-" & StringLower($sAstromon)), 5) = True Then
                Local $t_iEvolution = _getEvolution()
                If $t_iEvolution = 3 Then $t_iEvolution = 0

                $aAstromons[$iRow][$iCol] = $t_iEvolution
                If ($t_iEvolution <> 0) And ($t_iEvolution <> 3) Then $iRaw += 1 + ($t_iEvolution-1)*3
                If $t_iEvolution = 1 Then $iEvo1 += 1
                If $iRaw > 16 Then ExitLoop(2)
            Else
                $aAstromons[$iRow][$iCol] = 0
            EndIf
        Next
    Next

    ;Counting the awakens
    Local $t_hTimer = TimerInit()
    While getLocation() <> "monsters-evolution"
        If TimerDiff($t_hTimer) > 20000 Then
            addLog($g_aLog, "Could not go into evolution screen.", $LOG_ERROR)
            Return -2
        EndIf

        If getLocation($g_aLocations, False) <> "monsters" Then navigate("monsters")
        clickPoint(getArg($g_aPoints, "monsters-evolution"), 3, 50, Null)

        If _Sleep(200) Then Return -1
    WEnd

    For $iRow = 0 To 4
        For $iCol = 0 To 3
            If ($aAstromons[$iRow][$iCol] <> 0) And ($aAstromons[$iRow][$iCol] <> "") Then
                Local $t_aPoint = [$aStart[0]+($aOffset[0]*$iCol), $aStart[1]+($aOffset[1]*$iRow)]
                clickPoint($t_aPoint, 2, 100, Null)
                If _Sleep(100) Then Return -1

                CaptureRegion()
                Local $t_iAwaken = _getAwaken()
                If ($aAstromons[$iRow][$iCol] = 1) And ($t_iAwaken <> 3) Then $t_iAwaken = 0
                If $aAstromons[$iRow][$iCol] = 2 Then $iNeedEvo2 -= 1+$t_iAwaken
                
                $iRaw += $t_iAwaken*(1 + ($aAstromons[$iRow][$iCol]-1)*3)
                $aAstromons[$iRow][$iCol] &= "." & $t_iAwaken
            EndIf
        Next
    Next
    
    addLog($g_aLog, "# Raw astromons: " & $iRaw, $LOG_NORMAL)
    If $iRaw < 16 Then ;Exit early if not enough astromons.
        addLog($g_aLog, "Not enough astromons to evolve to evo3.")
        If $bForceEvolve = True Then 
            $iNeedEvo2 = Int($iEvo1 / 4)
            If $iNeedEvo2 = 0 Then
                Return 16-$iRaw
            EndIf
        Else
            Return 16-$iRaw
        EndIf
    Else
        $bForceEvolve = False
    EndIf

    ;Beginning actual evolving
    Local $iError = 0 ;Counts amounts of errors until deciding to stop. (Used for awaken and evolve process)

    addLog($g_aLog, "Evolving " & $iNeedEvo2 & " astromons to evo2.")
    While $iNeedEvo2 > 0
        ;Finding next evo1 slime
        Local $t_hTimer = TimerInit()
        While getLocation() <> "monsters"
            If getLocation($g_aLocations, False) = "monsters-astromon" Then closeWindow()
            If TimerDiff($t_hTimer) > 20000 Then
                addLog($g_aLog, "Could not go into monsters screen.", $LOG_ERROR)
                Return -3
            EndIf

            clickPoint(getArg($g_aPoints, "monsters-evolution-x"), 3, 50, Null)
            If _Sleep(200) Then Return -1

            If getLocation($g_aLocations, False) <> "monsters-evolution" Then navigate("monsters")
        WEnd

        ;Attempts to search for an astromon to evo2 for 1 minute
        Local $bFound = False

        ;---Check for evo1 with 3 awakens
            For $iRow = 0 To 4
                For $iCol = 0 To 3
                    If ($aAstromons[$iRow][$iCol] = "1.3") Then
                        addLog($g_aLog, "Evolving all evo1 with 3 awakens")
                        Local $t_aPoint = [$aStart[0]+($aOffset[0]*$iCol), $aStart[1]+($aOffset[1]*$iRow)]
                        clickPoint($t_aPoint, 2, 100, Null)
                        If _Sleep(100) Then Return -1

                        $aAstromons[$iRow][$iCol] = "2.0"
                        $bFound = True
                        ExitLoop(2)
                    EndIf
                Next
            Next
        ;---

        Local $t_hTimer = TimerInit()
        While $bFound = False
            addLog($g_aLog, "Looking for evo1 astromon.", $LOG_NORMAL)
            For $iRow = 0 To 4
                For $iCol = 0 To 3
                    Local $t_aPoint = [$aStart[0]+($aOffset[0]*$iCol), $aStart[1]+($aOffset[1]*$iRow)]
                    clickPoint($t_aPoint, 2, 100, Null)
                    If _Sleep(100) Then Return -1

                    CaptureRegion()
                    If isPixel(getArg($g_aPixels, "evolve-" & StringLower($sAstromon))) = True Then
                        If _getEvolution() = 1 Then
                            $bFound = True
                            ExitLoop(2)
                        EndIf
                    EndIf
                Next
            Next

            If $bFound = False Then ;resets positions
                navigate("village", False, False)
                navigate("monsters", False, False)
            EndIf

            If TimerDiff($t_hTimer) > 60000 Then
                addLog($g_aLog, "Could not select an astromon.", $LOG_ERROR)
                Return -4
            EndIf
        WEnd

        ;Evolving to evo2
        Local $t_hTimer = TimerInit()
        While getLocation() <> "monsters-evolution"
            If TimerDiff($t_hTimer) > 20000 Then
                addLog($g_aLog, "Could not go into evolution screen.", $LOG_ERROR)
                Return -2
            EndIf

            If getLocation($g_aLocations, False) <> "monsters" Then 
                navigate("monsters")
                ContinueLoop(2)
            EndIf

            clickPoint(getArg($g_aPoints, "monsters-evolution"), 3, 50, Null)
            If _Sleep(200) Then Return -1
        WEnd

        If _awaken() = True Then
            ;Handle merging errors:
            Switch _merge()
                Case 1 ;success
                    $iNeedEvo2 -= 1
                Case 0 ;fail
                    $iError += 1
                    navigate("village", False, False)
                Case -1 ;no gold
                    addLog($g_aLog, "Not enough gold.", $LOG_ERROR)
                    Return -5
            EndSwitch
        Else
            $iError += 1
            navigate("village", False, False)
        EndIf

        If _Sleep(10) Then Return -1
        If $iNeedEvo2 > 0 Then collectQuest()
    WEnd

    ;Evolve to evolution 3
    Local $bSuccess = False
    Local $hTimer = TimerInit()
    While ($bSuccess = False) And ($bForceEvolve = False)
        If _Sleep(10) Then Return -1
        If TimerDiff($hTimer) > 60000 Then
            addLog($g_aLog, "Could not evolve to evo3.", $LOG_ERROR)
            collectQuest()
            Return -6
        EndIf

        ;Finding astromon
        Local $t_hTimer = TimerInit()
        While getLocation() <> "monsters"
            If getLocation($g_aLocations, False) = "monsters-astromon" Then closeWindow()
            If TimerDiff($t_hTimer) > 20000 Then
                addLog($g_aLog, "Could not go into monsters screen.", $LOG_ERROR)
                Return -3
            EndIf

            clickPoint(getArg($g_aPoints, "monsters-evolution-x"), 3, 50, Null)
            If _Sleep(200) Then Return -1

            If getLocation($g_aLocations, False) <> "monsters-evolution" Then navigate("monsters")
        WEnd

        ;Attempts to search for an astromon to evo3 for 1 minute
        Local $bFound = False

        Local $t_hTimer = TimerInit()
        While $bFound = False
            addLog($g_aLog, "Looking for evo2 astromon.", $LOG_NORMAL)
            For $iRow = 2 To 0 Step -1
                For $iCol = 3 To 0 Step -1
                    Local $t_aPoint = [$aStart[0]+($aOffset[0]*$iCol), $aStart[1]+($aOffset[1]*$iRow)]
                    clickPoint($t_aPoint, 2, 100, Null)
                    If _Sleep(100) Then Return -1

                    CaptureRegion()
                    If isPixel(getArg($g_aPixels, "evolve-" & StringLower($sAstromon))) = True Then
                        If _getEvolution() = 2 Then
                            $bFound = True
                            ExitLoop(2)
                        EndIf
                    EndIf
                Next
            Next

            If $bFound = False Then ;resets positions
                navigate("village", False, False)
                navigate("monsters", False, False)
            EndIf

            If TimerDiff($t_hTimer) > 60000 Then
                addLog($g_aLog, "Could not select an astromon.", $LOG_ERROR)
                Return -4
            EndIf
        WEnd

        ;Evolving to evo3
        Local $t_hTimer = TimerInit()
        While getLocation() <> "monsters-evolution"
            If TimerDiff($t_hTimer) > 20000 Then
                addLog($g_aLog, "Could not go into evolution screen.", $LOG_ERROR)
                Return -2
            EndIf

            If getLocation($g_aLocations, False) <> "monsters" Then 
                navigate("monsters")
                ContinueLoop(2)
            EndIf

            clickPoint(getArg($g_aPoints, "monsters-evolution"), 3, 50, Null)
            If _Sleep(200) Then Return -1
        WEnd

        If _awaken() = True Then
            ;Handle merging errors:
            Switch _merge()
                Case 1 ;success
                    $bSuccess = True
                Case 0 ;fail
                    $iError += 1
                    navigate("village", False, False)
                Case -1 ;no gold.
                    addLog($g_aLog, "Not enough gold.", $LOG_ERROR)
                    Return -5
            EndSwitch
        Else
            $iError += 1
            navigate("village", False, False)
        EndIf

        If _Sleep(10) Then Return -1
    WEnd

    ;Release and collect quest
    If $bForceEvolve = False Then
        addLog($g_aLog, "Evolve to evo3 complete, cleaning up.", $LOG_NORMAL)

        Local $t_hTimer = TimerInit()
        While getLocation() <> "monsters"
            If getLocation($g_aLocations, False) = "monsters-astromon" Then closeWindow()
            If TimerDiff($t_hTimer) > 20000 Then
                addLog($g_aLog, "Could not go into monsters screen.", $LOG_ERROR)
                ExitLoop
            EndIf

            clickPoint(getArg($g_aPoints, "monsters-evolution-x"), 3, 50, Null)
            If _Sleep(200) Then Return -1

            If getLocation($g_aLocations, False) <> "monsters-evolution" Then navigate("monsters")
        WEnd

        If getLocation() = "monsters" Then 
            ;Releasing evo3 astromon.
            clickPoint($aStart, 2, 100, Null)

            If _Sleep(100) Then Return -1
            CaptureRegion()

            If _getEvolution() = 3 Then
                clickUntil("776,110", "isLocation", "monsters", 5, 100)
                If clickWhile("649, 513", "isLocation", "monsters,monsters-evolution", 10, 100) = True Then
                    clickPoint("311, 331", 20, 200)
                EndIf
            EndIf
        Else
            addLog($g_aLog, "Could not clean up.")
        EndIf
    EndIf

    collectQuest()
    Return 0
EndFunc

#cs
    Function: In monsters-evolution location, will select the three astromons to fulfill a complete evolution. Note: Will not merge astromons, just select; this is handled in _merge() function.
    Returns: If successfully selected then returns true; otherwise, returns false.
#ce
Func _awaken()
    Local $t_hTimer = TimerInit()
    While isPixel(getArg($g_aPixels, "not-fully-awakened"), 20) = True
        For $x = 0 To 6
            If TimerDiff($t_hTimer) > 30000 Then Return False

            ;click the astromons
            If getLocation() = "monsters-evolution" Then clickPoint(351+($x*65) & ",330", 1, 0, Null) ;astromon
            If _Sleep(100) Then Return False

            ;conditions for when selected locked astromon or already awakened astromon
            If getLocation() <> "monsters-evolution" Then 
                ;Will cancel locked astromon and forcefully awaken already awakened astromons.
                clickPoint(getArg($g_aPoints, "awaken-locked-cancel"), 1, 0, Null)
                $x -= 1
            EndIf
        Next
    WEnd

    Return Not(isPixel(getArg($g_aPixels, "not-fully-awakened"), 20))
EndFunc

#cs 
    Func: Completes awaken and evolve process. Assumes the 3 astromons are selected using _awaken function.
    Return: 1 for success, 0 for fail
    Error Codes:
        -1: Not enough currency.
#ce
Func _merge()
    Local $t_hTimer = TimerInit()
    While getLocation() = "monsters-evolution"
        If _Sleep(10) Then Return False
        If TimerDiff($t_hTimer) > 60000 Then Return False
        Switch getLocation($g_aLocations, False)
            Case "buy-gold", "buy-gem"
                Return -1
        EndSwitch

        If isPixel("425,394,0xF5E448", 10) = True Then ;The awaken pixel
            If clickUntil("425,395", "isLocation", "monsters-awaken", 10, 100) = True Then
                clickPoint("303,312", 10, 200) ;awaken/evolve confirm
            EndIf
        Else
            If isPixel("657,395,0xEBC83D", 10) = True Then
                If clickUntil("656,394", "isLocation", "monsters-evolve", 10, 100) = True Then
                    If clickUntil("303,312", "isLocation", "unknown", 10, 200) Then ;awaken/evolve confirm
                        clickUntil(getArg($g_aPoints, "tap"), "isLocation", "monsters-astromon", 20, 500)
                    EndIf 
                EndIf
            EndIf
        EndIf
    WEnd

    Return True
EndFunc

;Function will return evolution of astromon in monsters screen.
Func _getEvolution()
    If isPixel("356,129,0xD9D5D0", 10) = True Then
        Return 2
    ElseIf isPixel("360,129,0xDDD9D4", 10) = True Then
        Return 3
    Else
        Return 1
    EndIf
EndFunc

;Function will return number of awakens in monsters-evolution screen.
Func _getAwaken()
    If isPixel("367,210,0x17FBF8", 10) = True Then
        Return 3
    ElseIf isPixel("363,210,0x14FEF8", 10) = True Then
        Return 2
    ElseIf isPixel("359,210,0x15FCF8", 10) = True Then
        Return 1
    Else
        Return 0
    EndIf
EndFunc