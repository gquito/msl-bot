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

			If getLocation() = "refill" Then
				If $gemUsed + 30 <= $refillEnergy Then
					While getLocation() = "refill"
						clickPoint($game_coorRefill, 1, 1000)
					WEnd

					If getLocation() = "buy-gem" Or getLocation() = "unknown" Then
						setLog("Out of gems!", 2)
						Return $countRun
					EndIf

					clickUntil($game_coorRefillConfirm, "refill")
					clickWhile("705, 99", "refill")

					If setLog("Refill gems: " & $gemUsed + 30 & "/" & $refillEnergy, 0) Then ExitLoop
					$gemUsed += 30
				Else
					setLog("Gem used exceed max gems!", 0)
					Return $countRun
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
					Return $countRun
				EndIf
			WEnd

			clickUntil($game_coorTap, "battle-end", 100, 100)
			clickWhile("400,250", "battle-end")

			waitLocation("guardian-dungeons", 10000)
			$currLocation = getLocation()
		Else
			If $countRun = 0 Then
				If setLog("Guardian dungeon not found, going back to map.", 1) Then Return -1
			EndIf

			navigate("map")
			Return $countRun
		EndIf
	WEnd

	navigate("map")
	Return $countRun
EndFunc