#cs
	Function: farmPvp
	Farms Pvp until the stop condition is met.

	Author: Shimizoki (2017)
#ce
Func farmPvp()
	setLog("~~~Starting 'Farm Pvp' script~~~", 2)
	farmPvpMain()
	setLog("~~~Finished 'Farm Pvp' script~~~", 2)
EndFunc   ;==>farmPvp

Func farmPvpMain()

	Local $roundNumber = [0,0]
	Local $autoMode = $AUTO_BATTLE

	While True
		If _Sleep(100) Then Return -1
		
		antiStuck("map")

		Local $location = getLocation()
		Switch $location
			Case "battle-auto"
				If Not doAutoBattle($roundNumber, $autoMode) Then
					If setLog("Unknown error in Auto-Battle!", 1, $LOG_ERROR) Then Return -1
					ExitLoop
				EndIf
				
			Case "battle"
				If Not doBattle($autoMode) Then
					If setLog("Unknown error in Battle!", 1, $LOG_ERROR) Then Return -1
					ExitLoop
				EndIf
				
			Case "battle-end"
				If setLog("Battle-End!", 1) Then Return -1
				clickPoint($game_coorTap)
				
			Case "battle-end-exp"
				If setLog("Battle-End: Defeat!", 1) Then Return -1
				clickPoint($game_coorTap)
			
			Case "dialogue"
				If setLog("Dialogue Found") Then Return -1
				clickPoint($game_coorDialogueSkip)
						
			Case "astroleague"
				; Refresh the astromon league pvp list if possible
				Local $refreshButton = findImage("pvp-refresh-list", 100, 1000, 650, 150, 780, 195)
				If isArray($refreshButton) = True Then
					If setLog("Refreshing List...", 1) Then Return -1
					clickPoint($refreshButton)
					If _Sleep(100) Then Return -1
					clickPoint("405,310")
					If _Sleep(250) Then Return -1
				EndIf
				
				If setLog("Searching for battle...", 1, $LOG_DEBUG) Then Return -1
				
				; Search for an available battle
				Local $enterBattle = findImage("pvp-pay-ticket", 100, 1000, 670, 200, 785, 485)
				If isArray($enterBattle) = True Then
					If setLog("Entering battle...", 1) Then Return -1
					clickPoint($enterBattle)
					
				; If none can be found, scroll
				Else
					ControlSend($hWindow, "", "", "{RIGHT}")
					If _Sleep(1000) Then Return -1
				EndIf
			
			Case "astroleague-prize"
				clickWhile("400,325", "astroleague-prize")
			
			Case "map-battle"
				clickWhile($map_coorBattle, "map-battle")
			
			Case "buy-gem"
				If setLog("Out of tickets!", 0) Then Return -1
				clickPoint(findImage("misc-close", 30)) ;to close any windows open
				
				; Exit out of League
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
				
			Case "map", "map-stage", "village", "manage", "monsters", "quests", "clan", "esc", "inbox", "battle-sell"
				If setLog("Going to league...", 1) Then Return -1
				If navigate("map") = True Then
					If enterStage("map-astromon-league", "any", "any") = False Then
						If setLog("Error: Could not enter map stage.", 1) Then Return -1
					EndIf
				EndIf
				
			;Case Else
			;	If setLog("Going to league from " & $location, 1) Then Return -1
			;	If navigate("map") = True Then
			;		If enterStage("map-astromon-league", "any", "any") = False Then
			;			If setLog("Error: Could not enter map stage.", 1) Then Return -1
			;		EndIf
			;	EndIf
			
		EndSwitch
	WEnd
EndFunc   ;==>farmPvpMain