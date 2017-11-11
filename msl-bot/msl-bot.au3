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
        ;Local $aTest = [$g_sProfilePath, $g_sAdbPath, $g_sAdbDevice, $g_sEmuSharedFolder[0], $g_sEmuSharedFolder[1], $g_sWindowTitle, $g_sControlInstance, $g_iBackgroundMode, $g_iMouseMode, $g_iSwipeMode]
        ;_ArrayDisplay($aTest)

        Call(StringReplace($g_sScript, " ", "_"), $g_aScriptArgs)
    EndIf
EndFunc