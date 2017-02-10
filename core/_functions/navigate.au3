#cs ----------------------------------------------------------------------------

 Function: navigate

 Navigate through GUI in the game.

 Parameter:

	strMainLocation - Main location to navigate to sub location.

	strLocation - Sub location to navigate to

 Returns:

	On success - Returns 1

	On fail - Returns 0

 See Also:

	<getLocation>

#ce ----------------------------------------------------------------------------

Func navigate($strMainLocation, $strLocation = "")
	Local $strCurrentLocation = getLocation()

	If $strLocation = $strCurrentLocation Then Return 1
	If $strCurrentLocation = $strMainLocation Then
		Switch $strLocation
			;village
			Case "manage"
				clickPointUntil($village_coorMonsters, "monsters")
				clickPointWait($village_coorManage, "monsters")
			Case "quests"
				clickPointUntil($village_coorQuests, "quests")
			;map
			Case "guardian-dungeons"
				clickImageUntil("dungeons", "starstone-dungeons", 50)
				clickPointUntil($map_coorGuardianDungeons, "guardian-dungeons")
			Case "golem-dungeons"
				clickImageUntil("dungeons", "starstone-dungeons", 50)
				clickPointUntil($map_coorGolemDungeons, "golem-dungeons")
			;battle
			Case "catch-mode"
				If checkPixel($battle_pixelUnavailable) = True Then Return 0
				clickPointUntil($battle_pixelUnavailable, "catch-mode")
			Case ""
				Return 1
			Case Else
				MsgBox(0, "MSLBot v3", "Unknown location.")
		EndSwitch

		Return waitLocation($strLocation)
	Else
		If getLocation() = "battle-end-exp" Then
			While (getLocation() = "battle-end") = False
				clickPoint($game_coorTap)
			WEnd
		EndIf

		While True
			If _Sleep(50) Then Return

			If checkLocations("battle") = 1 Then
				While checkLocations("battle-pause") = 0
					ControlSend($hWindow, "", "", "{ESC}")
				WEnd

				clickPoint($battle_coorGiveUp)
				clickPoint($battle_coorGiveUpConfirm)
			EndIf

			Switch $strMainLocation
				Case "village"
					ControlSend($hWindow, "", "", "{ESC}")
					If getLocation() = "battle-end" Then clickPoint($battle_coorAirship)
				Case "map"
					If getLocation() = "village" Then
						While checkLocations("village", "unknown") = 1
							clickPoint($village_coorPlay)
						WEnd
					Else
						ControlSend($hWindow, "", "", "{ESC}")
						waitLocation("map", 3)
					EndIf

					If getLocation() = "battle-end" Then clickPoint($battle_coorMap)
				Case "battle"
					If Not(getLocation() = "battle") Then Return 0
				Case Else
					setLog("Unknown main location: " & $strMainLocation & ".")
					;btnStart_Click()
			EndSwitch
			If waitLocation($strMainLocation, 1) = 1 Then ExitLoop
		WEnd
		navigate($strMainLocation, $strLocation)
	EndIf

	If $strLocation = "" And $strMainLocation = getLocation() Then Return 1
	If $strLocation = getLocation() Then Return 1
EndFunc