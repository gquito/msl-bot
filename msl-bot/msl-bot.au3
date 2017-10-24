#include-once
#include "bin/_src/imports.au3"

Initialize()

;Function: Initialize GUI and data.
Func Initialize()
    _GDIPlus_Startup()
    $g_bRunning = True
    $g_hWindow = WinGetHandle("User1")
    $g_hControl = ControlGetHandle("User1", "", "[CLASS:AnglePlayer_0; INSTANCE:1]")

    $g_aLocations = getArgsFromURL("https://raw.githubusercontent.com/GkevinOD/msl-bot/version-check/msl-bot/locations.txt", ">", ":")
    $g_aPixel = getArgsFromURL("https://raw.githubusercontent.com/GkevinOD/msl-bot/version-check/msl-bot/pixels.txt")
    $g_aPoints = getArgsFromURL("https://raw.githubusercontent.com/GkevinOD/msl-bot/version-check/msl-bot/points.txt")
    MsgBox(0, "", navigate("village", True))
    ;clickPoint("20,20")
EndFunc