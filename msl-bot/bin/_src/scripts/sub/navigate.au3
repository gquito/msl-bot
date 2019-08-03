#include-once
#include "../../imports.au3"

#cs 
    Function: Script to navigate locations in MSL game.
    Parameters:
        $sLocation: One of the locations.
        $bForceSurrender: If in battle will surrender the match
        $iAttempt: Number of attempts
    Returns: 
        if success, true
        if fail, false
#ce
Func navigate($sLocation, $bForceSurrender = False, $iAttempt = 1)
    Local $bOutput = False ;Error code
    Log_Level_Add("navigate")
    Log_Add("Navigating to " & $sLocation & ".")

    Local $bIsLoading = False
    While $iAttempt > 0
        If (_Sleep() Or $bOutput) Then ExitLoop
        $iAttempt -= 1

        Local $t_sCurrLocation ;Will store current location.
        $sLocation = StringStripWS(StringLower($sLocation), $STR_STRIPALL)

        While $t_sCurrLocation <> $sLocation
            If (_Sleep(100)) Then ExitLoop
            $t_sCurrLocation = getLocation()

            If (HandleCommonLocations($t_sCurrLocation)) Then
                _Sleep(10)
                ContinueLoop
            EndIf
            ;Handles force surrender 
            Switch $t_sCurrLocation
                Case $sLocation
                    $bOutput = True
                    ExitLoop
                Case "another-device"
                    Log_Add("Another device detected!", $LOG_INFORMATION)

                    Switch $g_iLoggedOutTime
                        Case -1
                            Log_Add("Restart time set to Never, Stopping script.", $LOG_INFORMATION)
                            Stop()
                        Case 0
                            Log_Add("Restart time set to Immediately", $LOG_INFORMATION)
                            RestartGame()
                        Case Else
                            Local $iMinutes = $g_iLoggedOutTime
                            Log_Add("Restart time set to " & $iMinutes & " minutes.", $LOG_INFORMATION)
                            
                            Local $hTimer = TimerInit()
                            $g_bDisableAntiStuck = True
                            While TimerDiff($hTimer) < ($iMinutes*60000)
                                Local $iSeconds = Int(($iMinutes*60) - (TimerDiff($hTimer)/1000))
                                Data_Set("Status", "Restarting in: " & getTimeString($iSeconds))
                                If (_Sleep(1000)) Then ExitLoop
                            WEnd
                            $g_bDisableAntiStuck = False
                            RestartGame()
                    EndSwitch
                Case "manage", "monsters-evolution", "monsters-level-up"
                    clickUntil(getPointArg("manage-x"), "isLocation", "monsters", 3, 2000)
                Case "defeat" 
                    If (clickUntil(getPointArg("battle-give-up"), "isLocation", "unknown,battle-end-exp,battle-sell,battle-sell-item,battle-end")) Then
                        If (Not(clickUntil(getPointArg("tap"), "isLocation", "battle-end", 1000, 120))) Then ExitLoop(2)
                    Else
                        ExitLoop
                    EndIf
                Case "catch-success"
                    If ($bForceSurrender) Then
                        Local $t_sLoc = ""

                        While $t_sLoc <> "pause" And $t_sLoc <> "battle"
                            If ($g_bAdbWorking) Then ADB_SendESC()
                            If (_Sleep(50)) Then ExitLoop(2)

                            $t_sLoc = getLocation()
                        WEnd
                        ContinueCase
                    EndIf
                Case "battle", "battle-auto", "catch-mode", "pause"
                    If ($bForceSurrender) Then
                        ;Force surrender algorithm
                        If (clickUntil(getPointArg("battle-pause"), "isLocation", "pause", 60, 500)) Then
                            clickWhile(getPointArg("battle-give-up"), "isLocation", "pause,unknown,popup-window", 60, 500)
                        EndIf

                        ;Sets up for normal locations
                        If (Not(clickUntil(getPointArg("tap"), "isLocation", "pvp-battle-end,battle-end,astroleague", 60, 50))) Then ExitLoop(2)
                    Else   
                        ;Only catch-mode will need to be in one of the locations above.
                        If ($sLocation <> "catch-mode") Then ExitLoop
                    EndIf
                Case "battle-end-exp", "battle-sell", "battle-sell-item", "astroleague-defeat", "astroleague-victory"
                    Local $t_iError = 0 ;Counts errors
                    While $t_iError < 4
                        If (_Sleep(10)) Then ExitLoop(2)
                        If (clickUntil(getPointArg("tap"), "isLocation", "pvp-battle-end,battle-end,battle-sell-item,map,village,loading", 500, 120)) Then
                            If (isLocation("battle-sell-item")) Then
                                clickUntil(getPointArg("battle-sell-item-cancel"), "isLocation", "battle-end,pvp-battle-end", 2, 500)
                                clickUntil(getPointArg("battle-sell-item-okay"), "isLocation", "battle-end,pvp-battle-end", 2, 500)

                                $t_iError += 1
                            ElseIf (isLocation("battle-end,pvp-battle-end")) Then
                                ExitLoop
                            ElseIF (isLocation("map,village")) Then
                                ExitLoop
                            Else
                                $t_iError += 1
                            EndIf
                        Else
                            $t_iError += 1
                        EndIf
                    WEnd
            EndSwitch

            If (IsLocation($sLocation)) Then
                $bOutput = True
                ExitLoop
            EndIf

            ;Handles normal locations
            Switch $sLocation
                Case "village"
                    Local $navOutput = navigateToVillage($bOutput, $bForceSurrender)
                    $bOutput = $navOutput[1]
                    Switch $navOutput[0]
                        Case -1
                            ExitLoop
                        Case -2
                            ContinueLoop
                        Case -3
                            ExitLoop(2)
                        Case -4
                            ContinueLoop(2)
                    EndSwitch
                Case "map"
                    Switch $t_sCurrLocation
                        Case "battle-gem-full","map-gem-full"
                            closeWindow()
                            ContinueLoop
                        Case "battle-end", "pvp-battle-end"
                            ;Goes directly from battle-end to map
                            $bOutput = navigateFromBattleEnd("map",$bOutput)
                            If ($bOutput) Then
                                If (waitLocation("map,village", 60) = "village") Then
                                    ContinueLoop
                                Else
                                    $bOutput = isLocation("map")
                                EndIf
                            EndIf
                            ExitLoop
                            
                        Case "map-battle", "map-stage", "association", "clan", "toc", "astroleague", "starstone-dungeons", "golem-dungeons", "gold-dungeons", "elemental-dungeons", "guardian-dungeons", "extra-dungeons"
                            Local $t_hTimer = TimerInit() 
                            While Not(isLocation("map"))
                                If (_Sleep(10)) Then ExitLoop(2)
                                If (TimerDiff($t_hTimer) > 60000) Then
                                    Log_Add("Navigate: Timed out.", $LOG_ERROR)
                                    ExitLoop(2) ;60 seconds
                                EndIf
                                    
                                $t_sCurrLocation = getLocation()
                                Switch $t_sCurrLocation
                                    Case "village", "battle-end", "quit", "tap-to-start", "event-list","guardian-dungeons", "starstone-dungeons", "elemental-dungeons", "special-guardian-dungeons", "gold-dungeons" ,"extra-dungeons"
                                        closeWindow()
                                        ContinueLoop(2)
                                    Case "loading"
                                        If (_Sleep(200)) Then ExitLoop(2)
                                        $t_hTimer = TimerInit()
                                    Case "map-stage"
                                        clickUntil(getPointArg("map-stage-close"),"isLocation", "map")
                                    Case Else
                                        CaptureRegion()
                                        If (isPixel(getPixelArg("back"), 20)) Then
                                            ;ADB_SendESC() ; use ESC instead of back. should be better than trying to constantly click back
                                            clickBackButton()
                                        Else

                                            If (TimerDiff($t_hTimer) > 30000) Then ExitLoop ; Failed to navigate

                                            ;Tries ADB send keyevent escape
                                            If (TimerDiff($t_hTimer) > 10000 And $g_bAdbWorking) Then
                                                ADB_SendESC()
                                                If (_Sleep(500)) Then ExitLoop(2)
                                            EndIf

                                            ;Usually stuck in place with an in game window and an Exit button for the window.
                                            skipDialogue()
                                            closeWindow()

                                            If (isLocation("unknown") And Mod(Int(TimerDiff($t_hTimer)/1000), 3) = 0) Then 
                                                clickPoint(getPointArg("tap"))
                                                If (_Sleep(1000)) Then ExitLoop(2)
                                            EndIf

                                            If (TimerDiff($t_hTimer) > 10000 And isLocation("unknown")) Then resetHandles()
                                        EndIf
                                EndSwitch
                            WEnd

                            If (isLocation("map")) Then 
                                $bOutput = True
                                ExitLoop
                            EndIf

                        Case "village"
                            ;Goes directly to map from village
                            Local $t_iTimerInit = TimerInit()
                            While Not(isLocation("map"))
                                If (_Sleep(500)) Then ExitLoop(2)
                                If (TimerDiff($t_iTimerInit) >= 30000) Then ExitLoop(2)
                                If (isLocation("loading")) Then ContinueLoop
                                if (isLocation("map")) Then ExitLoop
                                ;Handles clan notification and bingo popups.
                                clickWhile(getPointArg("village-play"), "isLocation", "village", 50, 400) ;click for 10 seconds
                                
                                skipDialogue()
                                closeWindow()
                            WEnd

                            $bOutput = True
                            ExitLoop
                        Case "loading", "dialogue-skip", "popup-window"
                            ContinueLoop
                        Case Else
                            if (isLocation("map")) Then ExitLoop(2)
                            ;Uses navigate village algorithm to easily go to map
                            If (navigate("village", $bForceSurrender)) Then ContinueLoop
                            ExitLoop
                    EndSwitch

                Case "golem-dungeons"
                    If (Not(isLocation("map"))) Then
                        If (Not(navigate("map", $bForceSurrender))) Then ExitLoop
                    EndIf

                    Local $aPoint = navigateWhileOnMap("Ancient Dungeon")
                    
                    If (isArray($aPoint)) Then $bOutput = clickWhile($aPoint, "isLocation", "map,dialogue-skip", 10, $g_iNavClickDelay)
                    If (waitLocationMS("ancient-colossus-dungeon", 450, 20)) Then clickPoint("200,250")
                    If (Not(waitLocation("golem-dungeons", 1))) Then
                        Switch getLocation()
                            Case "map-battle"
                                Local $bResult = clickUntil(getPointArg("back"), "isLocation", "golem-dungeons")
                                $bOutput = True    
                            Case "unknown", "colossus-dungeons"
                                Local $bResult = clickUntil(getPointArg("back"), "isLocation", "golem-dungeons")
                                $bOutput = True
                        EndSwitch
                    Else
                        $bOutput = True
                    EndIf

                    ExitLoop

                Case "quests"
                    Local $t_hTimer = TimerInit()
                    navigate("village", $bForceSurrender)
                    If (Not(isLocation("village"))) Then 
                        If (Not(navigate("village", $bForceSurrender))) Then ExitLoop
                    EndIf
                    Local $iCount = 0
                    While Not(isLocation("quests")) And $iCount < 50
                        HandleCommonLocations(getLocation())

                        clickPoint(getPointArg("village-quests"))
                        $iCount += 1
                        If (_Sleep(400)) Then ExitLoop
                    WEnd
                    If (isLocation("quests")) Then $bOutput = True

                    ExitLoop
                Case "catch-mode"
                    Local $t_hTimer = TimerInit()
                    While TimerDiff($t_hTimer) < 30000

                        Switch getLocation()
                            Case "battle-auto"
                                If isPixel(getPixelArg("battle-catch-available")) = False Then
                                    clickBattle()
                                Else
                                    If isPixel(getPixelArg("catch-mode-standby")) = False Then
                                        clickWhile(getPointArg("battle-catch"), "isPixel", CreateArr(getPixelArg("battle-catch-available"), 10), 5, 500, "captureRegion()")
                                    EndIf
                                EndIf
                            Case "battle"
                                If (isPixel(getPixelArg("catch-mode-unavailable")) = False And isPixel(getPixelArg("battle-catch-available"), 10)) And (isPixel(getPixelArg("catch-mode-standby") = False)) Then 
                                    clickPoint(getPointArg("battle-catch"))
                                EndIf
                            Case "catch-mode"
                                $bOutput = True
                                ExitLoop(2)
                            Case "unknown"
                            Case Else
                                If waitLocation("battle,battle-auto,catch-mode,unknown", 3) = False Then
                                    ExitLoop(2)
                                Else
                                    ContinueLoop
                                EndIf
                        EndSwitch

                        If _Sleep(500) Then ExitLoop(2)

                        ;Check if there is no astrochips left
                        CaptureRegion()
                        If IsPixel(getPixelArg("catch-mode-unavailable")) = True Then
                            If _Sleep(5000) Then ExitLoop(2)

                            CaptureRegion()
                            If IsPixel(getPixelArg("catch-mode-unavailable")) = True Then 
                                Data_Set("Astrochips", 0)
                                ExitLoop(2)
                            EndIf
                        EndIf
                    WEnd

                    ExitLoop
                Case "monsters"
                Local $navOutput = navigateToMonsters($bOutput, $bForceSurrender)
                    $bOutput = $navOutput[1]
                    Switch $navOutput[0]
                        Case -1
                            ExitLoop
                        Case -2
                            ContinueLoop
                        Case -3
                            ExitLoop(2)
                        Case -4
                            ContinueLoop(2)
                    EndSwitch
                Case "manage"
                    Switch $t_sCurrlocation
                        Case "gem-upgrade-not-upgrading"
                            If (clickUntil("780,130","isLocation","manage")) Then ContinueLoop
                    EndSwitch
                    If ($t_sCurrLocation <> "monsters") Then
                        If (Not(navigate("monsters", False))) Then
                            ExitLoop
                        EndIf
                    EndIf

                    Local $t_hTimer = TimerInit()
                    While TimerDiff($t_hTimer) < 10000
                        If (_Sleep(200)) Then ExitLoop(2)
                        clickPoint(getPointArg("monsters-manage"), 1, 0)
                        If (isLocation("manage")) Then
                            $bOutput = True
                            ExitLoop
                        EndIf  
                    WEnd

                    ExitLoop
                Case "dungeons"
                    If (isLocation("guardian-dungeons,starstone-dungeons,elemental-dungeons,special-guardian-dungeons,gold-dungeons,extra-dungeons,dungeon-info")) Then
                        If (isLocation("special-guardian-dungeons")) Then
                            If (Not(clickDrag($g_aDungeonsSwipeDown))) Then ExitLoop
                            
                            $bOutput = True
                            ExitLoop
                        EndIf
                    EndIf
                    If (Not(isLocation("map"))) Then
                        If (Not(navigate("map", $bForceSurrender))) Then ExitLoop
                    EndIf

                    Local $aPoint = navigateWhileOnMap("Dungeons")
                    
                    If (isArray($aPoint)) Then $bOutput = clickWhile($aPoint, "isLocation", "map,dialogue-skip", 10, $g_iNavClickDelay)

                    ExitLoop
                Case "guardian-dungeons", "starstone-dungeons", "elemental-dungeons", "special-guardian-dungeons", "gold-dungeons"
                    If (navigate("dungeons")) Then
                        clickUntil(getPointArg("dungeons-starstone"), "isLocation", "extra-dungeons,starstone-dungeons")

                        Local $aDungeon = Null ;Will contain the points for the dungeon
                        Switch $sLocation
                            Case "guardian-dungeons"
                                $aDungeon = getPointArg("dungeons-guardian")
                            Case "starstone-dungeons"
                                $aDungeon = getPointArg("dungeons-starstone")
                            Case "elemental-dungeons"
                                $aDungeon = getPointArg("dungeons-elemental")
                            Case "special-guardian-dungeons"
                                $aDungeon = getPointArg("dungeons-special")
                            Case "gold-dungeons"
                                $aDungeon = getPointArg("dungeons-gold")
                        EndSwitch

                        ; Handles point offset when Lucian dungeon event is on-going.
                        If (isLocation("extra-dungeons")) Then
                            $aDungeon = StringSplit(StringStripWS($aDungeon, $STR_STRIPALL), ",", $STR_NOCOUNT)
                            $aDungeon[1] += 64
                            If ($sLocation = "special-guardian-dungeons") Then
                                If (Not(clickDrag($g_aDungeonsSwipeUp))) Then ExitLoop
                                If (_Sleep(200)) Then ExitLoop
                                $aDungeon = findImage("map-special-dungeon",95,0,70,335,215,150,True,True)
                                If (Not(isArray($aDungeon))) Then ExitLoop
                            EndIf
                        EndIf
                        If ($sLocation = "special-guardian-dungeons") Then
                            If (clickUntil($aDungeon, "isLocation", $sLocation & ",dungeon-info", 10, 200)) Then 
                                If (isLocation("dungeon-info")) Then ExitLoop
                                $bOutput = True                                
                            EndIf
                        Else
                            If (clickUntil($aDungeon, "isLocation", $sLocation, 10, 200)) Then $bOutput = True
                        EndIf

                    EndIf
                    ExitLoop
                
                Case Else
                    ExitLoop
            EndSwitch
        WEnd
    WEnd

    Log_Add("Navigating result: " & $bOutput, $LOG_DEBUG)
    Log_Level_Remove()
    Return $bOutput
