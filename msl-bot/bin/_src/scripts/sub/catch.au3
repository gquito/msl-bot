#include-once
#include "../../imports.au3"

#cs 
    Function: Catches specified astromons in catch-mode location.
    Parameters:
        $aImages: List of astromon images from the catch folder. Ex: "legendary,rare"
        $iAstrochips: Reference to the number of astrochips available.
    Return: Catches and misses in string.
#ce
Func catch($aImages, ByRef $iAstrochips)
    Log_Level_Add("catch")

    Local $bOutput = ""
    While True 
        If (Not(isLocation("catch-mode"))) Then 
            Log_Add("Not in catch mode.")
            ExitLoop
        EndIf

        ;Format images to [image, image, image]
        If (Not(isArray($aImages))) Then $aImages = StringSplit($aImages, ",", $STR_NOCOUNT)

        ;Process
        Log_Add("Searching for astromons.")

        Local $sAstromon = "";Will store astromon name
        Local $iSize = UBound($aImages, $UBOUND_ROWS)
        Local $aFound = Null ;This is where the astromon position is stored if found
        For $i = 0 To $iSize-1
            $aFound = findImage("catch-" & StringReplace(StringStripWS(StringLower($aImages[$i]), $STR_STRIPTRAILING), " ", "-"), 90, 0, 0, 263, 800, 210, True, True)
            $sAstromon = $aImages[$i]
            If (isArray($aFound)) Then ExitLoop
        Next

        If (Not(isArray($aFound))) Then
            Log_Add("Could not find any astromons.")
            ;CaptureRegion("new" & Random(0, 10000)) ;Debug
            ExitLoop
        EndIf

        ;Found process
        While $iAstrochips > 0 
            Local $iCounter = 1 
            Log_Add("Attempting to catch " & $sAstromon & " (" & $iCounter & "/" & $iAstrochips & ").")
            If (_Sleep(0)) Then ExitLoop

            Local $t_hTimer = TimerInit()
            While Not(isLocation("catch-mode"))
                If (TimerDiff($t_hTimer) > 10000) Then ExitLoop
                If (_Sleep(0)) Then ExitLoop(2)
            WEnd

            If (Not(clickWhile($aFound, "isLocation", "catch-mode", 15, 400))) Then
                Log_Add("Could not attempt to capture astromon.", $LOG_ERROR)
                $bOutput = "!" & $sAstromon
                ExitLoop
            EndIf
            
            If (waitLocationMS("battle-astromon-full",300,50)) Then
                Log_Add("Astromon bag full.", $LOG_ERROR)
                $bOutput = -1
                ExitLoop
            EndIf

            ;In catch process
            $iAstrochips -= 1
            $iCounter += 1
            Stat_Increment($g_aStats, "Astrochips used", 1)

            SendBack(2)
            clickPoint(getPointArg("battle-continue"), 5, 200)

            Local $t_hTimer = TimerInit()
            Local $t_hTimer2 = TimerInit()
            Local $t_hTimer3 = TimerInit()

            Local $sLocation ;stores current location
            Log_Add("Checking catch status.")
            Do
                If (TimerDiff($t_hTimer2) > 500 And TimerDiff($t_hTimer) < 3000) Then
                    clickPoint(getPointArg("battle-continue"))
                    $t_hTimer2 = TimerInit()
                EndIf

                If (TimerDiff($t_hTimer3) > 500) Then
                    clickPoint(getPointArg("tap"))
                    $t_hTimer3 = TimerInit()
                EndIf

                If (TimerDiff($t_hTimer) > 20000) Then 
                    If (navigate("catch-mode", False)) Then
                        clickPoint(getPointArg("catch-mode-cancel"))
                        $sLocation = "catch-success"
                        ExitLoop
                    Else
                        Log_Add("Failed to detect capture status.", $LOG_ERROR)
                        $bOutput = "!" & $sAstromon
                        ExitLoop(2)
                    EndIf
                EndIf

                If (_Sleep(0)) Then ExitLoop(3)

                $sLocation = getLocation()
                If $sLocation = "battle" Then
                    If (navigate("catch-mode", False)) Then
                        clickPoint(getPointArg("catch-mode-cancel"))
                        $sLocation = "catch-success"
                        ExitLoop
                    Else
                        Log_Add("Failed to detect capture status.", $LOG_ERROR)
                        $bOutput = "!" & $sAstromon
                        ExitLoop(3)
                    EndIf
                EndIf
            Until ($sLocation = "catch-success") Or ($sLocation = "battle-auto") Or ($sLocation = "catch-mode")
            Log_Add($sLocation, $LOG_DEBUG)
            Switch $sLocation
                Case "catch-success"
                    Log_Add("Caught a(n) " & $sAstromon & ".", $LOG_INFORMATION)

                    Switch $sAstromon
                        Case "Legendary","Exotic","Super Rare","Rare","Variant"
                            Stat_Increment($g_aStats, $sAstromon & " caught")
                    EndSwitch
                    Stat_Increment($g_aStats, "Overall caught")

                    $bOutput = $sAstromon
                    ExitLoop
                Case "battle-auto"
                    If (_Sleep(200)) Then ExitLoop
                    If (isLocation("battle-auto")) Then
                        Log_Add("Failed to catch a(n) " & $sAstromon & ".", $LOG_INFORMATION)
                        $bOutput = "!" & $sAstromon
                        ExitLoop
                    EndIf
                Case "pause"
                    clickWhile(getPointArg("battle-continue"), "isLocation", "pause")
                    $iAstrochips += 1
                    Stat_Increment($g_aStats, "Astrochips used", -1)

                    navigate("catch-mode", False)
            EndSwitch
        WEnd

        ExitLoop
    WEnd

    Log_Add("Catching astromon result: " & $bOutput, $LOG_DEBUG)
    Log_Level_Remove()
    Return $bOutput
EndFunc

Func _catch($aImages)
    Local $iAstrochips = 3
    Return catch($aImages, $iAstrochips)
EndFunc