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
        If getLocation() <> "catch-mode" Then 
            Log_Add("Not in catch mode.")
            ExitLoop
        EndIf

        ;Format images to [image, image, image]
        If isArray($aImages) = False Then
            $aImages = StringSplit($aImages, ",", $STR_NOCOUNT)
        EndIf

        ;Process
        Log_Add("Searching for astromons.")

        Local $sAstromon = "";Will store astromon name
        Local $iSize = UBound($aImages, $UBOUND_ROWS)
        Local $aFound = Null ;This is where the astromon position is stored if found
        For $i = 0 To $iSize-1
            $aFound = findImage("catch-" & StringReplace(StringStripWS(StringLower($aImages[$i]), $STR_STRIPTRAILING), " ", "-"), 90, 0, 0, 263, 800, 210, True, False)
            $sAstromon = $aImages[$i]
            If isArray($aFound) = True Then ExitLoop
        Next

        If isArray($aFound) = False Then
            Log_Add("Could not find any astromons.")
            ExitLoop
        EndIf

        ;Found process
        While $iAstrochips > 0 
            Log_Add("Attempting to catch " & $sAstromon & " (" & 4-$iAstrochips & "/3).")
            If _Sleep(0) Then ExitLoop(2)

            Local $t_hTimer = TimerInit()
            While getLocation() <> "catch-mode"
                If TimerDiff($t_hTimer) > 10000 Then ExitLoop
                If _Sleep(0) Then ExitLoop(2)
            WEnd

            If clickWhile($aFound, "isLocation", "catch-mode", 15, 200) = False Then
                Log_Add("Could not attempt to capture astromon.", $LOG_ERROR)
                $bOutput = "!" & $sAstromon
                ExitLoop(2)
            EndIf

            If getLocation($g_aLocations, False) = "battle-astromon-full" Then
                Log_Add("Astromon bag full.", $LOG_ERROR)
                ExitLoop(2)
            EndIf

            ;In catch process
            $iAstrochips -= 1
            Stat_Increment($g_aStats, "Astrochips used", 1)
            If $g_bAdbWorking = True Then ;speed catch
                Log_Add("Double ESCAPE for quick catch.")
                adbSendESC()
                adbSendESC()
            EndIf

            Local $t_hTimer = TimerInit()
            Local $t_hTimer2 = TimerInit()
            Local $t_hTimer3 = TimerInit()

            Local $sLocation ;stores current location
            Log_Add("Checking catch status.")
            Do
                If (TimerDiff($t_hTimer2) > 500) And (TimerDiff($t_hTimer) < 3000) Then
                    clickPoint(getArg($g_aPoints, "battle-continue"))
                    $t_hTimer2 = TimerInit()
                EndIf

                If TimerDiff($t_hTimer3) > 500 Then
                    clickPoint(getArg($g_aPoints, "tap"))
                    $t_hTimer3 = TimerInit()
                EndIf

                If TimerDiff($t_hTimer) > 20000 Then 
                    If navigate("catch-mode", False) = True Then
                        clickPoint(getArg($g_aPoints, "catch-mode-cancel"))
                        $sLocation = "catch-success"
                        ExitLoop
                    Else
                        Log_Add("Failed to detect capture status.", $LOG_ERROR)
                        $bOutput = "!" & $sAstromon
                        ExitLoop(3)
                    EndIf
                EndIf
                If _Sleep(0) Then ExitLoop(3)

                CaptureRegion() ;Update
                $sLocation = getLocation($g_aLocations, False)
                If $sLocation = "battle" Then
                    If navigate("catch-mode", False) = True Then
                        clickPoint(getArg($g_aPoints, "catch-mode-cancel"))
                        $sLocation = "catch-success"
                        ExitLoop
                    Else
                        Log_Add("Failed to detect capture status.", $LOG_ERROR)
                        $bOutput = "!" & $sAstromon
                        ExitLoop(3)
                    EndIf
                EndIf
            Until ($sLocation = "catch-success") Or ($sLocation = "battle-auto") Or ($sLocation = "catch-mode") Or ($sLocation = "pause")

            Switch $sLocation
                Case "catch-success"
                    Log_Add("Caught a(n) " & $sAstromon & ".", $LOG_INFORMATION)

                    Switch $sAstromon
                        Case "Legendary","Exotic","Super Rare","Rare","Variant"
                            Stat_Increment($g_aStats, $sAstromon & " caught")
                    EndSwitch
                    Stat_Increment($g_aStats, "Overall caught")

                    $bOutput = $sAstromon
                    ExitLoop(2)
                Case "battle-auto"
                    If _Sleep(200) Then Return ""
                    If getLocation() = "battle-auto" Then
                        Log_Add("Failed to catch a(n) " & $sAstromon & ".", $LOG_INFORMATION)
                        $bOutput = "!" & $sAstromon
                        ExitLoop(2)
                    EndIf
                Case "pause"
                    clickWhile(getArg($g_aPoints, "battle-continue"), "isLocation", "pause")
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