EndFunc

Func navigateWhileOnMap($sMapLocation)
    If (Not(isLocation("map"))) Then navigate("map")
    If (Not(waitLocation("map",5))) Then Return False
    Local $t_sMapLocation = StringReplace(StringLower($sMapLocation)," ","-")
    If ($t_sMapLocation <> "phantom-forest") Then
        Local $t_taMapCoords = findImage("map-" & $t_sMapLocation, 90, 100, 0, 0, 800, 552, True, True)
        If (isArray($t_taMapCoords)) Then 
            If ($t_sMapLocation = "ancient-dungeon") Then $t_taMapCoords[1] -= 40
            Return $t_taMapCoords
        Else
            If ($t_sMapLocation = "astromon-league") Then
                $t_taMapCoords = findImage("map-" & $t_sMapLocation & "-disabled", 90, 100, 0, 0, 800, 552, True, True)
                If (isArray($t_taMapCoords)) Then Return buildNavOutput(-1, False)
            EndIf
        EndIf
    EndIf
    Local $t_aMapCoords = findImage("map-phantom-forest", 90, 100, 0, 0, 800, 552, True, True)
    While Not(IsArray($t_aMapCoords))
        If (Not(clickDrag($g_aSwipeRight))) Then ExitLoop
        $t_aMapCoords = findImage("map-phantom-forest", 90, 100, 0, 0, 800, 552, True, True)
    Wend
    If ($t_sMapLocation = "phantom-forest") Then return $t_aMapCoords

    $t_aMapCoords = findImage("map-" & $t_sMapLocation, 90, 100, 0, 0, 800, 552, True, True)
    Local $t_hTimer = TimerInit()
    While Not(isArray($t_aMapCoords))
        If ($t_sMapLocation = "astromon-league") Then
                $t_aMapCoords = findImage("map-" & $t_sMapLocation & "-disabled", 90, 100, 0, 0, 800, 552, True, True)
                If (isArray($t_aMapCoords)) Then Return buildNavOutput(-1, False)
            EndIf
        If (_Sleep(10)) Then ExitLoop(3)
        If (TimerDiff($t_hTimer) > 30000) Then 
            Log_Add("Could not find map.", $LOG_ERROR)
            ExitLoop
        EndIf

        ;If map has not been found scrolls left
        If (Not(clickDrag($g_aSwipeLeft))) Then ExitLoop

        If (Not(isLocation("map"))) Then Return False ;Goes back to main loop if misclick happens
        $t_aMapCoords = findImage("map-" & $t_sMapLocation, 90, 100, 0, 0, 800, 552, True, True)
    WEnd
    If (Not(isArray($t_aMapCoords))) Then Return False
    If ($t_sMapLocation = "ancient-dungeon") Then $t_aMapCoords[1] -= 40
    Return $t_aMapCoords
