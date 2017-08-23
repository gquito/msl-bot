#cs
	Function: hatchEgg
	Calls hatchEggMain with config settings

	Author: Shimizoki (2017)
#ce
Func playBingo()
	setLog("~~~Starting 'Play Bingo' script~~~", 2)
	playBingoMain()
	setLog("~~~Finished 'Play Bingo' script~~~", 2)
EndFunc   ;==>farmGolem

Func playBingoMain()

	Local $intStartTime = TimerInit()
	Local $runCount = 0
	
	Local $village_pixelBingoReward = [75, 125, 0x702ACC]
	Local $village_pixelBingoReward2 = [81, 131, 0xFFBA08]
	Local $bingo_coorGetPiece = [600, 350]
	
	Local $timer = TimerInit()
	
	While True
		If _Sleep(50) Then ExitLoop

		Local $currLocation = getLocation()

		antiStuck("map")
		Switch $currLocation
				
			Case "village"				
				clickPoint("70,350") ;to close any windows open
				If _Sleep(500) Then Return -1
				
				;If checkPixel($village_pixelBingoReward) Or checkPixel($village_pixelBingoReward2) Then
					setLog("Playing Bingo")
					clickUntil($village_coorBingo, "village-bingo")
				;Else
				;	setLog("Bingo not currently available.", 1)
				;	ExitLoop
				;EndIf
				
			Case "bingo-play"
				setLog("Clicking Bingo")
				clickPoint($bingo_coorGetPiece)
				_Sleep(250)
				clickPoint($bingo_coorGetPiece)
				$timer = TimerInit()
				
			Case "bingo-wait"
				If TimerDiff($timer) > 3000 Then
					If setLog("No more rewards available at this time.") Then Return -1
					ExitLoop
				EndIf
				
			Case "dialogue"
				setLog("Dialogue Found")
				clickPoint($game_coorDialogueSkip)
				
			Case "bingo-success"
				setLog("Bingo!", 1)
				clickPoint("400,325")
				
			Case "bingo-over"
				setLog("Bingo is over!", 1)
				ExitLoop
			
			Case "map", "astroleague", "map-stage", "toc", "association", "clan", "starstone-dungeons", "golem-dungeons", "elemental-dungeons", "quests"
				navigate("map", "village")
				If _Sleep(2000) Then ExitLoop
				
			Case "pause"
				clickPoint($battle_coorContinue, 1, 2000)
				
			Case "unknown"
				clickPoint($game_coorTap)
				
			Case "lost-connection"
				clickPoint($game_coorConnectionRetry)
		EndSwitch
	WEnd
	
	clickPoint(findImage("misc-close", 30)) ;to close the open Bingo window
				
EndFunc   ;==>farmGolemMain
