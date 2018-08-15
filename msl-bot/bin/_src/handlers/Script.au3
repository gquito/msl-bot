Func Start()
    Log_Level_Add("PREPROCESS")
    Log_Add("Initializing scripts and checking preconditions.", $LOG_DEBUG)

;Initializing variables
    Data_Clear()
    Data_Order_Clear()

    $g_hTimeSpent = TimerInit()
    $g_hScriptTimer = TimerInit()
    UpdateSettings()

    ;Pre Conditions
    Local $bOutput = False
    While True
        If $g_hWindow = 0 Or $g_hControl = 0 Then
            If $g_hWindow = 0 Then 
                Log_Add("Window handle not found.", $LOG_ERROR)
                MsgBox($MB_ICONERROR+$MB_OK, "Window handle not found.", "Window handle (" & $g_sWindowTitle & ") : " & $g_hWindow & @CRLF & @CRLF & "Control handle (" & $g_sControlInstance & ") : " & $g_hControl & @CRLF & @CRLF & "Tip: Set the Emulator Title, Emulator Class, and Emulator Instance correctly.")
                ExitLoop
            EndIf

            If $g_hControl = 0 Then
                Local $iPID = WinGetProcess($g_hWindow)
                Local $sPath = _WinAPI_GetProcessFileName($iPID)
                        
                If StringInStr($sPath, "Nox") = True Then
                    Log_Add("Control Handle not found.", $LOG_ERROR)
                    Log_Add("Attempting to use default for Nox.")
                    
                    $g_sControlInstance = "[CLASS:subWin; INSTANCE:1]"
                    $g_hControl = ControlGetHandle($g_hWindow, "", $g_sControlInstance) 

                    If $g_hControl = 0 Then 
                        $g_sControlInstance = "[CLASS:AnglePlayer_0; INSTANCE:1]"
                        $g_hControl = ControlGetHandle($g_hWindow, "", $g_sControlInstance)
                    EndIf

                    If $g_hControl = 0 Then 
                        MsgBox($MB_ICONERROR+$MB_OK, "Control handle not found.", "Window handle (" & $g_sWindowTitle & ") : " & $g_hWindow & @CRLF & @CRLF & "Control handle (" & $g_sControlInstance & ") : " & $g_hControl & @CRLF & @CRLF & "Tip: Set the Emulator Title, Emulator Class, and Emulator Instance correctly.")
                        ExitLoop
                    EndIf
                EndIf

            EndIf
        EndIf

        If ($g_iBackgroundMode = $BKGD_ADB) Or ($g_iMouseMode = $MOUSE_ADB) Or ($g_iSwipeMode = $SWIPE_ADB) Then
            If FileExists($g_sAdbPath) = False Then
                MsgBox($MB_ICONERROR+$MB_OK, "Nox path does not exist.", "Path to adb.exe does not exist: " & $g_sAdbPath)
                ExitLoop
            EndIf

            If StringInStr(adbCommand("get-state"), "error") = True Then
                Log_Add("Attempting to connect to ADB Device: " & $g_sAdbDevice)
                adbCommand("connect " & $g_sAdbDevice)

                If StringInStr(adbCommand("get-state"), "error") = True Then 
                    MsgBox($MB_ICONERROR+$MB_OK, "Adb device does not exist.", "Device is not connected or does not exist: " & $g_sAdbDevice & @CRLF & @CRLF & adbCommand("devices"))
                    Log_Add("Failed to connect to device: " & $g_sAdbDevice, $LOG_ERROR)
                    ExitLoop
                Else
                    Log_Add("Successfully connected to device: " & $g_sAdbDevice)
                EndIf
            EndIf

            isAdbWorking()
        EndIf

        If ($g_iMouseMode = $MOUSE_REAL) Or ($g_iSwipeMode = $SWIPE_REAL) Then
            MsgBox($MB_ICONWARNING+$MB_OK, "Script is using real mouse.", "Mouse cursor will be moved automatically. To stop the script, press ESCAPE key.")
            HotKeySet("{ESC}", "Stop")
        EndIf

    ;Processing
        If $g_sScript = "" Then
            _GUICtrlComboBox_GetLBText($hCmb_Scripts, _GUICtrlComboBox_GetCurSel($hCmb_Scripts), $g_sScript)

            Local $t_aScriptArgs[_GUICtrlListView_GetItemCount($hLV_ScriptConfig)+1] ;Contains script args
            $t_aScriptArgs[0] = "CallArgArray"
            For $i = 1 To UBound($t_aScriptArgs, $UBOUND_ROWS)-1
                ;Retrieves the values column for each setting
                $t_aScriptArgs[$i] = _GUICtrlListView_GetItemText($hLV_ScriptConfig, $i-1, 1) 
            Next

            $g_aScriptArgs = $t_aScriptArgs
        EndIf
    
        $bOutput = True
        ExitLoop
    WEnd
    
    If $bOutput = False Then
        Log_Level_Remove()
        Return $bOutput
    EndIf

    While True
        ;Changing bot state and checking pixels
        $g_bRunning = True
        CaptureRegion()
        If isPixel("100,457,0x1FA9CE|200,457,0x24ABBD|300,457,0x29AEA8|400,457,0x2FB091", 10) = False Then
            For $i = 0 To $g_aControlSize[0] Step 100
                Local $hColor = getColor($i, $g_aControlSize[1]/2)
                If ($hColor <> "0x000000") Or ($hColor <> "0xFFFFFF") Then 
                ;Pass all conditions -> Setting control states
                    Local $sUser = "[" & getArg(formatArgs(getScriptData($g_aScripts, "_Config")[2]), "Profile_Name") & "] "
                    GUICtrlSetData($idLbl_RunningScript, "Running Script: " & $sUser & $g_sScript)
                    ControlDisable("", "", $hCmb_Scripts)
                    ControlDisable("", "", $hLV_ScriptConfig)
                    ControlDisable("", "", $hBtn_Start)
                    ControlDisable("", "", $hBtn_StatReset)
                    ControlEnable("", "", $hBtn_Stop)
                    ControlEnable("", "", $hBtn_Pause)

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

    Log_Add("Start result: " & $bOutput & ".", $LOG_DEBUG)
    Log_Level_Remove()
    If $bOutput = True Then _GUICtrlTab_ClickTab($hTb_Main, 1)
    Return $bOutput
