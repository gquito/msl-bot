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
    Log_Level_Add("navigate")
    Log_Add("Navigating to " & $sLocation & ".")

    Local $bOutput = False ;Error code

    While $iAttempt > 0
        If _Sleep(0) Or ($bOutput = True) Then ExitLoop
        $iAttempt -= 1

        Local $t_sCurrLocation ;Will store current location.
        $sLocation = StringStripWS(StringLower($sLocation), $STR_STRIPALL)

        While $t_sCurrLocation <> $sLocation
            If _Sleep(0) Then ExitLoop
            CaptureRegion()
            $t_sCurrLocation = getLocation($g_aLocations, False)
            If $t_sCurrLocation = "pvp-battle-end" Then $t_sCurrLocation = "battle-end" ;Location has the same functions.

            If $t_sCurrLocation = $sLocation Then
                $bOutput = True
                ExitLoop
            EndIf

            ;Handles force surrender 
            Switch $t_sCurrLocation
                Case "manage", "monsters-evolution", "monsters-level-up"
                    clickUntil(getArg($g_aPoints, "manage-x"), "isLocation", "monsters", 3, 2000)
                Case "defeat" 
                    If clickUntil(getArg($g_aPoints, "battle-give-up"), "isLocation", "unknown,battle-end-exp,battle-sell,battle-sell-item,battle-end") = True Then
                        If clickUntil(getArg($g_aPoints, "tap"), "isLocation", "battle-end", 1000, 120) = False Then ExitLoop(2)
                    Else
                        ExitLoop
                    EndIf
                Case "catch-success"
                    If $bForceSurrender = True Then
                        Local $t_sLoc = ""

                        While $t_sLoc <> "pause" And $t_sLoc <> "battle"
                            If $g_bAdbWorking Then adbSendESC()
                            If _Sleep(50) Then ExitLoop(2)

                            CaptureRegion()
                            $t_sLoc = getLocation($g_aLocations, False)
                        WEnd
                        ContinueCase
                    EndIf
                Case "battle", "battle-auto", "catch-mode", "pause"
                    If $bForceSurrender = True Then
                        ;Force surrender algorithm
                        If clickUntil(getArg($g_aPoints, "battle-pause"), "isLocation", "pause", 200, 100) = True Then
                            clickWhile(getArg($g_aPoints, "battle-give-up"), "isLocation", "pause,unknown", 100, 100)
                        EndIf

                        ;Sets up for normal locations
                        If clickUntil(getArg($g_aPoints, "tap"), "isLocation", "battle-end,astroleague", 1000, 120) = False Then ExitLoop(2)
                    Else   
                        ;Only catch-mode will need to be in one of the locations above.
                        If $sLocation <> "catch-mode" Then ExitLoop
                    EndIf
                Case "battle-end-exp", "battle-sell", "battle-sell-item", "astroleague-defeat", "astroleague-victory"
                    Local $t_iError = 0 ;Counts errors
                    While $t_iError < 4
                        If _Sleep(10) Then ExitLoop(2)
                        If clickUntil(getArg($g_aPoints, "tap"), "isLocation", "battle-end,battle-sell-item", 1000, 120) Then
                            If getLocation($g_aLocations, False) = "battle-sell-item" Then
                                clickUntil(getArg($g_aPoints, "battle-sell-item-cancel"), "isLocation", "battle-end,pvp-battle-end", 2, 500)
                                clickUntil(getArg($g_aPoints, "battle-sell-item-okay"), "isLocation", "battle-end,pvp-battle-end", 2, 500)

                                $t_iError += 1
                            ElseIf getLocation($g_aLocations, False) = "battle-end" Or getLocation($g_aLocations, False) = "pvp-battle-end" Then
                                ExitLoop
                            Else
                                $t_iError += 1
                            EndIf
                        Else
                            $t_iError += 1
                        EndIf
                    WEnd

                Case "tap-to-start"
                    If clickWhile("394,469", "isLocation", "tap-to-start", 10, 2000) = False Then
                        ExitLoop
                    Else
                        ContinueLoop
                    EndIf

                Case "event-list"
                    If clickUntil("776,20", "isLocation", "loading,unknown", 10, 2000) Then
                        ExitLoop
                    Else
                        ContinueLoop
                    EndIf

            EndSwitch

            If ($sLocation = "battle-end") And (getLocation() = "battle-end") Then
                $bOutput = True
                ExitLoop
            EndIf

            ;Handles normal locations
            Switch $sLocation
                Case "village"
                    Switch $t_sCurrLocation
                        Case "battle-end"
                            ;Goes directly from battle-end to village
                            If clickUntil(getArg($g_aPoints, "battle-end-airship"), "isLocation", "village,loading", 600, 100) = True Then
                                $bOutput = waitLocation("village", 60, True)
                            EndIf
                            ExitLoop
                        Case "tap-to-start", "event-list"
                            ContinueLoop
                        Case Else
                            ;All other locations will need either click back or esc to get to village.
                            Local $t_hTimer = TimerInit() 
                            While getLocation() <> "village"
                                If _Sleep(10) Then ExitLoop(2)
                                If TimerDiff($t_hTimer) > 60000 Then ExitLoop(2) 

                                $t_sCurrLocation = getLocation($g_aLocations, False)
                                Switch $t_sCurrLocation
                                    Case "hourly-reward"
                                        clickWhile(getArg($g_aPoints, "get-reward"), "isLocation", "hourly-reward", 10, 100)
                                        ContinueLoop(2)
                                    Case "battle-end", "quit", "tap-to-start", "event-list"
                                        closeWindow()
                                        ContinueLoop(2)
                                    Case "loading"
                                        If _Sleep(200) Then ExitLoop(2)
                                        $t_hTimer = TimerInit()
                                    Case Else
                                        CaptureRegion()
                                        If isPixel(getArg($g_aPixels, "back"), 20) = True Then
                                            clickPoint(getArg($g_aPoints, "back"))
                                        Else

                                            If TimerDiff($t_hTimer) > 30000 Then ExitLoop ; Failed to navigate

                                            ;Tries ADB send keyevent escape
                                            If (TimerDiff($t_hTimer) > 10000) And ($g_bAdbWorking = True) Then
                                                adbSendESC()
                                                If _Sleep(500) Then ExitLoop(2)
                                            EndIf

                                            ;Usually stuck in place with an in game window and an Exit button for the window.
                                            closeWindow()
                                            skipDialogue()

                                            If (getLocation() = "unknown") And (Mod(Int(TimerDiff($t_hTimer)/1000), 3) = 0) Then 
                                                clickPoint(getArg($g_aPoints, "tap"))
                                                If _Sleep(1000) Then ExitLoop(2)
                                            EndIf

                                            If (TimerDiff($t_hTimer) > 10000) And (getLocation() = "unknown") Then
                                                resetHandles()
                                            EndIf
                                        EndIf
                                EndSwitch
                            WEnd
                            
                            $bOutput = (getLocation() = "village")
                            ExitLoop
                    EndSwitch
                Case "map"
                    Switch $t_sCurrLocation
                        Case "battle-end"
                            ;Goes directly from battle-end to map
                            If clickUntil(getArg($g_aPoints, "battle-end-map"), "isLocation", "loading,map", 600, 100) = True Then
                                If waitLocation("map,village", 60) = "village" Then
                                    ContinueLoop
                                Else
                                    $bOutput = (getLocation() = "map")
                                EndIf
                            EndIf
                            ExitLoop
                            
                        Case "map-battle", "map-stage", "association", "clan", "toc", "astroleague", "starstone-dungeons", "golem-dungeons", "gold-dungeons", "elemental-dungeons"
                            Local $t_hTimer = TimerInit() 
                            While getLocation() <> "map"
                                If _Sleep(10) Then ExitLoop(2)
                                If TimerDiff($t_hTimer) > 60000 Then ExitLoop(2) ;30 seconds
                                    
                                $t_sCurrLocation = getLocation($g_aLocations, False)
                                Switch $t_sCurrLocation
                                    Case "village", "battle-end", "quit", "tap-to-start", "event-list"
                                        closeWindow()
                                        ContinueLoop(2)
                                    Case "loading"
                                        If _Sleep(200) Then ExitLoop(2)
                                        $t_hTimer = TimerInit()
                                    Case Else
                                        CaptureRegion()
                                        If isPixel(getArg($g_aPixels, "back"), 20) = True Then
                                            clickPoint(getArg($g_aPoints, "back"))
                                        Else

                                            If TimerDiff($t_hTimer) > 30000 Then ExitLoop ; Failed to navigate

                                            ;Tries ADB send keyevent escape
                                            If (TimerDiff($t_hTimer) > 10000) And ($g_bAdbWorking = True) Then
                                                adbSendESC()
                                                If _Sleep(500) Then ExitLoop(2)
                                            EndIf

                                            ;Usually stuck in place with an in game window and an Exit button for the window.
                                            closeWindow()
                                            skipDialogue()

                                            If (getLocation() = "unknown") And (Mod(Int(TimerDiff($t_hTimer)/1000), 3) = 0) Then 
                                                clickPoint(getArg($g_aPoints, "tap"))
                                                If _Sleep(1000) Then ExitLoop(2)
                                            EndIf

                                            If (TimerDiff($t_hTimer) > 10000) And (getLocation() = "unknown") Then
                                                resetHandles()
                                            EndIf
                                        EndIf
                                EndSwitch
                            WEnd

                            If getLocation($g_aLocations, False) = "map" Then 
                                $bOutput = True
                                ExitLoop
                            EndIf

                        Case "village"
                            ;Goes directly to map from village
                            Local $t_iTimerInit = TimerInit()
                            While getLocation() <> "map"
                                If _Sleep(500) Then ExitLoop(2)
                                If TimerDiff($t_iTimerInit) >= 30000 Then ExitLoop(2)
                                If getLocation() = "loading" Then ExitLoop

                                ;Handles clan notification and bingo popups.
                                clickWhile(getArg($g_aPoints, "village-play"), "isLocation", "village", 50, 200) ;click for 10 seconds
                                
                                skipDialogue()
                                closeWindow()
                            WEnd

                            $bOutput = True
                            ExitLoop
                        Case Else
                            ;Uses navigate village algorithm to easily go to map
                            If navigate("village", $bForceSurrender) = True Then ContinueLoop
                            ExitLoop
                    EndSwitch

                Case "golem-dungeons"
                    If $t_sCurrLocation <> "map" Then
                        If navigate("map", $bForceSurrender) = False Then
                            ExitLoop
                        EndIf
                    EndIf

                    ;Scrolling through map to find ancient dungeon place.
                    Local $aPoint = getMapCoor("Ancient Dungeon") ;Coordinates of found map.

                    Local $t_hTimer = TimerInit()
                    While isArray($aPoint) = False
                        If _Sleep(10) Then ExitLoop(2)
                        If TimerDiff($t_hTimer) > 30000 Then 
                            ExitLoop(2)
                        EndIf

                        ;If map has not been found scrolls left
                        clickDrag($g_aSwipeLeft)

                        If getLocation() <> "map" Then navigate("map", $bForceSurrender) ;Goes back to main loop if misclick happens
                        $aPoint = getMapCoor("Ancient Dungeon")
                    WEnd
                    
                    If clickWhile($aPoint, "isLocation", "map", 50, 200) = False Then
                        ExitLoop
                    Else
                        If getLocation() <> "golem-dungeons" Then
                            If getLocation($g_aLocations, False) = "map-battle" Then 
                                Local $bResult = clickUntil(getArg($g_aPoints, "back"), "isLocation", "golem-dungeons")
                                $bOutput = True 
                            ElseIf getLocation($g_aLocations, False) = "unknown" Or getLocation($g_aLocations, False) = "colossus-dungeons" Then
                                Local $bResult = clickUntil(getArg($g_aPoints, "ancient-dungeon-golem"), "isLocation", "golem-dungeons")
                                $bOutput = True
                            EndIf
                        Else
                            $bOutput = True
                        EndIf

                        ExitLoop
                    EndIf
                Case "quests"
                    If $t_sCurrLocation <> "village" Then
                        If navigate("village", $bForceSurrender) = False Then
                            ExitLoop
                        EndIf
                    EndIf

                    If clickUntil(getArg($g_aPoints, "village-quests"), "isLocation", "quests", 50, 200) = True Then
                        $bOutput = True
                        ExitLoop
                    Else
                        ExitLoop
                    EndIf

                Case "catch-mode"
                    Local $t_hTimer = TimerInit()
                    While TimerDiff($t_hTimer) < 30000
                        Switch getLocation()
                            Case "battle-auto"
                                If isPixelOR("162,509,0x612C22/340,507,0x612C22/513,520,0x612C22/683,520,0x612C22", 10) = False Then
                                    clickPoint(getArg($g_aPoints, "battle-auto"))
                                Else
                                    clickPoint(getArg($g_aPoints, "battle-catch"))
                                EndIf
                            Case "battle"
                                ;Looking for red hp pixels to that indicates if can click into catch-mode.
                                If isPixelOR("162,509,0x612C22/340,507,0x612C22/513,520,0x612C22/683,520,0x612C22", 10) = True Then
                                    clickPoint(getArg($g_aPoints, "battle-catch"))
                                EndIf
                            Case "catch-mode"
                                $bOutput = True
                                ExitLoop(2)
                            Case "unknown"
                            Case Else
                                If waitLocation("battle,battle-auto,catch-mode,unknown", 3) <> "" Then ContinueLoop
                                ExitLoop(2)
                        EndSwitch

                        If _Sleep(500) Then ExitLoop(2)

                        CaptureRegion()
                        If isPixel("746,267,0xBF332A") Then
                            If _Sleep(5000) Then ExitLoop(2)

                            CaptureRegion()
                            If isPixel("746,267,0xBF332A") Then 
                                Data_Set("Astrochips", 0)
                                ExitLoop(2)
                            EndIf
                        EndIf
                    WEnd

                    ExitLoop
                Case "monsters"
                    Switch $t_sCurrlocation
                        Case "monsters-awaken", "monsters-evolve", "monsters-astromon"
                            If closeWindow() = True Then ContinueCase
                        Case "monsters-evolution"
                            $bOutput = clickUntil("774,113", "isLocation", "monsters", 5, 500, Null)
                            If $bOutput = True Then ExitLoop
                    EndSwitch

                    If $t_sCurrLocation <> "village" Then
                        If navigate("village", $bForceSurrender) = False Then
                            ExitLoop
                        EndIf
                    EndIf

                    Local $t_hTimer = TimerInit()
                    Local $bResult = False
                    While TimerDiff($t_hTimer) < 15000
                        If _Sleep(200) Then ExitLoop(2)
                        clickPoint(getArg($g_aPoints, "village-monsters"))
                        If getLocation() = "monsters" Then
                            $bResult = True
                            ExitLoop
                        EndIf
                    WEnd

                    If $bResult = True Then
                        Local $t_hTimer = TimerInit()
                        While isPixel("133,19,0xF6C02A", 20) = False
                            If _Sleep(200) Then ExitLoop(2)
                            If TimerDiff($t_hTimer) > 5000 Then ExitLoop
                            clickPoint(getArg($g_aPoints, "monsters-grid"), 1, 0, Null)
                            CaptureRegion()
                        WEnd

                        Local $t_hTimer = TimerInit()
                        While isPixel("266,471,0x34F09B", 20) = False
                            If _Sleep(200) Then ExitLoop(2)
                            If TimerDiff($t_hTimer) > 5000 Then ExitLoop
                            clickPoint(getArg($g_aPoints, "monsters-recent"), 1, 0, Null)
                            CaptureRegion()
                        WEnd
                        clickPoint("49,152", 3) ;Clicks first astromon in grid.
                        
                        $bOutput = True
                        ExitLoop
                    Else
                    EndIf
                Case "manage"
                    If $t_sCurrLocation <> "monsters" Then
                        If navigate("monsters", False) = False Then
                            ExitLoop
                        EndIf
                    EndIf

                    Local $t_hTimer = TimerInit()
                    Local $bResult = False
                    While TimerDiff($t_hTimer) < 10000
                        If _Sleep(200) Then ExitLoop(2)
                        clickPoint(getArg($g_aPoints, "monsters-manage"), 1, 0, Null)
                        If getLocation() = "manage" Then
                            $bResult = True
                            ExitLoop
                        EndIf  
                    WEnd

                    If $bResult = True Then
                        $bOutput = True
                        ExitLoop
                    Else
                        ExitLoop
                    EndIf
                Case "guardian-dungeons", "starstone-dungeons", "elemental-dungeons", "special-guardian-dungeons", "gold-dungeons"
                    If getLocation() = "map" Then
                        Local $t_hTimer = TimerInit()
                        While (isArray(getMapCoor("Phantom Forest")) = False) And (TimerDiff($t_hTimer) < 10000)
                            clickDrag($g_aSwipeRight)
                        WEnd
                        clickDrag($g_aSwipeRight)
                    Else
                        If navigate("map", $bForceSurrender) = False Then
                            ExitLoop
                        EndIf
                    EndIf

                    CaptureRegion()
                    Local $aPoint = getMapCoor("Dungeons") ;Coordinates of found map.
                    If isArray($aPoint) = True Then

                    If clickWhile($aPoint, "isLocation", "map", 50, 200) = True Then
                            clickUntil(getArg($g_aPoints, "dungeons-starstone"), "isLocation", "extra-dungeons,starstone-dungeons")

                            Local $aDungeon = Null ;Will contain the points for the dungeon
                            Switch $sLocation
                                Case "guardian-dungeons"
                                    $aDungeon = getArg($g_aPoints, "dungeons-guardian")
                                Case "starstone-dungeons"
                                    $aDungeon = getArg($g_aPoints, "dungeons-starstone")
                                Case "elemental-dungeons"
                                    $aDungeon = getArg($g_aPoints, "dungeons-elemental")
                            EndSwitch

                            ; Handles point offset when Lucian dungeon event is on-going.
                            If getLocation() = "extra-dungeons" Then
                                $aDungeon = StringSplit(StringStripWS($aDungeon, $STR_STRIPALL), ",", $STR_NOCOUNT)
                                $aDungeon[1] += 64
                            EndIf

                            $bResult = clickUntil($aDungeon, "isLocation", $sLocation, 10, 200)
                            If $bResult = True Then
                                $bOutput = True
                                ExitLoop
                            Else
                                ExitLoop
                            EndIf
                        EndIf

                        ExitLoop
                    Else
                        ExitLoop
                    EndIf
                Case Else
                    ExitLoop
            EndSwitch
        WEnd
    WEnd

    Log_Add("Navigating result: " & $bOutput, $LOG_DEBUG)
    Log_Level_Remove()
    Return $bOutput
EndFunc