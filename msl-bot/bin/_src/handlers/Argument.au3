#include-once

#cs
	Function: Gets value of argument from an array of arguments
	Parameters:
		$aArgs: Array => [[arg1, value1], [arg2, value2]]
		$sName: String => "arg1"
	Return: Value of the found argument => "value1"
#ce
Func getArg($aArgs, $sName, $bSorted = False)
	If ($aArgs = -1) Then Return -1
	
	If isArray($aArgs) = False Or UBound($aArgs) = 0 Then 
		$g_sErrorMessage = "getArg() => Array argument not valid."
		Return -1
	EndIf

	Local $iFind = -1
	If $bSorted = False Then
		$iFind = _ArraySearch($aArgs , $sName)
	Else
		$iFind = _ArrayBinarySearch($aArgs, $sName, 0, 0, 0)
	EndIf
	If $iFind <> -1 Then Return $aArgs [$iFind][1]
	
	$g_sErrorMessage = 'getArg() => Argument not found: "' & $sName & '"'
	Return -1
EndFunc


Func getConfigArg($t_aConfig, $t_sConfig, $t_sDefaultChar, $t_DefaultParam)
    Local $t_sArg = getArg($t_aConfig, $t_sConfig)
    If (StringLeft($t_sArg, 1) <> $t_sDefaultChar) Then Return $t_sArg

	Return $t_DefaultParam
EndFunc

Global $g_aPixels_SORTED = Null
Func getPixelArg($sName)
	;Log_Add("getPixelArg(" & $sName & ")", $LOG_DEBUG)
	Local $t_sName = $sName
	If (StringInStr($sName,"/")) Then
		Local $t_aName = StringSplit($t_sName, "/")
		Local $t_sVal = ""
		For $i = 1 to $t_aName[0]
			Local $t_sPixelVal = getArg($g_aPixels, $t_aName[$i])
			If ($t_sPixelVal = -1) Then ContinueLoop

			$t_sVal &= $t_sPixelVal
			If ($i <> $t_aName[0]) Then $t_sVal &= "/"
		Next
		Return $t_sVal
	ElseIf (StringInStr($sName,",")) Then
		Local $t_aName = StringSplit($t_sName, ",")
		Local $t_sVal = ""
		For $i = 1 to $t_aName[0]
			Local $t_sPixelVal = getArg($g_aPixels, $t_aName[$i])
			If ($t_sPixelVal = -1) Then ContinueLoop

			$t_sVal &= $t_sPixelVal
			If ($i <> $t_aName[0]) Then $t_sVal &= "|"
		Next
		Return $t_sVal
	Else
		If $g_aPixels_SORTED = Null Then 
			$g_aPixels_SORTED = $g_aPixels
			_ArraySort($g_aPixels_SORTED)
		EndIf

		Return getArg($g_aPixels_SORTED, $sName, True)
	EndIf
EndFunc

Global $g_aLocations_SORTED = Null
Func getLocationArg($sName)
	If $g_aLocations_Sorted = Null Then 
		$g_aLocations_Sorted = $g_aLocations
		_ArraySort($g_aLocations_Sorted)
	EndIf

    Return getArg($g_aLocations_Sorted, $sName, True)
EndFunc

Global $g_aPoints_SORTED = Null
Func getPointArg($sName)
	If $g_aPoints_SORTED = Null Then 
		$g_aPoints_SORTED = $g_aPoints
		_ArraySort($g_aPoints_SORTED)
	EndIf

    Return getArg($g_aPoints_SORTED, $sName)
EndFunc

#cs
	Function: Sets value of argument from array of arguments
	Parameters:
		$aArgs: Array => [[arg1, value1], [arg2, value2]]
		$sName: String => "arg1"
		$sValue: New value to set arg to
	Returns:
		True if success, false if argument found.
#ce
Func setArg(ByRef $aArgs, $sName, $sValue)
	Local $iIndex = -1 ;index of argument
	For $i = 0 To UBound($aArgs)-1
		If ($aArgs[$i][0] = $sName) Then 
			$iIndex = $i
			ExitLoop
		EndIf
	Next

	;if not found returns early
	If ($iIndex = -1) Then Return False

	$aArgs[$iIndex][1] = $sValue
	Return True
EndFunc

Func formatArgs($sArgs, $sArgSeparator = ",", $sValueSeparator = "=")
	If $sArgs = -1 Then Return -1
	Local $aArgs[0][2]

	If isArray($sArgs) = False Then
		Local $aArguments = StringSplit($sArgs, $sArgSeparator)
		ReDim $aArgs[$aArguments[0]][2]

		For $i = 1 To $aArguments[0]
			Local $aData = StringSplit($aArguments[$i], $sValueSeparator, 2)
			Local $iSize = UBound($aData)
			If $iSize < 2 Then ContinueLoop
			If $iSize > 2 Then
				For $x = 2 To $iSize-1
					$aData[1] &= $sValueSeparator & $aData[$x]
				Next
			EndIf

			$aArgs[$i-1][0] = $aData[0]
			$aArgs[$i-1][1] = (StringLeft($aData[1], 1) = '"')?StringMid($aData[1], 2, StringLen($aData[1])-2):$aData[1]
		Next
	Else
		Local $iSize = UBound($sArgs)
		ReDim $aArgs[$iSize][2]

		For $i = 0 To $iSize-1
			Local $aArg = $sArgs[$i]
			$aArgs[$i][0] = $aArg[0]
			$aArgs[$i][1] = $aArg[1]
		Next
	EndIf

	;_ArrayDisplay($aArgs)
	Return $aArgs
