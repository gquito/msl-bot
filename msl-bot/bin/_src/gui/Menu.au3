#include-once

Func HandleMenu($iCode)
    If $iCode >= 5 Then 
        Config_Update()
        ResetHandles()
    EndIf

    Switch $iCode 
        Case $M_File_Check_Version
            Local $aLatest[0] ;Will contain [Major,Minor,Build]
            Local $sRaw = StringSplit(BinaryToString(INetRead("https://raw.githubusercontent.com/GkevinOD/msl-bot/release/msl-bot/msl-bot.au3", $INET_FORCERELOAD)), @CRLF, $STR_NOCOUNT)[0]
            If StringInStr($sRaw, "[") And StringInStr($sRaw, "]") Then
                Local $sRaw2 = StringSplit(StringStripWS($sRaw, $STR_STRIPALL), "[", $STR_NOCOUNT)[1]
                Local $sRaw3 = StringSplit($sRaw2, "]", $STR_NOCOUNT)[0]
                $aLatest = StringSplit($sRaw3, ",", $STR_NOCOUNT)
            EndIf
            Local $sVersion = _ArrayToString($aLatest, ".")

            If $sVersion = "" Then $sVersion = "Count not retrieve latest version."
            MsgBox($MB_ICONINFORMATION, "Check Version", "Current version: " & _ArrayToString($aVersion, ".") & @CRLF & "Latest version: " & $sVersion)
        Case $M_File_View_Hotkeys
            MsgBox($MB_ICONINFORMATION, "View Hotkeys", FileRead(@ScriptDir & "\bin\local\hotkeys.txt"))
        Case $M_File_Open_Log_Folder
            Local $sPath = @ScriptDir & "\profiles\" & $Config_Profile_Name & "\log"
            If FileExists($sPath) > 0 Then
                ShellExecute($sPath)
            Else
                MsgBox($MB_ICONWARNING, "Open Log Folder", "The log folder does not exist.")
            EndIf
        Case $M_Script_Start
        Case $M_Script_Pause
            If $g_bRunning > 0 Then Pause()
        Case $M_Script_Stop
            If $g_bRunning > 0 Then Stop()
        Case $M_General_Restart_Emulator
            If $g_bRunning > 0 Then
                If MsgBox($MB_ICONWARNING+$MB_YESNO, "Emulator Restart", "Script is currently running, would you like to continue?", 30) = $IDYES Then
                    Emulator_Restart()
                EndIf
            Else
                $g_sScript = "Emulator_Restart"
                Start()
            EndIf
        Case $M_General_Restart_Game
            If $g_bRunning > 0 Then
                If MsgBox($MB_ICONWARNING+$MB_YESNO, "Restart Game", "Script is currently running, would you like to continue?", 30) = $IDYES Then
                    Emulator_RestartGame()
                EndIf
            Else
                $g_sScript = "Emulator_RestartGame"
                Start()
            EndIf
        Case $M_General_Debug_Input
            If $g_hDebugInput = Null Then DebugInput_CreateGUI()
        Case $M_General_Compatibility_Test
            If $g_bRunning > 0 Then
                MsgBox($MB_ICONERROR, "Compatibility Test", "Stop any running script before running Compatibility Test.", 30)
            Else
                $g_sScript = "ScriptTest"
                Start()
            EndIf
        Case $M_ADB_Run_Command
            Local $bRunning = $g_bRunning
            $g_bRunning = True
            If $g_bADBWorking = 0 Then ADB_Establish()

            Local $sInput = InputBox("Run Command", "Enter a command:")
            MsgBox($MB_ICONINFORMATION, "Run Command", ADB_Command($sInput))
            $g_bRunning = $bRunning
        Case $M_ADB_Device_List
            Local $bRunning = $g_bRunning
            $g_bRunning = True
            If $g_bADBWorking = 0 Then ADB_Establish()

            MsgBox($MB_ICONINFORMATION, "Device List", ADB_Command("devices"))
            $g_bRunning = $bRunning
        Case $M_ADB_Status
            Local $bRunning = $g_bRunning
            $g_bRunning = True
            If $g_bADBWorking = 0 Then ADB_Establish()

            MsgBox($MB_ICONINFORMATION, "Status", "ADB is " & (ADB_isWorking()?"":"not ") & "working.")
            $g_bRunning = $bRunning
        Case $M_ADB_Game_Status
            Local $bRunning = $g_bRunning
            $g_bRunning = True
            If $g_bADBWorking = 0 Then ADB_Establish()

            Local $bGameRunning = ADB_IsGameRunning()
            If ($bGameRunning == -2) Then
                MsgBox($MB_ICONINFORMATION, "Game Status", "Error: Could not determine game status. ADB is not working.")
            Else
                MsgBox($MB_ICONINFORMATION, "Game Status", "Game is " & ($bGameRunning?"":"not ") & "running.")
            EndIf
           
            $g_bRunning = $bRunning
        Case $M_Location_Navigate
            If $g_bRunning > 0 Then
                MsgBox($MB_ICONWARNING, "Navigate", "A script is currently running.")
            Else
                Start()
                navigate(InputBox("Navigate", "Enter a location:"), True)
                Stop()
            EndIf
        Case $M_Location_Get_Location
            $g_iLocationIndex = -1
            MsgBox($MB_ICONINFORMATION, "Get Location", "Current location: " & getLocation())
        Case $M_Location_Set_Location
            If $g_bRunning > 0 Then
                MsgBox($MB_ICONWARNING, "Set Location", "A script is currently running.")
            Else
                Local $sLocation = InputBox("Set Location", "Enter location:")

                ResetHandles()
                $g_iLocationIndex = -1
                Local $sCurrent = getLocation(True, True)
                ;saveHBitmap("DEBUG")

                If $sCurrent == $sLocation Then
                    MsgBox($MB_ICONWARNING, "Set Location", "Location is already set to " & $sCurrent, 30)
                Else
                    If $sCurrent == "unknown" Or MsgBox($MB_ICONWARNING+$MB_YESNO, "Set Location", "Location is already set: " & $sCurrent & "." & @CRLF & "Would you like to set this as another location?", 30) = $IDYES Then
                        Local $bExist = False
                        For $i = 0 To UBound($g_aLocations)-1
                            If $sLocation = $g_aLocations[$i][0] Then
                                $bExist = True
                                ExitLoop
                            EndIf
                        Next

                        If $bExist > 0 Or MsgBox($MB_ICONWARNING+$MB_YESNO, "Set Location", "Location '" & $sLocation & "' does not exist." & @CRLF & "Would you like to continue?", 30) = $IDYES Then
                            Local $aData = Null
                            If $bExist = 0 Then
                                $aData = InputBox("Set Location", "Enter points using '|' per point:" & @CRLF & "Example: '0,0|12,10|313,544")
                            EndIf

                            MsgBox($MB_ICONINFORMATION, "Set Location", "Set location result: " & setLocation($sLocation, $aData, False))
                        EndIf
                    EndIf
                EndIf
            EndIf
        Case $M_Location_Test_Location
            If $g_bRunning > 0 Then
                MsgBox($MB_ICONWARNING, "Test Location", "A script is currently running.")
            Else
                $g_sScript = "testLocation"
                Start()
            EndIf
        Case $M_Pixel_Check_Pixel
            Local $sInput = InputBox("Check Pixel", "Enter pixel set:")
            Local $bResult = isPixel(Execute($sInput), 10, CaptureRegion(), True)
            MsgBox($MB_ICONINFORMATION, "Check Pixel", "Pixel set matches: " & $bResult & @CRLF)
            _ArrayDisplay($g_vDebug)
        Case $M_Pixel_Set_Pixel
            If $g_bRunning > 0 Then
                MsgBox($MB_ICONWARNING, "Set Pixel", "A script is currently running.")
            Else
                Local $sPixel = InputBox("Set Pixel", "Enter pixel name:")
                CaptureRegion()
                
                Local $bExist = False
                For $i = 0 To UBound($g_aPixels)-1
                    If $sPixel = $g_aPixels[$i][0] Then
                        $bExist = True
                        ExitLoop
                    EndIf
                Next

                If ($bExist > 0 And MsgBox($MB_ICONWARNING+$MB_YESNO, "Set Pixel", "Pixel '" & $sPixel & "' already exists." & @CRLF & "Would you like to continue?", 30) = $IDYES) Or MsgBox($MB_ICONWARNING+$MB_YESNO, "Set Pixel", "Pixel '" & $sPixel & "' does not exist." & @CRLF & "Would you like to continue?", 30) = $IDYES Then
                    Local $aData = Null
                    If $bExist = 0 Then
                        $aData = InputBox("Set Pixel", "Enter points using '|' per point:" & @CRLF & "Example: '0,0|12,10|313,544")
                    EndIf
                    MsgBox($MB_ICONINFORMATION, "Set Pixel", "Set Pixel result: " & setPixel($sPixel, $aData, False))
                EndIf
            EndIf
        Case $M_Pixel_Get_Color
            Local $sX = InputBox("Get Color", "Enter x-coordinate:")
            Local $sY = InputBox("Get Color", "Enter y-coordinate:")
            MsgBox($MB_ICONINFORMATION, "Get Color", StringFormat("Color at (%s, %s): %s", $sX, $sY, getColor($sX, $sY)))
        Case $M_Scripts_Hourly
            If $g_bRunning > 0 Then
                If MsgBox($MB_ICONWARNING+$MB_YESNO, "Hourly", "Script is currently running, would you like to continue?", 30) = $IDYES Then
                    doHourly()
                EndIf
            Else
                $g_sScript = "doHourly"
                Start()
            EndIf
        Case $M_Scripts_Collect_Quest
            If $g_bRunning > 0 Then
                If MsgBox($MB_ICONWARNING+$MB_YESNO, "Collect Quest", "Script is currently running, would you like to continue?", 30) = $IDYES Then
                    collectQuest()
                EndIf
            Else
                $g_sScript = "collectQuest"
                Start()
            EndIf
        Case $M_Scripts_Guardian_Dungeon
            If $g_bRunning > 0 Then
                If MsgBox($MB_ICONWARNING+$MB_YESNO, "Guardian Dungeon", "Script is currently running, would you like to continue?", 30) = $IDYES Then
                    _Schedule_Guardian()
                EndIf
            Else
                $g_sScript = "_Schedule_Guardian"
                Start()
            EndIf
        Case $M_Capture_Full_Screenshot
            If FileExists(@ScriptDir & "\screenshots\" & $Config_Profile_Name) = 0 Then DirCreate(@ScriptDir & "\screenshots\" & $Config_Profile_Name)
            Local $sName = StringRegExpReplace(_NowCalc() , "(\/|\s|\:)", "")
            CaptureRegion("screenshots\" & $Config_Profile_Name & "\" & $sName)
            MsgBox($MB_ICONINFORMATION, "Full Screenshot", $sName & ".bmp has been saved in the screenshots folder.")
        Case $M_Capture_Partial_Screenshot
            If FileExists(@ScriptDir & "\screenshots\" & $Config_Profile_Name) = 0 Then DirCreate(@ScriptDir & "\screenshots\" & $Config_Profile_Name)
            Local $sName = StringRegExpReplace(_NowCalc() , "(\/|\s|\:)", "")
            Local $x = InputBox("Partial Screenshot", "Enter x-coordinate:")
            Local $y = InputBox("Partial Screenshot", "Enter y-coordinate:")
            Local $width = InputBox("Partial Screenshot", "Enter width:")
            Local $height = InputBox("Partial Screenshot", "Enter height:")
            CaptureRegion("screenshots\" & $Config_Profile_Name & "\" & $sName, $x, $y, $width, $height)
            MsgBox($MB_ICONINFORMATION, "Partial Screenshot", $sName & ".bmp has been saved in the screenshots folder.")
        Case $M_Capture_Open_Folder
            Local $sPath = @ScriptDir & "\screenshots"
            If FileExists($sPath) > 0 Then
                ShellExecute($sPath)
            Else
                MsgBox($MB_ICONWARNING, "Open Screenshot Folder", "The screenshot folder does not exist.")
            EndIf
        Case $Dummy_Test_Function
            TestFunction()
    EndSwitch
EndFunc