EndFunc

#cs
Return values:
    -1 = ExitLoop
    -2 = ContinueLoop
    -3 = ExitLoop(2)
    -4 = ContinueLoop(2)
#ce

Func navigateToVillage($bOutput, $bForceSurrender)
    Local $t_sCurrLocation = getLocation()
    Switch $t_sCurrLocation
        Case "village"
            Return buildNavOutput(-1, True)
        Case "battle-end", "pvp-battle-end"
            ;Goes directly from battle-end to village
            $bOutput = navigateFromBattleEnd("village", $bOutput)
            Return buildNavOutput(-1, $bOutput)
        Case "tap-to-start", "event-list", "dialogue-skip", "quit", "unknown"
            Return buildNavOutput(-2, $bOutput)
        Case "map"
            ADB_SendESC()
            _Sleep(100)
            Return buildNavOutput(-2, $bOutput)
        Case Else
            ;All other locations will need either click back or esc to get to village.
            Local $t_hTimer = TimerInit() 
            While Not(isLocation("village"))
                If (_Sleep(10)) Then Return buildNavOutput(-3, $bOutput)
                If (TimerDiff($t_hTimer) > 60000) Then Return buildNavOutput(-3, $bOutput)

                $t_sCurrLocation = getCurrentLocation()
                Switch $t_sCurrLocation
                    Case "hourly-reward"
                        clickWhile(getPointArg("get-reward"), "isLocation", "hourly-reward", 10, 100)
                        Return buildNavOutput(-4, $bOutput)
                    Case "quit", "hero-fest-popup", "player-info", "master-info"
                        closeWindow()
                        Return buildNavOutput(-4, $bOutput)
                    Case "loading"
                        If (_Sleep(200)) Then Return buildNavOutput(-3, $bOutput)
                        $t_hTimer = TimerInit()
                    Case Else
                        If (isPixel(getPixelArg("back"), 20)) Then
                            ;adbSendESC() ; use ESC instead of back. should be better than trying to constantly click back
                            clickBackButton()
                        Else

                            If (TimerDiff($t_hTimer) > 30000) Then Return buildNavOutput(-1, $bOutput) ; Failed to navigate

                            ;Tries ADB send keyevent escape
                            If (TimerDiff($t_hTimer) > 10000 And $g_bAdbWorking = True) Then
                                ADB_SendESC()
                                If (_Sleep(500)) Then Return buildNavOutput(-3, $bOutput)
                            EndIf

                            ;Usually stuck in place with an in game window and an Exit button for the window.
                            skipDialogue()
                            closeWindow()

                            If (isLocation("unknown") And (Mod(Int(TimerDiff($t_hTimer)/1000), 3) = 0)) Then 
                                clickPoint(getPointArg("tap"))
                                If (_Sleep(1000)) Then Return buildNavOutput(-3, $bOutput)
                            EndIf

                            If (TimerDiff($t_hTimer) > 10000 And isLocation("unknown")) Then resetHandles()
                        EndIf
                EndSwitch
            WEnd
            
            $bOutput = isLocation("village")
            Return buildNavOutput(-1, $bOutput)
    EndSwitch
