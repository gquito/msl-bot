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

		Local $sellGem, $sellGrade, $filter, $sellTypes, $sellStats, $sellSubstats

		Switch $arrayData[0]
			Case "6"
				Local $sellGem = IniRead($botConfigDir, "Filter Six", "sell-gem", "")
				Local $sellGrade = "6"
				Local $filter = IniRead($botConfigDir, "Filter Six", "filter-gem", "")
				Local $sellTypes = IniRead($botConfigDir, "Filter Six", "sell-types", "")
				Local $sellStats = IniRead($botConfigDir, "Filter Six", "sell-stats", "")
				Local $sellSubstats = IniRead($botConfigDir, "Filter Six", "sell-substats", "")
			Case "5"
				Local $sellGem = IniRead($botConfigDir, "Filter Five", "sell-gem", "")
				Local $sellGrade = "5"
				Local $filter = IniRead($botConfigDir, "Filter Five", "filter-gem", "")
				Local $sellTypes = IniRead($botConfigDir, "Filter Five", "sell-types", "")
				Local $sellStats = IniRead($botConfigDir, "Filter Five", "sell-stats", "")
				Local $sellSubstats = IniRead($botConfigDir, "Filter Five", "sell-substats", "")
			Case "4"
				Local $sellGem = IniRead($botConfigDir, "Filter Four", "sell-gem", "")
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

		If $sellGem = 0 Then
			Return sellGem("B" & $intGolem, $sellGrade, 1, "", "", "") ;keep gem
		Else
			Return sellGem("B" & $intGolem, $sellGrade, $filter, $sellTypes, $sellStats, $sellSubstats)
		EndIf
	EndIf
EndFunc

Func getStone()
	waitLocation("battle-sell,battle-sell-item", 2000)

	Local $arrayData = ["-", "-", "-", "-", "-", ""]
	Local $arrayData = gatherData()

	Switch $arrayData[0]
		Case "STARSTONE", "FIRE", "WATER", "WOOD", "LIGHT", "DARK"
			clickUntil($battle_coorSellCancel, "battle-end")
			setLog("Grade: " & _StringProper($arrayData[1]) & " x" & $arrayData[2])
			Return $arrayData
		Case "EGG"
			clickUntil($battle_coorSellCancel, "battle-end")
			setLog("Grade: Egg x1")
			Return $arrayData
		Case Else
			setLog("Could not identify starstone.")
			Return -1
	EndSwitch
EndFunc

#cs ----------------------------------------------------------------------------

 Function: gatherData
 Record gem data from the screen

 Returns: [grade, shape, type, stat, sub]
 Author: GkevinOD (2017)

#ce ----------------------------------------------------------------------------
; wood, fire, water, dark, light
; high, mid, low
; main, 1, 2, 3, 4

