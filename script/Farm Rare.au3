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
	Dim $intStartTime = TimerInit()
	Dim $intTimeElapse = 0;

	Dim $intCheckStartTime; check if stuck
	Dim $intCheckTime; check if stuck

	Dim $map = "map-" & StringReplace(IniRead(@ScriptDir & "/config.ini", "Farm Rare", "map", "phantom forest"), " ", "-")
	Dim $guardian = IniRead(@ScriptDir & "/config.ini", "Farm Rare", "guardian-dungeon", "0")
	Dim $difficulty = IniRead(@ScriptDir & "/config.ini", "Farm Rare", "difficulty", "normal")
	Dim $captures[0] ;
	Dim $sellGems = StringSplit(StringReplace(IniRead(@ScriptDir & "/config.ini", "Farm Rare", "sell-gems", "one star,two star, three star"), " ", "-"), ",", 2)
	For $i = 0 To UBound($sellGems)-1
		$sellGems[$i] = "manage-" & $sellGems[$i]
	Next

	Dim $intGem = Int(IniRead(@ScriptDir & "/config.ini", "Farm Rare", "max-spend-gem", 0))
	Dim $intGemUsed = 0

	Dim $rawCapture = StringSplit(IniRead(@ScriptDir & "/config.ini", "Farm Rare", "capture", "legendary,super rare,rare,exotic"), ",", 2)
	For $capture In $rawCapture
		Local $grade = StringReplace($capture, " ", "-")
		If FileExists(@ScriptDir & "/core/images/catch/catch-" & $grade & ".bmp") Then
			_ArrayAdd($captures, "catch-" & $grade)

			Local $tempInt = 2
			While FileExists(@ScriptDir & "/core/images/catch/catch-" & $grade & $tempInt & ".bmp")
				_ArrayAdd($captures, "catch-" & $grade & $tempInt)
				$tempInt += 1
			WEnd
		EndIf
	Next

	setLog("~~~Starting 'Farm Rare' script~~~", 2)

	;setting up data capture
	GUICtrlSetData($cmbLoad, "Select a script..")
	$strScript = "" ;script section
	$strConfig = "" ;all keys

	Local $dataRuns = 0
	Local $dataGuardians = 0
	Local $dataEncounter = 0
	Local $dataStrCaught = ""
	Local $getHourly = False

	While True
		While True
			$intTimeElapse = Int(TimerDiff($intStartTime) / 1000)

			GUICtrlSetData($listScript, "")
			GUICtrlSetData($listScript, "~Farm Rare Data~|Total Runs: " & $dataRuns & "|Total Guardian Dungeons: " & $dataGuardians & "|# of Rare Encounters: " & $dataEncounter & "|Astromon Caught: " & StringMid($dataStrCaught, 2) & "|Gems Used: " & ($intGemUsed & "/" & $intGem) & "|Total Time Elapse: " & StringFormat("%.2f", $intTimeElapse / 60) & " Min.")

			If StringSplit(_NowTime(4), ":", 2)[1] = "00" Then $getHourly = True

			If _Sleep(100) Then ExitLoop (2) ;to stop farming
			If checkLocations("map", "map-stage", "astroleague", "village", "manage", "monsters", "quests", "map-battle", "clan", "esc", "inbox") = 1 Then
				If setLog("Going into battle...", 1) Then ExitLoop (2)
				If navigate("map") = 1 Then
					If enterStage($map, $difficulty, True, True) = 0 Then
						If setLog("Error: Could not enter map stage.", 1) Then ExitLoop (2)
					Else
						$dataRuns += 1
						If setLog("Waiting for astromon.", 1) Then ExitLoop (2)
					EndIf
				EndIf
			EndIf

			If checkLocations("battle-end-exp", "battle-sell") = 1 Then
				clickPointUntil($game_coorTap, "battle-end")
			EndIf

			If checkLocations("unknown") = 1 Then
				clickPoint($game_coorTap)

				Local $closePoint = findImageFiles("misc-close", 30)
				If isArray($closePoint) Then
					clickPoint($closePoint) ;to close any windows open
				EndIf
			EndIf

			If checkLocations("battle-end") = 1 Then
				$intCheckStartTime = 0
				clickPoint($game_coorTap, 5)
				If waitLocation("unknown", 10) = 0 Then
					While True
						If checkLocations("refill") Then
							$dataRuns -= 1
							ExitLoop
						EndIf
						If setLog("Autobattle finished.", 1) Then ExitLoop (3)

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
						EndIf

						If $getHourly = True Then
							If getHourly() = 1 Then
								$getHourly = False
							EndIf
						EndIf

						navigate("map")
						ExitLoop (2)
					WEnd
				EndIf
				$dataRuns += 1
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
				clickPointUntil($map_coorBattle, "battle")
			EndIf

			If checkLocations("battle") = 1 Then
				$intCheckTime = Int(TimerDiff($intCheckStartTime) / 1000)
				If (Not $intCheckStartTime = 0) And ($intCheckTime > 180) Then
					If setLog("Battle has not finished in 3 minutes! Attacking..", 1) Then ExitLoop (2)
					clickPoint($battle_coorAuto)
				EndIf

				If IsArray(findImagesWait($imagesRareAstromon, 5, 100)) Then
					$dataEncounter += 1
					If setLog("An astromon has been found!", 1) Then ExitLoop (2)
					waitLocation("battle")

					_CaptureRegion()
					If checkPixel($battle_pixelUnavailable) = False Then ;if there is more astrochips
						If navigate("battle", "catch-mode") = 1 Then
							Local $tempStr = catch($captures, True, False, False, True)
							If $tempStr = -2 Then ;double check
								If setLog("Did not recognize astromon, trying again..", 1) Then ExitLoop (2)

								navigate("battle", "catch-mode")
								$tempStr = catch($captures, True, True, False, True)
							EndIf
							If $tempStr = "-2" Then $tempStr = ""

							If Not $tempStr = "" Then $dataStrCaught &= ", " & $tempStr
							If setLog("Finish catching, attacking..", 1) Then ExitLoop (2)
							clickPoint($battle_coorAuto)
						EndIf
					Else ;if no more astrochips
						If setLog("Unable to catch astromons, out of astrochips.", 1) Then ExitLoop (2)
						clickPoint($battle_coorAuto)
					EndIf
					$intCheckStartTime = TimerInit()
				EndIf
			EndIf

			If checkLocations("map-gem-full", "battle-gem-full") = 1 Then
				If setLog("Gem is full, going to sell gems...", 1) Then ExitLoop (2)
				If navigate("village", "manage") = 1 Then
					ControlSend($hWindow, "", "", "{ESC}")
					clickPointWait($village_coorManage, "monsters")

					navigate("village", "manage")
					Local $soldGems = sellGems($sellGems)
					If setLog("Sold " & $soldGems & " gems!", 1) Then ExitLoop (2)
				EndIf
			EndIf

			If checkLocations("lost-connection") = 1 Then
				clickPoint($game_coorConnectionRetry)
			EndIf
		WEnd

		Dim $foundDungeon = 0
		If $guardian = 1 And navigate("map", "guardian-dungeons") = 1 Then
			If setLog("Checking for guardian dungeons...", 1) Then ExitLoop (2)
			While checkLocations("guardian-dungeons") = 1
				If clickImageUntil("misc-dungeon-energy", "map-battle", 50) = 1 Then
					clickPointWait($map_coorBattle, "map-battle", 5)

					If _Sleep(3000) Then ExitLoop (2)

					If checkLocations("map-gem-full", "battle-gem-full") = 1 Then
						If setLog("Gem is full, going to sell gems...", 1) Then ExitLoop (2)
						If navigate("village", "manage") = 1 Then
							ControlSend($hWindow, "", "", "{ESC}")
							clickPointWait($village_coorManage, "monsters")

							navigate("village", "manage")
							sellGems($sellGems)
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
		$dataGuardians += $foundDungeon
	WEnd

	setLog("~~~Finished 'Farm Rare' script~~~", 2)
EndFunc   ;==>farmRare
