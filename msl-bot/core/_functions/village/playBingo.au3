#cs
	Function: playBingo
	Calls playBingoMain with config settings

	Author: Shimizoki (2017)
#ce
Func playBingo()	
	;Local $village_pixelBingoReward = [75, 125, 0x702ACC]
	;Local $village_pixelBingoReward2 = [81, 131, 0xFFBA08]
	Local $bingo_coorGetPiece = [600, 350]
	
	Local $timer = TimerInit()
	Local $timeout = 3000	; 3 seconds
	
	While True
		If _Sleep(50) Then ExitLoop

		Local $currLocation = getLocation()

		antiStuck("map")
		Switch $currLocation
				
			Case "village"				
				clickPoint("70,350") ;to close any windows open
				If _Sleep(500) Then Return -1
				
				setLog("Playing Bingo", 1, $LOG_DEBUG)
				clickWhile($village_coorBingo, "village")
				
			Case "bingo-play"
				setLog("Clicking Bingo", 1, $LOG_DEBUG)
				clickWhile($bingo_coorGetPiece, "bingo-play")
				$timer = TimerInit()
				
			Case "bingo-wait"
				If TimerDiff($timer) > $timeout Then
					If setLog("No more rewards available at this time.") Then Return -1
					ExitLoop
				EndIf
				
			Case "dialogue"
				setLog("Dialogue Found", 1, $LOG_DEBUG)
				clickPoint($game_coorDialogueSkip)
				
			Case "bingo-prize"
				setLog("Bingo!", 1)
				clickPoint("400,325")
				
			Case "bingo-over"
				setLog("Bingo is over!", 1)
				ExitLoop
			
			;Case "map", "astroleague", "map-stage", "toc", "association", "clan", "starstone-dungeons", "golem-dungeons", "elemental-dungeons", "quests"
			;	navigate("map", "village")
			;	If _Sleep(2000) Then ExitLoop
				
			Case "pause"
				clickPoint($battle_coorContinue, 1, 2000)
				
			Case "unknown"
				clickPoint($game_coorTap)
				
			Case "lost-connection"
				clickPoint($game_coorConnectionRetry)
				
			Case Else
				navigate("village")
				If _Sleep(2000) Then ExitLoop
			
		EndSwitch
	WEnd
	
	clickPoint(findImage("misc-close", 30)) ;to close the open Bingo window
EndFunc   ;==>playBingo

Func playBingoMain()

				
EndFunc   ;==>playBingoMain
