#cs
	Function: farmPvp
	Farms Pvp until the stop condition is met.

	Author: Shimizoki (2017)
#ce
Func farmPvp()
	setLog("~~~Starting 'Farm Pvp' script~~~", 2)
	farmPvpMain()
	setLog("~~~Finished 'Farm Pvp' script~~~", 2)
EndFunc   ;==>farmGem

Func farmPvpMain()

	
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
				
			Case "battle-end"
				setLog("Battle-End!", 1)
				clickPoint($game_coorTap)
				
			Case "battle-end-exp"
				setLog("Battle-End: Defeat!", 1)
				clickPoint($game_coorTap)
			
			Case "dialogue"
				setLog("Dialogue Found")
				clickPoint($game_coorDialogueSkip)
			
			Case "map", "map-stage", "village", "manage", "monsters", "quests", "clan", "esc", "inbox", "battle-sell"
				If setLog("Going to league...", 1) Then ExitLoop
				If navigate("map") = True Then
					If enterStage("map-astromon-league", "any", "any") = False Then
						If setLog("Error: Could not enter map stage.", 1) Then ExitLoop
					EndIf
				EndIf
			
			Case "astroleague"
				Local $pointArray = findImage("pvp-refresh-list", 100, 1000, 650, 150, 780, 195)
				If isArray($pointArray) = True Then
					If setLog("Refreshing List...", 1) Then ExitLoop
					clickPoint($pointArray)
					If _Sleep(100) Then ExitLoop
					clickPoint("405,310")
					If _Sleep(250) Then ExitLoop
				EndIf
				
				If setLog("Searching for battle...", 1, $LOG_DEBUG) Then ExitLoop
				$pointArray = findImage("pvp-pay-ticket", 100, 1000, 670, 200, 785, 485)
				If isArray($pointArray) = True Then
					If setLog("Entering battle...", 1) Then ExitLoop
					clickPoint($pointArray)
				Else
					ControlSend($hWindow, "", "", "{RIGHT}")
					If _Sleep(1000) Then ExitLoop
				EndIf
			
			Case "astroleague-prize"
				clickWhile("400,325", "astroleague-prize")
			
			Case "map-battle"
				clickWhile($map_coorBattle, "map-battle")
			
			Case "buy-gem"
				setLog("Out of tickets!", 0)
				clickPoint(findImage("misc-close", 30)) ;to close any windows open
				ControlSend($hWindow, "", "", "{ESC}")
				_Sleep(100)
				ControlSend($hWindow, "", "", "{ESC}")
				ExitLoop
			
			Case "pause"
				clickPoint($battle_coorContinue, 1, 2000)
				
			Case "unknown"
				clickPoint($game_coorTap)
				clickPoint(findImage("misc-close", 30)) ;to close any windows open
				
			Case "lost-connection"
				clickPoint($game_coorConnectionRetry)
		EndSwitch
	WEnd
EndFunc