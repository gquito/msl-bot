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
				clickImageUntil("map-dungeons", "starstone-dungeons", 50)
				clickPointUntil($map_coorGuardianDungeons, "guardian-dungeons")
			Case "golem-dungeons"
				clickImageUntil("map-dungeons", "starstone-dungeons", 50)
				clickPointUntil($map_coorGolemDungeons, "golem-dungeons")
			;battle
			Case "catch-mode"
				If checkPixel($battle_pixelUnavailable) = True Then Return 0
				clickPointUntil($battle_pixelUnavailable, "catch-mode")
			Case ""
				Return 1
			Case Else
				MsgBox(0, $botName & " " & $botVersion, "Unknown location.")
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
				If ($strMainLocation = "battle") Then ExitLoop
				While waitLocation("pause", 1) = 0
					ControlSend($hWindow, "", "", "{ESC}")
				WEnd

				clickPoint($battle_coorGiveUp)
				clickPoint($battle_coorGiveUpConfirm)
			EndIf

			If checkLocations("dialogue") = 1 Then
				clickPoint($game_coorDialogueSkip)
			EndIf

			Switch $strMainLocation
				Case "village"
					If checkLocations("unknown") = 0 Then
						clickPoint($game_coorTap, 5)
						ControlSend($hWindow, "", "", "{ESC}")

						Local $closePoint = findImageFiles("misc-close", 30)
						If isArray($closePoint) Then
							clickPoint($closePoint) ;to close any windows open
						EndIf
					EndIf

					If getLocation() = "battle-end" Then clickPoint($battle_coorAirship)
				Case "map"
					If getLocation() = "village" Then
						Local $startTime = TimerInit()
						While checkLocations("village", "unknown") = 1
							clickPoint($village_coorPlay)

							Local $closePoint = findImageFiles("misc-close", 30)
							If isArray($closePoint) Then
								clickPoint($closePoint) ;to close any windows open
							EndIf

							If TimerDiff($startTime) > 60000 Then Return 0 ;if exceed 1 minute
						WEnd
					Else
						ControlSend($hWindow, "", "", "{ESC}")
						waitLocation("map", 1)
					EndIf

					If getLocation() = "battle-end" Then clickPoint($battle_coorMap)
				Case "battle"
					Return waitLocation("battle", 3)
				Case Else
					setLog("Unknown main location: " & $strMainLocation & ".")
			EndSwitch
			If waitLocation($strMainLocation, 1) = 1 Then ExitLoop
		WEnd
		navigate($strMainLocation, $strLocation)
	EndIf

	If $strLocation = "" And $strMainLocation = getLocation() Then Return 1
	If $strLocation = getLocation() Then Return 1
EndFunc