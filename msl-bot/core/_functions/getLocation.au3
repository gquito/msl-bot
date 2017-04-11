#cs ----------------------------------------------------------------------------
 Function: getLocation
 Find location within the game.

 Returns:
	One of the main location or unknown.
#ce ----------------------------------------------------------------------------

Func getLocation()
	_CaptureRegion()

	If isArray($listLocation) = False Then loadLocation()
	Local $result = "unknown"
	For $location In $listLocation
		If checkPixels(StringStripWS($location[1], 8), 20) = True Then
			_Sleep(100)

			;double check after 100 millisecond delay or 1/10 of a second.
			_CaptureRegion()
			If checkPixels(StringStripWS($location[1], 8), 20) = True Then
				$result = $location[0]
				ExitLoop
			EndIf
		EndIf
	Next

	#cs
	If FileExists(@ScriptDir & "/core/location-examples/" & $result & ".bmp") = False Then
		_CaptureRegion("/core/location-examples/" & $result & ".bmp")
	EndIf
	#ce

	Return $result
EndFunc

#cs
 Function: loadLocation
	Load a text file into a global variable named $listLocation

 Parameters:
	dir: File path of the locations.txt
	locationExtra: To stop recursion

 Return: boolean on success status

 Author: GkevinOD(2017)
#ce
Func loadLocation($dir = @ScriptDir & "\core\locations.txt", $locationExtra = False)
	If $locationExtra = False Then
		Global $listLocation[0]
		loadLocation(@ScriptDir & "\core\locations-extra.txt", True) ;To include the locations extra for the user
	EndIf

	If FileExists($dir) = False Then Return 0

	Local $fileLocation = FileOpen($dir, $FO_READ) ;opening file
	If $fileLocation = -1 Then Return 0 ;check file status for error

	Local $tempListLocation = FileRead($fileLocation)
	$tempListLocation = StringSplit($tempListLocation, @LF, 2)

	For $index = 0 To UBound($tempListLocation)-1
		If StringMid($tempListLocation[$index], 1, 1) = ";" Or StringStripWS($tempListLocation[$index], 8) = "" Then ;check for comment and empty elements
			ContinueLoop
		EndIf

		_ArrayAdd($listLocation, StringSplit($tempListLocation[$index], ":", 2), default, default, default, 1) ;add item into list
	Next

	FileClose($fileLocation)

	Return 1
EndFunc