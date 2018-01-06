#include-once
#include "../imports.au3"

#cs
	Function: Gets value of argument from an array of arguments
	Parameters:
		$aArgs: Array => [[arg1, value1], [arg2, value2]]
		$sName: String => "arg1"
	Return: Value of the found argument => "value1"
#ce
Func getArg($aArgs, $sName)
	If $aArgs = -1 Then Return -1

	For $i = 0 To UBound($aArgs)-1
		If UBound($aArgs) = 0 Then ;Error not valid format
			$g_sErrorMessage = "getArg() => Invalid argument format."
			Return -1
		EndIf
		
		If $aArgs[$i][0] = $sName Then Return $aArgs[$i][1]
	Next

	$g_sErrorMessage = 'getArg() => Argument not found: "' & $sName & '"'
	Return -1
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
		If $aArgs[$i][0] = $sName Then 
			$iIndex = $i
			ExitLoop
		EndIf
	Next

	;if not found returns early
	If $iIndex = -1 Then Return False

	$aArgs[$iIndex][1] = $sValue
	Return True
EndFunc

#cs
	Function: Convert string of arguments into a readable array.
	Parameters:
		$sArgs: String => "arg1=value1,arg2=value2, arg3=value3"
		$sArgSeparator: The character used to separate each argument and value.
		$sValueSeparator: The character used to separate value from identifier.
	Return: Array => [[arg1, value1], [arg2, value2], [arg3, value3]]
#ce
Func formatArgs($sArgs, $sArgSeparator = ",", $sValueSeparator = "=")
	If $sArgs = -1 Then Return -1

	Local $iArgSize = 0
	Local $aArgs[$iArgSize][2] ;Final formated argument array.

	If isArray($sArgs) = False Then
		Local Const $iSize = StringLen($sArgs)

		Local $sName = "", $sValue = ""
		Local $bName = False, $bQuoted = False
		For $i = 0 To $iSize
			Local $sChar = StringMid($sArgs, $i, 1)
			If $bName = False Then ;Handles name
				Switch $sChar
					Case $sArgSeparator, '"'
						$g_sErrorMessage = "formatArgs() => Invalid character in argument name."
						Return -1
					Case $sValueSeparator
						$bName = True
					Case " "
						ContinueLoop
					Case Else
						$sName &= $sChar
				EndSwitch
			Else ;Handles value
				If $sChar = '"' Then 
					$bQuoted = Not($bQuoted)
				Else
					If $bQuoted = False Then 
						If $sChar = " " Then ContinueLoop
						If $sChar = $sArgSeparator Then
							;Indicates finished argument
							$iArgSize += 1
							ReDim $aArgs[$iArgSize][2]

							$aArgs[$iArgSize-1][0] = $sName
							$aArgs[$iArgSize-1][1] = $sValue

							;Reset for next argument
							$bName = False
							$sName = ""
							$sValue = ""
						Else
							$sValue &= $sChar ;Non-quoted
						EndIf
					Else
						$sValue &= $sChar ;Quoted
					EndIf
				EndIf
			EndIf
		Next
		
		If $bQuoted = True Then ;No closing quote
			$g_sErrorMessage = "formatArgs() => Quote has not been closed."
			Return -1
		EndIf

		;Adds last argument
		$iArgSize += 1
		ReDim $aArgs[$iArgSize][2]

		$aArgs[$iArgSize-1][0] = $sName
		$aArgs[$iArgSize-1][1] = $sValue
	Else
		For $i = 0 To UBound($sArgs)-1
			$iArgSize += 1
			ReDim $aArgs[$iArgSize][2]

			Local $aArg = $sArgs[$i]
			$aArgs[$iArgSize-1][0] = $aArg[0]
			$aArgs[$iArgSize-1][1] = $aArg[1]
		Next
	EndIf
	;Formated Argument should be: [[arg1, value1], [arg2, value2], [..., ...]]
	Return $aArgs
EndFunc

#cs 
	Function: Reads data from url and formats into a readable argument list.
	Parameters:
		$sUrl: Url for data. Usually in a raw form of text file.
		$sArgSeparator: The character used to separate each argument and value.
		$sValueSeparator: The character used to separate value from identifier.
#ce
Func getArgsFromURL($sUrl, $sArgSeparator = ">", $sValueSeparator = ":")
	Local $sData = BinaryToString(InetRead($sUrl, $INET_FORCERELOAD))

	If $sData = "" Then ;Error handle
		$g_sErrorMessage = "getArgFromURL() => No information was found URL: " & $sUrl
		Return -1
	EndIf

	$sData = StringReplace($sData, @LF, $sArgSeparator)

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

	If $sData = "" Then ;Error handle
		$g_sErrorMessage = "getArgFromFile() => No information was found in path: " & $sPath
		Return -1
	EndIf

	$sData = StringReplace($sData, @LF, $sArgSeparator)

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
		If $sToArg <> -1 Then
			If $cAppend = '' Then
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