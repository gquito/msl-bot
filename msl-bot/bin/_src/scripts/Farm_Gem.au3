#include-once
Global Const $ASTROMON_EVO1 = 0, _ 
             $ASTROMON_EVO2 = 1, _
             $ASTROMON_AWAKENED_EVO1 = 2, _
             $ASTROMON_AWAKENED_EVO2 = 3

Func Farm_Gem($bParam = True, $aStats = Null)
    If $bParam > 0 Then Config_CreateGlobals(formatArgs(Script_DataByName("Farm_Gem")[2]), "Farm_Gem")
    ;Astrogems, Astromon, Release Evo3, Max Catch, Finish Round, Final Round, Map, Difficulty, Stage Level, Capture, Refill

    $Farm_Gem_Astrogems = (StringLeft($Farm_Gem_Astrogems, 1)="g"?Int(StringMid($Farm_Gem_Astrogems, 2)/330000)*100:($Farm_Gem_Astrogems))

    If StringIsInt($Farm_Gem_Refill) = False Or Int($Farm_Gem_Refill) < -1 Then
        Log_Add("Error: Refill is invalid: " & $Farm_Gem_Refill, $LOG_ERROR)
        Return -1
    Else
        If $g_iMaxRefill = Null Then $g_iMaxRefill = Int($Farm_Gem_Refill)
    EndIf

    Log_Level_Add("Farm_Gem")
    Global $Status, $Farmed_Gems, $Astrogems_Used
    Stats_Add(  CreateArr( _
                    CreateArr("Text",       "Status"), _
                    CreateArr("Text",       "Location"), _
                    CreateArr("Ratio",      "Farmed_Gems",      "Farm_Gem_Astrogems"), _
                    CreateArr("Ratio",      "Astrogems_Used",   "Farm_Gem_Refill") _
                ))
    If $aStats <> Null Then Stats_Values_Set($aStats)

    Status("Farm Gem has started.", $LOG_INFORMATION)

    Local $iEvo = 0
    Local $aAstromons = Null
    Local $aFarm_Astromon_Stats = Null

    ; Gem quest limits
    Local $bEvo1Limit = False
    Local $bEvo2Limit = False 

    navigate("village", True)
    While $g_bRunning = True
        If $Farm_Gem_Check_Limit = True And ($bEvo1Limit = True And $bEvo2Limit = True) Then
            Log_Add("Evolution quest limit has been reached. Stopping script.", $LOG_INFORMATION)
            ExitLoop
        EndIf

        If _Sleep($Delay_Script_Loop) Then ExitLoop
        Local $sLocation = getLocation()
        Common_Stuck($sLocation)

        If $Farmed_Gems >= $Farm_Gem_Astrogems Then ExitLoop
        Switch $sLocation
            Case "monsters"
                If $aAstromons = Null Then 
                    Status("Counting astromons", $LOG_DEBUG)
                    $aAstromons = Farm_Gem_Count($Farm_Gem_Astromon)
                EndIf

                If UBound($aAstromons) <> 4 Then
                    Log_Add("Invalid astromon count array.", $LOG_ERROR)
                    $aAstromons = Null
                    ContinueLoop
                EndIf

                Local $aEvo1 = $aAstromons[$ASTROMON_EVO1]
                Local $aEvo2 = $aAstromons[$ASTROMON_EVO2]
                Local $aAwakenedEvo1 = $aAstromons[$ASTROMON_AWAKENED_EVO1]
                Local $aAwakenedEvo2 = $aAstromons[$ASTROMON_AWAKENED_EVO2]
                Local $bSelectResult = False
                
                ;Handle Awakened Evo2 -> Evo3
                $bSelectResult = _Farm_Gem_Select($aAwakenedEvo2, $Farm_Gem_Astromon, 2, True, 0)
                $iEvo = @extended
                If $iEvo = 0 Then $aAstromons[$ASTROMON_AWAKENED_EVO2] = -1
                If $bSelectResult Then ContinueLoop

                ;Handle Evo2 -> Evo3
                $bSelectResult = _Farm_Gem_Select($aEvo2, $Farm_Gem_Astromon, 2, False, 3)
                $iEvo = @extended
                If $iEvo = 0 Then $aAstromons[$ASTROMON_EVO2] = -1
                If $bSelectResult Then ContinueLoop

                ;Handle Awakened Evo1 -> Evo2
                $bSelectResult = _Farm_Gem_Select($aAwakenedEvo1, $Farm_Gem_Astromon, 1, True, 0)
                $iEvo = @extended
                If $iEvo = 0 Then $aAstromons[$ASTROMON_AWAKENED_EVO1] = -1
                If $bSelectResult Then ContinueLoop

                ;Handle Evo1 -> Evo2
                $bSelectResult = _Farm_Gem_Select($aEvo1, $Farm_Gem_Astromon, 1, False, 3)
                $iEvo = @extended
                If $iEvo = 0 Then $aAstromons[$ASTROMON_EVO1] = -1
                If $bSelectResult Then ContinueLoop

                ;Handle else
                Local $iCount_Evo1 = UBound($aEvo1)
                Local $iCount_Evo2 = UBound($aEvo2)
                Local $iTotal = $iCount_Evo1+($iCount_Evo2*4)

                Local $iCalculated_Need = Ceiling((($Farm_Gem_Astrogems-$Farmed_Gems)/100)*16)
                Status("Total astromons needed: " & $iCalculated_Need, $LOG_PROCESS)
                Status("Current number of astromons: " & $iTotal, $LOG_PROCESS)
                
                Local $iCatch = 0
                If $Farm_Gem_Max_Catch = 0 Then
                    $iCatch = $iCalculated_Need-$iTotal
                Else
                    $iCatch = (($iCalculated_Need-$iTotal)>$Farm_Gem_Max_Catch)?($Farm_Gem_Max_Catch):($iCalculated_Need-$iTotal)
                EndIf
                
                Status(StringFormat("Going to catch %d astromons.", $iCatch), $LOG_PROCESS)

                Local $aParam = [$iCatch, $Farm_Gem_Astromon, $Farm_Gem_Finish_Round, $Farm_Gem_Final_Round, $Farm_Gem_Map, _
                                $Farm_Gem_Difficulty, $Farm_Gem_Stage_Level, $Farm_Gem_Capture, $Farm_Gem_Refill]

                Stats_Values_Edit($aFarm_Astromon_Stats, Stats_Values_IndexByName($aFarm_Astromon_Stats, "Runs"), 0)
                Stats_Values_Edit($aFarm_Astromon_Stats, Stats_Values_IndexByName($aFarm_Astromon_Stats, StringReplace($Farm_Gem_Astromon, "-", "_")), 0)
                $aFarm_Astromon_Stats = _RunScript("Farm_Astromon", $aParam, $aFarm_Astromon_Stats)
                Stats_Values_Remove($aFarm_Astromon_Stats, CreateArr("Farmed_Gems"))

                $aAstromons = Null

            Case "monsters-evolution"
                If $iEvo = 0 Or $aAstromons = Null Then
                    navigate("monsters")
                    ContinueLoop
                EndIf

                Status(StringFormat("Awakening evo%d %s.", Number($iEvo), String($Farm_Gem_Astromon)), $LOG_PROCESS)
                If Farm_Gem_Awaken() > 0 Then
                    Status(StringFormat("Evolving evo%d %s.", Number($iEvo), String($Farm_Gem_Astromon)), $LOG_PROCESS)
                    If Farm_Gem_Evolve() > 0 Then
                        Status(StringFormat("Successfully evolved evo%d %s.", Number($iEvo), String($Farm_Gem_Astromon)), $LOG_PROCESS)
                        If UBound($aAstromons[1]) <> 3 Then
                            If $iEvo = 2 And $Farm_Gem_Release_Evo3 > 0 Then
                                If navigate("monsters") > 0 And isPixel(getPixelArg("monsters-evolution-third"), 10, CaptureRegion()) > 0 Then
                                    Farm_Gem_Release()
                                EndIf
                            EndIf

                            collectQuest(3)
                            If @extended = 1 Then  ; Quest limit
                                If $iEvo = 1 Then $bEvo1Limit = True
                                If $iEvo = 2 Then $bEvo2Limit = True
                            EndIf

                            If $Farm_Gem_Check_Limit = True And ($bEvo1Limit = True And $bEvo2Limit = True) Then
                                ContinueLoop ; Invokes quest limit condition to stop script.
                            EndIf
                        EndIf

                        If $iEvo = 2 Then 
                            $Farmed_Gems += 100
                            Cumulative_AddNum("Resource Earned (Astrogems)", 100)
                            Cumulative_AddNum("Resource Used (Gold)", 330000)
                        EndIf
                        $iEvo = 0
                    Else
                        navigate("monsters")
                        Status("Could not evolve astromon.", $LOG_ERROR)
                    EndIf
                Else
                    navigate("monsters")
                    Status("Could not awaken astromon.", $LOG_ERROR)
                EndIf

                $aAstromons = Null
            Case "buy-gold", "buy-gem"
                Status("There was not enough gold to evolve.", $LOG_ERROR)
                ExitLoop
            Case "unknown"
                clickPoint(getPointArg("tap"))
                ContinueCase
            Case Else
                If HandleCommonLocations($sLocation) = 0 And $sLocation <> "unknown" Then
                    $aAstromons = Null
                    Status("Proceeding to monsters.")
                    navigate("monsters", True)
                EndIf
        EndSwitch
    WEnd

    Log_Add("Farm Gem has ended.", $LOG_INFORMATION)
    Log_Level_Remove()
    Return Stats_GetValues($g_aStats)
