#cs
	Function: farmPvp
	Farms Pvp until the stop condition is met.

	Author: Shimizoki (2017)
#ce
Func farmToc()
	setLog("~~~Starting 'Farm ToC' script~~~", 2)
	farmTocMain()
	setLog("~~~Finished 'Farm ToC' script~~~", 2)
EndFunc   ;==>farmGem

Func farmTocMain()

	
	Local $roundNumber = [0,0]
	Local $autoMode = $AUTO_BATTLE

	While True
		antiStuck("map")

		If _Sleep(100) Then ExitLoop
		Switch getLocation()
			Case "battle-auto"
				If Not doAutoBattle($roundNumber, $autoMode) Then
					setLog("Unknown error in Auto-Battle!", 1, $LOG_ERROR)
					ExitLoop
				EndIf
				
			Case "battle"
				If Not doBattle($autoMode) Then
					setLog("Unknown error in Battle!", 1, $LOG_ERROR)
					ExitLoop
				EndIf
				
			Case "defeat"
				setLog("Defeated!", 1)
				ExitLoop
				
			Case "battle-end-exp", "battle-sell"
				clickPoint($game_coorTap)
				
			Case "battle-end"
				Local $battle_coorNext = [500, 250]
				clickWhile($battle_coorNext, "battle-end")
				
			Case "map-battle"
				clickWhile($map_coorBattle, "map-battle")
			
			Case "refill"
				; If the number of used gems will not exceed the limit, purchase additional energy
				If Not refilGems($gemsUsed, $maxRefill) Then 
					setLog("Unknown error in Gem-Refill!", 1, $LOG_ERROR)
					ExitLoop
				EndIf
				
			Case "map", "map-stage", "village", "manage", "monsters", "quests", "clan", "esc", "inbox", "battle-sell"
				If setLog("Going to Tower of Chaos...", 1) Then ExitLoop
				If navigate("map") = True Then
					If enterStage("map-tower-of-chaos", "any", "any") = False Then
						If setLog("Error: Could not enter map stage.", 1) Then ExitLoop
					EndIf
				EndIf
			
			Case "toc"
				If setLog("Searching for battle...", 1, $LOG_DEBUG) Then ExitLoop
				$pointArray = findImage("misc-dungeon-energy", 100, 1000, 450, 0, 600, 550)
				If isArray($pointArray) = True Then
					If setLog("Entering battle...", 1) Then ExitLoop
					clickPoint($pointArray)
				Else
					ControlSend($hWindow, "", "", "{LEFT}")
					If _Sleep(1000) Then ExitLoop
				EndIf
				
			Case "pause"
				clickPoint($battle_coorContinue, 1, 2000)
				
			Case "unknown"
				;clickPoint($game_coorTap)
				;clickPoint(findImage("misc-close", 30)) ;to close any windows open
				
			Case "lost-connection"
				clickPoint($game_coorConnectionRetry)
		EndSwitch
	WEnd
EndFunc