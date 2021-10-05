#include-once

#cs
	Function: Retrieves data of current gem on screen. Works during battle-sell-item location
	Parameters:
		$bCapture: Save unknown gems
	Returns: [grade, shape, type, stat, sub, price]
		- If one of the items are missing then return -1
#ce
Func getGemData($bCapture = True)
	Local $aGemData[7] = ["-", "-", "-", "-", "-", "-", "-"] ;Stores current gem data
	CaptureRegion()
	Select ;grade
		Case isPixel(getPixelArg("battle-item-egg"), 20)
			$aGemData[0] = "EGG"
			Return $aGemData
		Case isPixel(getPixelArg("battle-item-gold"), 20)
			$aGemData[0] = "GOLD"
			Return $aGemData
		Case isPixel("406,144,0x261612")
			$aGemData[0] = 1
		Case isPixel("413,144,0x261612")
			$aGemData[0] = 2
		Case isPixel("418,144,0x261612")
			$aGemData[0] = 3
		Case isPixel("423,144,0x261612")
			$aGemData[0] = 4
		Case isPixel("428,144,0x261714")
			$aGemData[0] = 5
		Case Else
			$aGemData[0] = 6
	EndSelect

	Select ;shape
		Case Not(isPixel("413,159,0x261612"))
			$aGemData[1] = "S"
		Case Not(isPixel("414,168,0x261612"))
			$aGemData[1] = "D"
		Case Else
			$aGemData[1] = "T"
	EndSelect

	For $strType In $g_aGem_pixelTypes ;types
		Local $sType = StringSplit($strType, ":", 2)
		If (isPixel($sType[1], 20)) Then
			$aGemData[2] = $sType[0]
			ExitLoop
		EndIf
	Next

	For $strStat In $g_aGem_pixelStats ;main stats
		Local $aStat = StringSplit($strStat, ":", 2)
		If (isPixel($aStat[1], 20)) Then
			$aGemData[3] = $aStat[0]
			ExitLoop
		EndIf
	Next

	If (isArray(findColor("350,329", "50,1", "0xE9E3DE", 20))) Then ;number of substats
		$aGemData[4] = "4"
	ElseIf (isArray(findColor("350,311", "50,1", "0xE9E3DE", 20))) Then
		$aGemData[4] = "3"
	ElseIf (isArray(findColor("350,296", "50,1", "0xE9E3DE", 20))) Then
		$aGemData[4] = "2"
	ElseIf (isArray(findColor("350,329", "50,1", "0xE9E3DE", 20))) Then
		$aGemData[4] = "1"
	EndIf

	;Handles if gem is unknown
	If (($aGemData[0] == "-") Or ($aGemData[1] == "-") Or ($aGemData[2] == "-") Or ($aGemData[3] == "-") Or ($aGemData[4] == "-")) Then
		Return SetError(1, 0, -1)
	EndIf

	$aGemData[5] = getGemPrice($aGemData)
	$aGemData[6] = getGemSubs()

	Return $aGemData
EndFunc

Func getGemSubs()
	Local Const $aSubstats = ["attack", "critdmg", "critrate", "defense", "hp", "recovery", "resist"]
	Local $aSubFound[0]

	Local $aPercentages = findImageMultiple("gem-percent", 85, 5, 5, 4, 322, 266, 461-322, 344-266)
	For $sSubstat in $aSubstats
		Local $aFind = findImageMultiple("gem-" & $sSubstat, 85, 5, 5, 2, 322, 266, 461-322, 344-266)
		For $i = 0 To UBound($aFind)-1
			Local $bPercent = False
			For $x = 0 To UBound($aPercentages)-1
				If Abs($aFind[$i][1] - $aPercentages[$x][1]) <= 5 Then
					_ArrayDelete($aPercentages, $x)
					$bPercent = True
					ExitLoop
				EndIf
			Next
			_ArrayAdd($aSubFound, $sSubstat & (($bPercent)?"%":"+"))
			If UBound($aSubFound) = 4 Then ExitLoop(2)
		Next
	Next

	Return $aSubFound
EndFunc

#cs
	Function: Returns gem price using the data passed in
	Parameters:
		gemData: [Array] [grade, shape, type, stat, sub]
	Returns: (Int) Gem price
