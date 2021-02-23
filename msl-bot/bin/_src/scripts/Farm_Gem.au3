#include-once

Func Farm_Gem($bParam = True, $aStats = Null)
    If $bParam > 0 Then Config_CreateGlobals(formatArgs(Script_DataByName("Farm_Gem")[2]), "Farm_Gem")
    ;Astrogems, Astromon, Release Evo3, Max Catch, Finish Round, Final Round, Map, Difficulty, Stage Level, Capture, Refill

    $Farm_Gem_Astrogems = (StringLeft($Farm_Gem_Astrogems, 1)="g"?Int(StringMid($Farm_Gem_Astrogems, 2)/330000)*100:($Farm_Gem_Astrogems))

    Log_Level_Add("Farm_Gem")
    
    Global $Status, $Farmed_Gems, $Astrogems_Used
    Stats_Add(  CreateArr( _
                    CreateArr("Text",       "Status"), _
                    CreateArr("Ratio",      "Farmed_Gems",      "Farm_Gem_Astrogems"), _
                    CreateArr("Ratio",      "Astrogems_Used",   "Farm_Gem_Refill") _
                ))
    If $aStats <> Null Then Stats_Values_Set($aStats)

    Status("Farm Gem has started.", $LOG_INFORMATION)

    Local $iEvo = 0
    Local $aAstromons = Null
    Local $aFarm_Astromon_Stats = Null

    navigate("village", True)
    While $g_bRunning = True
        If $Farm_Gem_Check_Limit > 0 And isDeclared("g_bMaxIteration") > 0 Then
            If Eval("g_bMaxIteration") > 0 Then
                Log_Add("Evolution quest limit has been reached. Stopping script.", $LOG_INFORMATION)
                ExitLoop
            EndIf
        EndIf

        If _Sleep($Delay_Script_Loop) Then ExitLoop
        Local $sLocation = getLocation()
        Common_Stuck($sLocation)

        If $Farmed_Gems >= $Farm_Gem_Astrogems Then ExitLoop
        Switch $sLocation
            Case "monsters"
                Status("Counting astromons.")
                If $aAstromons = Null Then 
                    clickPoint("48,429", 3)
                    $aAstromons = Farm_Gem_Count($Farm_Gem_Astromon)
                EndIf

                If $aAstromons[0] <> -1 Or $aAstromons[1] <> -1 Then
                    If UBound($aAstromons[0]) >= 4 Then $iEvo = 1
                    If UBound($aAstromons[1]) >= 4 Then $iEvo = 2
                    If $iEvo <> 0 Then
                        If $aAstromons[$iEvo+1] <> -1 Then
                            For $i = 0 To UBound($aAstromons[$iEvo-1])-1
                                For $x = 0 To UBound($aAstromons[$iEvo+1])-1
                                    Local $aMon = $aAstromons[$iEvo-1]
                                    Local $aAwakened = $aAstromons[$iEvo+1]

                                    If ($aMon[$i][0] > $aAwakened[$x][0]-30 And $aMon[$i][0] < $aAwakened[$x][0]+30) Then
                                        If ($aMon[$i][1] > $aAwakened[$x][1]-30 And $aMon[$i][1] < $aAwakened[$x][1]+30) Then
                                            clickPoint(CreateArr($aMon[$i][0], $aMon[$i][1]), 3)
                                            clickPoint(getPointArg("monsters-evolution"))
                                            waitLocation("monsters-evolution", 3)
                                            ContinueLoop(3)
                                        EndIf
                                    EndIf

                                Next
                            Next
                        EndIf

                        clickPoint(CreateArr(($aAstromons[$iEvo-1])[0][0], ($aAstromons[$iEvo-1])[0][1]), 3)
                        clickPoint(getPointArg("monsters-evolution"))
                        waitLocation("monsters-evolution", 3)
                        ContinueLoop
                    EndIf
                EndIf
        
                Local $iCount_Evo1 = ($aAstromons[0]<>-1)?(UBound($aAstromons[0])):(0)
                Local $iCount_Evo2 = ($aAstromons[1]<>-1)?(UBound($aAstromons[1])):(0)
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
                            If collectQuest(3) <= 0 And $Farm_Gem_Check_Limit > 0 Then
                                Log_Add("Evolution quest limit has been reached. Stopping script.", $LOG_INFORMATION)
                                ExitLoop
                            EndIf
                        EndIf
                        If $iEvo = 2 Then 
                            $Farmed_Gems += 100 ;10 and 60, but that causes some weird stuff
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
    CaptureRegion("", 10, 100, 280, 350)
    Local $aEvo1 = findImageMultiple($sName & "-evo-one", 80, 10, 10, 0, 10, 100, 280, 350, False)
    Local $aEvo2 = findImageMultiple($sName & "-evo-two", 80, 10, 10, 0, 10, 100, 280, 350, False)
    Local $aAwakenedEvo1 = findImageMultiple("misc-awakened-evo-one", 70, 10, 10, 0, 10, 100, 280, 350, False)
    Local $aAwakenedEvo2 = findImageMultiple("misc-awakened-evo-two", 70, 10, 10, 0, 10, 100, 280, 350, False)
    Return CreateArr($aEvo1, $aEvo2, $aAwakenedEvo1, $aAwakenedEvo2)
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
                If isPixel(getPixelArg("monsters-not-awakened-third"), 20, CaptureRegion()) > 0 Then ;Not selected
                    clickPoint(CreateArr($iX, $iY))
                    $iX += 65
                    If $iX > 741 Then ExitLoop
                Else
                    If isPixel(getPixelArg("monsters-awakened-enabled"), 20, CaptureRegion()) <= 0 Then 
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
                waitLocation("release-reward,hourly-reward", 5)
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