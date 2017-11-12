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
                    If clickUntil(getArg($g_aPoints, "battle-pause"), "isLocation", "pause", 30, 1000) = True Then
                        clickWhile(getArg($g_aPoints, "battle-give-up"), "isLocation", "pause,unknown", 10, 1000)
                    EndIf

                    ;Sets up for normal locations
                    Local $t_iTimerInit = TimerInit()

                    While $t_sCurrLocation <> "battle-end"
                        If TimerDiff($t_iTimerInit) >= 120000 Then Return False ;2 Minutes, prevents infinite loop.

                        clickPoint(getArg($g_aPoints, "tap"))
                        If _Sleep(1000) Then Return False

                        $t_sCurrLocation = getLocation()
                    WEnd
                Else   
                    ;Only catch-mode will need to be in one of the locations above.
                    If $sLocation <> "catch-mode" Then Return False 
                EndIf
            Case "battle-end-exp", "battle-sell", "battle-sell-item"
                ;Sets up for normal locations
                Local $t_iTimerInit = TimerInit()

                While $t_sCurrLocation <> "battle-end"
                    If TimerDiff($t_iTimerInit) >= 120000 Then Return False ;2 Minutes, prevents infinite loop.

                    clickPoint(getArg($g_aPoints, "tap"))
                    If _Sleep(1000) Then Return False

                    $t_sCurrLocation = getLocation()
                WEnd
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
                                        adbCommand("shell input keyevent ESCAPE")
                                        adbCommand("shell input keyevent ESCAPE")
                                        adbCommand("shell input keyevent ESCAPE")

                                        If getLocation() <> "unknown" Then ContinueLoop(2)
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

                Local $t_iTimerInit = TimerInit()
                While TimerDiff($t_iTimerInit) < 120000 ;Two minutes
                    Local $aGolem = getMapCoor("Ancient Dungeon")
                    If isArray($aGolem) = True Then
                        If $bLog Then addLog($g_aLog, "-Clicking golem dungeons.", $LOG_NORMAL)
                        If clickUntil($aGolem, "isLocation", "golem-dungeons", 5, 1000) = True Then
                            If $bLog Then addLog($g_aLog, "Finished navigating.", $LOG_NORMAL)
                            Return True
                        Else
                            If $bLog Then addLog($g_aLog, "Failed to navigate.", $LOG_ERROR)
                            Return False
                        EndIf
                    Else
                        clickDrag($g_aSwipeLeft)
                    EndIf

                    If _Sleep(1000) Then Return False
                    captureRegion()
                WEnd

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
        EndSwitch
    WEnd

    Return True
EndFunc