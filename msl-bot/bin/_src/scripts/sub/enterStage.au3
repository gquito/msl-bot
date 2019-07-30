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
	Local $bOutput = False
	Log_Level_Add("enterStage")
	Log_Add("Entering " & $sMap & " Stage " & $sStage & " on " & $sDifficulty & ".")

	While True
		Local $bFound = False
		Local $hTimer = TimerInit()
		While TimerDiff($hTimer) < 120000 ;2 Minutes
			If (_Sleep(10)) Then ExitLoop(2)

			Switch getLocation()
				Case "map"
					;Looks for stage
					Log_Add("Searching for map.")

                    Local $aPoint = navigateWhileOnMap($sMap)
                    
                    If (isArray($aPoint)) Then 
						clickPoint($aPoint)
						If (waitlocation("map-stage",3,100)) Then 
							$bOutput = True
						Else
							$bOutput = clickWhile($aPoint, "isLocation", "map,dialogue-skip", 10, $g_iNavClickDelay)
						EndIf
					EndIf
					
					$bFound = True
					If (Not($bOutput)) Then
						Log_Add("Could not enter to map-stage.", $LOG_ERROR)
						ExitLoop(2)
					Else
						If (_Sleep(300)) Then ExitLoop(2)
						If (isLocation("map-stage")) Then ContinueCase

						closeWindow()
						ContinueLoop

					EndIf
				Case "map-stage"
					If ($bFound) Then
						;Selecting difficulty
						If (Not(isPixel(getPixelArg("map-stage-"& StringLower($sDifficulty))))) Then
							Log_Add("Changing difficulty to " & $sDifficulty & ".")
							clickPoint(getPointArg("map-stage-mode"), 5, 100)
							If (_Sleep(10)) Then ExitLoop(2)
							Switch $sDifficulty
								Case "Normal", "Hard", "Extreme"
									clickPoint(getPointArg("map-stage-" & StringLower($sDifficulty)))
								Case Else
									Log_Add("Could not change level.", $LOG_ERROR)
							EndSwitch
						EndIf

						;Selecting stage level
						Log_Add("Searching for level.")
						Local $aStage = findLevel($sStage) ;Point to go into map-battle

						Local $t_hTimer = TimerInit()
						While Not(isArray($aStage))
							If ($aStage = -2) Then
								Log_Add("No longer in map-stage.", $LOG_DEBUG)
								if (navigate("map-stage")) Then ContinueLoop(2)
							EndIF
							If (_Sleep(10)) Then ExitLoop(3)
							If (TimerDiff($t_hTimer) > 60000) Then 
								Log_Add("Could not find level.", $LOG_ERROR)
								ExitLoop(3)
							EndIf

							If (Not(isArray($aStage))) Then
								;Scrolling up sequence
								If (Not(clickDrag($g_aSwipeDown))) Then ExitLoop(3)
							EndIf
							
							$aStage = findLevel($sStage)
							If isArray($aStage) = True Then
								;Trying to avoid coords y:288-336
								Local $t_hTimer2 = TimerInit()
								While (isArray($aStage) = True And ($aStage[1] > 288 And $aStage[1] < 336))
									If TimerDiff($t_hTimer2) > 5000 Then ExitLoop
									If clickDrag($g_aSwipeDown_Half) = False Then ExitLoop(4)
									$aStage = findLevel($sStage)
								WEnd
							EndIf
						WEnd

						Log_Add("Entering stage level.")
						If clickWhile($aStage, "isLocation", "map-stage", 5, 2000) = False Then
							If navigate("map") = False Then
								Log_Add("Could not enter stage level.")
								ExitLoop(2)
							EndIf
						EndIf
					Else
						;Happens when accidentally clicked a map during scroll sequence
						navigate("map", False)
					EndIf
				Case "autobattle-prompt"
					$t_hTimer = TimerInit()
					While isLocation("autobattle-prompt")
						If (TimerDiff($t_hTimer) > 5000) Then ContinueLoop(2)
						closeWindow()
						If (_Sleep(300)) Then ExitLoop(3)
					WEnd

				Case "map-battle"
					;Check autofill
					If _Sleep(500) Or getLocation() <> "map-battle" Then ContinueLoop
					If isPixel(getPixelArg("map-battle-autofill-on"), 20) = False Then
						Log_Add("Enabling autofill astrochips")
						clickWhile(getPixelArg("map-battle-autofill-on"), "isLocation", "map-battle", 5, 1000)

						If waitLocation("popup-window,refill-astrochips-popup", 2) Then
							clickUntil(getPointArg("map-battle-autofill"), "isLocation", "map-battle", 10, 500)
						EndIf
					EndIf

					;Applying autobattle mode.
					If ($bAuto) Then
						Log_Add("Enabling autobattle mode.")
						clickUntil(getPointArg("map-battle-autobattle"), "isLocation", "autobattle-prompt")
						clickWhile(getPointArg("map-battle-autobattle-confirm"), "isLocation", "autobattle-prompt")
					EndIf

					If (isLocation("autobattle-prompt")) Then
						If (Not(clickUntil("489,310", "isLocation", "map-battle", 10, 200))) Then ContinueLoop
					EndIf

					;Starting battle
					$bOutput = enterBattle()
					ExitLoop(2)
				Case "refill-astrochips-popup"
					Log_Add("Enabling Autofill Astrochips")
					clickWhile(getPixelArg("map-battle-autofill-on"), "isLocation", "map-battle", 5, 1000)

					If waitLocation("popup-window,refill-astrochips-popup", 2) Then
						clickUntil(getPointArg("map-battle-autofill"), "isLocation", "map-battle", 10, 500)
					EndIf
				Case "unknown"
					closeWindow()
				Case Else
					If (Not(navigate("map", False))) Then ExitLoop(2)
			EndSwitch
		WEnd

		ExitLoop
	WEnd

	Log_Add("Enter stage result: " & $bOutput & ".", $LOG_DEBUG)
	Log_Level_Remove()
	Return $bOutput
EndFunc

Func TestAutoFill()
    Local $s_CurrColor = getColor(751,305)
    If (isPixel(getPixelArg("autofill-toggle-off"), 10)) Then
        If (Not(isPixel("751,305," & $s_CurrColor, 10))) Then
            Log_Add("Color found was " & $s_CurrColor & " but was not actually detected at 751,305",$LOG_INFORMATION)
            Return False
        Else
            Log_Add("Pixel was found: 751,305," & $s_CurrColor ,$LOG_INFORMATION)
            Return True
        EndIf
    Else
        Log_Add("Pixel was found: " & getPixelArg("autofill-toggle-off") & ", real color: " & $s_CurrColor,$LOG_INFORMATION)
        Return True
    EndIf
EndFunc