#ce
Func getGemPrice($aGemData)
	Local $iRank = 0

	;Looking if rank exists in g_aGemRanks
	For $i = 0 To UBound($g_aGemRanks)-1
		If (StringInStr($g_aGemRanks[$i], $aGemData[2])) Then
			$iRank = $i
			ExitLoop
		EndIf
	Next

	Local $iSub = 0 ;Formatting sub for index
	Switch $aGemData[4]
		Case 4
			$iSub = 0
		Case 3
			$iSub = 1
		Case 2
			$iSub = 2
	EndSwitch

    Local $iGemPrice = $g_aGemGrade[$aGemData[0]-1][$iSub][$iRank]
    Log_Add("Gem Price: " & $iGemPrice, $LOG_DEBUG)
    Return $iGemPrice
	;Gem prices are location in 3 different arrays organized in ranks. Refer to Global variables.
	;Return Int(Execute("$g_aGemGrade" & $aGemData[0] & "Price[" & $iSub & "][" & $iRank & "]"))
EndFunc

#cs
	Function: Filters gems that do not meet the criteria
	Parameters:
		$aGemData: Gem data. Refer to getGemData() function.
		$aFilter: format=[[4*-Filter, ""], [4*-Types, ""], [4*-Stats, ""], [4*-Substats, ""], ...]
	Returns:
		If the gem meets the criteria returns true; otherwise, returns false.
#ce
Func old_filterGem($aGemData, $bCheckDragonGems = False)
	If ($bCheckDragonGems And StringInStr("leech,pugilist,siphon", $aGemData[2])) Then
		Local $iGrade = $aGemData[0]
		Local $t_bFilter = Eval("DragonFilter_" & $iGrade & "_Star_Filter")
		Local $t_bFilterTypes = StringInStr(Eval("DragonFilter_" & $iGrade & "_Star_Types"), $aGemData[2])
		Local $t_bFilterStats = StringInStr(Eval("DragonFilter_" & $iGrade & "_Star_Stats"), $aGemData[3])
		Local $t_bFilterSubStats = StringInStr(Eval("DragonFilter_" & $iGrade & "_Star_Substats"), $aGemData[4])
	Else
		Local $iGrade = $aGemData[0]
		Local $t_bFilter = Eval("Filter_" & $iGrade & "_Star_Filter")
		Local $t_bFilterTypes = StringInStr(Eval("Filter_" & $iGrade & "_Star_Types"), $aGemData[2])
		Local $t_bFilterStats = StringInStr(Eval("Filter_" & $iGrade & "_Star_Stats"), $aGemData[3])
		Local $t_bFilterSubStats = StringInStr(Eval("Filter_" & $iGrade & "_Star_Substats"), $aGemData[4])
	EndIf

	If (Not($t_bFilter) Or Not($t_bFilterTypes) Or Not($t_bFilterStats) Or Not($t_bFilterSubStats)) Then Return False

	Return True
EndFunc

;Return name of filter that passes it
;Return false if it does not pass filter
Func filterGem($aGemData, $aFilters)
	If isArray($aFilters) = False Then $aFilters = StringSplit($aFilters, ",", $STR_NOCOUNT)
	If isArray($aFilters) = False Then $aFilters = CreateArr($aFilters)

	For $i = 0 To UBound($aFilters)-1
		Local $sFilter = $aFilters[$i]
		If ($sFilter <> "_Filter") And FileExists($g_sFilterFolder & $sFilter) = False Then
			Log_Add("Filter does not exist: " & $sFilter, $LOG_ERROR)
			ContinueLoop
		EndIf

		Local $bResult = _filterGem($aGemData, $sFilter)
		If @error = 0 Then
			If $bResult = True Then Return $sFilter
		Else
			Local $iError = @error
			Log_Add("Filter did not work: " & $FILTERGEM_ERROR_STRING[$iError], $LOG_ERROR)
			Return SetError(1, $iError, "Error")
		EndIf
	Next

	Return False
EndFunc

Global $FILTERGEM_ERROR_STRING = _
								["No error.", _
								"Invalid gem data.", _
								"Unable to parse gem data.", _
								"Could not get filter data.", _
								"Invalid filter data.", _
								"Invalid filter value."]
