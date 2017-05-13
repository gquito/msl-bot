#cs ----------------------------------------------------------------------------
 Function: antiStuck
 Checks for stuck locations and unstucks

 Parameter:
	strUnstuckLocation - Location to navigate to when the bot gets stuck

 Returns: (boolean) If stuck and been unstuck then return true, else return false
#ce ----------------------------------------------------------------------------

Func antiStuck($strMainLocation)
	Local $currLocation = getLocation()

	If $currLocation = $globalStuckLocation Then
		If TimerDiff($globalStuckTimer) > 600000 Then
			If setLog("Been stuck for 10 minutes! Navigating to " & $strMainLocation & ".", 1) Then Return -1
			$globalStuckLocation = ""
			$globalStuckTimer = TimerInit()
			navigate($strMainLocation, "", True)
			Return True
		EndIf
	Else
		$globalStuckLocation = $currLocation
		$globalStuckTimer = TimerInit()
	EndIf

	If $currLocation = "error" Then
		clickPoint("485,338", 10)
	EndIf

	If $currLocation = "not-in-game" Then
		If setLog("Not in game! Navigating to " & $strMainLocation & ".", 2) Then Return -1
		Local $gameIcon = findImage("misc-game-icon")

		If IsArray($gameIcon) Then
			clickUntil($gameIcon, "unknown")
		Else
			If setLog("Could not locate game icon, using default game icon location..") Then Return -1
			clickUntil("667,273", "unknown")
		EndIf

		If waitLocation("start-screen", 120000) = "start-screen" Then
			clickWhile("394,468", "start-screen", 100, 1000)
		EndIf

		If waitLocation("event", 100000) = "event" Then
			clickUntil("742,530", "event-list", 20, 1000)
		EndIf

		If waitLocation("event-list", 100000) = "event-list" Then
			clickPoint("777,20", 10)
		EndIf

		$globalStuckLocation = ""
		$globalStuckTimer = TimerInit()
		navigate($strMainLocation, "", True)
		Return True
	EndIf

	Return False
EndFunc

