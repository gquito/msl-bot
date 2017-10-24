#include-once
#include "../imports.au3"

#cs
	Function: Captures region and if there is saves into bmp if there is a specified file name.
	Parameters:
		$sFileName: File name saved to main folder.
#ce
Func captureRegion($sFileName = "")
	getBitmapHandles($g_hHBitmap, $g_hBitmap)

	If $sFileName <> "" Then
		$sFileName = StringReplace($sFileName, ".bmp", "")
		saveHBitmap($sFileName)
	EndIf
EndFunc

#cs
    Function: Retrieves current game location.
	Parameters:
		$aLocations: Format=[["LOCATION_NAME", "PIXEL_SET"], [...]]
	Returns: String game location.
#ce
Func getLocation($aLocations = $g_aLocations)
	captureRegion() ;Updates global bitmap

	;Going through location data and using isPixelAND() function to check each location.
	Local Const $iSize = UBound($aLocations)
	If $iSize = 0 Or isArray($aLocations) = False Or isArray($aLocations[0]) = False Then
		$g_sErrorMessage = "getLocation() => Invalid argument."
		Return -1
	EndIf

	Local $t_sLocation = "" ;Temporary location to double check location.
	For $i = 0 To $iSize-1
		Local $t_aLocation = $aLocations[$i]
		;_ArrayDisplay($t_aLocation)

		If isPixelOR($t_aLocation[1], 20) = True Then
			;checks in 200 miliseconds for same location.
			If _Sleep(200) Then Return -2
			captureRegion()

			If isPixelOR($t_aLocation[1], 20) = True Then
				Return $t_aLocation[0] ;Returns confirmed location.
			EndIf
		EndIf
	Next

	Return "unknown" ;If no location from database is found.
EndFunc

#cs
	Function: Waits for a location to appear and returns when it does.
	Parameters:
		$vLocations: Array or stirng of locations. Format=["location", "..."] or "location,..."
		$iInterval: How long to wait for in milliseconds
		$bReturnBool: If false, returns the location string found.
	Returns: String or Boolean depending on $bReturnBool
#ce
Func waitLocation($vLocations, $iInterval, $bReturnBool = False)
	Local $iTimerInit = TimerInit()
	While (TimerDiff($iTimerInit) < $iInterval)
		Local $t_vResult = isLocation($vLocations, $bReturnBool)
		If $t_vResult = True Or $t_vResult <> "" Then
			Return $t_vResult
		EndIf

		If _Sleep(100) Then Return -2
	WEnd

	;Not found within timeframe
	If $bReturnBool = True Then Return False
	Return ""
EndFunc

#cs
	Function: Checks if any one of the locations from the specified set of locations are
	Parameters:
		$vLocations: Array or stirng of locations. Format=["location", "..."] or "location,..."
		$bReturnBool: If false, returns the location string found.
	Returns: String or Boolean depending on $bReturnBool
#ce
Func isLocation($vLocations, $bReturnBool = True)
	Local $aLocations = []
	Local $sCurrLocation = getLocation()

	If $sCurrLocation = -1 Then Return -1

	;Fixing argument format= ["location", "..."]
	If isArray($vLocations) = False Then
		;Expected format: "location, ..."
		$vLocations = $STR_STRIPALL ;Removes all whitespace.
		$aLocations = StringSplit($vLocations, ",", $STR_NOCOUNT)
	Else
		$aLocations = $vLocations
	EndIf

	;Checking array if location exists
	For $sLocation In $aLocations
		If $sLocation = $sCurrLocation Then
			;found
			If $bReturnBool = True Then Return True
			Return $sLocation
		EndIf
	Next

	;not found
	If $bReturnBool = True Then Return False
	Return ""
EndFunc

#cs
	Function: Retrieves which round the battle is currently.
	Return: 1-4 If success. 0 If round was not found.
#ce
Func getRound()
	If isLocation("unknown,battle,battle-auto") Then Return 0
	;If isPixel(getArg($g_aPixels, "round"))
EndFunc

#cs 
	Function: Tries to close a in game window interface.
	Return: If window was closed successfully then return true. Else return false.
#ce
Func closeWindow()

EndFunc

#cs 
	Function: Tries to close dialogue between players in game
	Return: If dialogue has been closed successfully then return true. Else return false.
#ce
Func skipDialogue()

EndFunc