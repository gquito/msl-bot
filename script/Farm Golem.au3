;function: farmGolem
;-Automatically farms golem and gives information
;pre:
;   -config must be set for script
;   -required config keys: map, capture, guardian-dungeon
;author: GkevinOD
Func farmGolem()
	;beginning script
	setLog("*Loading config for Farm Golem.", 2)

	Dim $strGolem = Int(IniRead(@ScriptDir & "/" & $botConfig, "Farm Golem", "dungeon", 7))
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

	Dim $guardian = Int(IniRead(@ScriptDir & "/" & $botConfig, "Farm Golem", "farm-guardian", 0))
	Dim $intSellGradeMin = Int(IniRead(@ScriptDir & "/" & $botConfig, "Farm Golem", "sell-grade-min", 4))
	Dim $intKeepGradeMinSub = Int(IniRead(@ScriptDir & "/" & $botConfig, "Farm Golem", "keep-grade-min-sub", 5))
	Dim $intMinSub = Int(IniRead(@ScriptDir & "/" & $botConfig, "Farm Golem", "min-sub", 4))
	Dim $intGem = Int(IniRead(@ScriptDir & "/" & $botConfig, "Farm Golem", "max-spend-gem", 0))
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

			Dim $strData = "Runs: " & $intRunCount & " (Guardian:" & $intGuardian & ")|Profit: " & StringRegExpReplace(String($intGoldPrediction), "(\d)(?=(\d{3})+$)", "$1,") & "|Energy Used: " & ($intRunCount * $intGolem) & "|Gems Used: " & ($intGemUsed & "/" & $intGem) & "|Time Elapse: " & StringFormat("%.2f", $intTimeElapse / 60) & " Min." & "|Avg. Time: " & StringFormat("%.2f", $intTimeElapse / $intRunCount / 60) & " Min."

			GUICtrlSetData($listScript, "")
			GUICtrlSetData($listScript, $strData)

			Switch getLocation()
				Case "battle-end"
					If checkPixel($battle_pixelQuest) = True Then
						If setLog("Detected quest complete, navigating to village.", 1) Then ExitLoop (2)
						If navigate("village", "quests") = 1 Then
							If setLog("Collecting quests.", 1) Then ExitLoop (3)
							For $questTab In $village_coorArrayQuestsTab ;quest tabs
								clickPoint(StringSplit($questTab, ",", 2))
								While IsArray(findImageWait("misc-quests-get-reward", 3, 100)) = True
									If _Sleep(10) Then ExitLoop (5)
									clickImage("misc-quests-get-reward", 100)
								WEnd
							Next
						EndIf
						navigate("map") ;go back to map to repeat golem process
					EndIf


					If $getHourly = True Then
						If getHourly() = 1 Then
							$getHourly = False
						EndIf
						If $getGuardian = True Then ExitLoop
					Else
						If $getGuardian = True Then
							ExitLoop
						Else
							If checkLocations("battle-end") = 1 Then
								clickImageUntil("battle-quick-restart", "battle")
								$intRunCount += 1

								If checkLocations("battle-end") Then navigate("map")
							EndIf
						EndIf
					EndIf
				Case "refill"
					If $intGemUsed + 30 <= $intGem Then
						clickPointUntil($game_coorRefill, "refill-confirm")
						clickPointUntil($game_coorRefillConfirm, "refill")

						If checkLocations("buy-gem") Then
							setLog("Out of gems!", 2)
							ExitLoop (2)
						EndIf

						ControlSend($hWindow, "", "", "{ESC}")

						setLog("Refill gems: " & $intGemUsed + 30 & "/" & $intGem, 0)
						$intGemUsed += 30
					Else
						setLog("Gem used exceed max gems!", 0)
						ExitLoop (2)
					EndIf
				Case "map", "village", "astroleague", "map-stage", "map-battle"
					If navigate("map", "golem-dungeons") = 1 Then
						clickPointUntil(Eval("map_coorB" & $strGolem), "map-battle")
						clickPointUntil($map_coorBattle, "battle")

						$intRunCount += 1
					Else
						setLog("Unable to navigate to dungeon.", 1)
						ExitLoop (2)
					EndIf
				Case "battle-end-exp"
					clickPoint($game_coorTap)
					While waitLocation("battle-sell", 3) = 0
						clickPoint($game_coorTap)
					WEnd
					If _Sleep(10) Then ExitLoop (2)

					Local $gemInfo = sellGem("B" & $strGolem, $intSellGradeMin, True, 6, $intKeepGradeMinSub, $intMinSub)
					If IsArray($gemInfo) And StringInStr($gemInfo[6], "!") Then
						$intGoldPrediction += $intGoldEnergy
					EndIf
				Case "battle-gem-full"
					setLog("Gem inventory is full!", 2)
					ExitLoop (2)
				Case "defeat"
					clickImageFiles("battle-give-up", 30)
					clickPointUntil($game_coorTap, "battle-end", 20, 1000)
				Case "lost-connection"
					clickPoint($game_coorConnectionRetry)
				Case "unknown"
					clickPoint($game_coorTap)

					Local $closePoint = findImageFiles("misc-close", 30)
					If isArray($closePoint) Then
						clickPoint($closePoint) ;to close any windows open
					EndIf
			EndSwitch
		WEnd

		Local $foundDungeon = 0
		If $guardian = 1 And navigate("map", "guardian-dungeons") = 1 Then
			If setLog("Checking for guardian dungeons...", 1) Then ExitLoop (2)
			While checkLocations("guardian-dungeons") = 1
				If clickImageUntil("misc-dungeon-energy", "map-battle", 50) = 1 Then
					clickPointWait($map_coorBattle, "map-battle", 5)

					If _Sleep(3000) Then ExitLoop (2)

					If checkLocations("map-gem-full", "battle-gem-full") = 1 Then
						If setLog("Gem inventory is full.", 2) Then ExitLoop (2)
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

							setLog("Refill gems: " & $intGemUsed + 30 & "/" & $intGem, 0)
							$intGemUsed += 30
						Else
							setLog("Gem used exceed max gems!", 2)
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
