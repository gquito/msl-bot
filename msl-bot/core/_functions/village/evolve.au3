#cs ----------------------------------------------------------------------------
 Function: evolve
 Evolve an astromon to evo3 assuming all evo1 materials are available.

 Pre: Must have all other 15 evo1 to feed.

 Parameters:
 monster: Image of evo1 monster.

 Return: (Boolean) On error return False. Success return True
 Author: GkevinOD (2017)
#ce ----------------------------------------------------------------------------

Func evolve($monster)

	Local $monInfo = getAstromonInfo($monster)
	Local $imageName = $monInfo[$ASTROMON_INFO_IMAGE]
	Local $map = $monInfo[$ASTROMON_INFO_MAP]
	Local $stage = $monInfo[$ASTROMON_INFO_STAGE]
	Local $difficulty = $monInfo[$ASTROMON_INFO_DIFFICULTY]
	
	
	Local $numEvo1Needed = 0
	Local $numEvo2Needed = 0
	Local $numTotalNeeded = 0
	
	Local $logBaseStr = "Evolving " & $monster & "..."
	If setLogReplace($logBaseStr, 2) Then Return -1
	
	; Navigate to monsters
	If navigate("village", "monsters", True) = False Then
		If setLog("Error: Could not go into monsters!", 1) Then Return -1
		Return False
	EndIf

	;setting up recent and icon list
	clickPoint("133, 22", 3, 100)
	clickPoint("265, 469", 3, 100)

	; Evolve 4 evo2 mons
	For $i=0 To 3
		Local $evolveResult = evolveMon($monster)
		If $evolveResult == False Then Return False
		$numEvo1Needed += $evolveResult
		
		If $numEvo1Needed <> 0 Then
			If _Sleep(10) Then Return -1
			navigate("village") ;going back to monsters
			navigate("village", "monsters") ;going back to monsters
			ExitLoop
		EndIf
		
		; Get Quest and return to monsters
		getQuest()
		If _Sleep(10) Then Return -1
		navigate("village", "monsters")
	Next
	$numTotalNeeded = $numEvo1Needed
	
	Local $evolveResult = evolveMon($monster & "x")
	If $evolveResult == False Then Return False
	$numEvo2Needed = $evolveResult
	If $numEvo2Needed == 0 Then
	
		clickPoint("776, 111", 3) ;click x
		If _Sleep(100) Then Return -1

		; Releasing Evo3
		_CaptureRegion()
		If checkPixels("356,131,0xCEC9C5|357,127,0xD9D4D0|357,124,0xA09D9A|360,129,0xDDD9D4") = True Then
			If setLogReplace($logBaseStr & "Releasing " & $monster, 1) Then Return -1
			clickUntil("647,459", "unknown")
			clickUntil("319,334", "monsters")
		Else
			If setLog("Could not detect evo3 " & $monster & ", unable to release", 1) Then Return -1
		EndIf
		
		; Get Quest
		getQuest()
		If _Sleep(10) Then Return -1
		navigate("village")
		If setLogReplace($logBaseStr & "Done!", 1) Then Return -1
		
		; Reset the counter because an evo3 was made
		$numTotalNeeded = 0
	Else
		If $numEvo1Needed == 0 Then
			If setLogReplace($logBaseStr & "Unable to find " & $numEvo2Needed & "expected evo2 astromon!", 1, $LOG_WARN) Then Return -1
		EndIf
		
		; Inform the user that more astromon are needed if we were unable to evo3 the mon
		$numTotalNeeded += (4 * ($numEvo2Needed - 1))
		If setLogReplace($logBaseStr & "Need to catch " & $numTotalNeeded & " evo1 astromon to finish an evo3!", 1) Then Return -1
	EndIf
	
	Return $numTotalNeeded
EndFunc

