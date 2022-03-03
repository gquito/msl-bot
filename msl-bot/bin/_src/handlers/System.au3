#include-once

#cs
    Function: Sleep that accounts for script state
    Parameters:
        $iDuration: Amount of time to sleep in milliseconds
    Returns: True if script needs to be stopped.
#ce
Global $g_hTimer_TimeLabel = TimerInit()
Func _Sleep($iDuration = 0, $bPrecise = False)
    Local $hTimer = TimerInit()
    Do
        If (UBound($g_aLog) > $g_iLOG_Processed) Then Log_Display()

        If $g_bRunning > 0 Then
            If $iDuration = 0 And $g_bRestarting = 0 Then ExitLoop
            If $g_hScriptTimer <> Null Then
                If (BitAnd(WinGetState($g_hParent), $WIN_STATE_MINIMIZED) = False And TimerDiff($g_hTimer_TimeLabel) > 1000) And _GUICtrlTab_GetCurSel($g_hTb_Main) = 1 Then
                    GUICtrlSetData($g_idLbl_ScriptTime, "Time: " & getTimeString(TimerDiff($g_hScriptTimer)/1000))
                    $g_hTimer_TimeLabel = TimerInit()
                EndIf

                If $g_bRestarting = 0 Then _AntiStuck()
            EndIf

            While $g_bPaused
                $g_hTimerLocation = Null
                GUI_HANDLE()
            WEnd

            GUI_HANDLE()
        Else
            $g_hTimerLocation = Null
            Return True
        EndIf
        If $bPrecise = False Then Sleep(5)
    Until (TimerDiff($hTimer) > $iDuration)
    Return False
EndFunc

Func _AntiStuck()
    If $g_bAntiStuck = False Or $g_bRestarting = True Then Return True
    Log_Level_Add("_AntiStuck")
    Local $bOutput = False
    
    $g_bAntiStuck = False
    If $Config_Screen_Frozen_Check <> $CONFIG_NEVER Then
        If Mod(Int(TimerDiff($g_hScriptTimer)/1000)+1, $Config_Screen_Frozen_Check) = 0 And TimerDiff($g_hGameCheckCD) > 2000 Then
            $g_hGameCheckCD = TimerInit()
            If _AntiStuck_Frozen() = True Then
                Log_Add("AntiStuck: Game is frozen. Restarting Game.", $LOG_ERROR)
    
                $bOutput =_AntiStuck_Restart()
                If $bOutput <= 0 Then Stop()
            EndIf
        EndIf
    EndIf

    If $Config_Location_Stuck_Timeout <> $CONFIG_NEVER Then
        If $g_hTimerLocation <> Null Then
            If TimerDiff($g_hTimerLocation) > (60000 * $Config_Location_Stuck_Timeout) Then
                $g_hTimerLocation = Null

                Log_Add("AntiStuck: Stuck for " & $Config_Location_Stuck_Timeout & " minutes, restarting game.", $LOG_ERROR)
                If navigate("map", True) = 0 Then
                    $bOutput =_AntiStuck_Restart()
                    If $bOutput = 0 Then Stop()
                EndIf
            EndIf
        EndIf
    EndIf

    IF $Config_ADB_Game_Check <> $CONFIG_NEVER And $g_sLocation == "unknown" Then
        If Mod(Int(TimerDiff($g_hScriptTimer)/1000), $Config_ADB_Game_Check) = 0 Then
            If ADB_isGameRunning() = False Then
                Log_Add("AntiStuck: Game is not running. Restarting Game.", $LOG_ERROR)
                $bOutput =_AntiStuck_Restart()
                If $bOutput = False Then Stop()
            EndIf
        EndIf
    EndIf
    $g_bAntiStuck = True

    Log_Level_Remove()
    Return $bOutput
EndFunc

Global $_AntiStuck_Frozen = Null
Func _AntiStuck_Frozen()
    If $_AntiStuck_Frozen = Null Then
        CaptureRegion()
        $_AntiStuck_Frozen = GetPixelSum()
        If @error Then $_AntiStuck_Frozen = Null

        Return False
    EndIf

    CaptureRegion()
    Local $iSum = GetPixelSum()
    If @error Then Return False

    Local $iResult = ($_AntiStuck_Frozen = $iSum)
    $_AntiStuck_Frozen = Null

    Return $iResult
EndFunc

Func _AntiStuck_Restart()
    Local $bOutput = True
    If Emulator_RestartGame(3) = False Then
        If Emulator_Restart(3) = False Then
            Log_Add("AntiStuck: Could not restart emulator.", $LOG_ERROR)
            $bOutput = False
        EndIf
    EndIf
    Return $bOutput
EndFunc


