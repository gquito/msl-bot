#include-once
#include "../imports.au3"

#cs
	Function: Gets value of argument from an array of arguments
	Parameters:
		$aArgs: Array => [[arg1, value1], [arg2, value2]]
		$name: String => "arg1"
	Return: Value of the found argument => "value1"
#ce
Func getArg($aArgs, $name)
	If $aArgs = -1 Then Return -1

	For $i = 0 To UBound($aArgs)-1
		If UBound($aArgs) = 0 Then ;Error not valid format
			$g_sErrorMessage = "getArg() => Invalid argument format."
			Return -1
		EndIf
		
		If $aArgs[$i][0] = $name Then Return $aArgs[$i][1]
	Next

	$g_sErrorMessage = 'getArg() => Argument not found: "' & $name & '"'
	Return -1
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
	Local $iArgSize = 0
	Local $aArgs[$iArgSize][2] ;Final formated argument array.
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
		$g_sErrorMessage = "getArgFromURL() => No information was found: " & $sUrl
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
		$g_sErrorMessage = "getArgFromURL() => No information was found: " & $sPath
		Return -1
	EndIf

	$sData = StringReplace($sData, @LF, $sArgSeparator)

	Return formatArgs($sData, $sArgSeparator, $sValueSeparator)
EndFunc