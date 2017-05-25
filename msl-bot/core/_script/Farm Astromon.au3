#cs
	Function: farmAstromon
	Calls farmAstromonMain with config settings

	Author: GkevinOD (2017)
#ce
Func farmAstromon()
	Local $imgName = IniRead($botConfigDir, "Farm Astromon", "image", Null)
	Local $limit = Int(IniRead($botConfigDir, "Farm Astromon", "limit", 16))
	Local $catchRares = IniRead($botConfigDir, "Farm Astromon", "catch-rares", 1)
	Local $finishRound = IniRead($botConfigDir, "Farm Astromon", "finish-round", 0)

	setLog("~~~Starting 'Farm Astromon' script~~~", 2)
	farmAstromonMain($imgName, $limit, $catchRares, $finishRound, $nullVar, null)
	setLog("~~~Finished 'Farm Astromon' script~~~", 2)
EndFunc   ;==>farmAstromon

#cs
	Function: farmAstromonMain
	Farm a type of astromon in story mode.

	Parameters:
	imgName: (String) Image name of astromon to look for. EX: catch-one-star
	limit: (Int) Maximum number of astromons to farm. 0=Farm until max
	catchRares: (Int) 1=True; 0=False
	finishRound: (Int) 1=True; 0=False
	gemsUsed: (variable) Reference to gems used variable
	maxRefill: (Int) Max gems to use for refill

	Author: GkevinOD (2017)
