#cs
	Function: farmAstromon
	Calls farmAstromonMain with config settings

	Author: GkevinOD (2017)
#ce
Func farmAstromon()
	Local $monster = IniRead($botConfigDir, "Farm Astromon", "image", Null)
	Local $limit = Int(IniRead($botConfigDir, "Farm Astromon", "limit", 16))
	Local $catchRares = IniRead($botConfigDir, "Farm Astromon", "catch-rares", 1)
	Local $finishRound = IniRead($botConfigDir, "Farm Astromon", "finish-round", 0)
	
	
	;Local $buyEggs = IniRead($botConfigDir, "Farm Astromon", "buy-eggs", 0)
	;Local $buySoulstones = IniRead($botConfigDir, "Farm Astromon", "buy-soulstones", 0)
	;Local $maxGoldSpend = IniRead($botConfigDir, "Farm Astromon", "max-gold-spend", 1000000)
	;
	;Local $quest = IniRead($botConfigDir, "Farm Astromon", "collect-quest", 1)
	;Local $hourly = IniRead($botConfigDir, "Farm Astromon", "collect-hourly", 1)
	;Local $guardian = IniRead($botConfigDir, "Farm Astromon", "guardian-dungeon", 0)

	setLog("~~~Starting 'Farm Astromon' script~~~", 2)
	farmAstromonMain($monster, $limit, $catchRares, $finishRound, 0, 1000)
	setLog("~~~Finished 'Farm Astromon' script~~~", 2)
EndFunc   ;==>farmAstromon




Func farmAstromonMain($monster, $limit, $catchRares, $finishRound, ByRef $gemsUsed, $maxGemRefill)

	Local $quest = 1				; TODO: THIS SHOULD BE PASSED IN
	Local $hourly = 1				; TODO: THIS SHOULD BE PASSED IN
	Local $guardian = 1				; TODO: THIS SHOULD BE PASSED IN
	Local $sellGems = "1,2,3,4,5"	; TODO: THIS SHOULD BE PASSED IN
	Local $buySale = 1				; TODO: THIS SHOULD BE PASSED IN
	Local $buyEggs = 1				; TODO: THIS SHOULD BE PASSED IN
	Local $buySoulstones = 0		; TODO: THIS SHOULD BE PASSED IN
	Local $goldSpent = 0			; TODO: THIS SHOULD BE PASSED IN
	Local $maxGoldSpend = 1000000	; TODO: THIS SHOULD BE PASSED IN
	
	Local $shoppingList = [$buySale, $buySoulstones, $buyEggs]
	Return _farmAstromonMain($monster, $limit, $catchRares, $finishRound, $gemsUsed, $maxGemRefill, $quest, $hourly, $shoppingList, $goldSpent, $maxGoldSpend, $guardian, $sellGems)
EndFunc

#cs
	Function: farmAstromonMain
	Farm a type of astromon in story mode.

	Parameters:
	monster: (String) Image name of astromon to look for. EX: catch-one-star
	limit: (Int) Maximum number of astromons to farm. 0=Farm until max
	catchRares: (Int) 1=True; 0=False
	finishRound: (Int) 1=True; 0=False
	gemsUsed: (variable) Reference to gems used variable
	maxGemRefill: (Int) Max gems to use for refill

	Author: GkevinOD (2017)
