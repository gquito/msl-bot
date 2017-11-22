#include-once
#include "../imports.au3"

Func Farm_Guardian($sMode, $iGems, $bLoop, $bBoss, $bQuests, $bHourly, $t_aData = Null, $aDataPre = Null, $aDataPost = Null)
    Local Const $aLocations = ["loading", "village", "map", "battle-boss", "unknown", "battle", "battle-auto", "pause", "battle-end-exp", "battle-sell", "battle-end", "guardian-dungeons", "refill", "map-battle", "battle-gem-full", "map-gem-full", "defeat"]

    ;Variables
    Local $iGuardians = 0 ;Number of guardians attacked.
    Local $hUnknownTimer = Null ;Timer for when the location is not known.
    Local $iUsedGems = 0 ;Used gems for refill
    Local $bBossSelected = False ;Resets every new round

    If isArray($t_aData) = True Then
        Local $t_Var = Int(StringSplit(getArg($t_aData, "Refill"), "/", $STR_NOCOUNT)[0])
        If $t_Var <> -1 Then $iUsedGems = $t_Var

        Local $t_Var = Int(StringSplit(getArg($t_aData, "Guardians"), "/", $STR_NOCOUNT)[0])
        If $t_Var <> -1 Then $iGuardians = $t_Var
    EndIf

    ; Main script loop
    Local $aData[1][2] = [["Guardians", ""]]
    displayData($aData, $hLV_Stat, $aDataPre, $aDataPost)

    addLog($g_aLog, "```Farm Guardian script has started.")
    Switch isLocation($aLocations, False)
        Case "battle-end", "battle-end-exp", "battle-sell", ""
            navigate("map")
    EndSwitch

    While True
        setArg($aData, "Guardians", $iGuardians)
        displayData($aData, $hLV_Stat, $aDataPre, $aDataPost)

        If _Sleep(500) Then ExitLoop
        Local $sLocation = isLocation($aLocations, False)
        If $sLocation <> "" And $sLocation <> "unknown" Then $hUnknownTimer = Null

        Switch $sLocation
            Case "village"
                If ($bHourly = "Enabled") And ($g_bPerformHourly = True) Then doHourly()
                navigate("map")

            Case "map"
                If navigate("guardian-dungeons", True) = False Then
                    If $bLoop = "Enabled" Then
                        navigate("village")
                        ContinueLoop
                    Else
                        ExitLoop
                    EndIf
                EndIf

			Case "battle-end"
               ;if the quests notification with red pixel shows up
                If ($bQuests = "Enabled") And (isPixel(getArg($g_aPixels, "battle-end-quest")) = True) Then collectQuest()

                ;Hourly will only be done in specific times. Refer to the function.
                If ($bHourly = "Enabled") And ($g_bPerformHourly = True) Then doHourly()

                If getLocation() <> "battle-end" Then
                    navigate("map")
                Else
                    clickPoint(getArg($g_aPoints, "battle-end-exit")) ;Exit
                    waitLocation("guardian-dungeons", 60)
                EndIf

			Case "battle"
				clickPoint(getArg($g_aPoints, "battle-auto"))

            Case "battle-end-exp", "battle-sell"
                clickUntil(getArg($g_aPoints, "tap"), "isLocation", "battle-end", 20, 500)

            Case "refill"
                ;Refill function handles starting the quickrestart and or the start battle from map-battle. Also handles the error messages
                If $iUsedGems+30 <= $iGems Then
                    If doRefill() = True Then
                        $iUsedGems+=30
                        addLog($g_aLog, "Refill " & $iUsedGems & "/" & $iGems, $LOG_NORMAL)
                    Else
                        If $bLoop = "Enabled" Then
                            navigate("village")
                            ContinueLoop
                        Else
                            ExitLoop
                        EndIf
                    EndIf
                Else
                    addLog($g_aLog, "Gems used has exceeded max gems.", $LOG_NORMAL)
                    ExitLoop
                EndIf
        
			Case "map-battle"
				If enterBattle() = False Then
                    addLog($g_aLog, "Could not enter battle.", $LOG_ERROR)
                    ExitLoop
                EndIf
			Case "guardian-dungeons"
				;Finding available astromon within 10 seconds
				Local $aPoint = findGuardian($sMode);Point of an available astromon

				Local $t_hTimer = TimerInit()
				While isArray($aPoint) = False 
					$aPoint = findGuardian($sMode)

					If (TimerDiff($t_hTimer) > 10000) Or ($aPoint = -2) Then 
                        addLog($g_aLog, "Did not find any guardian dungeons.", $LOG_NORMAL)
                        If $bLoop = "Enabled" Then
                            navigate("village")
                            ContinueLoop(2)
                        Else
                            ExitLoop(2)
                        EndIf
                    EndIf

					clickDrag($g_aSwipeUp) ;Tries to check for other mons by scrolling up
					If _Sleep(500) Then Return -1
				WEnd

				;Enter into map-battle location and lets the case for map battle take over
				If clickUntil($aPoint, "isLocation", "map-battle", 10, 500) = True Then
					$iGuardians += 1
                    displayData($aData, $hLV_Stat, $aDataPre, $aDataPost)
					addLog($g_aLog, "Found dungeon, attacking x" & $iGuardians, $LOG_NORMAL)
				Else
                    addLog($g_aLog, "Could not enter into map-battle.", $LOG_ERROR)
                    If $bLoop = "Enabled" Then
                        navigate("village")
                        ContinueLoop
                    Else
                        ExitLoop
                    EndIf
				EndIf

            Case "pause"
                clickPoint(getArg($g_aPoints, "battle-continue"))

            Case "defeat"
                If clickUntil(getArg($g_aPoints, "battle-give-up"), "isLocation", "unknown,battle-end-exp,battle-sell,battle-sell-item,battle-end") = True Then
                    addLog($g_aLog, "You have been defeated.", $LOG_NORMAL)
                EndIf

            Case "battle-gem-full", "map-gem-full"
                addLog($g_aLog, "Gem inventory is full.", $LOG_ERROR)
                navigate("village")
                ExitLoop

            Case "battle-boss"
                If $bBossSelected = False Then ContinueCase

            Case "unknown", "battle-auto"
                Local $aRound = getRound()
                If ($bBoss = "Enabled") And (($sLocation = "battle-boss") Or (($bBossSelected = False) And ((isArray($aRound) = True) And ($aRound[0] = $aRound[1])))) Then
                    If _Sleep(1000) Then ExitLoop

                    Local $t_iTimerInit = TimerInit()
                    While (isLocation("battle-auto,battle") = "") And (TimerDiff($t_iTimerInit) < 5000)
                        If _Sleep(10) Then ExitLoop(2)
                    WEnd
                    clickPoint(getArg($g_aPoints, "boss"))

                    $bBossSelected = True
                EndIf

                If (isArray($aRound) = False) And ($sLocation = "unknown") then 
                    ContinueCase
                Else
                    $hUnknownTimer = Null
                Endif
            Case ""
                ;Waits 20 seconds before knowing that it is stuck in an unspecified location.
                If _Sleep(10) Then ExitLoop
                
                If $hUnknownTimer = Null Then 
                    $hUnknownTimer = TimerInit()
                Else
                    If TimerDiff($hUnknownTimer) > 20000 Then
                        If navigate("map", True) = False Then
                            addLog($g_aLog, "Something went wrong!", $LOG_ERROR)
                        EndIf
                        $hUnknownTimer = Null
                    EndIf
                EndIf
        EndSwitch
    WEnd
    addLog($g_aLog, "```Farm Guardian script has stopped.", $LOG_NORMAL)
    
    Local $t_vExtended[1][2] = [["Refill", $iUsedGems]]
    $g_vExtended = $t_vExtended

    $g_bPerformGuardian = False
    Return $aData
EndFunc