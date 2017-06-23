
Func farmStarstone()
	Local $level = IniRead($botConfigDir, "Farm Starstone", "level", 10)
	Local $refillGems = IniRead($botConfigDir, "Farm Starstone", "refill-gems", 500)
	Local $high = IniRead($botConfigDir, "Farm Starstone", "high", 20)
	Local $mid = IniRead($botConfigDir, "Farm Starstone", "mid", 0)
	Local $low = IniRead($botConfigDir, "Farm Starstone", "low", 0)

	setLog("~~~Starting 'Farm Starstone' script~~~", 2)
	farmStarstoneMain($level, $refillGems, $high, $mid, $low)
	setLog("~~~Finished 'Farm Starstone' script~~~", 2)
EndFunc   ;==>farmStarStone

Func farmStarstoneMain($level, $refillGems, $high, $mid = 0, $low = 0)
	$globalScriptTimer = TimerInit()

	;setting variables
	Local $maxGems = $refillGems
	Local $totHigh = $high
	Local $totMid = $mid
	Local $totLow = $low

	setList("High Stones: " & $totHigh-$high  & "/" & $totHigh & "|Mid Stones: " & $totMid-$mid  & "/" & $totMid & "|Low Stones: " & $totLow-$low  & "/" & $totLow & "|Gems used: " & $maxGems-$refillGems & "/" & $maxGems)

	;force navigate to starstone dungeons
	If setLog("Navigating to Starstone Dungeons.") Then Return -1
	Local $stuckTimer = TimerInit()
	While navigate("map", "starstone-dungeons", True) = False
		If TimerDiff($stuckTimer) > 60000*3 Then
			If setLog("Could not navigate to starstone dungeons.", 2) Then Return -1
			Return False
		EndIf
	WEnd

	;select level [incomplete]
	While checkLocations("battle,battle-auto") = ""
		MsgBox($MB_OK, $botName & " " & $botVersion, "Selecting the level for this script is unavailable. Go into your desired starstone level and enter battle and then press OK." & @CRLF & @CRLF & "Not all pixels are available therefore the script might not be able to read the amount of stones. Stage B10 is recommended.")
	WEnd

	;grind for starstone
	While (($high > 0) Or ($mid > 0) Or ($low > 0))
		setList("High Stones: " & $totHigh-$high  & "/" & $totHigh & "|Mid Stones: " & $totMid-$mid  & "/" & $totMid & "|Low Stones: " & $totLow-$low  & "/" & $totLow & "|Gems used: " & $maxGems-$refillGems & "/" & $maxGems)

		Local $currLocation = getLocation()

		antiStuck("map")
		Switch getLocation()
			Case "battle"
				clickPoint($battle_coorAuto)
			Case "battle-end"
				If (($high > 0) Or ($mid > 0) Or ($low > 0)) Then
					If clickUntil($battle_coorRestart, "unknown,refill", 30, 1000) = True Then
						If getLocation() = "refill" Then ContinueCase
					EndIf
				EndIf
			Case "refill"
				If $refillGems >= 30 Then
					clickUntil($game_coorRefill, "refill-confirm")

					If getLocation() = "buy-gem" Or getLocation() = "unknown" Then
						setLog("Out of gems!", 2)
						ExitLoop
					EndIf

					clickWhile($game_coorRefillConfirm, "refill-confirm")
					clickWhile("705, 99", "refill")

					$refillGems -= 30
				Else
					setLog("Gem used exceed max gems!", 0)
					ExitLoop
				EndIf
			Case "battle-end-exp", "battle-sell", "battle-sell-item"
				clickUntil("193,255", "battle-sell-item", 500, 100)
				If _Sleep(10) Then ExitLoop

				Local $stoneInfo = getStone()
				If IsArray($stoneInfo) Then
					If Not($stoneInfo[0] = "EGG") Then
						Switch $stoneInfo[1]
							Case "LOW"
								$low -= $stoneInfo[2]
							Case "MID"
								$mid -= $stoneInfo[2]
							Case "HIGH"
								$high -= $stoneInfo[2]
						EndSwitch
					EndIf
				EndIf
			Case "defeat"
				clickPoint(findImage("battle-give-up", 30))
				clickUntil($game_coorTap, "battle-end", 20, 1000)
			Case "lost-connection"
				clickPoint($game_coorConnectionRetry)
			Case "battle-boss"
					waitLocation("battle-auto", 5000)
					clickPoint("406, 209")
			Case "pause"
				clickPoint($battle_coorContinue)
			Case "map"
				Return farmStarstoneMain($level, $refillGems, $high, $mid, $low)
		EndSwitch
	WEnd

	setList("High Stones: " & $totHigh-$high  & "/" & $totHigh & "|Mid Stones: " & $totMid-$mid  & "/" & $totMid & "|Low Stones: " & $totLow-$low  & "/" & $totLow)
	Return True
EndFunc
