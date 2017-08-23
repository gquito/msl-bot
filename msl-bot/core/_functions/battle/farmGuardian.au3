#cs ----------------------------------------------------------------------------
 Function: farmGuardian
 Goes into guardian dungeons and attacks all dungeons

 Parameters:
	sellGems: (array) Gems to sell; Not array will not sell
	maxGemRefill: (int) Amount of gems available to use to sell gems. >30 can refill once.
	gemsUsed: (ByRef int) Increments 30 when refill

 Return:
	#number of dungeons run
	-1 on bot stop
#ce ----------------------------------------------------------------------------

Func farmGuardian($sellGems, $maxGemRefill, ByRef $gemsUsed)
	If navigate("map", "guardian-dungeons") = False Then Return 0
	If setLog("Checking for guardian dungeons...", 1) Then Return -1

	Local $battleTimer = TimerInit()
	
	Local $roundNumber = [0,0]		; The curround Round Number. [Curruent Round, Total Rounds]
	Local $autoMode = $AUTO_ROUND	; This is to determine at what points auto-battle will be enabled
	Local $runCount = 0
	
	While True

		antiStuck("map")
		If _Sleep(100) Then ExitLoop
		
		If TimerDiff($battleTimer)/1000 > 120 Then
			If setLog("Error: Could not finish Guardian dungeon within 2 minutes, exiting.") Then Return -1
			ExitLoop
		EndIf
		
		Local $location = getLocation()
		Switch $location
			Case "guardian-dungeons"
				Local $energyPoint = findImage("misc-dungeon-energy", 50)
				If isArray($energyPoint) Then
					clickUntil($energyPoint, "map-battle", 50)
					ContinueLoop
				Else
					If $runCount = 0 Then
						If setLog("Guardian dungeon not found, going back to map.", 1) Then Return -1
					EndIf
					ExitLoop
				EndIf
			
			Case "battle-auto"
				If Not doAutoBattle($roundNumber, $autoMode) Then
					setLog("Unknown error in Auto-Battle!", 1, $LOG_ERROR)
				EndIf
				
			Case "battle"
				If Not doBattle($autoMode) Then
					setLog("Unknown error in Battle!", 1, $LOG_ERROR)
				EndIf
				
			Case "refill"
				; If the number of used gems will not exceed the limit, purchase additional energy
				If Not refilGems($gemsUsed, $maxGemRefill) Then 
					setLog("Unknown error in Gem-Refill!", 1, $LOG_ERROR)
				EndIf
				
			Case "battle-end-exp", "battle-sell"
				clickUntil($game_coorTap, "battle-end", 100, 100)

			Case "battle-end"				
				; If Run end of battle checks and then restart
				If Not restartBattle($runCount) Then
					setLog("Unknown error in Battle-End!", 1, $LOG_ERROR)
				EndIf
				
				$battleTimer = TimerInit()
				
			Case "map-battle"
				$runCount += 1
				If setLogReplace("Found dungeon, attacking x" & $runCount & ".", 1) Then Return -1
				clickWhile($map_coorBattle, "map-battle")
				$battleTimer = TimerInit()
				
			Case "map-gem-full", "battle-gem-full"
				If setLogReplace("Gem is full, going to sell gems...", 1) Then Return -1
				If navigate("village", "manage") = 1 Then
					sellGems($sellGems)
					If setLogReplace("Gem is full, going to sell gems... Done!", 1) Then ExitLoop
				EndIf
				
			Case "lost-connection"
				clickPoint($game_coorConnectionRetry)

			Case "dialogue"
				clickPoint($game_coorDialogueSkip)

			Case "pause"
				clickPoint($battle_coorContinue, 1, 1000)
			
			Case "unknown"
				clickPoint($game_coorTap)
				clickPoint(findImage("misc-close", 30)) ;to close any windows open
					
			Case "battle-boss"
				;do Nothing
				If _Sleep(100) Then Return -1
					
			Case "map"
				ExitLoop
				
			;Case Else
			;	If setLog("Going into battle from " & $location & ".", 1) Then ExitLoop
			;	If navigate("map", "guardian-dungeons") = False Then Return 0
			
		EndSwitch
	WEnd
	
	navigate("map")
	Return $runCount
EndFunc