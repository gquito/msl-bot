#cs
	Function: farmGem
	Calls farmGemMain with config settings

	Author: GkevinOD (2017)
#ce
Func farmGem()
	Local $justEvolve = IniRead($botConfigDir, "Farm Gem", "just-evolve", 1)
	Local $monster = IniRead($botConfigDir, "Farm Gem", "monster", "slime")
	Local $gemsToFarm = IniRead($botConfigDir, "Farm Gem", "gems-to-farm", 100)
	Local $maxRefill = IniRead($botConfigDir, "Farm Gem", "refill-max", 30)

	Local $freeSpace = 16
	If $justEvolve = 1 Then
		If MsgBox(8193, "Farm Gem WARNING", "WARNING: You must have at least " & 330*Int($gemsToFarm/100) & "k gold for this script to function correctly!" & @CRLF & "**LOCK YOUR GLEEMS.") = 2 Then Return -1
	Else
		If MsgBox(8193, "Farm Gem WARNING", "WARNING: You must have at least " & 330*Int($gemsToFarm/100) & "k gold and " & 16 & " spaces in your astromon storage for this script to function correctly!" & @CRLF & "Also average energy per 16 astromons is 40, make sure you refill to make things more smooth." & @CRLF & "**LAST THING LOCK YOUR GLEEMS.") = 2 Then Return -1
		Do
			$freeSpace = InputBox("Free Gem Input", "Enter number of free space in your Astromon Inventory: " & @CRLF & "(Must be greater than or equal to 16)", 16)
			If @Error = 1 Then Return -1
		Until StringIsDigit($freeSpace) And ($freeSpace >= 0); And ($freeSpace >= 16)
	EndIf

	setLog("~~~Starting 'Farm Gem' script~~~", 2)
	farmGemMain($monster, $justEvolve, $gemsToFarm, $maxRefill, $freeSpace)
	setLog("~~~Finished 'Farm Gem' script~~~", 2)
EndFunc   ;==>farmGem

#cs ----------------------------------------------------------------------------
	Function: farmGemMain
	Farm astromon and evo to get 100 gems

	Parameter:
		monster: (String) Monster to farm with, current available: slime
		justEvolve: (Int) 1=True; 0=False
		gemsToFarm: (Int) Gems to farm 100, 200, 300
		refillMax: (Int) Maximum gems bot can use for refill

	Author: GkevinOD (2017)
#ce ----------------------------------------------------------------------------

Func farmGemMain($monster, $justEvolve, $gemsToFarm, $maxRefill, $freeSpace)

	Local $gemUsed = 0

	Local $numIteration = Int($gemsToFarm/100)
	If setLog("Total number of iteration: " & $numIteration & ", " & 100*$numIteration & " gems.", 1) Then Return -1
	Local $cIteration = 0
	Local $totalIteration = $numIteration
	
	$globalDataStr = ("Iteration: " & $cIteration & "/" & $totalIteration & "|Farmed Gems: " & $cIteration*100 & "|Gem Refill Used: " & $gemUsed & "/" & $maxRefill)

	While $numIteration > 0
		setList("")

		;going back to village to manage
		If _Sleep(10) Then Return -1
		If setLog("Going to evolve " & $monster & "...", 1) Then Return -1
		
		Local $monsNeededToEvo = evolve($monster)
		While Not ($monsNeededToEvo > 0)
			If $monsNeededToEvo == False Then
				If setLog("Error: Something went wrong in the evolving process!", 1) Then Return -1
				Return False
			ElseIf $monsNeededToEvo < 0 Then 
				Return -1
			EndIf
		
			$cIteration += 1
			$freeSpace += 16
			setList("Iteration: " & $cIteration & "/" & $totalIteration & "|Farmed Gems: " & $cIteration*100 & "|Gem Refill Used: " & $gemUsed & "/" & $maxRefill)
			
			$monsNeededToEvo = evolve($monster)
		WEnd	
		
		; Catch any additional mons needed
		Local $numIterationsCatching =  _Min(BitShift($freeSpace, 4), $numIteration - $cIteration)
		If $justEvolve = 0 Then
			If _Sleep(10) Then Return -1
			
			Local $needCatch = (($numIterationsCatching - 1) * 16) + $monsNeededToEvo
			If $needCatch >= 0 Then
				If setLog("Going to collect " & $needCatch & " " & $monster & "s...", 1) Then Return -1
				farmGemCatching($needCatch, $monster, $gemUsed, $maxRefill)
				
				$freeSpace -= $needCatch
			Else
				If setLog("Not enough free-space! Free up " & -$needCatch & " space(s).", 1) Then Return -1
				ExitLoop
			EndIf
		Else
			ExitLoop
		EndIf
		
		$numIteration -= $numIterationsCatching

		$globalDataStr = ("Iteration: " & $cIteration & "/" & $totalIteration & "|Farmed Gems: " & $cIteration*100 & "|Gem Refill Used: " & $gemUsed & "/" & $maxRefill)
	WEnd
	setList("")

	navigate("village")
	Return True ;success
EndFunc   ;==>farmGemMain

Func farmGemCatching(ByRef $needCatch, $monster, ByRef $gemUsed, $maxRefill)
	While $needCatch > 0
		If setLog("Need to catch " & $needCatch & " more astromon" , 1, $LOG_DEBUG) Then Return -1
	
		;calling farmAstromon script to farm monsters
		If _Sleep(10) Then Return -1
		$needCatch -= farmAstromonMain($monster, $needCatch, 0, 0, $gemUsed, $maxRefill)
	WEnd
EndFunc
