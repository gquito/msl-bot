#cs
	Function: farmGoldDungeon
	Calls farmGoldDungeonMain with config settings

	Author: Shimizoki (2017)
#ce
Func farmGoldDungeon()
	Local $selectBoss = True

	Local $intStartTime = TimerInit()
	Local $intRunCount = 0
	
	Local $roundNumber = [0,0]
	Local $autoMode = $AUTO_BATTLE
	
	Local $gemsUsed = 0
	Local $maxGemRefill = 30

	While True
		If _Sleep(50) Then ExitLoop

		Local $currLocation = getLocation()

		antiStuck("map")
		Switch $currLocation
			Case "battle-auto"
				If Not doAutoBattle($roundNumber, $autoMode, $selectBoss) Then
					setLog("Unknown error in Auto-Battle!", 1, $LOG_ERROR)
					;ExitLoop
				EndIf
				
			Case "battle"
				If Not doBattle($autoMode) Then
					setLog("Unknown error in Battle!", 1, $LOG_ERROR)
					;ExitLoop
				EndIf
				
			Case "refill"
				; If the number of used gems will not exceed the limit, purchase additional energy
				If Not refilGems($gemsUsed, $maxGemRefill) Then 
					setLog("Unknown error in Gem-Refill!", 1, $LOG_ERROR)
					;ExitLoop
				EndIf
				
			Case "battle-end-exp", "battle-sell"
				clickPoint($game_coorTap)
				
			Case "battle-end"
				Local $battle_coorNext = [500, 250]
				clickUntil($battle_coorNext, "map-battle")
				
			Case "map-battle"
				clickWhile($map_coorBattle, "map-battle")
			
			Case "map", "village", "astroleague", "map-stage", "toc", "association", "clan", "starstone-dungeons", "golem-dungeons", "elemental-dungeons", "quests"
				navigate("map", "gold-dungeons")
			
			Case "elemental-dungeons", "starstone-dungeons"
				clickUntil($map_coorGoldDungeons, "gold-dungeons")
			
			Case "gold-dungeons"				
				$pointArray = findImage("misc-dungeon-energy", 100, 1000, 550, 100, 700, 500)
				If isArray($pointArray) = True Then
					If setLog("Entering battle...", 1) Then ExitLoop
					clickPoint($pointArray)
				Else
					ControlSend($hWindow, "", "", "{ESC}")
					If setLog("No battles to enter...", 1) Then ExitLoop
					ExitLoop
				EndIf
								
			Case "battle-gem-full"
				setLog("Gem inventory is full!", 2)
				ExitLoop
				
			Case "defeat"
				clickPoint(findImage("battle-give-up", 30))
				clickUntil($game_coorTap, "battle-end", 20, 1000)
				
			Case "pause"
				clickPoint($battle_coorContinue)
				
			Case "lost-connection"
				clickPoint($game_coorConnectionRetry)
				
			;Case Else
			;	navigate("map", "gold-dungeons")
			
		EndSwitch
	WEnd
EndFunc   ;==>farmGoldDungeon