EndFunc

Func navigateToMonsters($bOutput, $bForceSurrender)
    Local $aOutput[2]
    Local $t_hTmpTimer = TimerInit()
    While Not(isLocation("monsters")) And TimerDiff($t_hTmpTimer) < 15000
        Local $t_sCurrLocation = getLocation()

        Switch $t_sCurrlocation
            Case "monsters-awaken", "monsters-evolve", "monsters-astromon"
                If (closeWindow()) Then ContinueCase
            Case "monsters-evolution", "monsters-level-up", "monsters-level-up-max"
                If (clickUntil("774,113", "isLocation", "monsters", 5, 500)) Then Return buildNavOutput(-1, True)
            Case "gem-upgrade-not-upgrading"
                If (clickUntil("780,130","isLocation","manage")) Then ContinueLoop
            Case "manage"
                If (clickUntil("780,130","isLocation","monsters")) Then Return buildNavOutput(-1, True)
            Case "battle-end"
                navigateFromBattleEnd("monsters",$aOutput[1])
                ContinueLoop
        EndSwitch

        If ($t_sCurrLocation <> "village") Then
            If (Not(navigate("village", $bForceSurrender))) Then Return buildNavOutput(-1, False)
        EndIf

        Local $t_hTimer = TimerInit()
        Local $bResult = False
        While TimerDiff($t_hTimer) < 15000
            If (_Sleep(200)) Then Return buildNavOutput(-3, False)
            clickPoint(getPointArg("village-monsters"))
            If (isLocation("monsters")) Then
                $bResult = True
                ExitLoop
            EndIf
        WEnd

        If $bResult = True Then
            Local $t_hTimer = TimerInit()
            While Not(isPixel("133,19,0xF6C02A", 20))
                If (_Sleep(200)) Then Return buildNavOutput(-3, False)
                If (TimerDiff($t_hTimer) > 5000) Then Return buildNavOutput(-1, False)
                clickPoint(getPointArg("monsters-grid"), 1, 0)
                CaptureRegion()
            WEnd

            Local $t_hTimer = TimerInit()
            While Not(isPixel("266,471,0x34F09B", 20))
                If (_Sleep(200)) Then Return buildNavOutput(-3, False)
                If (TimerDiff($t_hTimer) > 5000) Then Return buildNavOutput(-1, False)
                clickPoint(getPointArg("monsters-recent"), 1, 0)
                CaptureRegion()
            WEnd
            clickPoint(getPointArg("monsters-grid-first"), 3) ;Clicks first astromon in grid.
            
            Return buildNavOutput(-1, True)
        EndIf
    WEnd
    Return buildNavOutput(0, True)
EndFunc

Func navigateFromBattleEnd($sToLocation, $bOutput)
    Local $t_aClickPos, $t_sPositionInfo
    Switch $sToLocation
        Case "village"
            $t_sPositionInfo = "airship"
        Case "map"
            $t_sPositionInfo = "map"
        Case "monsters"
            $t_sPositionInfo = "monsters"
        Case Else
            Return -1
    EndSwitch
    $t_aClickPos = getPointArg("battle-end-" & $t_sPositionInfo)
    If (clickUntil($t_aClickPos, "isLocation", $sToLocation & ",loading,unknown", 10, 3000)) Then $bOutput = waitLocation($sToLocation, 60)
    Return $bOutput
EndFunc

Func buildNavOutput($outputCode, $bOutput)
    Local $aOutput[2]
    $aOutput[0] = $outputCode
    $aOutput[1] = $bOutput
    Return $aOutput
EndFunc
