#include-once
#include "../imports.au3"

Func RestartNox($iPID = WinGetProcess($g_hWindow), $bDebug = False)
	Log_Level_Add("RestartNox")
	Log_Add("Restarting Nox process.")
	$bOutput = False

	While True
		$g_hTimerLocation = Null

		Local $sPath = _WinAPI_GetProcessFileName($iPID)
		Local $aPosition = WinGetPos($g_hWindow)
		Local $t_sCommandLine = StringStripWS(_WinAPI_GetProcessCommandLine($iPID), $STR_STRIPALL)
		Local $aCommandLine = formatArgs(StringMid($t_sCommandLine, StringInStr($t_sCommandLine, "-") + 1), "-", ":")
		Local $sClone = getArg($aCommandLine, "clone")

		If ($sClone <> -1) And (StringInStr($t_sCommandLine, "-clone") = True) Then
			$sClone = " -clone:" & $sClone
		Else
			$sClone = " -clone:Nox"
		EndIf

		Run($sPath & $sClone & " -quit")
		Local $t_hTimer = TimerInit()

		Log_Add("Closing current Nox process.")
		While ProcessExists($iPID) <> 0
			If TimerDiff($t_hTimer) > 120000 Then ;Force end process after 2 minutes

				If (ProcessClose($iPID) = 0) Or (ProcessWaitClose($iPID, 30) = 0) Then
					Log_Add("Could not close current Nox process.", $LOG_ERROR)
					Stop()

					ExitLoop (2)
				EndIf
			EndIf
			If _Sleep(1000) Then ExitLoop (2)
		WEnd

		Log_Add("Starting new Nox process and waiting for handles.")
		Run($sPath & $sClone & " -resolution:800x552 -dpi:160 -package:com.ftt.msleague_gl -lang:en")

		$g_hWindow = 0
		$g_hControl = 0
		Local $hTimer = TimerInit()
		While getLocation() <> "tap-to-start"
			If TimerDiff($hTimer) > 300000 Or _Sleep(1000) Then ExitLoop (2)
			isAdbWorking()

			$g_hWindow = WinGetHandle($g_sWindowTitle)
			$g_hControl = ControlGetHandle($g_hWindow, "", $g_sControlInstance)
			If $g_hWindow <> 0 Then
				Local $t_aPosition = WinGetPos($g_hWindow)
				WinMove($g_hWindow, "", $t_aPosition[0], $t_aPosition[1])
			EndIf
		WEnd

		;Waiting for start menu
		$bOutput = (getLocation() = "tap-to-start")
		ExitLoop
	WEnd
	navigate("map", True, 3)

	Log_Add("Restarting nox result: " & $bOutput, $LOG_DEBUG)
	Log_Level_Remove()
	Return $bOutput
EndFunc   ;==>RestartNox
