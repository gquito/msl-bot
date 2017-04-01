;function: farmGolem
;-Automatically farms golem and gives information
;pre:
;   -config must be set for script
;   -required config keys: map, capture, guardian-dungeon
;author: GkevinOD
Func farmGolem()
	;beginning script
	setLog("*Loading config for Farm Golem.", 2)

	Local $strGolem = Int(IniRead(@ScriptDir & "/" & $botConfig, "Farm Golem", "dungeon", 7))
	Local $intGoldEnergy = 12231
	Local $intGolem = 7
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

	Local $guardian = Int(IniRead(@ScriptDir & "/" & $botConfig, "Farm Golem", "farm-guardian", 0))
	Local $intSellGradeMin = Int(IniRead(@ScriptDir & "/" & $botConfig, "Farm Golem", "sell-grade-min", 4))
	Local $intKeepGradeMinSub = Int(IniRead(@ScriptDir & "/" & $botConfig, "Farm Golem", "keep-grade-min-sub", 5))
	Local $intMinSub = Int(IniRead(@ScriptDir & "/" & $botConfig, "Farm Golem", "min-sub", 4))
	Local $intGem = Int(IniRead(@ScriptDir & "/" & $botConfig, "Farm Golem", "max-spend-gem", 0))
	Local $intGemUsed = 0

	Local $intCheckStartTime = 0
	Local $intStartTime = TimerInit()
	Local $intGoldPrediction = 0
	Local $intRunCount = 0
	Local $intTimeElapse = 0
	Local $intGuardian = 0
	Local $getHourly = False
	Local $getGuardian = True

	setLog("~~~Starting 'Farm Golem' script~~~", 2)
	While True
		While True
			If _Sleep(10) Then ExitLoop (2)
			$intTimeElapse = Int(TimerDiff($intStartTime) / 1000)

			If StringSplit(_NowTime(4), ":", 2)[1] = "00" Then $getHourly = True
			If Mod(Int(StringSplit(_NowTime(4), ":", 2)[1]), 20) = 0 Then $getGuardian = True

			Local $strData = "Runs: " & $intRunCount & " (Guardian:" & $intGuardian & ")|Profit: " & StringRegExpReplace(String($intGoldPrediction), "(\d)(?=(\d{3})+$)", "$1,") & "|Energy Used: " & ($intRunCount * $intGolem) & "|Gems Used: " & ($intGemUsed & "/" & $intGem) & "|Time Elapse: " & StringFormat("%.2f", $intTimeElapse / 60) & " Min." & "|Avg. Time: " & StringFormat("%.2f", $intTimeElapse / $intRunCount / 60) & " Min."

			GUICtrlSetData($listScript, "")
			GUICtrlSetData($listScript, $strData)

			Switch getLocation()
				Case "battle"
					Local $intCheckTime = Int(TimerDiff($intCheckStartTime) / 1000)
					If Not($intCheckStartTime = 0) And ($intCheckTime > 600) Then
						If setLog("Battle has not finished in 10 minutes! Attacking..", 1) Then ExitLoop (2)
						clickPoint($battle_coorAuto)
						$intCheckStartTime = TimerInit() ;reset timer
					EndIf
				Case "battle-end"
					$intCheckStartTime = 0

					_CaptureRegion()
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
								Local $quickRestart = findImageFiles("battle-quick-restart", 30)
								clickPointUntil($quickRestart, "unknown")
								$intRunCount += 1
								$intCheckStartTime = TimerInit()

								If checkLocations("battle-end") Then navigate("map")
							EndIf
						EndIf
					EndIf
				Case "refill"
					$intCheckStartTime = 0

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
					$intCheckStartTime = 0

					Local $result = navigate("map", "golem-dungeons")
					If $result = 1 Then
						clickPointUntil(Eval("map_coorB" & $strGolem), "map-battle")
						clickPointUntil($map_coorBattle, "battle")

						$intRunCount += 1
						$intCheckStartTime = TimerInit()
					ElseIf $result = 0 Then
						setLog("Unable to navigate to dungeon.", 1)
						ExitLoop (2)
					EndIf
				Case "battle-end-exp"
					$intCheckStartTime = 0

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
					$intCheckStartTime = 0

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

		Dim $foundDungeon = 0
		If $guardian = 1 And navigate("map", "guardian-dungeons") = 1 Then
			If setLog("Checking for guardian dungeons...", 1) Then ExitLoop (2)
			Local $currLocation = getLocation()

			While $currLocation = "guardian-dungeons"
				Local $energyPoint = findImageFiles("misc-dungeon-energy", 50)
				If isArray($energyPoint) And (clickPointUntil($energyPoint, "map-battle", 50) = 1) Then
					clickPointWait($map_coorBattle, "map-battle", 5)

					If _Sleep(500) Then ExitLoop (2)

					If checkLocations("map-gem-full", "battle-gem-full") = 1 Then
						setLog("Gem box is full!", 0)
						ExitLoop (2)
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
					If setLogReplace("Found dungeon, attacking x" & $foundDungeon & ".", 1) Then ExitLoop (2)

					Local $initTime = TimerInit()
					While True
						_Sleep(1000)
						If getLocation() = "battle-end-exp" Then ExitLoop

						If Int(TimerDiff($initTime)/1000) > 240 Then
							If setLog("Error: Could not finish Guardian dungeon within 5 minutes, exiting.") Then ExitLoop(2)
							navigate("map")

							ExitLoop
						EndIf
					WEnd

					clickPointUntil($game_coorTap, "battle-end", 20, 1000)
					clickImageUntil("battle-exit", "guardian-dungeons", 20)

					waitLocation("guardian-dungeons", 10000)
					$currLocation = getLocation()
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
