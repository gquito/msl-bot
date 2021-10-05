#include-once

Global $g_hADBShellPID = -1
Global $g_sSerialNumber = ""
Global $g_iADBInputDevice = ""

;Run CMD session to send ADB command.
;Output will be retrieved after command has been executed.
Func ADB_Command($sCommand, $iTimeout = $Delay_ADB_Timeout, $sDevice = $ADB_Device)
	Log_Level_Add("ADB_Command")
	Log_Add("ADB command: " & $sCommand, $LOG_DEBUG)

	If $Config_Emulator_Path <> "" Then
		Local $iPID = -1
		Local $sResult ;Holds ADB output

		; get PID
		If $sDevice == "~AUTO" Then
			$iPID = Run($Config_Emulator_Path & "\" & $Config_Console_ADB & '"' & $sCommand & '"', "", @SW_HIDE, $STDERR_MERGED)
		Else
			$iPID = Run($Config_Emulator_Path & "\adb.exe -s " & $sDevice & '"' & $sCommand & '"', "", @SW_HIDE, $STDERR_MERGED)
		EndIf

		Local $hTimer = TimerInit()
		While ProcessExists($iPID)
			If _Sleep(10) Then ExitLoop
			If TimerDiff($hTimer) > $iTimeout Then
				$sResult = "Timed out."
				ProcessClose($iPID)
				ExitLoop
			EndIf
		WEnd
		If ($sResult <> "Timed out.") Then $sResult = StdoutRead($iPID)
		StdioClose($iPID)
	Else
		$sResult = "Error could not access Emulator Path."
	EndIf

    ProcessClose($iPID)
    If ($sResult <> "") Then Log_Add("ADB output: " & $sResult, $LOG_DEBUG)
	Log_Level_Remove()
    Return (($sResult=="")?(True):($sResult))
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

Func ADB_Establish()
	Log_Level_Add("ADB_Establish")

	Local $hTimer = TimerInit()
    Do
        If ADB_isWorking() <= 0 Then
            Log_Add("Attempting to connect to ADB server", $LOG_DEBUG)
			ADB_Command("connect 127.0.0.1", 60000)

			If _Sleep(5000) Or TimerDiff($hTimer) > 120000 Then ExitLoop

            If ADB_isWorking() <= 0 Then
                Log_Add("Failed to connect to ADB server", $LOG_ERROR)
            Else
                Log_Add("Successfully connected to ADB server", $LOG_DEBUG)
            EndIf
		EndIf
        $g_bADBWorking = ADB_isWorking()
	Until ($g_bADBWorking > 0)

	Log_Add("ADB_Establish Result: " & $g_bADBWorking, $LOG_DEBUG)
	Log_Level_Remove()
    Return $g_bADBWorking
EndFunc

;Extra Functions ==========================================

;Returns working condition of ADB.
Func ADB_isWorking()
	Local $bStatus = (StringInStr(ADB_Command("shell help"), "error") = False)
	Log_Add("Checking ADB status: " & $bStatus, $LOG_DEBUG)
	$g_bAdbWorking = $bStatus

	Return $bStatus
EndFunc   ;==>ADB_isWorking

Func ADB_isGameRunning($sPackageName = $g_sPackageName)
    If $g_bADBWorking = 0 Then Return SetError(1, 0, False)

	Local $bRunning = True ;Default true if adb command fails.

	$g_bLogEnabled = False
	Local $sResult = ADB_Command("shell dumpsys window windows")
	$g_bLogEnabled = True

	If StringInStr($sResult, "mCurrentFocus") = True Then
		$bRunning = StringRegExp($sResult, "mCurrentFocus.*" & $sPackageName)
	EndIf

	If (Not($bRunning)) Then Log_Add("Is game running: " & $bRunning, $LOG_DEBUG)
	Return $bRunning
EndFunc