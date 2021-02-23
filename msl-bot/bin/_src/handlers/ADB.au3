#include-once

Global $g_hADBShellPID = -1
Global $g_sSerialNumber = ""
Global $g_iADBInputDevice = ""

;Run CMD session to send ADB command.
;Output will be retrieved after command has been executed.
Func ADB_Command($sCommand, $iTimeout = $Delay_ADB_Timeout, $sConsole_Command = $Config_Console_ADB)
	Log_Level_Add("ADB_Command")
	Log_Add("ADB command: " & $sCommand, $LOG_DEBUG)

	;If StringLeft($sCommand, 5) == "shell" Then
	;	Local $sShellResult = ADB_Shell(StringMid($sCommand, 6), $iTimeout, False)
	;	Log_Level_Remove()
	;	Return $sShellResult
	;EndIf

	If $Config_Emulator_Path <> "" Then
		;MsgBox(0, "", $Config_Emulator_Path & "\" & $sConsole_Command & '"' & $sCommand & '"')
			Local $iPID = Run($Config_Emulator_Path & "\" & $sConsole_Command & '"' & $sCommand & '"', "", @SW_HIDE, $STDERR_MERGED)
			Local $sResult ;Holds ADB output

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
    Return $sResult
EndFunc   ;==>ADB_Command

Func ADB_Shell($sCommand, $iTimeout = $Delay_ADB_Timeout, $bBinary = False)
	If $g_hADBShellPID <= 0 Or ProcessExists($g_hADBShellPID) <= 0 Then
		$g_hADBShellPID = _ADB_ShellConnect()

		If $g_hADBShellPID <= 0 Or ProcessExists($g_hADBShellPID) <= 0 Then Return -1 ;Failed to connect
	EndIf

	_ADB_ShellRead() ;Clear current stream
	_ADB_ShellWrite($sCommand)
	Sleep(100)

	Local $sReturn = ""
	Do
		$sReturn &= _ADB_ShellRead($bBinary)
	Until(@error Or @extended = 0)

	;ClipPut($sReturn)
	Return $sReturn
EndFunc

Func _ADB_ShellConnect()
	If $g_sSerialNumber == "" Then
		If _ADB_GetSerialNumber() == "" Then Return -1
	EndIf

	$g_hADBShellPID = Run($Config_Emulator_Path & "adb -s " & $g_sSerialNumber & " shell", "", @SW_HIDE, $STDIN_CHILD + $STDOUT_CHILD)
	If $g_hADBShellPID <> -1 Then StdinWrite($g_hADBShellPID, @CRLF & @CRLF)
	Return $g_hADBShellPID
EndFunc

Func _ADB_GetSerialNumber()
	Local $sRaw = ADB_Command("get-serialno")
	If $sRaw == "Timed out." Then Return -1
	If $sRaw == "unknown" Then Return -2
	Local $aMatches = StringRegExp($sRaw, ".*:.*", $STR_REGEXPARRAYFULLMATCH)
	If isArray($aMatches) > 0 And UBound($aMatches) > 0 Then
		$g_sSerialNumber = $aMatches[UBound($aMatches)-1]
	Else
		$g_sSerialNumber = ""
	EndIf
	Return $g_sSerialNumber
EndFunc

Func _ADB_ShellWrite($sCommand)
	If $g_hADBShellPID <= 0 Or ProcessExists($g_hADBShellPID) <= 0 Then Return -1
	StdinWrite($g_hADBShellPID, $sCommand & @CRLF)
EndFunc

Func _ADB_ShellRead($bBinary = False)
	If $g_hADBShellPID <= 0 Or ProcessExists($g_hADBShellPID) <= 0 Then Return -1
	Return StdoutRead($g_hADBShellPID, False, $bBinary)
EndFunc

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
    If $g_bADBWorking = 0 Then Return -2

	$g_bLogEnabled = False
	Local $bRunning = (StringInStr(ADB_Command("shell ps"), $sPackageName) > 0)
	$g_bLogEnabled = True

	If (Not($bRunning)) Then Log_Add("Is game running: " & $bRunning, $LOG_DEBUG)
	Return $bRunning
EndFunc
