#include-once

Global $g_hADBShellPID = -1
Global $g_sSerialNumber = ""
Global $g_iADBInputDevice = ""

;Run CMD session to send ADB command.
;Output will be retrieved after command has been executed.
Func ADB_Command($sCommand, $iTimeout = $Delay_ADB_Timeout, $sDevice = $ADB_Device)
	Log_Level_Add("ADB_Command")
	Log_Add("ADB command: " & $sCommand, $LOG_DEBUG)
	Local $iError = 0
	Local $iExtended = 0
	If $Config_Emulator_Path <> "" Then
		Local $iPID = -1
		Local $sResult ;Holds ADB output

		; get PID
		If $sDevice == "~AUTO" Then
			$iPID = Run($Config_Emulator_Path & "\" & $Config_Console_ADB & '"' & $sCommand & '"', "", @SW_HIDE, $STDERR_MERGED)
		Else
			$iPID = Run($Config_Emulator_Path & "\adb.exe -s " & $sDevice & '"' & $sCommand & '"', "", @SW_HIDE, $STDERR_MERGED)
		EndIf

		If $iPID = 0 Then
			$iExtended = @error
			$iError = 1	;Error in Run function.
		EndIf

		Local $hTimer = TimerInit()
		While ProcessExists($iPID)
			If _Sleep(10) Then ExitLoop
			If TimerDiff($hTimer) > $iTimeout Then
				$sResult = "Timed out."
				$iError = 2 ; Timed out error
				ProcessClose($iPID)
				ExitLoop
			EndIf
		WEnd

		If ($sResult <> "Timed out.") Then 
			$sResult = StdoutRead($iPID)
		EndIf
		StdioClose($iPID)
	Else
		$sResult = "Error could not access Emulator Path."
	EndIf

    ProcessClose($iPID)
    If ($sResult <> "") Then Log_Add("ADB output: " & $sResult, $LOG_DEBUG)
	Log_Level_Remove()
    Return SetError($iError, $iExtended, (($sResult=="")?(True):($sResult)))
EndFunc   ;==>ADB_Command

;Send ESC through ADB.
Func ADB_SendESC($iCount = 1)
	Local $sCommand = ""
	For $i = 0 To $iCount - 1
		$sCommand &= ";input keyevent ESCAPE"
	Next
	$sCommand = StringMid($sCommand , 2)
	ADB_Command('shell ' & $sCommand)
	Return 1
EndFunc   ;==>ADB_SendESC

Func ADB_RestartServer()
	ADB_Command("kill-server")
	ADB_Command("start-server")
EndFunc

Func ADB_Establish($bRetry = False)
	Log_Level_Add("ADB_Establish")

	Local $hTimer = TimerInit()
    Do
		If TimerDiff($hTimer) > 120000 Then ExitLoop

		Local $bWorking = ADB_isWorking()
        If $bWorking = False Then
            Log_Add("Attempting to connect to ADB server", $LOG_DEBUG)
			ADB_RestartServer()

			$bWorking = ADB_isWorking()
            If $bWorking = False Then
                Log_Add("Failed to connect to ADB server", $LOG_ERROR)
            Else
                Log_Add("Successfully connected to ADB server", $LOG_DEBUG)
            EndIf
		EndIf

        $g_bADBWorking = $bWorking
		If $g_bADBWorking = False And $bRetry = True Then
			If _Sleep(5000) Then ExitLoop
		EndIf
	Until ($g_bADBWorking Or Not($bRetry))

	Log_Add("ADB_Establish Result: " & $g_bADBWorking, $LOG_DEBUG)
	Log_Level_Remove()
    Return $g_bADBWorking
EndFunc

;Extra Functions ==========================================

;Returns working condition of ADB.
Func ADB_isWorking()
	Local $iExtended = 0
	Local $bStatus = True
	Local $sADBOutput = ADB_Command("shell help")
	If @error Then 
		$bStatus = False
		$iExtended = 1
	EndIf

	If StringInStr($sADBOutput, "error") Then 
		$bStatus = False
		$iExtended = 2
	EndIf

	If StringInStr($sADBOutput, "failed") Then 
		$bStatus = False
		$iExtended = 3
	EndIf

	Log_Add("Checking ADB status: " & $bStatus & " (" & $iExtended & ")", $LOG_DEBUG)
	$g_bAdbWorking = $bStatus

	Return SetExtended($iExtended, $bStatus)
EndFunc   ;==>ADB_isWorking

Func ADB_isGameRunning($sPackageName = $g_sPackageName)
    If $g_bADBWorking = False Then Return SetError(1, 0, True)

	Local $bRunning = True ;Default true if adb command fails.

	$g_bLogEnabled = False
	Local $sResult = ADB_Command("shell dumpsys window windows")
	If @error Then Return SetError(2, 0, True)
	$g_bLogEnabled = True

	If StringInStr($sResult, "mCurrentFocus") = True Then
		$bRunning = StringRegExp($sResult, "mCurrentFocus.*" & $sPackageName)
	EndIf

	If (Not($bRunning)) Then Log_Add("Is game running: " & $bRunning, $LOG_DEBUG)
	Return $bRunning
EndFunc