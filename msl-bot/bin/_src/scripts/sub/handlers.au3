#include-once

Func HandleAppUpdate()
	If (isLocation("app-update")) Then
		Log_Add("App update found. Updating from google play.", $LOG_DEBUG)
		If (clickUntil(getPointArg("app-update"), "isLocation", "play-store-update", 5, 2000)) Then
			If (clickUntil(getPointArg("play-store-update"), "isLocation", "play-store-updating", 5, 2000)) Then
				If (waitLocation("play-store-open", 600)) Then 
					clickPoint(getPointArg("play-store-open"))
					_Sleep(3000)
				EndIf
			EndIf
		EndIf
	EndIf

	If (isLocation("data-update-download")) Then
		Log_Add("App data update found. Updating data.", $LOG_DEBUG)
		clickPoint(getPointArg("app-data-download"))
		waitLocation("tap-to-start",600)
	EndIf
EndFunc

Func HandleCommonLocations($sCurrLocation)
    ;Log_Add("Handling Common Locations. Curr Location = " & $sCurrLocation, $LOG_DEBUG)
    Switch ($sCurrLocation)
        Case "tap-to-start"
            If (Not(clickWhile(getPointArg("tap-to-start"), "isLocation", "tap-to-start", 10, 2000))) Then 
                Log_Add("Emulator is not detecting the commands. Restarting Emulator.", $LOG_ERROR)
                RestartNox(1, "")
            EndIf
            Return True
        Case "event-list"
            If (Not(clickUntil(getPointArg("event-list-close"), "isLocation", "loading,unknown", 10, 2000))) Then Return False
            Return True
        case "super-lab", "super-fest-popup", "village-summon", "anvil"
            clickPoint(getPointArg("back"))
            Return True
        Case "view-clan-popup", "master-info", "player-info", "toc-mon-info", "hero-fest-popup", "quit", "login-event", "monster-super-evolution", "popup-window", "summon-astromon-popup", "boutique"
            closeWindow()
            Return True
        Case "dialogue-skip"
            skipDialogue()
            Return True
        Case "loading"
            _Sleep(100)
            Return True
        Case "app-update","data-update-download","app-maintenance"
            RestartGame()
            Return True
        Case "dragon-dungeons-popup", "dragon-astral-essence", "exotic-ticket-claim"
            clickWhile(getPointArg("tap"), "isLocation", $sCurrLocation, 10, 1000)
        Case "monsters"
            clickUntil(getPointArg("monsters-grid"), "isPixel", CreateArr("133,30,0xF6C02A"), 5, 200, "CaptureRegion()")
            clickUntil(getPointArg("monsters-recent"), "isPixel", CreateArr("265,473,0x45F5A7"), 5, 200, "CaptureRegion()")
        Case "association-expedition"
            clickPoint("698,380")
    EndSwitch
    Return False
EndFunc