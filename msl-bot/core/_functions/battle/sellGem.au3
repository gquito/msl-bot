#cs ----------------------------------------------------------------------------

 Function: sellGem
 Sells gem during battle end screen

 Parameters:
	strRecord - Record data to file named in strRecord if not equal to ""
	sellGrades: (String) Sell gems with grades specified
	filterGrades: (String) Grades you want to go through the filter system
	sellTypes: (String) Sell gems with types specified
	sellFlat: (Int) 1=True; 0=False
	sellStats: (String) Sell gems with stats specified
	sellSubstats = (String) Sell gems with substats specified

 Returns:
	On success - Returns gem data
	On fail - Return empty string

#ce ----------------------------------------------------------------------------

Func sellGem($strRecord = "!", $sellGrades = "1,2,3,4,5", $filterGrades = "5", $sellTypes = "healing,ferocity,tenacity,fortitude", $sellFlat = "1", $sellStats = "rec", $sellSubstats = "1,2")
	Local $boolLog = Not(StringInStr($strRecord, "!"))
	Local $sold = ""
	$strRecord = StringReplace($strRecord, "!", "")
	Switch waitLocation("battle-sell,battle-sell-item", 2000)
		Case "battle-sell"
			Local $findGem = findColor(615, 65, 142, 142, 0xFFFA6B, 10, -1)
		Case "battle-sell-item"
			Local $findGem = findColor(361, 436, 142, 142, 0xFFFA6B, 10)
		Case Else
			Return ""
	EndSwitch

	Local $arrayData = ["-", "-", "-", "-", "-", ""]
	;go into battle-sell-item

	If isArray($findGem) = False Then
		$arrayData[0] = "EGG"
		If Not($strRecord = "") Then recordGem($strRecord, $arrayData)

		clickUntil($game_coorTap, "battle-end")
		If $boolLog = True Then setLog("Grade: Egg |Shape: - |Type: - |Stat: - |Substat: -")
		Return $arrayData
	Else ;not egg
		clickUntil($findGem, "battle-sell-item")
		Local $arrayData = gatherData()
		If Not($strRecord = "") Then recordGem($strRecord, $arrayData)

		Local $boolSell = StringInStr($sellGrades, $arrayData[0])
		If (StringInStr($filterGrades, $arrayData[0])) And ($boolSell = True) Then
			$boolSell = False
			Select
				Case StringInStr($sellTypes, StringMid($arrayData[2], 3))
					$boolSell = True
				Case ($sellFlat = 1) And (StringLeft($arrayData[3], 2) = "F.")
					$boolSell = True
				Case StringInStr($sellStats, $arrayData[3])
					$boolSell = True
				Case StringInStr($sellSubstats, $arrayData[4])
					$boolSell = True
			EndSelect
		EndIf

		If $boolSell = True Then
			clickUntil($battle_coorSell, "battle-end")
			$sold = "!"
		Else
			clickUntil($battle_coorSellCancel, "battle-end")
		EndIf
	EndIf

	If $boolLog = True Then
		Local $strData = $sold & "Grade: " & $arrayData[0] & "* |Shape: "
		If $arrayData[1] = "D" Then $strData &= "Diamond |Type: "
		If $arrayData[1] = "S" Then $strData &= "Square |Type: "
		If $arrayData[1] = "T" Then $strData &= "Triangle |Type: "
		$strData &= _StringProper($arrayData[2]) & " |Stat: "
		Switch StringLeft($arrayData[3], 2)
			Case "F."
				$strData &= "Flat " & _StringProper(StringMid($arrayData[3], 3))
			Case "P."
				$strData &= "Percent " & _StringProper(StringMid($arrayData[3], 3))
			Case Else
				$strData &= _StringProper($arrayData[3])
		EndSwitch
		$strData &= " |Substat: " & $arrayData[4]
		$strData &= " |Price: " & getGemPrice($arrayData)

		setLog($strData, 1)
		_ArrayAdd($arrayData, $strData)
	EndIf

	Return $arrayData
EndFunc

#cs ----------------------------------------------------------------------------

 Function: gatherData
 Record gem data from the screen

 Returns: [grade, shape, type, stat, sub]
 Author: GkevinOD (2017)

#ce ----------------------------------------------------------------------------

Func gatherData()
	Local $gemData[5];
	If getLocation() = "battle-sell-item" Then
		_CaptureRegion()

		Select ;grade
			Case checkPixel("406,144,0x261612")
				$gemData[0] = 1
			Case checkPixel("413,144,0x261612")
				$gemData[0] = 2
			Case checkPixel("418,144,0x261612")
				$gemData[0] = 3
			Case checkPixel("423,144,0x261612")
				$gemData[0] = 4
			Case checkPixel("428,144,0x261714")
				$gemData[0] = 5
			Case Else
				$gemData[0] = 6
		EndSelect

		Select ;shape
			Case Not(checkPixel("413,159,0x261612"))
				$gemData[1] = "S"
			Case Not(checkPixel("414,168,0x261612"))
				$gemData[1] = "D"
			Case Else
				$gemData[1] = "T"
		EndSelect

		For $strType In $gem_pixelTypes
			If checkPixels(StringSplit($strType, ":", 2)[1], 20) Then
				$gemData[2] = StringSplit($strType, ":", 2)[0]
				ExitLoop
			EndIf
		Next

		For $strStat In $gem_pixelStats
			If checkPixels(StringSplit($strStat, ":", 2)[1], 20) Then
				$gemData[3] = StringSplit($strStat, ":", 2)[0]
				ExitLoop
			EndIf
		Next

		If isArray(findColor(350, 450, 329, 329, 0xE9E3DE, 20)) Then
			$gemData[4] = "4"
		ElseIf isArray(findColor(350, 450, 311, 311, 0xE9E3DE, 20)) Then
			$gemData[4] = "3"
		ElseIf isArray(findColor(350, 450, 296, 296, 0xE9E3DE, 20)) Then
			$gemData[4] = "2"
		ElseIf isArray(findColor(350, 450, 279, 279, 0xE9E3DE, 20)) Then
			$gemData[4] = "1"
		Else
			$gemData[4] = "0"
		EndIf

		If $gemData[0] = "" Or $gemData[1] = "" Or $gemData[2] = "" Or $gemData[3] = "" Or $gemData[4] = "" Then
			Local $fileCounter = 1
			While FileExists(@ScriptDir & "/unknown-gem" & $fileCounter & ".bmp")
				$fileCounter += 1
			WEnd
			_CaptureRegion("unknown-gem" & $fileCounter)
		EndIf

	EndIf
	Return $gemData
EndFunc

#cs
	Function: getGemPrice
	Returns gem price using the data passed in

	Parameters:
		gemData: [Array] [grade, shape, type, stat, sub]

	Returns: (Int) Gem price
	Author: GkevinOD(2017)
#ce

Func getGemPrice($gemData)
	Local $gemRank = 0
	For $i = 0 To UBound($gemRanks)-1
		If StringInStr($gemRanks[$i], $gemData[2]) Then
			$gemRank = $i
			ExitLoop
		EndIf
	Next

	Local $gemSub = 0
	Switch $gemData[4]
		Case 4
			$gemSub = 0
		Case 3
			$gemSub = 1
		Case 2
			$gemSub = 2
	EndSwitch

	Return Int(Execute("$gemGrade" & $gemData[0] & "Price[" & $gemSub & "][" & $gemRank & "]"))
EndFunc
