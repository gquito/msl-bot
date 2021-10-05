#include-once

Func Emulator_Console_Command($sCommand, $iTimeout = $Delay_Console_Timeout)
	Log_Level_Add("Emulator_Console_Command")
    Log_Add("Emulator Console Command: " & $sCommand, $LOG_DEBUG)

    Local $sResult ;Holds ADB output
	If $Config_Emulator_Path <> "" Then
		;MsgBox(0, "", $Config_Emulator_Path & "\" & $sConsole_Command & '"' & $sCommand & '"')
			Local $iPID = Run($Config_Emulator_Path & "\" & $Config_Emulator_Console & ' ' & $sCommand, "", @SW_HIDE, $STDERR_MERGED)
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

    If ($sResult <> "") Then Log_Add("Emulator Console Command output: " & $sResult, $LOG_DEBUG)
    Log_Level_Remove()
    Return $sResult
EndFunc   ;==>ADB_Command

Func Emulator_Restart($iAttempt = 1, $sPackageName = $g_sPackageName)
    Log_Level_Add("Emulator Restart")
    Log_Add("Restarting emulator process.")
    $g_bRestarting = True
    Local $aSavePos = WinGetPos($g_hWindow)

    Local $bOutput = 0
    While $iAttempt >= 1
        $g_hTimerLocation = Null ;Prevent AntiStuck restart
        If $bOutput > 0 Or _Sleep(500) Then ExitLoop

        While (WinGetProcess($g_hWindow) <> -1)
            If $g_hWindow = 0 Then ExitLoop
            Switch StringLower($Config_Emulator_Console)
                Case "noxconsole"
                    Emulator_Console_Command("quit -name:" & $Config_Emulator_Title)
                Case "ldconsole", "dnconsole"
                    Emulator_Console_Command("quit --name " & $Config_Emulator_Title)
                Case "memuc"
                    Emulator_Console_Command("stop -n " & $Config_Emulator_Title)
                Case Else
                    Log_Add("Error: Emulator console is not recognized.", $LOG_ERROR)
                    $bOutput = -3
                    ExitLoop(2)
            EndSwitch
            If _Sleep(5000) Then ExitLoop(2)
        WEnd

        ;Restore settings
        Switch StringLower($Config_Emulator_Console)
            Case "noxconsole"
                Emulator_Console_Command("modify -name:" & $Config_Emulator_Title & " -resolution:800,552,160")
            Case "ldconsole", "dnconsole"
                Emulator_Console_Command("modify --name " & $Config_Emulator_Title & " --resolution 800,552,160 --autorotate 0 --lockwindow 1")
            Case "memuc"
                Emulator_Console_Command("setconfigex -n " & $Config_Emulator_Title & " custom_resolution 800 552 160")
                Emulator_Console_Command("setconfigex -n " & $Config_Emulator_Title & " disable_resize 1")
                Emulator_Console_Command("setconfigex -n " & $Config_Emulator_Title & " start_window_mode 1")
            Case Else
                Log_Add("Error: Emulator console is not recognized.", $LOG_ERROR)
                $bOutput = -3
                ExitLoop
        EndSwitch

        Local $hTimer = TimerInit()
        Log_Add("Trying to connect to ADB Server...")
        $g_bLogEnabled = False
        Do
            $g_bLogEnabled = True
            ResetHandles()
            If $g_hWindow <> 0 Then WinMove($g_hWindow, "", $aSavePos[0], $aSavePos[1])
            _Emulator_Console_RunApp($Config_Emulator_Title, $sPackageName)

            If ($g_hWindow <> 0 And $g_hControl <> 0) And getLocation() == "tap-to-start" Then 
                ADB_Establish()
                ExitLoop()
            EndIf

            If _Sleep(5000) Then ExitLoop(2) 
            If TimerDiff($hTimer) > 180000 Then ExitLoop ;3 Minutes
            $g_bLogEnabled = False
        Until (ADB_Establish() > 0)
        $g_bLogEnabled = True

        ScriptTest_Handles()
        If ADB_isWorking() > 0 Then
            Log_Add("Successfully connected to ADB Server.")
            If ADB_isGameRunning() = False Then
                $bOutput = Emulator_RestartGame($iAttempt, $sPackageName)
                ExitLoop
            EndIf
        Else
            Log_Add("Could not connect to ADB Server.")
            If $g_sLocation <> "tap-to-start" Then
                _Emulator_Console_RunApp($Config_Emulator_Title, $sPackageName)
            EndIf
        EndIf

        ResetHandles()
        If $g_hWindow <> 0 Then WinMove($g_hWindow, "", $aSavePos[0], $aSavePos[1])

        $bOutput = navigate("village", True, 5)
        If @extended = 1 Then ExitLoop ;app-maintenance or app-update

        $iAttempt -= 1
    WEnd
    
    $g_bRestarting = False
    Log_Add("Restarting emulator result: " & $bOutput, $LOG_DEBUG)
    Log_Level_Remove()
    Return $bOutput
EndFunc

Func Emulator_RestartGame($iAttempt = 1, $sPackageName = $g_sPackageName, $bUseADB = $ADB_ADB_Restart_Game, $sActivity = $g_sPackageActivity)
    Log_Level_Add("Emulator_RestartGame")
    Log_Add("Restarting game.")
    $g_bRestarting = True
    $bOutput = False

    Local $bScheduleBusy = $g_bScheduleBusy
    $g_bScheduleBusy = True
    Local $iCounter = 1
    While $iAttempt > 0
        Status("Restarting game attempt #" & $iCounter, $LOG_INFORMATION)
        $iCounter += 1

        $g_hTimerLocation = Null ;Prevent AntiStuck restart
        If $bOutput > 0 Or _Sleep(500) Then ExitLoop
        If $bUseADB = False Then
            ;Use emulator console to restart game.
            If _Emulator_Console_KillApp($Config_Emulator_Title, $sPackageName) = -1 Then ExitLoop
            If _Sleep(2000) Then ExitLoop
            If _Emulator_Console_RunApp($Config_Emulator_Title, $sPackageName) = -1 Then ExitLoop
        Else
            ;Use adb to restart game.
            If ADB_Command("shell am force-stop " & $sPackageName) = False Then ExitLoop
            If _Sleep(2000) Then ExitLoop
            If ADB_Command("shell am start -n " & $sPackageName & "/" & $sActivity) = False Then ExitLoop
        EndIf
        If _Sleep(10000) Then ExitLoop

        ResetHandles()
        clickPoint(getPointArg("tap")) ; Closes app crash window

        Status("Waiting for game to load.")
        Local $sWait = waitLocation("tap-to-start,app-maintenance,app-update", 240, 5000, False, True) ;4 minutes wait
        If $sWait <> "$game_not_running" Then
            $bOutput = ($sWait == "tap-to-start")
            If $bOutput = True Then
                ExitLoop
            Else
                If $sWait == "app-update" Or $sWait == "app-maintenance" Then 
                    ExitLoop ;app-maintenance or app-update
                EndIf
            EndIf
        EndIf

        $iAttempt -= 1
    WEnd
    $g_bScheduleBusy = $bScheduleBusy
    $g_bRestarting = False

    Log_Add("Restart game result: " & $bOutput, $LOG_DEBUG)
    Log_Level_Remove()
    Return $bOutput
EndFunc

;======================= EMULATOR CONSOLE COMMANDS ======================= 
Func _Emulator_Console_KillApp($sName = $Config_Emulator_Title, $sPackageName = $g_sPackageName)
    Switch StringLower($Config_Emulator_Console)
        Case "noxconsole"
            Emulator_Console_Command("killapp -name:" & $Config_Emulator_Title & " -packagename:" & $sPackageName)
        Case "ldconsole", "dnconsole"
            Emulator_Console_Command("killapp --name " & $Config_Emulator_Title & " --packagename " & $sPackageName)
        Case "memuc"
            Emulator_Console_Command("stopapp -n " & $Config_Emulator_Title & " " & $sPackageName)
        Case Else
            Log_Add("Error: Emulator console is not recognized.", $LOG_ERROR)
            Return -1
    EndSwitch

    Return 1
EndFunc

Func _Emulator_Console_RunApp($sName = $Config_Emulator_Title, $sPackageName = $g_sPackageName)
    Switch StringLower($Config_Emulator_Console)
        Case "noxconsole"
            Emulator_Console_Command("runapp -name:" & $Config_Emulator_Title & " -packagename:" & $sPackageName)
        Case "ldconsole", "dnconsole"
            Emulator_Console_Command("launchex --name " & $Config_Emulator_Title & " --packagename " & $sPackageName)
        Case "memuc"
            Emulator_Console_Command("start -n " & $Config_Emulator_Title)
            Emulator_Console_Command("startapp -n " & $Config_Emulator_Title & " " & $sPackageName)
        Case Else
            Log_Add("Error: Emulator console is not recognized.", $LOG_ERROR)
            Return -1
    EndSwitch

    Return 1
EndFunc
