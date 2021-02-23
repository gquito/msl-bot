#include-once

#cs
    Function: Retrieves current game location.
	Returns: String game location.
	Extended: Location pixel data.
#ce
Func getLocation($bUpdate = True, $bSkipImage = False)
	If TimerDiff($g_hGetLocationCoolDown) < 100 Then Return $g_sLocation
	$g_hGetLocationCoolDown = TimerInit()

	If $g_sLocation == "unknown" And TimerDiff($g_hTimerLocation) > 3000 Then $g_iLocationIndex = -1
	If $g_hTimerLocation = Null Then $g_hTimerLocation = TimerInit()

	Local $sOldLocation = $g_sLocation

	If $bUpdate > 0 Then CaptureRegion()
	If $g_iLocationIndex <> -1 And $g_aLocationsMap[$g_iLocationIndex][0] <> -1 Then
		For $i = 0 To $g_aLocationsMap[$g_iLocationIndex][0]-1
			Local $aIndices = $g_aLocationsMap[$g_iLocationIndex][1]
			Local $sLocation = $g_aLocations[$aIndices[$i]][0]
			Local $sPixelSet = $g_aLocations[$aIndices[$i]][1]

			If isPixel($sPixelSet, 20) > 0 Then
				Local $LocationArray = [$sLocation, $sPixelSet] 
				_ArrayAdd($g_vDebug, $LocationArray)

				$g_sLocation = $sLocation
				If ($g_sLocation <> $sOldLocation) Then $g_hTimerLocation = TimerInit()
				$g_iLocationIndex = $aIndices[$i]

				Return $g_sLocation
			EndIf
		Next
	Else
		For $i = 0 To UBound($g_aLocations)-1
			Local $sLocation = $g_aLocations[$i][0]
			Local $sPixelSet = $g_aLocations[$i][1]

			If isPixel($sPixelSet, 20) > 0 Then
				Local $LocationArray = [$sLocation, $sPixelSet] 
				_ArrayAdd($g_vDebug, $LocationArray)

				$g_sLocation = $sLocation
				If ($g_sLocation <> $sOldLocation) Then $g_hTimerLocation = TimerInit()
				$g_iLocationIndex = $i

				Return $g_sLocation
			EndIf
		Next
	EndIf

	;Image locations
	If $bSkipImage <= 0 And $g_iLocationIndex = -1 Then
		;$g_aImageLocation = [[NAME, 'x,y,w,h,"image"|x,y,w,h,"image"|...'], [...]]
		If isArray($g_aImageLocations) > 0 Then
			For $i = 0 To UBound($g_aImageLocations)-1
				If UBound($g_aImageLocations, 2) <> 2 Then ExitLoop

				Local $sLocation = $g_aImageLocations[$i][0] ;name
				Local $aLocationData_Set = StringSplit($g_aImageLocations[$i][1], "|", 2)
				For $sLocationData In $aLocationData_Set
					Local $aLocationData = StringSplit($sLocationData, ",", 2)
					If isArray($aLocationData) <= 0 And UBound($aLocationData) <> 5 Then ExitLoop
					
					Local $sImage = StringReplace($aLocationData[4], '"', "")
					Local $aImage = findImage($sImage, 90, 0, $aLocationData[0], $aLocationData[1], $aLocationData[2], $aLocationData[3], True, True)
					If isArray($aImage) > 0 Then
						$g_sLocation = $sLocation
						Return $g_sLocation
					EndIf
				Next
			Next
		EndIf
    EndIf

	$g_sLocation = "unknown"
	If ($g_sLocation <> $sOldLocation) Then $g_hTimerLocation = TimerInit()

	Return $g_sLocation ;If no location from database is found.
EndFunc

#cs
	Function: Waits for a location to appear and returns when it does.
	Parameters:
		$vLocations: Array or stirng of locations. Format=["location", "..."] or "location,..."
		$iSeconds: How long to wait for in seconds
		$bReturnBool: If false, returns the location string found.
	Returns: String or Boolean depending on $bReturnBool
#ce
Func waitLocation($vLocations, $iSeconds, $iDelay = 200, $bReturnBool = True)
	Local $bOutput = ($bReturnBool? False : "")
	Log_Level_Add("waitLocation()")
	Local $iTimerInit = TimerInit()	
	While TimerDiff($iTimerInit) < $iSeconds*1000
		$bOutput = isLocation($vLocations, $bReturnBool)
		If ($bOutput) Then ExitLoop

		If (_Sleep($iDelay)) Then ExitLoop
	WEnd

	;Not found within timeframe
	;Log_Add("waitLocation(" & $vLocations & ", " & $iSeconds*1000 & ", " & $iDelay & ", " & $bReturnBool & ") Result: " & $bOutput, $LOG_DEBUG)
	Log_Level_Remove()
	Return $bOutput
EndFunc

Func waitLocationMS($vLocations, $iMSeconds, $iDelay = 200, $bReturnBool = True)
	Local $bOutput = ($bReturnBool? False : "")
	Log_Level_Add("waitLocation(" & $vLocations & ", " & $iMSeconds * ", " & $iDelay & ", " & $bReturnBool & ")")
	Local $iTimerInit = TimerInit()	
	While TimerDiff($iTimerInit) < $iMSeconds
		$bOutput = isLocation($vLocations, $bReturnBool)
		If ($bOutput) Then ExitLoop

		If (_Sleep($iDelay)) Then ExitLoop
	WEnd

	;Not found within timeframe
	Log_Level_Remove()
	Return $bOutput
EndFunc

