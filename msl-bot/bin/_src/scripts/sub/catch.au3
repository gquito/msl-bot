#include-once
#include "../../imports.au3"

Func catch($aImages, ByRef $iAstrochips, $bLog = True)
    If (getLocation() <> "catch-mode") Then Return ""

    ;Format images to [image, image, image]
    If isArray($aImages) = False Then
        $aImages = StringSplit($aImages, ",", $STR_NOCOUNT)
    EndIf

    ;Process
    If $bLog Then addLog($g_aLog, "Beginning to catch astromons.", $LOG_NORMAL)
    If $bLog Then addLog($g_aLog, "-Looking for astromons.", $LOG_NORMAL)

    Local $sAstromon = "";Will store astromon name
    Local $iSize = UBound($aImages, $UBOUND_ROWS)
    Local $aFound = Null ;This is where the astromon position is stored if found
    For $i = 0 To $iSize-1
        $aFound = findImage("catch-" & StringReplace(StringStripWS(StringLower($aImages[$i]), $STR_STRIPTRAILING), " ", "-"), 120, 0, 0, 263, 800, 210)
        $sAstromon = $aImages[$i]
        If isArray($aFound) = True Then ExitLoop
    Next

    If isArray($aFound) = False Then
        If $bLog Then addLog($g_aLog, "Could not find any astromons.", $LOG_ERROR)
        Return ""
    EndIf

    ;Found process
    While $iAstrochips > 0 
        If $bLog Then addLog($g_aLog, "-Attempting to catch " & $sAstromon & " (" & 4-$iAstrochips & "/3).", $LOG_NORMAL)

        If _Sleep(10) Then Return ""

        Local $t_hTimer = TimerInit()
        While getLocation() <> "catch-mode"
            If TimerDiff($t_hTimer) > 10000 Then ExitLoop
            If _Sleep(10) Then Return ""
        WEnd

        If clickWhile($aFound, "isLocation", "catch-mode", 15, 200) = False Then
            If $bLog Then addLog($g_aLog, "Could not attempt to capture astromon.", $LOG_ERROR)
            Return "!" & $sAstromon
        EndIf

        If getLocation($g_aLocations, False) = "battle-astromon-full" Then
            If $bLog Then addLog($g_aLog, "Astromon bag full.", $LOG_ERROR)
            Return -1
        EndIf

        ;In catch process
        $iAstrochips -= 1
        If (FileExists($g_sAdbPath) = True) And (StringInStr(adbCommand("get-state"), "error") = False) Then ;speed catch
            adbCommand('shell "input keyevent ESCAPE;input keyevent ESCAPE"')
        EndIf

        Local $t_hTimer = TimerInit()
        Local $sLocation ;stores current location
        Do
            clickPoint(getArg($g_aPoints, "battle-continue"))
            clickPoint(getArg($g_aPoints, "tap"))
            If TimerDiff($t_hTimer) > 20000 Then 
                If navigate("catch-mode", False, False) = True Then
                    clickPoint(getArg($g_aPoints, "catch-mode-cancel"))
                    $sLocation = "catch-success"
                    ExitLoop
                Else
                    If $bLog Then addLog($g_aLog, "Failed to detect capture status.", $LOG_ERROR)
                    Return "!" & $sAstromon
                EndIf
            EndIf
            
            If _Sleep(10) Then Return ""
            CaptureRegion() ;Update
            $sLocation = getLocation($g_aLocations, False)
            If $sLocation = "battle" Then
                If navigate("catch-mode", False, False) = True Then
                    clickPoint(getArg($g_aPoints, "catch-mode-cancel"))
                    $sLocation = "catch-success"
                    ExitLoop
                Else
                    If $bLog Then addLog($g_aLog, "Failed to detect capture status.", $LOG_ERROR)
                    Return "!" & $sAstromon
                EndIf
            EndIf
        Until ($sLocation = "catch-success") Or ($sLocation = "battle-auto") Or ($sLocation = "catch-mode") Or ($sLocation = "pause")

        Switch $sLocation
        Case "catch-success"
            If $bLog Then addLog($g_aLog, "Caught a " & $sAstromon & ".", $LOG_NORMAL)
            Return $sAstromon
        Case "battle-auto"
            If _Sleep(200) Then Return ""
            If getLocation() = "battle-auto" Then
                If $bLog Then addLog($g_aLog, "Could not catch " & $sAstromon & ".")
                Return "!" & $sAstromon
            EndIf
        Case "pause"
            clickWhile(getArg($g_aPoints, "battle-continue"), "isLocation", "pause")
            $iAstrochips += 1

            navigate("catch-mode")
        EndSwitch
    WEnd

    If $sAstromon <> "" Then
        Return "!" & $sAstromon
    Else
        Return ""
    EndIf
EndFunc