Func _filterGem($aGemData, $sFilter)
	If isArray($aGemData) = False Or UBound($aGemData) <> 7 Then Return SetError(1, 0, True) ;Invalid gem data.

	If $sFilter == "_Filter" Then
		Return old_filterGem($aGemData, True)
	Else
		Local $aGem = Null
		If UBound($aGemData) = 7 Then $aGem = parseGem($aGemData)
		;_ArrayDisplay($aGem)
		IF isArray($aGem) = False Or UBound($aGem) <> 8 Then Return SetError(2, 0, True) ;Invalid gem data.

		Local $aCurrentSub[0]
		For $i = 4 To 7
			If $aGem[$i] <> "" Then _ArrayAdd($aCurrentSub, $aGem[$i])
		Next

		Local $aFilter = getFilter($sFilter)
		If @error Then 
			Return SetError(3, @error, True) ;Could not get filter
		EndIf
		
		Local $aFilterSub[0]
		For $x = 0 To UBound($aFilter)-1
			Local $aData = StringSplit($aFilter[$x], ":", $STR_NOCOUNT)
			If isArray($aData) = False Or UBound($aData) <> 2 Then Return SetError(4, 0, True) ;Invalid filter

			$aData[0] = StringLower(StringStripWS($aData[0], $STR_STRIPALL))
			$aData[1] = StringLower(StringStripWS($aData[1], $STR_STRIPALL))
			If StringInStr($aData[1], ",") Then 
				$aData[1] = StringSplit($aData[1], ",", $STR_NOCOUNT)
			Else
				$aData[1] = CreateArr($aData[1])
			EndIf
			
			Local $sType = $aData[0]
			Local $aValue = $aData[1]
			If isArray($aValue) = False Or UBound($aValue) = 0 Then Return SetError(5, 0, True) ;Invalid value
			
			Local $sCurrent = $aGem[Eval("GEM_PARSED_" & StringUpper($sType))]
			Switch $aData[0]
				Case "grade", "shape", "type"
					If $aValue[0] == "any" Then ContinueLoop ;Accepts any of that data type
					Local $aFind = _ArrayFindAll($aValue, $sCurrent)
					If isArray($aFind) = False Then Return SetExtended(1, False) ;Not Found
				Case "stat"
					If $aValue[0] == "any" Then ContinueLoop ;Accepts any of that data type
					Local $aFind = _ArrayFindAll($aValue, $sCurrent)
					If isArray($aFind) = False Then $aFind = _ArrayFindAll($aValue, StringMid($sCurrent, 1, StringLen($sCurrent) - 1))
					If isArray($aFind) = False Then
						Local $bFound = False
						Local $aFindP = _ArrayFindAll($aValue, "any%")
						Local $aFindF = _ArrayFindAll($aValue, "any+")

						If isArray($aFindP) = True And StringRight($sCurrent, 1) == "%" Then $bFound = True
						If $bFound = False And (isArray($aFindF) And StringRight($sCurrent, 1) == "+") Then $bFound = True

						If $bFound = False Then Return SetExtended(2, False)
					EndIf
				Case Else ;handles substats
					_ArrayAdd($aFilterSub, $aValue, 0, "|", @CRLF, $ARRAYFILL_FORCE_SINGLEITEM)
			EndSwitch
		Next
		
		;handle substats
		If UBound($aCurrentSub) < UBound($aFilterSub) Then Return SetExtended(3, False) ;minimum substat

		Local $aPermutedCurrent = _ArrayPermute($aCurrentSub, "|")
		Local $bFits = False ;Fits filter
		For $z = 1 To $aPermutedCurrent[0]
			$aCurrentSub = StringSplit($aPermutedCurrent[$z], "|", $STR_NOCOUNT)
			If isArray($aCurrentSub) = False Then $aCurrentSub = CreateArr($aPermutedCurrent[$z])

			Local $aFilterSub_Inner = $aFilterSub
			For $x = UBound($aCurrentSub)-1 To 0 Step -1
				Local $sSub = $aCurrentSub[$x]
				Local $bFound = False
				For $y = 0 To UBound($aFilterSub_Inner)-1
					Local $aSub = $aFilterSub_Inner[$y]
					If $aSub[0] == "any" Then 
						$bFound = True
						ExitLoop
					EndIf

					Local $aFind = _ArrayFindAll($aSub, $sSub)
					If isArray($aFind) = False Then $aFind = _ArrayFindAll($aSub, StringMid($sSub, 1, StringLen($sSub)-1))
					If isArray($aFind) = False Then
						Local $aFindP = _ArrayFindAll($aSub, "any%")
						Local $aFindF = _ArrayFindAll($aSub, "any+")

						If isArray($aFindP) = True And StringRight($sSub, 1) == "%" Then $bFound = True
						If $bFound = False And (isArray($aFindF) = True And StringRight($sSub, 1) == "+") Then $bFound = True
					Else
						$bFound = True
					EndIf

					If $bFound = True Then ExitLoop
				Next

				If UBound($aFilterSub_Inner) > 0 And $bFound = True Then
					_ArrayDelete($aFilterSub_Inner, $y)
					_ArrayDelete($aCurrentSub, $x)
				EndIf
			Next

			If UBound($aFilterSub_Inner) = 0 Then 
				$bFits = True
				ExitLoop
			EndIf
		Next

		If $bFits = False Then Return SetExtended(4, False)
	EndIf

	Return SetExtended(1, True) ;Fits the criteria
EndFunc

