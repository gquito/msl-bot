#include-once
#include "../../imports.au3"

#cs 
    Function: Selects boss during battle-boss location or last round.
    Parameter: Reference to current location of the script.
#ce
Func Common_Boss(ByRef $sLocation)
    If Data_Get("Common Boss Targeted") = -1 Then
        Data_Add("Common Boss Targeted", $DATA_TEXT, "False")
    EndIf

    If Data_Get("Common Boss Targeted") = "False" Then
        Switch $sLocation
            Case "battle-auto", "unknown"
                Local $aRound = getRound()
                If isArray($aRound) = True Then
                    If $aRound[0] = $aRound[1] Then
                        waitLocation("unknown", 5)
                        ContinueCase
                    EndIf
                EndIf

                Return 0
            Case "battle-boss"
                If _Sleep(1000) Then Return 0

                Local $t_hTimer = TimerInit()
                While TimerDiff($t_hTimer) < 5000
                    CaptureRegion()
                    $sLocation = getLocation($g_aLocations, False)
                    If ($sLocation = "battle-auto") Or ($sLocation = "battle") Then
                        ExitLoop
                    EndIf

                    If _Sleep(10) Then Return 0
                WEnd

                Data_Set("Status", "Targeting boss.")
                Log_Add("Targeting boss.")
                Data_Set("Common Boss Targeted", "True")

                clickPoint(getArg($g_aPoints, "boss"))
        EndSwitch
    Else
        Switch $sLocation
            Case "battle-end", "battle-end-exp", "battle-sell", "map", "village"
                Data_Set("Common Boss Targeted", "False")
        EndSwitch
    EndIf
EndFunc

#cs 
    Function: Collect quest from battle-end location.
    Parameter: Reference to current location of the script.
#ce
Func Common_Quests(ByRef $sLocation)
    If isPixel(getArg($g_aPixels, "battle-end-quest")) = True Then
        Data_Set("Status", "Collecting quests.")
        collectQuest()
        $sLocation = getLocation()
    EndIf
EndFunc

#cs 
    Function: Attacks guardian dungeons by running Farm_Guardian() script, usually once every 30 minutes
    Parameters:
        $sLocation: Reference to current location of the script.
        *Other parameters include settings for Farm_Guardian excluding $Loop
#ce
Func Common_Guardian(ByRef $sLocation, $Mode, $Usable_Astrogems, $Target_Boss, $Collect_Quests, $Hourly_Script)
    If $g_bPerformGuardian = True Then
        Switch $sLocation
            Case "battle-end", "map", "village"
                Local $t_aOrder = $g_aOrder
                Farm_Guardian($Mode, $Usable_Astrogems, "Disabled", $Target_Boss, $Collect_Quests, $Hourly_Script)
                $g_bPerformGuardian = False
                If _Sleep(10) Then Return 0
                
                $g_aOrder = $t_aOrder
                Data_Display_Update()
        EndSwitch
    EndIf
EndFunc

#cs 
    Function: Perform hourly functions as per scheduled time.
    Parameters: Reference to currentl ocation of the script.
#ce
Func Common_Hourly(ByRef $sLocation)
    If $g_bPerformHourly = True Then
        Switch $sLocation
            Case "battle-end", "map", "village"
                doHourly()
        EndSwitch
    EndIf
EndFunc

#cs 
    Function: Prevents getting stuck at an unknown/unspecified location for a script.
    Parameter: Reference to current location of the script.
#ce
Func Common_Stuck(ByRef $sLocation)
    If Data_Get("Common Stuck Timer") = -1 Then
        Data_Add("Common Stuck Timer", $DATA_TEXT, TimerInit())
    EndIf

    Switch $sLocation
        Case "unknown"
            If isArray(getRound()) = False Then
                If Data_Get("Unknown Tap") = -1 Then
                    Data_Add("Unknown Tap", $DATA_TEXT, TimerInit())
                EndIf

                If TimerDiff(Data_Get("Unknown Tap")) > 5000 Then
                    clickPoint(getArg($g_aPoints, "tap"))
                    Data_Set("Unknown Tap", TimerInit())
                EndIf

                ContinueCase
            EndIf
            Data_Set("Common Stuck Timer", "Null")
        Case "", "lost-connection"
            If _Sleep(10) Then Return 0

            If Data_Get("Common Stuck Timer") = "Null" Then
                Data_Set("Common Stuck Timer", TimerInit())
            Else
                If TimerDiff(Data_Get("Common Stuck Timer")) > 20000 Then
                    $sLocation = getLocation()
                    If $sLocation = "lost-connection" Then
                        Log_Add("Lost connection detected, retrying.")
                        clickWhile(getArg($g_aPoints, "lost-connection-retry"), "isLocation", "lost-connection")
                    Else
                        If navigate("map", True) = False Then
                            $sLocation = getLocation()
                            Log_Add("Stuck at an unspecified location.", $LOG_ERROR)
                        EndIf
                    EndIf
                    If Data_Get("Common Stuck Timer") <> "Null" Then Data_Set("Common Stuck Timer", "Null")
                EndIf
            EndIf
        Case "battle-end", "map"
            ;Data resets
            Data_Set("Astrochips", "3")
            Data_Set("Skip Round", "-1")
            ContinueCase

        Case Else
            If Data_Get("Common Stuck Timer") <> "Null" Then Data_Set("Common Stuck Timer", "Null")
    EndSwitch
EndFunc