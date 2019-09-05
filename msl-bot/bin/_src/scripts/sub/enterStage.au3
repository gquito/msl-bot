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
				If isArray($aPoint) = True Then
					clickPoint($aPoint) 
					If waitLocation("map-stage", 5) Then $bFoundMap = True
				EndIf
			Case "map-stage"
				If $bFoundMap = True Then
					Local $hTimer2 = TimerInit()
					If isPixel(getPixelArg("map-stage-" & StringLower($sDifficulty))) = False Then
						Log_Add("Changing difficulty to " & $sDifficulty & ".")
						clickPoint(getPointArg("map-stage-mode"), 5, 100)
						clickPoint(getPointArg("map-stage-" & StringLower($sDifficulty)))
					EndIf

					Local $aPoint = findLevel($sStage)
					If isArray($aPoint) = True Then
						clickPoint($aPoint)
						waitLocation("map-battle", 10)
					Else
						If isArray(findLevel(1)) = True Then ExitLoop
						clickDrag($g_aSwipeDown)
					EndIf
				Else
					navigate("map")
				EndIf
			Case "refill"
				ExitLoop
			Case "map-battle"
				If isPixel(getPixelArg("map-battle-autofill-on"), 20) = False Then
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
				If HandleCommonLocations($sLocation) = False And navigate("map", True, 3) = False Then ExitLoop
				$bFoundMap = False
		EndSwitch
	WEnd

	Log_Level_Remove()
	Log_Add("Enter stage result: " & $bOutput, $LOG_DEBUG)
	Return $bOutput
EndFunc