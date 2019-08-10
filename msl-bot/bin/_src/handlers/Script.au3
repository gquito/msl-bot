#include-once
#include "../imports.au3"

Func Start()
    Log_Level_Add("PREPROCESS")
    Log_Add("Initializing scripts and checking preconditions.", $LOG_DEBUG)

;Initializing variables
    $g_bRunning = True

    Data_Clear()
    Data_Order_Clear()

    $g_hTimeSpent = TimerInit()
    $g_hScriptTimer = TimerInit()
    UpdateSettings()
    $g_bDisableAntiStuck = False

    ;Pre Conditions
    Local $bOutput = False
    While True
        If ($g_hWindow = 0 Or $g_hControl = 0) Then
            If ($g_hWindow = 0) Then 
                Log_Add("Window handle not found.", $LOG_ERROR)
                MsgBox($MB_ICONERROR+$MB_OK, "Window handle not found.", "Window handle (" & $g_sWindowTitle & ") : " & $g_hWindow & @CRLF & @CRLF & "Control handle (" & $g_sControlInstance & ") : " & $g_hControl & @CRLF & @CRLF & "Tip: Set the Emulator Title, Emulator Class, and Emulator Instance correctly.")
                ExitLoop
            EndIf

            If ($g_hControl = 0) Then
                Local $iPID = WinGetProcess($g_hWindow)
                Local $sPath = _WinAPI_GetProcessFileName($iPID)
                        
                If (StringInStr($sPath, "Nox")) Then
                    Log_Add("Control Handle not found.", $LOG_ERROR)
                    Log_Add("Attempting to use default for Nox.")
                    
                    $g_sControlInstance = $d_sControlInstance
                    $g_hControl = ControlGetHandle($g_hWindow, "", $g_sControlInstance) 

                    ;If $g_hControl = 0 Then 
                    ;    $g_sControlInstance = "[CLASS:AnglePlayer_0; INSTANCE:1]"
                    ;    $g_hControl = ControlGetHandle($g_hWindow, "", $g_sControlInstance)
                    ;EndIf

                    If ($g_hControl = 0) Then 
                        MsgBox($MB_ICONERROR+$MB_OK, "Control handle not found.", "Window handle (" & $g_sWindowTitle & ") : " & $g_hWindow & @CRLF & @CRLF & "Control handle (" & $g_sControlInstance & ") : " & $g_hControl & @CRLF & @CRLF & "Tip: Set the Emulator Title, Emulator Class, and Emulator Instance correctly.")
                        ExitLoop
                    EndIf
                EndIf

            EndIf
        EndIf

        ;Establish ADB controls
        If (Not(_Establish_ADB())) Then ExitLoop

        If ($g_iMouseMode = $MOUSE_REAL Or $g_iSwipeMode = $SWIPE_REAL) Then
            MsgBox($MB_ICONWARNING+$MB_OK, "Script is using real mouse.", "Mouse cursor will be moved automatically. To stop the script, press ESCAPE key.")
            HotKeySet("{ESC}", "Stop")
        EndIf

    ;Processing
        If ($g_sScript = "") Then
            _GUICtrlComboBox_GetLBText($g_hCmb_Scripts, _GUICtrlComboBox_GetCurSel($g_hCmb_Scripts), $g_sScript)

            Local $t_aScriptArgs[_GUICtrlListView_GetItemCount($g_hLV_ScriptConfig)+1] ;Contains script args
            $t_aScriptArgs[0] = "CallArgArray"
            For $i = 1 To UBound($t_aScriptArgs, $UBOUND_ROWS)-1
                ;Retrieves the values column for each setting
                $t_aScriptArgs[$i] = _GUICtrlListView_GetItemText($g_hLV_ScriptConfig, $i-1, 1) 
            Next

            $g_aScriptArgs = $t_aScriptArgs
        EndIf
    
        $bOutput = True
        ExitLoop
    WEnd
    
    If (Not($bOutput)) Then
        Log_Level_Remove()
        Return $bOutput
    EndIf

    While True
        ;Changing bot state and checking pixels
        $g_bRunning = True
        CaptureRegion()
        If (Not(isPixel("100,457,0x1FA9CE|200,457,0x24ABBD|300,457,0x29AEA8|400,457,0x2FB091", 10))) Then
            For $i = 0 To $NOX_WIDTH Step 100
                Local $hColor = getColor($i, $NOX_HEIGHT/2)
                If ($hColor <> "0x000000" Or $hColor <> "0xFFFFFF") Then 
                ;Pass all conditions -> Setting control states
                    Local $sUser = "[" & getArg($g_aConfigSettings, "Profile_Name") & "] "
                    GUICtrlSetData($g_idLbl_RunningScript, "Running Script: " & $sUser & $g_sScript)
                    ControlDisable("", "", $g_hCmb_Scripts)
                    ControlDisable("", "", $g_hLV_ScriptConfig)
                    ControlDisable("", "", $g_hBtn_Start)
                    ControlDisable("", "", $g_hBtn_StatReset)
                    ControlEnable("", "", $g_hBtn_Stop)
                    ControlEnable("", "", $g_hBtn_Pause)

                    ExitLoop(2)
                EndIf
            Next
        EndIf

        ;Screen is black:
        MsgBox($MB_ICONERROR+$MB_OK, "Could not capture correctly.", "Unable to correctly capture screen. Try changing 'Capture Mode' or Nox 'Graphics Rendering Mode.'")
        Stop()

        $bOutput = False
        ExitLoop
    WEnd

    ;Write for error handler
    ConsoleWrite(@CRLF & "~> Info stop" & @CRLF)

    ConsoleWrite("Swipe Mode: " & getArg($g_aConfigsettings, "Swipe_Mode") & @CRLF)
    ConsoleWrite("Mouse Mode: " & getArg($g_aConfigsettings, "Mouse_Mode") & @CRLF)
    ConsoleWrite("Capture Mode: " & getArg($g_aConfigsettings, "Capture_Mode") & @CRLF)
    ConsoleWrite("Display Scaling: " & getArg($g_aConfigsettings, "Display_Scaling") & @CRLF)
    ConsoleWrite("ADB Method: " & getArg($g_aConfigsettings, "ADB_Method") & @CRLF)
    ConsoleWrite("Emulator Instance: " & getArg($g_aConfigsettings, "Emulator_Instance") & @CRLF)
    ConsoleWrite("Emulator Class: " & getArg($g_aConfigsettings, "Emulator_Class") & @CRLF)
    ConsoleWrite(@CRLF & "Current Script: " & $g_sScript & @CRLF)

    Log_Add("Start result: " & $bOutput & ".", $LOG_DEBUG)
    Log_Level_Remove()
    If ($bOutput) Then _GUICtrlTab_ClickTab($g_hTb_Main, 1)
    Return $bOutput
