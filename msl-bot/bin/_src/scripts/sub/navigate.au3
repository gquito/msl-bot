#include-once

#cs 
    Function: Script to navigate locations in MSL game.
    Parameters:
        $sLocation: One of the locations.
        $bForceSurrender: If in battle will surrender the match
        $iAttempt: Number of attempts
    Returns: 
        if success, true
        if fail, false
#ce
Func navigate($sFind, $bForceSurrender = False, $iAttempt = 1)
    Log_Level_Add("navigate")
    Log_Add("Navigating to " & $sFind & ".")

    $sFind = StringStripWS(StringLower($sFind), $STR_STRIPALL)
    Local $iExtended = 0
    While $iAttempt > 0
        $iAttempt -= 1

        Local $hTimer = TimerInit()
        While TimerDiff($hTimer) < $Delay_Navigation_Timeout*1000
            If _Sleep($Delay_Script_Loop) Then ExitLoop(2)

            Local $sCurrent = getLocation()
            If $sFind == $sCurrent Then ExitLoop(2)

            If HandleCommonLocations($sCurrent) Then 
                $iExtended = @extended
                If $iExtended Then 
                    ExitLoop(2)
                EndIf

                ContinueLoop
            EndIf

            Switch getLocation()
                Case "defeat" 
                    clickPoint(getPointArg("battle-give-up"))
                    ContinueLoop
                Case "catch-success"
                    If $bForceSurrender > 0 Then
                        SendBack()
                        ContinueLoop
                    EndIf
                    If $sFind <> "catch-mode" Then ExitLoop(2)
                Case "battle", "battle-auto"
                    If $bForceSurrender > 0 Then
                        clickPoint(getPointArg("battle-pause"))
                        ContinueLoop
                    EndIf
                    If $sFind <> "catch-mode" Then ExitLoop(2)
                Case "pause"
                    If $bForceSurrender > 0 Then
                        clickPoint(getPointArg("battle-give-up"), 5, 200)
                        ContinueLoop
                    EndIf
                    If $sFind <> "catch-mode" Then ExitLoop(2)
                Case "battle-end-exp", "battle-sell", "astroleague-defeat", "astroleague-victory", "champion-defeat", "champion-victory"
                    clickUntil(getPointArg("tap"), "isLocation", "battle-end", 10, 200)
                    ContinueLoop
                Case "battle-sell-item"
                    clickPoint(getPointArg("battle-sell-item-cancel"))
                    clickPoint(getPointArg("battle-sell-item-okay"))
                    ContinueLoop
                Case "unknown"
                    If Mod(Int(TimerDiff($hTimer)/1000)+1, 8) = 0 Then SendBack()
                    If Mod(Int(TimerDiff($hTimer)/1000)+1, 5) = 0 Then clickPoint(getPointArg("tap"))
                    ContinueLoop
            EndSwitch

            Local $sLocation = getLocation()
            If $sFind == $sLocation Then ContinueLoop
            
            ;Handles normal locations
            Switch $sFind
                Case "village"
                    Switch $sLocation
                        Case "battle-end", "pvp-battle-end"
                            clickPoint(getPointArg("battle-end-airship"))
                            If waitLocation("loading,village", 5) Then clickPoint(getPointArg("astroleague-exit"))
                        Case "hourly-reward"
                            clickPoint(getPointArg("get-reward"))
                        Case Else
                            goBack()
                    EndSwitch
                Case "map"
                    Switch $sLocation
                        Case "map-stage"
                            clickPoint(getPointArg("map-stage-close"))
                        Case "battle-end", "pvp-battle-end"
                            clickPoint(getPointArg("battle-end-map"))
                            If waitLocation("loading,map", 5) Then clickPoint(getPointArg("astroleague-exit"))
                        Case "village"
                            clickPoint(getPointArg("village-play"))
                            waitLocation("loading,bingo,unknown,dialogue-skip", 5)
                        Case Else
                            goBack()
                    EndSwitch
                Case "battle-end"
                    Switch $sLocation
                        Case "popup-window", "battle-sell-item"
                            goBack()
                        Case "battle-end-exp", "unknown", "battle-sell"
                            clickPoint(getPointArg("tap"))
                            clickPoint("742,477")
                    EndSwitch
                Case "golem-dungeons"
                    Switch $sLocation
                        Case "map"
                            Local $aPoint = findMap("Ancient Dungeon")
                            If isArray($aPoint) > 0 Then 
                                clickPoint($aPoint)
                                waitLocation("colossus-dungeons", 5)
                            EndIf
                        Case "colossus-dungeons"
                            clickPoint("200,250")
                            waitLocation("golem-dungeons", 5)
                        Case "map-battle", "autobattle-prompt", "dialogue", "monsters-astromon", "popup-window"
                            goBack()
                        Case Else
                            If navigate("map", $bForceSurrender) = 0 Then ExitLoop
                    EndSwitch
                Case "quests"
                    Switch $sLocation
                        Case "village"
                            clickPoint(getPointArg("village-quests"))
                            waitLocation("quests", 5)
                        Case "autobattle-prompt", "popup-window", "dialogue"
                            goBack()
                        Case Else
                            If navigate("village", $bForceSurrender) = 0 Then ExitLoop
                    EndSwitch
                Case "catch-mode"
                    Switch $sLocation
                        Case "battle", "battle-auto", "catch-success", "unknown"
                            Local $aPixels = getPixelArg("catch-mode-available")
                            Local $aPoint = getPointArg("battle-catch")
                            If isPixel($aPixels, 30) = True Then
                                clickWhile($aPoint, "isPixel", CreateArr($aPixels, 30), 10, 300, "CaptureRegion()")
                            Else
                                If isArray(findImage("misc-no-astrochips", 90, 0, 625, 50, 799-625, 329-100)) = True Then ExitLoop
                            EndIf
                        Case "pause"
                            clickPoint(getPointArg("battle-continue"))
                        Case "battle-end-exp", "battle-sell", "battle-sell-item", "battle-end"
                            ExitLoop
                        Case Else
                            goBack()
                    EndSwitch
                Case "monsters"
                    Switch $sLocation
                        Case "village"
                            clickPoint(getPointArg("village-monsters"))
                        Case "battle-end", "pvp-battle-end"
                            clickPoint(getPointArg("battle-end-monsters"))
                        Case "monsters-level-up", "manage", "monsters-evolution", "awakened-success"
                            clickPoint(getPointArg("manage-x"))
                        Case "popup-window", "monsters-astromon", "monsters-awaken", "monsters-evolve", "gem-upgrade-not-upgrading", _
                                "gem-consecutive-upgrades", "release-confirm", "release-reward"
                            goBack()
                        Case Else
                            If navigate("village", $bForceSurrender) = 0 Then ExitLoop
                    EndSwitch
                Case "manage"
                    Switch $sLocation
                        Case "monsters"
                            clickPoint(getPointArg("monsters-manage"))
                        Case "gem-upgrade-not-upgrading", "gem-consecutive-upgrades"
                            goBack()
                        Case "popup-window"
                            If isPixel("748,151,0xFFD428", 10, CaptureRegion()) > 0 Then
                                clickPoint(CreateArr(362, 117))
                            Else
                                ContinueCase
                            EndIf
                        Case Else
                            If navigate("monsters", $bForceSurrender) = 0 Then ExitLoop
                    EndSwitch
                Case "dungeons"
                    Switch $sLocation
                        Case "guardian-dungeons", "starstone-dungeons", "elemental-dungeons", "special-guardian-dungeons", "gold-dungeons", "extra-dungeons", "dungeon-info", "clan-dungeons"
                            $sFind = $sLocation
                        Case "map"
                            Local $aPoint = findMap("Dungeons")
                            If isArray($aPoint) Then 
                                clickWhile($aPoint, "isLocation", "map", 3, 1000)
                                clickPoint("105,180", 3)
                            EndIf
                        Case "map-battle", "popup-window", "autobattle-prompt"
                            goBack()
                        Case Else
                            If navigate("map", $bForceSurrender) = 0 Then ExitLoop
                    EndSwitch
                Case "elemental-dungeons"
                    Switch $sLocation
                        Case "starstone-dungeons", "extra-dungeons" ,"guardian-dungeons", "special-guardian-dungeons", "gold-dungeons", "dungeon-info", "clan-dungeons"
                            Local $sFound = findImage("level-dungeon-" & $Farm_Starstone_Special_Dungeon, 90, 0, 70, 127, 276-70, 475-127)
                            If isArray($sFound) Then
                                clickPoint($sFound, 2)
                                waitlocation("elemental-dungeons", 2)
                            Else
                                If isArray(findImage("level-dungeon-info", 90, 0, 70, 127, 276-70, 475-127)) Then
                                    $sFound = findImage("level-dungeon-elemental", 90, 0, 70, 127, 276-70, 475-127)
                                    If isArray($sFound) Then
                                        clickPoint($sFound, 2)
                                        waitlocation("elemental-dungeons", 2)
                                    Else
                                        ExitLoop ;Not found.
                                    EndIf
                                Else
                                    clickDrag($g_aDungeonsSwipeUp)
                                EndIf
                            EndIf
                        Case Else
                            If navigate("dungeons", $bForceSurrender) = 0 Then ExitLoop
                    EndSwitch
                Case "guardian-dungeons", "starstone-dungeons", "special-guardian-dungeons", "gold-dungeons", "clan-dungeons", "extra-dungeons"
                    Switch $sLocation
                        Case "starstone-dungeons", "extra-dungeons" ,"guardian-dungeons", "elemental-dungeons", "special-guardian-dungeons", "gold-dungeons", "dungeon-info", "clan-dungeons"
                            Local $sFound = findImage("level-" & $sFind, 90, 0, 70, 127, 276-70, 475-127) 
                            If isArray($sFound) Then
                                clickPoint($sFound, 2)
                                waitlocation($sFind, 2)
                            Else
                                If isArray(findImage("level-dungeon-info", 90, 0, 70, 127, 276-70, 475-127)) Then ExitLoop ;Not found
                                clickDrag($g_aDungeonsSwipeUp)
                            EndIf
                        Case Else
                            If navigate("dungeons", $bForceSurrender) = 0 Then ExitLoop
                    EndSwitch
                Case "expedition"
                    Switch $sLocation
                        Case "village"
                            Local $iVillage = getVillagePos()
                            If $iVillage = -1 Or $g_aExpeditionPos[$iVillage] = -1 Then
                                navigate("map", $bForceSurrender)
                                ContinueLoop
                            Else
                                clickPoint($g_aExpeditionPos[$iVillage])
                                waitLocation("expedition", 3)
                            EndIf
                        Case "popup-window", "expedition-explore"
                            goBack()
                        Case Else
                            If navigate("village", $bForceSurrender) = 0 Then ExitLoop
                    EndSwitch
                Case "inbox"
                    Switch $sLocation
                        Case "village"
                            Local $aInbox = findImage("misc-inbox", 90, 0, 0, 180, 60, 40)
                            If isArray($aInbox) > 0 Then
                                clickPoint(getPointArg("tab-inbox"))
                            Else
                                clickPoint(getPointArg("tab-expand"))
                            EndIf
                        Case "friend-gifts"
                            clickPoint(getPointArg("inbox-inbox"))
                        Case Else
                            If navigate("village", $bForceSurrender) = 0 Then ExitLoop
                    EndSwitch
                Case "friend-gifts"
                    Switch $sLocation
                        Case "inbox"
                            clickPoint(getPointArg("inbox-friend-gifts"))
                        Case Else
                            If navigate("inbox", $bForceSurrender) = 0 Then ExitLoop
                    EndSwitch
                Case Else
                    Log_Add($sFind & " is not navigable.", $LOG_ERROR)
                    ExitLoop
            EndSwitch
        WEnd
    WEnd

    Local $bOutput = (getLocation() == $sFind)
    Log_Add("Navigating result: " & $bOutput, $LOG_DEBUG)
    Log_Level_Remove()
    Return SetExtended($iExtended, $bOutput)
EndFunc