#cs
	Function: farmCollosus
	Calls farmCollosusMain with config settings

	Author: GkevinOD (2017)
#ce
Func farmCollosus()
	Local $strCollosus = IniRead($botConfigDir, "Farm Collosus", "dungeon", 7)

	Local $buyEggs = IniRead($botConfigDir, "Farm Collosus", "buy-eggs", 0)
	Local $buySoulstones = IniRead($botConfigDir, "Farm Collosus", "buy-soulstones", 1)
	Local $maxGoldSpend = IniRead($botConfigDir, "Farm Collosus", "max-gold-spend", 100000)
	Local $guardian = IniRead($botConfigDir, "Farm Collosus", "farm-guardian", 0)
	Local $intGem = IniRead($botConfigDir, "Farm Collosus", "max-spend-gem", 0)
	Local $selectBoss = IniRead($botConfigDir, "Farm Collosus", "select-boss", 1)
	Local $keepAllGrade = IniRead($botConfigDir, "Farm Collosus", "keep-all-grade", 6)

	Local $quest = IniRead($botConfigDir, "Farm Collosus", "collect-quest", "1")
	Local $hourly = IniRead($botConfigDir, "Farm Collosus", "collect-hourly", "1")

	setLog("~~~Starting 'Farm Collosus' script~~~", 2)
	farmCollosusMain($strCollosus, $selectBoss, $intGem, $guardian, $quest, $hourly, $buyEggs, $buySoulstones, $maxGoldSpend)
	setLog("~~~Finished 'Farm Collosus' script~~~", 2)
EndFunc   ;==>farmCollosus

#cs
	Function: farmCollosusMain
	Farms collosuss while collecting hourly and quests, and selling and collecting gems.

	Parameters:
	strCollosus: (Int) The collosus stage.
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
Func farmCollosusMain($strCollosus, $selectBoss, $intGem, $guardian, $quest, $hourly, $buyEggs, $buySoulstones, $maxGoldSpend)
	Local $avgGoldPerRound = 0
	Switch ($strCollosus)
		Case 7
			$avgGoldPerRound = 1500
		Case 8
			$avgGoldPerRound = 1500
		Case 9
			$avgGoldPerRound = 1100
		Case 10
			$avgGoldPerRound = 1200
	EndSwitch

	Local $intCollosus = 7
	Switch ($strCollosus)
		Case 1 To 3
			$intCollosus = 5
		Case 4 To 6
			$intCollosus = 6
		Case 7 To 9
			$intCollosus = 7
		Case 10
			$intCollosus = 8
	EndSwitch

	Local $gemsUsed = 0

	Local $intStartTime = TimerInit()
	Local $intGoldPrediction = 0
	Local $intRunCount = 0
	Local $intTimeElapse = 0
	Local $numGuardian = 0
	Local $doGuardian = False

	Local $doHourly = False

	Local $numEggs = 0 ;keeps count of number of eggs found
	Local $numGemsKept = 0; keeps count of number of eggs kept
	
	Local $roundNumber = [0,0]
	Local $autoMode = $AUTO_BATTLE

	Local $goldSpent = 0
	While True
		If _Sleep(50) Then ExitLoop
		$intTimeElapse = Int(TimerDiff($intStartTime) / 1000)

		checkTimeTasks($doHourly, $doGuardian, $hourly, $guardian)

		Local $strData = "Runs: " & $intRunCount & " (Guardian:" & $numGuardian & ")|Profit: " & StringRegExpReplace(String($intGoldPrediction), "(\d)(?=(\d{3})+$)", "$1,") & "|Gems Used: " & ($gemsUsed & "/" & $maxGemRefill) & "|Avg. Time: " & getTimeString(Int($intTimeElapse / $intRunCount)) & "|Eggs: " & $numEggs & "|Gems Kept: " & $numGemsKept
		setList($strData)

		Local $currLocation = getLocation()

		antiStuck("map")
		Switch $currLocation
			Case "battle-auto"
				If Not doAutoBattle($roundNumber, $autoMode, $selectBoss) Then
					If setLog("Unknown error in Auto-Battle!", 1, $LOG_ERROR) Then ExitLoop
					ExitLoop
				EndIf
				
			Case "battle"
				If Not doBattle($autoMode) Then
					If setLog("Unknown error in Battle!", 1, $LOG_ERROR) Then ExitLoop
					ExitLoop
				EndIf
				
			Case "refill"
				; If the number of used gems will not exceed the limit, purchase additional energy
				If Not refilGems($gemsUsed, $maxGemRefill) Then 
					If setLog("Unknown error in Gem-Refill!", 1, $LOG_ERROR) Then ExitLoop
					ExitLoop
				EndIf
				
			Case "battle-end"
				Local $itemsToBuy = [1, $buySoulstones, $buyEggs]
				If Not doBattleEnd($quest, $doHourly, $itemsToBuy, $goldSpent, $maxGoldSpend, $doGuardian, $numGuardian, $intRunCount) Then
					If setLog("Unknown error in Battle-End!", 1, $LOG_ERROR) Then ExitLoop
					ExitLoop
				EndIf
				
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
			
			Case "map", "village", "astroleague", "map-stage", "map-battle", "toc", "association", "clan", "starstone-dungeons", "collosus-dungeons", "elemental-dungeons", "gold-dungeons", "quests"
				If navigate("map", "collosus-dungeons") = True Then
					Local $tempCurrLocation = getLocation()
					While Not ($tempCurrLocation = "map-battle")
						If $tempCurrLocation = "autobattle-prompt" Then
							clickPoint($map_coorCancelAutoBattle, 1, 500)
						EndIf

						clickPoint(Eval("map_coorB" & $strCollosus), 1, 500)
						$tempCurrLocation = getLocation()
					WEnd

					clickUntil($map_coorBattle, "battle")

					$intRunCount += 1
				EndIf
			
			Case "battle-end-exp", "battle-sell", "battle-sell-item"
				clickUntil("193,255", "battle-sell-item", 500, 100)
				If _Sleep(10) Then ExitLoop

				Local $gemInfo = sellGemGolemFilter($strCollosus)
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
				
			Case "map-gem-full", "battle-gem-full"
				If setLogReplace("Gem is full, going to sell gems...", 1) Then ExitLoop
				If navigate("village", "manage") = 1 Then
					Local $sellGems = "1,2,3,4"
					sellGems($sellGems)
					If setLogReplace("Gem is full, going to sell gems... Done!", 1) Then ExitLoop
				EndIf
				
			Case "defeat"
				clickPoint(findImage("battle-give-up", 30))
				clickUntil($game_coorTap, "battle-end", 20, 1000)
				
			Case "lost-connection"
				clickPoint($game_coorConnectionRetry)
				
			Case "pause"
				clickPoint($battle_coorContinue)
		EndSwitch
	WEnd
EndFunc   ;==>farmCollosusMain