EndFunc

Func Stop()
    ConsoleWrite("~> Script stopped" & @CRLF)
    HotKeySet("{Esc}") ;unbinds hotkey

;Save stats
    _Stat_Calculated($g_aStats)
    Stat_Save($g_aStats)
    $g_hTimeSpent = Null

;Resets variables
    If (FileExists($g_sEmuSharedFolder[1] & "\" & $g_sWindowTitle & ".png")) Then FileDelete($g_sEmuSharedFolder[1] & "\" & $g_sWindowTitle & ".png")
    $g_hTimerLocation = Null
    $g_hScriptTimer = Null
    $g_aScriptArgs = Null
    $g_sScript = ""
    $g_bDisableAntiStuck = False

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
    FileDelete($g_sEmuSharedFolder[1] & "\" & $g_sWindowTitle & ".png")
    _GDIPlus_Shutdown()
    Exit
EndFunc

Func _Establish_ADB($iADB_GetEvent_TIMEOUT = 0)
    $bOutput = False
    While True
        If (Not(FileExists($g_sADBPath))) Then
            MsgBox($MB_ICONERROR+$MB_OK, "Nox path does not exist.", "Path to adb.exe does not exist: " & $g_sADBPath)
            ExitLoop
        EndIf

        ;Add ADB absolute path.
        If (Not(StringInStr($g_sADBPath, "adb.exe"))) Then 
            If (StringRight($g_sADBPath, 1) = "\") Then
                $g_sADBPath &= "adb.exe"
            Else
                $g_sADBPath &= "\adb.exe"
            EndIf
        EndIf

        If (StringInStr(ADB_Command("get-state"), "error")) Then
            Log_Add("Attempting to connect to ADB Device: " & $g_sADBDevice)
            ADB_Command("connect " & $g_sADBDevice, 0, 60000)

            If (StringInStr(ADB_Command("get-state"), "error")) Then 
                ;MsgBox($MB_ICONERROR+$MB_OK, "ADB device does not exist.", "Device is not connected or does not exist: " & $g_sADBDevice & @CRLF & @CRLF & ADB_Command("devices"))
                Log_Add("Failed to connect to device: " & $g_sADBDevice, $LOG_ERROR)

                $g_bADBWorking = False
                ExitLoop
            Else
                Log_Add("Successfully connected to device: " & $g_sADBDevice)
            EndIf
        EndIf

        $g_bADBWorking = True
        $g_sADBEvent = ADB_GetEvent($iADB_GetEvent_TIMEOUT)

        $bOutput = True
        ExitLoop
    WEnd

    Return $bOutput
EndFunc

;Includes tests to see if all features are working properly.
Func ScriptTest()
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
    _ArrayAdd($aTempLOG, "  -Emulator Class: " & getArg($g_aConfigsettings, "Emulator_Class"))
    _ArrayAdd($aTempLOG, "  -Emulator Instance: " & getArg($g_aConfigsettings, "Emulator_Instance"))
    Local $sAdbMethod = getArg($g_aConfigsettings, "ADB_Method")
    _ArrayAdd($aTempLOG, "  -ADB Method: " & $sAdbMethod)
    _ArrayAdd($aTempLOG, "  -Display Scaling: " & getArg($g_aConfigsettings, "Display_Scaling"))
    _ArrayAdd($aTempLOG, "  -Capture Mode: " & getArg($g_aConfigsettings, "Capture_Mode"))
    _ArrayAdd($aTempLOG, "  -Mouse Mode: " & getArg($g_aConfigsettings, "Mouse_Mode"))
    _ArrayAdd($aTempLOG, "  -Swipe Mode: " & getArg($g_aConfigsettings, "Swipe_Mode"))

    ;Test window and control handle.
    ScriptTest_Handles()
    _ArrayAdd($aTempLOG, "Checking handles:")
    _ArrayAdd($aTempLOG, "  -Window handle: " & $g_hWindow)
    _ArrayAdd($aTempLOG, "  -Control handle: " & $g_hControl)
    _ArrayAdd($aTempLOG, "  -Toolbox handle: " & $g_hToolbox)

    If ($g_hWindow = 0) Then $sError &= @CRLF & @CRLF & "- Window handle was not found. Make sure the enter the correct Emulator Title in _Config."
    If ($g_hWindow <> 0 And $g_hControl = 0) Then $sError &= @CRLF & @CRLF & "- Control handle was not found. Make sure to enter the correct Emulator Class and Emulator Instance in _Config."

    ;Test Capture and Clicks
    Local $bCaptureWorking = False
    _ArrayAdd($aTempLOG, "Checking capture and click:")
    If ($g_hControl <> 0) Then
        CaptureRegion()

        Local $cFirst = getColor(0, 0)

        _ArrayAdd($aTempLOG, "  -Current location: " & getLocation())
        If (String($cFirst) = "0x000000" Or String($cFirst) = "0xFFFFFF" Or Not(isLocation("map"))) Then
            $sError &= @CRLF & @CRLF & "- Could not capture the emulator correctly. Make sure you are in MAP. If you are in the map, make sure the resolution of the emulator is 800x552 and is not maximized. " & _
                "You can use the function `RestartNox()` in the debug input (CTRL+D) to automatically set the resolution (this automatic method could fail). Change the GRAPHICS RENDERING MODE in the emulator settings or change the CAPTURE METHOD in _Config."
            $sError &= @CRLF & @CRLF & "- Could not test click status because capture is not working."

            _ArrayAdd($aTempLOG, "  -Click working status: Unknown")
        Else
            $bCaptureWorking = True

            ;Opens refill window
            If clickWhile("414,16", "isPixel", CreateArr(0, 0, $cFirst), 5, 2000, "CaptureRegion()") = False Then 
                $sError &= @CRLF & @CRLF & "- Click is not working. Make sure you have the correct DISPLAY SCALING. You can check by right clicking in your desktop and clicking Display Settings. You will see" & _
                    " the scaling. Set the setting DISPLAY SCALING in _Config as the same as the scaling in your display setting. You can also change the click method in _Config."
            
                _ArrayAdd($aTempLog, "  -Click working status: False")
            Else
                _ArrayAdd($aTempLog, "  -Click working status: True")
            EndIf
        EndIf
        _ArrayAdd($aTempLog, "  -Capture working status: " & $bCaptureWorking)
    Else
        $sError &= @CRLF & @CRLF & "- Could not test capture and click because window/control handles was not found."
        _ArrayAdd($aTempLOG, "  -Capture working status: Unknown")
        _ArrayAdd($aTempLOG, "  -Click working status: Unknown")
    EndIf
    
    ;Test ADB functions.
    _ArrayAdd($aTempLOG, "Checking ADB:")
    Local $bAdbWorking = ADB_IsWorking()
    LocaL $sAdbEvent = ADB_GetEvent()
    _ArrayAdd($aTempLOG, "  -ADB working status: " & $bAdbWorking)
    If ($sAdbMethod = "sendevent") Then _ArrayAdd($aTempLOG, "  -ADB event device: " & $sAdbEvent)

    If (Not($bAdbWorking)) Then $sError &= @CRLF & @CRLF & "- ADB is not working. Make sure the ADB Path and ADB Device is correct. " & _
        "ADB Path is the path to the adb executable which can be found in the Nox directory. Enter the complete path which includes '...adb.exe' at the end." & _
        ' ADB Device can be found by typing `MsgBox(0, "", ADB_Command("devices"))` which will give you a list of available devices. Multiple emulators will need to guess which device goes with an emulator.'
    If ($sAdbMethod = "sendevent" And Not($sAdbEvent)) Then $sError &= @CRLF & @CRLF & "- Could not find ADB device event. This will prevent you from using the 'sendevent' method setting in _Config. Make sure to use 'input event' instead."
    
    If ($bAdbWorking And $bCaptureWorking) Then
        If (isLocation("map")) Then
            Local $bAdbResponse = clickWhile("414,16", "isPixel", CreateArr(0, 0, getColor(0, 0)), 5, 2000, "CaptureRegion()", $MOUSE_ADB)
            _ArrayAdd($aTempLOG, "  -ADB response status: " & $bAdbResponse) ; Opens refill window using ADB
            If $bAdbResponse = False Then $sError &= @CRLF & @CRLF & '- Emulator is not responding to the ADB command. The ADB DEVICE in _Config might not be correct. Enter `MsgBox(0, "", ADB_Command("devices"))` in the debug input (Ctrl+D) to get the devices list.'
        Else
            SendBack(1, 0, $BACK_ADB)
            If waitLocation("map", 5) = False Then
                _ArrayAdd($aTempLOG, "  -ADB response status: False")
                $sError &= @CRLF & @CRLF & '- Emulator is not responding to the ADB command. The ADB DEVICE in _Config might not be correct. Enter `MsgBox(0, "", ADB_Command("devices"))` in the debug input (Ctrl+D) to get the devices list.'
            Else
                _ArrayAdd($aTempLOG, "  -ADB response status: True")
            EndIf
        EndIf
    Else
        _ArrayAdd($aTempLOG, "  -ADB response status: Unknown")
        $sError &= @CRLF & @CRLF & "- Could not test ADB response because ADB or Capture is not working."
    EndIf
    
    ;Check Resolution
    If ($bAdbWorking) Then
        _ArrayAdd($aTempLOG, "Checking resolution: ")
        
        Local $sAdbResponse = StringStripWS(StringMid(ADB_Command("shell wm size"),15),$STR_STRIPALL)
        _ArrayAdd($aTempLOG, "  -Android Resolution: " & $sAdbResponse)
        If ($sAdbResponse <> "800x552") Then $sError &= @CRLF & "- Emulator resolution is not 800x552."

        $sAdbResponse = StringStripWS(StringMid(ADB_Command("shell wm density"),18),$STR_STRIPALL)
        _ArrayAdd($aTempLOG, "  -Android Dpi: " & $sAdbResponse)
        If ($sAdbResponse <> "160") Then $sError &= @CRLF & "- Emulator dpi is not 160."

        Local $screenScaling = getScreenScaling()
        if (IsArray($screenScaling) And Ubound($screenScaling) > 0) Then
            For $i = 0 To Ubound($screenScaling)-1
                If ($g_iCurrentMonitor = $i + 1) Then
                    _ArrayAdd($aTempLOG, "  -Monitor #" & $i+1 & " (Current) Scaling: " & $screenScaling[$i])
                    If ($screenScaling[$i] <> $g_iDisplayScaling) Then $sError &= @CRLF & "- Screen scaling does not match. Monitor Scaling: " & $screenScaling[$i] & ", Display Scaling Setting: " & $g_iDisplayScaling
                Else
                    _ArrayAdd($aTempLOG, "  -Monitor #" & $i+1 & " Scaling: " & $screenScaling[$i])
                EndIf
            Next
        EndIf
    EndIf
    
    ;Imagesearch test
    _ArrayAdd($aTempLOG, "Checking Imagesearch:")
    Local $t_hBitmap = _GDIPlus_BitmapCreateFromFile(@ScriptDir & "\bin\images\misc\misc-test1.bmp")
    If ($t_hBitmap <> 0) Then
        Local $t_hHBitmap = _GDIPlus_BitmapCreateHBITMAPFromBitmap($t_hBitmap)
        $g_hHBitmap = $t_hHBitmap
        If (isArray(findImage("misc-test2", 90, 0, 0, 0, 597, 348, False))) Then
            _ArrayAdd($aTempLOG, "  -Imagesearch working status: True")
        Else
            _ArrayAdd($aTempLOG, "  -Imagesearch working status: False")
            $sError &= @CRLF & @CRLF & "- Imagesearch did not work. Make sure to have the file `\bin\dll\ImageSearchLibrary.dll`. Also make sure you are running the bot as x86 instead of x64."
        EndIf
    Else
        _ArrayAdd($aTempLOG, "  -Imagesearch working status: Unknown")
        $sError &= @CRLF & @CRLF & "- The file \bin\images\misc\misc-test1.bmp or \bin\images\misc\misc-test2.bmp is missing. Could not check imagesearch status."
    EndIf
    _GDIPlus_BitmapDispose($t_hBitmap)
    _WinAPI_DeleteObject($t_hHBitmap)

    _ArrayAdd($aTempLOG, "== Finished Compatibility Test ==")

    Local $idResult = MsgBox($MB_ICONINFORMATION+$MB_YESNO, "MSL Compatibility Test", _ArrayToString($aTempLOG, @CRLF) & $sError & @CRLF & @CRLF & "Would you like to copy this information?")
    If ($idResult = $IDYES) Then 
        ClipPut(_ArrayToString($aTempLOG, @CRLF) & $sError)
        MsgBox($MB_ICONINFORMATION, "MSL Compatibility Test", "Information has been copied to your clipboard.")
    EndIf

    For $i = UBound($aTempLOG)-1 To 0 Step -1
        Log_Add($aTempLOG[$i])
    Next
    Log_Level_Remove()

    Return "COMPLETE"
EndFunc

Func ScriptTest_Handles()
    Log_Level_Add("Checking Handles")
    resetHandles()
    Log_Add("Window Title: " & $g_sWindowTitle, $LOG_DEBUG)
    Log_Add("Window Handle: " & $g_hWindow, $LOG_DEBUG)
    Log_Add("Control Properties: " & $g_sControlInstance, $LOG_DEBUG)
    Log_Add("Control Handle: " & $g_hControl, $LOG_DEBUG)
    Log_Add("Toolbox Handle: " & $g_hToolbox, $LOG_DEBUG)
    Log_Level_Remove()
EndFunc

Func SwitchScript($sScript)
    Local $iIndex = _GUICtrlComboBox_FindStringExact($g_hCmb_Scripts, $sScript)
    If $iIndex <> -1 Then
        _GUICtrlComboBox_SetCurSel($g_hCmb_Scripts, $iIndex)
        ChangeScript()

        If $g_bRunning = True Then Stop()
        Schedule_Add("Start " & $sScript & ".", __ArrayFromString("\1Start()"), $SCHEDULE_TYPE_CONDITION, 1, __ArrayFromString("\2$g_bRunning = False\1True"), 0, 0)
    EndIf
EndFunc

Func EditScript($sName, $sConfig, $sValue)
    Local $iFound = -1
    For $i = 0 To UBound($g_aScripts)-1
        If StringReplace(($g_aScripts[$i])[0], "_", " ") = $sName Then
            $iFound = $i
            ExitLoop
        EndIf
    Next

    If $iFound = -1 Then
        MsgBox($MB_ICONERROR, "EditScript Error", "Script does not exist.", 10)
    Else
        Local $iFoundConfig = -1
        For $i = 0 To UBound(($g_aScripts[$iFound])[2])-1
            If StringReplace(((($g_aScripts[$iFound])[2])[$i])[0], "_", " ") = $sConfig Then
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
                        If $sAllowed = $sValue Then
                            $bAllow = True
                            ExitLoop
                        EndIf   
                    Next

                    If $bAllow = False Then
                        MsgBox($MB_ICONERROR, "EditScript Error", "Value not allowed for " & $sName & ", " & ((($g_aScripts[$iFound])[2])[$iFoundConfig])[0], 10)
                    Else
                        Local $aNew = $g_aScripts[$iFound]
                        Local $aLayer = $aNew[2]
                        Local $aLayer2 = $aLayer[$iFoundConfig]

                        $aLayer2[1] = $sValue
                        $aLayer[$iFoundConfig] = $aLayer2
                        $aNew[2] = $aLayer
                        $g_aScripts[$iFound] = $aNew

                        Log_Add($sScript & ", " & $sConfig & " has been changed to " & $sValue)
                    EndIf

                Case "text"
                    Local $aNew = $g_aScripts[$iFound]
                    Local $aLayer = $aNew[2]
                    Local $aLayer2 = $aLayer[$iFoundConfig]

                    $aLayer2[1] = $sValue
                    $aLayer[$iFoundConfig] = $aLayer2
                    $aNew[2] = $aLayer
                    $g_aScripts[$iFound] = $aNew

                    Log_Add($sScript & ", " & $sConfig & " has been changed to " & $sValue)

                Case "list"
                    MsgBox($MB_ICONWARNING, "EditScript Warning", "List cannot be edited yet.")
            EndSwitch
            _GUICtrlComboBox_SetCurSel($g_hCmb_Scripts, _GUICtrlComboBox_FindStringExact($g_hCmb_Scripts, $sName))

            ChangeScript()
            _saveSettings()
        EndIf
    EndIf
EndFunc