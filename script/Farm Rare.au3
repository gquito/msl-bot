;function: farmRare
;-Automatically farms rares in story mode
;pre:
;   -config must be set for script
;   -required config keys: map, capture, guardian-dungeon
;author: GkevinOD
Func farmRare()
    ;beginning script
    setLog("*Loading config for Farm Rare.", 2)

    ;getting configs
    Dim $map = "map-" & StringReplace(IniRead(@ScriptDir & "/config.ini", "Farm Rare", "map", "phantom forest"), " ", "-")
    Dim $guardian = IniRead(@ScriptDir & "/config.ini", "Farm Rare", "guardian-dungeon", "0")
    Dim $difficulty = IniRead(@ScriptDir & "/config.ini", "Farm Rare", "difficulty", "normal")
    Dim $captures[0];

    Dim $rawCapture = StringSplit(IniRead(@ScriptDir & "/config.ini", "Farm Rare", "capture", "legendary,super rare,rare,exotic"), ",", 2)
    For $capture In $rawCapture
        Local $grade = StringReplace($capture, " ", "-")
        If FileExists(@ScriptDir & "/core/images/catch/catch-" & $grade & ".bmp") Then
            _ArrayAdd($captures, "catch-" & $grade)

            Local $tempInt = 2
            While FileExists(@ScriptDir & "/core/images/catch/catch-" & $grade & $tempInt & ".bmp")
                _ArrayAdd($captures, "catch-" & $grade & $tempInt)
                $tempInt += 1
            WEnd
        EndIf
    Next

    setLog("~~~Starting 'Farm Rare' script~~~", 2)

    ;setting up data capture
    GUICtrlSetData($cmbLoad, "Select a script..")
    $strScript = "" ;script section
    $strConfig = "" ;all keys

    Local $dataRuns = 0
    Local $dataGuardians = 0
    Local $dataEncounter = 0
    Local $dataStrCaught = ""
    Local $getHourly = False

    While True
        While True
            GUICtrlSetData($listScript, "")
            GUICtrlSetData($listScript, "~Farm Rare Data~|# of Runs: " & $dataRuns & "|# of Guardian Dungeons: " & $dataGuardians & "|# of Rare Encounters: " & $dataEncounter & "|Astromon Caught: " & StringMid($dataStrCaught, 2))

            If StringSplit(_NowTime(4), ":", 2)[1] = "00" Then $getHourly = True

            If _Sleep(100) Then ExitLoop(2) ;to stop farming
            If checkLocations("map", "map-stage", "astroleague", "village", "manage", "monsters", "quests", "map-battle", "clan") = 1 Then
                If setLog("Going into battle...", 1) Then ExitLoop(2)
                If navigate("map") = 1 Then
                    If enterStage($map, $difficulty, True, True) = 0 Then
                        If setLog("Error: Could not enter map stage.", 1) Then ExitLoop(2)
                    Else
                        $dataRuns += 1
                        If setLog("Waiting for astromon.", 1) Then ExitLoop(2)
                    EndIf
                EndIf
            EndIf

            If checkLocations("battle-end-exp", "battle-sell") = 1 Then
                clickPointUntil($game_coorTap, "battle-end")
            EndIf

            If checkLocations("battle-end") = 1 Then
                clickPoint($game_coorTap, 5)
                If waitLocation("unknown", 10) = 0 Then
                    If setLog("Autobattle finished.", 1) Then ExitLoop(2)
                    If $getHourly = True Then 
                        getHourly()
                        $getHourly = False
                    EndIf
                    If checkPixel($battle_pixelQuest) = True Then
                        If setLog("Detected quest complete, navigating to village.", 1) Then ExitLoop(2)
                        If navigate("village", "quests") = 1 Then
                            If setLog("Collecting quests.", 1) Then ExitLoop(2)
                            For $questTab In $village_coorArrayQuestsTab ;quest tabs
                                clickPoint(StringSplit($questTab, ",", 2))
                                While isArray(findImageWait("misc-quests-get-reward", 3, 100)) = True
                                    If _Sleep(10) Then ExitLoop(4)
                                    clickImage("misc-quests-get-reward", 100)
                                WEnd
                            Next
                        EndIf
                    EndIf
                    navigate("map")
                    ExitLoop
                EndIf
                $dataRuns += 1
            EndIf

            If checkLocations("battle") = 1 Then
                If isArray(findImagesWait($imagesRareAstromon, 5, 100)) Then
                    $dataEncounter += 1
                    If setLog("An astromon has been found!", 1) Then ExitLoop(2)
                    waitLocation("battle")

                    _CaptureRegion()
                    If checkPixel($battle_pixelUnavailable) = False Then ;if there is more astrochips
                        If navigate("battle", "catch-mode") = 1 Then
                            Local $tempStr = catch($captures, True, False, False, True)
                            If $tempStr = -2 Then ;double check
                                If setLog("Did not recognize astromon, trying again..", 1) Then ExitLoop(2)

                                navigate("battle", "catch-mode")
                                $tempStr = catch($captures, True, True, False, True)
                            EndIf
                            If $tempStr = "-2" Then $tempStr = ""

                            If Not $tempStr = "" Then $dataStrCaught &= ", " & $tempStr
                            If setLog("Finish catching, attacking..", 1) Then ExitLoop(2)
                            clickPoint($battle_coorAuto)
                        EndIf
                    Else ;if no more astrochips
                        If setLog("Unable to catch astromons, out of astrochips.", 1) Then ExitLoop(2)
                        clickPoint($battle_coorAuto)
                    EndIf
                EndIf
            EndIf

            If checkLocations("map-gem-full", "battle-gem-full") = 1 Then
                If setLog("Gem is full, going to sell gems...", 1) Then ExitLoop(2)
                If navigate("village", "manage") = 1 Then
                    sellGems($imagesUnwantedGems)
                EndIf
            EndIf

            If checkLocations("lost-connection") = 1 Then
                clickPoint($game_coorConnectionRetry)
            EndIf
        WEnd

        Dim $foundDungeon = 0
        If $guardian = 1 And navigate("map", "guardian-dungeons") = 1 Then
            If setLog("Checking for guardian dungeons...", 1) Then ExitLoop(2)
            While checkLocations("guardian-dungeons") = 1
                If clickImageUntil("misc-dungeon-energy", "map-battle", 50) = 1 Then
                    clickPointWait($map_coorBattle, "map-battle", 5)

                    If _Sleep(3000) Then ExitLoop(2)

                    If checkLocations("map-gem-full", "battle-gem-full") = 1 Then
                        If setLog("Gem is full, going to sell gems...", 1) Then ExitLoop(2)
                        If navigate("village", "manage") = 1 Then
                            sellGems($imagesUnwantedGems)
                        EndIf

                        clickImageUntil("misc-dungeon-energy", "map-battle", 50)
                        clickPointWait($map_coorBattle, "map-battle", 5)
                    EndIf
                    $foundDungeon += 1
                    setLogReplace("Found dungeon, attacking x" & $foundDungeon & ".", 1)

                    If waitLocation("battle-end-exp", 240) = 0 Then
                        If setLog("Unable to finish golem in 5 minutes!", 1) Then ExitLoop(2)
                        ExitLoop
                    EndIf

                    While checkLocations("battle-end") = 0
                        clickPoint($game_coorTap)
                        If _Sleep(10) Then ExitLoop(2)
                    WEnd

                    clickImageUntil("battle-exit", "guardian-dungeons")
                Else
                    If setLog("Guardian dungeon not found, going back to map.", 1) Then ExitLoop(2)
                    navigate("map")
                    ExitLoop
                EndIf
            WEnd
        EndIf
        $dataGuardians += $foundDungeon
    WEnd

    setLog("~~~Finished 'Farm Rare' script~~~", 2)
EndFunc