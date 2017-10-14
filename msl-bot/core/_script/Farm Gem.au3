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

	If $justEvolve = 1 Then
		If MsgBox(8193, "Farm Gem WARNING", "WARNING: You must have at least " & 330*Int($gemsToFarm/100) & "k gold for this script to function correctly!" & @CRLF & "**LOCK YOUR GLEEMS.") = 2 Then Return -1
	Else
		If MsgBox(8193, "Farm Gem WARNING", "WARNING: You must have at least " & 330*Int($gemsToFarm/100) & "k gold and " & 16 & " spaces in your astromon storage for this script to function correctly!" & @CRLF & "Also average energy per 16 astromons is 40, make sure you refill to make things more smooth." & @CRLF & "**LAST THING LOCK YOUR GLEEMS.") = 2 Then Return -1
		Do
			Local $freeSpace = InputBox("Free Gem Input", "Enter number of free space in your Astromon Inventory: " & @CRLF & "(Must be greater than or equal to 16)", 16)
			If @Error = 1 Then Return -1
		Until StringIsDigit($freeSpace) And ($freeSpace >= 16)
	EndIf

	setLog("~~~Starting 'Farm Gem' script~~~", 2)
	farmGemMain($monster, $justEvolve, $gemsToFarm, $maxRefill)
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

Func farmGemMain($monster, $justEvolve, $gemsToFarm, $maxRefill)
	Switch $monster
		Case "slime"
			Local $imgName = "catch-one-star"
			Local $map = "map-phantom-forest"
	EndSwitch

	Local $gemUsed = 0

	Local $numIteration = Int($gemsToFarm/100)
	If setLog("Total number of iteration: " & $numIteration & ", " & 100*$numIteration & " gems.", 1) Then Return -1
	Local $cIteration = 0
	Local $totalIteration = $numIteration

	While $numIteration > 0
		$globalData = "Iteration: " & $cIteration & "/" & $totalIteration & "|Farmed Gems: " & $cIteration*100 & "|Gem Refill Used: " & $gemUsed & "/" & $maxRefill
		setList("")

		If $justEvolve = 0 Then
			If _Sleep(10) Then Return -1
			If setLog("Going to collect 16 " & $monster & "s..", 1) Then Return -1

			;calling farmAstromon script to farm 16 monsters

			Local $needCatch = 16
			farmGemCatching($needCatch, $gemUsed, $maxRefill)
		EndIf

		;going back to village to manage
		If _Sleep(10) Then Return -1
		If setLog("Going to evolve " & $monster & "..", 1) Then Return -1
		If evolve("monster-" & $monster) = False Then
			If setLog("Error: Something went wrong in the evolving process!", 1) Then Return -1
			Return False
		EndIf

		$numIteration -= 1
		$cIteration += 1

		$globalData = "Iteration: " & $cIteration & "/" & $totalIteration & "|Farmed Gems: " & $cIteration*100 & "|Gem Refill Used: " & $gemUsed & "/" & $maxRefill
		setList("")
	WEnd

	Return True ;success
EndFunc   ;==>farmGemMain

Func farmGemCatching(ByRef $needCatch, ByRef $gemUsed, $maxRefill)
	While $needCatch > 0
		;Going into battle to farm astromons
		Local $locTimer = TimerInit()
		While navigate("map") = False
			If TimerDiff($locTimer) > 300000 Then ;5 minutes
				If setLog("Error: Could not go into maps!", 1) Then Return -1
				Return False
			EndIf
		WEnd

		Local $locTimer = TimerInit()
		While enterStage("Phantom Forest", "normal", "1", False) = False
			If getLocation() = "refill" Then
				If Not($gemUsed = null) And ($gemUsed + 30 <= $maxRefill) Then
					While getLocation() = "refill"
						clickPoint($game_coorRefill, 1, 1000)
					WEnd

					If getLocation() = "buy-gem" Or getLocation() = "unknown" Then
						setLog("Out of gems!", 2)
						ExitLoop
					EndIf

					clickUntil($game_coorRefillConfirm, "refill")
					clickWhile("705, 99", "refill")

					If setLog("Refill gems: " & $gemUsed + 30 & "/" & $maxRefill, 0) Then ExitLoop
					$gemUsed += 30
				Else
					setLog("Gem used exceed max gems!", 0)
					ExitLoop
				EndIf

				navigate("map")
			EndIf

			If TimerDiff($locTimer) > 300000 Then ;5 minutes
				If setLog("Error: Could not go into battle!", 1) Then Return -1
				Return False
			EndIf
		WEnd

		If _Sleep(10) Then Return -1
		$needCatch -= farmAstromonMain("catch-one-star", $needCatch, 1, 0, $gemUsed, $maxRefill)
	WEnd
EndFunc
