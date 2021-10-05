#include-once

#cs
    Function: Retrieves current game location.
	Returns: String game location.
	Extended: Location pixel data.
#ce
Global $g_hTimer_ImageLocation = TimerInit()
Func getLocation($bUpdate = True, $bSkipImage = False)
	If TimerDiff($g_hGetLocationCoolDown) < 100 Then Return $g_sLocation
	$g_hGetLocationCoolDown = TimerInit()

	If $g_sLocation == "unknown" And TimerDiff($g_hTimerLocation) > 3000 Then $g_iLocationIndex = -1
	If $g_hTimerLocation = Null Then $g_hTimerLocation = TimerInit()

	Local $sOldLocation = $g_sLocation

	If $bUpdate = True Then CaptureRegion()
	If $g_iLocationIndex <> -1 And $g_aLocationsMap[$g_iLocationIndex][0] <> -1 Then
		For $i = 0 To $g_aLocationsMap[$g_iLocationIndex][0]-1
			Local $aIndices = $g_aLocationsMap[$g_iLocationIndex][1]
			Local $sLocation = $g_aLocations[$aIndices[$i]][0]
			Local $sPixelSet = $g_aLocations[$aIndices[$i]][1]

			If isPixel($sPixelSet, 20) > 0 Then
				Local $LocationArray = [$sLocation, $sPixelSet] 
				_ArrayAdd($g_vDebug, $LocationArray)

				$g_sLocation = $sLocation
				$Location = $sLocation & " (" & getTimeString(TimerDiff($g_hTimerLocation)/1000) & ")"
				If ($g_sLocation <> $sOldLocation) Then $g_hTimerLocation = TimerInit()
				$g_iLocationIndex = $aIndices[$i]

				$g_hTimer_ImageLocation = TimerInit()
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
				$Location = $sLocation & " (" & getTimeString(TimerDiff($g_hTimerLocation)/1000) & ")"
				If ($g_sLocation <> $sOldLocation) Then $g_hTimerLocation = TimerInit()
				$g_iLocationIndex = $i

				$g_hTimer_ImageLocation = TimerInit()
				Return $g_sLocation
			EndIf
		Next
	EndIf

	;Image locations, consumes lots of power
	If TimerDiff($g_hTimer_ImageLocation) > 5000 Then
		$g_hTimer_ImageLocation = TimerInit()
		If $bSkipImage = False And $g_iLocationIndex = -1 Then
			;$g_aImageLocation = [[NAME, 'x,y,w,h,"image"|x,y,w,h,"image"|...'], [...]]
			If isArray($g_aImageLocations) = True Then
				For $i = 0 To UBound($g_aImageLocations)-1
					If UBound($g_aImageLocations, 2) <> 2 Then ExitLoop
	
					Local $sLocation = $g_aImageLocations[$i][0] ;name
					Local $aLocationData_Set = StringSplit($g_aImageLocations[$i][1], "|", 2)
					For $sLocationData In $aLocationData_Set
						Local $aLocationData = StringSplit($sLocationData, ",", 2)
						If isArray($aLocationData) = False And UBound($aLocationData) <> 5 Then ExitLoop
						
						Local $sImage = StringReplace($aLocationData[4], '"', "")
						Local $aImage = findImage($sImage, 90, 0, $aLocationData[0], $aLocationData[1], $aLocationData[2], $aLocationData[3], False, True)
	
						If isArray($aImage) Then
							$g_sLocation = $sLocation
							$Location = $sLocation & " (" & getTimeString(TimerDiff($g_hTimerLocation)/1000) & ")"
							Return $g_sLocation
						EndIf
					Next
				Next
			EndIf
		EndIf
	EndIf

	$g_sLocation = "unknown"
	$Location = $g_sLocation & " (" & getTimeString(TimerDiff($g_hTimerLocation)/1000) & ")"
	If ($g_sLocation <> $sOldLocation) Then 
		$g_hTimerLocation = TimerInit()
	Else
		If BitAnd(WinGetState($g_hParent), $WIN_STATE_MINIMIZED) = False And _GUICtrlTab_GetCurSel($g_hTb_Main) = 1 Then Stats_Update()
	EndIf

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
Func waitLocation($vLocations, $iSeconds, $iDelay = 200, $bReturnBool = True, $bCheckGame = False)
	Local $bOutput = ($bReturnBool? False : "")
	Log_Level_Add("waitLocation()")
	Local $iTimerInit = TimerInit()	
	While TimerDiff($iTimerInit) < $iSeconds*1000
		If $bCheckGame Then
			If ADB_isGameRunning() = False Then
				$bOutput = "$game_not_running"
				ExitLoop
			EndIf
		EndIf

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
		$bBoolean: If false, returns the location string found.
	Returns: String or Boolean depending on $bBoolean
#ce
Func isLocation($vLocations, $bBoolean = True)
	If isArray($vLocations) = False Then 
		If StringInStr($vLocations, ",") = False Then
			$vLocations = CreateArr($vLocations)
		Else
			$vLocations = StringSplit($vLocations, ",", $STR_NOCOUNT)
		EndIf
	EndIf

	$g_iLocationIndex = -1
	Local $sCurrent = getLocation()

	For $sLocation In $vLocations
		$sLocation = StringStripWS($sLocation, $STR_STRIPALL)
		If $sLocation == $sCurrent Then Return ($bBoolean?(True):($sLocation))
	Next

	Return ($bBoolean?(False):(""))
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
	
	If @error Then
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
		If (StringInStr($sPixelSet, "/")) Then
			$sPixelSet = StringSplit($sPixelSet, "/", $STR_NOCOUNT)
			$sPixelSet = $sPixelSet[UBound($sPixelSet) - 1] ;Latest entry
		EndIf

		Local $aPixels = StringSplit($sPixelSet, "|", $STR_NOCOUNT)
		ReDim $aPoints[UBound($aPixels)][2]
		For $i = 0 To UBound($aPixels)-1
			Local $aPixel = StringSplit($aPixels[$i], ",", $STR_NOCOUNT)
			If UBound($aPixel) < 2 Then Return SetError(1, 0, False)

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
        If Not(@error) Then ;if exist
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