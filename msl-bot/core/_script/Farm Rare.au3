#cs
	Function: farmRare
	Calls farmRareMain function with config settings

	Author: GkevinOD (2017)
#ce
Func farmRare()
	Local $buyEggs = Int(IniRead($botConfigDir, "Farm Rare", "buy-eggs", 0))
	Local $buySoulstones = Int(IniRead($botConfigDir, "Farm Rare", "buy-soulstones", 1))
	Local $maxGoldSpend = Int(IniRead($botConfigDir, "Farm Rare", "max-gold-spend", 100000))
	Local $intGem = Int(IniRead($botConfigDir, "Farm Rare", "max-spend-gem", 0))
	Local $map = "map-" & StringReplace(IniRead($botConfigDir, "Farm Rare", "map", "phantom forest"), " ", "-")
	Local $guardian = IniRead($botConfigDir, "Farm Rare", "guardian-dungeon", "0")
	Local $difficulty = IniRead($botConfigDir, "Farm Rare", "difficulty", "normal")
	Local $stage = IniRead($botConfigDir, "Farm Rare", "stage", "gold")
	Local $sellGems = StringSplit(IniRead($botConfigDir, "Farm Rare", "sell-gems-grade", "1,2,3"), ",", 2)
	Local $rawCapture = StringSplit(IniRead($botConfigDir, "Farm Rare", "capture", "legendary,super rare,rare,exotic,variant"), ",", 2)
	Local $quest = IniRead($botConfigDir, "Farm Rare", "collect-quest", "1")
	Local $hourly = IniRead($botConfigDir, "Farm Rare", "collect-hourly", "1")

	setLog("~~~Starting 'Farm Rare' script~~~", 2)
	farmRareMain($map, $difficulty, $stage, $rawCapture, $sellGems, $intGem, $guardian, $quest, $hourly, $buyEggs, $buySoulstones, $maxGoldSpend)
	setLog("~~~Finished 'Farm Rare' script~~~", 2)
EndFunc   ;==>farmRare

#cs
	Function: farmRareMain
	Farm Rare script aims to catch rares automatically

	Parameters:
	map: (String) Map to farm rare in. EX: phantom forest, lunar valley, aria lake...
	difficulty: (String) normal, hard, extreme
	stage: (String) gold, exp, any
	rawCapture: (String) "legendary,variant,rare..." This type of string format.
	sellGems: (String) "1,2,3,4" This type of string format.
	intGem: (Int) Maximum number of gems to allow bot to spend on refill
	guardian: (Int) 1=True; 0=False
	quest: (Int) 1=True; 0=False
	hourly: (Int) 1=True; 0=False

	Author: GkevinOD (2017)
