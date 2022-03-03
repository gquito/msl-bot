#include-once

Func Start($bSchedule = True)
    $g_bLogEnabled = True
    Log_Level_Add("PREPROCESS")
    Log_Add("Initializing scripts and checking preconditions.", $LOG_DEBUG)

    ;Setting controls
    Local $sUser = "[" & $Config_Profile_Name & "] "
    GUICtrlSetData($g_idLbl_RunningScript, "Running Script: " & $sUser & $g_sScript)
    ControlDisable("", "", $g_hCmb_Scripts)
    ControlDisable("", "", $g_hLV_ScriptConfig)
    ControlDisable("", "", $g_hBtn_Start)
    ControlDisable("", "", $g_hBtn_StatReset)

    ControlEnable("", "", $g_hBtn_Stop)
    ControlEnable("", "", $g_hBtn_Pause)

    _GUICtrlTab_ClickTab($g_hTb_Main, 1)

    ;Initializing variables
    Local $bOutput = True
    $g_bRunning = True

    If isDeclared("Astrogems_Used") Then
        $Astrogems_Used = 0
    EndIF

    Config_Update()
    ResetHandles()
    ScriptTest_Handles() ;Debug info
    Stats_Clear()

    $g_hScriptTimer = TimerInit()
    $g_bAntiStuck = True
    
    ;Pre Conditions
    If $g_hWindow = 0 Or $g_hControl = 0 Then
        Log_Add("Window handle not found.", $LOG_ERROR)

        Local $aCandidates = FindEmulatorCandidates()
        Local $sCandidateMessage = ""
        If UBound($aCandidates) > 0 Then
            $sCandidateMessage = "Possible Emulator Title candidates: " & _ArrayToString($aCandidates, ", ")
        EndIf

        MsgBox($MB_ICONERROR+$MB_OK, _
            "Window handle not found.", "Window handle (" & $Config_Emulator_Title & ") : " & $g_hWindow & @CRLF & @CRLF & _
            "Control handle (" & $Config_Emulator_Property & ") : " & $g_hControl & @CRLF & @CRLF & _ 
            "Tip: Check if Emulator Title and Resolution (800x552) are correct." & @CRLF & @CRLF & _
            $sCandidateMessage)

        $bOutput = False
    EndIf

    ;Establish ADB controls
    ;If $bOutput > 0 And ADB_Establish() <= 0 Then $bOutput = False
    If ADB_Establish(False) = False Then
        Log_Add("ADB is not working. Some features may not work properly.", $LOG_ERROR)
    EndIf

    If ($g_bRunning > 0 And $bOutput > 0) And ($Config_Mouse_Mode = $MOUSE_REAL Or $Config_Swipe_Mode == $SWIPE_REAL) Then
        MsgBox($MB_ICONWARNING+$MB_OK, "Script is using real mouse.", "Mouse cursor will be moved automatically. To stop the script, press ESCAPE key.")
        HotKeySet("{ESC}", "Stop")
    EndIf

    If $g_bRunning > 0 And $bOutput > 0 Then
        If $g_sScript == "" Then _GUICtrlComboBox_GetLBText($g_hCmb_Scripts, _GUICtrlComboBox_GetCurSel($g_hCmb_Scripts), $g_sScript)
        GUICtrlSetData($g_idLbl_RunningScript, "Running Script: " & $sUser & $g_sScript)


        ;DEBUG INFO=============================
        Local $aData = ($g_aScripts[0])[2] ;Config data
        For $i = 0 To UBound($aData)-1
            Local $aSetting = $aData[$i] ;Setting data
            Log_Add("::" & $aSetting[0] & " = " & $aSetting[1], $LOG_DEBUG)
        Next
    
        Log_Add("Current Script: " & $g_sScript, $LOG_DEBUG)
        Local $iIndex = -1
        For $i = 0 To UBound($g_aScripts)-1
            If ($g_aScripts[$i])[0] = StringReplace($g_sScript, " ", "_") Then
                $iIndex = $i
                ExitLoop
            EndIf
        Next
    
        If $iIndex <> -1 Then
            $aData = ($g_aScripts[$iIndex])[2] ;Current Script data
            For $i = 0 To UBound($aData)-1
                Local $aSetting = $aData[$i] ;Setting data
                Log_Add("::" & $aSetting[0] & " = " & $aSetting[1], $LOG_DEBUG)
            Next
        EndIf
        ;========================================
        Cumulative_Load()
        If $bSchedule = True Then Start_Schedule()
    EndIf

    Log_Add("Start result: " & $bOutput & ".", $LOG_DEBUG)
    Log_Level_Remove()
    Return $bOutput
