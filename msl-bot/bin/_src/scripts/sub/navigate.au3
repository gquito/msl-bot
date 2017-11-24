#include-once
#include "../../imports.au3"

#cs 
    Function: Script to navigate locations in MSL game.
    Parameters:
        $sLocation: One of the locations.
        $bForceSurrender: If in battle will surrender the match
        $bLog: Show log or not
    Returns: Boolean if successful or not.
#ce
Func navigate($sLocation, $bForceSurrender = False, $bLog = True)
    Local $t_sCurrLocation ;Will store current location.
    
    If $bLog Then addLog($g_aLog, "Navigating to '" & $sLocation & "'.", $LOG_NORMAL)
    $sLocation = StringStripWS(StringLower($sLocation), $STR_STRIPALL)

    While $t_sCurrLocation <> $sLocation
        If _Sleep(10) Then Return False
        $t_sCurrLocation = getLocation()
        If $t_sCurrLocation = $sLocation Then Return True

        ;Handles force surrender 
        Switch $t_sCurrLocation
            Case "defeat" 
                If clickUntil(getArg($g_aPoints, "battle-give-up"), "isLocation", "unknown,battle-end-exp,battle-sell,battle-sell-item,battle-end") = True Then
                    ;Sets up for normal locations
                    Local $t_iTimerInit = TimerInit()

                    While $t_sCurrLocation <> "battle-end"
                        If TimerDiff($t_iTimerInit) >= 120000 Then Return False ;2 Minutes, prevents infinite loop.

                        clickPoint(getArg($g_aPoints, "tap"))
                        If _Sleep(1000) Then Return False

                        $t_sCurrLocation = getLocation()
                    WEnd
                Else
                    Return False
                EndIf
            Case "battle", "battle-auto", "catch-mode", "pause"
                If $bForceSurrender = True Then
                    If $bLog Then addLog($g_aLog, "-Forcing to surrender.", $LOG_NORMAL)

                    ;Force surrender algorithm
                    If clickUntil(getArg($g_aPoints, "battle-pause"), "isLocation", "pause", 150, 200) = True Then
                        clickWhile(getArg($g_aPoints, "battle-give-up"), "isLocation", "pause,unknown", 10, 200)
                    EndIf

                    ;Sets up for normal locations
                    Local $t_iTimerInit = TimerInit()

                    While $t_sCurrLocation <> "battle-end"
                        If TimerDiff($t_iTimerInit) >= 120000 Then Return False ;2 Minutes, prevents infinite loop.

                        clickPoint(getArg($g_aPoints, "tap"))
                        If _Sleep(100) Then Return False

                        $t_sCurrLocation = getLocation()
                    WEnd

                    ;When location is battle-end, only available with force surrender on.
                    If $sLocation = "battle-end" Then 
                        If $bLog Then addLog($g_aLog, "Finished navigating.", $LOG_NORMAL)
                        Return True
                    EndIf
                Else   
                    ;Only catch-mode will need to be in one of the locations above.
                    If $sLocation <> "catch-mode" Then Return False 
                EndIf
            Case "battle-end-exp", "battle-sell", "battle-sell-item"
                ;Sets up for normal locations
                Local $t_iTimerInit = TimerInit()

                While $t_sCurrLocation <> "battle-end"
                    If TimerDiff($t_iTimerInit) >= 120000 Then Return False ;2 Minutes, prevents infinite loop.

                    If $t_sCurrLocation = "battle-sell-item" Then
                        clickPoint(getArg($g_aPoints, "battle-sell-item-cancel"))
                        clickPoint(getArg($g_aPoints, "battle-sell-item-okay"))
                    EndIf

                    clickPoint(getArg($g_aPoints, "tap"))
                    If _Sleep(1000) Then Return False

                    $t_sCurrLocation = getLocation()
                WEnd
            Case "tap-to-start"
                clickPoint("394,469", 3, 50)
                If _Sleep(2000) Then Return False
                ContinueLoop

            Case "event-list"
                clickPoint("776,20", 3, 50)
                If _Sleep(2000) Then Return False
                ContinueLoop
                
        EndSwitch

        ;Handles normal locations
        Switch $sLocation
            Case "village"
                Switch $t_sCurrLocation
                    Case "battle-end" 
                        ;Goes directly from battle-end to village
                        clickUntil(getArg($g_aPoints, "battle-end-airship"), "isLocation", "unknown,village", 60, 1000) ;60 seconds of clicking.
                        
                        Local $bResult = waitLocation("village", 60, True)
                        If $bResult = True Then addLog($g_aLog, "Finished navigating.", $LOG_NORMAL)
                        Return $bResult ;waits for map location for 60 seconds
                    Case Else
                        ;All other locations will need either click back or esc to get to village.

                        Local $t_vTimerInit = TimerInit() 
                        While getLocation() <> "village"
                            If getLocation($g_aLocations, False) = "hourly-reward" Then 
                                clickWhile(getArg($g_aPoints, "get-reward"), "isLocation", "hourly-reward")
                                ContinueLoop(2)
                            EndIf

                            If getLocation($g_aLocations, False) = "battle-end" Then ContinueLoop(2)
                            If TimerDiff($t_vTimerInit) > 30000 Then Return False ;30 seconds
                                
                            ;Handles back or esc
                            If isPixel(getArg($g_aPixels, "back"), 20) = True Then
                                clickPoint(getArg($g_aPoints, "back"))
                            Else
                                ;Usually stuck in place with an in game window and an Exit button for the window.
                                closeWindow()
                                skipDialogue()

                                clickPoint(getArg($g_aPoints, "tap"))

                                ;Tries ADB send keyevent escape
                                If TimerDiff($t_vTimerInit) > 10000 Then
                                    If (FileExists($g_sAdbPath) = True) And (StringInStr(adbCommand("get-state"), "error") = False) Then
                                        If getLocation() <> "unknown" Then ContinueLoop(2)
                                        adbCommand("shell input keyevent ESCAPE")
                                    EndIf
                                EndIf
                             EndIf

                            If _Sleep(500) Then Return False
                        WEnd

                        If $bLog Then addLog($g_aLog, "Finished navigating.", $LOG_NORMAL)
                        Return True
                EndSwitch
            Case "map"
                Switch $t_sCurrLocation
                    Case "battle-end"
                        ;Goes directly from battle-end to map
                        clickUntil(getArg($g_aPoints, "battle-end-map"), "isLocation", "unknown,map", 60, 1000) ;60 seconds of clicking.
                        
                        Local $bResult = waitLocation("map", 60, True) 
                        If $bResult = True Then addLog($g_aLog, "Finished navigating.", $LOG_NORMAL)
                        Return $bResult ;waits for map location for 60 seconds

                    Case "map-battle", "map-stage", "association", "clan", "toc"
                        Local $t_vTimerInit = TimerInit() 
                        While getLocation() <> "map"
                            If getLocation($g_aLocations, False) = "village" Then ContinueLoop(2)
                            If TimerDiff($t_vTimerInit) > 30000 Then Return False ;30 seconds
                                
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

                            If _Sleep(500) Then Return False
                        WEnd

                        If getLocation($g_aLocations, False) = "map" Then 
                            addLog($g_aLog, "Finished navigating.", $LOG_NORMAL)
                            Return True
                        EndIf
                    Case "village"
                        ;Goes directly to map from village
                        Local $t_iTimerInit = TimerInit()

                        While getLocation() <> "map" 
                            If TimerDiff($t_iTimerInit) >= 180000 Then Return False ;3 minutes

                            ;Handles clan notification and bingo popups.
                            clickWhile(getArg($g_aPoints, "village-play"), "isLocation", "village", 10, 1000) ;click for 10 seconds

                            skipDialogue()
                            closeWindow()

                            clickPoint(getArg($g_aPoints, "tap"))
                            If _Sleep(500) Then Return False
                        WEnd

                        If $bLog Then addLog($g_aLog, "Finished navigating.", $LOG_NORMAL)
                        Return True
                    Case Else
                        If _Sleep(10) Then Return False

                        ;Uses navigate village algorithm to easily go to map
                        If $bLog Then addLog($g_aLog, "-Navigating to village.")

                        Local $t_bResult = navigate("village", $bForceSurrender, False)
                        If $t_bResult = False Then 
                            If $bLog Then addLog($g_aLog, "Could not navigate to village.", $LOG_ERROR)
                            Return False
                        EndIf

                        If _Sleep(10) Then Return False
                        Local $bResult = navigate("map", $bForceSurrender, False)
                        If $bResult = True Then addLog($g_aLog, "Finished navigating.", $LOG_NORMAL)
                        Return $bResult ;waits for map location for 60 seconds
                EndSwitch

            Case "golem-dungeons"
                If $t_sCurrLocation <> "map" Then
                    If $bLog Then addLog($g_aLog, "-Navigating to 'map'.")
                    If navigate("map", $bForceSurrender, False) = False Then
                        If $bLog Then addLog($g_aLog, "Failed to navigate.", $LOG_ERROR)
                        Return False
                    EndIf
                EndIf

                ;Scrolling through map to find ancient dungeon place.
                If $bLog Then addLog($g_aLog, "-Swiping to golem dungeons.", $LOG_NORMAL)
				Local $aPoint = getMapCoor("Ancient Dungeon") ;Coordinates of found map.

				Local $t_hTimer = TimerInit()
				While isArray($aPoint) = False
					If _Sleep(10) Then Return False
					If TimerDiff($t_hTimer) > 30000 Then 
						addLog($g_aLog, "Could not find golems.", $LOG_ERROR)
						Return False
					EndIf

					;If map has not been found scrolls left
					clickDrag($g_aSwipeLeft)

					If getLocation() <> "map" Then navigate("map", False, False) ;Goes back to main loop if misclick happens
					$aPoint = getMapCoor("Ancient Dungeon")
				WEnd
                
				If clickWhile($aPoint, "isLocation", "map", 10, 1000) = False Then
					addLog($g_aLog, "Could not enter to map-stage.", $LOG_ERROR)
					Return False
                Else
					If getLocation() <> "golem-dungeons" Then
                        If getLocation($g_aLocations, False) = "map-battle" Then 
                            Local $bResult = clickUntil(getArg($g_aPoints, "back"), "isLocation", "golem-dungeons")
                            If $bResult = False Then
                                addLog($g_aLog, "Could not enter golem dungeons.", $LOG_ERROR)
                                Return False
                            Else  
                                addLog($g_aLog, "Finished navigating.", $LOG_NORMAL)
                                Return True
                            EndIf
                        Else
                            addLog($g_aLog, "Could not enter golem dungeons.", $LOG_ERROR)
                            Return False
                        EndIf
                    Else
                        addLog($g_aLog, "Finished navigating.", $LOG_NORMAL)
                        Return True
                    EndIf
				EndIf
            Case "quests"
                If $t_sCurrLocation <> "village" Then
                    If $bLog Then addLog($g_aLog, "-Navigating to 'village'.")
                    If navigate("village", $bForceSurrender, False) = False Then
                        If $bLog Then addLog($g_aLog, "Failed to navigate.", $LOG_ERROR)
                        Return False
                    EndIf
                EndIf

                If $bLog Then addLog($g_aLog, "-Clicking quests.", $LOG_NORMAL)
                If clickUntil(getArg($g_aPoints, "village-quests"), "isLocation", "quests", 10, 500) = True Then
                    If $bLog Then addLog($g_aLog, "Finished navigating.", $LOG_NORMAL)
                    Return True
                Else
                    If $bLog Then addLog($g_aLog, "Failed to navigate.", $LOG_ERROR)
                    Return False
                EndIf

            Case "catch-mode"
                Local $t_hTimer = TimerInit()
                Local $aRound = getRound()
                
                While TimerDiff($t_hTimer) < 20000
                    Switch $t_sCurrLocation
                        Case "battle-auto"
                            Local $t_aRound = getRound()
                            If isArray($aRound) And isArray($t_aRound) Then
                                If $aRound[0] <> $t_aRound[0] Then ContinueCase
                            EndIf

                            If isPixelOR("162,509,0x612C22/340,507,0x612C22/513,520,0x612C22/683,520,0x612C22", 10) = False Then
                                If isPixel("730,268,0xFED61D", 30) = False Then
                                    clickPoint(getArg($g_aPoints, "battle-catch"))
                                    If _Sleep(100) Then Return False
                                    CaptureRegion()
                                EndIf

                                If isPixel("730,268,0xFED61D", 30) = True Then
                                    waitLocation("catch-mode", 20)
                                    $t_sCurrLocation = getLocation($g_aLocations, False)
                                    ContinueLoop
                                Else
                                    clickPoint(getArg($g_aPoints, "battle-auto"))
                                EndIf
                            Else
                                ContinueCase
                            EndIf
                        Case "battle"
                            ;Looking for red hp pixels to that indicates if can click into catch-mode.
                            If isPixelOR("162,509,0x612C22/340,507,0x612C22/513,520,0x612C22/683,520,0x612C22", 10) = True Then
                                If clickUntil(getArg($g_aPoints, "battle-catch"), "isLocation", "catch-mode,unknown", 3, 100) = False Then
                                    If $bLog Then addLog($g_aLog, "Failed to navigate.", $LOG_ERROR)
                                    Return False
                                EndIf
                            EndIf
                        Case "catch-mode"
                            If $bLog Then addLog($g_aLog, "Finished navigating.", $LOG_NORMAL)
                            Return True
                        Case "unknown"
                        Case Else
                            If $bLog Then addLog($g_aLog, "Failed to navigate.", $LOG_ERROR)
                            Return False
                    EndSwitch

                    If _Sleep(10) Then Return False
                    $t_sCurrLocation = getLocation()
                WEnd
                Return False

            Case "monsters"
                If $t_sCurrLocation <> "village" Then
                    If $bLog Then addLog($g_aLog, "-Navigating to village.", $LOG_NORMAL)
                    If navigate("village", False, False) = False Then
                        If $bLog Then addLog($g_aLog, "Failed to navigate.", $LOG_ERROR)
                        Return False
                    EndIf
                EndIf

                Local $t_hTimer = TimerInit()
                Local $bResult = False
                While TimerDiff($t_hTimer) < 15000
                    If _Sleep(10) Then Return False
                    clickPoint(getArg($g_aPoints, "village-monsters"))
                    If getLocation() = "monsters" Then
                        $bResult = True
                        ExitLoop
                    EndIf
                WEnd
                If $bResult = True Then
                    Local $t_hTimer = TimerInit()
                    While isPixel("133,19,0xF6C02A", 20) = False
                        If _Sleep(10) Then Return False
                        If TimerDiff($t_hTimer) > 5000 Then ExitLoop
                        clickPoint(getArg($g_aPoints, "monsters-grid"), 1, 0, Null)
                        CaptureRegion()
                    WEnd

                    Local $t_hTimer = TimerInit()
                    While isPixel("266,471,0x34F09B", 20) = False
                        If _Sleep(10) Then Return False
                        If TimerDiff($t_hTimer) > 5000 Then ExitLoop
                        clickPoint(getArg($g_aPoints, "monsters-recent"), 1, 0, Null)
                        CaptureRegion()
                    WEnd
                    
                    If $bLog Then addLog($g_aLog, "Finished navigating.", $LOG_NORMAL)
                    Return True
                Else
                    If $bLog Then addLog($g_aLog, "Failed to navigate.", $LOG_ERROR)
                EndIf
            Case "manage"
                If $t_sCurrLocation <> "monsters" Then
                    If $bLog Then addLog($g_aLog, "-Navigating to monsters.", $LOG_NORMAL)
                    If navigate("monsters", False, False) = False Then
                        If $bLog Then addLog($g_aLog, "Failed to navigate.", $LOG_ERROR)
                        Return False
                    EndIf
                EndIf

                Local $t_hTimer = TimerInit()
                Local $bResult = False
                While TimerDiff($t_hTimer) < 10000
                    If _Sleep(10) Then Return False
                    clickPoint(getArg($g_aPoints, "monsters-manage"), 1, 0, Null)
                    If getLocation() = "manage" Then
                        $bResult = True
                        ExitLoop
                    EndIf  
                WEnd

                If $bResult = True Then
                    If $bLog Then addLog($g_aLog, "Finished navigating.", $LOG_NORMAL)
                    Return True
                Else
                    If $bLog Then addLog($g_aLog, "Failed to navigate.", $LOG_ERROR)
                    Return False
                EndIf
            Case "guardian-dungeons"
                If getLocation() = "map" Then
                    Local $t_hTimer = TimerInit()
                    While (isArray(getMapCoor("Phantom Forest")) = False) And (TimerDiff($t_hTimer) < 10000)
                        clickDrag($g_aSwipeRight)
                    WEnd
                    clickDrag($g_aSwipeRight)
                Else
                    If navigate("map", $bForceSurrender, False) = False Then
                        If $bLog Then addLog($g_aLog, "Could not enter into map.", $LOG_ERROR)
                        Return False
                    EndIf
                EndIf

                CaptureRegion()
                Local $aPoint = getMapCoor("Dungeons") ;Coordinates of found map.
                If isArray($aPoint) = True Then
                    If $bLog Then addLog($g_aLog, "Clicking into Dungeons.", $LOG_NORMAL)

                   If clickWhile($aPoint, "isLocation", "map", 20, 200) = True  Then
                        $bResult = clickUntil(getArg($g_aPoints, "dungeons-guardian"), "isLocation", "guardian-dungeons", 10, 500)
                        If $bResult = True Then
                            If $bLog Then addLog($g_aLog, "Finished Navigating.", $LOG_NORMAL)
                            Return True
                        Else
                            If $bLog Then addLog($g_aLog, "Could not click into guardian-dungeons.", $LOG_ERROR)
                            Return False
                        EndIf
                    EndIf

                    If $bLog Then addLog($g_aLog, "Could not click into Dungeons", $LOG_ERROR)
                    Return False
                Else
                    If $bLog Then addLog($g_aLog, "Could not find dungeons place.", $LOG_ERROR)
                    Return False
                EndIf
            Case Else
                If $bLog Then addLog($g_aLog, "Cannot navigate to location: " & $sLocation)
                Return False
        EndSwitch
    WEnd

    Return True
EndFunc