Func farmSlime()
	;beginning script
    setLog("*Loading config for Farm Slime.", 2)

    ;getting configs
    Dim $captures[0];

    Dim $rawCapture = StringSplit("legendary,super rare,rare,exotic,one star", ",", 2)
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

	Dim $limit = Int(IniRead(@ScriptDir & "/config.ini", "Farm Slime", "limit", 16))
	If $limit = 0 Then
		setLog("*Limit is 0, will farm until inv full.", 2)
	EndIf

    setLog("~~~Starting 'Farm Slime' script~~~", 2)
	;set up data info
    GUICtrlSetData($cmbLoad, "Select a script..")
    $strScript = "" ;script section
    $strConfig = "" ;all keys

	Dim $intCounter = 0
	While $intCounter < $limit
		GUICtrlSetData($listScript, "")
		GUICtrlSetData($listScript, "~Farm Slime Data~|# of Slimes: " & $intCounter & "/" & $limit)

		If _Sleep(10) Then ExitLoop
		If checkLocations("battle") = 1 Then
			If checkPixelWait($battle_pixelUnavailable, 2) = False Then
				While True ;while there are slimes
					navigate("battle", "catch-mode")
					$tempStr = catch($captures, True, False, True, False)
					If ($tempStr = -1) or ($tempStr = "") Then ExitLoop

					$intCounter += 1

					GUICtrlSetData($listScript, "")
					GUICtrlSetData($listScript, "~Farm Slime Data~|# of Slimes: " & $intCounter & "/" & $limit)
					If $intCounter = $limit Then ExitLoop(2)
				WEnd
					
				If _Sleep(10) Then ExitLoop
				clickPoint($battle_coorAuto, 2, 10)
			Else
				setLog("Out of astrochips, restarting..")
				While True
					ControlSend($hWindow, "", "", "{ESC}")
					If checkLocations("battle-end-exp", "battle-sell", "pause") = 1 Then
						ExitLoop
					EndIf
					
					If _Sleep(500) Then ExitLoop(2)
				WEnd

				clickPoint($battle_coorGiveUp)
				clickPoint($battle_coorGiveUpConfirm)
			EndIf
		EndIf

		If _Sleep(10) Then ExitLoop
		If checkLocations("battle-end-exp", "battle-sell") = 1 Then
			clickPointUntil($game_coorTap, "battle-end")
		EndIf

		If _Sleep(10) Then ExitLoop
		If checkLocations("battle-end") = 1 Then
			clickImage("battle-play-again")
		EndIf
		
		If _Sleep(10) Then ExitLoop
		If checkLocations("map-battle") = 1 Then
			clickPointUntil($map_coorBattle, "battle")
		EndIf

		If _Sleep(10) Then ExitLoop
		If checkLocations("map", "map-stage", "astroleague", "village", "manage", "monsters", "quests") = 1 Then
			If navigate("map") = 1 Then
				enterStage("map-phantom-forest", "normal")
				
				If waitLocation("map-astromon-full", 3) = 1 Then
					setLog("Inventory is full.", 1)
					ExitLoop
				EndIf
			EndIf
		EndIf

		If _Sleep(10) Then ExitLoop
		If checkLocations("map-gem-full", "battle-gem-full") = 1 Then
			If navigate("village", "manage") = 1 Then
				sellGems($imagesUnwantedGems)
			EndIf
		EndIf

		If _Sleep(10) Then ExitLoop
		If checkLocations("battle-astromon-full", "map-astromon-full") = 1 Then 
			setLog("Inventory is full.", 1)
			ExitLoop
		EndIf
	WEnd

    setLog("~~~Finished 'Farm Slime' script~~~", 2)
EndFunc