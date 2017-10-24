#include-once
#include "../../imports.au3"

#cs 
    Function: Script to navigate locations in MSL game.
    Parameters:
        $sLocation: One of the locations.
        $bForceSurrender: If in battle will surrender the match
    Returns: Boolean if successful or not.
#ce
Func navigate($sLocation, $bForceSurrender = False)
    Local $t_sCurrLocation = "" ;Location
    While $t_sCurrLocation <> $sLocation
        $t_sCurrLocation = getLocation()

        ;Handles force surrender 
        Switch $t_sCurrLocation
            Case "battle", "battle-auto", "catch-mode", "pause"
                If $bForceSurrender = True Then
                    ;Force surrender algorithm
                    If clickUntil(getArg($g_aPoints, "battle-pause"), "isLocation", "pause", 30, 1000) = True Then
                        clickWhile(getArg($g_aPoints, "battle-give-up"), "isLocation", "pause,unknown", 60, 1000)
                    EndIf

                    ;Sets up for normal locations
                    Local $t_iTimerInit = TimerInit()

                    While $t_sCurrLocation <> "battle-end"
                        If TimerDiff($t_iTimerInit) >= 120000 Then Return False ;2 Minutes, prevents infinite loop.

                        If clickPoint(getArg($g_aPoints, "tap")) = -2 Then Return -2
                        $t_sCurrLocation = getLocation()

                        If _Sleep(100) Then Return -2
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
                        
                        Return waitLocation("village", 60000, True) ;waits for village location for 60 seconds
                    Case Else
                        ;All other locations will need either click back or esc to get to village.

                        Local $t_vTimerInit = TimerInit() ;Will only do this for max 5 minutes
                        While getLocation() <> "village"
                            If TimerDiff($t_vTimerInit) >= 300000 Then Return False ;5 minutes
                                
                            ;Handles back or esc
                            If isPixel(getArg($g_aPixels, "back"), 20) = True Then
                                If clickPoint(getArg($g_aPoints, "back")) = -2 Then Return -2
                            Else
                                ;Usually stuck in place with an in game window and an Exit button for the window.
                                If closeWindow() = -2 Or skipDialogue() = -2 Then Return -2
                                If clickPoint(getArg($g_aPoints, "tap")) = -2 Then Return -2
                            EndIf

                            If _Sleep(100) Then Return -2
                        WEnd

                        Return getLocation() = "village"
                EndSwitch
            Case "map"
                Switch $t_sCurrLocation
                    Case "battle-end"
                        ;Goes directly from battle-end to map
                        Local $t_aArguments = ["unknown,map", True]
                        clickUntil(getArg($g_aPoints, "battle-end-airship"), "isLocation", $t_aArguments, 60, 1000) ;60 seconds of clicking.
                        
                        Return waitLocation("map", 60000, True) ;waits for map location for 60 seconds
                    Case "village"
                        ;Goes directly to map from village
                        Local $t_iTimerInit = TimerInit()

                        While getLocation() <> "map" 
                            If TimerDiff($t_iTimerInit) >= 180000 Then Return False ;3 minutes

                            ;Handles clan notification and bingo popups.
                            If clickWhile(getArg($g_aPoints, "village-play"), "isLocation", "village", 10, 1000) = True Then ;click for 10 seconds
                                skipDialogue()
                                closeWindow()
                            EndIf

                            If _Sleep(100) Then Return -2
                        WEnd
                    Case Else
                        ;Uses navigate village algorithm to easily go to map
                        Local $t_bResult = navigate("village")
                        If $t_bResult = -1 Or $t_bResult = -2 Then Return $t_bResult

                        If $t_bResult = True Then
                            Return navigate("map")
                        Else
                            Return False
                        EndIf
                EndSwitch
        EndSwitch
    WEnd
EndFunc