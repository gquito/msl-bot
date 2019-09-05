#include-once

;Run CMD session to send ADB command.
;Output will be retrieved after command has been executed.
Func ADB_Command($sCommand, $iVersion = $Config_ADB_Input_Event_Version, $iTimeout = $Delay_ADB_Timeout, $sAdbDevice = $Config_ADB_Device, $sAdbPath = $Config_ADB_Path)
	Log_Level_Add("ADB_Command")
    Log_Add("ADB command: " & '"' & $sAdbPath & '"' & " -s " & $sAdbDevice & " " & $sCommand, $LOG_DEBUG)

    Local $iPID = Run('"' & $sAdbPath & '"' & " -s " & $sAdbDevice & " " & $sCommand, "", @SW_HIDE, $STDERR_MERGED)
	Local $sResult ;Holds ADB output

	Switch $iVersion
		Case 0 ;Most stable method, slower.
			If ProcessWaitClose($iPID, $iTimeout) = 0 Then
				ProcessClose($iPID)
				$sResult = "Timed out."
			Else
				$sResult = StdoutRead($iPID)
			EndIf
		Case 1 ;Newer method, faster.
			Local $hTimer = TimerInit()
			While ProcessExists($iPID)
				If (_Sleep(100)) Then ExitLoop
				If (TimerDiff($hTimer) > $iTimeout) Then
					$sResult = "Timed out."
					ProcessClose($iPID)
					ExitLoop
				EndIf
			WEnd
			If ($sResult <> "Timed out.") Then $sResult = StdoutRead($iPID)
		Case Else
			$sResult = "(ERROR) Version invalid."
	EndSwitch
    StdioClose($iPID)

    If ($sResult <> "") Then Log_Add("ADB output: " & $sResult, $LOG_DEBUG)
    Log_Level_Remove()
    Return $sResult
EndFunc   ;==>ADB_Command

;Runs ADB Shell session directly and inputs commands individually.
;Commands could be separated by @CRLF.
;Output is automatically parsed to show only output.
;Raw output displays all command inputs from session.
Func ADB_Shell($sCommand, $iTimeout = $Delay_ADB_Timeout, $bOutput = False, $bRawOutput = False, $sAdbDevice = $Config_ADB_Device, $sAdbPath = $Config_ADB_Path)
	Log_Level_Add("ADB_Shell")
	;Log_Add("ADB shell: " & '"' & $sAdbPath & '"' & " -s " & $sAdbDevice & " " & $sCommand, $LOG_DEBUG)

	;Run shell session
	Local $iPID_ADB = Run('"' & $sAdbPath & '" -s ' & $sAdbDevice & ' shell', "", @SW_HIDE, $STDIN_CHILD + $STDOUT_CHILD)
	StdinWrite($iPID_ADB, $sCommand & @CRLF)
	StdinWrite($iPID_ADB, "exit" & @CRLF)

	;Read output from session.
	Local $sOutput = ""
	If ($bOutput) Then

        ;Reading output from stream.
		Local $hTimer = TimerInit()
		While True 
			$sOutput &= StdoutRead($iPID_ADB)
			If (@error Or _Sleep(0)) Then ExitLoop

			If (TimerDiff($hTimer) > $iTimeout) Then
				$sOutput = "Timed out."
				ExitLoop
			EndIf
		WEnd

		;Parsing output
		If ($sOutput <> "Timed out." And Not($bRawOutput)) Then
			Local $aOutput = StringRegExp($sOutput, "(?s)\n.*?\n.*?\n(.*)\n(?:root@)", $STR_REGEXPARRAYMATCH) ;Process input
			If (IsArray($aOutput)) Then $sOutput = $aOutput[0]
		EndIf

	EndIf

	;Prevent adb process from building up.
	If ($sOutput = "Timed out.") Then
		Log_Add("ADB Process has stopped functioning. Restarting Nox.", $LOG_ERROR)
		If (ProcessExists($iPID_ADB)) Then ProcessClose($iPID_ADB)
		RestartNox(1, "")
	EndIf

	;If ($sOutput <> "") Then Log_Add("ADB output: " & $sOutput, $LOG_DEBUG)
	Log_Level_Remove()
	Return $sOutput
EndFunc   ;==>ADB_Shell

;Returns working condition of ADB.
Func ADB_isWorking()
	Local $bStatus = (FileExists($Config_ADB_Path) = True) And (StringInStr(ADB_Command("get-state"), "error") = False)
	Log_Add("Checking ADB status: " & $bStatus, $LOG_DEBUG)
	$g_bAdbWorking = $bStatus

	Return $bStatus
