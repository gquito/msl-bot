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

    While $iAttempt > 0
        $iAttempt -= 1

        Local $hTimer = TimerInit()
        While TimerDiff($hTimer) < $Delay_Navigation_Timeout*1000
            If $sFind == getLocation() Or _Sleep(300) Then ExitLoop(2)
            If HandleCommonLocations(getLocation()) > 0 Then ContinueLoop
                
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
                        clickWhile(getPointArg("battle-give-up"), "isLocation", "pause,unknown,popup-window", 60, 500)
                        ContinueLoop
                    EndIf
                    If $sFind <> "catch-mode" Then ExitLoop(2)
                Case "battle-end-exp", "battle-sell", "astroleague-defeat", "astroleague-victory", "champion-defeat", "champion-victory"
                    clickWhile(getPointArg("tap"), "isLocation", "battle-end-exp,battle-sell,astroleague-defeat,astroleague-victory,champion-defeat,champion-victory,unknown", 100, 100)
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
                                waitLocation("ancient-colossus-dungeon", 5)
                            EndIf
                        Case "ancient-colossus-dungeon"
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
                    If isArray(findImage("misc-no-astrochips")) > 0 Then ExitLoop
                    
                    Switch $sLocation
                        Case "battle-auto"
                            Local $aRound = getRound()
                            clickBattle()
                            clickPoint(getPointArg("battle-catch"))

                            If waitLocation("unknown,catch-mode,battle", 5, False) == "unknown" Then
                                Local $aRound2 = getRound()
                                If isArray($aRound) > 0 And isArray($aRound2) > 0 Then
                                    If $aRound[0] <> $aRound2[0] Then
                                        waitLocation("battle-auto,battle", 5)
                                        clickPoint(getPointArg("battle-catch"))
                                        waitLocation("catch-mode", 5)
                                    EndIf
                                EndIf
                            EndIf
                        Case "battle", "catch-success"
                            clickPoint(getPointArg("battle-catch"))
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
                        Case "guardian-dungeons", "starstone-dungeons", "elemental-dungeons", "special-guardian-dungeons", "gold-dungeons", "extra-dungeons", "dungeon-info"
                            If $sLocation == "special-guardian-dungeons" Then clickDrag($g_aDungeonsSwipeDown)
                            $sFind = $sLocation
                        Case "map"
                            Local $aPoint = findMap("Dungeons")
                            If isArray($aPoint) Then 
                                clickPoint($aPoint)
                                waitLocation("startstone-dungeons,extra-dungeons", 2)
                            EndIf
                        Case "map-battle", "popup-window", "autobattle-prompt"
                            goBack()
                        Case Else
                            If navigate("map", $bForceSurrender) = 0 Then ExitLoop
                    EndSwitch
                Case "guardian-dungeons", "starstone-dungeons", "elemental-dungeons", "special-guardian-dungeons", "gold-dungeons"
                    Switch $sLocation
                        Case "starstone-dungeons", "extra-dungeons"
                            Local $aPoint = StringSplit(getPointArg("dungeons-" & StringSplit($sFind, "-", 2)[0]), ",", 2)
                            If $sLocation == "extra-dungeons" Then $aPoint[1] += 64

                            Switch $sFind
                                Case "special-guardian-dungeons"
                                    clickDrag($g_aDungeonsSwipeUp)
                                    If _Sleep(1000) Then ExitLoop

                                    $aPoint = findImage("map-special-dungeon",95,0,70,335,215,150,True,True)

                                    If isArray($aPoint) = 0 Then ExitLoop
                                    clickPoint($aPoint)
                                Case Else
                                    clickPoint($aPoint)
                            EndSwitch
                        Case "guardian-dungeons", "elemental-dungeons", "special-guardian-dungeons", "gold-dungeons", "dungeon-info"
                            clickPoint(getPointArg("dungeons-starstone"))
                        Case Else
                            If navigate("dungeons", $bForceSurrender) = 0 Then ExitLoop
                    EndSwitch
                Case Else
                    Log_Add($sFind & " is not navigable.", $LOG_ERROR)
                    ExitLoop
            EndSwitch
        WEnd
    WEnd

    Local $bOutput = (getLocation() = $sFind)
    Log_Add("Navigating result: " & $bOutput, $LOG_DEBUG)
    Log_Level_Remove()
    Return $bOutput
EndFunc