Func getFilter($sFilter)
	Local $sContent = FileRead($g_sFilterFolder & $sFilter)
	If @error Then Return SetError(1, 0, False)
	If _GemWindow_isValid($sContent) = False Then SetError(2, @error, False)

	Local $aFilter = StringSplit($sContent, @CRLF, $STR_NOCOUNT)
	For $i = UBound($aFilter)-1 To 0 Step -1
		If $aFilter[$i] == "" Then _ArrayDelete($aFilter, $i)
	Next

	Return $aFilter
EndFunc

Global Const	$GEM_PARSED_GRADE = 0, $GEM_PARSED_SHAPE = 1, $GEM_PARSED_TYPE = 2, $GEM_PARSED_STAT = 3, _
				$GEM_PARSED_SUB1 = 4, $GEM_PARSED_SUB2 = 5, $GEM_PARSED_SUB3 = 6, $GEM_PARSED_SUB4 = 7
Func parseGem($aGemData)
	If isArray($aGemData) = False Or UBound($aGemData) < 7 Then Return SetError(1, 0, False)
	
	Local $aGem[8];[grade, shape, type, stat, sub1, sub2, sub3, sub4]
	$aGem[$GEM_PARSED_GRADE] = $aGemData[0]
	If $aGemData[1] == "S" Then $aGem[$GEM_PARSED_SHAPE] = "square"
	If $aGemData[1] == "T" Then $aGem[$GEM_PARSED_SHAPE] = "triangle"
	If $aGemData[1] == "D" Then $aGem[$GEM_PARSED_SHAPE] = "square"
	$aGem[$GEM_PARSED_TYPE] = StringLower($aGemData[2])
	If StringLeft($aGemData[3], 2) == "F." Then
		$aGem[$GEM_PARSED_STAT] = StringLower(StringMid($aGemData[3], 3)) & "+"
	ElseIf StringLeft($aGemData[3], 2) == "P." Then
		$aGem[$GEM_PARSED_STAT] = StringLower(StringMid($aGemData[3], 3)) & "%"
	Else
		$aGem[$GEM_PARSED_STAT] = StringLower(StringStripWS($aGemData[3], $STR_STRIPALL)) & "%"
	EndIf
	Switch StringLeft($aGem[$GEM_PARSED_STAT], 3)
		Case "atk"
			$aGem[$GEM_PARSED_STAT] = "attack" & StringRight($aGem[$GEM_PARSED_STAT], 1)
		Case "def"
			$aGem[$GEM_PARSED_STAT] = "defense" & StringRight($aGem[$GEM_PARSED_STAT], 1)
		Case "rec"
			$aGem[$GEM_PARSED_STAT] = "recovery" & StringRight($aGem[$GEM_PARSED_STAT], 1)
	EndSwitch

	Local $aSubs = $aGemData[6]
	For $i = 0 To UBound($aSubs)-1
		If $aSubs[$i] == "" Then ContinueLoop
		$aGem[4+$i] = $aSubs[$i]
	Next

	Return $aGem
EndFunc

#cs
	Function: Puts gem data into readable string.
	Parameters:
		$aGemData: Gem data. Refer to function: getGemData()
	Returns: Ex. 4*	Triangle Intuition %Atk
#ce
Func stringGem($aGemData)
	Local $sShape = "[Shape]"
	Switch $aGemData[1]
	Case "S"
		$sShape = "Square"
	Case "T"
		$sShape = "Triangle"
	Case "D"
		$sShape = "Diamond"
	EndSwitch

	Local $sType = "[Type]"
	$sType = _StringProper($aGemData[2])

	Local $sStat = "[Stat]"
	If (StringInStr($aGemData[3], ".")) Then
		Local $t_aSplit = StringSplit($aGemData[3], ".", $STR_NOCOUNT)

		$sStat = "+"
		If ($t_aSplit[0] == "P") Then $sStat = "%"

		$sStat &= _StringProper($t_aSplit[1])
	Else
		$sStat = _StringProper($aGemData[3])
	EndIf

	Local $sSub = "[Substat]"
	$sSub = $aGemData[4] & " Substat"
	If ($aGemData[4] > 1) Then $sSub &= "s"

	Return $aGemData[0] & "*; " & $sShape & "; " & $sType & "; " & $sStat & "; " & $sSub & "; " & _ArrayToString($aGemData[6])
EndFunc

#cs
	Function: Looks for level in map stage selection location.
	Parameters:
		$iLevel: Integer from 1-17.
	Return:
		Array point of where the energy is. -1 on not found.
