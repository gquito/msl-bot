#include-once
#include "../imports.au3"

Func RestartNox($iAttempt = 1)
    Log_Level_Add("RestartNox")
    Log_Add("Restarting Nox process.")
    $g_bRestarting = True

    Local $bOutput = False
    While $iAttempt >= 1
        $iAttempt -= 1

        $g_hTimerLocation = NULL ;Reset restart timer to prevent meta restart.
        While True
            $g_hTimerLocation = Null

            ;Getting all process information to restart process with correct Nox clone.
            ;Clone can be found and ran through Command Line. If no clone is in command line then
            ;   the original Nox emulator is used.
            Local $iPID = WinGetProcess($g_hWindow)
            Local $sPath = _WinAPI_GetProcessFileName($iPID)
            Local $sCommandLine = StringStripWS(_WinAPI_GetProcessCommandLine($iPID), $STR_STRIPALL)

            Local $old_aPos = WinGetPos($g_hWindow)

            Local $aCommandLine = formatArgs(StringMid($sCommandLine, StringInStr($sCommandLine, "-")+1), "-", ":")
            Local $sClone = getArg($aCommandLine, "clone")

            If ($sClone <> -1 And StringInStr($sCommandLine, "-clone")) Then
                $sClone = " -clone:" & $sClone
            Else
                $sClone = " -clone:Nox"
            EndIf

            Log_Add("Closing current Nox process.")

            Local $hTimer = TimerInit()
            While ProcessExists($iPID) = True
                If (TimerDiff($hTimer) > 120000 Or _Sleep(1000)) Then ;Force end process after 2 minutes
                    Log_Add("RestartNox() => Could not close Nox process.", $LOG_ERROR)
                    ExitLoop(2)
                EndIf

                ProcessClose($iPID)
            WEnd

            Local $sRun = $sPath & $sClone & " -resolution:800x552 -dpi:160 -package:com.ftt.msleague_gl -lang:en"
            Log_Add("Starting Nox process: " & $sRun)

            Run($sRun, "", @SW_SHOWNOACTIVATE)

            ;Waiting for Nox handles to load.
            $g_hWindow = 0
            $g_hControl = 0

            $hTimer = TimerInit()
            While ($g_hWindow = 0 Or $g_hControl = 0)
                If (TimerDiff($hTimer) > 120000 Or _Sleep(5000)) Then ;Force end process after 2 minutes
                    Log_Add("RestartNox() => Could not get Nox handles.", $LOG_ERROR)
                    ExitLoop(2)
                EndIf

                resetHandles()

                If (isArray($old_aPos)) Then _WinAPI_SetWindowPos($g_hWindow, $HWND_BOTTOM, $old_aPos[0], $old_aPos[1], -1, -1, $SWP_NOACTIVATE+$SWP_NOSIZE)
            WEnd

            If (Not(_Establish_ADB(60000))) Then 
                Log_Add("RestartNox() => ADB did not work.", $LOG_ERROR)
                ExitLoop
            EndIf

            If (Not(isGameRunning())) Then 
                If (RestartGame()) Then 
                    $bOutput = True
                    ExitLoop(2)
                EndIf
            EndIf

            ;Might cause some problems with ADB capture mode because ADB has not been established yet.
            ;Probably need a better to wait until we are able to re-establish ADB
            $hTimer = TimerInit()
            While Not(isLocation("tap-to-start"))
                $g_hTimerLocation = NULL ;Reset restart timer to prevent meta restart.
                If Mod(TimerDiff($hTimer), 5) Then clickPoint(getPointArg("facebook-login-close"))
                If (TimerDiff($hTimer) > 300000 Or _Sleep(5000)) Then
                    Log_Add("RestartNox() => Could not detect game.", $LOG_ERROR)
                    ExitLoop(2)
                EndIf

                resetHandles()
            WEnd

            ;Waiting for start menu
            $bOutput = (getLocation() = "tap-to-start")
            ExitLoop
        WEnd

        If ($bOutput) Then 
        	$g_bRestarting = False
            navigate("map", True, 3)
            ExitLoop ;Exit attempts
        EndIf
    WEnd
    
    $g_bRestarting = False
    Log_Add("Restarting nox result: " & $bOutput, $LOG_DEBUG)
    Log_Level_Remove()
    Return $bOutput