EndFunc

Func Farm_Gem_Count($sName)
    CaptureRegion()
    Local $aEvo1 = findImageMultiple($sName & "-evo-one", 80, 10, 10, 16, 10, 100, 280, 350, False)
    Local $aEvo2 = findImageMultiple($sName & "-evo-two", 80, 10, 10, 4, 10, 100, 280, 350, False)

    Local $aAwakenedEvo1 = findImageMultiple("misc-awakened-evo-one", 70, 10, 10, 16, 10, 100, 280, 350, False, True)
    ; Delete incorrect evo level found.
    For $i = UBound($aAwakenedEvo1) - 1 To 0 Step -1
        Local $bFound = False
        For $j = 0 To UBound($aEvo1) - 1
            Local $aPoint1 = CreateArr($aAwakenedEvo1[$i][0], $aAwakenedEvo1[$i][1] - 23)
            Local $aPoint2 = CreateArr($aEvo1[$j][0], $aEvo1[$j][1])
            Local $iDistance = GetDistance($aPoint1, $aPoint2)
            If $iDistance < 10 Then
                $bFound = True
                ExitLoop
            EndIf
        Next

        If $bFound = False Then
            _ArrayDelete($aAwakenedEvo1, $i)
        EndIf
    Next
    If UBound($aAwakenedEvo1) = 0 Then $aAwakenedEvo1 = -1

    Local $aAwakenedEvo2 = findImageMultiple("misc-awakened-evo-two", 70, 10, 10, 4, 10, 100, 280, 350, False, True)
    ; Delete incorrect evo level found.
    For $i = UBound($aAwakenedEvo2) - 1 To 0 Step -1
        Local $bFound = False
        For $j = 0 To UBound($aEvo2) - 1
            Local $aPoint1 = CreateArr($aAwakenedEvo2[$i][0], $aAwakenedEvo2[$i][1] - 23)
            Local $aPoint2 = CreateArr($aEvo2[$j][0], $aEvo2[$j][1])
            Local $iDistance = GetDistance($aPoint1, $aPoint2)
            If $iDistance < 10 Then
                $bFound = True
                ExitLoop
            EndIf
        Next

        If $bFound = False Then
            _ArrayDelete($aAwakenedEvo2, $i)
        EndIf
    Next
    If UBound($aAwakenedEvo2) = 0 Then $aAwakenedEvo2 = -1

    Return CreateArr($aEvo1, $aEvo2, $aAwakenedEvo1, $aAwakenedEvo2)
