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

	Local $sellGems = Int(IniRead(@ScriptDir & "/" & $botConfig, "Farm Golem", "sell-gems", 1))
	Local $guardian = Int(IniRead(@ScriptDir & "/" & $botConfig, "Farm Golem", "farm-guardian", 0))
	Local $intSellGradeMin = Int(IniRead(@ScriptDir & "/" & $botConfig, "Farm Golem", "sell-grade-min", 4))
	Local $intKeepGradeMinSub = Int(IniRead(@ScriptDir & "/" & $botConfig, "Farm Golem", "keep-grade-min-sub", 5))
	Local $intMinSub = Int(IniRead(@ScriptDir & "/" & $botConfig, "Farm Golem", "min-sub", 4))
	Local $intGem = Int(IniRead(@ScriptDir & "/" & $botConfig, "Farm Golem", "max-spend-gem", 0))
	Local $intGemUsed = 0

	Local $quest = IniRead(@ScriptDir & "/" & $botConfig, "Farm Golem", "collect-quest", "1")
	Local $hourly = IniRead(@ScriptDir & "/" & $botConfig, "Farm Golem", "collect-hourly", "1")

	Local $intStartTime = TimerInit()
	Local $intGoldPrediction = 0
	Local $intRunCount = 0
	Local $intTimeElapse = 0
	Local $intGuardian = 0
	Local $getHourly = False
	Local $getGuardian = False

	setLog("~~~Starting 'Farm Golem' script~~~", 2)
	While True
		While True
			If _Sleep(100) Then ExitLoop (2)
			$intTimeElapse = Int(TimerDiff($intStartTime) / 1000)

			If $hourly = 1 And StringSplit(_NowTime(4), ":", 2)[1] = "00" Then $getHourly = True
			If $guardian = 1 And Mod($intRunCount, 10) = 0 Then $getGuardian = True

			Local $strData = "Runs: " & $intRunCount & " (Guardian:" & $intGuardian & ")|Profit: " & StringRegExpReplace(String($intGoldPrediction), "(\d)(?=(\d{3})+$)", "$1,") & "|Energy Used: " & ($intRunCount * $intGolem) & "|Gems Used: " & ($intGemUsed & "/" & $intGem) & "|Time Elapse: " & StringFormat("%.2f", $intTimeElapse / 60) & " Min." & "|Avg. Time: " & StringFormat("%.2f", $intTimeElapse / $intRunCount / 60) & " Min."

			GUICtrlSetData($listScript, "")
			GUICtrlSetData($listScript, $strData)

			Switch getLocation()
				Case "battle"
					clickPoint($battle_coorAuto)
				Case "battle-end"
					_CaptureRegion()
					If $quest = 1 And checkPixel($battle_pixelQuest) = True Then
						If setLog("Detected quest complete, navigating to village.", 1) Then ExitLoop (2)
						If navigate("village", "quests") = 1 Then
							If setLog("Collecting quests.", 1) Then ExitLoop (3)
							For $questTab In $village_coorArrayQuestsTab ;quest tabs
								clickPoint(StringSplit($questTab, ",", 2))
								While IsArray(findImage("misc-quests-get-reward", 100, 3)) = True
									If _Sleep(10) Then ExitLoop (5)
									clickPoint(findImage("misc-quests-get-reward", 100))
								WEnd
							Next
						EndIf
						navigate("map") ;go back to map to repeat golem process
					EndIf

					If $hourly = 1 And $getHourly = True Then
						If getHourly() = 1 Then $getHourly = False
					EndIf
					If $getGuardian = True Then ExitLoop

					If getLocation() = "battle-end" Then
						Local $quickRestart = findImage("battle-quick-restart", 30)
						clickWhile($quickRestart, "battle-end")
						$intRunCount += 1
					EndIf

					If getLocation() = "battle-end" Then navigate("map")
				Case "refill"
					If $intGemUsed + 30 <= $intGem Then
						While getLocation() = "refill"
							clickPoint($game_coorRefill, 1, 1000)
						WEnd

						If checkLocations("buy-gem") Then
							setLog("Out of gems!", 2)
							ExitLoop (2)
						EndIf

						clickUntil($game_coorRefillConfirm, "refill")

						clickPoint(findImage("misc-close", 30))

						setLog("Refill gems: " & $intGemUsed + 30 & "/" & $intGem, 0)
						$intGemUsed += 30
					Else
						setLog("Gem used exceed max gems!", 0)
						ExitLoop (2)
					EndIf
				Case "map", "village", "astroleague", "map-stage", "map-battle", "toc", "association", "clan", "starstone-dungeons", "golem-dungeons", "elemental-dungeons", "gold-dungeons"
					Local $result = navigate("map", "golem-dungeons")
					If $result = 1 Then
						Local $tempCurrLocation = getLocation()
						While Not($tempCurrLocation = "map-battle")
							If $tempCurrLocation = "autobattle-prompt" Then
								clickPoint($map_coorCancelAutoBattle, 1, 500)
							EndIf

							clickPoint(Eval("map_coorB" & $strGolem), 1, 500)
							$tempCurrLocation = getLocation()
						WEnd

						clickUntil($map_coorBattle, "battle")

						$intRunCount += 1
					ElseIf $result = 0 Then
						setLog("Unable to navigate to dungeon, trying again.", 1)
					EndIf
				Case "battle-end-exp"
					clickUntil($game_coorTap, "battle-sell")
					If _Sleep(10) Then ExitLoop (2)

					If $sellGems = 1 Then
						Local $gemInfo = sellGem("B" & $strGolem, $intSellGradeMin, True, 6, $intKeepGradeMinSub, $intMinSub)
						If IsArray($gemInfo) And StringInStr($gemInfo[6], "!") Then
							$intGoldPrediction += $intGoldEnergy
						EndIf
					EndIf

					clickPoint($game_coorTap)
				Case "battle-gem-full"
					setLog("Gem inventory is full!", 2)
					ExitLoop (2)
				Case "defeat"
					clickPoint(findImage("battle-give-up", 30))
					clickUntil($game_coorTap, "battle-end", 20, 1000)
				Case "lost-connection"
					clickPoint($game_coorConnectionRetry)
				Case "unknown"
					clickPoint($game_coorTap)
					clickPoint(findImage("misc-close", 30)) ;to close any windows open
				Case "pause"
					clickPoint($battle_coorContinue, 1, 2000)
			EndSwitch
		WEnd

		Dim $foundDungeon = 0
		If $guardian = 1 And navigate("map", "guardian-dungeons") = 1 Then
			If setLog("Checking for guardian dungeons...", 1) Then ExitLoop (2)
			Local $currLocation = getLocation()

			While $currLocation = "guardian-dungeons"
				Local $energyPoint = findImage("misc-dungeon-energy", 50)
				If isArray($energyPoint) And (clickUntil($energyPoint, "map-battle") = 1) Then
					clickWhile($map_coorBattle, "map-battle")

					If _Sleep(500) Then ExitLoop (2)

					If checkLocations("map-gem-full", "battle-gem-full") = 1 Then
						setLog("Gem box is full!", 0)
						ExitLoop (2)
					EndIf

					If checkLocations("refill") = 1 Then
						If $intGemUsed + 30 <= $intGem Then
							clickUntil($game_coorRefill, "refill-confirm")
							clickUntil($game_coorRefillConfirm, "refill")

							If checkLocations("buy-gem") Then
								setLog("Out of gems!", 1)
								ExitLoop
							EndIf

							clickPoint(findImage("misc-close", 30))

							setLog("Refill gems: " & $intGemUsed + 30 & "/" & $intGem)
							$intGemUsed += 30
						Else
							setLog("Gem used exceed max gems!")
							ExitLoop
						EndIf
						clickWhile($map_coorBattle, "map-battle")
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

					clickUntil($game_coorTap, "battle-end", 100, 100)

					Local $pointExit = findImage("battle-exit", 50)
					If isArray($pointExit) Then
						clickUntil($pointExit, "guardian-dungeons")
					Else
						If setLog("Could not find battle-exit.bmp! Going back to farming.") Then ExitLoop(2)
						ExitLoop
					EndIf

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
