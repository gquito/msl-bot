#include-once

Func Start()
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

    Config_Update()
    ResetHandles()
    ScriptTest_Handles() ;Debug info
    Stats_Clear()

    $g_hScriptTimer = TimerInit()
    $g_bAntiStuck = True
    
    ;Pre Conditions
    If $g_hWindow = 0 Or $g_hControl = 0 Then
        Log_Add("Window handle not found.", $LOG_ERROR)
        MsgBox($MB_ICONERROR+$MB_OK, "Window handle not found.", "Window handle (" & $Config_Emulator_Title & ") : " & $g_hWindow & @CRLF & @CRLF & "Control handle (" & $Config_Emulator_Property & ") : " & $g_hControl & @CRLF & @CRLF & "Tip: Check if Emulator Title and Resolution (800x552) are correct.")
        $bOutput = False
    EndIf

    ;Establish ADB controls
    If $bOutput > 0 And ADB_Establish() <= 0 Then $bOutput = False

    If ($g_bRunning > 0 And $bOutput > 0) And ($Config_Mouse_Mode = $MOUSE_REAL Or $Config_Swipe_Mode == $SWIPE_REAL) Then
        MsgBox($MB_ICONWARNING+$MB_OK, "Script is using real mouse.", "Mouse cursor will be moved automatically. To stop the script, press ESCAPE key.")
        HotKeySet("{ESC}", "Stop")
    EndIf

    If $g_bRunning > 0 And $bOutput > 0 Then
        If $g_sScript == "" Then _GUICtrlComboBox_GetLBText($g_hCmb_Scripts, _GUICtrlComboBox_GetCurSel($g_hCmb_Scripts), $g_sScript)

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
        Start_Schedule()
    EndIf

    Log_Add("Start result: " & $bOutput & ".", $LOG_DEBUG)
    Log_Level_Remove()
    Return $bOutput
EndFunc

Func Start_Schedule()
    If StringLeft($g_sScript, 4) == "Farm" Or StringLeft($g_sScript, 6) == "Attack" Then
        Local $aStructure = ""
        Local $aAction = ""
        If $Hourly_Hourly_Script > 0 Then
            $aStructure = CreateArr(CreateArr("*", "*", "*", "00", "*"))
            $aAction = CreateArr("doHourly()")
            Schedule_Add("_Hourly", $aAction, $SCHEDULE_TYPE_DATE, "*", $aStructure, $SCHEDULE_FLAG_RunSafe, 60, True, False)
        EndIf

        If $General_Collect_Quests > 0 Then
            $aStructure = CreateArr(CreateArr(CreateArr('$g_sLocation = "battle-end"', 'isPixel(getPixelArg("battle-end-quest"), 10, CaptureRegion())')), True)
            $aAction = CreateArr("collectQuest()")
            Schedule_Add("_Quest", $aAction, $SCHEDULE_TYPE_CONDITION, "*", $aStructure, $SCHEDULE_FLAG_RunSafe, 5, True, False)
        EndIf   

        If $Guardian_Guardian_Script > 0 Then
            $aStructure = CreateArr(TimerInit(), $Guardian_Check_Intervals*60)
            $aAction = CreateArr('_Schedule_Guardian()')
            Schedule_Add("_Guardian", $aAction, $SCHEDULE_TYPE_TIMER, "*", $aStructure, $SCHEDULE_FLAG_RunSafe, 0, True, False)
        EndIf
    EndIf
EndFunc

Func _Schedule_Stop()
    Schedule_RemoveByName("_Hourly")
    Schedule_RemoveByName("_Quest")
    Schedule_RemoveByName("_Guardian")
EndFunc

Func _Schedule_Guardian()
    Local $aValues = Stats_Values_GetSpecific(Stats_GetValues($g_aStats), CreateArr("Guardians", "Astrogems_Used"))
    Local $aParam = CreateArr($Guardian_Guardian_Mode, IsDeclared($g_sScript & "_Refill")?Eval($g_sScript & "_Refill"):0, 0, $Guardian_Target_Boss)
    _RunScript("Farm_Guardian", $aParam, $aValues)

    navigate("map")
EndFunc

Func Stop()
    HotKeySet("{Esc}") ;unbinds hotkey

