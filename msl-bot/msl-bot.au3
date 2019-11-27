Global $aVersion = [4, 2, 1] ;Major, Minor, Build

#pragma compile(Out, "msl-bot.exe")
#pragma compile(x64, False)
#pragma compile(UPX, False)
#pragma compile(ProductName, "Monster Super League Bot")
#pragma compile(FileDescription, "Open-sourced Monster Super League Bot - https://github.com/GkevinOD/msl-bot")
#pragma compile(LegalCopyright, "Copyright (C) Kevin Quito")
#pragma compile(FileVersion, 4.2.1)
#pragma compile(ProductVersion, 4.2.1)
#pragma compile(OriginalFilename, "msl-bot.exe")
#pragma compile(AutoItExecuteAllowed, True)

#include-once
#include "bin/_src/imports.au3"
#RequireAdmin

Opt("MustDeclareVars", 1)
Opt("GUICloseOnESC", 0)

Initialize()

;Function: Initialize GUI and data.
Func Initialize()
    ;If (@Compiled) Then
    ;    MsgBox(0, "Not Supported", "Compiling is no longer supported until further notice")
    ;    Exit
    ;EndIf

    _GDIPlus_Startup()

    ; Default configs and constants
    If _WinAPI_IsInternetConnected() = False Then
        MsgBox($MB_ICONWARNING+$MB_OK, "Not connected.", "Could not retrieve script data from remote location." & @CRLF & "Using local files instead.")
        If FileExists($g_sLocalCacheFolder & $g_sLocations) = False Then MsgBox($MB_ICONERROR+$MB_OK, "No cache found.", "There has not been any cache files made.")
        $g_aNezzPos = getArgsFromFile($g_sLocalCacheFolder & $g_sNezzPositions)
        $g_aLocations = getArgsFromFile($g_sLocalCacheFolder & $g_sLocations)
        $g_aPixels = getArgsFromFile($g_sLocalCacheFolder & $g_sPixels)
        $g_aPoints = getArgsFromFile($g_sLocalCacheFolder & $g_sPoints)
        $g_aLocationsMap = getArgsFromFile($g_sLocalCacheFolder & $g_sLocationsMap)

        Script_SetData($g_sLocalCacheFolder & $g_sScriptsSettings)
    Else
        $g_aNezzPos = getArgsFromURL($g_sRemoteUrl & $g_sNezzPositions, ">", ":", $g_sLocalCacheFolder & $g_sNezzPositions)
        $g_aLocations = getArgsFromURL($g_sRemoteUrl & $g_sLocations, ">", ":", $g_sLocalCacheFolder & $g_sLocations)
        $g_aPixels = getArgsFromURL($g_sRemoteUrl & $g_sPixels, ">", ":", $g_sLocalCacheFolder & $g_sPixels)
        $g_aPoints = getArgsFromURL($g_sRemoteUrl & $g_sPoints, ">", ":", $g_sLocalCacheFolder & $g_sPoints)
        $g_aLocationsMap = getArgsFromURL($g_sRemoteUrl & $g_sLocationsMap, ">", ":", $g_sLocalCacheFolder & $g_sLocationsMap)

        Script_SetData($g_sRemoteUrl & $g_sScripts, $g_sLocalCacheFolder & $g_sScriptsSettings)
    EndIf

    CreateLocationsMap($g_aLocationsMap, $g_aLocations)

    mergeArgFromTo(getArgsFromFile($g_sLocalDataFolder & $g_sLocations), $g_aLocations, "/")
    mergeArgFromTo(getArgsFromFile($g_sLocalDataFolder & $g_sNezzPositions), $g_aNezzPos)
    mergeArgFromTo(getArgsFromFile($g_sLocalDataFolder & $g_sPixels), $g_aPixels)
    mergeArgFromTo(getArgsFromFile($g_sLocalDataFolder & $g_sPoints), $g_aPoints)
    mergeArgFromTo(getArgsFromFile($g_sLocalDataFolder & $g_sImageLocations), $g_aImageLocations)

    ;Found existing profile..
    Local $aFolders = _FileListToArray($g_sProfileFolder)
    If isArray($aFolders) = True Then
        For $i = 1 To $aFolders[0]
            If $aFolders[$i] <> "schedule_presets" Then
                Script_ChangeProfile($aFolders[$i])
                ExitLoop
            EndIf
        Next
    EndIf

    Config_Update()
    CreateGUI()
EndFunc

Func MSLMain()
    If $g_bRunning = True Then
        ;Other preconditions
        If ($Config_Capture_Mode = $BKGD_ADB) Then
            CaptureRegion()
            If (Not(FileExists($Config_ADB_Shared_Folder2 & "\" & $Config_Emulator_Title & ".png"))) Then
                MsgBox($MB_ICONERROR+$MB_OK, "Shared folder not valid.", "Image file was not created: " & $Config_ADB_Shared_Folder2 & "\" & $Config_Emulator_Title & ".png")
                Stop()
            EndIf
        EndIf

        WinSetTitle($g_hParent, "", $g_sAppTitle & ": " & StringReplace($g_sScript, "_", ""))
        Call(StringReplace($g_sScript, " ", "_"))
        If (@error = 0xDEAD And @extended = 0xBEEF) Then MsgBox($MB_ICONERROR+$MB_OK, "Function call error", "Could not call function: " & StringReplace($g_sScript, " ", "_"))

        Stop()
    EndIf
 EndFunc