EndFunc

Func Start_Schedule()
    If StringLeft($g_sScript, 4) == "Farm" Or StringLeft($g_sScript, 6) == "Attack" Then
        Local $aStructure = ""
        Local $aAction = ""
        If $Hourly_Hourly_Script = True Then
            $aStructure = CreateArr(CreateArr("*", "*", "*", "01", "*"))
            $aAction = CreateArr("doHourly()")
            Schedule_Add("_Hourly", $aAction, $SCHEDULE_TYPE_DATE, "*", $aStructure, $SCHEDULE_FLAG_RunSafe, 60, True, False)
        EndIf

        If $Guardian_Guardian_Script = True Then
            $aStructure = CreateArr(TimerInit(), $Guardian_Check_Intervals*60)
            $aAction = CreateArr('_Schedule_Guardian()')
            Schedule_Add("_Guardian", $aAction, $SCHEDULE_TYPE_TIMER, "*", $aStructure, $SCHEDULE_FLAG_RunSafe, 0, True, False)
        EndIf

        ;Scheduled Restart
        If $Config_Scheduled_Restart <> $CONFIG_NEVER Then
            Local $aRestart = StringSplit($Config_Scheduled_Restart, ":", $STR_NOCOUNT)
            If isArray($aRestart) = True And UBound($aRestart) = 2 Then
                $aRestart[1] = StringReplace($aRestart[1], "H", "")
                $aStructure = CreateArr(TimerInit(), $aRestart[1]*60*60)
                If $aRestart[0] == "Game" Then $aAction = CreateArr('Emulator_RestartGame(2)')
                If $aRestart[0] == "Emulator" Then $aAction = CreateArr('Emulator_Restart(2)')
                Schedule_Add("_Restart", $aAction, $SCHEDULE_TYPE_TIMER, "*", $aStructure, $SCHEDULE_FLAG_RunImmediately, 0, True, False)
            EndIf 
        EndIf

        ;App maintenance and and app update
        $aStructure = CreateArr(CreateArr(CreateArr('$g_sLocation == "app-maintenance"')), True)
        $aAction = CreateArr('appMaintenance()')
        Schedule_Add("_Maintenance", $aAction, $SCHEDULE_TYPE_CONDITION, "*", $aStructure, $SCHEDULE_FLAG_RunImmediately, 0, True, False)
    
        $aStructure = CreateArr(CreateArr(CreateArr('$g_sLocation == "app-update"'), CreateArr('$g_sLocation == "app-update-ok"')), True)
        $aAction = CreateArr('appUpdate()')
        Schedule_Add("_Update", $aAction, $SCHEDULE_TYPE_CONDITION, "*", $aStructure, $SCHEDULE_FLAG_RunImmediately, 0, True, False)
    EndIf
EndFunc

Func _Schedule_Stop()
    Schedule_RemoveByName("_Hourly")
    Schedule_RemoveByName("_Guardian")
    Schedule_RemoveByName("_Restart")
    Schedule_RemoveByName("_Maintenance")
    Schedule_RemoveByName("_Update")
EndFunc

Func _Schedule_Guardian()
    Local $aValues = Stats_Values_GetSpecific(Stats_GetValues($g_aStats), CreateArr("Guardians", "Astrogems_Used"))
    Local $aParam = CreateArr($Guardian_Guardian_Mode, IsDeclared($g_sScript & "_Refill")?Eval($g_sScript & "_Refill"):0, $CONFIG_NEVER, $Guardian_Target_Boss)
    _RunScript("Farm_Guardian", $aParam, $aValues)

    navigate("map")
EndFunc

Func Stop()
    Log_Add("Stopping running scripts.", $LOG_INFORMATION)
    $g_bLogEnabled = False
    HotKeySet("{Esc}") ;unbinds hotkey

