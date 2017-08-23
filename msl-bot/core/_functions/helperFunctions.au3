
Func refilGems(ByRef $gemsUsed, $maxRefill)
	; If the number of used gems will not exceed the limit, purchase additional energy
	If Not($gemsUsed = null) And ($gemsUsed + 30 <= $maxRefill) Then
		While getLocation() = "refill"
			clickPoint($game_coorRefill, 1, 1000)
		WEnd

		If getLocation() = "buy-gem" Or getLocation() = "unknown" Then
			If setLog("Out of gems!", 2) Then Return -1
			Return False
		EndIf

		clickUntil($game_coorRefillConfirm, "refill")
		clickWhile("705, 99", "refill")

		If setLog("Refill gems: " & $gemsUsed + 30 & "/" & $maxRefill, 0) Then Return -1
		$gemsUsed += 30
	Else
		If setLog("Gem used exceed max gems!", 0) Then Return -1
		Return False
	EndIf
	
	Return True
EndFunc

; ItemsToBuy is an array of 1 or 0 in the form of [Sale, Soulstone, Egg]
Func goShopping($itemsToBuy, ByRef $goldSpent, $maxGoldSpend = 0)
	
	Local $ITEMS = [[0, "sale"],[1, "soulstone"],[2, "egg"]]
		
	For $idx = 0 To UBound($itemsToBuy)-1
		If $itemsToBuy[$ITEMS[$idx][0]] = 1 Then
			Local $itemsBought = buyItem($ITEMS[$idx][1], $maxGoldSpend-$goldSpent)
			If isArray($itemsBought) Then
				For $item In $itemsBought
					$goldSpent += Int(StringSplit($item, ",", 2)[1])
				Next
			EndIf
		EndIf
	Next
EndFunc

Func checkTimeTasks(ByRef $doHourly, ByRef $doGuardian, $initHourly = 1, $initGuardian = 1)

	Static Local $hourly = $initHourly
	Static Local $checkHourly = 1
	Static Local $guardian = $initGuardian
	Static Local $checkGuardian = 1
	
	Switch StringSplit(_NowTime(4), ":", 2)[1]
		Case "00", "01", "02", "03", "04", "05", "06", "07", "08", "09"
			If $hourly = 1 And $checkHourly = True Then
				$checkHourly = False
				$doHourly = True
			EndIf
			If $guardian = 1 And $checkGuardian = True Then
				$checkGuardian = False
				$doGuardian = True
			EndIf
		Case "10" ;to prevent checking twice
			$checkHourly = True
			$checkGuardian = True
		Case "30", "31", "32", "33", "34"
			If $guardian = 1 And $checkGuardian = True Then
				$checkGuardian = False
				$doGuardian = True
			EndIf
		Case "35";to prevent checking twice
			$checkGuardian = True
	EndSwitch
EndFunc

Local $AUTO_OFF = 0
Local $AUTO_ROUND = 1
Local $AUTO_BATTLE = 2
Local $AUTO_ALWAYS = 3

;auto: 0 = off, 1 = next round, 2 = remainder of battle
Func doBattle(ByRef $auto, $catchAstromon = False, $exitWhenEmpty = False)	
	If $catchAstromon Then
		; Get the current number of astrochips
		Local $ascrochipCount = findChips()
		If setLog("Remaining Astrochips: " & $ascrochipCount, 1, $LOG_DEBUG) Then Return -1
		
		; Error: Astrochip counter could not be found
		If $ascrochipCount == -1 Then
			If setLog("Unable to find astrochip counter", 1, $LOG_ERROR) Then Return -1
			Return False
		
		; If player is out of astrochips, end the battle according to the config
		ElseIf $ascrochipCount == 0 Then
			If $exitWhenEmpty == True Then
				If setLog("Out of astrochips, restarting..", 1) Then Return -1
				clickUntil($battle_coorPause, "pause")
				clickUntil($battle_coorGiveUp, "unknown")
				clickWhile($battle_coorGiveUpConfirm, "unknown")
			Else
				If setLog("Out of astrochips, attacking..", 1) Then Return -1		
				$auto = _Max($auto, $AUTO_BATTLE)
			EndIf
			
		; If there are still astrochips remaining, catch astromon
		Else		
			; A rare mon prevents entering catch-mode until its animation is over, continue trying until it is
			Local $timerStart = TimerInit()
			While Not(getLocation() == "catch-mode")
				_Sleep(10)
				If navigate("battle", "catch-mode") = True Then 
					$auto = $AUTO_OFF
					Return True
				EndIf
				If TimerDiff($timerStart) > 7000 Then ExitLoop
			WEnd
			
			If setLog("Unable to navigate to catch-mode", 1, $LOG_ERROR) Then Return -1
			Return False
		EndIf
	Else
		$auto = _Max($auto, $AUTO_BATTLE)
	EndIf
		
	; If there is nothing else to do this round, begin auto-attacking
	If $auto == $AUTO_ROUND Then
		If setLog("Attacking until the next round", 1, $LOG_DEBUG) Then Return -1
		clickPoint($battle_coorAuto)
	EndIf
	
	; If user is not catching astromon, begin auto-attacking
	If $auto >= $AUTO_BATTLE Then
		If setLog("Attacking until end of battle", 1, $LOG_DEBUG) Then Return -1
		clickPoint($battle_coorAuto)
	EndIf
		
	Return True
