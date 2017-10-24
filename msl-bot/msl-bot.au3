#include-once
#include "bin/_src/imports.au3"

Initialize()

;Function: Initialize GUI and data.
Func Initialize()
    _GDIPlus_Startup()
    $g_bRunning = True
    $g_sWindowTitle = "User2"
    $g_sControlInstance = "[CLASS:subWin; INSTANCE:1]"
    $g_hWindow = WinGetHandle($g_sWindowTitle)
    $g_hControl = ControlGetHandle($g_hWindow, "", $g_sControlInstance)

    $g_aLocations = getArgsFromURL("https://raw.githubusercontent.com/GkevinOD/msl-bot/version-check/msl-bot/locations.txt", ">", ":")
    $g_aPixels = getArgsFromURL("https://raw.githubusercontent.com/GkevinOD/msl-bot/version-check/msl-bot/pixels.txt", ">", ":")
    $g_aPoints = getArgsFromURL("https://raw.githubusercontent.com/GkevinOD/msl-bot/version-check/msl-bot/points.txt", ">", ":")
    MsgBox(0, "", navigate("village", True))
    DisplayDebug()
EndFunc