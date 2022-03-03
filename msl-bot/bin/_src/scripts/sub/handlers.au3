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
        Case "super-fest-popup"
            clickPoint(getPointArg("back"))
            Return True
        Case "view-clan-popup", "master-info", "player-info", "toc-mon-info", _ 
             "hero-fest-popup", "quit", "login-event", "monster-super-evolution", _ 
             "summon-astromon-popup", "boutique"
            closeWindow()
            Return True
        Case "dialogue-skip"
            skipDialogue()
            Return True
        Case "loading"
            _Sleep(100)
            Return True
        Case "app-maintenance"
            Return SetExtended(1, True)
        Case "app-update", "app-update-ok"
            Return SetExtended(2, True)
        Case "another-device"
            anotherDevice()
            Return True
        Case "dragon-dungeons-popup", "dragon-astral-essence", "exotic-ticket-claim", "summoned-astromon"
            clickPoint(getPointArg("tap"))
            Return True
        Case "monsters"
            clickUntil(getPointArg("monsters-grid"), "isPixel", CreateArr("133,30,0xF6C02A"), 5, 200, "CaptureRegion()")
            clickUntil(getPointArg("monsters-recent"), "isPixel", CreateArr("265,473,0x45F5A7"), 5, 200, "CaptureRegion()")
        Case "map-limit"
            clickPoint(findImage("misc-ok"))
            SendBack()
        Case "catch-mode"
            _Sleep(500)
            CaptureRegion()
        Case "titans"
            Return (waitLocation("roll-call", 3) = True)
    EndSwitch
    Return False
EndFunc