Global $elementalStone =  [[["393,182,0x5ABA74|399,163,0xC3E472|403,151,0xA6CB2C", "", "473,228,0x36BBAF|472,226,0x50352B|472,221,0x503026|470,225,0x36BCB0", "469,228,0x3D998E|475,228,0x47655B|473,224,0x43746A|471,220,0x4C463C|471,218,0x3AA599", ""], ["", "", "", "", ""], ["", "", "", "", ""]] _
						  ,[["404,155,0xFFAC7C|399,167,0xEA6F6D|392,178,0xD16A76", "467,221,0x36BEB2|467,224,0x36BBB0|467,229,0x47685C|464,220,0x39AA9E|465,225,0x513026", "464,218,0x3BA196|466,221,0x503026|466,226,0x513228|463,223,0x503026|463,228,0x37B7AB|469,226,0x513026|468,220,0x36BCB0", "464,218,0x3BA397|465,221,0x49564C|468,221,0x4A5146|467,225,0x4B5045|469,228,0x4A564B", ""], ["402,154,0xFD6576|398,165,0xDE9676|394,174,0xBE347C|392,179,0xA04374", "461,218,0x3BA196|463,220,0x4C473C|462,226,0x4B4F45|465,221,0x36BBAF|460,226,0x38B5A9|465,228,0x513026", "461,219,0x3D9589|460,228,0x37B7AB|466,228,0x39ABA0|465,221,0x36BBAF|463,226,0x513228|463,221,0x503026", "460,219,0x427B70|462,223,0x37B6AB|461,228,0x36BBAF|463,226,0x513026", "465,225,0x34C6BA|463,224,0x4C463C|465,218,0x3BA196|467,225,0x3D988C|467,222,0x4F382E"], ["402,158,0xFF4F81|397,166,0xE94173|397,176,0x86189D|403,171,0x81137F", "", "", "", "462,226,0x3F8F84|466,226,0x37B8AC|466,219,0x35C3B7|465,224,0x4B4D43|467,228,0x37BAAE"]] _
						  ,[["402,156,0x01E0DE|395,168,0x7BFFFE|394,178,0x337FDE", "", "473,221,0x503026|472,226,0x4B4F45|476,226,0x513026|472,224,0x37BAAE", "472,223,0x37B6AB|472,220,0x4C463C|476,221,0x4F3329|473,226,0x513026", ""], ["", "", "", "", ""], ["", "", "", "", ""]] _
						  ,[["402,167,0xECCCFF|401,155,0xE3C9FF|396,163,0x29F2FF", "", "468,219,0x3D988D|471,228,0x36BBAF|469,226,0x50352B|469,221,0x503026|466,227,0x3BA59A|467,221,0x503026|467,218,0x3C9E92", "467,219,0x3E9488|471,222,0x447368|471,228,0x3AA99D|467,224,0x4E3C32|468,229,0x513126|468,226,0x513026", ""], ["403,153,0xDC61EF|396,163,0x2BEFFE|403,166,0xE757F5", "", "464,219,0x3E8F84|465,228,0x36BFB3|468,226,0x513026|466,221,0x503026|468,220,0x3AA89C|464,221,0x503026", "465,218,0x3AA599|463,221,0x503026|464,228,0x36BBAF|469,221,0x4F372D|466,223,0x34C7BB|466,226,0x513026", "466,223,0x46655B|463,228,0x513026|466,229,0x513126|464,219,0x503026|468,219,0x35C5B9|464,225,0x35C5B9"], ["402,157,0xCF44E9|400,174,0x4E1B9F|396,165,0x8F18BE", "", "", "", "468,224,0x4A5146|471,226,0x36BBAF|471,228,0x3BA599|466,229,0x513126|463,217,0x4F3026|471,222,0x3AA69A"]] _
						  ,[["403,152,0xFFF12A|399,164,0xFEFFFF|406,175,0xF7914A", "", "473,220,0x36BCB0|469,225,0x36BFB3|473,228,0x36BBAF|472,223,0x36BBAF|471,226,0x513228|471,221,0x503026", "473,219,0x35C5B9|471,225,0x513228|374,221,0x4F3329|469,228,0x36BBAF|470,223,0x37B6AB|473,219,0x35C5B9", ""], ["402,154,0xFFDE46|398,163,0x59FFF1|398,175,0xDD6531", "", "470,220,0x36BCB0|465,228,0x37B7AB|468,226,0x513228|468,221,0x503026|470,228,0x36BBAF|470,226,0x513026", "467,223,0x37B6AB|469,219,0x35C0B4|471,221,0x4F3329|466,228,0x3AAA9E|468,225,0x513228", "470,219,0x34C7BB|470,228,0x36BEB2|465,225,0x36BEB2|471,225,0x38B5A9|466,228,0x513026"], ["403,170,0xD5592D|401,158,0xFCD031|398,165,0xE0872D", "", "", "", "470,224,0x4B4D43|471,219,0x35C3B7|467,225,0x34C7BB|472,225,0x35C5B9|472,227,0x36BCB0"]]]

