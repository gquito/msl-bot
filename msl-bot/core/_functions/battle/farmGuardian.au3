#cs ----------------------------------------------------------------------------
 Function: farmGuardian
 Goes into guardian dungeons and attacks all dungeons

 Parameters:
	sellGems: (array) Gems to sell; Not array will not sell
	refillEnergy: (int) Amount of gems available to use to sell gems. >30 can refill once.
	gemUsed: (ByRef int) Increments 30 when refill

 Return:
	#number of dungeons run
	-1 on bot stop
#ce ----------------------------------------------------------------------------

Func farmGuardian($sellGems, $refillEnergy, ByRef $gemUsed)
	If navigate("map", "guardian-dungeons") = False Then Return 0
	If setLog("Checking for guardian dungeons...", 1) Then Return -1
	Local $currLocation = getLocation()

	Local $countRun = 0
	While $currLocation = "guardian-dungeons"
		Local $energyPoint = findImage("misc-dungeon-energy", 50)
		If isArray($energyPoint) And (clickUntil($energyPoint, "map-battle", 50) = 1) Then
			clickWhile($map_coorBattle, "map-battle")
			If _Sleep(500) Then Return -1

			Local $currLocation = getLocation()

			If $currLocation = "battle-gem-full" Or $currLocation = "map-gem-full" Then
				If isArray($sellGems) Then
					If setLog("Gem box is full, going to sell gems...", 1) Then Return -1
					If navigate("village", "manage") = 1 Then sellGems($sellGems)

					clickUntil("misc-dungeon-energy", "map-battle")
					clickWhile($map_coorBattle, "map-battle", 5)
				Else
					If setLog("Gem box is full!", 1) Then Return -1
					navigate("map")

					ExitLoop
				EndIf
			EndIf

			If checkLocations("refill") = 1 Then
				If $gemUsed + 30 <= $refillEnergy Then
					clickUntil($game_coorRefill, "refill-confirm")
					clickUntil($game_coorRefillConfirm, "refill")

					If checkLocations("buy-gem") Then
						setLog("Out of gems!", 1)
						ExitLoop
					EndIf

					clickPoint(findImage("misc-close", 30))

					setLog("")
					$gemUsed += 30
				Else
					setLog("Gem used exceed max gems!")
					navigate("map")

					ExitLoop
				EndIf
				clickWhile($map_coorBattle, "map-battle")
			EndIf

			$countRun += 1
			If setLogReplace("Found dungeon, attacking x" & $countRun & ".", 1) Then Return -1

			Local $initTime = TimerInit()
			While True
				If _Sleep(1000) Then Return -1
				If getLocation() = "battle-end-exp" Then ExitLoop

				If Int(TimerDiff($initTime)/1000) > 240 Then
					If setLog("Error: Could not finish Guardian dungeon within 5 minutes, exiting.") Then Return -1
					navigate("map")

					ExitLoop
				EndIf
			WEnd

			clickUntil($game_coorTap, "battle-end", 100, 100)

			Local $pointExit = findImage("battle-exit", 50)
			If isArray($pointExit) Then
				clickUntil($pointExit, "guardian-dungeons")
			Else
				If setLog("Error: Could not find battle-exit.bmp") Then Return -1
				Return 0
			EndIf

			waitLocation("guardian-dungeons", 10000)
			$currLocation = getLocation()
		Else
			If $countRun = 0 Then
				If setLog("Guardian dungeon not found, going back to map.", 1) Then Return -1
			EndIf

			navigate("map")
			ExitLoop
		EndIf
	WEnd

	Return $countRun
EndFunc