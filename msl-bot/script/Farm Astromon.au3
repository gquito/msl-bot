#cs
	Function: farmAstromon
	Calls farmAstromonMain with config settings

	Author: GkevinOD (2017)
#ce
Func farmAstromon()
	Local $imgName = IniRead(@ScriptDir & "/" & $botConfig, "Farm Astromon", "image", Null)
	Local $limit = Int(IniRead(@ScriptDir & "/" & $botConfig, "Farm Astromon", "limit", 16))
	Local $catchRares = IniRead(@ScriptDir & "/" & $botConfig, "Farm Astromon", "catch-rares", 0)
	Local $finishRound = IniRead(@ScriptDir & "/" & $botConfig, "Farm Astromon", "finish-round", 0)

	farmAstromonMain($imgName, $limit, $catchRares, $finishRound)
EndFunc

#cs
	Function: farmAstromonMain
	Farm a type of astromon in story mode.

	Parameters:
		imgName: (String) Image name of astromon to look for. EX: catch-one-star
		limit: (Int) Maximum number of astromons to farm. 0=Farm until max
		catchRares: (Int) 1=True; 0=False
		finishRound: (Int) 1=True; 0=False

	Author: GkevinOD (2017)
#ce
Func farmAstromonMain($imgName, $limit, $catchRares, $finishRound)
	Local $captures[0]
	If $catchRares = 1 Then
		Dim $rawCapture = StringSplit("legendary,super rare,rare,exotic,variant", ",", 2)
		For $capture In $rawCapture
			Local $grade = StringReplace($capture, " ", "-")
			If FileExists(@ScriptDir & "/core/images/catch/catch-" & $grade & ".bmp") Then
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

	setLog("~~~Starting 'Farm Astromon' script~~~", 2)

	Dim $intCounter = 0
	While $intCounter < $limit
		GUICtrlSetData($listScript, "")
		GUICtrlSetData($listScript, "Astromons: " & $intCounter & "/" & $limit)

		If _Sleep(100) Then ExitLoop
		Switch getLocation()
			Case "battle-auto"
				clickPoint($battle_coorAuto, 1, 1000)
			Case "battle"
				If checkPixel($battle_pixelUnavailable) = False Then
					While navigate("battle", "catch-mode") = True
						Local $catch = catch($captures, True)

						If UBound($catch) = 0 Or $intCounter >= $limit Then ExitLoop
						For $astromon In $catch
							If Not(StringLeft($astromon, 1) = "!") Then $intCounter += 1
							GUICtrlSetData($listScript, "")
							GUICtrlSetData($listScript, "Astromons: " & $intCounter & "/" & $limit)
							If $intCounter >= $limit Then ExitLoop
						Next
					WEnd

					While getLocation() = "battle"
						If checkPixel($battle_pixelUnavailable) = True Then ExitLoop
						If setLogReplace("Attaking astromons..", 1) Then ExitLoop
						clickPoint($battle_coorAuto, 2, 10)
						If _Sleep(1000) Then ExitLoop
					WEnd
					logUpdate()
				Else
					If $finishRound = 0 Then
						setLog("Out of astrochips, restarting..", 1)
						clickUntil($battle_coorPause, "pause")
						clickPoint($battle_coorGiveUp)
						clickPoint($battle_coorGiveUpConfirm)
					Else
						If setLog("Out of astrochips, attacking..", 1) Then ExitLoop(2)
						While checkLocations("battle-end,battle-end-exp,battle-sell,defeat") = ""
							clickPoint($battle_coorAuto, 2, 10)
							If _Sleep(1000) Then ExitLoop(2)
						WEnd
					EndIf
				EndIf
			Case "battle-end-exp", "battle-sell"
				clickUntil($game_coorTap, "battle-end", 100, 100)

			Case "battle-end"
				Local $quickRestartPoint = findImage("battle-quick-restart", 30)
				If isArray($quickRestartPoint) Then
					clickPoint($quickRestartPoint)
				Else
					clickPoint(findImage("battle-play-again", 30))
				EndIf

			Case "map-battle"
				clickUntil($map_coorBattle, "battle")

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

			Case "battle-astromon-full", "map-astromon-full"
				setLog("Inventory is full! Finishing round.", 1)
				clickUntil("400, 300", "battle")

				While checkLocations("battle-end,battle-end-exp,battle-sell,defeat") = ""
					clickPoint($battle_coorAuto, 2, 10)
					If _Sleep(1000) Then ExitLoop(2)
				WEnd

				ExitLoop
		EndSwitch
	WEnd

	If getLocation() = "battle" Then
		clickPoint($battle_coorAuto)
	EndIf

	setLog("~~~Finished 'Farm Astromon' script~~~", 2)
EndFunc   ;==>farmAstromon
