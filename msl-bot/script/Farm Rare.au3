#cs
	Function: farmRare
	Farm Rare script aims to catch rares automatically

	Author: GkevinOD (2017)
#ce
Func farmRare()
	;initializing configs
	Local $map = "map-" & StringReplace(IniRead(@ScriptDir & "/" & $botConfig, "Farm Rare", "map", "phantom forest"), " ", "-")
	Local $guardian = IniRead(@ScriptDir & "/" & $botConfig, "Farm Rare", "guardian-dungeon", "0")
	Local $difficulty = IniRead(@ScriptDir & "/" & $botConfig, "Farm Rare", "difficulty", "normal")
	Local $stage = IniRead(@ScriptDir & "/" & $botConfig, "Farm Rare", "stage", "gold")
	Local $captures[0]
	Local $rareIcons[0]
	Local $sellGems = StringSplit(IniRead(@ScriptDir & "/" & $botConfig, "Farm Rare", "sell-gems-grade", "one star,two star, three star"), ",", 2)

	Local $intGem = Int(IniRead(@ScriptDir & "/" & $botConfig, "Farm Rare", "max-spend-gem", 0))
	Local $intGemUsed = 0

	Local $rawCapture = StringSplit(IniRead(@ScriptDir & "/" & $botConfig, "Farm Rare", "capture", "legendary,super rare,rare,exotic,variant"), ",", 2)
	For $capture In $rawCapture
		Local $grade = StringReplace($capture, " ", "-")
		If FileExists(@ScriptDir & "/core/images/catch/catch-" & $grade & ".bmp") Then
			_ArrayAdd($captures, "catch-" & $grade)
		EndIf

		If FileExists(@ScriptDir & "/core/images/battle/battle-" & $grade & ".bmp") Then
			_ArrayAdd($rareIcons, "battle-" & $grade)
		EndIf
	Next

	Local $quest = IniRead(@ScriptDir & "/" & $botConfig, "Farm Rare", "collect-quest", "1")
	Local $hourly = IniRead(@ScriptDir & "/" & $botConfig, "Farm Rare", "collect-hourly", "1")

	setLog("~~~Starting 'Farm Rare' script~~~", 2)

	Local $intStartTime = TimerInit()
	Local $intTimeElapse = 0;

	Local $strEllipses = ["", ".", "..", "..."]
	Local $tempCounter = 0

	Local $dataRuns = 0
	Local $dataGuardians = 0
	Local $dataEncounter = 0
	Local $dataStrCaught = ""
	Local $counterWordWrap = 0
	Local $getHourly = False

	While True
		$intTimeElapse = Int(TimerDiff($intStartTime) / 1000)

		GUICtrlSetData($listScript, "")
		GUICtrlSetData($listScript, "Runs: " & $dataRuns & " (Guardian: " & $dataGuardians & ")|Rares: " & $dataEncounter & "|Caught: " & StringMid($dataStrCaught, 2) & "|Gems Used: " & ($intGemUsed & "/" & $intGem) & "|Time Elapse: " & StringFormat("%.2f", $intTimeElapse / 60) & " Min.")

		If StringSplit(_NowTime(4), ":", 2)[1] = "00" Then $getHourly = True

		If _Sleep(100) Then ExitLoop
		Switch getLocation()
			Case "map", "map-stage", "astroleague", "village", "manage", "monsters", "quests", "map-battle", "clan", "esc", "inbox"
				If setLog("Going into battle...", 1) Then ExitLoop
				If navigate("map") = True Then
					If enterStage($map, $difficulty, $stage, False) = False Then
						If setLog("Error: Could not enter map stage.", 1) Then ExitLoop
					Else
						$dataRuns += 1
					EndIf
				EndIf
			Case "battle-end-exp", "battle-sell"
				clickUntil($game_coorTap, "battle-end")
			Case "pause"
				clickPoint($battle_coorContinue, 1, 2000)
			Case "unknown"
				clickPoint($game_coorTap)
				clickPoint(findImage("misc-close", 30)) ;to close any windows open
			Case "battle-end"
				If $quest = 1 And checkPixel($battle_pixelQuest) = True Then getQuest()
				If $hourly = 1 And $getHourly = True Then
					If getHourly() = 1 Then $getHourly = False
				EndIf

				If getLocation() = "battle-end" Then
					If Not Mod($dataRuns+1, 20) = 0 Then
						clickUntil(findImage("battle-quick-restart", 30), "unknown")
						$dataRuns += 1
					Else
						If $guardian = 1 Then $dataGuardians += farmGuardian($sellGems, $intGem, $intGemUsed)

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

					If getLocation() = "buy-gem" Then setLog("Out of gems!", 2)

					clickUntil($game_coorRefillConfirm, "refill")
					clickPoint(findImage("misc-close", 30))

					setLog("Refill gems: " & $intGemUsed + 30 & "/" & $intGem)
					$intGemUsed += 30

					navigate("map") ;sometimes it gets stuck and adds 20 runs
					$dataRuns -= 1
				Else
					setLog("Gem used exceed max gems!")
					ExitLoop
				EndIf
				clickUntil($map_coorBattle, "unknown")
			Case "battle"
				If IsArray(findImages($rareIcons, 100, 5000)) Then
					If checkPixel($battle_pixelUnavailable) = False Then ;if there is more astrochips
						$dataEncounter += 1
						If setLogReplace("An astromon has been found!", 1) Then ExitLoop

						If navigate("battle", "catch-mode") = True Then
							Local $tempStr = catch($captures, True, False, False, True)
							If $tempStr = -2 Then ;double check
								If setLog("Did not recognize astromon, trying again..", 1) Then ExitLoop

								navigate("battle", "catch-mode")
								$tempStr = catch($captures, True, True, False, True)
							EndIf
							If $tempStr = "-2" Then $tempStr = ""

							If Not $tempStr = "" Then
								$counterWordWrap += 1
								$dataStrCaught &= ", " & $tempStr

								If Mod($counterWordWrap, 11) = 0 Then $dataStrCaught &= "|.........."
							EndIf
							If setLog("Finish catching... Attacking", 1) Then ExitLoop
							clickPoint($battle_coorAuto)
						EndIf
					Else ;if no more astrochips
						If setLog("No astrochips left... Attacking", 1) Then ExitLoop
						clickPoint($battle_coorAuto)
					EndIf
				Else
					clickPoint($battle_coorAuto)
				EndIf
			Case "catch-mode"
				clickUntil($battle_coorCatchCancel, "battle")
			Case "battle-auto"
				$tempCounter += 1
				If setLogReplace("Auto Mode: Waiting" & $strEllipses[Mod($tempCounter, 4)], 1) Then ExitLoop
				If _Sleep(1000) Then ExitLoop
			Case "map-gem-full", "battle-gem-full"
				If setLogReplace("Gem is full, going to sell gems...", 1) Then ExitLoop
				If navigate("village", "manage") = 1 Then
					sellGems($sellGems)
					If setLogReplace("Gem is full, going to sell gems... Done!", 1) Then ExitLoop
				EndIf
			Case "lost-connection"
				clickPoint($game_coorConnectionRetry)
		EndSwitch
	WEnd

	setLog("~~~Finished 'Farm Rare' script~~~", 2)
EndFunc   ;==>farmRare