;Resets variables
    If (FileExists($ADB_PC_Shared & "\" & $Config_Emulator_Title & ".rgba")) Then FileDelete($ADB_PC_Shared & "\" & $Config_Emulator_Title & ".rgba")
    $g_hTimerLocation = Null
    $g_hScriptTimer = Null
    $g_sScript = ""
    $g_bAntiStuck = False

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
    _GDIPlus_Shutdown()
    ProcessClose($g_hADBShellPID)
    Exit
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
    _ArrayAdd($aTempLOG, "  -Emulator Path: " & $Config_Emulator_Path)
    _ArrayAdd($aTempLOG, "  -Emulator Console: " & $Config_Emulator_Console)
    _ArrayAdd($aTempLOG, "  -Emulator Title: " & $Config_Emulator_Title)
    _ArrayAdd($aTempLOG, "  -Emulator Property: " & $Config_Emulator_Property)
    _ArrayAdd($aTempLOG, "  -Display Scaling: " & $Config_Display_Scaling)
    _ArrayAdd($aTempLOG, "  -Capture Mode: " & $Config_Capture_Mode)
    _ArrayAdd($aTempLOG, "  -Mouse Mode: " & $Config_Mouse_Mode)
    _ArrayAdd($aTempLOG, "  -Swipe Mode: " & $Config_Swipe_Mode)
    _ArrayAdd($aTempLOG, "  -Back Mode: " & $Config_Back_Mode)

    ;Test window and control handle.
    ScriptTest_Handles()
    _ArrayAdd($aTempLOG, "Checking handles:")
    _ArrayAdd($aTempLOG, "  -Window handle: " & $g_hWindow)
    _ArrayAdd($aTempLOG, "  -Control handle: " & $g_hControl)

    If ($g_hWindow = 0) Then $sError &= @CRLF & @CRLF & "- Window handle was not found. Make sure the enter the correct Emulator Title in _Config."
    If ($g_hWindow <> 0 And $g_hControl = 0) Then $sError &= @CRLF & @CRLF & "- Control handle was not found. Make sure to enter the correct Emulator Class and Emulator Instance in _Config."

    ;Test Capture and Clicks
    Local $bCaptureWorking = False
    _ArrayAdd($aTempLOG, "Checking capture and click:")
    If ($g_hControl <> 0) Then
        CaptureRegion()

        Local $cFirst = getColor(0, 0)

        _ArrayAdd($aTempLOG, "  -Current location: " & getLocation())
        If (String($cFirst) == "0x000000" Or String($cFirst) == "0xFFFFFF" Or Not(isLocation("map"))) Then
            $sError &= @CRLF & @CRLF & "- Could not capture the emulator correctly. Make sure you are in MAP. If you are in the map, make sure the resolution of the emulator is 800x552 and is not maximized. " & _
                "You can use the function `Emulator_Restart()` in the debug input (CTRL+D) to automatically set the resolution (this automatic method could fail). Change the GRAPHICS RENDERING MODE in the emulator settings or change the CAPTURE METHOD in _Config."
            $sError &= @CRLF & @CRLF & "- Could not test click status because capture is not working."

            _ArrayAdd($aTempLOG, "  -Click working status: Unknown")
        Else
            $bCaptureWorking = True

            ;Opens refill window
            If clickWhile("414,16", "isPixel", CreateArr(0, 0, $cFirst), 5, 2000, "CaptureRegion()") = 0 Then 
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
    _ArrayAdd($aTempLOG, "  -ADB working status: " & $bAdbWorking)

    If $bAdbWorking <= 0 Then $sError &= @CRLF & @CRLF & "- ADB is not working. Make sure the ADB Path and ADB Device is correct. " & _
        "ADB Path is the path to the adb executable which can be found in the Nox directory. Enter the complete path which includes '...adb.exe' at the end." & _
        ' ADB Device can be found by typing `MsgBox(0, "", ADB_Command("devices"))` which will give you a list of available devices. Multiple emulators will need to guess which device goes with an emulator.'

    If $bAdbWorking > 0 And $bCaptureWorking > 0 Then
        If isLocation("map") > 0 Then
            Local $bAdbResponse = clickWhile("414,16", "isPixel", CreateArr(0, 0, getColor(0, 0)), 5, 2000, "CaptureRegion()", $MOUSE_ADB)
            _ArrayAdd($aTempLOG, "  -ADB response status: " & $bAdbResponse) ; Opens refill window using ADB
            If $bAdbResponse = 0 Then $sError &= @CRLF & @CRLF & '- Emulator is not responding to the ADB command. The ADB DEVICE in _Config might not be correct. Enter `MsgBox(0, "", ADB_Command("devices"))` in the debug input (Ctrl+D) to get the devices list.'
        Else
            SendBack(1, 0, $BACK_ADB)
            If waitLocation("map", 5) = 0 Then
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
    Log_Add("Window Title: " & $Config_Emulator_Title, $LOG_DEBUG)
    Log_Add("Window Handle: " & $g_hWindow, $LOG_DEBUG)
    Log_Add("Control Properties: " & $Config_Emulator_Property, $LOG_DEBUG)
    Log_Add("Control Handle: " & $g_hControl, $LOG_DEBUG)
    Log_Level_Remove()
EndFunc

Func ResetHandles()
    Log_Level_Add("ResetHandles()")
    Local $aHandles = WinList($Config_Emulator_Title)
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

    If $g_hControl = 0 Then
        $g_hWindow = $g_hControl
        ;Log_Add("Error: Could not get control handle.", $LOG_ERROR)
    Else
        If $Config_Emulator_Path = "~AUTO" Then $Config_Emulator_Path = GetWorkingDirectory(_WinAPI_GetProcessFileName(WinGetProcess($g_hWindow)))
    EndIf

    Log_Level_Remove()
    Return ($g_hControl <> 0)
EndFunc

Func RetrieveControlHandle($hWindow) ;Retrieves based on Emulator size
    Local $hChild = _WinAPI_GetWindow($hWindow, $GW_CHILD)
    If $hChild = 0 Then Return 0
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

    Local $hBack = $hParent[UBound($hParent)-1]
    If _ArrayDelete($hParent, UBound($hParent)-1) = 0 Then Return 0
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

                        Log_Add($g_sScript & ", " & $sConfig & " has been changed to " & $sValue)
                    EndIf

                Case "text"
                    Local $aNew = $g_aScripts[$iFound]
                    Local $aLayer = $aNew[2]
                    Local $aLayer2 = $aLayer[$iFoundConfig]

                    $aLayer2[1] = $sValue
                    $aLayer[$iFoundConfig] = $aLayer2
                    $aNew[2] = $aLayer
                    $g_aScripts[$iFound] = $aNew

                    Log_Add($g_sScript & ", " & $sConfig & " has been changed to " & $sValue)

                Case "list"
                    MsgBox($MB_ICONWARNING, "EditScript Warning", "List cannot be edited yet.")
            EndSwitch
            _GUICtrlComboBox_SetCurSel($g_hCmb_Scripts, _GUICtrlComboBox_FindStringExact($g_hCmb_Scripts, $sName))

            Script_ChangeConfig()
            Config_Save()
        EndIf
    EndIf
EndFunc