#ce
Func farmAstromonMain($imgName, $limit, $catchRares, $finishRound, ByRef $gemsUsed, $maxRefill)
	Local $captures[0]
	If $catchRares = 1 Then
		Dim $rawCapture = StringSplit("legendary,super rare,rare,exotic,variant", ",", 2)
		For $capture In $rawCapture
			Local $grade = StringReplace($capture, " ", "-")
			If FileExists(@ScriptDir & "/core/_images/catch/catch-" & $grade & ".bmp") Then
				_ArrayAdd($captures, "catch-" & $grade)
			EndIf
		Next
	EndIf

	If ($imgName = Null) Or (Not FileExists($strImageDir & StringSplit($imgName, "-", 2)[0] & "\" & $imgName & ".bmp")) Then
		setLog("*Error: Image file does not exist!", 2)
		Return 0
	EndIf
	_ArrayAdd($captures, $imgName)

	If $limit = 0 Then
		setLog("*Limit is 0, will farm until inventory is full.", 2)
		$limit = 9999 ;really high number so counter never hits
	EndIf

	Local $intCounter = 0
	Local $roundCatch = 0 ;This to count if caught three so it skips faster
	While $intCounter <= $limit
		If _Sleep(100) Then ExitLoop
		Switch getLocation()
			Case "battle-auto"
				clickPoint($battle_coorAuto, 1, 1000)
			Case "battle"
				If checkPixel($battle_pixelUnavailable) = False Then
					Local $nextRound = False

					While True
						If _Sleep(10) Then Return -1
						If getLocation() = "pause" Then clickPoint($battle_coorContinue)

						Local $timerStart = TimerInit()
						While Not(getLocation() = "catch-mode")
							If _Sleep(10) Then Return -1
							If navigate("battle", "catch-mode") = True Then ExitLoop
							If TimerDiff($timerStart) > 7000 Then ExitLoop(2)
						WEnd

						Local $catch = catch($captures, True, False)
						If _Sleep(10) Then Return -1
						If UBound($catch) = 0 Then
							$nextRound = True ;not found
							ExitLoop
						EndIf

						For $astromon In $catch
							If _Sleep(10) Then Return -1
							If Not (StringMid($astromon, 1, 1) = "!") And (StringInStr($imgName, $astromon, 0) = True) Then
								$intCounter += 1
							EndIf
							$roundCatch += 1

							If setList("Astromons: " & $intCounter & "/" & $limit) Then Return -1
						Next

						If $intCounter >= $limit Then ExitLoop(2)
						If $roundCatch = 3 Then
							$roundCatch = 0
							If $finishRound = 0 Then
								If setLog("Out of astrochips, restarting..", 1) Then Return -1
								clickUntil($battle_coorPause, "pause")
								clickUntil($battle_coorGiveUp, "unknown")
								clickWhile($battle_coorGiveUpConfirm, "unknown")
							Else
								If setLog("Out of astrochips, attacking..", 1) Then Return -1
								Local $timerStart2 = TimerInit()
								While checkLocations("battle-end,battle-end-exp,battle-sell,defeat") = ""
									If TimerDiff($timerStart2) > 1500000 Then
										ExitLoop(2)
									EndIf

									clickPoint($battle_coorAuto, 2, 10)
									If _Sleep(1000) Then Return -1
								WEnd
							EndIf

							ContinueCase
						EndIf
					WEnd

					If $nextRound = True Then
						While Not(getLocation() = "unknown")
							clickPoint($battle_coorAuto, 2, 10)
							If _Sleep(1000) Then ExitLoop
						WEnd
					EndIf
				Else
					$roundCatch = 0
					If $finishRound = 0 Then
						setLog("Out of astrochips, restarting..", 1)
						clickUntil($battle_coorPause, "pause")
						clickUntil($battle_coorGiveUp, "unknown")
						clickWhile($battle_coorGiveUpConfirm, "unknown")
					Else
						If setLog("Out of astrochips, attacking..", 1) Then ExitLoop (2)
						While checkLocations("battle-end,battle-end-exp,battle-sell,defeat") = ""
							clickPoint($battle_coorAuto, 2, 10)
							If _Sleep(1000) Then ExitLoop (2)
						WEnd
					EndIf
				EndIf
			Case "battle-end-exp", "battle-sell"
				clickUntil($game_coorTap, "battle-end", 100, 100)

			Case "battle-end"
				Local $quickRestartPoint = findImage("battle-quick-restart", 30)
				If IsArray($quickRestartPoint) Then
					clickPoint($quickRestartPoint)
				Else
					clickPoint(findImage("battle-play-again", 30))
				EndIf

			Case "map-battle"
				clickWhile($map_coorBattle, "map-battle")

			Case "map", "map-stage", "astroleague", "village", "manage", "monsters", "quests"
				MsgBox($MB_ICONINFORMATION, $botName & " " & $botVersion, "Enter battle and turn auto off, then click ok.")

			Case "map-gem-full", "battle-gem-full"
				setLog("Gem inventory is full!", 1)
				ExitLoop
			Case "lost-connection"
				clickPoint($game_coorConnectionRetry)

			Case "dialogue"
				clickPoint($game_coorDialogueSkip)

			Case "catch-mode"
				clickPoint($battle_coorCatchCancel)

			Case "pause"
				clickPoint($battle_coorContinue)

			Case "refill"
				If Not($gemsUsed = null) And ($gemsUsed + 30 <= $maxRefill) Then
					While getLocation() = "refill"
						clickPoint($game_coorRefill, 1, 1000)
					WEnd

					If getLocation() = "buy-gem" Or getLocation() = "unknown" Then
						setLog("Out of gems!", 2)
						ExitLoop
					EndIf

					clickUntil($game_coorRefillConfirm, "refill")
					clickWhile("705, 99", "refill")

					If setLog("Refill gems: " & $gemsUsed + 30 & "/" & $maxRefill, 0) Then ExitLoop
					$gemsUsed += 30
				Else
					setLog("Gem used exceed max gems!", 0)
					ExitLoop
				EndIf

			Case "battle-astromon-full", "map-astromon-full"
				setLog("Inventory is full! Finishing round.", 1)
				clickUntil("400, 300", "battle")

				While checkLocations("battle-end,battle-end-exp,battle-sell,defeat") = ""
					clickPoint($battle_coorAuto, 2, 10)
					If _Sleep(1000) Then ExitLoop (2)
				WEnd

				ExitLoop
		EndSwitch
	WEnd

	If getLocation() = "battle" Then
		clickPoint($battle_coorAuto)
	EndIf

	Return $intCounter
EndFunc   ;==>farmAstromonMain