#ce
Func findLevel($iLevel)
	Local $aPoint[2]
	Local $sLevel = StringLower($iLevel)
	If $sLevel == "boss" Then $sLevel = "any"
	
	If getLocation() == "map-stage" Then
		If StringIsDigit($sLevel) > 0 Then 
			If ($sLevel < 10) Then $sLevel = "0" & $sLevel ;Must be in format ##
			$sLevel = "n" & $sLevel
		EndIf		 

		Local $t_sImageName = "level-" & $sLevel
		Local $t_aPoint = findImageMultiple($t_sImageName, 95, 5, 5, 4, 400, 220, 380, 260, False, True) ;tolerance 100, rectangle at (402,229) dim. 50x250
		;Sort lowest
		_ArraySort($t_aPoint, 1, 0, 0, 1) ;Sort highest level
		;_ArrayDisplay($t_aPoint)

		If isArray($t_aPoint) = False Or UBound($t_aPoint) <= 0 Then Return -1
		;Found point
		
		Local $aReturn[2] = [725, $t_aPoint[0][1]]
		Return $aReturn
	EndIf

	Return -2
EndFunc

Func findBLevel($iLevel)
	Local $aPoint0, $aPoint1

	If $iLevel > 1 Then $aPoint0 = findImage("level-b" & ($iLevel-1<10?"0":"") & $iLevel-1 , 90, 0, 310, 160, 50, 330, True)
	$aPoint1 = findImage("level-b" & ($iLevel<10?"0":"") & $iLevel , 90, 0, 310, 160, 50, 330, ($iLevel <= 1))

	If isArray($aPoint1) = False Or UBound($aPoint1) < 2 Then Return SetError(1, 0, False) ;Could not find
	If $iLevel > 1 Then
		If isArray($aPoint0) = False Or UBound($aPoint0) < 2 Then Return SetError(2, 0, False) ;Partner could not find
		If Abs($aPoint0[1]-$aPoint1[1]) < 30 Then Return SetError(3, 0, False) ;Same position
		If $aPoint0[1] > $aPoint1[1] Then Return SetError(4, 0, False) ;Incorrect position
	EndIf
	
	$aPoint1[0] = 626 ;x coordinate for left side of button
	Return $aPoint1
EndFunc

#cs
	Function: Finds an available guardian dungeon based on the current guardian dungeons.
	Parameters:
		$sMode: "left", "right", "both" - Handles the left/right side on the two visible guardian dungeon.
	Return: Points of the energy of the guardian dungeon.
#ce
Func findGuardian($sMode)
	$sMode = StringLower(StringStripWS($sMode, $STR_STRIPALL))
	CaptureRegion()
	If isArray(findImage("level-any", 70, 0, 614, 266, 100, 220, False)) <= 0 Then Return -2

	CaptureRegion("\bin\images\misc\misc-guardian-left", 335, 191, 15, 15)
	CaptureRegion("\bin\images\misc\misc-guardian-right", 398, 191, 15, 15)
	Local $aResult = False
	Switch $sMode
		Case "left", "right"
			$aResult = findImage("misc-guardian-" & $sMode, 70, 0, 550, 250, 60, 250, False, True)
		Case Else
			Return findImage("level-any", 70, 0, 614, 266, 100, 220, False)
	EndSwitch
	If isArray($aResult) <= 0 Then Return -1
	$aResult[0] = 650

	Return $aResult
EndFunc

#cs
	Function: Retrieves village position and angle.
	Return: Village position from 0-5. 0-2 for first ship, 3-4 for second, and 5-6 for third.
#ce
Func getVillagePos()
	CaptureRegion()

	;Traverse through idShip checking the pixel sets.
	For $i = 0 To UBound($g_aVillagePos)-1
		If isPixel($g_aVillagePos[$i], 10) Then Return $i
	Next

	;Return -1 if ship not found.
	Return -1
EndFunc

#cs
	Function: Checks if there are still astrochips left, only works if in 'battle' location.
	Returns Codes:
	   -2: Unknown
	   -1: Not in battle
		0: No astrocips
		1: Has astrochips
#ce
Func hasAstrochips()
	If Not(isLocation("battle")) Then Return -1
	If (isPixel("162,509,0x612C22/340,507,0x612C22/513,520,0x612C22/683,520,0x612C22")) > 0 Then
		If (isPixel("743,279,0x53100C|746,266,0xBD3229")) Then Return 0

		Return 1
	EndIf

	Return -2
EndFunc

#cs
	Function: Gets stone data.
	Returns: Array => [ELEMENT, GRADE, QUANTITY] ex. ["fire", "high", 3]
