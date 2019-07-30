#include-once
#include "../imports.au3"

#cs
    Function: Retrieves current game location.
	Returns: String game location.
	Extended: Location pixel data.
#ce
Func getLocation($bUpdate = True, $bSkipImage = False)
	If TimerDiff($g_hGetLocationCoolDown) < 100 Then Return $g_sLocation
	$g_hGetLocationCoolDown = TimerInit()

	If ($g_hTimerLocation = Null Or TimerDiff($g_hTimerLocation) > 5000) And $g_sLocation = "unknown" Then $g_iLocationIndex = -1
	
	If ($g_hTimerLocation = Null) Then $g_hTimerLocation = TimerInit()
	Local $sOldLocation = $g_sLocation

	If $bUpdate = True Then CaptureRegion()
	If $g_iLocationIndex <> -1 And $g_aLocationsMap[$g_iLocationIndex][0] <> -1 Then
		For $i = 0 To $g_aLocationsMap[$g_iLocationIndex][0]-1
			Local $aIndices = $g_aLocationsMap[$g_iLocationIndex][1]
			Local $sLocation = $g_aLocations[$aIndices[$i]][0]
			Local $sPixelSet = $g_aLocations[$aIndices[$i]][1]

			If isPixel($sPixelSet, 20) = True Then
				Local $LocationArray = [$sLocation, $sPixelSet] 
				_ArrayAdd($g_vDebug, $LocationArray)

				$g_sLocation = $sLocation
				If ($g_sLocation <> $sOldLocation) Then $g_hTimerLocation = TimerInit()
				If $g_sLocation <> "unknown" Then $g_iLocationIndex = $aIndices[$i]

				Return $g_sLocation
			EndIf
		Next
	Else
		For $i = 0 To UBound($g_aLocations)-1
			Local $sLocation = $g_aLocations[$i][0]
			Local $sPixelSet = $g_aLocations[$i][1]

			If isPixel($sPixelSet, 20) = True Then
				Local $LocationArray = [$sLocation, $sPixelSet] 
				_ArrayAdd($g_vDebug, $LocationArray)

				$g_sLocation = $sLocation
				If ($g_sLocation <> $sOldLocation) Then $g_hTimerLocation = TimerInit()
				If $g_sLocation <> "unknown" Then $g_iLocationIndex = $i

				Return $g_sLocation
			EndIf

		Next
	EndIf

    If (Not($bSkipImage)) Then
        Local $imageLocation = checkImageLocations()
        If ($imageLocation <> False) Then return $imageLocation
    EndIf
	$g_vDebug = ""

	$g_sLocation = "unknown"
	If ($g_sLocation <> $sOldLocation) Then $g_hTimerLocation = TimerInit()

	Return $g_sLocation ;If no location from database is found.
EndFunc

Func getCurrentLocation()
	Return $g_sLocation
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
	Log_Level_Add("waitLocation(" & $vLocations & ", " & $iSeconds * ", " & $iDelay & ", " & $bReturnBool & ")")
	Local $iTimerInit = TimerInit()	
	While TimerDiff($iTimerInit) < $iSeconds*1000
		$bOutput = isLocation($vLocations, $bReturnBool)
		If ($bOutput) Then ExitLoop

		If (_Sleep($iDelay)) Then ExitLoop
	WEnd

	;Not found within timeframe
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

	If isArray($vLocations) = False Then
		If StringInStr($vLocations, ",") = 0 Then 
			If $bReturnBool = True Then Return $sCurrLocation = $vLocations
			If $sCurrLocation = $vLocations Then Return $vLocations
			Return ""
		EndIf

		$vLocations = StringStripWS($vLocations, $STR_STRIPALL) ;Removes all whitespace.
		$aLocations = StringSplit($vLocations, ",", $STR_NOCOUNT)
	Else
		$aLocations = $vLocations
	EndIf

	Local $iIndex = -1
	If $bSorted = False Then
		$iIndex = _ArraySearch($aLocations, $sCurrLocation)
	Else
		$iIndex = _ArrayBinarySearch($aLocations, $sCurrLocation)
	EndIf

	If $bReturnBool = True Then
		If $iIndex <> -1 Then Return True
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
Func setLocation($sLocation, $aData = Null)
	Local $aLocation = getArg($g_aLocations, $sLocation)
	Local $aPoints[0][2] ;Will store points to find colors for.
	
	If ($aLocation = -1) Then
		;Creates new location.
		If (Not(isArray($aData))) Then $aData = StringSplit(StringStripWS($aData, 4), "|", $STR_NOCOUNT)

		For $sData In $aData
			Local $aPoint = StringSplit($sData, ",", $STR_NOCOUNT)

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

			$aPoints[$i][0] = $aPixel[0]
			$aPoints[$i][1] = $aPixel[1]
		Next
	EndIf

	CaptureRegion()

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

Func checkImageLocations()
	Local $iSize = UBound($g_aImageLocations)
	If ($iSize = 0 Or Not(isArray($g_aImageLocations))) Then Return False
	For $i = 0 To $iSize-1
		Local $aImageLocation = StringSplit($g_aImageLocations[$i][1],",")
		Local $locationFound = findImage($aImageLocation[5], 90, 100, $aImageLocation[1], $aImageLocation[2], $aImageLocation[3], $aImageLocation[4], True, True)
		If (IsArray($locationFound)) Then 
			#cs 
			Code for ignore location. test and fix later.
			If (Ubound($aImageLocation) = 7) Then
				Local $ignoreLocationFound = findImage($aImageLocation[6], 100, 100, $aImageLocation[1], $aImageLocation[2], $aImageLocation[3], $aImageLocation[4], False, True)
				if (IsArray($ignoreLocationFound)) Then ContinueLoop
			EndIf
			#ce
			Return $g_aImageLocations[$i][0]
		EndIf
	Next
	Return False
EndFunc

; Calls getLocation() in .2 second intervals until debug stopped.
Func testLocation()
	While Not(_Sleep(200))
		CaptureRegion()
		$g_iLocationIndex = -1
		$g_sLocation = "unknown"
		Log_Add(getLocation())
	WEnd
EndFunc

Func CreateLocationsMap(ByRef $aLocationsMap, ByRef $aLocations)
	Local $iSize = UBound($aLocations)

    Local $t_aMapped[$iSize][2]
    For $a = 0 To $iSize-1
        Local $sContent = getArg($aLocationsMap, $aLocations[$a][0])
        If $sContent <> -1 Then
            $sContent = $aLocations[$a][0] & "," & $sContent

            Local $aContents = StringSplit($sContent, ",")
            Local $aIndex[0] ;List of index
            For $b = 1 To $aContents[0]
                For $c = 0 To $iSize-1
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