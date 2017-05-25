#cs
	Function: farmGolem
	Calls farmGolemMain with config settings

	Author: GkevinOD (2017)
#ce
Func farmGolem()
	Local $strGolem = IniRead($botConfigDir, "Farm Golem", "dungeon", 7)

	Local $buyEggs = IniRead($botConfigDir, "Farm Golem", "buy-eggs", 0)
	Local $buySoulstones = IniRead($botConfigDir, "Farm Golem", "buy-soulstones", 1)
	Local $maxGoldSpend = IniRead($botConfigDir, "Farm Golem", "max-gold-spend", 100000)
	Local $guardian = IniRead($botConfigDir, "Farm Golem", "farm-guardian", 0)
	Local $intGem = IniRead($botConfigDir, "Farm Golem", "max-spend-gem", 0)
	Local $selectBoss = IniRead($botConfigDir, "Farm Golem", "select-boss", 1)
	Local $keepAllGrade = IniRead($botConfigDir, "Farm Golem", "keep-all-grade", 6)

	Local $quest = IniRead($botConfigDir, "Farm Golem", "collect-quest", "1")
	Local $hourly = IniRead($botConfigDir, "Farm Golem", "collect-hourly", "1")

	setLog("~~~Starting 'Farm Golem' script~~~", 2)
	farmGolemMain($strGolem, $selectBoss, $intGem, $guardian, $quest, $hourly, $buyEggs, $buySoulstones, $maxGoldSpend)
	setLog("~~~Finished 'Farm Golem' script~~~", 2)
EndFunc   ;==>farmGolem

#cs
	Function: farmGolemMain
	Farms golems while collecting hourly and quests, and selling and collecting gems.

	Parameters:
	strGolem: (Int) The golem stage.
	selectBoss: (Int) 1=True; 0=False
	sellGems: (Int) 1=True; 0=False
	sellGrades: (String) Sell gems with grades specified
	filterGrades: (String) Grades you want to go through the filter system
	sellTypes: (String) Sell gems with types specified
	sellFlat: (Int) 1=True; 0=False
	sellStats: (String) Sell gems with stats specified
	sellSubstats = (String) Sell gems with substats specified
	intGem: (Int) Maximum number of gems the bot can spend for refill.
	guardian: (Int) 1=True; 0=False
	quest: (Int) 1=True; 0=False
	hourly: (Int) 1=True; 0=False

	Author: GkevinOD (2017)
#ce
Func farmGolemMain($strGolem, $selectBoss, $intGem, $guardian, $quest, $hourly, $buyEggs, $buySoulstones, $maxGoldSpend)

	Local $avgGoldPerRound = 0
	Switch ($strGolem)
		Case 7
			$avgGoldPerRound = 1500
		Case 8
			$avgGoldPerRound = 1500
		Case 9
			$avgGoldPerRound = 1100
		Case 10
			$avgGoldPerRound = 1200
	EndSwitch

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

	Local $intGemUsed = 0

	Local $intStartTime = TimerInit()
	Local $intGoldPrediction = 0
	Local $intRunCount = 0
	Local $intTimeElapse = 0
	Local $intGuardian = 0
	Local $getGuardian = False

	Local $getHourly = False
	Local $checkHourly = True ;bool to prevent checking twice
	Local $checkGuardian = True ;bool to prevent checking guardian twice

	Local $numEggs = 0 ;keeps count of number of eggs found
	Local $numGemsKept = 0; keeps count of number of eggs kept

	Local $goldSpent = 0
	While True
		If _Sleep(50) Then ExitLoop
		$intTimeElapse = Int(TimerDiff($intStartTime) / 1000)

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


		Local $strData = "Runs: " & $intRunCount & " (Guardian:" & $intGuardian & ")|Profit: " & StringRegExpReplace(String($intGoldPrediction), "(\d)(?=(\d{3})+$)", "$1,") & "|Gems Used: " & ($intGemUsed & "/" & $intGem) & "|Time Elapse: " & StringFormat("%.2f", $intTimeElapse / 60) & " Min." & "|Avg. Time: " & StringFormat("%.2f", $intTimeElapse / $intRunCount / 60) & " Min.|Eggs: " & $numEggs & "|Gems Kept: " & $numGemsKept

		GUICtrlSetData($listScript, "")
		GUICtrlSetData($listScript, $strData)

		Local $currLocation = getLocation()

		antiStuck("map")
		Switch $currLocation
			Case "battle"
				clickPoint($battle_coorAuto)
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

				If $getGuardian = True Then
					If $guardian = 1 Then $intGuardian += farmGuardian(0, $intGem, $intGemUsed)
					$checkGuardian = False
					$getGuardian = False
				EndIf

				If getLocation() = "battle-end" Then
					If clickUntil($battle_coorRestart, "unknown,refill", 30, 1000) = True Then
						If getLocation() = "refill" Then ContinueLoop
						$intRunCount += 1
					EndIf
				EndIf

				If getLocation() = "battle-end" Then navigate("map")
			Case "refill"
				If $intGemUsed + 30 <= $intGem Then
					clickUntil($game_coorRefill, "refill-confirm")

					If getLocation() = "buy-gem" Or getLocation() = "unknown" Then
						setLog("Out of gems!", 2)
						ExitLoop
					EndIf

					clickWhile($game_coorRefillConfirm, "refill-confirm")
					clickWhile("705, 99", "refill")

					If setLog("Refill gems: " & $intGemUsed + 30 & "/" & $intGem, 0) Then ExitLoop
					$intGemUsed += 30
				Else
					setLog("Gem used exceed max gems!", 0)
					ExitLoop
				EndIf
			Case "map", "village", "astroleague", "map-stage", "map-battle", "toc", "association", "clan", "starstone-dungeons", "golem-dungeons", "elemental-dungeons", "gold-dungeons", "quests"
				If navigate("map", "golem-dungeons") = True Then
					Local $tempCurrLocation = getLocation()
					While Not ($tempCurrLocation = "map-battle")
						If $tempCurrLocation = "autobattle-prompt" Then
							clickPoint($map_coorCancelAutoBattle, 1, 500)
						EndIf

						clickPoint(Eval("map_coorB" & $strGolem), 1, 500)
						$tempCurrLocation = getLocation()
					WEnd

					clickUntil($map_coorBattle, "battle")

					$intRunCount += 1
				EndIf
			Case "battle-end-exp", "battle-sell", "battle-sell-item"
				clickUntil("193,255", "battle-sell-item", 500, 100)
				If _Sleep(10) Then ExitLoop

				Local $gemInfo = sellGemGolemFilter($strGolem)
				If IsArray($gemInfo) Then
					If Not($gemInfo[0] = "EGG") And StringInStr($gemInfo[5], "!") Then
						$intGoldPrediction += getGemPrice($gemInfo) + $avgGoldPerRound
					Else
						If $gemInfo[0] = "EGG" Then
							$numEggs += 1
						Else
							$numGemsKept += 1
						EndIf
					EndIf
				EndIf
			Case "battle-gem-full"
				setLog("Gem inventory is full!", 2)
				ExitLoop
			Case "defeat"
				clickPoint(findImage("battle-give-up", 30))
				clickUntil($game_coorTap, "battle-end", 20, 1000)
			Case "lost-connection"
				clickPoint($game_coorConnectionRetry)
			Case "battle-boss"
				If $selectBoss = 1 Then
					waitLocation("battle-auto", 5000)
					clickPoint("406, 209")
				EndIf
			Case "pause"
				clickPoint($battle_coorContinue)
		EndSwitch
	WEnd
EndFunc   ;==>farmGolemMain
