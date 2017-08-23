#cs
	Function: hatchEgg
	Calls hatchEggMain with config settings

	Author: Shimizoki (2017)
#ce
Func hatchEgg()
	setLog("~~~Starting 'Hatch Egg' script~~~", 2)
	hatchEggMain()
	setLog("~~~Finished 'Hatch Egg' script~~~", 2)
EndFunc   ;==>farmGolem

Func hatchEggMain()

	Local $intStartTime = TimerInit()
	Local $runCount = 0
	
	While True
		If _Sleep(50) Then ExitLoop

		Local $currLocation = getLocation()

		antiStuck("map")
		Switch $currLocation
				
			Case "village"
				clickUntil($village_coorSummon, "summon-fusion")
				
			Case "summon-fusion", "summon-rebirth", "summon-soulstones", "summon-astral"
				clickUntil($summon_coorIncubators, "summon-incubators")
				
			Case "map", "astroleague", "map-stage", "toc", "association", "clan", "starstone-dungeons", "golem-dungeons", "elemental-dungeons", "quests"
				navigate("map", "village")
				
			Case "summon-incubators"
				$pointArray = findImage("shop-egg", 100, 1000, 150, 160, 530, 500)
				If isArray($pointArray) = True Then
					If setLog("Found Egg...", 1) Then ExitLoop
					clickPoint($pointArray)
					If _Sleep(100) Then ExitLoop
					clickPoint("645,465")
				Else
					If setLog("Could not find egg...", 1) Then ExitLoop
					ExitLoop
				EndIf
				
			Case "incubators-hatch-confirm"
					clickPoint($game_coorRefillConfirm)
					
			Case "incubators-hatch-success"
				If _Sleep(100) Then ExitLoop
				clickPoint("645,105")
				If _Sleep(2000) Then ExitLoop
				
			Case "incubators-inventory-full"
				If setLog("Inventory Full... Exiting!", 1) Then ExitLoop
				clickPoint("375,310")
				If _Sleep(100) Then ExitLoop
				ControlSend($hWindow, "", "", "{ESC}")
				ExitLoop
				
			Case "pause"
				clickPoint($battle_coorContinue, 1, 2000)
				
			Case "unknown"
				clickPoint($game_coorTap)
				;clickPoint(findImage("misc-close", 30)) ;to close any windows open
				
			Case "lost-connection"
				clickPoint($game_coorConnectionRetry)
		EndSwitch
	WEnd
EndFunc   ;==>farmGolemMain
