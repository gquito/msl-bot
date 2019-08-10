#include-once
#include "../../imports.au3"

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
        -7: Unknown
#ce
Func evolve1($sAstromon, $bForceEvolve = False, $bReleaseEvo3 = True)
    Log_Level_Add("evolve")
    Log_Add("Evolving astromon using algorithm 1.")

    Local $iOutput = -1
    While True
        ;Declaring variables/constants
        Local Const $aOffset = [69, 75] ;Offset between each astromon
        Local Const $aStart = [50, 130] ;First astromon on the grid view

        Local $aAstromons[5][4] ; => '1.#': evo1, '2.#': evo2, '3.0': evo3, '0':Not a valid astromon. (.# represents number of awakens, does not count awakens on evo1 slimes unless 3 slimes)
        Local $iRaw = 0 ;Number of astromons (worth evo1, EX. evo2 = 4)
        Local $iEvo1 = 0 ;Number of evo1 astromons
        Local $iNeedEvo2 = 4 ;Number of evo2 to make

        ;Navigate for 3 attempts

        ;exit early if could not navigate
        If (Not(navigate("monsters", True, 3))) Then 
            Log_Add("Could not navigate to monsters location.", $LOG_ERROR)
            $iOutput = -1
            ExitLoop
        EndIf

        ;Scan the 20 astromons in the current view.
        Log_Add("Counting current astromons.")
        For $iRow = 0 To 4
            For $iCol = 0 To 3
                Local $t_aPoint = [$aStart[0]+($aOffset[0]*$iCol), $aStart[1]+($aOffset[1]*$iRow)]
                clickPoint($t_aPoint, 2, 100)
                If (_Sleep(100)) Then ExitLoop(3)

                CaptureRegion()

                If (isPixel(getPixelArg("evolve-" & StringLower($sAstromon)), 5)) Then
                    Local $t_iEvolution = _getEvolution()
                    If ($t_iEvolution = 3) Then $t_iEvolution = 0

                    $aAstromons[$iRow][$iCol] = $t_iEvolution
                    If ($t_iEvolution <> 0) And ($t_iEvolution <> 3) Then $iRaw += 1 + ($t_iEvolution-1)*3
                    If ($t_iEvolution = 1) Then $iEvo1 += 1
                    If ($iRaw > 16) Then ExitLoop(2)
                Else
                    $aAstromons[$iRow][$iCol] = 0
                EndIf
            Next
        Next

        ;Counting the awakens
        Local $t_hTimer = TimerInit()
        While Not(isLocation("monsters-evolution"))
            If (TimerDiff($t_hTimer) > 20000) Then
                Log_Add("Could not go into evolution screen.", $LOG_ERROR)
                $iOutput = -2
                ExitLoop(2)
            EndIf

            If (Not(isLocation("monsters"))) Then navigate("monsters")

            clickPoint(getPointArg("monsters-evolution"), 3, 50)

            If _Sleep(200) Then ExitLoop(2)
        WEnd

        For $iRow = 0 To 4
            For $iCol = 0 To 3
                If ($aAstromons[$iRow][$iCol] <> 0 And $aAstromons[$iRow][$iCol] <> "") Then
                    Local $t_aPoint = [$aStart[0]+($aOffset[0]*$iCol), $aStart[1]+($aOffset[1]*$iRow)]
                    clickPoint($t_aPoint, 2, 100)
                    If (_Sleep(100)) Then ExitLoop(3)

                    CaptureRegion()
                    Local $t_iAwaken = _getAwaken()
                    If ($aAstromons[$iRow][$iCol] = 1 And $t_iAwaken <> 3) Then $t_iAwaken = 0
                    If ($aAstromons[$iRow][$iCol] = 2) Then $iNeedEvo2 -= 1+$t_iAwaken
                    
                    $iRaw += $t_iAwaken*(1 + ($aAstromons[$iRow][$iCol]-1)*3)
                    $aAstromons[$iRow][$iCol] &= "." & $t_iAwaken
                EndIf
            Next
        Next
        
        Log_Add("# Raw astromons: " & $iRaw, $LOG_INFORMATION)
        If ($iRaw < 16) Then ;Exit early if not enough astromons.
            Log_Add("Not enough astromons to evolve to evo3.")
            If ($bForceEvolve) Then 
                $iNeedEvo2 = Int($iEvo1 / 4)
                If ($iNeedEvo2 = 0) Then
                    $iOutput = 16-$iRaw
                    ExitLoop
                EndIf
            Else
                $iOutput = 16-$iRaw
                ExitLoop
            EndIf
        Else
            $bForceEvolve = False
        EndIf

        ;Beginning actual evolving
        Local $iError = 0 ;Counts amounts of errors until deciding to stop. (Used for awaken and evolve process)

        Log_Add("Evolving " & $iNeedEvo2 & " astromons to evo2.")
        While $iNeedEvo2 > 0
            ;Finding next evo1 slime
            Local $t_hTimer = TimerInit()
            While Not(isLocation("monsters"))
                If (isLocation("monsters-astromon")) Then closeWindow()
                If (TimerDiff($t_hTimer) > 20000) Then
                    Log_Add("Could not go into monsters screen.", $LOG_ERROR)
                    $iOutput = -3
                    ExitLoop(3)
                EndIf

                clickPoint(getPointArg("monsters-evolution-x"), 3, 50)
                If (_Sleep(200)) Then ExitLoop(3)

                If (Not(isLocation("monsters-evolution"))) Then navigate("monsters")
            WEnd

            ;Attempts to search for an astromon to evo2 for 1 minute
            Local $bFound = False

            ;---Check for evo1 with 3 awakens
            For $iRow = 0 To 4
                For $iCol = 0 To 3
                    If ($aAstromons[$iRow][$iCol] = "1.3") Then
                        Local $t_aPoint = [$aStart[0]+($aOffset[0]*$iCol), $aStart[1]+($aOffset[1]*$iRow)]
                        clickPoint($t_aPoint, 2, 100)
                        If (_Sleep(100)) Then ExitLoop(4)

                        $aAstromons[$iRow][$iCol] = "2.0"
                        $bFound = True
                        ExitLoop(3)
                    EndIf
                Next
            Next
            ;---

            Local $t_hTimer = TimerInit()
            While $bFound = False
                Log_Add("Looking for evo1 astromon.")
                For $iRow = 0 To 4
                    For $iCol = 0 To 3
                        Local $t_aPoint = [$aStart[0]+($aOffset[0]*$iCol), $aStart[1]+($aOffset[1]*$iRow)]
                        clickPoint($t_aPoint, 2, 100)
                        If (_Sleep(100)) Then ExitLoop(5)

                        CaptureRegion()
                        If (isPixel(getPixelArg("evolve-" & StringLower($sAstromon)))) Then
                            If (_getEvolution() = 1) Then
                                $bFound = True
                                ExitLoop(2)
                            EndIf
                        EndIf
                    Next
                Next

                If (Not($bFound)) Then ;resets positions
                    navigate("village")
                    navigate("monsters")
                EndIf

                If (TimerDiff($t_hTimer) > 60000) Then
                    Log_Add("Could not select an astromon.", $LOG_ERROR)
                    $iOutput = -4
                    ExitLoop(3)
                EndIf
            WEnd

            ;Evolving to evo2
            Local $t_hTimer = TimerInit()
            While Not(isLocation("monsters-evolution"))
                If (TimerDiff($t_hTimer) > 20000) Then
                    Log_Add("Could not go into evolution screen.", $LOG_ERROR)
                    $iOutput = -2
                    ExitLoop(3)
                EndIf

                If (Not(isLocation("monsters"))) Then 
                    navigate("monsters")
                    ContinueLoop(2)
                EndIf

                clickPoint(getPointArg("monsters-evolution"), 3, 50)
                If (_Sleep(200)) Then ExitLoop(3)
            WEnd

            If (_awaken()) Then
                ;Handle merging errors:
                Switch _merge()
                    Case 1 ;success
                        $iNeedEvo2 -= 1
                    Case 0 ;fail
                        $iError += 1
                        navigate("village")
                    Case -1 ;no gold
                        Log_Add("Not enough gold.", $LOG_ERROR)
                        $iOutput = -5
                        ExitLoop(2)
                EndSwitch
            Else
                $iError += 1
                navigate("village")
            EndIf

            If (_Sleep(10)) Then ExitLoop(2)
            If ($iNeedEvo2 > 0) Then collectQuest()
        WEnd

        ;Evolve to evolution 3
        Local $bSuccess = False
        Local $hTimer = TimerInit()
        While (Not($bSuccess)) And (Not($bForceEvolve))
            If (_Sleep(10)) Then ExitLoop(2)
            If (TimerDiff($hTimer) > 60000) Then
                Log_Add("Could not evolve to evo3.", $LOG_ERROR)
                collectQuest()
                $iOutput = -6
                ExitLoop(2)
            EndIf

            ;Finding astromon
            Local $t_hTimer = TimerInit()
            While Not(isLocation("monsters"))
                If (isLocation("monsters-astromon")) Then closeWindow()
                If (TimerDiff($t_hTimer) > 20000) Then
                    Log_Add("Could not go into monsters screen.", $LOG_ERROR)
                    $iOutput = -3
                    ExitLoop(3)
                EndIf

                clickPoint(getPointArg("monsters-evolution-x"), 3, 50)

                If (_Sleep(200)) Then ExitLoop(3)

                If (Not(isLocation("monsters-evolution"))) Then navigate("monsters")
            WEnd

            ;Attempts to search for an astromon to evo3 for 1 minute
            Local $bFound = False

            Local $t_hTimer = TimerInit()
            While $bFound = False
                Log_Add("Looking for evo2 astromon.")
                For $iRow = 2 To 0 Step -1
                    For $iCol = 3 To 0 Step -1
                        Local $t_aPoint = [$aStart[0]+($aOffset[0]*$iCol), $aStart[1]+($aOffset[1]*$iRow)]
                        clickPoint($t_aPoint, 2, 100)
                        If (_Sleep(100)) Then ExitLoop(5)

                        CaptureRegion()
                        If (isPixel(getPixelArg("evolve-" & StringLower($sAstromon)))) Then
                            If (_getEvolution() = 2) Then
                                $bFound = True
                                ExitLoop(2)
                            EndIf
                        EndIf
                    Next
                Next

                If (Not($bFound)) Then ;resets positions
                    navigate("village")
                    navigate("monsters")
                EndIf

                If (TimerDiff($t_hTimer) > 60000) Then
                    Log_Add("Could not select an astromon.", $LOG_ERROR)
                    $iOutput = -4
                    ExitLoop(3)
                EndIf
            WEnd

            ;Evolving to evo3
            Local $t_hTimer = TimerInit()
            While Not(isLocation("monsters-evolution"))
                If (TimerDiff($t_hTimer) > 20000) Then
                    Log_Add("Could not go into evolution screen.", $LOG_ERROR)
                    $iOutput = -2
                    ExitLoop(3)
                EndIf

                If (Not(isLocation("monsters"))) Then 
                    navigate("monsters")
                    ContinueLoop(2)
                EndIf

                clickPoint(getPointArg("monsters-evolution"), 3, 50)
                If (_Sleep(200)) Then ExitLoop(3)
            WEnd

            If (_awaken()) Then
                ;Handle merging errors:
                Switch _merge()
                    Case 1 ;success
                        $bSuccess = True
                    Case 0 ;fail
                        $iError += 1
                        navigate("village")
                    Case -1 ;no gold.
                        Log_Add("Not enough gold.", $LOG_ERROR)
                        $iOutput = -5
                        ExitLoop(2)
                EndSwitch
            Else
                $iError += 1
                navigate("village")
            EndIf

            If (_Sleep(10)) Then ExitLoop(2)
        WEnd

        ;Release and collect quest
        If (Not($bForceEvolve)) Then
            Log_Add("Evolve to evo3 complete, cleaning up.", $LOG_INFORMATION)

            Local $t_hTimer = TimerInit()
            While Not(isLocation("monsters"))
                If (isLocation("monsters-astromon")) Then closeWindow()
                If (TimerDiff($t_hTimer) > 20000) Then
                    Log_Add("Could not go into monsters screen.", $LOG_ERROR)
                    ExitLoop
                EndIf

                clickPoint(getPointArg("monsters-evolution-x"), 3, 50)
                If (_Sleep(200)) Then ExitLoop(2)

                If (Not(isLocation("monsters-evolution"))) Then navigate("monsters")
            WEnd

            If (isLocation("monsters")) Then 
                If ($bReleaseEvo3) Then
                    ;Releasing evo3 astromon.
                    clickPoint($aStart, 2, 100)

                    If (_Sleep(100)) Then ExitLoop
                    CaptureRegion()

                    If (_getEvolution() = 3) Then
                        If (isPixel("399,129,0xE1BC87", 20)) Then
                            clickUntil("776,110", "isLocation", "monsters", 5, 100)
                            If (clickWhile(getPointArg("release"), "isLocation", "monsters,monsters-evolution", 10, 100)) Then clickPoint(getPointArg("release-confirm"), 20, 200)
                        EndIf
                    EndIf
                EndIf
            Else
                Log_Add("Could not clean up.")
            EndIf
        EndIf
        collectQuest()

        $iOutput = 0
        ExitLoop
    WEnd

    Log_Add("Evolving astromon using algorithm 1 result: " & $iOutput, $LOG_DEBUG)
    Log_Level_Remove()
    Return $iOutput
EndFunc

;************************************************************************************************************************************************************
;************************************************************************************************************************************************************
;************************************************************************************************************************************************************
;************************************************************************************************************************************************************
;************************************************************************************************************************************************************
;************************************************************************************************************************************************************
;************************************************************************************************************************************************************
;************************************************************************************************************************************************************

Func evolve2($bReleaseEvo3 = True)
    Log_Level_Add("evolve")
    Log_Add("Evolving astromon using algorithm 2.")

    Local $aOut = [-1, ""]
    While True
        ;Defining variables
        Local Const $aStart = [44, 149]     ; Starting position of first astromon on the grid.
        Local Const $aDiff = [69, 75]       ; Pixel count difference between each astromon in grid.

        Local $iEvo1 = 0 ; Number of Evo1 slimes.
        Local $iEvo2 = 0 ; Numerb of Evo2 slimes.

        $g_bLogEnabled = False
        If (Not(navigate("monsters", True, 3))) Then
            $aOut[1] = "Could not navigate to monsters."
            ExitLoop
        EndIf
        $g_bLogEnabled = True

        ; If Evo2 slimes is insufficient for evo3, tries to use evo1 slimes. 
        ; Uses 4 evo1 slimes at a time. If there are no more evo1 slimes and we still
        ; need evo2 slimes, it will return number of evo1 slimes needed for farming.
        alignMonsters()
        $iEvo2 = countEvo2Slime()
        Log_Add("Evo2 Count: " & $iEvo2)

        If ($iEvo2 < 4) Then
            Log_Add("Not enough evo2 to make an evo3.")

            While (4-$iEvo2) > 0
                Log_Add("Number of evo2 needed: " & (4-$iEvo2))

                $g_bLogEnabled = False
                If (Not(navigate("monsters", True, 3))) Then
                    $aOut[1] = "Could not navigate to monsters."
                    ExitLoop
                EndIf
                $g_bLogEnabled = True

                alignMonsters()
                $iEvo1 = countEvo1Slime()

                If ($iEvo1 >= 4) Then
                    Log_Add("Evolving evo1 astromon.")

                    clickPoint($aStart[0]+($aDiff[0]*$g_iExtended[0]) & "," & $aStart[1]+($aDiff[1]*$g_iExtended[1]), 3, 50)
                    clickUntil(getPointArg("monsters-evolution"), "isLocation", "monsters-evolution", 5, 500)

                    If (_awaken()) Then
                        Local $iMergeResult = _merge()
                        If ($iMergeResult = 1) Then       ; Success
                            $iEvo2 += 1
                        ElseIf ($iMergeResult = 0) Then   ; Failure
                            $g_bLogEnabled = False
                            navigate("monsters", True, 2)
                            $g_bLogEnabled = True
                        Else                            ; No Gold
                            $aOut[0] = -2
                            $aOut[1] = "Not enough gold."
                            ExitLoop(2)
                        EndIf
                    Else
                        $g_bLogEnabled = False
                        navigate("monsters", True, 2)
                        $g_bLogEnabled = True
                    EndIf

                Else
                    ; Returning number of evo1 needed
                    $aOut[0] = 4*(4-$iEvo2) - $iEvo1
                    Log_Add("Need " & $aOut[0] & " astromons for an evo3.")
                    ExitLoop(2)
                EndIf

                If (_Sleep(0)) Then ExitLoop(2)
                If ((4-$iEvo2) > 0) Then 
                    Log_Add("Collecting quest rewards.")
                    $g_bLogEnabled = False
                    collectQuest()
                    $g_bLogEnabled = True
                EndIf
            WEnd
        EndIf

        ; Assuming all is well, the user should have at least 4 evo2 here.
        ; Bot will awaken and evolve the evo2s into an evo3 and proceed to release the evo3.
        Log_Add("Evolving astromons to evo3.")

        $g_bLogEnabled = False
        If (Not(navigate("monsters", True, 3))) Then
            $aOut[1] = "Could not navigate to monsters."
            ExitLoop
        EndIf
        $g_bLogEnabled = True

        alignMonsters()
        $iEvo2 = countEvo2Slime()

        If ($iEvo2 < 4) Then
            $aOut[1] = "Not enough evo2 astromons to make an evo3."
            ExitLoop
        EndIf

        ; g_iExtended should have an array of a single astromon position from the countEvo2Slime() function.
        ; Using that we can select the correct astromon to evo3.
        clickPoint($aStart[0]+($aDiff[0]*$g_iExtended[0]) & "," & $aStart[1]+($aDiff[1]*$g_iExtended[1]), 3, 50)
        clickUntil(getPointArg("monsters-evolution"), "isLocation", "monsters-evolution", 5, 500)

        If (_awaken()) Then
            Local $iMergeResult = _merge()
            If ($iMergeResult = 1) Then       ; Success
                $aOut[0] = 0
                $aOut[1] = "Successfully evolved astromon to evo3."
            ElseIf ($iMergeResult = 0) Then   ; Failure
                $aOut[1] = "Could not evolve astromons to evo3."
                ExitLoop
            Else                            ; No Gold
                $aOut[0] = -2
                $aOut[1] = "Not enough gold."
                ExitLoop
            EndIf
        Else
            $g_bLogEnabled = False
            navigate("monsters", True, 2)
            $g_bLogEnabled = True
        EndIf

        ; Assuming all is well, this section should only trigger when successfully evolved an evo3.
        ; Release and collect quest.
        Log_Add("Cleaning up evo3 slime.")
        $g_bLogEnabled = False
        navigate("monsters", True, 3)
        $g_bLogEnabled = True
        
        If (_getEvolution() = 3 And $bReleaseEvo3) Then
            If (isPixel("399,129,0xE1BC87", 20)) Then
                clickUntil("776,110", "isLocation", "monsters", 5, 100)
                If (clickWhile(getPointArg("release"), "isLocation", "monsters,monsters-evolution", 10, 100)) Then clickPoint(getPointArg("release-confirm"), 20, 200)
            EndIf
        EndIf

        Log_Add("Collecting quest rewards.")
        $g_bLogEnabled = False
        collectQuest()
        $g_bLogEnabled = True

        ExitLoop
    WEnd

    Log_Add("Evolving astromon using algorithm 2 result: " & $aOut[0], $LOG_DEBUG)
    Log_Level_Remove()
    Return $aOut
EndFunc

;************************************************************************************************************************************************************
;************************************************************************************************************************************************************
;************************************************************************************************************************************************************
;************************************************************************************************************************************************************
;************************************************************************************************************************************************************
;************************************************************************************************************************************************************
;************************************************************************************************************************************************************
;************************************************************************************************************************************************************

;uses imagesearch for slime farming.
Func evolve3($sAstromon = "slime", $iTolerance = 85, $bReleaseEvo3 = True)
    Log_Level_Add("evolve3(" & $sAstromon & ", " & $iTolerance & ", " & $bReleaseEvo3 & ")")
    Log_Add("Evolving astromon using algorithm 3. ReleaseEvo3: " & $bReleaseEvo3)

    Local $aOut = [-1, ""]
    
    While True
        ;Defining variables
        Local $iEvo2 = 0 ; Numerb of Evo2 slimes.

        $g_bLogEnabled = False
        If (Not(navigate("monsters", True, 3))) Then
            $aOut[1] = "Could not navigate to monsters."
            ExitLoop
        EndIf
        $g_bLogEnabled = True
        
        clickPoint(getPointArg("monsters-recent"))
        If (_Sleep(300)) Then ExitLoop
        ; If Evo2 slimes is insufficient for evo3, tries to use evo1 slimes. 
        ; Uses 4 evo1 slimes at a time. If there are no more evo1 slimes and we still
        ; need evo2 slimes, it will return number of evo1 slimes needed for farming.
        $iEvo2 = countEvo2Mons($sAstromon, $iTolerance, True)
        Log_Add("Evo2 Count: " & $iEvo2)

        If ($iEvo2 <= 3) Then
            Log_Add("Not enough evo2 to make an evo3.")

            While (4-$iEvo2) > 0
                Log_Add("Number of evo2 needed: " & (4-$iEvo2))
                Local $evoResult = evolveEvo1Mons($sAstromon, $iTolerance, $iEvo2, $aOut)
                Switch $evoResult
                    Case -1, -2, -3
                        Exitloop(2)
                EndSwitch
            WEnd
        EndIf
            
        ; Assuming all is well, the user should have at least 4 evo2 here.
        ; Bot will awaken and evolve the evo2s into an evo3 and proceed to release the evo3.
        Local $evoResult = evolveEvo2Mons($sAstromon, $iTolerance, $aOut)
        Switch $evoResult
            Case -1, -2
                ExitLoop
            Case Else
                ; Assuming all is well, this section should only trigger when successfully evolved an evo3.
                ; Release and collect quest.
                Log_Add("Cleaning up evo3 slime.")
                navigate("monsters", True, 3)
                
                If (_getEvolution() = 3 And $bReleaseEvo3) Then
                    releaseAstromon()
                EndIf

                Log_Add("Collecting quest rewards.")
                collectQuest()
        EndSwitch

        ExitLoop
    WEnd

    Log_Add("Evolving astromon using algorithm 3 result: " & $aOut[0], $LOG_DEBUG)
    Log_Level_Remove()
    Return $aOut
EndFunc


Func releaseAstromon()
    Local $bOutput = False
    Log_Level_Add("releaseAstromon()")
    Local $hTimer = TimerInit()
    If IsLocation("monsters,monsters-evolution,monsters-level-up") = False Then 
        If navigate("monsters", True, 2) = False Then
            Log_Add("Unable to navigate to monsters")
            Log_Level_Remove()
            Return $bOutput
        EndIf
    EndIf

    If (isLocation("monsters,monsters-evolution,monsters-level-up") = True And _
        clickWhile(getPointArg("release"), "isLocation", "monsters,monsters-evolution,monsters-level-up", 5, 1000) = True) Then
        
        If (waitLocation("release-confirm", 2) = True And _
            clickWhile(getPointArg("release-confirm"), "isLocation", "release-confirm") = True) Then

            If (waitLocation("release-reward,hourly-reward", 5) = True And _
                clickWhile(getPointArg("release-confirm"), "isLocation", "release-reward,hourly-reward") = True) Then
                
                $bOutput = True
            EndIf
        EndIf
    EndIf
    
    Log_Add("releaseAstromon() result: " & $bOutput, $LOG_DEBUG)
    Log_Level_Remove()
    Return $bOutput
EndFunc
;Function will return evolution of astromon in monsters screen.
Func _getEvolution()
    Local $bOutput = 1
    Log_Level_Add("_getEvolution()")
    If (isPixel(getPixelArg("monsters-evolution-second"))) Then
        $bOutput = 2
    ElseIf (isPixel(getPixelArg("monsters-evolution-third"))) Then
        $bOutput = 3
    EndIf
    Log_Level_Remove()
    Return $bOutput
EndFunc

;Function will return number of awakens in monsters-evolution screen.
Func _getAwaken()
    If (Not(isPixel(getPixelArg("monsters-not-awakened-third")))) Then
        Return 3
    ElseIf (Not(isPixel(getPixelArg("monsters-not-awakened-second")))) Then
        Return 2
    ElseIf (Not(isPixel(getPixelArg("monsters-not-awakened-first")))) Then
        Return 1
    Else
        Return 0
    EndIf
EndFunc

;Only available for blue/green slimes
Func countEvo1Slime()
    Local $aFirst = [44, 145]   ; First pixel of the slime on the first astromon slot.
    Local $aSecond = [65, 146]  ; Second pixel of the slime on the first astromon slot.
    Local $aThird = [44, 147]   ; Third pixel of the slime on the first astromons slot.

    Local $iCount = 0           ; Number of astromons.
    Local $cPixel = 0xEAF7F7    ; Highlight color of the eyes of the slime
    Local $cPixel3 = 0x2E1D1D   ; A dark color under the highlights of the slime.

    Local $foundAwakened = False

    CaptureRegion()
    If (Not(StringInStr(getLocation(), "monsters"))) Then Return 0

    For $x = 0 To 3
        For $y = 0 To 3
            If (isPixel($aFirst[0]+(69*$x) & "," & $aFirst[1]+(75*$y) & "," & $cPixel, 30)) Then
                If (isPixel($aSecond[0]+(69*$x) & "," & $aSecond[1]+(75*$y) & "," & $cPixel, 30)) Then
                    If (isPixel($aThird[0]+(69*$x) & "," & $aThird[1]+(75*$y) & "," & $cPixel3, 30)) Then
                        If (isPixel("55,178,0x16FFFD", 30)) Then
                            $foundAwakened = True
                            $iCount += 3
                            
                            Local $aExt = [$x, $y]
                            $g_iExtended = $aExt 
                        EndIf
                        
                        If (Not($foundAwakened)) Then 
                            Local $aExt = [$x, $y]
                            $g_iExtended = $aExt   
                        EndIf

                        $iCount += 1
                    EndIf
                EndIf
            EndIf
        Next
    Next

    Return $iCount
EndFunc

Func countEvo2Slime()
    ; Blue slime pixel positions
    Local $aFirst = [44, 149]   ; First pixel of the slime on the first astromon slot.
    Local $aSecond = [65, 151]  ; Second pixel of the slime on the first astromon slot.
    Local $aThird = [44, 152]   ; Third pixel of the slime on the first astromon slot.

    ; Green slime pixel positions
    Local $aFourth = [46, 146]  ; First pixel of the slime on the first astromon slot.
    Local $aFifth = [65, 148]   ; Second pixel of the slime on the first astromon slot.
    Local $aSixth = [46, 149]   ; Third pixel of the slime on the first astromon slot.

    Local $iCount = 0           ; Number of astromons.
    Local $cPixel1 = 0xCBDCE8   ; Highlight for the blue slime eyes.
    Local $cPixel4 = 0xE9E9E9   ; Highlight for the green slime eyes.
    Local $cPixel3 = 0x463939   ; Black pixel under eyes of blue slimes.
    Local $cPixel6 = 0x453434   ; Black pixel under eyes of green slimes.

    Local $foundAwakened = False

    CaptureRegion()
    If (Not(StringInStr(getLocation(), "monsters"))) Then Return 0

    For $x = 0 To 3
        For $y = 0 To 3
            If (isPixel($aFirst[0]+(69*$x) & "," & $aFirst[1]+(75*$y) & "," & $cPixel1, 30)) Then
                If (isPixel($aSecond[0]+(69*$x) & "," & $aSecond[1]+(75*$y) & "," & $cPixel1, 30)) Then
                    If (isPixel($aThird[0]+(69*$x) & "," & $aThird[1]+(75*$y) & "," & $cPixel3, 30)) Then
                        If (isPixel("55,178,0x16FFFD", 30)) Then
                            $foundAwakened = True
                            $iCount += 3

                            Local $aExt = [$x, $y]
                            $g_iExtended = $aExt 
                        EndIf
                        
                        If (Not($foundAwakened)) Then 
                            Local $aExt = [$x, $y]
                            $g_iExtended = $aExt   
                        EndIf


                        $iCount += 1
                        ContinueLoop
                    EndIf
                EndIf
            EndIf

            If (isPixel($aFourth[0]+(69*$x) & "," & $aFourth[1]+(75*$y) & "," & $cPixel4, 30)) Then
                If (isPixel($aFifth[0]+(69*$x) & "," & $aFifth[1]+(75*$y) & "," & $cPixel4, 30)) Then
                    If (isPixel($aSixth[0]+(69*$x) & "," & $aSixth[1]+(75*$y) & "," & $cPixel6, 30)) Then
                        Local $aExt = [$x, $y]
                        $g_iExtended = $aExt
                        
                        $iCount += 1
                    EndIf
                EndIf
            EndIf
        Next
    Next

    Return $iCount
EndFunc

Func alignMonsters()
    Local $aReset = [250, 150, 250, 300]
    If (Not(clickDrag($aReset))) Then Return 0
EndFunc

Func countEvo2Mons($sAstromon, $iTolerance = 90, $bReturnCount = False)
    Log_Level_Add("countEvo2Mons(" & $sAstromon & ", " & $iTolerance & ", " & $bReturnCount & ")")
    Local $aInventoryDim[4] = [0, 100, 300, 350]
    Local $monsFound = findImageMultiple("manage-" & $sAstromon & "x", $iTolerance, 10, 10, 4, $aInventoryDim[0], $aInventoryDim[1], $aInventoryDim[2], $aInventoryDim[3], True, True)
    Log_Level_Remove()
    If ($bReturnCount) Then Return Ubound($monsFound)
    Return $monsFound
EndFunc

Func countEvo1Mons($sAstromon, $iTolerance = 90, $bReturnCount = False)
    Log_Level_Add("countEvo1Mons(" & $sAstromon & ", " & $iTolerance & ", " & $bReturnCount & ")")
    Local $aInventoryDim[4] = [0, 100, 300, 350]
    Local $monsFound = findImageMultiple("manage-" & $sAstromon, $iTolerance, 10, 10, 4, $aInventoryDim[0], $aInventoryDim[1], $aInventoryDim[2], $aInventoryDim[3], True, True)
    Log_Level_Remove()
    If ($bReturnCount) Then Return Ubound($monsFound)
    Return $monsFound
EndFunc

Func evolveEvo1Mons($sAstromon, $iTolerance, ByRef $iEvo2, ByRef $aOut)
    Local $bOutput = 0
    Log_Level_Add("evolveEvo1Mons(" & $sAstromon & ", " & $iTolerance & ", " & $iEvo2 & ", " & $aOut[0] & ")")
    Log_Add("Evolving astromons to evo2.")
    Local $iEvo1 = 0 ; Number of Evo1 slimes.
    If (Not(navigate("monsters", True, 3))) Then
        $aOut[1] = "Could not navigate to monsters."
        $bOutput = -1
    EndIf

    Local $aPoints_Evo1 = countEvo1Mons($sAstromon, $iTolerance)
    $iEvo1 = UBound($aPoints_Evo1)

    If ($iEvo1 <=3 ) Then
        $aOut[0] = 4*(4-$iEvo2) - $iEvo1
        Log_Add("Need " & $aOut[0] & " astromons for an evo3.")
        $bOutput = -3
    EndIf

    If ($bOutput <> 0) Then
        Log_Level_Remove()
        Return $bOutput
    EndIf

    Log_Add("Evolving evo1 astromon.")

    clickPoint($aPoints_Evo1[0][0] & "," & $aPoints_Evo1[0][1], 2, 50)
    clickUntil(getPointArg("monsters-evolution"), "isLocation", "monsters-evolution", 5, 1000)

    Local $t_rAwakened = _awaken()
    Log_Add("Awakening Status: " & $t_rAwakened, $LOG_DEBUG)
    Switch $t_rAwakened
        Case 0
            Local $t_rMerge = _merge()
            Log_Add("Merge Status: " & $t_rMerge, $LOG_DEBUG)
            Switch ($t_rMerge)
                Case 0
                    $aOut[0] = 0
                    $aOut[1] = "Successfully evolved astromon to evo2"
                    $iEvo2 += 1
                    Data_Increment("Farmed Gems", 10)
                    Stat_Increment($g_aStats, "Astrogems farmed", 10)
                    Log_Add("Farmed Gems " & Data_Get("Farmed Gems"), $LOG_INFORMATION)
                Case -1
                    $aOut[1] = "Could not evolve astromons to evo2."
                    $bOutput = -1
                Case -2
                    $aOut[0] = -2
                    $aOut[1] = "Not enough gold."
                    $bOutput = -2
            EndSwitch
        Case -1
            $aOut[1] = "Monster awakening failed."
            navigate("monsters", True, 2)
            $bOutput = -1
        Case -2
            $aOut[0] = -2
            $aOut[1] = "Monster awakening failed. Not enough gold."
            $bOutput = -2
    EndSwitch

    If ((4-$iEvo2) > 0) Then 
        Log_Add("Collecting quest rewards.")
        collectQuest()
    EndIf
    Log_Level_Remove()
    Return $bOutput
EndFunc

Func evolveEvo2Mons($sAstromon, $iTolerance, ByRef $aOut)
    Local $bOutput = 0
    Log_Level_Add("evolveEvo2Mons(" & $sAstromon & ", " & $iTolerance & ", " & $aOut[0] & ")")
    Log_Add("Evolving astromons to evo3.")
    Local $iEvo2 = 0 ; Number of Evo1 slimes.
    If (Not(navigate("monsters", True, 3))) Then
        $aOut[1] = "Could not navigate to monsters."
        $bOutput = -1
    EndIf

    Local $aPoints_Evo2 = countEvo2Mons($sAstromon, $iTolerance)
    $iEvo2 = UBound($aPoints_Evo2)

    If ($iEvo2 <= 3) Then
        $aOut[1] = "Not enough evo2 astromons to make an evo3."
        $bOutput = -1
    EndIf

    If ($bOutput <> 0) Then
        Log_Level_Remove()
        Return $bOutput
    EndIf

    clickPoint($aPoints_Evo2[0][0] & "," & $aPoints_Evo2[0][1], 2, 50)
    clickUntil(getPointArg("monsters-evolution"), "isLocation", "monsters-evolution", 5, 1000)

    Local $t_rAwakened = _awaken()
    Switch $t_rAwakened
        Case 0
            Local $t_rMerge = _merge()
            Switch ($t_rMerge)
                Case 0
                    $aOut[0] = 0
                    $aOut[1] = "Successfully evolved astromon to evo3."
                    Data_Increment("Farmed Gems", 60)
                    Stat_Increment($g_aStats, "Astrogems farmed", 60)
                    Log_Add("Farmed Gems " & Data_Get("Farmed Gems"), $LOG_INFORMATION)
                Case -1
                    $aOut[1] = "Could not evolve astromons to evo3."
                    $bOutput = -1
                Case -2
                    $aOut[0] = -2
                    $aOut[1] = "Not enough gold."
                    $bOutput = -2
            EndSwitch
        Case -1
            $aOut[1] = "Monster awakening failed."
            navigate("monsters", True, 2)
            $bOutput = -1
        Case -2
            $aOut[0] = -2
            $aOut[1] = "Monster awakening failed. Not enough gold."
            $bOutput = -2
    EndSwitch
    Log_Level_Remove()
    Return $bOutput
EndFunc

#cs
    Function: In monsters-evolution location, will select the three astromons to fulfill a complete evolution. Note: Will not merge astromons, just select; this is handled in _merge() function.
    Returns: If successfully selected then returns true
#ce
Func _awaken()
    Local $bOutput = 0
    Log_Level_Add("_awaken")
    Local $t_hTimer = TimerInit()
    Local $x = 0
    While Not(isFullyAwakened()) And $x < 7
        If (_Sleep(100)) Then $bOutput = -1
        If (TimerDiff($t_hTimer) > 30000) Then $bOutput = -1
        Local $iMonPointX = 351+($x*65)
        Local $iMonPointY = 330
        Local $t_sMonPoint = StringFormat("%d,%d", $iMonPointX, $iMonPointY)
        ;click the astromons
        If (isLocation("monsters-evolution")) Then clickPoint($t_sMonPoint) ;astromon
        If (_Sleep(200)) Then $bOutput = -1

        If ($bOutput = -1) Then ExitLoop
        If (waitLocation("monsters-awakened-locked,monsters-previous-awaken,buy-gold,buy-gem,monsters-evolution", 2, 100)) Then
            ;conditions for when selected locked astromon or already awakened astromon
            Switch getLocation()
                Case "monsters-awakened-locked"
                    Log_Add("Monster is locked. Skipping.", $LOG_DEBUG)
                    clickUntil(getPointArg("awaken-locked-cancel"), "isLocation", "monsters-evolution", 10, 1000)
                Case "monsters-previous-awaken"
                    Log_Add("Selected monster is already awakened. Skipping", $LOG_DEBUG)
                    clickUntil(getPointArg("already-awakened-close"), "isLocation", "monsters-evolution", 10, 1000)
                Case "buy-gold","buy-gem"
                    $bOutput = -2
                    ExitLoop
            EndSwitch
        EndIf
        $x += 1
    WEnd

    If (Not(IsFullyAwakened())) Then $bOutput = -1
    If ($bOutput = -1) Then takeErrorScreenShot("_awaken")
    Log_Level_Remove()
    Return $bOutput
EndFunc

#cs 
    EXRA-TODO: clean up pixel and point strings
    Func: Completes awaken and evolve process. Assumes the 3 astromons are selected using _awaken function.
    Return: 1 for success, 0 for fail
    Error Codes:
        -1: Not enough currency.
#ce
Func _merge()
    Log_Level_Add("_merge()")
    Local $t_hTimer = TimerInit()
    Local $bResult = doAwaken()
    If ($bResult = 0) Then 
        $bResult = doEvolve()
    EndIf

    Log_Level_Remove()
    Return $bResult
EndFunc

Func doAwaken()
    Log_Level_Add("doAwaken()")
    Local $t_hTimer = TimerInit()
    Local $bOutput = -1
    Local $iCurrentPosition = 0
    While TimerDiff($t_hTimer) < 60000
        If (_Sleep(0)) Then ExitLoop
        Switch getLocation()
            Case "monsters-evolution"
                If ($iCurrentPosition = 0 And isPixel(getPixelArg("monsters-awakened-enabled"), 20)) Then
                    If (clickWhile(getPointArg("monsters-awaken"), "isLocation", "monsters-evolution", 10, 750)) Then 
                        $iCurrentPosition = 1
                    EndIf
                ElseIf ($iCurrentPosition = 0 Or $iCurrentPosition = 3) Then
                    If (waitLocationMS("awakened-success",1000,10)) Then ContinueLoop
                    $bOutput = 0
                    ExitLoop
                EndIf
            Case "monsters-awaken"
                If ($iCurrentPosition = 1 And clickWhile(getPointArg("monsters-awaken-confirm"), "isLocation", "monsters-awaken", 10, 1500)) Then $iCurrentPosition = 2
            Case "awakened-success"
                If ($iCurrentPosition = 2 Or $iCurrentPosition = 3) Then
                    clickWhile(getPointArg("monsters-awaken-tap"), "isLocation", "awakened-success", 20, 500)
                    $iCurrentPosition = 3
                EndIf
            Case "buy-gold","buy-gem"
                $bOutput = -2
                ExitLoop
        EndSwitch
    WEnd
    If ($bOutput = -1) Then takeErrorScreenShot("doAwaken")
    Log_Level_Remove()
    Return $bOutput
EndFunc

Func doEvolve()
    Log_Level_Add("doEvolve()")
    Local $t_hTimer = TimerInit()
    Local $bOutput = -1
    Local $iCurrentPosition = 0
    While TimerDiff($t_hTimer) < 60000
        If (_Sleep(100)) Then ExitLoop
        Switch getLocation()
            Case "monsters-evolution"
                If ($iCurrentPosition = 0 And isPixel(getPixelArg("monsters-evolve-enabled"), 20)) Then
                    If (clickWhile(getPointArg("monsters-evolve"), "isLocation", "monsters-evolution", 10, 1500)) Then 
                        $iCurrentPosition = 1
                    EndIf
                ElseIf ($iCurrentPosition = 0 Or $iCurrentPosition = 4) Then
                    If (waitLocationMS("unknown",1000,10)) Then ContinueLoop
                    $bOutput = 0
                    ExitLoop
                EndIf
            Case "monsters-evolve"
                If ($iCurrentPosition = 1 And clickUntil(getPointArg("monsters-evolve-confirm"), "isLocation", "unknown", 10, 1500)) Then $iCurrentPosition = 2
            Case "unknown"
                If ($iCurrentPosition = 2 Or $iCurrentPosition = 3) Then
                    clickWhile(getPointArg("tap"), "isLocation", "unknown", 50, 500)
                    $iCurrentPosition = 3
                EndIf
            Case "monsters-astromon"
                If ($iCurrentPosition = 3) Then
                    clickWhile(getPointArg("monsters-astromon-close"), "isLocation", "monsters-astromon", 5, 1000)
                    $iCurrentPosition = 4
                EndIf
            Case "buy-gold","buy-gem"
                $bOutput = -2
                ExitLoop
        EndSwitch
    WEnd
    If ($bOutput = -1) Then takeErrorScreenShot("doEvolve_" & $iCurrentPosition)
    Log_Level_Remove()
    Return $bOutput
EndFunc

Func isFullyAwakened()
    captureRegion()
    Return (Not(isPixel(getPixelArg("monsters-not-awakened-third"), 20)))
EndFunc