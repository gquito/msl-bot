Global $aVersion = [3, 1, 0] ;Major, Minor, Build

#AutoIt3Wrapper_UseX64=n
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
    $g_aLocations = getArgsFromURL("https://raw.githubusercontent.com/GkevinOD/msl-bot/version-check/msl-bot/locations.txt", ">", ":")
    $g_aPixels = getArgsFromURL("https://raw.githubusercontent.com/GkevinOD/msl-bot/version-check/msl-bot/pixels.txt", ">", ":")
    $g_aPoints = getArgsFromURL("https://raw.githubusercontent.com/GkevinOD/msl-bot/version-check/msl-bot/points.txt", ">", ":")

    getScriptsFromUrl($g_aScripts, "https://raw.githubusercontent.com/GkevinOD/msl-bot/version-check/msl-bot/scripts.txt")
    For $i = 0 To UBound($g_aScripts, $UBOUND_ROWS)-1
        Local $aScript = $g_aScripts[$i]
        If FileExists($g_sProfilePath & "\" & $aScript[0]) = True Then
            getConfigsFromFile($g_aScripts, $aScript[0])
        EndIf
    Next

    ;User configs
    Local $aFolders = _FileListToArray(@ScriptDir & "\profiles\", "*", $FLTA_FOLDERS)
    If isArray($aFolders) = True And $aFolders[0] > 0 Then
        ;Found existing profile..
        getConfigsFromFile($g_aScripts, "_Config", @ScriptDir & "\profiles\" & $aFolders[1] & "\")
    EndIf

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
            MsgBox($MB_ICONERROR+$MB_OK, "Function does not exist.", "Function for the script does not exist: " & StringReplace($g_sScript, " ", "_"))
            Stop()
        EndIf
    EndIf
EndFunc