EndFunc

Func Stop()
    HotKeySet("{Esc}") ;unbinds hotkey

;Save stats
    _Stat_Calculated($g_aStats)
    Stat_Save($g_aStats)
    $g_hTimeSpent = Null

;Resets variables
    If FileExists($g_sEmuSharedFolder[1] & "\" & $g_sWindowTitle & ".png") Then FileDelete($g_sEmuSharedFolder[1] & "\" & $g_sWindowTitle & ".png")
    $g_hTimerLocation = Null
    $g_hScriptTimer = Null
    $g_aScriptArgs = Null
    $g_sScript = ""

;Setting control states
    GUICtrlSetData($idLbl_RunningScript, "Running Script: ")
    ControlEnable("", "", $hCmb_Scripts)
    ControlEnable("", "", $hLV_ScriptConfig)
    ControlEnable("", "", $hBtn_Start)
    ControlEnable("", "", $hBtn_StatReset)
    ControlDisable("", "", $hBtn_Stop)
    ControlDisable("", "", $hBtn_Pause)

;Calls to stop scripts
    $g_bRunning = False
    WinSetTitle($hParent, "", $g_sAppTitle & UpdateStatus())
EndFunc

Func Pause()
    $g_bPaused = Not($g_bPaused)

    If $g_bPaused = True Then
        ;From not being paused to being paused
        _GUICtrlButton_SetText($hBtn_Pause, "Unpause")
        ControlDisable("", "", $hBtn_Stop)
    Else
        ;From being paused to being unpaused
        _GUICtrlButton_SetText($hBtn_Pause, "Pause")
        ControlEnable("", "", $hBtn_Stop)
    EndIf
EndFunc

Func CloseApp()
    Log_Save($g_aLog)
    FileDelete($g_sEmuSharedFolder[1] & "\" & $g_sWindowTitle & ".png")
    _GDIPlus_Shutdown()
    Exit
EndFunc


;Includes tests to see if all features are working properly.
Func ScriptTest()
    Log_Level_Add("SCRIPT_TEST")
    Local $aTempLOG[0]
    _ArrayAdd($aTempLOG, "== Starting Compatibility Test ==")
    
    Local $sError = "" ;Will store error information.

    ;Pre test
    If MsgBox($MB_ICONINFORMATION+$MB_OKCANCEL, "MSL Bot Compatibility Test", "Navigate to the MAP in the game and press OKAY to begin the test.") = $IDCANCEL Then
        _ArrayAdd($aTempLOG, "== Finished Compatibility Test ==")

        For $i = UBound($aTempLOG)-1 To 0 Step -1
            Log_Add($aTempLOG[$i])
        Next
        Log_Level_Remove()
        
        Return "CANCELED"
    EndIf

    ;Test window and control handle.
    resetHandles()
    _ArrayAdd($aTempLOG, "Checking handles:")
    _ArrayAdd($aTempLOG, "  -Window handle: " & $g_hWindow)
    _ArrayAdd($aTempLOG, "  -Control handle: " & $g_hControl)

    If $g_hWindow = 0 Then $sError &= @CRLF & @CRLF & "- Window handle was not found. Make sure the enter the correct Emulator Title in _Config."
    If $g_hWindow <> 0 And $g_hControl = 0 Then $sError &= @CRLF & @CRLF & "- Control handle was not found. Make sure to enter the correct Emulator Class and Emulator Instance in _Config."

    ;Test Capture and Clicks
    Local $bCaptureWorking = False
    _ArrayAdd($aTempLOG, "Checking capture and click:")
    If $g_hControl <> 0 Then
        CaptureRegion()

        Local $cFirst = getColor(0, 0)
        Local $cSecond = "0x000000"

        _ArrayAdd($aTempLOG, "  -Current location: " & getLocation($g_aLocations, False))
        If String($cFirst) = "0x000000" Or String($cFirst) = "0xFFFFFF" Or Not(getLocation($g_aLocations, False)="map") Then
            $sError &= @CRLF & @CRLF & "- Could not capture the emulator correctly. Make sure you are in MAP. If you are in the map, make sure the resolution of the emulator is 800x552 and is not maximized. " & _
                "You can use the function `RestartNox()` in the debug input (CTRL+D) to automatically set the resolution (this automatic method could fail). Change the GRAPHICS RENDERING MODE in the emulator settings or change the CAPTURE METHOD in _Config."
            $sError &= @CRLF & @CRLF & "- Could not test click status because capture is not working."

            _ArrayAdd($aTempLOG, "  -Click working status: Unknown")
        Else
            $bCaptureWorking = True
            clickUntil("414,16", "isLocation", "refill", 3, 200) ; Opens refill window

            $cSecond = getColor(0, 0)
            If $cFirst = $cSecond Then 
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
    Local $bAdbWorking = isAdbWorking()
    LocaL $sAdbEvent = getEvent()
    _ArrayAdd($aTempLOG, "  -ADB working status: " & $bAdbWorking)
    _ArrayAdd($aTempLOG, "  -ADB event device: " & $sAdbEvent)

    If $bAdbWorking = False Then $sError &= @CRLF & @CRLF & "- ADB is not working. Make sure the ADB Path and ADB Device is correct. " & _
        "ADB Path is the path to the adb executable which can be found in the Nox directory. Enter the complete path which includes '...adb.exe' at the end." & _
        ' ADB Device can be found by typing `MsgBox(0, "", adbCommand("devices"))` which will give you a list of available devices. Multiple emulators will need to guess which device goes with an emulator.'
    If $sAdbEvent = False Then $sError &= @CRLF & @CRLF & "- Could not find ADB device event. This will prevent you from using the 'sendevent' method setting in _Config. Make sure to use 'input event' instead."
    
    If $bAdbWorking = True And $bCaptureWorking = True Then
        If getLocation() = "map" Then
            _ArrayAdd($aTempLOG, "  -ADB response status: " & clickUntil("414,16", "isLocation", "refill", 3, 200, Null, $MOUSE_ADB)) ; Opens refill window using ADB
            If getLocation($g_aLocations, False) <> "refill" Then
                $sError &= @CRLF & @CRLF & '- Emulator is not responding to the ADB command. The ADB DEVICE in _Config might not be correct. Enter `MsgBox(0, "", adbCommand("devices"))` in the debug input (Ctrl+D) to get the devices list.'
            EndIf
        Else
            adbSendESC()
            If getLocation() <> "map" Then
                _ArrayAdd($aTempLOG, "  -ADB response status: False")
                $sError &= @CRLF & @CRLF & '- Emulator is not responding to the ADB command. The ADB DEVICE in _Config might not be correct. Enter `MsgBox(0, "", adbCommand("devices"))` in the debug input (Ctrl+D) to get the devices list.'
            Else
                _ArrayAdd($aTempLOG, "  -ADB response status: True")
            EndIf
        EndIf
    Else
        _ArrayAdd($aTempLOG, "  -ADB response status: Unknown")
        $sError &= @CRLF & @CRLF & "- Could not test ADB response because ADB or Capture is not working."
    EndIf
    
    ;Check Resolution
    If $bAdbWorking = True Then
        _ArrayAdd($aTempLOG, "Checking resolution: ")
        Local $sAdbResponse = StringStripWS(StringMid(adbCommand("shell wm size"),15),$STR_STRIPALL)
        _ArrayAdd($aTempLOG, "  -Android Resolution: " & $sAdbResponse)
        If ($sAdbResponse <> "800x552") Then
            $sError &= @CRLF & "- Emulator resolution is not 800x552."
        EndIf
        $sAdbResponse = StringStripWS(StringMid(adbCommand("shell wm density"),18),$STR_STRIPALL)
        _ArrayAdd($aTempLOG, "  -Android Dpi: " & $sAdbResponse)
        If ($sAdbResponse <> "160") Then
            $sError &= @CRLF & "- Emulator dpi is not 160."
        EndIf
    EndIf

    ;Imagesearch test
    _ArrayAdd($aTempLOG, "Checking Imagesearch:")
    Local $t_hBitmap = _GDIPlus_BitmapCreateFromFile(@ScriptDir & "\bin\images\misc\misc-test1.bmp")
    If $t_hBitmap <> 0 Then
        Local $t_hHBitmap = _GDIPlus_BitmapCreateHBITMAPFromBitmap($t_hBitmap)
        $g_hHBitmap = $t_hHBitmap
        If isArray(findImage("misc-test2", 90, 0, 0, 0, 597, 348, False)) = True Then
            _ArrayAdd($aTempLOG, "  -Imagesearch working status: True")
        Else
            _ArrayAdd($aTempLOG, "  -Imagesearch working status: False")
            $sError &= @CRLF & @CRLF & "- Imagesearch did not work. Make sure to have the file `\bin\dll\ImageSearchLibrary.dll`. Also make sure you are running the bot as x86 instead of x64."
        EndIf
    Else
        _ArrayAdd($aTempLOG, "  -Imagesearch working status: Unknown")
        $sError &= @CRLF & @CRLF & "- The file \bin\images\misc\misc-test1.bmp or \bin\images\misc\misc-test2.bmp is missing. Could not check imagesearch status."
    EndIf
    _GDIPlus_BitmapDispose ($t_hBitmap)
    _WinAPI_DeleteObject($t_hHBitmap)

    _ArrayAdd($aTempLOG, "== Finished Compatibility Test ==")

    Local $idResult = MsgBox($MB_ICONINFORMATION+$MB_YESNO, "MSL Compatibility Test", _ArrayToString($aTempLOG, @CRLF) & $sError & @CRLF & @CRLF & "Would you like to copy this information?")
    If $idResult = $IDYES Then 
        ClipPut(_ArrayToString($aTempLOG, @CRLF) & $sError)
        MsgBox($MB_ICONINFORMATION, "MSL Compatibility Test", "Information has been copied to your clipboard.")
    EndIf

    For $i = UBound($aTempLOG)-1 To 0 Step -1
        Log_Add($aTempLOG[$i])
    Next
    Log_Level_Remove()

    Return "COMPLETE"
EndFunc