#ce
Func getStone()
	;Defining variables
	Local $sElement = "", $sGrade = "", $iQuantity = -1
	CaptureRegion()

	;Check if egg or gold
	If isPixel(getPixelArg("battle-item-egg"), 20) Then
		Local $t_aData = ["egg", "n/a", "1"]
		Return $t_aData
	ElseIf isPixel(getPixelArg("battle-item-gold"), 20) Then
		Local $t_aData = ["gold", "n/a", "n/a"]
		Return $t_aData
	EndIf

	;Getting element and grade
	Local $aElements = ["normal", "water", "wood", "fire", "dark", "light"]
	Local $aGrades = ["low", "mid", "high"]

	For $sCurElement In $aElements
		For $sCurGrade In $aGrades
			If isPixel(getPixelArg("stone-" & $sCurElement & "-" & $sCurGrade)) > 0 Or findImage("stone-" & $sCurElement & "-" & $sCurGrade, 90, 0, 359, 131, 80, 80, False) <> -1 Then
				$sElement = $sCurElement
				$sGrade = $sCurGrade

				ExitLoop(2)
			EndIf
		Next
	Next

	If ($sElement == "" Or $sGrade == "") Then
		Local $iCounter = 0
		While FileExists(@ScriptDir & "\bin\images\stone\stone-unknown" & $iCounter & ".bmp")
			$iCounter += 1
		WEnd
		Log_Add("Could not get Element or Grade", $LOG_ERROR)
		Return -1
	EndIf

	;Getting quantity
	For $i = 1 To 5
		If (isArray(findImage("misc-stone-x" & $i, 90, 0, 440, 214, 50, 20, False))) Then
			$iQuantity = $i
			ExitLoop
		EndIf
	Next

	If ($iQuantity = -1) Then
		Log_Add("Could not get quantity", $LOG_ERROR)
		Return -1
	EndIf

	Local $t_aData = [$sElement, $sGrade, $iQuantity]
	Return $t_aData
EndFunc

#cs
	Function: Retrieves which round the battle is currently.
	Parameters:
		$aPixels: List where the pixel rounds are.
	Return: Current round and the number of total rounds: Array format=[current, max, isLastRound, isBoss, MonsPerRound]
#ce
Func getRound($bUpdate = True)
	If ($bUpdate) Then CaptureRegion()
	Local $iMax = 0 ;Max number of rounds
	Local $iCurr = 0 ;Current round
	$g_sErrorMessage = ""
	;Getting round info
	For $i = 1 To 4
		If ($i > 1 And $iMax = 0 And checkRoundPixels("max-round-" & $i)) Then $iMax = $i
		If ($iCurr = 0 And checkRoundPixels("curr-round-" & $i)) Then $iCurr = $i
	Next

	If ($iMax = 0) Then  $g_sErrorMessage &= "getRound() => Could not find max."
	If ($iCurr = 0) Then $g_sErrorMessage &= "getRound() => Could not find current."

	If ($g_sErrorMessage <> "") Then Return -1
	
	Local $t_aResult = [$iCurr, $iMax]
	Return $t_aResult
EndFunc

Func checkRoundPixels($sPixelArg)
	Local $t_sArgument = getPixelArg($sPixelArg)
	If ($t_sArgument == "" Or $t_sArgument = -1) Then Return False

	Return isPixel($t_sArgument)
EndFunc
#cs 
	Function: Tries to close a in game window interface.
	Parameters:
	Return: If window was closed successfully then return true. Else return false.
#ce
Func closeWindow()
	Local $sCurrLocation = getLocation()
	;Switch $sCurrLocation
		;Case "autobattle-prompt"
		;	Return clickWhile(getPointArg("autobattle-prompt-close"), "isLocation", "autobattle-prompt", 5, 1000)
		;Case "monsters-previous-awaken"
		;	Return clickWhile(getPointArg("already-awakened-close"), "isLocation", "monsters-previous-awaken", 5, 1000)
		;Case "refill"
		;	Return clickWhile(getPointArg("refill-close"), "isLocation", "refill", 5, 1000)
		;Case "boutique"
		;	Return clickWhile(getPointArg("boutique-close"), "isLocation", "boutique", 5, 1000)
		;Case Else
			Local $aPoints = findImageMultiple("location-dialogue-close", 90, 5, 5, 4, 0, 0, 800, 552, False, True)
			If IsArray($aPoints) Then
				For $i = 0 to UBound($aPoints)-1
					Local $sLoc = getLocation()
					
					clickPoint(CreateArr($aPoints[$i][0], $aPoints[$i][1]))
					If _Sleep(300) Then ExitLoop

					If $sLoc <> getLocation() Then ExitLoop
				Next

				Return True
			Else
				$g_sErrorMessage = "closeWindow() => No close found."
				Return False
			EndIf
	;EndSwitch