EndFunc

#cs 
	Function: Reads data from url or file and formats into a readable argument list.
	Parameters:
		$sPathOrUrl: Url or file path for data. Usually in a raw form of text file.
		$sCachePath: Create cache file for remote data.
		$sValueSeparator: The character used to separate value from identifier.
#ce

;~ Func getArgs($sPathOrUrl, $sCachePath = "", $sValueSeparator = ":")
;~ 	Local $t_aData[0]
;~ 	If (StringInStr($sPathOrUrl,"https://") Or StringInStr($sPathOrUrl, "http://")) Then
;~ 		Local $sData = BinaryToString(InetRead($sUrl, $INET_FORCERELOAD))
;~ 		If ($sCachePath <> "") Then
;~ 			Local $hFile = FileOpen($sCachePath, $FO_OVERWRITE+$FO_CREATEPATH)
;~ 			FileWrite($hFile, $sData)
;~ 			FileClose($hFile)
;~ 			$t_aData = _FileReadToArray($sCachePath,)
;~ 		EndIf
;~ 	EndIf
;~ EndFunc

#cs 
	Function: Reads data from url and formats into a readable argument list.
	Parameters:
		$sUrl: Url for data. Usually in a raw form of text file.
		$sArgSeparator: The character used to separate each argument and value.
		$sValueSeparator: The character used to separate value from identifier.
		$sCachePath: Create cache file for remote data.
#ce
Func getArgsFromURL($sUrl, $sArgSeparator = ">", $sValueSeparator = ":", $sCachePath = "")
	Local $sData = BinaryToString(InetRead($sUrl, $INET_FORCERELOAD))
	If ($sCachePath <> "") Then
		Local $hFile = FileOpen($sCachePath, $FO_OVERWRITE+$FO_CREATEPATH)
		FileWrite($hFile, $sData)
		FileClose($hFile)
	EndIf

	If ($sData = "") Then ;Error handle
		$g_sErrorMessage = "getArgFromURL() => No information was found URL: " & $sUrl
		Return -1
	EndIf

	$sData = StringReplace(StringStripCR($sData), @LF, $sArgSeparator)

	While StringLeft($sData, 1) = $sArgSeparator
		$sData = StringMid($sData, 2)
	WEnd

	While StringRight($sData, 1) = $sArgSeparator
		$sData = StringMid($sData, 1, StringLen($sData)-1)
	WEnd

	While StringInStr($sData, $sArgSeparator & $sArgSeparator)
		$sData = StringReplace($sData, $sArgSeparator & $sArgSeparator, $sArgSeparator)
	WEnd

	Return formatArgs($sData, $sArgSeparator, $sValueSeparator)
EndFunc

#cs 
	Function: Reads data from file and formats into a readable argument list.
	Parameters:
		$sPath: Path to file for for data. Usually in a raw form of text file.
		$sArgSeparator: The character used to separate each argument and value.
		$sValueSeparator: The character used to separate value from identifier.
#ce
Func getArgsFromFile($sPath, $sArgSeparator = ">", $sValueSeparator = ":")
	Local $sData = FileRead($sPath)

	If ($sData = "") Then ;Error handle
		$g_sErrorMessage = "getArgFromFile() => No information was found in path: " & $sPath
		Return -1
	EndIf

	$sData = StringReplace(StringStripCR($sData), @LF, $sArgSeparator)
	While StringLeft($sData, 1) = $sArgSeparator
		$sData = StringMid($sData, 2)
	WEnd

	While StringRight($sData, 1) = $sArgSeparator
		$sData = StringMid($sData, 1, StringLen($sData)-1)
	WEnd

	While StringInStr($sData, $sArgSeparator & $sArgSeparator)
		$sData = StringReplace($sData, $sArgSeparator & $sArgSeparator, $sArgSeparator)
	WEnd
	
	Return formatArgs($sData, $sArgSeparator, $sValueSeparator)
EndFunc

#cs 
	Function: Merges two sets of arguments
	Parameters:
		$aFrom: Argument that will be merged to $aTo
		$aTo: Main argument that will be merged.
		$cAppend: Character to separate two values. A blank string will overwrite data.
#ce
Func mergeArgFromTo($aFrom, ByRef $aTo, $cAppend = '')
	For $i = 0 To UBound($aFrom)-1
		Local $sArgValue = $aFrom[$i][1]
		Local $sToArg = getArg($aTo, $aFrom[$i][0])
		If ($sToArg <> -1) Then
			If ($cAppend = '') Then
				setArg($aTo, $aFrom[$i][0], $sArgValue)
			Else
				setArg($aTo, $aFrom[$i][0], $sToArg & $cAppend & $sArgValue)
			EndIf
		Else
			ReDim $aTo[UBound($aTo)+1][2]
			$aTo[UBound($aTo)-1][0] = $aFrom[$i][0]
			$aTo[UBound($aTo)-1][1] = $aFrom[$i][1]
		EndIf
	Next
EndFunc

Func saveAndReloadArgs(ByRef $aArgs)

EndFunc

Func isEnabled($sArg)
	$sArg = StringStripWS($sArg, $STR_STRIPALL)
	Return ($sArg = "enabled")
EndFunc

Func isDisabled($sArg)
	$sArg = StringStripWS($sArg, $STR_STRIPALL)
	Return ($sArg = "disabled")
EndFunc