#include-once
#include "../imports.au3"

#cs
	Function: Sends command to Android Debug Bridge and returns output
	Parameters:
	$sCommand: Command to send
	$sAdbDevice: If more than one device, device is needed.
	$sAdbPath: ADB executable path.
	Returns: Output after command has been executed.
#ce
Func adbCommand($sCommand, $sAdbDevice = $g_sAdbDevice, $sAdbPath = $g_sAdbPath)
	Log_Level_Add("adbCommand")
	Log_Add("ADB command: " & '"' & $sAdbPath & '"' & " -s " & $sAdbDevice & " " & $sCommand, $LOG_DEBUG)

	Local $iPID = Run('"' & $sAdbPath & '"' & " -s " & $sAdbDevice & " " & $sCommand, "", @SW_HIDE, $STDERR_MERGED)
	If ProcessWaitClose($iPID, 3000) = 0 Then
		ProcessClose($iPID)
		$sResult = "timed out."
	Else
		$sResult = StdoutRead($iPID)
	EndIf
	StdioClose($iPID)

	If $sResult <> "" Then Log_Add("ADB output: " & $sResult, $LOG_DEBUG)
	Log_Level_Remove()
	Return $sResult
EndFunc   ;==>adbCommand

Func isAdbWorking()
	Local $bStatus = (FileExists($g_sAdbPath) = True) And (StringInStr(adbCommand("get-state"), "error") = False)
	Log_Add("Checking ADB status: " & $bStatus, $LOG_DEBUG)
	$g_bAdbWorking = $bStatus

	If $bStatus = True Then $g_sEvent = getEvent()
	Return $bStatus
EndFunc   ;==>isAdbWorking

Func adbSendESC($sAdbDevice = $g_sAdbDevice, $sAdbPath = $g_sAdbPath)
	If $g_sAdbMethod = "input event" Then
		Return adbCommand("shell input keyevent ESCAPE")
	Else
		If IsDeclared("sEvent") = 0 Then
			Global $g_sEvent = getEvent()
		EndIf

		Local $aTCV = ["1 158 1", "0 0 0", "1 158 0", "0 0 0"]
		Return adbCommand("shell " & sendEvent($g_sEvent, $aTCV), $sAdbDevice, $sAdbPath)
	EndIf
EndFunc   ;==>adbSendESC

Func sendEvent($sEvent, $aTCV)
	Local $sFinal = ""
	If IsArray($aTCV) = False Then
		$aTCV = StringSplit($aTCV, ",", $STR_NOCOUNT)
	EndIf

	For $i = 0 To UBound($aTCV) - 1
		Local $aRaw = StringSplit($aTCV[$i], " ", $STR_NOCOUNT)
		Local $sType = $aRaw[0]
		Local $sCode = $aRaw[1]
		Local $sValue = $aRaw[2]

		$sFinal &= ";sendevent " & $sEvent & " " & $sType & " " & $sCode & " " & $sValue
	Next

	Return '"' & StringMid($sFinal, 2) & '"'
EndFunc   ;==>sendEvent

Func getEvent($sGetEvent = "~")
	If $sGetEvent = "~" Then
		$g_bLogEnabled = False
		$sGetEvent = adbCommand("shell getevent -p")
		$g_bLogEnabled = True
	EndIf

	$aEvents = StringSplit(StringStripWS($sGetEvent, $STR_STRIPSPACES), @CRLF, $STR_NOCOUNT)
	If IsArray($aEvents) Then
		For $i = 0 To UBound($aEvents) - 1
			If StringInStr($aEvents[$i], "Android Input") Then
				Local $aEventNum = StringSplit($aEvents[$i - 1], ":", $STR_NOCOUNT)
				If IsArray($aEventNum) = True And UBound($aEventNum) > 1 Then
					Return StringStripWS($aEventNum[1], $STR_STRIPLEADING)
				EndIf
			EndIf
		Next
	Else
		$g_sErrorMessage = "getEvent() => Could not get event list. Using default."
		Log_Add($g_sErrorMessage, $LOG_ERROR)
		Return "/dev/input/event7"
	EndIf

	$g_sErrorMessage = "getEvent() => Could not retrieve event number for Android Input. Using default."
	Log_Add($g_sErrorMessage, $LOG_ERROR)
	Return "/dev/input/event7"
EndFunc   ;==>getEvent
