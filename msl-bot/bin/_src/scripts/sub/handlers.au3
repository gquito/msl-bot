#include-once

Func HandleCommonLocations($sCurrLocation)
    ;Log_Add("Handling Common Locations. Curr Location = " & $sCurrLocation, $LOG_DEBUG)
    Switch ($sCurrLocation)
        Case "tap-to-start"
            clickPoint(getPointArg("tap-to-start"))
            waitLocation("event-list", 5)
            Return True
        Case "event-list"
            clickPoint(getPointArg("event-list-close"))
            waitLocation("village", 5)
            Return True
        case "super-fest-popup", "village-summon", "anvil"
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
        Case "app-maintenance"
            appMaintenance()
            Return True
        Case "app-update"
            appUpdate()
            Return True
        Case "another-device0"
            anotherDevice()
            Return True
        Case "dragon-dungeons-popup", "dragon-astral-essence", "exotic-ticket-claim"
            clickWhile(getPointArg("tap"), "isLocation", $sCurrLocation, 10, 1000)
        Case "monsters"
            clickUntil(getPointArg("monsters-grid"), "isPixel", CreateArr("133,30,0xF6C02A"), 5, 200, "CaptureRegion()")
            clickUntil(getPointArg("monsters-recent"), "isPixel", CreateArr("265,473,0x45F5A7"), 5, 200, "CaptureRegion()")
        Case "association-expedition"
            clickPoint("698,380")
        Case "map-limit"
            clickPoint(findImage("misc-ok"))
            SendBack()
    EndSwitch
    Return False
EndFunc