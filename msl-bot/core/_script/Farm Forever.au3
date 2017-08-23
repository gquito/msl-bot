#cs
	Function: farmForever
	Calls farmAstromonMain with config settings

	Author: Shimizoki (2017)
#ce
Func farmForever()
	setLog("~~~Starting 'Farm Forever' script~~~", 2)
	farmForeverMain()
	setLog("~~~Finished 'Farm Forever' script~~~", 2)
EndFunc   ;==>farmForever


#cs
	Function: farmForeverMain
	Farm a type of astromon in story mode.

	Author: Shimizoki (2017)
#ce
Func farmForeverMain()
	
	Local $monster = "mimic"
	Local $strGolem = 8
	
	Local $gemsUsed = 0
	Local $maxGemRefill = 9999
	
	Local $goldSpent = 0			
	Local $maxGoldSpend = 1000000	
	
	Local $quest = 1				; TODO: THIS SHOULD BE PASSED IN
	Local $hourly = 1				; TODO: THIS SHOULD BE PASSED IN
	Local $guardian = 1				; TODO: THIS SHOULD BE PASSED IN
	Local $sellGems = "1,2,3,4,5"	; TODO: THIS SHOULD BE PASSED IN
	
	Local $buySale = 1				; TODO: THIS SHOULD BE PASSED IN
	Local $buyEggs = 1				; TODO: THIS SHOULD BE PASSED IN
	Local $buySoulstones = 0		; TODO: THIS SHOULD BE PASSED IN
	Local $shoppingList = [$buySale, $buySoulstones, $buyEggs]
	
	
	While True

		antiStuck("map")
		If _Sleep(100) Then ExitLoop
		
		Local $location = getLocation()
		Switch $location
			Case "battle-end"
				clickWhile($battle_coorRestart, "battle-end", 30, 1000)
				If _Sleep(1000) Then ExitLoop
				
			Case "map-battle"
				clickWhile($map_coorBattle, "map-battle", 30, 1000)
				If _Sleep(1000) Then ExitLoop
							
			Case "map-astromon-full"
				setLog("~~~Starting 'Farm Gem' script~~~", 2)
				farmGemMain($monster, 1, 9999, 30, 0)
				navigate("map")
			
			Case "buy-gold"
				clickPoint(findImage("misc-close", 30)) ;to close any windows open
				navigate("map")
				setLog("~~~Starting 'Farm Golem' script~~~", 2)
				farmGolemMain($strGolem, 1, $maxGemRefill, $guardian, $quest, $hourly, $buyEggs, $buySoulstones, $maxGoldSpend)
			
			Case "refill"
				setLog("~~~Starting 'Farm Gem' script~~~", 2)
				farmGemMain($monster, 1, 9999, 30, 0)
				
			Case "unknown"
				clickPoint($game_coorTap)
				clickPoint(findImage("misc-close", 30)) ;to close any windows open
				ExitLoop
					
			Case Else
				setLog("~~~Starting 'Farm Astromon' script~~~", 2)
				_farmAstromonMain($monster, 0, 1, 1, $gemsUsed, $maxGemRefill, $quest, $hourly, $shoppingList, $goldSpent, $maxGoldSpend, $guardian, $sellGems)
			
		EndSwitch
	WEnd
	
	Return
EndFunc   ;==>farmForeverMain