EndFunc

Func Farm_Gem_Select($aPoint, $sAstromon, $iEvo, $bAwakened)
    If $iEvo <> 1 And $iEvo <> 2 Then Return SetError(1, 0, False)
    If UBound($aPoint) <> 2 Then Return SetError(2, 0, False)

    Log_Level_Add("Farm_Gem_Select")
    Status("Selecting Evo " & $iEvo & " astromon.", $LOG_PROCESS)
    Local $bOutput = False
    Local $hTimer = TimerInit()
    While TimerDiff($hTimer) < 5000
        If _Sleep($Delay_Script_Loop) Then ExitLoop

        Switch getLocation()
            Case "monsters"
                clickPoint(getPointArg("monsters-evolution"))
            Case "monsters-evolution"
                Local $bTemp = $g_bLogEnabled
                $g_bLogEnabled = False

                clickPoint($aPoint)
                Local $sEvo = ($iEvo = 1)?("one"):("two")

                Local $bFoundAwakened = isPixel("367,210,0x49D8D8/367,209,0x38E3E5", 20)
                Local $aFound = findImage($sAstromon & "-evo-" & $sEvo, 90, 0, 327, 147, 70, 70, False)

                $g_bLogEnabled = $bTemp

                If UBound($aFound) = 0 Then ContinueLoop
                If $bAwakened = True And $bFoundAwakened = False Then ContinueLoop

                $bOutput = True
                ExitLoop
            Case Else
                ExitLoop
        EndSwitch
    WEnd

    If $bOutput = False Then
        Log_Add("Could not select Evo " & $iEvo & " astromon.", $LOG_ERROR)
    EndIf

    Log_Level_Remove()
    Return $bOutput
EndFunc