;===============================================================================
;
; Name...........: _HighPrecisionSleep()
; Description ...: Sleeps down to 0.1 microseconds
; Syntax.........: _HighPrecisionSleep( $iMicroSeconds, $hDll=False)
; Parameters ....:  $iMicroSeconds      - Amount of microseconds to sleep
;                  $hDll  - Can be supplied so the UDF doesn't have to re-open the dll all the time.
; Return values .: None
; Author ........: Andreas Karlsson (monoceres)
; Modified.......:
; Remarks .......: Even though this has high precision you need to take into consideration that it will take some time for autoit to call the function.
; Related .......:
; Link ..........;
; Example .......; No
;
;;==========================================================================================
Func _HighPrecisionSleep($iMicroSeconds,$hDll=False)
    Local $hStruct, $bLoaded
    If Not $hDll Then
        $hDll=DllOpen("ntdll.dll")
        $bLoaded=True
    EndIf
    $hStruct=DllStructCreate("int64 time;")
    DllStructSetData($hStruct,"time",-1*($iMicroSeconds*10))
    DllCall($hDll,"dword","ZwDelayExecution","int",0,"ptr",DllStructGetPtr($hStruct))
    ;If $bLoaded Then DllClose($hDll)
EndFunc


;calls for debug prompt
Global $g_hDebugInput = Null
Global $g_aDebugInput_History[0]
Global $g_hDebugInput_listHistory = Null
Func DebugInput_CreateGUI()
    If $g_hDebugInput <> Null Then
        GUIDelete($g_hDebugInput)
        $g_hDebugInput = Null
    EndIf

    $g_hDebugInput = GUICreate("MSL Bot Debug Input", 402, 138, -1, -1, -1, -1, $g_hParent)
    Global $g_idDebugInput_editMain = GUICtrlCreateEdit("", 8, 24, 257, 105)
    Global $g_idDebugInput_lblExpression = GUICtrlCreateLabel("Enter an expression:", 8, 6, 100, 17)
    Global $g_idDebugInput_listHistory = GUICtrlCreateListView("", 272, 24, 121, 71, $LVS_SINGLESEL+$LVS_NOCOLUMNHEADER, $LVS_EX_FULLROWSELECT+$LVS_EX_GRIDLINES+$WS_EX_CLIENTEDGE+$LVS_EX_FLATSB)
    _GUICtrlListView_AddColumn($g_idDebugInput_listHistory, "History", 300)
    $g_hDebugInput_listHistory = GUICtrlGetHandle($g_idDebugInput_listHistory)
    Global $g_idDebugInput_btnRun = GUICtrlCreateButton("Run", 272, 104, 123, 25)
    Global $g_idDebugInput_lblHistory = GUICtrlCreateLabel("History", 314, 6, 36, 17)
    GUISetState(@SW_SHOW)

    Local $sPath = $g_sProfileFolder & "\" & $Config_Profile_Name & "\debug\history"
    If UBound($g_aDebugInput_History) = 0 And FileExists($sPath) = True Then
        Local $sData = FileRead($sPath)
        $g_aDebugInput_History = StringSplit($sData, @CRLF, $STR_NOCOUNT)
        For $i = UBound($g_aDebugInput_History)-1 To 0 Step -1
            Local $sExpression = $g_aDebugInput_History[$i]
            If $sExpression == "" Then
                _ArrayDelete($g_aDebugInput_History, $i)
            EndIf
        Next
        If isArray($g_aDebugInput_History) = False Then
            $g_aDebugInput_History = CreateArr($sData)
        EndIf
    EndIf

    For $sExpression In $g_aDebugInput_History
        If $sExpression == "" Then ContinueLoop
        _GUICtrlListView_AddItem($g_idDebugInput_listHistory, $sExpression)
        If GUICtrlRead($g_idDebugInput_editMain) == "" Then
            GUICtrlSetData($g_idDebugInput_editMain, StringReplace($sExpression, "|", @CRLF))
        EndIf
    Next
EndFunc

Func _ProcessLines($aLines, $bDisplayArray = True, $bLog = True)
    For $i = 0 To UBound($aLines)-1
        If ($aLines[$i] == "") Then ContinueLoop
        Local $sResult = Execute($aLines[$i])

        If (@error) Then
            If $bLog Then Log_Add("ERROR (" & @error & "," & @extended & ") <= " & $aLines[$i], $LOG_INFORMATION)
            ContinueLoop
        EndIf

        If (Not(isArray($sResult)) And String($sResult) == "") Then $sResult = "N/A"

        If (isArray($sResult)) Then
            If $bDisplayArray > 0 Then _ArrayDisplay($sResult)
            If $bLog Then Log_Add("{Array} <= " & $aLines[$i], $LOG_INFORMATION)
        Else
            If $bLog Then Log_Add(String($sResult) & " <= " & $aLines[$i], $LOG_INFORMATION)
        EndIf
    Next
EndFunc