EndFunc

#cs 
	Function: Tries to close dialogue between players in game
	Return: If dialogue has been closed successfully then return true. Else return false.
#ce
Func skipDialogue()
	Local $t_iTimerInit = TimerInit()
	While isLocation("dialogue-skip")
		If (TimerDiff($t_iTimerInit) >= 5000) Then Return False 
		
		clickWhile(getPointArg("dialogue-skip"), "isLocation", "dialogue-skip", 5, 1000)
		If (_Sleep(200)) Then Return False
	WEnd
EndFunc


Func testEachPixel($sPixelString)
	CaptureRegion()
	Local $aFailedPixelResults[0]
	If (StringInStr($sPixelString,'/',$STR_NOCASESENSE)) Then
		Local $a_sPixels = StringSplit($sPixelString, '/', $STR_NOCOUNT)
		For $i = 0 To UBound($a_sPixels)
			Local $sPixels = $a_sPixels[$i]
			If (isPixel($sPixels)) Then ExitLoop
			Local $aPixels = StringSplit($sPixels,'|', $STR_NOCOUNT)
			checkEachPixel($aFailedPixelResults,$aPixels)
		Next
	Else
		Local $aPixels = StringSplit($sPixels,'|', $STR_NOCOUNT)
		checkEachPixel($aFailedPixelResults,$aPixels)
	EndIf
	Return $aFailedPixelResults
EndFunc

Func checkEachPixel(ByRef $aFailedArray, $aPixels)
	If (Not(IsArray($aFailedArray))) Then Return False

	For $p = 0 To UBound($aPixels)
		If (Not(isPixel($aPixels[$p]))) Then _ArrayAdd($aFailedArray, $aPixels[$p])
	Next

	Return True
EndFunc

;Only deals with 1D array
Func __ArrayToString($aArray, $iLayer = 1)
    Local $sArray = ""
    For $i = 0 To UBound($aArray)-1
        Local $temp = $aArray[$i]
        If isArray($temp) > 0 Then
            $sArray &= "\" & $iLayer & __ArrayToString($temp, $iLayer+1)
        Else
            $sArray &= "\" & $iLayer & $temp
        EndIf
    Next
    Return $sArray
EndFunc

