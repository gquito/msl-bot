;function: farmRare
;-Automatically farms rares in story mode
;pre:
;   -config must be set for script
;   -required config keys: map, capture, guardian-dungeon
;author: GkevinOD
Func farmRare()
	;beginning script
	setLog("*Report any issues/bugs in GitHub", 2)
	setLog("*Loading config for Farm Rare.", 2)

	;getting configs
	Local $intStartTime = TimerInit()
	Local $intTimeElapse = 0;

	Local $map = "map-" & StringReplace(IniRead(@ScriptDir & "/" & $botConfig, "Farm Rare", "map", "phantom forest"), " ", "-")
	Local $guardian = IniRead(@ScriptDir & "/" & $botConfig, "Farm Rare", "guardian-dungeon", "0")
	Local $difficulty = IniRead(@ScriptDir & "/" & $botConfig, "Farm Rare", "difficulty", "normal")
	Local $captures[0] ;
	Local $sellGems = StringSplit(IniRead(@ScriptDir & "/" & $botConfig, "Farm Rare", "sell-gems-grade", "one star,two star, three star"), ",", 2)

	Local $intGem = Int(IniRead(@ScriptDir & "/" & $botConfig, "Farm Rare", "max-spend-gem", 0))
	Local $intGemUsed = 0

	Local $rawCapture = StringSplit(IniRead(@ScriptDir & "/" & $botConfig, "Farm Rare", "capture", "legendary,super rare,rare,exotic"), ",", 2)
	For $capture In $rawCapture
		Local $grade = StringReplace($capture, " ", "-")
		If FileExists(@ScriptDir & "/core/images/catch/catch-" & $grade & ".bmp") Then
			_ArrayAdd($captures, "catch-" & $grade)
		EndIf
	Next

	Local $quest = IniRead(@ScriptDir & "/" & $botConfig, "Farm Rare", "collect-quest", "1")
	Local $hourly = IniRead(@ScriptDir & "/" & $botConfig, "Farm Rare", "collect-hourly", "1")

	setLog("~~~Starting 'Farm Rare' script~~~", 2)

	;setting up data capture
	Local $strEllipses = ["", ".", "..", "..."]
	Local $tempCounter = 0

	Local $dataRuns = 0
	Local $dataGuardians = 0
	Local $dataEncounter = 0
	Local $dataStrCaught = ""
	Local $counterWordWrap = 0
	Local $getHourly = False

	While True
		While True
			$intTimeElapse = Int(TimerDiff($intStartTime) / 1000)

			GUICtrlSetData($listScript, "")
			GUICtrlSetData($listScript, "Runs: " & $dataRuns & " (Guardian: " & $dataGuardians & ")|Rares: " & $dataEncounter & "|Caught: " & StringMid($dataStrCaught, 2) & "|Gems Used: " & ($intGemUsed & "/" & $intGem) & "|Time Elapse: " & StringFormat("%.2f", $intTimeElapse / 60) & " Min.")

			If StringSplit(_NowTime(4), ":", 2)[1] = "00" Then $getHourly = True

			If _Sleep(100) Then ExitLoop (2) ;to stop farming
			Switch getLocation()
				Case "map", "map-stage", "astroleague", "village", "manage", "monsters", "quests", "map-battle", "clan", "esc", "inbox"
					If setLog("Going into battle...", 1) Then ExitLoop (2)
					If navigate("map") = 1 Then
						If enterStage($map, $difficulty, False, True) = 0 Then
							If setLog("Error: Could not enter map stage.", 1) Then ExitLoop (2)
						Else
							$dataRuns += 1
						EndIf
					EndIf
				Case "battle-auto"
					$tempCounter += 1
					If setLogReplace("Auto Mode: Waiting" & $strEllipses[Mod($tempCounter, 4)], 1) Then ExitLoop (2)
					If _Sleep(1000) Then ExitLoop(2)
				Case "battle-end-exp", "battle-sell"
					clickUntil($game_coorTap, "battle-end")
				Case "pause"
					clickPoint($battle_coorContinue, 1, 2000)
				Case "unknown"
					clickPoint($game_coorTap)
					clickPoint(findImage("misc-close", 30)) ;to close any windows open
				Case "battle-end"
					If $quest = 1 And checkPixel($battle_pixelQuest) = True Then
						If setLogReplace("Collecting quests...", 1) Then ExitLoop (2)
						If navigate("village", "quests") = 1 Then
							For $questTab In $village_coorArrayQuestsTab ;quest tabs
								clickPoint(StringSplit($questTab, ",", 2))
								While IsArray(findImage("misc-quests-get-reward", 100, 3)) = True
									If _Sleep(10) Then ExitLoop (5)
									clickPoint(findImage("misc-quests-get-reward", 100))
								WEnd
							Next
						EndIf
						If setLogReplace("Collecting quests... Done!", 1) Then ExitLoop (2)
					EndIf

					If $hourly = 1 And $getHourly = True Then
						If getHourly() = 1 Then
							$getHourly = False
						EndIf
					EndIf

					If getLocation() = "battle-end" Then
						If Not Mod($dataRuns, 20) = 0 Then
							clickUntil(findImage("battle-quick-restart", 30), "unknown")
							$dataRuns += 1
						Else
							If $guardian = 1 Then
								ExitLoop
							EndIf

							If getLocation() = "battle-end" Then
								clickUntil(findImage("battle-quick-restart", 30), "unknown")
								$dataRuns += 1
							EndIf
						EndIf
					EndIf
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

						setLog("Refill gems: " & $intGemUsed + 30 & "/" & $intGem)
						$intGemUsed += 30

						navigate("map") ;sometimes it gets stuck and adds 20 runs
						$dataRuns -= 1
					Else
						setLog("Gem used exceed max gems!")
						ExitLoop (2)
					EndIf
					clickUntil($map_coorBattle, "unknown")
				Case "battle"
					If IsArray(findImages($imagesRareAstromon, 100)) Then
						If checkPixel($battle_pixelUnavailable) = False Then ;if there is more astrochips
							$dataEncounter += 1
							If setLog("An astromon has been found!", 1) Then ExitLoop (2)

							If navigate("battle", "catch-mode") = 1 Then
								Local $tempStr = catch($captures, True, False, False, True)
								If $tempStr = -2 Then ;double check
									If setLog("Did not recognize astromon, trying again..", 1) Then ExitLoop (2)

									navigate("battle", "catch-mode")
									$tempStr = catch($captures, True, True, False, True)
								EndIf
								If $tempStr = "-2" Then $tempStr = ""

								If Not $tempStr = "" Then
									$counterWordWrap += 1
									$dataStrCaught &= ", " & $tempStr

									If Mod($counterWordWrap, 11) = 0 Then $dataStrCaught &= "|.........."
								EndIf
								If setLog("Finish catching... Attacking", 1) Then ExitLoop (2)
								clickPoint($battle_coorAuto)
							EndIf
						Else ;if no more astrochips
							If setLog("No astrochips left... Attacking", 1) Then ExitLoop (2)
							clickPoint($battle_coorAuto)
						EndIf
					Else
						clickPoint($battle_coorAuto)
					EndIf
				Case "map-gem-full", "battle-gem-full"
					If setLogReplace("Gem is full, going to sell gems...", 1) Then ExitLoop (2)
					If navigate("village", "manage") = 1 Then
						sellGems($sellGems)
						If setLogReplace("Gem is full, going to sell gems... Done!", 1) Then ExitLoop (2)
					EndIf
				Case "lost-connection"
					clickPoint($game_coorConnectionRetry)
			EndSwitch
		WEnd

		Dim $foundDungeon = 0
		If $guardian = 1 And navigate("map", "guardian-dungeons") = 1 Then
			If setLog("Checking for guardian dungeons...", 1) Then ExitLoop (2)
			Local $currLocation = getLocation()

			While $currLocation = "guardian-dungeons"
				Local $energyPoint = findImage("misc-dungeon-energy", 50)
				If isArray($energyPoint) And (clickUntil($energyPoint, "map-battle", 50) = 1) Then
					clickWhile($map_coorBattle, "map-battle")

					If _Sleep(500) Then ExitLoop (2)

					If checkLocations("map-gem-full", "battle-gem-full") = 1 Then
						If setLog("Gem is full, going to sell gems...", 1) Then ExitLoop (2)
						If navigate("village", "manage") = 1 Then
							ControlSend($hWindow, "", "", "{ESC}")
							clickWhile($village_coorManage, "monsters")

							navigate("village", "manage")
							sellGems($sellGems)
						EndIf

						clickUntil("misc-dungeon-energy", "map-battle")
						clickWhile($map_coorBattle, "map-battle", 5)
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
		$dataGuardians += $foundDungeon
	WEnd

	setLog("~~~Finished 'Farm Rare' script~~~", 2)
EndFunc   ;==>farmRare
