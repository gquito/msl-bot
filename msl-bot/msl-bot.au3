Global $aVersion = [4, 3, 1] ;Major, Minor, Build

#pragma compile(Out, "msl-donator.exe")
#pragma compile(x64, False)
#pragma compile(UPX, False)
#pragma compile(ProductName, "Monster Super League Bot")
#pragma compile(FileDescription, "Open-sourced Monster Super League Bot - https://github.com/GkevinOD/msl-bot")
#pragma compile(LegalCopyright, "Copyright (C) Kevin Quito")
#pragma compile(FileVersion, 4.3.1)
#pragma compile(ProductVersion, 4.3.1)
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
    If (@Compiled) Then
        MsgBox(0, "Not Supported", "Compiling is no longer supported until further notice")
        Exit
    EndIf

    ; Default configs and constants
    $g_aNezzPos = getArgsFromFile($g_sLocalOriginalFolder & $g_sNezzPositions)
    If @error Then MsgBox($MB_ICONERROR, "MSL-Bot Error", "Could not read file: " & $g_sLocalOriginalFolder & $g_sNezzPositions)
    $g_aLocations = getArgsFromFile($g_sLocalOriginalFolder & $g_sLocations)
    If @error Then MsgBox($MB_ICONERROR, "MSL-Bot Error", "Could not read file: " & $g_sLocalOriginalFolder & $g_sLocations)
    $g_aPixels = getArgsFromFile($g_sLocalOriginalFolder & $g_sPixels)
    If @error Then MsgBox($MB_ICONERROR, "MSL-Bot Error", "Could not read file: " & $g_sLocalOriginalFolder & $g_sPixels)
    $g_aPoints = getArgsFromFile($g_sLocalOriginalFolder & $g_sPoints)
    If @error Then MsgBox($MB_ICONERROR, "MSL-Bot Error", "Could not read file: " & $g_sLocalOriginalFolder & $g_sPoints)
    $g_aLocationsMap = getArgsFromFile($g_sLocalOriginalFolder & $g_sLocationsMap)
    If @error Then MsgBox($MB_ICONERROR, "MSL-Bot Error", "Could not read file: " & $g_sLocalOriginalFolder & $g_sLocationsMap)
    $g_aImageLocations = getArgsFromFile($g_sLocalDataFolder & $g_sImageLocations)
    If @error Then MsgBox($MB_ICONERROR, "MSL-Bot Error", "Could not read file: " & $g_sLocalDataFolder & $g_sImageLocations)

    Script_SetData($g_sLocalFolder & $g_sScriptsSettings)

    mergeArgFromTo(getArgsFromFile($g_sLocalDataFolder & $g_sLocations), $g_aLocations)
    mergeArgFromTo(getArgsFromFile($g_sLocalDataFolder & $g_sLocationsMap), $g_aLocationsMap)
    mergeArgFromTo(getArgsFromFile($g_sLocalDataFolder & $g_sNezzPositions), $g_aNezzPos)
    mergeArgFromTo(getArgsFromFile($g_sLocalDataFolder & $g_sPixels), $g_aPixels)
    mergeArgFromTo(getArgsFromFile($g_sLocalDataFolder & $g_sPoints), $g_aPoints)

    CreateLocationsMap($g_aLocationsMap, $g_aLocations)

    ;Found existing profile..
    Local $aFolders = _FileListToArray($g_sProfileFolder)
    If isArray($aFolders) > 0 Then
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
    If $g_bRunning > 0 Then
        WinSetTitle($g_hParent, "", $g_sAppTitle & ": " & StringReplace($g_sScript, "_", ""))
        Call(StringReplace($g_sScript, " ", "_"))
        If (@error = 0xDEAD And @extended = 0xBEEF) Then MsgBox($MB_ICONERROR+$MB_OK, "Function call error", "Could not call function: " & StringReplace($g_sScript, " ", "_"))

        Stop()
    EndIf
EndFunc