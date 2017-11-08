#include-once
#include "../../imports.au3"

#cs 
    Function: Script to navigate locations in MSL game.
    Parameters:
        $sLocation: One of the locations.
        $bForceSurrender: If in battle will surrender the match
    Returns: Boolean if successful or not.
#ce
Func navigate($sLocation, $bForceSurrender = False, $bLog = True)
    Local $t_sCurrLocation = getLocation() ;Location
    If $t_sCurrLocation = $sLocation Then Return True

    If $bLog Then addLog($g_aLog, "Navigating to '" & $sLocation & "'.", $LOG_NORMAL)
    $sLocation = StringStripWS(StringLower($sLocation), $STR_STRIPALL)

    While $t_sCurrLocation <> $sLocation
        ;Handles force surrender 
        Switch $t_sCurrLocation
            Case "battle", "battle-auto", "catch-mode", "pause"
                If $bForceSurrender = True Then
                    If $bLog Then addLog($g_aLog, "-Forcing to surrender.", $LOG_NORMAL)

                    ;Force surrender algorithm
                    If clickUntil(getArg($g_aPoints, "battle-pause"), "isLocation", "pause", 30, 1000) = True Then
                        clickWhile(getArg($g_aPoints, "battle-give-up"), "isLocation", "pause,unknown", 60, 1000)
                    EndIf

                    ;Sets up for normal locations
                    Local $t_iTimerInit = TimerInit()

                    While $t_sCurrLocation <> "battle-end"
                        If TimerDiff($t_iTimerInit) >= 120000 Then Return False ;2 Minutes, prevents infinite loop.

                        clickPoint(getArg($g_aPoints, "tap"))
                        If _Sleep(1000) Then Return -2

                        $t_sCurrLocation = getLocation()
                    WEnd
                Else   
                    ;Only catch-mode will need to be in one of the locations above.
                    If $sLocation <> "catch-mode" Then Return False 
                EndIf
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

                        Local $t_vTimerInit = TimerInit() ;Will only do this for max 1 minutes
                        While getLocation() <> "village"
                            If TimerDiff($t_vTimerInit) >= 60000 Then Return False ;1 minutes
                                
                            ;Handles back or esc
                            If isPixel(getArg($g_aPixels, "back"), 20) = True Then
                                clickPoint(getArg($g_aPoints, "back"))
                            Else
                                ;Usually stuck in place with an in game window and an Exit button for the window.
                                closeWindow()
                                skipDialogue()

                                clickPoint(getArg($g_aPoints, "tap"))
                            EndIf

                            If _Sleep(1000) Then Return -2
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

                            If _Sleep(500) Then Return -2
                        WEnd

                        If $bLog Then addLog($g_aLog, "Finished navigating.", $LOG_NORMAL)
                        Return True
                    Case Else
                        ;Uses navigate village algorithm to easily go to map
                        If $bLog Then addLog($g_aLog, "-Navigating to village.")

                        Local $t_bResult = navigate("village", $bForceSurrender, False)
                        If $t_bResult = False Then Return False

                        Local $bResult = navigate("map", $bForceSurrender, False)
                        If $bResult = True Then addLog($g_aLog, "Finished navigating.", $LOG_NORMAL)
                        Return $bResult ;waits for map location for 60 seconds
                EndSwitch

                Case "golem-dungeons"
                    If $t_sCurrLocation <> "map" Then
                        If $bLog Then addLog($g_aLog, "-Navigating to Map.")
                        If navigate("map", $bForceSurrender, False) = False Then Return False
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
                                If $bLog Then addLog($g_aLog, "Failed to navigate.", $LOG_NORMAL)
                                Return False
                            EndIf
                        Else
                            clickDrag($g_aSwipeLeft)
                        EndIf

                        If _Sleep(1000) Then Return -2
                        captureRegion()
                    WEnd
        EndSwitch

        $t_sCurrLocation = getLocation()
    WEnd
EndFunc