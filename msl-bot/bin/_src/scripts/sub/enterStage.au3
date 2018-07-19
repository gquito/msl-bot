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
	Log_Level_Add("enterStage")
	Log_Add("Entering " & $sMap & " Stage " & $sStage & " on " & $sDifficulty & ".")

	Local $bOutput = False
	While True
		If getLocation() = "map" Then
			Log_Add("Resetting map position.")
			Local $t_hTimer = TimerInit()
			While (isArray(getMapCoor("Phantom Forest")) = False) And (TimerDiff($t_hTimer) < 10000)
				clickDrag($g_aSwipeRight)
			WEnd
			clickDrag($g_aSwipeRight)
		EndIf

		Local $bFound = False
		Local $hTimer = TimerInit()
		While TimerDiff($hTimer) < 120000 ;2 Minutes
			If _Sleep(10) Then ExitLoop(2)
			Local $sLocation = isLocation("map,map-stage,map-battle,battle-gem-full,unknown", False)

			Switch $sLocation
				Case ""
					;Goes into map if location is not within list above
					If navigate("map", False) = False Then ExitLoop(2)
				Case "map"
					;Looks for stage
					Log_Add("Searching for map.")

					Local $aPoint = getMapCoor($sMap) ;Coordinates of found map.

					Local $t_hTimer = TimerInit()
					While isArray($aPoint) = False
						If _Sleep(10) Then ExitLoop(3)
						If TimerDiff($t_hTimer) > 30000 Then 
							Log_Add("Could not find map.", $LOG_ERROR)
							ExitLoop(3)
						EndIf

						;If map has not been found scrolls left
						clickDrag($g_aSwipeLeft)

						If getLocation() <> "map" Then ContinueLoop(2) ;Goes back to main loop if misclick happens
						$aPoint = getMapCoor($sMap)
					WEnd

					$bFound = True
					If clickWhile($aPoint, "isLocation", "map", 10, 1000) = False Then
						Log_Add("Could not enter to map-stage.", $LOG_ERROR)
						ExitLoop(2)
					Else
						If _Sleep(300) Then ExitLoop(2)
						If getLocation() <> "map-stage" Then
							closeWindow()
							If getLocation($g_aLocations, False) = "map-stage" Then ContinueCase
						EndIf
					EndIf
				Case "map-stage"
					If $bFound = True Then
						;Selecting difficulty
						Log_Add("Changing difficulty to " & $sDifficulty & ".")
						clickPoint(getArg($g_aPoints, "map-stage-mode"), 5, 100)
						If _Sleep(10) Then ExitLoop(2)

						Switch $sDifficulty
							Case "Normal", "Hard", "Extreme"
								clickPoint(getArg($g_aPoints, "map-stage-" & StringLower($sDifficulty)))
							Case Else
								Log_Add("Could not change level.", $LOG_ERROR)
						EndSwitch

						;Selecting stage level
						Log_Add("Searching for level.")
						Local $aStage = findLevel($sStage) ;Point to go into map-battle

						Local $t_hTimer = TimerInit()
						While isArray($aStage) = False
							If _Sleep(10) Then ExitLoop(3)
							If TimerDiff($t_hTimer) > 60000 Then 
								Log_Add("Could not find level.", $LOG_ERROR)
								ExitLoop(3)
							EndIf

							If isArray($aStage) = False Then
								;Scrolling up sequence
								clickDrag($g_aSwipeDown)
							EndIf
							
							CaptureRegion()
							$aStage = findLevel($sStage)
						WEnd

						Log_Add("Entering stage level.")
						Local $t_hTimer = TimerInit()
						While getLocation() <> "map-battle"
							If TimerDiff($t_hTimer) > 5000 Then ContinueLoop(2)
							clickPoint($aStage)

							If _Sleep(500) Then ExitLoop(3)

							While getLocation() = "autobattle-prompt"
								If TimerDiff($t_hTimer) > 5000 Then ContinueLoop(3)
								clickPoint("494,330")
							WEnd
						WEnd

						If getLocation($g_aLocations, False) <> "map-battle" Then
							If navigate("map", False, False) = False Then
								Log_Add("Could not enter stage level.")
								ExitLoop(2)
							EndIf
						Else
							ContinueCase
						EndIf
					Else
						;Happens when accidentally clicked a map during scroll sequence
						navigate("map", False)
					EndIf

				Case "map-battle"
					;Making sure autofill astrochips are on.
					Log_Add("Making sure autofill is turned on.")
					If clickWhile("737, 306", "isLocation", "map-battle", 10, 500) = True Then ;Autofill toggle
						If clickUntil("400, 323", "isLocation", "map-battle", 10, 500) = False Then ContinueLoop ;Autofill Astrochips button
					EndIf
					
					;Applying autobattle mode.
					If $bAuto = True Then
						Log_Add("Enabling autobattle mode.")
						clickUntil(getArg($g_aPoints, "map-battle-autobattle"), "isLocation", "autobattle-prompt")
						clickWhile(getArg($g_aPoints, "map-battle-autobattle-confirm"), "isLocation", "autobattle-prompt")
					EndIf

					If getLocation($g_aLocations, False) = "autobattle-prompt" Then
						If clickUntil("489, 310", "isLocation", "map-battle", 10, 200) = False Then ContinueLoop
					EndIf

					;Starting battle
					Log_Add("Entering battle.")
					$bOutput = enterBattle()
					ExitLoop(2)
				Case "unknown"
					closeWindow()
			EndSwitch
		WEnd

		ExitLoop
	WEnd

	Log_Add("Enter stage result: " & $bOutput & ".", $LOG_DEBUG)
	Log_Level_Remove()
	Return $bOutput
EndFunc