;Deals with string that come from __ArrayToString
Func __ArrayFromString($sString, $iLayer = 1)
    Local $aArray = StringSplit($sString, "\" & $iLayer, $STR_ENTIRESPLIT+$STR_NOCOUNT)
	For $i = UBound($aArray)-1 To 0 Step -1
		If $aArray[$i] == "" Then _ArrayDelete($aArray, $i)
	Next

    For $i = 0 To UBound($aArray)-1
        If StringInStr($aArray[$i], "\" & $iLayer+1) Then
            $aArray[$i] = __ArrayFromString($aArray[$i], $iLayer+1)
        EndIf
    Next
    Return $aArray
EndFunc

Func CreateArr($o1 = Null, $o2 = Null, $o3 = Null, $o4 = Null, $o5 = Null, $o6 = Null, $o7 = Null, $o8 = Null, $o9 = Null, $o10 = Null, _
			   $o11 = Null, $o12 = Null, $o13 = Null, $o14 = Null, $o15 = Null, $o16 = Null, $o17 = Null, $o18 = Null, $o19 = Null, $o20 = Null)
	;count defined
	For $i = 20 To 1 Step -1
		If Eval("o" & $i) <> Null Then
			ExitLoop 
		EndIf
	Next

	;assign
	Local $arr[$i]
	For $x = 0 To $i-1
		$arr[$x] = Eval("o" & $x+1)
	Next

	Return $arr
EndFunc

Func clickBattle()
	Local $sLocation = getLocation()
	clickPoint(getPointArg("battle-auto"))
	$sLocation = ($sLocation=="battle")?"battle-auto":"battle"

	Return waitLocation($sLocation, 1)
EndFunc

Func findMap($sMap)
	If getLocation() <> "map" Then Return -1
	$sMap = StringReplace(StringLower($sMap)," ","-")

	Local $aPoint = findImage("map-" & $sMap, 90, 0, 0, 100, 800, 430, False, True)

	If isArray($aPoint) = 0 Then clickDrag($g_aSwipeRightFast)
	While isArray($aPoint) = False
		If _Sleep(200) Or getLocation() <> "map" Then ExitLoop
		If $sMap == "astromon-league" Then
			If findImage("map-astromon-league-disabled", 90, 0, 0, 100, 800, 430, False, True) Then
				$aPoint = -1
				ExitLoop
			EndIf
		EndIf

		$aPoint = findImage("map-" & $sMap, 90, 0, 0, 100, 800, 430, False, True)
		If isArray(findImage("map-terrestrial-rift", 90, 0, 0, 100, 800, 430, False, True)) > 0 Then ExitLoop
		
		If isArray($aPoint) = 0 Then 
			clickDrag($g_aSwipeLeft)
		EndIf
	WEnd

	If $sMap == "ancient-dungeon" And isArray($aPoint) > 0 Then $aPoint[1] -= 100
	Return $aPoint
EndFunc

Func goBack()
	Log_Add("Sending back command", $LOG_DEBUG)
	If isPixel(getPixelArg("back"), 20, CaptureRegion()) > 0 Then
		clickPoint(getPointArg("back"))
	Else
		If closeWindow() = 0 Then clickPoint(getPointArg("tap"))
	EndIf
EndFunc

Func anotherDevice()
	Log_Level_Add("anotherDevice")

	If getLocation() == "another-device" Then
		Log_Add("Another device detected!", $LOG_INFORMATION)

		Switch $Config_Another_Device_Timeout
			Case $CONFIG_NEVER
				Log_Add("Restart time set to Never, Stopping script.", $LOG_INFORMATION)
				Stop()
			Case $CONFIG_IMMEDIATELY
				Log_Add("Restart time set to Immediately", $LOG_INFORMATION)
			Case Else
				Local $iMinutes = $Config_Another_Device_Timeout
				Log_Add("Restart time set to " & $iMinutes & " minutes.", $LOG_INFORMATION)
				
				Local $hTimer = TimerInit()
				$g_bAntiStuck = False
				While TimerDiff($hTimer) < ($iMinutes*60000)
					Local $iSeconds = Int(($iMinutes*60) - (TimerDiff($hTimer)/1000))
					Status("Restarting in: " & getTimeString($iSeconds))
					If _Sleep(1000) Then ExitLoop
				WEnd
				$g_bAntiStuck = True

				Emulator_RestartGame()
		EndSwitch
	EndIf
	
	Log_Level_Remove()
EndFunc

Func appMaintenance()
	Log_Level_Add("appMaintenance")

	Local $bAntiStuck = $g_bAntiStuck
	$g_bAntiStuck = False
	Local $bScheduleBusy = $g_bScheduleBusy
	$g_bScheduleBusy = True
	While waitLocation("app-maintenance", 10)
		Local $iMinutes = $Config_Maintenance_Timeout
		Log_Add("Maintenance found. Waiting " & ($Config_Maintenance_Timeout) & " minutes then restarting game.", $LOG_INFORMATION)

		Local $hTimer = TimerInit()
		While TimerDiff($hTimer) < ($iMinutes*60000)
			Local $iSeconds = Int(($iMinutes*60) - (TimerDiff($hTimer)/1000))
			Status("Restarting in: " & getTimeString($iSeconds))
			If _Sleep(1000) Then ExitLoop(2)
		WEnd
		
		Emulator_RestartGame()
	WEnd
	$g_bScheduleBusy = $bScheduleBusy
	$g_bAntiStuck = $bAntiStuck
	
	Log_Level_Remove()
EndFunc

Func appUpdate()
	Log_Level_Add("appUpdate")

	Local $bOutput = True
	Local $hTimer = Null

	Local $bAntiStuck = $g_bAntiStuck
	$g_bAntiStuck = False
	Local $bScheduleBusy = $g_bScheduleBusy
	$g_bScheduleBusy = True
	While $g_bRunning
		If _Sleep(2000) Then ExitLoop

		Local $sLocation = waitLocation("app-update,app-google-update,app-google-open,app-update-ok,popup-window,tap-to-start", 200, False)
		If $sLocation <> "unknown" Then $hTimer = Null
		Switch $sLocation
			Case "app-update"
				clickPoint(findImage("misc-update"))
			Case "app-google-update"
				clickPoint(findImage("misc-google-update"))
			Case "app-google-open"
				clickPoint(findImage("misc-google-open"))
			Case "app-update-ok", "popup-window"
				clickPoint(findImage("misc-ok"))
			Case "tap-to-start"
				ExitLoop
			Case "unknown"
				If $hTimer = Null Then $hTimer = TimerInit()
				If TimerDiff($hTimer) > 300000 Then
					$bOutput = False
					Log_Add("Could not download update from google play.", $LOG_ERROR)
					ExitLoop
				EndIf
		EndSwitch
	WEnd
	$g_bScheduleBusy = $bScheduleBusy
	$g_bAntiStuck = $bAntiStuck

	Log_Level_Remove()
	If $bOutput = False Then Stop()
	Return $bOutput
EndFunc