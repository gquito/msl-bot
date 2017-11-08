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

    $g_sWindowTitle = "User2"
    $g_sControlInstance = "[CLASS:subWin; INSTANCE:1]"
    $g_hWindow = WinGetHandle($g_sWindowTitle)
    $g_hControl = ControlGetHandle($g_hWindow, "", $g_sControlInstance)
    $g_iBackgroundMode = $BKGD_ADB
    $g_sAdbPort = 62026
    $g_sProfilePath = @ScriptDir & "\profiles\" & $g_sWindowTitle

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

    CreateGUI()
EndFunc

Func MSLMain()
    If $g_bRunning = True Then
        Call(StringReplace($g_sScript, " ", "_"), $g_aScriptArgs)
    EndIf
EndFunc