#include-once
#include "../../imports.au3"

#cs 
    Function: Script to navigate locations in MSL game.
    Parameters:
        $sLocation: One of the locations.
        $bForceSurrender: If in battle will surrender the match
    Returns: 
        if success, true
        if fail, false
#ce
Func navigate($sLocation, $bForceSurrender = False)
    Log_Level_Add("navigate")
    Log_Add("Navigating to " & $sLocation & ".")

    Local $bOutput = False ;Error code

    Local $t_sCurrLocation ;Will store current location.
    $sLocation = StringStripWS(StringLower($sLocation), $STR_STRIPALL)

    While $t_sCurrLocation <> $sLocation
        If _Sleep(10) Then ExitLoop
        $t_sCurrLocation = getLocation()

        If $t_sCurrLocation = $sLocation Then
            $bOutput = True
            ExitLoop
        EndIf

        ;Handles force surrender 
        Switch $t_sCurrLocation
            Case "defeat" 
                If clickUntil(getArg($g_aPoints, "battle-give-up"), "isLocation", "unknown,battle-end-exp,battle-sell,battle-sell-item,battle-end") = True Then
                    If clickUntil(getArg($g_aPoints, "tap"), "isLocation", "battle-end", 1000, 120) = False Then ExitLoop(2)
                Else
                    ExitLoop
                EndIf
            Case "battle", "battle-auto", "catch-mode", "pause"
                If $bForceSurrender = True Then
                    ;Force surrender algorithm
                    If clickUntil(getArg($g_aPoints, "battle-pause"), "isLocation", "pause", 200, 100) = True Then
                        clickWhile(getArg($g_aPoints, "battle-give-up"), "isLocation", "pause,unknown", 100, 100)
                    EndIf

                    ;Sets up for normal locations
                    If clickUntil(getArg($g_aPoints, "tap"), "isLocation", "battle-end", 1000, 120) = False Then ExitLoop(2)
                Else   
                    ;Only catch-mode will need to be in one of the locations above.
                    If $sLocation <> "catch-mode" Then ExitLoop
                EndIf
            Case "battle-end-exp", "battle-sell", "battle-sell-item"
                Local $t_iError = 0 ;Counts errors
                While $t_iError < 4
                    If _Sleep(10) Then ExitLoop(2)
                    If clickUntil(getArg($g_aPoints, "tap"), "isLocation", "battle-end,battle-sell-item", 1000, 120) Then
                        If getLocation($g_aLocations, False) = "battle-sell-item" Then
                            clickPoint(getArg($g_aPoints, "battle-sell-item-cancel"))
                            clickPoint(getArg($g_aPoints, "battle-sell-item-okay"))

                            $t_iError += 1
                        ElseIf getLocation($g_aLocations, False) = "battle-end" Then
                            ExitLoop
                        Else
                            $t_iError += 1
                        EndIf
                    Else
                        $t_iError += 1
                    EndIf
                WEnd

            Case "tap-to-start"
                clickPoint("394,469", 3, 1000)
                If _Sleep(2000) Then ExitLoop
                ContinueLoop

            Case "event-list"
                clickPoint("776,20", 3, 1000)
                If _Sleep(2000) Then ExitLoop
                ContinueLoop
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
                        clickUntil(getArg($g_aPoints, "battle-end-airship"), "isLocation", "unknown,village,loading", 600, 100) ;60 seconds of clicking.
                        
                        $bOutput = waitLocation("village", 60, True) ;waits for map location for 60 seconds
                        ExitLoop
                    Case Else
                        ;All other locations will need either click back or esc to get to village.

                        Local $t_hTimer = TimerInit() 
                        While getLocation() <> "village"
                            If getLocation($g_aLocations, False) = "hourly-reward" Then 
                                clickWhile(getArg($g_aPoints, "get-reward"), "isLocation", "hourly-reward")
                                ContinueLoop(2)
                            EndIf

                            If getLocation($g_aLocations, False) = "battle-end" Then ContinueLoop(2)
                            If TimerDiff($t_hTimer) > 30000 Then ExitLoop(2) 
                                
                            ;Handles back or esc
                            If isPixel(getArg($g_aPixels, "back"), 20) = True Then
                                clickPoint(getArg($g_aPoints, "back"))
                            Else
                                ;Usually stuck in place with an in game window and an Exit button for the window.
                                closeWindow()
                                skipDialogue()

                                clickPoint(getArg($g_aPoints, "tap"))

                                ;Tries ADB send keyevent escape
                                If TimerDiff($t_hTimer) > 10000 Then
                                    If (FileExists($g_sAdbPath) = True) And (StringInStr(adbCommand("get-state"), "error") = False) Then
                                        If getLocation() <> "unknown" Then ContinueLoop(2)
                                        adbCommand("shell input keyevent ESCAPE")
                                    EndIf
                                EndIf
                             EndIf

                            If _Sleep(100) Then ExitLoop(2)
                        WEnd

                        $bOutput = True
                        ExitLoop
                EndSwitch
            Case "map"
                Switch $t_sCurrLocation
                    Case "battle-end"
                        ;Goes directly from battle-end to map
                        clickUntil(getArg($g_aPoints, "battle-end-map"), "isLocation", "unknown,map", 60, 1000) ;60 seconds of clicking.
                        
                        $bOutput = waitLocation("map", 60, True) ;waits for map location for 60 seconds
                        ExitLoop
                    Case "map-battle", "map-stage", "association", "clan", "toc"
                        Local $t_vTimerInit = TimerInit() 
                        While getLocation() <> "map"
                            If getLocation($g_aLocations, False) = "village" Then ContinueLoop(2)
                            If TimerDiff($t_vTimerInit) > 30000 Then ExitLoop(2) ;30 seconds
                                
                            ;Handles back or esc
                            If (isPixel(getArg($g_aPixels, "back"), 20) = True) And (getLocation($g_aLocations, False) <> "map-stage") Then
                                clickPoint(getArg($g_aPoints, "back"))
                            Else
                                ;Usually stuck in place with an in game window and an Exit button for the window.
                                closeWindow()
                                skipDialogue()

                                clickPoint(getArg($g_aPoints, "tap"))

                                ;Tries ADB send keyevent escape
                                If TimerDiff($t_vTimerInit) > 10000 Then
                                    If (FileExists($g_sAdbPath) = True) And (StringInStr(adbCommand("get-state"), "error") = False) Then
                                        adbCommand("shell input keyevent ESCAPE")
                                        If getLocation() <> "unknown" Then ContinueLoop(2)
                                    EndIf
                                EndIf
                             EndIf

                            If _Sleep(100) Then ExitLoop(2)
                        WEnd

                        If getLocation($g_aLocations, False) = "map" Then 
                            $bOutput = True
                            ExitLoop
                        EndIf
                    Case "village"
                        ;Goes directly to map from village
                        Local $t_iTimerInit = TimerInit()

                        While getLocation() <> "map" 
                            If TimerDiff($t_iTimerInit) >= 180000 Then ExitLoop(2) ;3 minutes

                            ;Handles clan notification and bingo popups.
                            clickWhile(getArg($g_aPoints, "village-play"), "isLocation", "village", 50, 200) ;click for 10 seconds

                            skipDialogue()
                            closeWindow()

                            clickPoint(getArg($g_aPoints, "tap"))
                            If _Sleep(100) Then ExitLoop(2)
                        WEnd

                        $bOutput = True
                        ExitLoop
                    Case Else
                        If _Sleep(10) Then ExitLoop

                        ;Uses navigate village algorithm to easily go to map

                        Local $t_bResult = navigate("village", $bForceSurrender)
                        If $t_bResult = False Then 
                            ExitLoop
                        EndIf

                        If _Sleep(10) Then ExitLoop
                        $bOutput = navigate("map", $bForceSurrender) ;waits for map location for 60 seconds
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

					If getLocation() <> "map" Then navigate("map", False) ;Goes back to main loop if misclick happens
					$aPoint = getMapCoor("Ancient Dungeon")
				WEnd
                
				If clickWhile($aPoint, "isLocation", "map", 50, 200) = False Then
					ExitLoop
                Else
					If getLocation() <> "golem-dungeons" Then
                        If getLocation($g_aLocations, False) = "map-battle" Then 
                            Local $bResult = clickUntil(getArg($g_aPoints, "back"), "isLocation", "golem-dungeons")
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
                WEnd

                ExitLoop
            Case "monsters"
                If $t_sCurrLocation <> "village" Then
                    If navigate("village", False) = False Then
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
            Case "guardian-dungeons", "starstone-dungeons", "elemental-dungeons"
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
                        Local $aDungeon = Null ;Will contain the points for the dungeon
                        Switch $sLocation
                            Case "guardian-dungeons"
                                $aDungeon = getArg($g_aPoints, "dungeons-guardian")
                            Case "starstone-dungeons"
                                $aDungeon = getArg($g_aPoints, "dungeons-starstone")
                            Case "elemental-dungeons"
                                $aDungeon = getArg($g_aPoints, "dungeons-elemental")
                        EndSwitch

                        $bResult = clickUntil($aDungeon, "isLocation", $sLocation, 50, 200)
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
            
            Case "astroleague"
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
                Local $aPoint = getMapCoor("Astromon League") ;Coordinates of found map.
                If isArray($aPoint) = True Then

                    If clickWhile($aPoint, "isLocation", "map", 50, 200) = True Then
                        $bOutput = waitLocation("astroleague", 20)
                        ExitLoop
                    EndIf
                Else
                    ExitLoop
                EndIf

            Case Else
                ExitLoop
        EndSwitch
    WEnd

    Log_Add("Navigating result: " & $bOutput, $LOG_DEBUG)
    Log_Level_Remove()
    Return $bOutput
EndFunc