#ce
Func farmRareMain($map, $difficulty, $stage, $rawCapture, $sellGems, $intGem, $guardian, $quest, $hourly, $buyEggs, $buySoulstones, $maxGoldSpend)
	;initializing configs
	Local $captures[0]
	Local $intGemUsed = 0

	For $capture In $rawCapture
		Local $grade = StringReplace($capture, " ", "-")
		If FileExists(@ScriptDir & "/core/_images/catch/catch-" & $grade & ".bmp") Then
			_ArrayAdd($captures, "catch-" & $grade)
		EndIf
	Next

	Local $intStartTime = TimerInit()
	Local $intTimeElapse = 0 ;

	Local $strEllipses = ["", ".", "..", "..."]
	Local $tempCounter = 0

	Local $dataRuns = 0
	Local $dataGuardians = 0
	Local $dataStrCaught = ""
	Local $dataStrMissed = ""
	Local $displayCaught = ""
	Local $displayMissed = ""

	Local $getHourly = False
	Local $getGuardian = False
	Local $checkHourly = True ;bool to prevent checking twice
	Local $checkGuardian = True ;bool to prevent checking twice

	Local $goldSpent = 0

	While True
		$intTimeElapse = Int(TimerDiff($intStartTime) / 1000)

		GUICtrlSetData($listScript, "")
		GUICtrlSetData($listScript, "Runs: " & $dataRuns & " (Guardian: " & $dataGuardians & ")|Caught: " & StringMid($displayCaught, 3) & "|Missed: " & StringMid($displayMissed, 3) & "|Gems Used: " & ($intGemUsed & "/" & $intGem) & "|Time Elapse: " & StringFormat("%.2f", $intTimeElapse / 60) & " Min.")

		Switch StringSplit(_NowTime(4), ":", 2)[1]
			Case "00", "01", "02", "03", "04", "05", "06", "07", "08", "09"
				If $checkHourly = True Then $getHourly = True
				If $checkGuardian = True Then $getGuardian = True
			Case "10" ;to prevent checking twice
				$checkHourly = True
			Case "35";to prevent checking twice
				$checkGuardian = True
			Case "30", "31", "32", "33", "34"
				If $checkGuardian = True Then $getGuardian = True
		EndSwitch

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
					If getHourly() = 1 Then
						$getHourly = False
						$checkHourly = False
					EndIf

					If $buySoulstones = 1 Then
						Local $itemsBought = buyItem("soulstone", $maxGoldSpend-$goldSpent)
						If isArray($itemsBought) Then
							For $item In $itemsBought
								$goldSpent += Int(StringSplit($item, ",", 2)[1])
							Next
						EndIf
					EndIf

					If $buyEggs = 1 Then
						Local $itemsBought = buyItem("egg", $maxGoldSpend-$goldSpent)
						If isArray($itemsBought) Then
							For $item In $itemsBought
								$goldSpent += Int(StringSplit($item, ",", 2)[1])
							Next
						EndIf
					EndIf
				EndIf

				If getLocation() = "battle-end" Then
					If Not Mod($dataRuns + 1, 20) = 0 Then
						If clickUntil($battle_coorRestart, "unknown,refill", 30, 1000) = True Then
							If getLocation() = "refill" Then ContinueLoop
							$dataRuns += 1
						EndIf
					Else
						If $getGuardian = True Then
							If $guardian = 1 Then $dataGuardians += farmGuardian($sellGems, $intGem, $intGemUsed)
							$checkGuardian = False
							$getGuardian = False
						EndIf

						If getLocation() = "battle-end" Then
							If clickUntil($battle_coorRestart, "unknown,refill", 30, 1000) = True Then
								If getLocation() = "refill" Then ContinueLoop
								$dataRuns += 1
							EndIf
						EndIf
					EndIf
				EndIf
			Case "refill"
				If $intGemUsed + 30 <= $intGem Then
					While getLocation() = "refill"
						clickPoint($game_coorRefill, 1, 1000)
					WEnd

					If getLocation() = "buy-gem" Then
						setLog("Out of gems!", 2)
						ExitLoop
					EndIf

					clickUntil($game_coorRefillConfirm, "refill")
					clickWhile("705, 99", "refill")

					setLog("Refill gems: " & $intGemUsed + 30 & "/" & $intGem, 0)
					$intGemUsed += 30
				Else
					setLog("Gem used exceed max gems!", 0)
					ExitLoop
				EndIf
			Case "battle"
				If checkPixel($battle_pixelUnavailable) = False Then ;if there is more astrochips
					If setLog("Checking for rare") Then Return -1
					If navigate("battle", "catch-mode") = True Then
						If isArray(findImages($captures, 100, 1000)) Then
							If setLogReplace("An astromon has been found!", 1) Then Return -1

							Local $catch = catch($captures)
							For $astromon In $catch
								If StringLeft($astromon, 1) = "!" Then ;if missed
									$dataStrMissed &= "," & StringMid($astromon, 2, 2)
								Else ;if caught
									$dataStrCaught &= "," & StringMid($astromon, 1, 2)
								EndIf
							Next

							;caught
							Local $arrayCounter[0]
							For $caught In StringSplit(StringMid($dataStrCaught, 2), ",", 2)
								Local $inTracker = False
								For $i = 0 To UBound($arrayCounter)-1
									If StringLeft($arrayCounter[$i], 2) = $caught Then
										Local $splitCounter = StringSplit($arrayCounter[$i], ":", 2)
										$arrayCounter[$i] = $splitCounter[0] &  ":" & Int($splitCounter[1])+1
										$inTracker = True

										ExitLoop
									EndIf
								Next

								If $inTracker = False And Not($caught = "") Then
									_ArrayAdd($arrayCounter, $caught & ":1")
								EndIf
							Next
							$displayCaught = ""
							For $element In $arrayCounter
								$displayCaught &= ", " & $element
							Next

							;miss
							Local $arrayCounter[0]
							For $missed In StringSplit(StringMid($dataStrMissed, 2), ",", 2)
								Local $inTracker = False
								For $i = 0 To UBound($arrayCounter)-1
									If StringLeft($arrayCounter[$i], 2) = $missed Then
										Local $splitCounter = StringSplit($arrayCounter[$i], ":", 2)
										$arrayCounter[$i] = $splitCounter[0] &  ":" & Int($splitCounter[1])+1
										$inTracker = True

										ExitLoop
									EndIf
								Next

								If $inTracker = False And Not($missed = "") Then
									_ArrayAdd($arrayCounter, $missed & ":1")
								EndIf
							Next
							$displayMissed = ""
							For $element In $arrayCounter
								$displayMissed &= ", " & $element
							Next

							If setLog("Finish catching... Attacking", 1) Then ExitLoop
							clickPoint($battle_coorAuto)

							ContinueCase
						Else
							If setLog("Cannot find the rare astromon, continuing battle.") Then Return -1
							clickUntil($battle_coorCatchCancel, "battle")
						EndIf
					EndIf
				EndIf

				clickPoint($battle_coorAuto)
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
EndFunc   ;==>farmRareMain
