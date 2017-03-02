;function: farmGolem
;-Automatically farms golem and gives information
;pre:
;   -config must be set for script
;   -required config keys: map, capture, guardian-dungeon
;author: GkevinOD
Func farmGolem()
	;beginning script
	setLog("*Loading config for Farm Golem.", 2)

	Dim $strGolem = Int(IniRead(@ScriptDir & "/config.ini", "Farm Golem", "dungeon", 7))
	Dim $intGoldEnergy = 12231
	Dim $intGolem = 7
	Switch ($strGolem)
		Case 1 To 3
			$intGolem = 5
		Case 4 To 6
			$intGolem = 6
		Case 7 To 9
			$intGolem = 7
		Case 10
			$intGolem = 8
	EndSwitch

	Dim $guardian = Int(IniRead(@ScriptDir & "/config.ini", "Farm Golem", "farm-guardian", 0))
	Dim $intSellGradeMin = Int(IniRead(@ScriptDir & "/config.ini", "Farm Golem", "sell-grade-min", 4))
	Dim $intKeepGradeMinSub = Int(IniRead(@ScriptDir & "/config.ini", "Farm Golem", "keep-grade-min-sub", 5))
	Dim $intMinSub = Int(IniRead(@ScriptDir & "/config.ini", "Farm Golem", "min-sub", 4))
	Dim $intGem = Int(IniRead(@ScriptDir & "/config.ini", "Farm Golem", "max-spend-gem", 0))
	Dim $intGemUsed = 0

	Dim $intStartTime = TimerInit()
	Dim $intGoldPrediction = 0
	Dim $intRunCount = 0
	Dim $intTimeElapse = 0
	Dim $intGuardian = 0
	Dim $getHourly = False
	Dim $getGuardian = True

	setLog("~~~Starting 'Farm Golem' script~~~", 2)
	While True
		While True
			If _Sleep(10) Then ExitLoop (2)
			$intTimeElapse = Int(TimerDiff($intStartTime) / 1000)

			If StringSplit(_NowTime(4), ":", 2)[1] = "00" Then $getHourly = True
			If Mod(Int(StringSplit(_NowTime(4), ":", 2)[1]), 20) = 0 Then $getGuardian = True

			Dim $strData = "Total Runs: " & $intRunCount & "|Total Guardian Runs:" & $intGuardian & "|Predicted Profit: " & StringRegExpReplace(String($intGoldPrediction), "(\d)(?=(\d{3})+$)", "$1,") & "|Energy Used: " & ($intRunCount * $intGolem) & "|Gems Used: " & ($intGemUsed & "/" & $intGem) & "|Total Time Elapse: " & StringFormat("%.2f", $intTimeElapse / 60) & " Min." & "|Average Time Per Run: " & StringFormat("%.2f", $intTimeElapse / $intRunCount / 60) & " Min."

			GUICtrlSetData($listScript, "")
			GUICtrlSetData($listScript, $strData)

			If checkLocations("battle-end") = 1 Then
				If $getHourly = True Then
					getHourly()
					$getHourly = False
					If $getGuardian = True Then ExitLoop
				Else
					If $getGuardian = True Then
						ExitLoop
					Else
						clickImageUntil("battle-quick-restart", "battle")
						$intRunCount += 1

						If checkLocations("battle-end") Then navigate("map")
					EndIf
				EndIf
			EndIf

			If checkLocations("refill") = 1 Then
				If $intGemUsed + 30 <= $intGem Then
					clickPointUntil($game_coorRefill, "refill-confirm")
					clickPointUntil($game_coorRefillConfirm, "refill")

					If checkLocations("buy-gem") Then
						setLog("Out of gems!", 1)
						ExitLoop (2)
					EndIf

					ControlSend($hWindow, "", "", "{ESC}")

					setLog("Refill gems: " & $intGemUsed + 30 & "/" & $intGem)
					$intGemUsed += 30
				Else
					setLog("Gem used exceed max gems!")
					ExitLoop (2)
				EndIf
			EndIf

			If checkLocations("map", "village", "astroleague", "map-stage", "map-battle") = 1 Then
				If navigate("map", "golem-dungeons") = 1 Then
					clickPointUntil(Eval("map_coorB" & $strGolem), "map-battle")
					clickPointUntil($map_coorBattle, "battle")

					$intRunCount += 1
				Else
					setLog("Unable to navigate to dungeon.")
					ExitLoop (2)
				EndIf
			EndIf

			If checkLocations("battle-end-exp") = 1 Then
				clickPoint($game_coorTap)
				While waitLocation("battle-sell", 3) = 0
					clickPoint($game_coorTap)
				WEnd
				If _Sleep(10) Then ExitLoop (2)

				Local $gemInfo = sellGem("B" & $strGolem, $intSellGradeMin, True, 6, $intKeepGradeMinSub, $intMinSub)
				If IsArray($gemInfo) And StringInStr($gemInfo[6], "!") Then
					$intGoldPrediction += $intGoldEnergy
				EndIf
			EndIf

			If checkLocations("battle-gem-full") = 1 Then
				setLog("Gem inventory is full!")
				ExitLoop (2)
			EndIf

			If checkLocations("defeat") = 1 Then
				clickImage("battle-give-up")
				clickPointUntil($game_coorTap, "battle-end", 20, 1000)
			EndIf

			If checkLocations("lost-connection") = 1 Then
				clickPoint($game_coorConnectionRetry)
			EndIf
		WEnd

		Local $foundDungeon = 0
		If $guardian = 1 And navigate("map", "guardian-dungeons") = 1 Then
			If setLog("Checking for guardian dungeons...", 1) Then ExitLoop (2)
			While checkLocations("guardian-dungeons") = 1
				If clickImageUntil("misc-dungeon-energy", "map-battle", 50) = 1 Then
					clickPointWait($map_coorBattle, "map-battle", 5)

					If _Sleep(3000) Then ExitLoop (2)

					If checkLocations("map-gem-full", "battle-gem-full") = 1 Then
						If setLog("Gem is full, going to sell gems...", 1) Then ExitLoop (2)
						If navigate("village", "manage") = 1 Then
							sellGems($imagesUnwantedGems)
						EndIf

						clickImageUntil("misc-dungeon-energy", "map-battle", 50)
						clickPointWait($map_coorBattle, "map-battle", 5)
					EndIf

					If checkLocations("refill") = 1 Then
						If $intGemUsed + 30 <= $intGem Then
							clickPointUntil($game_coorRefill, "refill-confirm")
							clickPointUntil($game_coorRefillConfirm, "refill")

							If checkLocations("buy-gem") Then
								setLog("Out of gems!", 1)
								ExitLoop
							EndIf

							ControlSend($hWindow, "", "", "{ESC}")

							setLog("Refill gems: " & $intGemUsed + 30 & "/" & $intGem)
							$intGemUsed += 30
						Else
							setLog("Gem used exceed max gems!")
							ExitLoop
						EndIf
						clickPointWait($map_coorBattle, "map-battle", 5)
					EndIf

					$foundDungeon += 1
					setLogReplace("Found dungeon, attacking x" & $foundDungeon & ".", 1)

					If waitLocation("battle-end-exp", 240) = 0 Then
						If setLog("Unable to finish golem in 5 minutes!", 1) Then ExitLoop (2)
						ExitLoop
					EndIf

					clickPointUntil($game_coorTap, "battle-end", 20, 1000)
					clickImageUntil("battle-exit", "guardian-dungeons", 50)
				Else
					If setLog("Guardian dungeon not found, going back to map.", 1) Then ExitLoop (2)
					navigate("map")
					ExitLoop
				EndIf
			WEnd
		EndIf
		$intGuardian += $foundDungeon
		$getGuardian = False
	WEnd

	setLog("~~~Finished 'Farm Golem' script~~~", 2)
EndFunc   ;==>farmGolem