;Resets variables
    If (FileExists($ADB_PC_Shared & "\" & $Config_Emulator_Title & ".rgba")) Then FileDelete($ADB_PC_Shared & "\" & $Config_Emulator_Title & ".rgba")
    $g_hTimerLocation = Null
    $g_hScriptTimer = Null
    $g_sScript = ""
    $g_bAntiStuck = False
    $g_bTitansFast = False

;Removing Schedules
    _Schedule_Stop()

;Setting control states
    GUICtrlSetData($g_idLbl_RunningScript, "Running Script: ")
    ControlEnable("", "", $g_hCmb_Scripts)
    ControlEnable("", "", $g_hLV_ScriptConfig)
    ControlEnable("", "", $g_hBtn_Start)
    ControlEnable("", "", $g_hBtn_StatReset)

    ControlDisable("", "", $g_hBtn_Stop)
    ControlDisable("", "", $g_hBtn_Pause)

;Calls to stop scripts
    $g_bRunning = False
    WinSetTitle($g_hParent, "", $g_sAppTitle & UpdateStatus())

;Cumulative
    Cumulative_Save()
EndFunc

Func Pause()
    $g_bPaused = Not($g_bPaused)

    If ($g_bPaused) Then
        ;From not being paused to being paused
        _GUICtrlButton_SetText($g_hBtn_Pause, "Unpause")
        ControlDisable("", "", $g_hBtn_Stop)
    Else
        ;From being paused to being unpaused
        _GUICtrlButton_SetText($g_hBtn_Pause, "Pause")
        ControlEnable("", "", $g_hBtn_Stop)
    EndIf
EndFunc

Func CloseApp()
    Cumulative_Save()
    FileDelete($ADB_PC_Shared & "\" & $Config_Emulator_Title & ".rgba")
    ProcessClose($g_hADBShellPID)
    Exit
EndFunc

;Includes tests to see if all features are working properly.
Func ScriptTest()
    If $g_hCompatibilityTest <> Null Then GUI_HANDLE_MESSAGE(CreateArr($GUI_EVENT_CLOSE, $g_hCompatibilityTest))

    Log_Level_Add("SCRIPT_TEST")
    Local $aTempLOG[0]
    _ArrayAdd($aTempLOG, "== Starting Compatibility Test ==")
    Local $sError = "" ;Will store error information.

    ;Pre test
    If (MsgBox($MB_ICONINFORMATION+$MB_OKCANCEL, "MSL Bot Compatibility Test", "Navigate to the MAP in the game and press OKAY to begin the test.") = $IDCANCEL) Then
        _ArrayAdd($aTempLOG, "== Finished Compatibility Test ==")

        For $i = UBound($aTempLOG)-1 To 0 Step -1
            Log_Add($aTempLOG[$i])
        Next
        Log_Level_Remove()
        
        Return "CANCELED"
    EndIf

    ;Add necessary information 
    _ArrayAdd($aTempLOG, "Config information:")
    _ArrayAdd($aTempLOG, "  -Bot version: " & _ArrayToString($aVersion, "."))
    _ArrayAdd($aTempLOG, "  -Emulator Path: " & $Config_Emulator_Path)
    _ArrayAdd($aTempLOG, "  -Emulator Console: " & $Config_Emulator_Console)
    _ArrayAdd($aTempLOG, "  -Emulator Title: " & $Config_Emulator_Title)
    _ArrayAdd($aTempLOG, "  -Emulator Property: " & $Config_Emulator_Property)
    _ArrayAdd($aTempLOG, "  -Display Scaling: " & $Config_Display_Scaling)
    _ArrayAdd($aTempLOG, "  -Capture Mode: " & $BKGD_STR[$Config_Capture_Mode])
    _ArrayAdd($aTempLOG, "  -Mouse Mode: " & $MOUSE_STR[$Config_Mouse_Mode])
    _ArrayAdd($aTempLOG, "  -Swipe Mode: " & $SWIPE_STR[$Config_Swipe_Mode])
    _ArrayAdd($aTempLOG, "  -Back Mode: " & $BACK_STR[$Config_Back_Mode])

    ;Test window and control handle.
    ScriptTest_Handles()
    _ArrayAdd($aTempLOG, "Checking handles:")
    _ArrayAdd($aTempLOG, "  -Window handle: " & $g_hWindow)
    _ArrayAdd($aTempLOG, "  -Control handle: " & $g_hControl)

    If ($g_hWindow = 0) Then 
        $sError &= @CRLF & @CRLF & "• Error: Window handle was not found."
        $sError &= @CRLF & @CRLF & "- Tip: Make sure the emulator is running and has 800x552 resolution."

        Local $aCandidates = FindEmulatorCandidates()
        If UBound($aCandidates) > 0 Then
            $sError &= @CRLF & @CRLF & "- Tip: Possible Emulator Title candidates: " & _ArrayToString($aCandidates, ", ")
        EndIf
    EndIf

    If ($g_hWindow <> 0 And $g_hControl = 0) Then 
        $sError &= @CRLF & @CRLF & "• Error: Control handle was not found."
        $sError &= @CRLF & @CRLF & "- Tip: Make sure to enter the correct Emulator Property or use ~AUTO in _Config."
    EndIf

    ;Test Capture and Clicks
    Local $bCaptureWorking = False
    _ArrayAdd($aTempLOG, "Checking capture and click:")
    If ($g_hControl <> 0) Then
        CaptureRegion()

        Local $cFirst = getColor(0, 0)

        _ArrayAdd($aTempLOG, "  -Current location: " & getLocation())
        If (String($cFirst) == "0x000000" Or String($cFirst) == "0xFFFFFF" Or Not(isLocation("map"))) Then
            $sError &= @CRLF & @CRLF & "• Error: Could not capture the emulator correctly. Make sure you are in MAP."
            $sError &= @CRLF & @CRLF & "- Tip: If you are in the map, make sure the resolution of the emulator is 800x552 and is not maximized."
            $sError &= @CRLF & @CRLF & "- Tip: You can use Debug->General->Restart Emulator in the menu to automatically set the resolution (this automatic method could fail)."
            $sError &= @CRLF & @CRLF & "- Tip: Change the GRAPHICS RENDERING MODE in the emulator settings or change the CAPTURE METHOD in _Config."
            $sError &= @CRLF & @CRLF & "• Error: Could not test click status because capture is not working."

            _ArrayAdd($aTempLOG, "  -Click working status: Unknown")
        Else
            $bCaptureWorking = True

            ;Opens refill window
            If clickWhile("414,16", "isPixel", CreateArr("0,0," & $cFirst), 5, 2000, "CaptureRegion()") = 0 Then 
                $sError &= @CRLF & @CRLF & "• Error: Click is not working."
                $sError &= @CRLF & @CRLF & "- Tip: Control handle might not allow for clicking. Change Emulator Property."
                $sError &= @CRLF & @CRLF & "- Tip: Make sure you have the correct DISPLAY SCALING."
                $sError &= @CRLF & @CRLF & "- Tip: You can check by right clicking in your desktop and clicking Display Settings."
                $sError &= @CRLF & @CRLF & "- Tip: Set the setting DISPLAY SCALING in _Config as the same as the scaling in your display setting."
                $sError &= @CRLF & @CRLF & "- Tip: You can also try to change the click method in _Config."
            
                _ArrayAdd($aTempLog, "  -Click working status: False")
            Else
                _ArrayAdd($aTempLog, "  -Click working status: True")
            EndIf
        EndIf
        _ArrayAdd($aTempLog, "  -Capture working status: " & $bCaptureWorking)
    Else
        $sError &= @CRLF & @CRLF & "• Error: Could not test capture and click because window/control handles was not found."
        _ArrayAdd($aTempLOG, "  -Capture working status: Unknown")
        _ArrayAdd($aTempLOG, "  -Click working status: Unknown")
    EndIf
    
    ;Test ADB functions.
    _ArrayAdd($aTempLOG, "Checking ADB:")
    Local $bAdbWorking = ADB_IsWorking()
    _ArrayAdd($aTempLOG, "  -ADB working status: " & $bAdbWorking)

    If $bAdbWorking <= 0 Then 
        $sError &= @CRLF & @CRLF & "• Error: ADB is not working."  
        $sError &= @CRLF & @CRLF & "- Tip: Bot will still work without ADB by setting Mouse, Swipe, and Back control to Real or Control (_Config)."
        $sError &= @CRLF & @CRLF & "- Tip: Bot will still work without ADB by setting ADB Restart Game to Disabled (_ADB)."
        $sError &= @CRLF & @CRLF & "- Tip: Make sure the Emulator Path (in _Config) and Device (in _ADB) are correct or use ~AUTO."
        $sError &= @CRLF & @CRLF & "- Tip: Emulator Path is the path to the emulator directory which contains the ADB executable: adb.exe."
        $sError &= @CRLF & @CRLF & "- Tip: Get the Device list using Debug->ADB->Device List in the menu."
        $sError &= @CRLF & @CRLF & "- Tip: For Multiple emulators will need to see which device goes with an emulator or use ~AUTO."
    EndIf

    If $bAdbWorking > 0 And $bCaptureWorking > 0 Then
        If isLocation("map") > 0 Then
            Local $bAdbResponse = clickWhile("414,16", "isPixel", CreateArr("0,0," & getColor(0, 0)), 5, 2000, "CaptureRegion()", $MOUSE_ADB)
            _ArrayAdd($aTempLOG, "  -ADB response status: " & $bAdbResponse) ; Opens refill window using ADB
            If $bAdbResponse = 0 Then 
                $sError &= @CRLF & @CRLF & "• Error: Emulator is not responding to the ADB command." 
                $sError &= @CRLF & @CRLF & "- Tip: The Device in _ADB might not be valid."
                $sError &= @CRLF & @CRLF & "- Tip: Get the device list using Debug->ADB->Device List in the menu or use ~AUTO."
            EndIf
        Else
            SendBack(1, 0, $BACK_ADB)
            If waitLocation("map", 5) = 0 Then
                _ArrayAdd($aTempLOG, "  -ADB response status: False")
                $sError &= @CRLF & @CRLF & "• Error: Emulator is not responding to the ADB command." 
                $sError &= @CRLF & @CRLF & "- Tip: The Device in _ADB might not be valid."
                $sError &= @CRLF & @CRLF & "- Tip: Get the device list using Debug->ADB->Device List in the menu or use ~AUTO."
            Else
                _ArrayAdd($aTempLOG, "  -ADB response status: True")
            EndIf
        EndIf
    Else
        _ArrayAdd($aTempLOG, "  -ADB response status: Unknown")
        $sError &= @CRLF & @CRLF & "• Error: Could not test ADB response because ADB or Capture is not working."
    EndIf
    
    ;Check Resolution
    If ($bAdbWorking) Then
        _ArrayAdd($aTempLOG, "Checking resolution: ")
        
        Local $aTemp = StringRegExp(ADB_Command("shell wm size"), "(\d+x\d+)", 3)
        If isArray($aTemp) > 0 And UBound($aTemp) > 0 Then
            _ArrayAdd($aTempLOG, "  -Android Resolution: " & $aTemp[0])
            If $aTemp[0] <> "800x552" Then $sError &= @CRLF & "- Emulator resolution is not 800x552."
        EndIf

        $aTemp = StringRegExp(ADB_Command("shell wm density"), "(\d+)", 3)
        If isArray($aTemp) > 0 And UBound($aTemp) > 0 Then
            _ArrayAdd($aTempLOG, "  -Android DPI: " & $aTemp[0])
            If $aTemp[0] <> "160" Then $sError &= @CRLF & "- Emulator dpi is not 160."
        EndIf
    EndIf
    
    ;Imagesearch test
    _ArrayAdd($aTempLOG, "Checking Imagesearch:")
    Local $t_hBitmap = _WinAPI_LoadImage(0, @ScriptDir & "\bin\images\misc\misc-test1.bmp", $IMAGE_BITMAP, 0, 0, $LR_LOADFROMFILE)
    If ($t_hBitmap <> 0) Then
        $g_hBitmap = $t_hBitmap
        If (isArray(findImage("misc-test2", 90, 0, 0, 0, 597, 348, False))) Then
            _ArrayAdd($aTempLOG, "  -Imagesearch working status: True")
        Else
            _ArrayAdd($aTempLOG, "  -Imagesearch working status: False")
            $sError &= @CRLF & @CRLF & "• Error: Imagesearch did not work."
            $sError &= @CRLF & @CRLF & "- Tip: Make sure to have the file `\bin\dll\ImageSearchLibrary.dll`."
            $sError &= @CRLF & @CRLF & "- Tip: Make sure you are running the bot as an x86 script and NOT as an x64 script."
        EndIf
    Else
        _ArrayAdd($aTempLOG, "  -Imagesearch working status: Unknown")
        $sError &= @CRLF & @CRLF & "• Error: The file \bin\images\misc\misc-test1.bmp or \bin\images\misc\misc-test2.bmp is missing. Could not check imagesearch status."
    EndIf
    _WinAPI_DeleteObject($t_hBitmap)
    _ArrayAdd($aTempLOG, "== Finished Compatibility Test ==")

    For $i = UBound($aTempLOG)-1 To 0 Step -1
        Log_Add($aTempLOG[$i])
    Next
    Log_Level_Remove()

    CaptureRegion()
    ScriptTest_CreateGui(_ArrayToString($aTempLog, @CRLF) & $sError, $g_hBitmap)
    Return "COMPLETE"
EndFunc

Func ScriptTest_Handles()
    Log_Level_Add("Checking Handles")
    Log_Add("Window Title: " & $Config_Emulator_Title, $LOG_DEBUG)
    Log_Add("Window Handle: " & $g_hWindow, $LOG_DEBUG)
    Log_Add("Control Properties: " & $Config_Emulator_Property, $LOG_DEBUG)
    Log_Add("Control Handle: " & $g_hControl, $LOG_DEBUG)
    Log_Level_Remove()
EndFunc

Func ResetHandles()
    Log_Level_Add("ResetHandles()")
    Local $aHandles = WinList($Config_Emulator_Title)
    If $aHandles[0][0] = 0 Then
        $g_hWindow = 0
        $g_hControl = 0
    EndIf

    For $i = 1 To $aHandles[0][0]
        If $Config_Emulator_Title <> $aHandles[$i][0] Then ContinueLoop
        $g_hWindow = $aHandles[$i][1]
        If $Config_Emulator_Property == "~AUTO" Then
            ;Auto retrieve control handle
            $g_hControl = RetrieveControlHandle($g_hWindow)
        Else
            $g_hControl = ControlGetHandle($g_hWindow, "", $Config_Emulator_Property)
        EndIf

        If $g_hControl <> 0 Then ExitLoop
    Next

    If $g_hControl <> 0 And $Config_Emulator_Path = "~AUTO" Then 
        $Config_Emulator_Path = GetWorkingDirectory(_WinAPI_GetProcessFileName(WinGetProcess($g_hWindow)))
    EndIf

    Log_Level_Remove()

    If $g_hWindow == "" Then $g_hWindow = 0
    If $g_hControl == "" Then $g_hControl = 0
    Return ($g_hControl <> 0)
EndFunc

; Returns array of potential candidates for emulator titles.
Func FindEmulatorCandidates()
    Local $aCandidates[0]
    Local $aWinList = WinList()
    If isArray($aWinList) = False Then Return SetError(1, 0, $aCandidates)

    For $i = 1 To $aWinList[0][0]
        If $aWinList[$i][0] == "" Then ContinueLoop

        Local $iPotentialHandle = RetrieveControlHandle($aWinList[$i][1])
        If $iPotentialHandle <> 0 Then
            _ArrayAdd($aCandidates, $aWinList[$i][0])
        EndIf
    Next

    Return $aCandidates
EndFunc

Func RetrieveControlHandle($hWindow) ;Retrieves based on Emulator size
    Local $hChild = _WinAPI_GetWindow($hWindow, $GW_CHILD)
    If @error Or $hChild = 0 Then Return 0
    Return _RetrieveControlHandle($hChild)
EndFunc
Func _RetrieveControlHandle($hCurrent, $hParent = CreateArr()) ;Visits each child window within main handle. Tree can be found using Spy++ tool in Visual Studio
    ;MsgBox(0, "", $hCurrent)
    
    Local $aPos = WinGetPos($hCurrent)
    If (((isArray($aPos) > 0) And ($aPos[2] = $EMULATOR_WIDTH And $aPos[3] = $EMULATOR_HEIGHT)) And (BitAND(WinGetState($hCurrent), 2))) Or $hCurrent = 0 Then Return $hCurrent

    Local $hChild = _WinAPI_GetWindow($hCurrent, $GW_CHILD)
    If $hChild <> 0 Then 
        _ArrayAdd($hParent, $hCurrent)
        Return _RetrieveControlHandle($hChild, $hParent)
    EndIf

    Local $hNext = _WinAPI_GetWindow($hCurrent, $GW_HWNDNEXT)
    If $hNext <> 0 Then Return _RetrieveControlHandle($hNext, $hParent)

    Local $hBack = 0
    If UBound($hParent) > 0 Then
        $hBack = $hParent[UBound($hParent)-1]
    If _ArrayDelete($hParent, UBound($hParent)-1) = 0 Then Return 0
    EndIf

    Return _RetrieveControlHandle(_WinAPI_GetWindow($hBack, $GW_HWNDNEXT), $hParent)
EndFunc

Func SwitchScript($sScript)
    Local $iIndex = _GUICtrlComboBox_FindStringExact($g_hCmb_Scripts, $sScript)
    If $iIndex <> -1 Then
        _GUICtrlComboBox_SetCurSel($g_hCmb_Scripts, $iIndex)
        Script_ChangeConfig()

        If $g_bRunning > 0 Then Stop()
        Schedule_Add("Start " & $sScript & ".", __ArrayFromString("\1Start()"), $SCHEDULE_TYPE_CONDITION, 1, __ArrayFromString("\2$g_bRunning = False\1True"), 0, 0)
    EndIf
EndFunc

Func EditScript($sName, $sConfig, $sValue)
    Local $iFound = -1
    For $i = 0 To UBound($g_aScripts)-1
        If StringReplace(($g_aScripts[$i])[0], "_", " ") == $sName Then
            $iFound = $i
            ExitLoop
        EndIf
    Next

    If $iFound = -1 Then
        MsgBox($MB_ICONERROR, "EditScript Error", "Script does not exist.", 10)
    Else
        Local $iFoundConfig = -1
        For $i = 0 To UBound(($g_aScripts[$iFound])[2])-1
            If StringReplace(((($g_aScripts[$iFound])[2])[$i])[0], "_", " ") == $sConfig Then
                $iFoundConfig = $i
                ExitLoop
            EndIf
        Next

        If $iFoundConfig = -1 Then
            MsgBox($MB_ICONERROR, "EditScript Error", "Setting does not exist in " & $sName, 10)
        Else
            Switch ((($g_aScripts[$iFound])[2])[$iFoundConfig])[3]
                Case "combo"
                    Local $aAllowed = StringSplit(((($g_aScripts[$iFound])[2])[$iFoundConfig])[4], ",", $STR_NOCOUNT)
                    Local $bAllow = False
                    For $sAllowed In $aAllowed
                        If $sAllowed == $sValue Then
                            $bAllow = True
                            ExitLoop
                        EndIf   
                    Next

                    If $bAllow = 0 Then
                        MsgBox($MB_ICONERROR, "EditScript Error", "Value not allowed for " & $sName & ", " & ((($g_aScripts[$iFound])[2])[$iFoundConfig])[0], 10)
                    Else
                        Local $aNew = $g_aScripts[$iFound]
                        Local $aLayer = $aNew[2]
                        Local $aLayer2 = $aLayer[$iFoundConfig]

                        $aLayer2[1] = $sValue
                        $aLayer[$iFoundConfig] = $aLayer2
                        $aNew[2] = $aLayer
                        $g_aScripts[$iFound] = $aNew

                        Log_Add($sName & ", " & $sConfig & " has been changed to " & $sValue)
                    EndIf

                Case "text", "list"
                    Local $aNew = $g_aScripts[$iFound]
                    Local $aLayer = $aNew[2]
                    Local $aLayer2 = $aLayer[$iFoundConfig]

                    $aLayer2[1] = $sValue
                    $aLayer[$iFoundConfig] = $aLayer2
                    $aNew[2] = $aLayer
                    $g_aScripts[$iFound] = $aNew

                    Log_Add($sName & ", " & $sConfig & " has been changed to " & $sValue)

                ;Case "list"
                ;    MsgBox($MB_ICONWARNING, "EditScript Warning", "List cannot be edited yet.")
            EndSwitch
            _GUICtrlComboBox_SetCurSel($g_hCmb_Scripts, _GUICtrlComboBox_FindStringExact($g_hCmb_Scripts, $sName))

            Script_ChangeConfig()
            Config_Save()
        EndIf
    EndIf
EndFunc