#cs
	Function: Checks if any one of the locations from the specified set of locations are
	Parameters:
		$vLocations: Array or stirng of locations. Format=["location", "..."] or "location,..."
		$bReturnBool: If false, returns the location string found.
	Returns: String or Boolean depending on $bReturnBool
#ce
Func isLocation($vLocations, $bReturnBool = True, $bSorted = False)
	Local $aLocations = Null
	Local $bPopupWindow = StringInStr($vLocations,"popup-window")
	Local $sCurrLocation = getLocation(True, Not($bPopupWindow))
	If ($sCurrLocation = -1) Then Return False

	If isArray($vLocations) = 0 Then
		If StringInStr($vLocations, ",") = 0 Then 
			If $bReturnBool > 0 Then Return $sCurrLocation = $vLocations
			If $sCurrLocation = $vLocations Then Return $vLocations
			Return ""
		EndIf

		$vLocations = StringStripWS($vLocations, $STR_STRIPALL) ;Removes all whitespace.
		$aLocations = StringSplit($vLocations, ",", $STR_NOCOUNT)
	Else
		$aLocations = $vLocations
	EndIf

	Local $iIndex = -1
	If $bSorted = 0 Then
		$iIndex = _ArraySearch($aLocations, $sCurrLocation)
	Else
		$iIndex = _ArrayBinarySearch($aLocations, $sCurrLocation)
	EndIf

	If $bReturnBool > 0 Then
		Return ($iIndex <> -1)
	Else
		If $iIndex <> -1 Then 
			Return $aLocations[$iIndex]
		Else
			Return ""
		EndIf
	EndIf
EndFunc

#cs 
	Function: Creates a local location data.
	Parameters:
		$sLocation: New or exisiting location.
		$aData: If location does not exist, will create location based on array of points. Format: "123,321|564,456|..." or ["123, 321", "321, 123", "...,..."]
	Returns: 
		- On successful, true
		- On failure, false
#ce
Func setLocation($sLocation, $aData = Null, $bUpdate = True)
	Local $aLocation = getArg($g_aLocations, $sLocation)
	Local $aPoints[0][2] ;Will store points to find colors for.
	
	If ($aLocation = -1) Then
		;Creates new location.
		If isArray($aData) = 0 Then $aData = StringSplit(StringStripWS($aData, 4), "|", $STR_NOCOUNT)

		For $i = 0 To UBound($aData)-1
			Local $aPoint = StringSplit($aData[$i], ",", $STR_NOCOUNT)

			ReDim $aPoints[UBound($aPoints)+1][2]
			$aPoints[UBound($aPoints)-1][0] = $aPoint[0]
			$aPoints[UBound($aPoints)-1][1] = $aPoint[1]
		Next
	Else
		;Creates local version of the location. This location will be prioritized versus the remote location.
		Local $sPixelSet = $aLocation
		If (StringInStr($sPixelSet, "/")) Then $sPixelSet = StringSplit($sPixelSet, "/", $STR_NOCOUNT)[0]

		Local $aPixels = StringSplit($sPixelSet, "|", $STR_NOCOUNT)
		ReDim $aPoints[UBound($aPixels)][2]
		For $i = 0 To UBound($aPixels)-1
			Local $aPixel = StringSplit($aPixels[$i], ",", $STR_NOCOUNT)

			$aPoints[$i][0] = Int($aPixel[0])
			$aPoints[$i][1] = Int($aPixel[1])
		Next
	EndIf

	If $bUpdate > 0 Then CaptureRegion()

	Local $sNewPixels = "" ;Will store new pixel set
	For $i = 0 To UBound($aPoints)-1
		$sNewPixels &= "|" & $aPoints[$i][0] & "," & $aPoints[$i][1] & "," & getColor($aPoints[$i][0], $aPoints[$i][1])
	Next
	$sNewPixels = StringMid($sNewPixels, 2)

	Local $hFile = FileOpen($g_sLocalDataFolder & $g_sLocations, $FO_APPEND+$FO_CREATEPATH)
	Local $bOutput = (FileWrite($hFile, @CRLF & $sLocation & ":" & $sNewPixels) = 1)
	FileClose($hFile)

	mergeArgFromTo(getArgsFromFile($g_sLocalDataFolder & $g_sLocations), $g_aLocations, "/")
	Return $bOutput
EndFunc

; Calls getLocation() in .2 second intervals until debug stopped.
Func testLocation()
	$g_bAntiStuck = False
	While Not(_Sleep(200))
		$g_iLocationIndex = -1
		Log_Add(getLocation())
	WEnd
	$g_bAntiStuck = True
EndFunc

Func CreateLocationsMap(ByRef $aLocationsMap, ByRef $aLocations)
	Local $iSize = UBound($aLocations)

    Local $t_aMapped[$iSize][2] ;Contain final location map
    For $a = 0 To $iSize-1
        Local $sContent = getArg($aLocationsMap, $aLocations[$a][0]) ;Find corresponding mapped location from name
        If $sContent <> -1 Then ;if exist
            $sContent = $aLocations[$a][0] & "," & $sContent ;Add current location as first in search and other mapped locations

            Local $aContents = StringSplit($sContent, ",") 
            Local $aIndex[0] ;List of index
            For $b = 1 To $aContents[0] ;traverse mapped array
                For $c = 0 To $iSize-1 ;traverse location array
                    If $aContents[$b] = $aLocations[$c][0] Then
                        _ArrayAdd($aIndex, $c)
                    EndIf
                Next
            Next

            _ArraySort($aIndex)
            $t_aMapped[$a][0] = UBound($aIndex)
            $t_aMapped[$a][1] = $aIndex
        Else
            $t_aMapped[$a][0] = -1
        EndIf
    Next
    $aLocationsMap = $t_aMapped
EndFunc