#ce
Func _farmAstromonMain($monster, $limit, $catchRares, $finishRound, ByRef $gemsUsed, $maxGemRefill, $quest, $hourly, $shoppingList, $goldSpent, $maxGoldSpend, $guardian, $sellGems)
	
	Local $getHourly = False
	Local $getGuardian = False
	Local $guardianCount = 0
	
	Local $inventoryFull = False	; If the astromon inventory is currently full
	
	Local $roundNumber = [0,0]		; The curround Round Number. [Curruent Round, Total Rounds]
	Local $autoMode = $AUTO_ROUND	; This is to determine at what points auto-battle will be enabled
	Local $runCount = 0
	Local $catchCount = 0
	
	; Astromon attempted catch information
	Local $dataStrCaught = "", $dataStrMissed = "", $displayCaught = "", $displayMissed = ""
	
	; Format the monster and rare lists
	_farmAstromonFormatCaptureList($autoMode, $monster, $catchRares)
	
	; Create capture list consisting of the supplied rares and the monster
	Local $captures[0]
	For $capture In $catchRares
		Local $grade = StringReplace($capture, " ", "-")
		If FileExists(@ScriptDir & "/core/_images/catch/catch-" & $grade & ".bmp") Then
			_ArrayAdd($captures, "catch-" & $grade)
		EndIf
	Next
		
	; Verify monster file exists and add it to captures
	Local $imageName = $monster[$ASTROMON_INFO_IMAGE]
	If $imageName == null Then
		; Do Nothing
		If _Sleep(10) Then Return -1
	ElseIf Not FileExists($strImageDir & StringSplit($imageName, "-", 2)[0] & "\" & $imageName & ".bmp") Then
		setLog("Image file does not exist: " & $imageName, 2, $LOG_ERROR)
	Else
		_ArrayAdd($captures, $imageName)
	EndIf

	;Write out the list of monsters to capture
	setLog("Farming for " & UBound($captures) & " astromon", 1, $LOG_DEBUG)
	For $capture In $captures
		setLog(" - " & $capture, 1, $LOG_DEBUG)
	Next
	
	; Set Limit
	If $limit <= 0 Then
		setLog("*Limit is 0, will farm until inventory is full.", 2)
		$limit = 9999 ;really high number so counter never hits
	EndIf
	
	While $catchCount <= $limit
	
		Local $listDisplay = "Runs: " & $runCount & " (Guardian: " & $guardianCount & ")"
		$listDisplay &= "|Astromons: " & $catchCount & "/" & $limit
		$listDisplay &= "|Caught: " & StringMid($displayCaught, 3)
		$listDisplay &= "|Missed: " & StringMid($displayMissed, 3)
		$listDisplay &= "|Gems Used: " & ($gemsUsed & "/" & $maxGemRefill)
		If setList($listDisplay) Then Return -1
	
		checkTimeTasks($getHourly, $getGuardian, $hourly, $guardian)

		antiStuck("map")
		If _Sleep(100) Then ExitLoop
		
		Local $location = getLocation()
		Switch $location
			Case "battle-auto"
				If Not doAutoBattle($roundNumber, $autoMode) Then
					setLog("Unknown error in Auto-Battle!", 1, $LOG_ERROR)
				EndIf
				
			Case "battle"
				If Not doBattle($autoMode, True) Then
					setLog("Unknown error in Battle!", 1, $LOG_ERROR)
				EndIf
				
			Case "refill"
				; If the number of used gems will not exceed the limit, purchase additional energy
				If Not refilGems($gemsUsed, $maxGemRefill) Then 
					setLog("Unknown error in Gem-Refill!", 1, $LOG_ERROR)
					ExitLoop
				EndIf
				
			Case "battle-end-exp", "battle-sell"
				clickUntil($game_coorTap, "battle-end", 100, 100)

			Case "battle-end"				
				; If the astromon inventory is full, exit
				If $inventoryFull Then
					setLog("Final run due to full inventory.", 1)
					ExitLoop
				EndIf
				
				; If Run end of battle checks and then restart
				If Not doBattleEnd($quest, $getHourly, $shoppingList, $goldSpent, $maxGoldSpend, $getGuardian, $guardianCount, $runCount) Then
					setLog("Unknown error in Battle-End!", 1, $LOG_ERROR)
				EndIf

			Case "battle-astromon-full"
				; If there is no additional space in the astromon bag, finish the round
				setLog("Inventory is full! Finishing battle.", 1)
				clickUntil("400, 300", "battle")
				clickPoint($battle_coorAuto)
				
				$inventoryFull = True
				$autoMode = $AUTO_BATTLE
				
			Case "catch-mode"
				; If there are astromon to be caught, catch them
				Local $catch = catch($captures, True, False)
				If _Sleep(10) Then Return -1
									
				If UBound($catch) = 0 Then
					if $autoMode <> $AUTO_BATTLE Then $autoMode = $AUTO_ROUND
					clickPoint($battle_coorAuto)
					ContinueLoop
				EndIf	
				
				_farmAstromonDisplay($catch, $catchCount, $dataStrMissed, $dataStrCaught , $displayMissed , $displayCaught)
				
				; If the number of astromon is at the supplied limit, exit
				If $catchCount >= $limit Then
					setLog("Finished catching " & $limit & " astromon.", 1)
					ExitLoop
				EndIf
				
			Case "map-battle"
				clickWhile($map_coorBattle, "map-battle")
				
				; Resets auto-mode for the next battle
				If $autoMode <> $AUTO_ALWAYS Then $autoMode = $AUTO_ROUND
				
			Case "map-gem-full", "battle-gem-full"
				If setLogReplace("Gem is full, going to sell gems...", 1) Then ExitLoop
				If navigate("village", "manage") = 1 Then
					sellGems($sellGems)
					If setLogReplace("Gem is full, going to sell gems... Done!", 1) Then ExitLoop
				EndIf
				
			Case "lost-connection"
				clickPoint($game_coorConnectionRetry)

			Case "dialogue"
				clickPoint($game_coorDialogueSkip)

			Case "pause"
				clickPoint($battle_coorContinue, 1, 1000)

			Case "map-astromon-full"
				; If there is no additional space in the astromon bag, Exit
				setLog("Inventory is full!", 1)
				clickPoint(findImage("misc-close", 30)) ;to close any windows open
				ExitLoop
			
			Case "unknown", "catch-success"
				clickPoint($game_coorTap)
				clickPoint(findImage("misc-close", 30)) ;to close any windows open
					
			Case Else
				If $monster[$ASTROMON_INFO_MAP] == null Then
					MsgBox($MB_ICONINFORMATION, $botName & " " & $botVersion, "Enter battle and turn auto off, then click ok.")
				Else
					If setLog("Going into battle from " & $location & ".", 1) Then ExitLoop
					If navigate("map") = True Then
						If enterStage($monster[$ASTROMON_INFO_MAP], $monster[$ASTROMON_INFO_DIFFICULTY], $monster[$ASTROMON_INFO_STAGE], False) = False Then
							If setLog("Error: Could not enter map stage.", 1) Then ExitLoop
						Else
							$runCount += 1
						EndIf
					EndIf
				EndIf
			
		EndSwitch
	WEnd

	If getLocation() = "battle" Then
		clickPoint($battle_coorAuto)
	EndIf

	Return $catchCount
EndFunc   ;==>farmAstromonMain


Func _farmAstromonDisplay($catch, ByRef $counter, ByRef $dataStrMissed, ByRef $dataStrCaught , ByRef $displayMissed , ByRef $displayCaught)
	For $astromon In $catch
		If StringLeft($astromon, 1) = "!" Then ;if missed
			$dataStrMissed &= "," & StringMid($astromon, 2, 2)
		Else ;if caught
			$dataStrCaught &= "," & StringMid($astromon, 1, 2)
			$counter += 1
		EndIf
	Next		
	
	$displayCaught = _farmAstromonTrackerParse($dataStrCaught)
	$displayMissed = _farmAstromonTrackerParse($dataStrMissed)
EndFunc

Func _farmAstromonTrackerParse($dataStr)
	Local $arrayCounter[0]
	For $caught In StringSplit(StringMid($dataStr, 2), ",", 2)
		Local $inTracker = False
		For $i = 0 To UBound($arrayCounter)-1
			If StringLeft($arrayCounter[$i], 2) = $caught Then
				Local $splitCounter = StringSplit($arrayCounter[$i], ":", 2)
				$arrayCounter[$i] = $splitCounter[0] &  ":" & Int($splitCounter[1])+1
				$inTracker = True

				ExitLoop
			EndIf
		Next

		If $inTracker = False And Not($caught = "") Then
			_ArrayAdd($arrayCounter, $caught & ":1")
		EndIf
	Next
	
	Local $display = ""
	For $element In $arrayCounter
		$display &= ", " & $element
	Next
	
	Return $display
EndFunc

Func _farmAstromonFormatCaptureList(ByRef $auto, ByRef $monster, ByRef $rares)
	; Farm for a custom astromon
	If IsArray($monster) Then
		If setLog("Farming " & $monster[$ASTROMON_INFO_NAME] & "(s) at " & $monster[$ASTROMON_INFO_MAP], 1, $LOG_DEBUG) Then Return -1
		$auto = $AUTO_BATTLE
	
	; Farm for a specific astromon
	ElseIf IsString($monster) And $monster <> "" Then
		$monster = getAstromonInfo($monster)
		If setLog("Farming " & $monster[$ASTROMON_INFO_NAME] & "(s) at " & $monster[$ASTROMON_INFO_MAP], 1, $LOG_DEBUG) Then Return -1
		$auto = $AUTO_ROUND
	
	; Farm for rares only
	Else
		$monster = getAstromonInfo($monster)
		setLog("Script will be unable to return to stage if it leaves. Ensure quest, hourly, and guardian is disabled", 1, $LOG_WARN)
		$auto = $AUTO_ALWAYS
		
	EndIf
	
	If $monster[$ASTROMON_INFO_IMAGE] == null Then $auto = $AUTO_ALWAYS
	
	; Set Rares to the default list
	Local $rawCapture = []
	If $rares = 1 Then
		$rares = StringSplit("legendary,super rare,rare,exotic,variant", ",", 2)
		
	; Set Rares to the default list
	ElseIf $rares = 0 Then
		Local $empty[0]
		$rares = $empty
		
	; Do nothing if the array is already formed
	ElseIf IsArray($rares) Then
		If _Sleep(10) Then Return -1
		
	; Set Rares to custom list
	ElseIf IsString($rares) Then
		$rares = StringSplit($rares, ",", 2)
	EndIf
	
	If setLog("Rare List: " & _ArrayToString($rares, ","), 1) Then Return -1
	If setLog("Monster Info: [" & $monster[$ASTROMON_INFO_NAME] & ", " & $monster[$ASTROMON_INFO_IMAGE] & ", " & $monster[$ASTROMON_INFO_MAP] & ", " & $monster[$ASTROMON_INFO_DIFFICULTY] & ", " & $monster[$ASTROMON_INFO_STAGE] & "]", 1) Then Return -1
EndFunc