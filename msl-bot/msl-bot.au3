Global $aVersion = [3, 6, 2] ;Major, Minor, Build

#pragma compile(Out, msl-bot.exe)
#pragma compile(Icon, bin\_src\msl-bot.ico)
#pragma compile(x64, false)
#pragma compile(UPX, false)
#pragma compile(ProductName, Monster Super League Bot)
#pragma compile(FileDescription, Open-sourced Monster Super League Bot - https://github.com/GkevinOD/msl-bot)
#pragma compile(LegalCopyright, "Copyright (C) Kevin Quito")
#pragma compile(FileVersion, 3.6.2)
#pragma compile(ProductVersion, 3.6.2)
#pragma compile(OriginalFilename, msl-bot.exe)

#include-once
#include "bin/_src/imports.au3"

Initialize()

;Function: Initialize GUI and data.
Func Initialize()
    _GDIPlus_Startup()

    If FileExists(@TempDir & "\ImageSearchDLL.dll") = False Then
        _CreateTempDLL() ;Creates dll file in windows temporary directory.
    EndIf

    ; Default configs and constants
    $g_aLocations = getArgsFromURL($g_sLocationsURL, ">", ":")
    $g_aPixels = getArgsFromURL($g_sPixelsURL, ">", ":")
    $g_aPoints = getArgsFromURL($g_sPointsURL, ">", ":")

    getScriptsFromUrl($g_aScripts, $g_sScriptsURL)

    ;User configs
    Local $aFolders = _FileListToArray(@ScriptDir & "\profiles\", "*", $FLTA_FOLDERS)
    If isArray($aFolders) = True And $aFolders[0] > 0 Then
        ;Found existing profile..
        $g_sProfilePath = @ScriptDir & "\profiles\" & $aFolders[1] & "\"
        getConfigsFromFile($g_aScripts, "_Config", @ScriptDir & "\profiles\" & $aFolders[1] & "\")
    EndIf

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