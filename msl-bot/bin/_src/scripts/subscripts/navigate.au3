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
                    If clickUntil(getArg($g_aPoints, "battle-pause"), "pause", 30, 1000) = True Then
                        clickWhile(getArg($g_aPoints, "battle-give-up"), "pause,unknown", 60, 1000)
                    EndIf

                    ;Sets up for normal locations
                    While $t_sCurrLocation <> "battle-end"
                        If clickPoint(getArg($g_aPoints, "tap")) = -2 Then Return -2
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
                        Local $t_aArguments = ["unknown,village", True]
                        clickUntil(getArg($g_aPoints, "battle-end-airship"), "isLocation", $t_aArguments, 60, 1000) ;60 seconds of clicking.
                        
                        Return waitLocation("village", 60000, True) ;waits for village location for 60 seconds
                    Case Else
                        ;All other locations will need either click back or esc to get to village.

                        Local $t_vTimerInit = TimerInit() ;Will only do this for max 5 minutes
                        While getLocation() <> "village"
                            If TimerDiff($t_vTimerInit) >= 300000 Then Return False ;5 minutes
                                
                            If clickPoint(getArg($g_aPoints, "tap")) = -2 Then Return -2

                            ;Handles back or esc
                            If isPixel(getArg($g_aPixels, "back"), 20) = True Then
                                If clickPoint(getArg($g_aPoints, "back")) = -2 Then Return -2
                            Else
                                If sendKey("{ESC}") = -1 Then Return -1
                            EndIf
                        WEnd

                        Return waitLocation("village", 60000, True) ;waits for village location for 60 seconds
                EndSwitch
            Case "map"

        EndSwitch
    WEnd
EndFunc