#cs ----------------------------------------------------------------------------

 Function: sellGem

 Sells gem during battle end screen

 Parameters:

	strRecord - Record data to file named in strRecord if not equal to ""

	intMinStar - Number of stars will sell and below.

	intSellFlat - If true then sell, else do not sell. Overrides intKeepAll.

	intKeepAll - Keeps all gems with grade [int] or higher.

	intMinStarForSub - Minimum grade for intMinSub to apply.

	intMinSub - Keeps all gems with substat [int] or higher. Does not override intMinStar.

 Returns:

	On success - Returns gem data

	On fail - Return empty string

#ce ----------------------------------------------------------------------------

Func sellGem($strRecord = "!", $intMinStar = 5, $boolSellFlat = True, $intKeepAll = 6, $intMinStarForSub = 5, $intMinSub = 4)
	Local $boolLog = Not(StringInStr($strRecord, "!"))
	Local $sold = ""
	$strRecord = StringReplace($strRecord, "!", "")

	If waitLocation("battle-sell", 2) Then
		Local $arrayData = ["-", "-", "-", "", "-", "-", ""]

		;egg check
		If isArray(findImage("gem-egg", 75)) Then
			$arrayData[0] = "EGG"
			If Not($strRecord = "") Then recordGem($strRecord, $arrayData)

			clickPointUntil($game_coorTap, "battle-end")
			If $boolLog = True Then setLog("Grade: Egg |Shape: - |Type: - |Stat: - |Substat: -")
			Return $arrayData
		Else ;not egg
			gatherData($arrayData)
			If Not($strRecord = "") Then recordGem($strRecord, $arrayData)

			If ($arrayData[3] = "F.") And ($boolSellFlat = True) Then
				clickPoint($battle_coorSell, 1, 1000)
				clickPointUntil($battle_coorSellConfirm, "battle-end")
				$sold = "!"
			Else
				If (($arrayData[0] <= $intMinStar) And ($arrayData[0] < $intKeepAll)) Then
					If Not (($arrayData[0] >= $intMinStarForSub) And ($arrayData[5] >= $intMinSub)) Then
						clickPoint($battle_coorSell, 1, 1000)
						clickPointUntil($battle_coorSellConfirm, "battle-end")
						$sold = "!"
					EndIf
				EndIf
			EndIf
			;clickPointUntil($game_coorTap, "battle-end")
		EndIf

		If $boolLog = True Then
			Local $strData = $sold & "Grade: " & $arrayData[0] & "* |Shape: "
			If $arrayData[1] = "D" Then $strData &= "Diamond |Type: "
			If $arrayData[1] = "S" Then $strData &= "Square |Type: "
			If $arrayData[1] = "T" Then $strData &= "Triangle |Type: "
			$strData &= _StringProper($arrayData[2]) & " |Stat: "
			If $arrayData[3] = "F." Then $strData &= "Flat "
			If $arrayData[3] = "P." Then $strData &= "Percent "
			$strData &= _StringProper($arrayData[4]) & " |Substat: " & $arrayData[5]

			setLog($strData, 1)
			$arrayData[6] = $strData
		EndIf

		Return $arrayData
	Else
		Return ""
	EndIf
EndFunc

#cs ----------------------------------------------------------------------------

 Function: gatherData

 Record gem data from the screen

 Parameters:

	arrayData - Reference, array to put data in.

 Returns:

	On success - Return 1

	On fail - Returns 0

#ce ----------------------------------------------------------------------------

Func gatherData(ByRef $arrayData)
	If getLocation() = "battle-sell" Then
		Local $gemGrade = findImages($imagesGemGrades, 75)
		If isArray($gemGrade) Then
			$arrayData[0] = 6-$gemGrade[2]
		Else
			Return 0
		EndIf

		Local $tempPixel = [562, 239, 0x281A17]
		Local $tempPixel2 = [579, 270, 0x281A17]

		If Not(checkPixel($tempPixel)) Then
			$arrayData[1] = "S"
		ElseIf Not(checkPixel($tempPixel2)) Then
			$arrayData[1] = "D"
		Else
			$arrayData[1] = "T"
		EndIf

		For $strType In $imagesGemType
			If isArray(findImage($strType, 75)) Then
				$arrayData[2] = StringUpper(StringReplace($strType, "gem-", ""))
				ExitLoop
			EndIf
		Next

		If isArray(findImage("gem-crit-rate", 75)) Then
			$arrayData[3] = ""
			$arrayData[4] = "CRIT RATE"
		ElseIf isArray(findImage("gem-crit-dmg", 75)) Then
			$arrayData[3] = ""
			$arrayData[4] = "CRIT DMG"
		ElseIf isArray(findImage("gem-resist", 75)) Then
			$arrayData[3] = ""
			$arrayData[4] = "RESIST"
		Else
			If isArray(findImage("gem-percent", 75)) Then
				$arrayData[3] = "P."
			Else
				$arrayData[3] = "F."
			EndIf

			For $strStat In $imagesGemStat
				If isArray(findImage($strStat, 75)) Then
					$arrayData[4] = StringUpper(StringReplace($strStat, "gem-", ""))
					ExitLoop
				EndIf
			Next
		EndIf

		If isArray(findColor(530, 570, 451, 451, 0xE9E3DE, 20)) Then
			$arrayData[5] = "4"
		ElseIf isArray(findColor(530, 570, 432, 432, 0xE9E3DE, 20)) Then
			$arrayData[5] = "3"
		Else
			$arrayData[5] = "2"
		EndIf

		Return 1
	Else
		setLog("Could not gather gem data.")
		Return 0
	EndIf
EndFunc
