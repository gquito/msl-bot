;function: farmAstromon
;-Automatically farms an astromon
;pre:
;   -config must be set for script
;   -required config keys: map, capture, guardian-dungeon
;author: GkevinOD
Func farmAstromon()
	;beginning script
	setLog("*Loading config for Farm Astromon.", 2)

	;getting configs
	Dim $captures[0] ;

	If IniRead(@ScriptDir & "/" & $botConfig, "Farm Astromon", "catch-rares", 0) = 1 Then
		Dim $rawCapture = StringSplit("legendary,super rare,rare,exotic,variant", ",", 2)
		For $capture In $rawCapture
			Local $grade = StringReplace($capture, " ", "-")
			If FileExists(@ScriptDir & "/core/images/catch/catch-" & $grade & ".bmp") Then
				_ArrayAdd($captures, "catch-" & $grade)

				Local $tempInt = 2
				While FileExists(@ScriptDir & "/core/images/catch/catch-" & $grade & $tempInt & ".bmp")
					_ArrayAdd($captures, "catch-" & $grade & $tempInt)
					$tempInt += 1
				WEnd
			EndIf
		Next
	EndIf

	Local $imgName = IniRead(@ScriptDir & "/" & $botConfig, "Farm Astromon", "image", Null)
	If ($imgName = Null) Or (Not FileExists($strImageDir & StringSplit($imgName, "-", 2)[0] & "\" & $imgName & ".bmp")) Then
		setLog("*Error: Image file does not exist!", 2)
		Return 0
	EndIf

	_ArrayAdd($captures, $imgName)

	Dim $limit = Int(IniRead(@ScriptDir & "/" & $botConfig, "Farm Astromon", "limit", 16))
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
			Case "battle"
				If checkPixelWait($battle_pixelUnavailable, 2) = False Then
					While True ;while there are Astromons
						navigate("battle", "catch-mode")
						$tempStr = catch($captures, True, False, True, False)
						If ($tempStr = -1) Or ($tempStr = "") Then ExitLoop

						$intCounter += 1

						GUICtrlSetData($listScript, "")
						GUICtrlSetData($listScript, "~Farm Astromon Data~|# of Astromons: " & $intCounter & "/" & $limit)
						If $intCounter = $limit Then ExitLoop (2)
					WEnd

					If _Sleep(10) Then ExitLoop

					setLog("Attaking astromons..", 1)
					clickPoint($battle_coorAuto, 2, 10)
				Else
					setLog("Out of astrochips, restarting..", 1)
					While True
						ControlSend($hWindow, "", "", "{ESC}")
						If checkLocations("battle-end-exp", "battle-sell", "pause") = 1 Then
							ExitLoop
						EndIf

						If _Sleep(50) Then ExitLoop (2)
					WEnd

					clickPoint($battle_coorGiveUp)
					clickPoint($battle_coorGiveUpConfirm)
				EndIf
			Case "battle-end-exp", "battle-sell"
				clickPointUntil($game_coorTap, "battle-end")

			Case "battle-end"
				clickImage("battle-play-again")

			Case "map-battle"
				clickPointUntil($map_coorBattle, "battle")

			Case "map", "map-stage", "astroleague", "village", "manage", "monsters", "quests"
				MsgBox($MB_ICONINFORMATION, $botName & " " & $botVersion, "Enter battle and turn auto off, then click ok.")

			Case "map-gem-full", "battle-gem-full"
				setLog("Gem inventory is full", 1)
				ExitLoop

			Case "lost-connection"
				clickPoint($game_coorConnectionRetry)

			Case "dialogue"
				clickPoint($game_coorDialogueSkip)

			Case "battle-astromon-full", "map-astromon-full"
				setLog("Inventory is full.", 1)
				ExitLoop
		EndSwitch
	WEnd

	If getLocation() = "battle" Then
		clickPoint($battle_coorAuto)
	EndIf

	setLog("~~~Finished 'Farm Astromon' script~~~", 2)
EndFunc   ;==>farmAstromon