EndFunc   ;==>ADB_isWorking

;Send ESC through ADB.
Func ADB_SendESC($iCount = 1, $sMethod = $Config_ADB_Method, $sAdbDevice = $Config_ADB_Device, $sAdbPath = $Config_ADB_Path)
	If (Not($g_bAdbWorking)) Then Return 0

	Switch $sMethod
		Case "input event"
			Local $sCommand = ""
			For $i = 0 To $iCount - 1
				$sCommand &= ";input keyevent ESCAPE"
			Next
			$sCommand = StringMid($sCommand , 2)
			ADB_Command('shell "' & $sCommand & '"')

		Case "sendevent"
			Local $aTCV = ["1 158 1", "0 0 0", "1 158 0", "0 0 0", "0 0 0"]
			If $g_sADBEvent <> "" Then
				For $i = 0 To $iCount - 2
					_ArrayAdd($aTCV, $aTCV)
				Next
				ADB_Shell(ADB_ConvertEvent($g_sADBEvent, $aTCV))
			Else
				ContinueCase
			EndIf
		Case Else
			Return ADB_SendESC($iCount, "input event", $sAdbDevice, $sAdbPath)
	EndSwitch
	Return 1
EndFunc   ;==>ADB_SendESC

Func ADB_RestartServer()
	ADB_Command("kill-server")
	ADB_Command("start-server")
EndFunc

Func ADB_GetDevices()
	If (Not($g_bAdbWorking)) Then Return "Adb Not Working"
	Msgbox(0,"Adb Devices", ADB_Command("devices"))
EndFunc

;Converts an array of event, type, code, and value to sendevent long text.
Func ADB_ConvertEvent($sEvent, $aTCV)
	Local $sFinal = ""
	If (Not(IsArray($aTCV))) Then $aTCV = StringSplit($aTCV, ",", $STR_NOCOUNT)

	For $i = 0 To UBound($aTCV) - 1
		Local $aRaw = StringSplit($aTCV[$i], " ", $STR_NOCOUNT)
		Local $sType = $aRaw[0]
		Local $sCode = $aRaw[1]
		Local $sValue = $aRaw[2]

		$sFinal &= ";sendevent " & $sEvent & " " & $sType & " " & $sCode & " " & $sValue
	Next

	Return StringMid($sFinal, 2)
EndFunc   ;==>ADB_ConvertEvent

;Retrieves "Android Input" to be able to use sendevent method.
Func ADB_GetEvent($iTimeout = 500)
	Log_Level_Add("ADB_GetEvent")
	If ($Config_ADB_Method <> "sendevent") Then 
		Log_Level_Remove()
		Return ""
	EndIf

	;Capture event list.
	Local $sData = ""
	Local $hTimer = TimerInit()

	$g_bLogEnabled = False
	While ($sData = "" Or $sData = "Timed out.")
		$sData = ADB_Command("shell getevent -p")
		If (TimerDiff($hTimer) > $iTimeout Or _Sleep(100)) Then ExitLoop
	WEnd
	$g_bLogEnabled = True
	
	If (Not(StringInStr($sData , "Android Input")) And Not(StringInStr($sData , "Android_Input"))) Then
		Log_Add("ADB_GetEvent() => Could not find Android Input.", $LOG_ERROR)
		Log_Level_Remove()
		Return ""
	EndIf

	Local $aEvents = StringSplit(StringStripWS($sData, $STR_STRIPSPACES), @CRLF, $STR_NOCOUNT)
	If (IsArray($aEvents)) Then
		For $i = 0 To UBound($aEvents) - 1
			If (StringInStr($aEvents[$i], "Android Input") Or StringInStr($aEvents[$i], "Android_Input")) Then

				Local $aEventNum = StringSplit($aEvents[$i - 1], ":", $STR_NOCOUNT)
				If (IsArray($aEventNum) And UBound($aEventNum) > 1) Then
					Log_Level_Remove()
					Return StringStripWS($aEventNum[1], $STR_STRIPLEADING)
				EndIf

			EndIf
		Next
	Else
		Log_Add("ADB_GetEvent() => Could not get event list.", $LOG_ERROR)
		Log_Level_Remove()
		Return ""
	EndIf

	Log_Add("ADB_GetEvent() => Something went wrong.", $LOG_ERROR)
	Log_Level_Remove()
	Return ""
EndFunc   ;==>ADB_GetEvent