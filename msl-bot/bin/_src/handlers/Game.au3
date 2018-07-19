#include-once
#include "../imports.au3"

Func isGameRunning()
    If isAdbWorking() = False Then Return 2
    Return StringInStr(adbCommand("shell ps | grep msleague | awk '{print $9}'"), "com.ftt.msleague_gl")
EndFunc

Func RestartGame()
    Log_Level_Add("RestartGame")
    Log_Add("Restarting game.")
    $bOutput = False

    While True
        Local $hTimer = TimerInit() ;Stores timerinit
        If isAdbWorking() = False Then 
            Log_Add("ADB Unavailable, could not restart game.", $LOG_ERROR)
            ExitLoop
        EndIf

        Local $bGameRunning = isGameRunning()
        If $bGameRunning = True Then
            Log_Add("Game is already running, killing current process.")
            While isGameRunning()
                If _Sleep(2000) Or (TimerDiff($hTimer) > 120000) Then ExitLoop(2)
                adbCommand("shell am force-stop com.ftt.msleague_gl")
            WEnd
        EndIf

        ;Start game through ADB
        Log_Add("Starting game and waiting for main screen.")
        While isGameRunning() = False
            If _Sleep(2000) Or (TimerDiff($hTimer) > 120000) Then ExitLoop(2)
            adbCommand("shell monkey -p com.ftt.msleague_gl -c android.intent.category.LAUNCHER 1")
        WEnd

        ;Waiting for start menu
        $g_hWindow = 0
        $g_hControl = 0
        Local $hTimer = TimerInit()
        While getLocation() <> "tap-to-start"
            If TimerDiff($hTimer) > 300000 Or _Sleep(5000) Then ExitLoop(2)
            isAdbWorking()
            resetHandles()
        WEnd

        ;Waiting for start menu
        $bOutput = (getLocation() = "tap-to-start")
        ExitLoop
    WEnd

    If navigate("map", True, 2) = False Then
		resetHandles()
        If getLocation() = "tap-to-start" Then
            $bOutput = False
        EndIf
    EndIf
    Log_Add("Restart game result: " & $bOutput, $LOG_DEBUG)
    Log_Level_Remove()
    Return $bOutput
EndFunc

;Reset global handles: $g_hWindow, $g_hControl
Func resetHandles()
	$g_hWindow = WinGetHandle($g_sWindowTitle)
	$g_hControl = ControlGetHandle($g_hWindow, "", $g_sControlInstance)
EndFunc

#cs
    Function: Retrieves current game location.
	Parameters:
		$aLocations: Format=[["LOCATION_NAME", "PIXEL_SET"], [...]]
	Returns: String game location.
	Extended: Location pixel data.
#ce
Func getLocation($aLocations = $g_aLocations, $bUpdate = True)
	If $g_hTimerLocation = Null Then $g_hTimerLocation = TimerInit()
	Local $sOldLocation = $g_sLocation

	If $bUpdate = True Then captureRegion() ;Updates global bitmap

	;Going through location data and using isPixelAND() function to check each location.
	Local Const $iSize = UBound($aLocations, $UBOUND_ROWS)
	If ($iSize = 0) Or (isArray($aLocations) = False) Then
		$g_sErrorMessage = "getLocation() => Invalid argument."
		Return -1
	EndIf

	Local $t_sLocation = "" ;Temporary location to double check location.
	For $i = 0 To $iSize-1
		If ($aLocations[$i][0] = "") Or (StringMid($aLocations[$i][0], 0, 1) = ";") Then ContinueLoop

		If isPixelOR($aLocations[$i][1], 20) = True Then
			If $bUpdate = False Then 
				Global $g_vDebug = [$aLocations[$i][0], $aLocations[$i][1]]

				$g_sLocation = $aLocations[$i][0]
				If $g_sLocation <> $sOldLocation Then $g_hTimerLocation = TimerInit()

				Return $aLocations[$i][0] ;no double check if update is false.
			EndIf

			;checks in 200 miliseconds for same location.
			If ($g_iBackgroundMode <> $BKGD_ADB) And (_Sleep(200) = True) Then Return ""
			captureRegion()

			If isPixelOR($aLocations[$i][1], 20) = True Then
				Global $g_vDebug = [$aLocations[$i][0], $aLocations[$i][1]]

				$g_sLocation = $aLocations[$i][0]
				If $g_sLocation <> $sOldLocation Then $g_hTimerLocation = TimerInit()

				Return $aLocations[$i][0] ;Returns confirmed location.
			EndIf
		EndIf
	Next

	$g_vDebug = ""

	$g_sLocation = "unknown"
	If $g_sLocation <> $sOldLocation Then $g_hTimerLocation = TimerInit()

	Return "unknown" ;If no location from database is found.
