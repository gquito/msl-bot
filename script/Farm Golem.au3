;function: farmGolem
;-Automatically farms golem and gives information
;pre:
;   -config must be set for script
;   -required config keys: map, capture, guardian-dungeon
;author: GkevinOD
Func farmGolem()
	;beginning script
    setLog("*Loading config for Farm Golem.", 2)

    Dim $strGolem = Int(IniRead(@ScriptDir & "/config.ini", "Farm Golem", "dungeon", 7))
    Dim $intGoldEnergy  = 12244
    Dim $intGolem = 7
    Switch($strGolem)
        Case 1 To 3
            $intGolem = 5
        Case 4 To 6
            $intGolem = 6
        Case 7 To 9
            $intGolem = 7
        Case 10
            $intGolem = 8
    EndSwitch

    Dim $intSellGradeMin = Int(IniRead(@ScriptDir & "/config.ini", "Farm Golem", "sell-grade-min", 4))
    Dim $intKeepGradeMinSub = Int(IniRead(@ScriptDir & "/config.ini", "Farm Golem", "keep-grade-min-sub", 5))
    Dim $intMinSub = Int(IniRead(@ScriptDir & "/config.ini", "Farm Golem", "min-sub", 4))
    Dim $intEnergy = Int(IniRead(@ScriptDir & "/config.ini", "Farm Golem", "current-energy", 1000))
    Dim $intGold = Int(IniRead(@ScriptDir & "/config.ini", "Farm Golem", "current-gold", 1000000))
    Dim $intStartTime = TimerInit()
    Dim $intGoldPrediction = 0
    Dim $intRunCount = 0
    Dim $intTimeElapse = 0
    Dim $getHourly = False

    setLog("~~~Starting 'Farm Golem' script~~~", 2)
    While True
        If _Sleep(10) Then ExitLoop
        $intTimeElapse = Int(TimerDiff($intStartTime)/1000)

        If StringSplit(_NowTime(4), ":", 2)[1] = "00" Then $getHourly = True

        Dim $strData = "# of Run: " & $intRunCount & ".|Predicted Profit: " & StringRegExpReplace(String($intGoldPrediction), "(\d)(?=(\d{3})+$)", "$1,") & "|Predicted Gold: " & StringRegExpReplace(String($intGold+$intGoldPrediction), "(\d)(?=(\d{3})+$)", "$1,") & "|Current Energy: " & ($intEnergy-($intRunCount*$intGolem)) & "|Total Time Elapse: " & StringFormat("%.2f", $intTimeElapse/60) & " Min." & "|Average Time Per Run: " & StringFormat("%.2f", $intTimeElapse/$intRunCount/60) & " Min." & "|Predicted No-Energy In: " & StringFormat("%.2f", $intTimeElapse/$intRunCount*(($intEnergy-($intRunCount*$intGolem))/$intGolem)/60) & " Min."

        GUICtrlSetData($listScript, "")
		GUICtrlSetData($listScript, $strData)

        If checkLocations("battle-end") = 1 Then
            If $getHourly = True Then
                getHourly()
                $getHourly = False
            Else
                clickImageUntil("battle-quick-restart", "battle")
                $intRunCount += 1
            EndIf
        EndIf

        If checkLocations("map", "village", "astroleague", "map-stage", "map-battle") = 1 Then
            If navigate("map", "golem-dungeons") = 1 Then
                clickPointUntil(Eval("map_coorB" & $strGolem), "map-battle")
                clickPointUntil($map_coorBattle, "battle")

                $intRunCount += 1
            Else
                setLog("Unable to navigate to dungeon.")
                ExitLoop
            EndIf
        EndIf

        If checkLocations("battle-end-exp") = 1 Then
            clickPoint($game_coorTap)
            While waitLocation("battle-sell", 3) = 0
                clickPoint($game_coorTap)
            WEnd
            If _Sleep(10) Then ExitLoop
            If StringInStr(sellGem("B" & $strGolem, $intSellGradeMin, True, 6, $intKeepGradeMinSub, $intMinSub)[6], "!") Then
                $intGoldPrediction += $intGoldEnergy
            EndIf
        EndIf

        If _Sleep(10) Then ExitLoop
        If checkLocations("battle-gem-full") = 1 Then
            setLog("Gem inventory is full!")
            ExitLoop
        EndIf

        If _Sleep(10) Then ExitLoop
        If checkLocations("defeat") = 1 Then
            clickImage("battle-give-up")
            clickPointUntil($game_coorTap, "battle-end", 20, 1000)
        EndIf

        If _Sleep(10) Then ExitLoop
        If checkLocations("lost-connection") = 1 Then
            clickPoint($game_coorConnectionRetry)
        EndIf
    WEnd

    setLog("~~~Finished 'Farm Golem' script~~~", 2)
EndFunc