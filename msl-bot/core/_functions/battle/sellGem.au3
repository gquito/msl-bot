#cs ----------------------------------------------------------------------------

 Function: sellGem
 Sells gem during battle end screen

 Parameters:
	strRecord - Record data to file named in strRecord if not equal to ""
	sellGrade: (String) Sell gems with grade specified
	filter: (Int) 1=True; 0=False
	sellTypes: (String) Sell gems with types specified
	sellFlat: (Int) 1=True; 0=False
	sellStats: (String) Sell gems with stats specified
	sellSubstats = (String) Sell gems with substats specified

 Returns:
	On success - Returns gem data
	On fail - Return empty string

#ce ----------------------------------------------------------------------------

Func sellGem($strRecord = "!", $sellGrade = "5", $filter = "0", $sellTypes = "healing,ferocity,tenacity,fortitude", $sellStats = "f.rec,f.atk,f.def,f.hp", $sellSubstats = "1,2")
	Local $boolLog = Not(StringInStr($strRecord, "!"))
	Local $sold = ""
	$strRecord = StringReplace($strRecord, "!", "")
	Switch waitLocation("battle-sell,battle-sell-item", 2000)
		Case "battle-sell"
			_CaptureRegion()
			Local $findGem = findColor(615, 65, 229, 229, 0xFFFA6B, 10, -1)
			If (isArray($findGem) = False) And (isArray(findColor(615, 65, 252, 252, 0xF769B9, 10, -1)) = True) Then
				$findGem = Null
			EndIf
		Case "battle-sell-item"
			_CaptureRegion()
			If checkPixels("398,155,0xFDEC43|393,168,0xE7A831|396,182,0xD98F1F") = True Then
				clickUntil("399,401", "battle-sell", 2, 2000)
				Return sellGem($strRecord, $sellGrade, $filter, $sellTypes, $sellStats, $sellSubstats)
			Else
				Local $findGem = findColor(361, 436, 142, 142, 0xFFFA6B, 10)
			EndIf
		Case Else
			Return ""
	EndSwitch

	Local $arrayData = ["-", "-", "-", "-", "-", ""]
	;go into battle-sell-item

	If isArray($findGem) = False Then
		$arrayData[0] = "EGG"
		If Not($strRecord = "") Then recordGem($strRecord, $arrayData)

		clickUntil($battle_coorSellCancel, "battle-end")
		If $boolLog = True Then setLog("Grade: Egg |Shape: - |Type: - |Stat: - |Substat: -")
		Return $arrayData
	Else ;not egg
		clickUntil($findGem, "battle-sell-item")
		Local $arrayData = gatherData()
		If Not($strRecord = "") Then recordGem($strRecord, $arrayData)

		If $arrayData[0] = "EGG" Then
			clickUntil($battle_coorSellCancel, "battle-end")
			If $boolLog = True Then setLog("Grade: Egg |Shape: - |Type: - |Stat: - |Substat: -")
			Return $arrayData
		EndIf

		Local $boolSell = False
		If $sellGrade = $arrayData[0] Then
			If $filter = "1" Then
				For $element In StringSplit($sellTypes, ",", 2)
					If StringLower($element) = StringLower($arrayData[2]) Then
						$boolSell = True
					EndIf
				Next

				For $element In StringSplit($sellStats, ",", 2)
					If StringLower($element) = StringLower($arrayData[3]) Then
						$boolSell = True
					EndIf
				Next

				For $element In StringSplit($sellSubstats, ",", 2)
					If StringLower($element) = StringLower($arrayData[4]) Then
						$boolSell = True
					EndIf
				Next
			Else
				$boolSell = True
			EndIf
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
		$arrayData[5] = $strData
	EndIf

	Return $arrayData
EndFunc


Func sellGemGolemFilter($intGolem)
	Switch waitLocation("battle-sell,battle-sell-item", 2000)
		Case "battle-sell"
			Local $findGem = [298, 260]
		Case "battle-sell-item"
			_CaptureRegion()
			If checkPixels("398,155,0xFDEC43|393,168,0xE7A831|396,182,0xD98F1F") = True Then
				clickUntil("399,401", "battle-sell", 2, 2000)
				Return sellGemGolemFilter($intGolem)
			Else
				Local $findGem = findColor(361, 436, 142, 142, 0xFFFA6B, 10)
			EndIf
		Case Else
			Return ""
	EndSwitch

	Local $arrayData = ["-", "-", "-", "-", "-", ""]
	;go into battle-sell-item

	If isArray($findGem) = False Then
		$arrayData[0] = "EGG"
		recordGem("B" & $intGolem, $arrayData)

		clickUntil($battle_coorSellCancel, "battle-end")
		setLog("Grade: Egg |Shape: - |Type: - |Stat: - |Substat: -")
		Return $arrayData
	Else ;not egg
		clickUntil($findGem, "battle-sell-item")
		Local $arrayData = gatherData()

		Local $sellGrade, $filter, $sellTypes, $sellStats, $sellSubstats

		Switch $arrayData[0]
			Case "6"
				Local $sellGrade = "6"
				Local $filter = IniRead($botConfigDir, "Filter Six", "filter-gem", "")
				Local $sellTypes = IniRead($botConfigDir, "Filter Six", "sell-types", "")
				Local $sellStats = IniRead($botConfigDir, "Filter Six", "sell-stats", "")
				Local $sellSubstats = IniRead($botConfigDir, "Filter Six", "sell-substats", "")
			Case "5"
				Local $sellGrade = "5"
				Local $filter = IniRead($botConfigDir, "Filter Five", "filter-gem", "")
				Local $sellTypes = IniRead($botConfigDir, "Filter Five", "sell-types", "")
				Local $sellStats = IniRead($botConfigDir, "Filter Five", "sell-stats", "")
				Local $sellSubstats = IniRead($botConfigDir, "Filter Five", "sell-substats", "")
			Case "4"
				Local $sellGrade = "4"
				Local $filter = IniRead($botConfigDir, "Filter Four", "filter-gem", "")
				Local $sellTypes = IniRead($botConfigDir, "Filter Four", "sell-types", "")
				Local $sellStats = IniRead($botConfigDir, "Filter Four", "sell-stats", "")
				Local $sellSubstats = IniRead($botConfigDir, "Filter Four", "sell-substats", "")
			Case "EGG"
				recordGem("B" & $intGolem, $arrayData)

				clickUntil($battle_coorSellCancel, "battle-end")
				setLog("Grade: Egg |Shape: - |Type: - |Stat: - |Substat: -")
				Return $arrayData
			Case Else
				setLog("Could not filter gem. Keeping this gem.")
				Return sellGem("!", 0, 0)
		EndSwitch

		Return sellGem("B" & $intGolem, $sellGrade, $filter, $sellTypes, $sellStats, $sellSubstats)
	EndIf
EndFunc

#cs ----------------------------------------------------------------------------

 Function: gatherData
 Record gem data from the screen

 Returns: [grade, shape, type, stat, sub]
 Author: GkevinOD (2017)

#ce ----------------------------------------------------------------------------

Func gatherData()
	Local $gemData[6];
	If getLocation() = "battle-sell-item" Then
		_CaptureRegion()

		Select ;grade
			Case checkPixels("399,175,0xF39C72|399,164,0xF769BA|406,144,0x261612")
				$gemData[0] = "EGG"
				$gemData[1] = "-"
				$gemData[2] = "-"
				$gemData[3] = "-"
				$gemData[4] = "-"
				$gemData[5] = "-"
				Return $gemData
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
			_CaptureRegion("unknown-gem" & $fileCounter & ".bmp")
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