EndFunc

#cs
	Function: Waits for a location to appear and returns when it does.
	Parameters:
		$vLocations: Array or stirng of locations. Format=["location", "..."] or "location,..."
		$iSeconds: How long to wait for in seconds
		$bReturnBool: If false, returns the location string found.
	Returns: String or Boolean depending on $bReturnBool
#ce
Func waitLocation($vLocations, $iSeconds, $bReturnBool = True)
	Local $iTimerInit = TimerInit()
	While (TimerDiff($iTimerInit) < $iSeconds*1000)
		Local $t_vResult = isLocation($vLocations, $bReturnBool)
		If $t_vResult <> "" Then
			Return $t_vResult
		EndIf

		If _Sleep(200) Then Return False
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
	Local $aLocations = Null
	Local $sCurrLocation = getLocation()

	If $sCurrLocation = -1 Then Return False

	;Fixing argument format= ["location", "..."]
	If isArray($vLocations) = False Then
		;Expected format: "location, ..."
		$vLocations = StringStripWS($vLocations, $STR_STRIPALL) ;Removes all whitespace.
		$aLocations = StringSplit($vLocations, ",", $STR_NOCOUNT)
	Else
		$aLocations = $vLocations
	EndIf

	;Checking array if location exists
	For $i = 0 To UBound($aLocations)-1
		Local $sLocation = $aLocations[$i]
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
	
	If $aLocation = -1 Then
		;Creates new location.
		If isArray($aData) = False Then 
			$aData = StringSplit($aData, "|", $STR_NOCOUNT)
		EndIf

		For $sData In $aData
			Local $aPoint = StringSplit($sData, ",", $STR_NOCOUNT)

			ReDim $aPoints[UBound($aPoints)+1][2]
			$aPoints[UBound($aPoints)-1][0] = $aPoint[0]
			$aPoints[UBound($aPoints)-1][1] = $aPoint[1]
		Next
	Else
		;Creates local version of the location. This location will be prioritized versus the remote location.
		Local $sPixelSet = $aLocation
		If StringInStr($sPixelSet, "/") = True Then
			$sPixelSet = StringSplit($sPixelSet, "/", $STR_NOCOUNT)[0]
		EndIf

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

	Local $hFile = FileOpen($g_sLocationsLocal, $FO_APPEND+$FO_CREATEPATH)
	Local $bOutput = (FileWrite($hFile, @CRLF & $sLocation & ":" & $sNewPixels) = 1)
	FileClose($hFile)

	mergeArgFromTo(getArgsFromFile($g_sLocationsLocal, ">", ":"), $g_aLocations, "/")
	Return $bOutput
EndFunc

; Calls getLocation() in .2 second intervals until debug stopped.
Func testLocation()
	While Not(_Sleep(200))
		CaptureRegion()
		Log_Add(getLocation($g_aLocations, False))
	WEnd
EndFunc

Func SetupKeymap()
	Log_Add("Right click the keymap icon...")
	While _IsPressed(02) = False
		If _Sleep(10) Then Return -1
	WEnd

	;Left keymap
	setLog("Setting up left keymap...")
	Local $initialPos = MouseGetPos()

	MouseClickDrag("Left", $initialPos[0]-224, $initialPos[1]+202, $initialPos[0]-495, $initialPos[1]+341, 10)
	Send("{LEFT}")

	;Right keymap
	setLog("Setting up right keymap...")

	MouseClickDrag("Left", $initialPos[0]-620, $initialPos[1]+306, $initialPos[0]-483, $initialPos[1]+206, 10)
	Send("{RIGHT}")

	;Up keymap
	setLog("Setting up up keymap...")

	MouseClickDrag("Left", $initialPos[0]-386, $initialPos[1]+313, $initialPos[0]-386, $initialPos[1]+241, 10)
	Send("{UP}")
	MouseClickDrag("Left", $initialPos[0]-386, $initialPos[1]+241, $initialPos[0]-600, $initialPos[1]+241, 10)

	;Down keymap
	setLog("Setting up down keymap...")

	MouseClickDrag("Left", $initialPos[0]-386, $initialPos[1]+241, $initialPos[0]-386, $initialPos[1]+313, 10)
	Send("{DOWN}")

	Log_Add("Setup complete.")
EndFunc