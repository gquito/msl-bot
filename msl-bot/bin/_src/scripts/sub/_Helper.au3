#include-once
#include "../../imports.au3"

#cs
	Function: Returns a 2D array of the location of a specified map
	Parameters:
		- $map: String of the map, case sensitive.
	Return:
		- A 2D array: [x, y]
		*On error or not found, returns -1
	Pre-condition:
		- Global variable, $g_aCoorMaps, should be defined. [[MAP, MARK, X-DISPLACE, Y-DISPLACE], [...], [...]]
#ce
Func getMapCoor($map)
	Local $arrMarks = _getMapMarks() ;[["A", 0, 0], [...], [...]]
	Local $pointDisplacement ;Creates final coordination of map with sum of the mark

	;Returns early if there are no marks found
	If UBound($arrMarks) = 0 Then Return -1

	;Checking if $map exists in $coorMaps
	For $i = 0 To UBound($g_aCoorMaps, $UBOUND_ROWS)-1
		If $g_aCoorMaps[$i][0] = $map Then
			;Checking if the mark exists on $arrMarks.
			For $x = 0 To UBound($arrMarks, $UBOUND_ROWS)-1
				Local $myMark = $arrMarks[$x]

				If $g_aCoorMaps[$i][1] = $myMark[0] Then
                    Local $pointDisplacement = [$g_aCoorMaps[$i][2], $g_aCoorMaps[$i][3]]

					ExitLoop(2)
				Else
					ContinueLoop
				EndIf
			Next
		EndIf
	Next

	;Returns early if $map does not exist or $mark does not exist
	If isArray($pointDisplacement) = False Then Return -2

	Local $finalX = $myMark[1] + $pointDisplacement[0]
	Local $finalY = $myMark[2] + $pointDisplacement[1]

	;Returns early if final coordinations are out of bounds.
	If ($finalX < 0) Or ($finalX > $g_aControlSize[0]) Or ($finalY < 0) Or ($finalY > $g_aControlSize[1]) Then
		Return -3
	EndIf

	;Output
	Local $returnPoint = [$finalX, $finalY]
	Return $returnPoint
EndFunc

#cs
	Function: Helper function for getMapCoor. Retrieves an array of visible marks and their points.
	Return:
		- An array of string and point. [[STRING, X, Y], [...], [...]]
		*Returns empty array if nothing is found.
	Pre-condition:
		- Global variable, $g_aImageMarks, must be defined. [STRING, STRING, ...]
#ce
Func _getMapMarks()
	Local $finalArr[0] ;Empty array for marks.

	;Adding marks that are found in map
	For $myMark In $g_aImageMarks
		Local $imageCoor = findImage($myMark, 100)

		;If image found then it adds a mark into $finalArr
		If isArray($imageCoor) Then
			Local $newMark = [$myMark, $imageCoor[0], $imageCoor[1]]
			_ArrayAdd($finalArr, $newMark, 0, default, default, 1) ;Force as single item
		EndIf
	Next

	;Output
	Return $finalArr
EndFunc

#cs
	Function: Retrieves data of current gem on screen. Works during battle-sell-item location
	Parameters:
		$bCapture: Save unknown gems
	Returns: [grade, shape, type, stat, sub, price]
#ce
Func getGemData($bCapture = True)
	Local $aGemData[6] = ["-", "-", "-", "-", "-", "-"] ;Stores current gem data
	If getLocation() = "battle-sell-item" Then
		Select ;grade
			Case isPixel("399,175,0xF39C72|399,164,0xF769BA|406,144,0x261612")
				$aGemData[0] = "EGG"
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
			If isPixelOR(StringSplit($strType, ":", 2)[1], 20) Then
				$aGemData[2] = StringSplit($strType, ":", 2)[0]
				ExitLoop
			EndIf
		Next

		For $strStat In $g_aGem_pixelStats ;main stats
			If isPixelOR(StringSplit($strStat, ":", 2)[1], 20) Then
				$aGemData[3] = StringSplit($strStat, ":", 2)[0]
				ExitLoop
			EndIf
		Next

		If isArray(findColor("350,329", "50,1", "0xE9E3DE", 20)) Then ;number of substats
			$aGemData[4] = "4"
		ElseIf isArray(findColor("350,311", "50,1", "0xE9E3DE", 20)) Then
			$aGemData[4] = "3"
		ElseIf isArray(findColor("350,296", "50,1", "0xE9E3DE", 20)) Then
			$aGemData[4] = "2"
		ElseIf isArray(findColor("350,329", "50,1", "0xE9E3DE", 20)) Then
			$aGemData[4] = "1"
		EndIf

		$aGemData[5] = getGemPrice($aGemData)

		;Handles if gem is unknown
		If ($bCapture = True) And (($aGemData[0] = "-") Or ($aGemData[1] = "-") Or ($aGemData[2] = "-") Or ($aGemData[3] = "-") Or ($aGemData[4] = "-")) Then
			Local $iCounter = 1
			While FileExists(@ScriptDir & $g_sProfilePath & "/unknown-gem" & $iCounter & ".bmp")
				$iCounter += 1
			WEnd
			CaptureRegion($g_sProfilePath & "/unknown-gem" & $iCounter & ".bmp")
		EndIf
	EndIf
	Return $aGemData
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
		If StringInStr($g_aGemRanks[$i], $aGemData[2]) = True Then
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

	;Gem prices are location in 3 different arrays organized in ranks. Refer to Global variables.
	Return Int(Execute("$g_aGemGrade" & $aGemData[0] & "Price[" & $iSub & "][" & $iRank & "]"))
EndFunc

#cs 
	Function: Filters gems that do not meet the criteria
	Parameters:
		$aGemData: Gem data. Refer to getGemData() function.
		$aFilter: format=[[4*-Filter, ""], [4*-Types, ""], [4*-Stats, ""], [4*-Substats, ""], ...]
	Returns:
		If the gem meets the criteria returns true; otherwise, returns false.
#ce
Func filterGem($aGemData, $aFilter = formatArgs(getScriptData($g_aScripts, "_Filter")[2]))
	Local $iGrade = $aGemData[0]
	If getArg($aFilter, $iGrade & "*-Filter") = "Disabled" Then Return False

	If StringInStr(getArg($aFilter, $iGrade & "*-Types"), $aGemData[2]) = False Then Return False
	If StringInStr(getArg($aFilter, $iGrade & "*-Stats"), $aGemData[3]) = False Then Return False
	If StringInStr(getArg($aFilter, $iGrade & "*-Substats"), $aGemData[4]) = False Then Return False

	Return True
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
	If StringInStr($aGemData[3], ".") = True Then
		Local $t_aSplit = StringSplit($aGemData[3], ".", $STR_NOCOUNT)

		$sStat = "+"
		If $t_aSplit[0] = "P" Then $sStat = "%"

		$sStat &= _StringProper($t_aSplit[1])
	Else
		$sStat = _StringProper($aGemData[3])
	EndIf

	Local $sSub = "[Substat]"
	$sSub = $aGemData[4] & " Substat"
	If $aGemData[4] > 1 Then $sSub &= "s"

	Return $aGemData[0] & "*; " & $sShape & "; " & $sType & "; " & $sStat & "; " & $sSub
EndFunc
