Global $aVersion = [4, 1, 2] ;Major, Minor, Build, Beta

ConsoleWrite($aVersion[0] & "." & $aVersion[1] & "." & $aVersion[2] & @CRLF);"." & $aVersion[3] & @CRLF)

#pragma compile(Out, "msl-bot")
#pragma compile(Icon, "bin\_src\msl-bot.ico")
#pragma compile(x64, False)
#pragma compile(UPX, False)
#pragma compile(ProductName, "Monster Super League Bot")
#pragma compile(FileDescription, "Open-sourced Monster Super League Bot - https://github.com/GkevinOD/msl-bot")
#pragma compile(LegalCopyright, "Copyright (C) Kevin Quito")
#pragma compile(FileVersion, 4.1.2)
#pragma compile(ProductVersion, 4.1.2)
#pragma compile(OriginalFilename, "msl-bot")
#pragma compile(AutoItExecuteAllowed, True)

#AutoIt3Wrapper_Version=P

#include-once
#include "bin/_src/imports.au3"
#RequireAdmin


;Opt("MustDeclareVars", 1)
Opt("GUICloseOnESC", 0)

Initialize()

;Function: Initialize GUI and data.
Func Initialize()
    If (@Compiled) Then
        MsgBox(0, "Not Supported", "Compiling is no longer supported until further notice")
        Exit
    EndIf

    _GDIPlus_Startup()
    ;_WinAPI_SetProcessDpiAwareness($PROCESS_PER_MONITOR_DPI_AWARE)
    ; Default configs and constants
    setScripts($g_aScripts, $g_sLocalFolder & $g_sScriptsSettings) ;Sets local scripts first, existing scripts will not be overwritten
    If (Not(_WinAPI_IsInternetConnected())) Then
        MsgBox($MB_ICONWARNING+$MB_OK, "Not connected.", "Could not retrieve script data from remote location." & @CRLF & "Using local files instead.")
        If (Not(FileExists($g_sLocalCacheFolder & $g_sLocations))) Then MsgBox($MB_ICONERROR+$MB_OK, "No cache found.", "There has not been any cache files made.")
        $g_aNezzPos = getArgsFromFile($g_sLocalCacheFolder & $g_sNezzPositions)
        $g_aLocations = getArgsFromFile($g_sLocalCacheFolder & $g_sLocations)
        $g_aPixels = getArgsFromFile($g_sLocalCacheFolder & $g_sPixels)
        $g_aPoints = getArgsFromFile($g_sLocalCacheFolder & $g_sPoints)
        $g_sLocationsMap = getArgsFromFile($g_sLocalCacheFolder & $g_sLocationsMap)

        setScripts($g_aScripts, $g_sLocalCacheFolder & $g_sScriptsSettings)
    Else
        $g_aNezzPos = getArgsFromURL($g_sRemoteUrl & $g_sNezzPositions, ">", ":", $g_sLocalCacheFolder & $g_sNezzPositions)
        $g_aLocations = getArgsFromURL($g_sRemoteUrl & $g_sLocations, ">", ":", $g_sLocalCacheFolder & $g_sLocations)
        $g_aPixels = getArgsFromURL($g_sRemoteUrl & $g_sPixels, ">", ":", $g_sLocalCacheFolder & $g_sPixels)
        $g_aPoints = getArgsFromURL($g_sRemoteUrl & $g_sPoints, ">", ":", $g_sLocalCacheFolder & $g_sPoints)
        $g_aLocationsMap = getArgsFromURL($g_sRemoteUrl & $g_sLocationsMap, ">", ":", $g_sLocalCacheFolder & $g_sLocationsMap)

        setScripts($g_aScripts, $g_sRemoteUrl & $g_sScriptsV4, $g_sLocalCacheFolder & $g_sScriptsSettings)
    EndIf

    CreateLocationsMap($g_aLocationsMap, $g_aLocations)

    mergeArgFromTo(getArgsFromFile($g_sLocalDataFolder & $g_sLocations), $g_aLocations, "/")
    mergeArgFromTo(getArgsFromFile($g_sLocalDataFolder & $g_sNezzPositions), $g_aNezzPos)
    mergeArgFromTo(getArgsFromFile($g_sLocalDataFolder & $g_sPixels), $g_aPixels)
    mergeArgFromTo(getArgsFromFile($g_sLocalDataFolder & $g_sPoints), $g_aPoints)
    mergeArgFromTo(getArgsFromFile($g_sLocalDataFolder & $g_sImageLocations), $g_aImageLocations)

    ;User configs
    Local $t_sProfile = $d_sProfile
    If ($CmdLine[0] > 0 And FileExists($g_sProfileFolder & $CmdLine[1] & "\")) Then
        $t_sProfile = $CmdLine[1]
    Else
        Local $aFolders = _FileListToArray($g_sProfileFolder, "*", $FLTA_FOLDERS)
        If (isArray($aFolders) And $aFolders[0] > 0) Then $t_sProfile = $aFolders[1]
    EndIf

    ;Found existing profile..
    $g_sProfilePath = $g_sProfileFolder & $t_sProfile & "\"
    getConfigsFromFile($g_aScripts, "_Config", $g_sProfileFolder & $t_sProfile & "\")

    For $i = 0 To UBound($g_aScripts, $UBOUND_ROWS)-1
        Local $aScript = $g_aScripts[$i]
        If (FileExists($g_sProfilePath & "\" & $aScript[0])) Then getConfigsFromFile($g_aScripts, $aScript[0])
    Next

    UpdateSettings()
    CreateGUI()
EndFunc

Func MSLMain()
    If $g_bRunning = True Then
        ;Other preconditions
        If ($g_iBackgroundMode = $BKGD_ADB) Then
            CaptureRegion()
            If (Not(FileExists($g_sEmuSharedFolder[1] & "\" & $g_sWindowTitle & ".png"))) Then
                MsgBox($MB_ICONERROR+$MB_OK, "Shared folder not valid.", "Image file was not created: " & $g_sEmuSharedFolder[1] & "\" & $g_sWindowTitle & ".png")
                Stop()
            EndIf
        EndIf

        WinSetTitle($g_hParent, "", $g_sAppTitle & ": " & StringReplace($g_sScript, "_", ""))
        Call(StringReplace($g_sScript, " ", "_"), $g_aScriptArgs)
        If (@error = 0xDEAD And @extended = 0xBEEF) Then MsgBox($MB_ICONERROR+$MB_OK, "Function call error", "Function for the script does not exist or does not meet parameter count: " & StringReplace($g_sScript, " ", "_"))

        Stop()
    EndIf
 EndFunc