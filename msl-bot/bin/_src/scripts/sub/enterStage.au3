#include-once
#include "../../imports.au3"

#cs
	Function: Algorithm for entering a stage in the maps.
	Parameters:
		sMap - Map name. Available can be found in global.au3
		sDifficutly - Modes include: normal, hard, extreme
		sStage - Level number, includes "Gold", "Any", "Exp", "Boss"
		bAuto - Autobattle mode
	Returns: (boolean) On success returns true, fail return false
#ce
Func enterStage($sMap, $sDifficulty = "Normal", $sStage = "Exp", $bAuto = False)
	addLog($g_aLog, "Entering " & $sMap & " Stage " & $sStage & " on " & $sDifficulty & ".", $LOG_NORMAL)

    If getLocation() = "map" Then
		Local $t_hTimer = TimerInit()
		While (isArray(getMapCoor("Phantom Forest")) = False) And (TimerDiff($t_hTimer) < 10000)
			clickDrag($g_aSwipeRight)
		WEnd
		clickDrag($g_aSwipeRight)
	EndIf

	Local $bFound = False
	Local $hTimer = TimerInit()
	While TimerDiff($hTimer) < 120000 ;2 Minutes
        If _Sleep(10) Then Return False
        Local $sLocation = isLocation("map,map-stage,map-battle,battle-gem-full,unknown", False)

		Switch $sLocation
			Case ""
				;Goes into map if location is not within list above
                addLog($g_aLog, "-Navigating to 'map.'", $LOG_NORMAL)

				If navigate("map", False, False) = False Then
					addLog($g_aLog, "Could not navigate to 'map.'", $LOG_ERROR)
                    Return False
				EndIf
			Case "map"
				;Looks for stage
				addLog($g_aLog, "-Searching for " & $sMap & ".", $LOG_NORMAL)

				Local $aPoint = getMapCoor($sMap) ;Coordinates of found map.

				Local $t_hTimer = TimerInit()
				While isArray($aPoint) = False
					If _Sleep(10) Then Return False
					If TimerDiff($t_hTimer) > 30000 Then 
						addLog($g_aLog, "Could not find map.", $LOG_ERROR)
						Return False
					EndIf

					;If map has not been found scrolls left
					clickDrag($g_aSwipeLeft)

					If getLocation() <> "map" Then ContinueLoop(2) ;Goes back to main loop if misclick happens
					$aPoint = getMapCoor($sMap)
				WEnd

				$bFound = True
				If clickWhile($aPoint, "isLocation", "map", 10, 1000) = False Then
					addLog($g_aLog, "Could not enter to map-stage.", $LOG_ERROR)
					Return False
                Else
					If _Sleep(300) Then Return False
					If getLocation() <> "map-stage" Then
						closeWindow()
						If getLocation($g_aLocations, False) = "map-stage" Then ContinueCase
					EndIf
				EndIf
			Case "map-stage"
				If $bFound = True Then
					;Selecting difficulty
					addLog($g_aLog, "-Changing difficulty to " & $sDifficulty & ".", $LOG_NORMAL)
					clickPoint(getArg($g_aPoints, "map-stage-mode"), 5, 100)
					If _Sleep(10) Then Return False

					Switch $sDifficulty
						Case "Normal", "Hard", "Extreme"
							clickPoint(getArg($g_aPoints, "map-stage-" & StringLower($sDifficulty)))
						Case Else
							addLog($g_aLog, "-Could not change level.", $LOG_ERROR)
					EndSwitch

					;Selecting stage level
					addLog($g_aLog, "-Searching for level.")
					Local $aStage = findLevel($sStage) ;Point to go into map-battle

					Local $t_hTimer = TimerInit()
					While isArray($aStage) = False
						If _Sleep(10) Then Return False
						If TimerDiff($t_hTimer) > 60000 Then 
							addLog($g_aLog, "Could not find level.", $LOG_ERROR)
							Return False
						EndIf

						If isArray($aStage) = False Then
							;Scrolling up sequence
							clickDrag($g_aSwipeDown)
						EndIf
						
						CaptureRegion()
						$aStage = findLevel($sStage)
					WEnd

					addLog($g_aLog, "-Entering stage level.", $LOG_NORMAL)
					Local $t_hTimer = TimerInit()
					While getLocation() <> "map-battle"
						If TimerDiff($t_hTimer) > 5000 Then ContinueLoop(2)
						clickPoint($aStage)

						If _Sleep(500) Then Return False
					WEnd

					If getLocation($g_aLocations, False) <> "map-battle" Then
						If navigate("map", False, False) = False Then
							addLog($g_aLog, "Could not enter stage level.", $LOG_NORMAL)
							Return False
						EndIf
					Else
						ContinueCase
					EndIf
				Else
					;Happens when accidentally clicked a map during scroll sequence
					navigate("map", False, False)
				EndIf

			Case "map-battle"
				;Making sure autofill astrochips are on.
				If clickWhile("737, 306", "isLocation", "map-battle", 10, 500) = True Then ;Autofill toggle
					If clickUntil("400, 323", "isLocation", "map-battle", 10, 500) = False Then ContinueLoop ;Autofill Astrochips button
				EndIf

				;Applying autobattle mode.
				If $bAuto = True Then
					addLog($g_aLog, "-Enabling autobattle mode.", $LOG_NORMAL)
					clickUntil(getArg($g_aPoints, "map-battle-autobattle"), "isLocation", "autobattle-prompt")
					clickWhile(getArg($g_aPoints, "map-battle-autobattle-confirm"), "isLocation", "autobattle-prompt")
				EndIf

				If getLocation($g_aLocations, False) = "autobattle-prompt" Then
					If clickUntil("489, 310", "isLocation", "map-battle", 10, 200) = False Then ContinueLoop
				EndIf

				;Starting battle
				addLog($g_aLog, "-Entering battle.", $LOG_NORMAL)
				If enterBattle() = True Then
					addLog($g_aLog, "Finished entering stage.", $LOG_NORMAL)
					Return True
				Else
					addLog($g_aLog, "Failed to enter stage.", $LOG_ERROR)
					Return False
				EndIf
			Case "unknown"
				closeWindow()
		EndSwitch
	WEnd

	Return False ;If time runs out
EndFunc

