Global $aVersion = [3, 10, 6] ;Major, Minor, Build

#pragma compile(Out, msl-bot.exe)
#pragma compile(Icon, bin\_src\msl-bot.ico)
#pragma compile(x64, false)
#pragma compile(UPX, false)
#pragma compile(ProductName, Monster Super League Bot)
#pragma compile(FileDescription, Open-sourced Monster Super League Bot - https://github.com/GkevinOD/msl-bot)
#pragma compile(LegalCopyright, "Copyright (C) Kevin Quito")
#pragma compile(FileVersion, 3.10.6)
#pragma compile(ProductVersion, 3.10.6)
#pragma compile(OriginalFilename, msl-bot.exe)

#include-once
#include "bin/_src/imports.au3"

#RequireAdmin

Initialize()

;Function: Initialize GUI and data.
Func Initialize()
    _GDIPlus_Startup()

    If FileExists(@TempDir & "\ImageSearchDLL.dll") = False Then
        _CreateTempDLL() ;Creates dll file in windows temporary directory.
    EndIf

    ; Default configs and constants
    setScripts($g_aScripts, $g_sScriptsLocal) ;Sets local scripts first, existing scripts will not be overwritten
    If _WinAPI_IsInternetConnected() = False Then
        MsgBox($MB_ICONWARNING+$MB_OK, "Not connected.", "Could not retrieve script data from remote location." & @CRLF & "Using local files instead.")
        If FileExists($g_sLocationsLocalCache) = False Then
            MsgBox($MB_ICONERROR+$MB_OK, "No cache found.", "There has not been any cache files made.")
        EndIf
        $g_aNezzPos = getArgsFromFile($g_sNezzPosLocalCache, ">", ":")
        $g_aLocations = getArgsFromFile($g_sLocationsLocalCache, ">", ":")
        $g_aPixels = getArgsFromFile($g_sPixelsLocalCache, ">", ":")
        $g_aPoints = getArgsFromFile($g_sPointsLocalCache, ">", ":")

        setScripts($g_aScripts, $g_sScriptsLocalCache)
    Else
        $g_aNezzPos = getArgsFromURL($g_sNezzPosURL, ">", ":", $g_sNezzPosLocalCache)
        $g_aLocations = getArgsFromURL($g_sLocationsURL, ">", ":", $g_sLocationsLocalCache)
        $g_aPixels = getArgsFromURL($g_sPixelsURL, ">", ":", $g_sPixelsLocalCache)
        $g_aPoints = getArgsFromURL($g_sPointsURL, ">", ":", $g_sPointsLocalCache)

        setScripts($g_aScripts, $g_sScriptsURL, $g_sScriptsLocalCache)
    EndIf

    mergeArgFromTo(getArgsFromFile($g_sLocationsLocal, ">", ":"), $g_aLocations, "/")
    mergeArgFromTo(getArgsFromFile($g_sNezzPosLocal, ">", ":"), $g_aNezzPos)
    mergeArgFromTo(getArgsFromFile($g_sPixelsLocal, ">", ":"), $g_aPixels)
    mergeArgFromTo(getArgsFromFile($g_sPointsLocal, ">", ":"), $g_aPoints)

    ;User configs
    Local $t_sProfile = "Default"
    If ($CmdLine[0] > 0) And (FileExists(@ScriptDir & "\profiles\" & $CmdLine[1] & "\") = True) Then
        $t_sProfile = $CmdLine[1]
    Else
        Local $aFolders = _FileListToArray(@ScriptDir & "\profiles\", "*", $FLTA_FOLDERS)
        If isArray($aFolders) = True And $aFolders[0] > 0 Then
            $t_sProfile = $aFolders[1]
        EndIf
    EndIf

    ;Found existing profile..
    $g_sProfilePath = @ScriptDir & "\profiles\" & $t_sProfile & "\"
    getConfigsFromFile($g_aScripts, "_Config", @ScriptDir & "\profiles\" & $t_sProfile & "\")

    For $i = 0 To UBound($g_aScripts, $UBOUND_ROWS)-1
        Local $aScript = $g_aScripts[$i]
        If FileExists($g_sProfilePath & "\" & $aScript[0]) = True Then
            getConfigsFromFile($g_aScripts, $aScript[0])
        EndIf
    Next

    UpdateSettings()
    CreateGUI()
EndFunc

Func MSLMain()
    If $g_bRunning = True Then
        ;Other preconditions
        If $g_iBackgroundMode = $BKGD_ADB Then
            CaptureRegion()
            If FileExists($g_sEmuSharedFolder[1] & "\" & $g_sWindowTitle & ".png") = False Then
                MsgBox($MB_ICONERROR+$MB_OK, "Shared folder not valid.", "Image file was not created: " & $g_sEmuSharedFolder[1] & "\" & $g_sWindowTitle & ".png")
                Stop()
            EndIf
        EndIf

        Call(StringReplace($g_sScript, " ", "_"), $g_aScriptArgs)
        If @error = 0xDEAD And @extended = 0xBEEF Then
            MsgBox($MB_ICONERROR+$MB_OK, "Function call error", "Function for the script does not exist or does not meet parameter count: " & StringReplace($g_sScript, " ", "_"))
        EndIf

        Stop()
    EndIf
EndFunc