EndFunc

Func doAutoBattle(ByRef $roundNumber, ByRef $auto, $selectBoss = 0)
	; Check if new round has started
	Local $curRoundNumber = getRound();				
	If $roundNumber[0] <> $curRoundNumber[0] Then
		
		If $curRoundNumber[0] == 0 Then 
			If setLog("Leaving Battle" , 1, $LOG_DEBUG) Then Return -1
			$roundNumber = $curRoundNumber
			Return True
		Else
			If setLog("Moving to round " & $curRoundNumber[0] & " / " & $curRoundNumber[1] & " from round " & $roundNumber[0] & " / " & $roundNumber[1] , 1, $LOG_DEBUG) Then Return -1
			$roundNumber = $curRoundNumber
		EndIf
		
		; If there is a boss to select, click it for faster runs
		If $roundNumber[0] == $roundNumber[1] AND $selectBoss = 1 Then
			_Sleep(1000)
			waitLocation("battle-auto", 5000)
			clickPoint("406, 209")
		EndIf
				
		; If auto-battle should be turned off, do so
		If $auto <= $AUTO_ROUND Then
			$auto = $AUTO_OFF
		EndIf
		
		If $roundNumber[0] == 1 And $auto <= $AUTO_BATTLE Then
			$auto = $AUTO_OFF
		EndIf
	EndIf	
	
	If $auto == $AUTO_OFF Then
		clickPoint($battle_coorAuto)
	EndIf
		
	Return True
EndFunc

Func doBattleEnd($doQuest, ByRef $doHourly, $shoppingList, $goldSpent, $maxGold, ByRef $doGuardian, ByRef $guardianCount, ByRef $runCount)
	Local $success = True
	
	Local $questSuccess = doQuest($doQuest)
	Local $hourlySuccess = doHourly($doHourly, $shoppingList, $goldSpent, $maxGold)
	Local $guardianSuccess = doGuardian($doGuardian, $guardianCount)
	Local $restartSuccess = restartBattle($runCount)
	
	Return $questSuccess & $hourlySuccess & $guardianSuccess & $restartSuccess
EndFunc


Func doQuest($doQuest)
	; Check if this run completed a quest and pick it up to avoid missing it
	If $doQuest = 1 And checkPixel($battle_pixelQuest) = True Then getQuest()
	
	Return True
EndFunc

Func doHourly(ByRef $doHourly, $shoppingList, $goldSpent, $maxGold)
	; Collect hourly hidden items and check shop
	If $doHourly = True Then
		$doHourly = getHourly()
		If $doHourly = -1 Then setLog("An unknown error occured in Get-Hourly!", 0)
		$doHourly = False

		goShopping($shoppingList, $goldSpent, $maxGold)
		playBingoMain()
		farmPvpMain()
	EndIf
	
	Return True
EndFunc

Func doGuardian(ByRef $doGuardian, ByRef $guardianCount, $intGem = 30, $intGemUsed = 0)
	; Collect any guardians that may have been found
	If $doGuardian = True Then		
		Local $caught = farmGuardian(0, $intGem, $intGemUsed)
		If $caught = -1 Then setLog("An unknown error occured in Farm-Guardian!", 0)
		
		$doGuardian = False
		$guardianCount += $caught
	EndIf
	
	Return True
EndFunc

Func restartBattle(ByRef $runCount)
	; Restart Battle
	If getLocation() = "battle-end" Then
		If clickWhile($battle_coorRestart, "battle-end", 30, 1000) = True Then
			Local $location = getLocation()
			If $location == "refill" Then Return True
			$runCount += 1
		EndIf
	EndIf

	; If still at battle-end, restart at map to reset run
	If getLocation() = "battle-end" Then navigate("map")
	
	Return True
EndFunc

Func _doBattleEndTest()
	Local $itemsToBuy = [1, 0, 1]
	If Not doBattleEnd(1, True, $itemsToBuy, 0, 1000000, False, 0, 0) Then
		If setLog("Unknown error in Battle-End!", 1, $LOG_ERROR) Then Return -1
	EndIf
EndFunc