Func _Farm_Gem_Select($aEvo, $sAstromon, $l_iEvo, $bAwakened, $iMin)
    Local $iSize = UBound($aEvo)

    If $iSize > $iMin Then
        Local $iIndex = $iSize - 1
        Status("Evolving " & (($bAwakened)?("awakened"):("")) & " evo" & $l_iEvo & " to evo" & $l_iEvo+1 & ".", $LOG_PROCESS)
        If UBound($aEvo, $UBOUND_COLUMNS) = 2 Then
            Local $iX = $aEvo[$iIndex][0]
            Local $iY = $aEvo[$iIndex][1]
            Local $bSelect = Farm_Gem_Select(CreateArr($iX, $iY), $sAstromon, $l_iEvo, $bAwakened)
            If $bSelect = False Then 
                $l_iEvo = 0
            EndIf
        Else
            Log_Add("Invalid point array (1).", $LOG_ERROR)
            $l_iEvo = 0
        EndIf
        
        If $l_iEvo = 0 Then
            $iIndex = ($l_iEvo - 1) + (($bAwakened)?(2):(0))
        EndIf

        Return SetExtended($l_iEvo, True)
    EndIf

    Return False
EndFunc

Func Farm_Gem_Awaken()
    Log_Level_Add("Farm_Gem_Awaken")
    Local $bOutput = False

    Local $hTimer = TimerInit()
    Local $iX = 351
    Local $iY = 330
    While TimerDiff($hTimer) < 30000
        If _Sleep(300) > 0 Then ExitLoop
        Local $sLocation = getLocation()
        Switch $sLocation
            Case "monsters-evolution"
                If isPixel(getPixelArg("monsters-not-awakened-third"), 20) > 0 Then ;Not selected
                    clickPoint(CreateArr($iX, $iY))
                    $iX += 65
                    If $iX > 741 Then ExitLoop
                Else
                    If isPixel(getPixelArg("monsters-awakened-enabled"), 20) <= 0 Then 
                        $bOutput = True
                        ExitLoop
                    EndIf
                    clickPoint(getPointArg("monsters-awaken"))
                EndIf
            Case "monsters-awaken"
                clickPoint(getPointArg("monsters-awaken-confirm"), 3)
                waitLocation("awakened-success", 10)
            Case "awakened-success"
                clickPoint(getPointArg("monsters-awaken-tap"), 3, 100)
                $bOutput = True
                ExitLoop
            Case "popup-window"
                closeWindow()
            Case "buy-gem", "buy-gold"
                ExitLoop
            Case "unknown"
            Case Else
                ExitLoop
        EndSwitch
    WEnd

    Log_Add("Awaken astromon result: " & $bOutput, $LOG_DEBUG)
    Log_Level_Remove()
    Return $bOutput
EndFunc

Func Farm_Gem_Evolve()
    Log_Level_Add("Farm_Gem_Evolve")
    Local $bOutput = False

    Local $hTimer = TimerInit()
    While TimerDiff($hTimer) < 30000
        If _Sleep(300) > 0 Then ExitLoop
        Local $sLocation = getLocation()
        Switch $sLocation
            Case "monsters-evolution"
                If isPixel(getPixelArg("monsters-evolve-enabled"), 20, CaptureRegion()) <= 0 Then 
                    $bOutput = True
                    ExitLoop
                EndIf
                clickPoint(getPointArg("monsters-evolve"))
            Case "monsters-evolve"
                clickPoint(getPointArg("monsters-evolve-confirm"), 3)
                waitLocation("unknown,monsters-astromon", 10)
            Case "monsters-astromon"
                closeWindow()
                $bOutput = True
                ExitLoop
            Case "popup-window"
                closeWindow()
            Case "buy-gem", "buy-gold"
                ExitLoop
            Case "unknown"
                clickPoint(getPointArg("tap"))
            Case Else
                ExitLoop
        EndSwitch
    WEnd

    Log_Add("Evolve astromon result: " & $bOutput, $LOG_DEBUG)
    Log_Level_Remove()
    Return $bOutput
EndFunc

Func Farm_Gem_Release()
    Log_Level_Add("Farm_Gem_Release")
    Local $bOutput = False
    Local $hTimer = TimerInit()
    While TimerDiff($hTimer) < 15000
        If _Sleep(500) Then ExitLoop
        Local $sLocation = getLocation()
        Switch $sLocation
            Case "monsters", "monsters-evolution", "monsters-level-up"
                clickPoint(getPointArg("release"), 3)
                waitLocation("release-confirm", 5)
            Case "release-confirm"
                clickPoint(getPointArg("release-confirm"), 3)
                If waitLocation("release-reward,hourly-reward", 5) Then ContinueCase
                $bOutput = True
                ExitLoop
            Case "release-reward", "hourly-reward"
                clickPoint(getPointArg("release-confirm"), 3)
                $bOutput = True
                ExitLoop
            Case "unknown"
            Case Else
                ExitLoop
        EndSwitch
    WEnd
    
    Log_Add("Release astromon result: " & $bOutput, $LOG_DEBUG)
    Log_Level_Remove()
    Return $bOutput
EndFunc