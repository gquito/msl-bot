#include-once

Func getArg($aArgs, $sName)
	If isArray($aArgs) = False Or UBound($aArgs, $UBOUND_DIMENSIONS) <> 2 Then Return SetError(1, 0, "")

	Local $iFind = _ArraySearch($aArgs, $sName, 0, 0, 0, 0, 1, 0)
	If @error And @error <> 6 Then Return SetError(2, 0, "")

	If $iFind <> -1 Then Return $aArgs[$iFind][1]
	Return SetError(3, 1, "")
EndFunc

Func setArg(ByRef $aArgs, $sName, $sValue)
	If isArray($aArgs) = False Or UBound($aArgs, $UBOUND_DIMENSIONS) <> 2 Then Return SetError(1, 0, False)

	Local $iIndex = _ArraySearch($aArgs, $sName, 0, 0, 0, 0, 1, 0)
	If @error And @error <> 6 Then Return SetError(2, @error, False)

	If $iIndex <> -1 Then
		$aArgs[$iIndex][1] = $sValue
	Else
		_ArrayAdd($aArgs, $sName)
		If @error Then Return SetError(3, 0, False)
		$aArgs[UBound($aArgs)-1][1] = $sValue
	EndIf
	
	Return True
EndFunc

Func getConfigArg($t_aConfig, $t_sConfig, $t_sDefaultChar, $t_DefaultParam)
    Local $t_sArg = getArg($t_aConfig, $t_sConfig)
    If (StringLeft($t_sArg, 1) <> $t_sDefaultChar) Then Return $t_sArg

	Return $t_DefaultParam
EndFunc

Func getPixelArg($sName)
	Return getArg($g_aPixels, $sName)
EndFunc


Func getArgs($sData, $sDelimeter = ":")
	Local $sPattern = "(.*)(?:\Q" & $sDelimeter & "\E)(.*)"
	Local $aMatches = StringRegExp($sData, $sPattern, $STR_REGEXPARRAYGLOBALMATCH)

	Local $iSize = UBound($aMatches) / 2
	Local $aArgs[$iSize][2]

	If isArray($aMatches) = True Then
		For $i = 0 To $iSize-1
			$aArgs[$i][0] = $aMatches[$i*2]
			$aArgs[$i][1] = StringReplace($aMatches[$i*2+1], '"', "")
		Next
	EndIf

	Return $aArgs
EndFunc

Func getArgsFromURL($sUrl, $sDelimeter = ":", $sCachePath = "")
	Local $sData = BinaryToString(InetRead($sUrl, $INET_FORCERELOAD))
	If ($sCachePath <> "") Then
		Local $hFile = FileOpen($sCachePath, $FO_OVERWRITE+$FO_CREATEPATH)
		FileWrite($hFile, $sData)
		FileClose($hFile)
	EndIf

	Return getArgs($sData, $sDelimeter)
EndFunc

Func getArgsFromFile($sPath, $sDelimeter = ":")
	Local $sData = FileRead($sPath)
	If @error Then Return SetError(1, 0, 0)

	Return getArgs($sData, $sDelimeter)
EndFunc

Func mergeArgFromTo($aFrom, ByRef $aTo, $cAppend = '/')
	If (isArray($aFrom) = False Or isArray($aTo) = False) Or _
	   (UBound($aFrom, $UBOUND_DIMENSIONS) <> 2) Then

		Return SetError(1, 0, False)
	EndIf

	For $i = 0 To UBound($aFrom)-1
		Local $sName = $aFrom[$i][0]
		Local $sValue = $aFrom[$i][1]

		Local $sCurrent = getArg($aTo, $sName)
		If @error And Not(@extended) Then Return SetError(2, 0, False)
		If @extended Then ;Not found
			setArg($aTo, $sName, $sValue)
		Else
			setArg($aTo, $sName, $sCurrent & $cAppend & $sValue)
		EndIf
	Next

	Return True
EndFunc

Func getLocationArg($sName)
    Return getArg($g_aLocations, $sName)
EndFunc

Func getPointArg($sName)
    Return getArg($g_aPoints, $sName)
EndFunc

; Format Script Arguments
Func formatArgs($aScript)
	If isArray($aScript) = False Then Return SetError(1, 0, -1)

	Local $iSize = UBound($aScript)
	Local $aArgs[$iSize][2]

	For $i = 0 To $iSize-1
		Local $aSetting = $aScript[$i]
		If isArray($aSetting) = False Or UBound($aSetting) < 2 Then Return SetError(2, 0, -1)

		$aArgs[$i][0] = $aSetting[0]
		$aArgs[$i][1] = StringReplace($aSetting[1], '"', "")
	Next

	Return $aArgs
EndFunc