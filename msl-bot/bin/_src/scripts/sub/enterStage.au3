#include-once

#cs
	Function: Algorithm for entering a stage in the maps.
	Parameters:
		sMap - Map name. Available can be found in global.au3
		sDifficutly - Modes include: normal, hard, extreme
		sStage - Level number, includes "Gold", "Any", "Exp", "Boss"
	Returns: (boolean) On success returns true, fail return false
#ce
Func enterStage($sMap, $sDifficulty = "Normal", $sStage = "Exp")
	Local $bOutput = False
	Log_Level_Add("enterStage")
	Log_Add("Entering " & $sMap & " Stage " & $sStage & " on " & $sDifficulty & ".")

	Local $bFoundMap = False
	Local $hTimer = TimerInit()
	While TimerDiff($hTimer) < 60000
		If _Sleep(300) Then ExitLoop
		Local $sLocation = getLocation()
		Switch $sLocation
			Case "map"
				Log_Add("Searching for map.")
				Local $aPoint = findMap($sMap)
				If isArray($aPoint) > 0 Then
					clickPoint($aPoint) 
					If waitLocation("map-stage", 5) Then $bFoundMap = True
				EndIf
			Case "map-stage"
				If $bFoundMap > 0 Then
					Local $hTimer2 = TimerInit()
					While isArray(findImage("misc-stage-" & StringLower($sDifficulty), 90, 0, 611, 62, 737-611, 92-62, True)) = False
						If TimerDiff($hTimer2) > 5000 Then
							Log_Add("Could not select stage level.", $LOG_ERROR)
							ExitLoop(2)
						EndIf

						
						Log_Add("Changing difficulty to " & $sDifficulty & ".")
						clickPoint(getPointArg("map-stage-mode"), 2)
						If _Sleep(500) Then ExitLoop(2)
						clickPoint(getPointArg("map-stage-" & StringLower($sDifficulty)))
						If _Sleep(500) Then ExitLoop(2)
					WEnd
					
					If StringLower($sStage) == "any" Then
						For $y = 470 To 238 Step -2
							If isPixel(CreateArr(709, $y, 0xFEF7C9), 10, CaptureRegion()) > 0 Then
								clickPoint(CreateArr(709, $y))
								waitLocation("map-battle", 10)
								ExitLoop
							EndIf
						Next
					Else
						Local $aPoint = findLevel($sStage)
						If isArray($aPoint) > 0 Then
							clickPoint($aPoint)
							waitLocation("map-battle", 10)
						Else
							If isArray(findLevel(1)) > 0 Then ExitLoop
							clickDrag($g_aSwipeDown)
						EndIf
					EndIf
				Else
					navigate("map")
				EndIf
			Case "refill"
				ExitLoop
			Case "map-battle"
				If isPixel(getPixelArg("map-battle-autofill-on"), 20, CaptureRegion()) <= 0 Then
					clickPoint(getPointArg("astrochips-refill"))
					ContinueLoop
				EndIf

				enterBattle()
			Case "autobattle-prompt", "popup-window"
				closeWindow()
			Case "refill-astrochips-popup"
				clickPoint(getPointArg("astrochips-popup-refill"))
            Case "battle-astromon-full", "map-astromon-full", "astromon-full", "map-gem-full", "battle-gem-full"
                ExitLoop
			Case "battle", "battle-auto"
				$bOutput = True
				ExitLoop
			Case Else
				If HandleCommonLocations($sLocation) = 0 And navigate("map", True, 3) = 0 Then ExitLoop
				$bFoundMap = False
		EndSwitch
	WEnd

	Log_Level_Remove()
	Log_Add("Enter stage result: " & $bOutput, $LOG_DEBUG)
	Return $bOutput
EndFunc