EndFunc

Func isGameRunning()
    If (Not($g_bADBWorking)) Then Return 2
	
	$g_bLogEnabled = False
	Local $bRunning = (StringInStr(ADB_Command("shell ps"), "com.ftt.msleague_gl") > 0)
	$g_bLogEnabled = True

	If (Not($bRunning)) Then Log_Add("Is game running: " & $bRunning, $LOG_DEBUG)
    Return $bRunning
EndFunc

Func RestartGame($iAttempt = 1)
    Log_Level_Add("RestartGame")
    Log_Add("Restarting game.")
	$g_bRestarting = True
    $bOutput = False

	While $iAttempt >= 1
		$iAttempt -= 1

		$g_hTimerLocation = NULL ;Reset restart timer to prevent meta restart.
		While True
			Local $hTimer ;Store timer

			If (Not($g_bADBWorking)) Then 
				Log_Add("ADB Unavailable, could not restart game.", $LOG_ERROR)
				ExitLoop(2)
			EndIf

			If (isGameRunning()) Then
				Log_Add("Game is already running, killing current process.", $LOG_DEBUG)

				$hTimer = TimerInit()
				While isGameRunning()
					If (TimerDiff($hTimer) > 120000 Or _Sleep(2000)) Then 
						Log_Add("RestartGame() => Could not close game process.", $LOG_ERROR)
						ExitLoop(2)
					EndIf

					ADB_Command("shell am force-stop com.ftt.msleague_gl")
				WEnd
			EndIf

			;Start game through ADB
			Log_Add("Starting game and waiting for main screen.")
			$hTimer = TimerInit()
			While Not(isGameRunning())
				If (TimerDiff($hTimer) > 120000 Or _Sleep(2000)) Then 
					Log_Add("RestartGame() => Could not open game process.", $LOG_ERROR)
					ExitLoop(2)
				EndIf

				ADB_Command("shell monkey -p com.ftt.msleague_gl -c android.intent.category.LAUNCHER 1")
			WEnd

			;Waiting for start menu
			$hTimer = TimerInit()
			While Not(isLocation("tap-to-start,app-maintenance,app-update,data-update-download"))
				$g_hTimerLocation = NULL ;Reset restart timer to prevent meta restart.
                If Mod(TimerDiff($hTimer), 5) Then clickPoint(getPointArg("facebook-login-close"))
				If (TimerDiff($hTimer) > 300000 Or _Sleep(1000)) Then
					Log_Add("RestartGame() => Could not detect game.", $LOG_ERROR)
					ExitLoop(2)
				EndIf
			WEnd

			if (isLocation("app-maintenance")) Then
				Log_Add("Maintenance found. Waiting " & ($g_iMaintenanceTimeout) & " minutes then restarting game.", $LOG_DEBUG)
				$hTimer = TimerInit()
				While TimerDiff($hTimer) < (1000 * 60 * $g_iMaintenanceTimeout)
					_Sleep(10)
				WEnd
				ContinueLoop
			EndIf

			If (isLocation("app-update,data-update-download")) Then
				HandleAppUpdate()
				ContinueLoop
			EndIf

			;Waiting for start menu
			$bOutput = isLocation("tap-to-start")
			ExitLoop
		WEnd

		If ($bOutput) Then 
			$g_bRestarting = False
			navigate("map", True, 2)
			ExitLoop ;Exit attempts
		EndIf
	WEnd

    Log_Add("Restart game result: " & $bOutput, $LOG_DEBUG)
    Log_Level_Remove()
    Return $bOutput
EndFunc

Func resetHandles()
	$g_hWindow = WinGetHandle($g_sWindowTitle)
	$g_hControl = ControlGetHandle($g_hWindow, "", $g_sControlInstance)
    If $g_hControl = 0x000000 Then 
        $g_hControl = ControlGetHandle($g_hWindow, "", $d_sControlInstance)
    EndIf
EndFunc