Func evolveClickMon($monster)
	Local $logBaseStr = "Evolving " & $monster & "..."
	If setLogReplace($logBaseStr & "Searching", 1) Then Return -1

	Local $timerStart = TimerInit()
	Local $monEvo = findImage("monster-" & $monster, 100, 1000, 9, 101, 292, 449)
	While IsArray($monEvo) = False
		ControlSend($hWindow, "", "", "{RIGHT}")
		If _Sleep(500) Then Return -1

		If TimerDiff($timerStart) > 45000 Then Return False ;45 Seconds
		$monEvo = findImage("monster-" & $monster, 100, 500, 9, 101, 292, 449)
	WEnd
	
	If setLogReplace($logBaseStr & "Found!", 1) Then Return -1
	clickPoint($monEvo) ;click monster
	
	If _Sleep(10) Then Return -1
	clickUntil("600, 391", "monsters-evolution")
		
	Return True
EndFunc

Func monsNeededToEvo()
	Local $count = 0
	
	Local $empty1stSlot = [458, 182, 0x7D624D]
	Local $empty2ndSlot = [520, 182, 0x7D624D]
	Local $empty3rdSlot = [583, 182, 0x7D624D]
		
	_CaptureRegion()
	If checkPixel($empty1stSlot) Then 
		$count = 3
	ElseIf checkPixel($empty2ndSlot) Then
		$count = 2
	ElseIf checkPixel($empty3rdSlot) Then
		$count = 1
	EndIf
	
	Return $count
EndFunc

Func evolveMon($monster)
	If Not evolveClickMon($monster) Then Return 4
		
	Local $logBaseStr = "Evolving " & $monster & "..."
	If setLogReplace($logBaseStr & "Awakening", 1) Then Return -1
		
	Local $numMonsNeeded = 0 	
	
	; While mons are still needed to evo
	While True
		If _Sleep(100) Then Return -1
		
		$numMonsNeeded = monsNeededToEvo()
		If $numMonsNeeded == 0 Then ExitLoop
	
		; Search for an available mon and use it, if no mon is found, exit
		Local $evoMon = findImage("monster-" & $monster, 100, 100, 314, 298, 772, 363)
		If isArray($evoMon) Then
			If _Sleep(100) Then Return -1
			clickPoint($evoMon) 			;click to awaken
			clickPoint("574, 223", 3, 50) 	;click ex just in case it is already awakened

			;TODO: Handle pre-awakened mons
		Else
			If setLog($logBaseStr & "Missing " & $numMonsNeeded & "!", 1, $LOG_WARN) Then Return -1
			ExitLoop
		EndIf
	WEnd
	
	If $numMonsNeeded == 0 Then
		; Do Awakening
		If setLogReplace($logBaseStr & "Awakening", 2) Then Return -1
		If _Sleep(10) Then Return -1
		clickUntil("424, 394", "monsters-awaken")

		; Abort if out of gold
		If getLocation() = "buy-gold" Then
			If setLog("Error: Out of gold!", 2) Then Return -1
			Return False
		EndIf

		; Confirm Awakening
		If _Sleep(10) Then Return -1
		clickUntil("308, 316", "monsters-evolution")
		
		; Do Evolution
		If setLogReplace($logBaseStr & "Evolving", 2) Then Return -1
		If _Sleep(10) Then Return -1
		clickUntil("657, 394", "monsters-evolve")

		; Abort if out of gold
		If getLocation() = "buy-gold" Then
			If setLog("Error: Out of gold!", 1) Then Return -1
			Return False
		EndIf

		; Confirm Evolution
		If _Sleep(10) Then Return -1
		clickUntil("308, 316", "unknown")
		
		; Speed through Evolution
		If _Sleep(10) Then Return -1
		clickUntil($game_coorTap, "monsters-astromon", 10, 500)
		
		; Close Dialog
		If _Sleep(100) Then Return -1
		clickPoint("650,100")
		
		logUpdate()
	EndIf
	
	Return $numMonsNeeded
EndFunc