Func gatherData()
	Local $gemData[6];
	If getLocation() = "battle-sell-item" Then
		_CaptureRegion()

		Select ;grade
			Case checkPixels("376,168,0x261612|396,168,0x9DC89C|394,177,0xE3CEA2") ;high starstone
				$gemData[0] = "STARSTONE"
				$gemData[1] = "HIGH"
				If checkPixels("468,219,0x34C6BA|465,223,0x3C9B8F|465,226,0x513026|465,220,0x4C463C") Then
					$gemData[2] = "3"
				ElseIf checkPixels("466,228,0x36BBAF|468,219,0x36BFB3|467,223,0x37B8AC") Then
					$gemData[2] = "2"
				EndIf

				$gemData[3] = "-"
				$gemData[4] = "-"
				$gemData[5] = "-"

				If $gemData[0] = "" Or $gemData[1] = "" Or $gemData[2] = "" Or $gemData[3] = "" Or $gemData[4] = "" Then
					Local $fileCounter = 1
					While FileExists(@ScriptDir & "/unknown-stone" & $fileCounter & ".bmp")
						$fileCounter += 1
					WEnd
					_CaptureRegion("unknown-stone" & $fileCounter & ".bmp")
				EndIf

				Return $gemData
			Case checkPixels("371,162,0x261612|397,162,0xFFFFE4|421,163,0x261612|393,173,0xC1C5A5") ;mid starstone
				$gemData[0] = "STARSTONE"
				$gemData[1] = "MID"
				If checkPixels("466,225,0x35C1B5|461,225,0x34C6BA|465,219,0x35C4B8|462,222,0x3AA69A") Then
					$gemData[2] = "4"
				ElseIf checkPixels("462,221,0x4D3F35|465,221,0x418176|463,225,0x513228|461,228,0x36BBAF|466,228,0x427F74") Then
					$gemData[2] = "3"
				ElseIf checkPixels("461,219,0x3F8C80|461,221,0x503026|460,223,0x503026|463,226,0x4F392F|461,227,0x36BFB3") Then
					$gemData[2] = "2"
				EndIf

				$gemData[3] = "-"
				$gemData[4] = "-"
				$gemData[5] = "-"

				If $gemData[0] = "" Or $gemData[1] = "" Or $gemData[2] = "" Or $gemData[3] = "" Or $gemData[4] = "" Then
					Local $fileCounter = 1
					While FileExists(@ScriptDir & "/unknown-stone" & $fileCounter & ".bmp")
						$fileCounter += 1
					WEnd
					_CaptureRegion("unknown-stone" & $fileCounter & ".bmp")
				EndIf

				Return $gemData
			Case checkPixels("414,164,0x261612|398,163,0x9D7E6A|376,163,0x261612|399,170,0xB9AA96") ;low starstone
				$gemData[0] = "STARSTONE"
				$gemData[1] = "LOW"
				If checkPixels("466,224,0x475E53|464,228,0x513026|469,225,0x3AA79B|462,225,0x3BA599") Then
					$gemData[2] = "4"
				EndIf

				$gemData[3] = "-"
				$gemData[4] = "-"
				$gemData[5] = "-"

				If $gemData[0] = "" Or $gemData[1] = "" Or $gemData[2] = "" Or $gemData[3] = "" Or $gemData[4] = "" Then
					Local $fileCounter = 1
					While FileExists(@ScriptDir & "/unknown-stone" & $fileCounter & ".bmp")
						$fileCounter += 1
					WEnd
					_CaptureRegion("unknown-stone" & $fileCounter & ".bmp")
				EndIf

				Return $gemData
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
		EndIf

		If $gemData[0] = "" Or $gemData[1] = "" Or $gemData[2] = "" Or $gemData[3] = "" Or $gemData[4] = "" Then
			For $element = 0 To 4
				For $grade = 0 To 2
					If checkPixels($elementalStone[$element][$grade][0]) = True Then
						Local $stoneData = getElementalData($element, $grade)
						$gemData[0] = $stoneData[0]
						$gemData[1] = $stoneData[1]
						$gemData[3] = "-"
						$gemData[4] = "-"
						$gemData[5] = "-"

						$gemData[2] = ""
						For $amount = 1 To 4
							If $elementalStone[$element][$grade][$amount] = "" Then ContinueLoop
							If checkPixels($elementalStone[$element][$grade][$amount]) = True Then
								$gemData[2] = $amount
								Return $gemData
							EndIf
						Next
					EndIf
				Next
			Next

			Local $fileCounter = 1
			While FileExists(@ScriptDir & "/unknown-gem" & $fileCounter & ".bmp")
				$fileCounter += 1
			WEnd
			_CaptureRegion("unknown-gem" & $fileCounter & ".bmp")
		EndIf

	EndIf
	Return $gemData
EndFunc

Func getElementalData($element, $grade)
	Local $stoneData = ["", ""]
	Switch $element
		Case 0
			$stoneData[0] = "WOOD"
		Case 1
			$stoneData[0] = "FIRE"
		Case 2
			$stoneData[0] = "WATER"
		Case 3
			$stoneData[0] = "DARK"
		Case 4
			$stoneData[0] = "LIGHT"
	EndSwitch

	Switch $grade
		Case 0
			$stoneData[1] = "HIGH"
		Case 1
			$stoneData[1] = "MID"
		Case 2
			$stoneData[1] = "LOW"
	EndSwitch

	Return $stoneData
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
