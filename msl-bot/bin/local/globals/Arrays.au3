#include-once
#include "../../_src/global.au3"

;data from files
Global $g_aScripts[0] ;Script data [[script, description, [[config, value, description], [..., ..., ...]]], ...]
Global $g_aLocations[0] ;Data locations [[location, value], ...]
Global $g_aLocationsMap = Null ;Location mappings
Global $g_aPixels[0] ;Individual pixel data [[name, pixel], ...]
Global $g_aPoints[0] ;Significant Points in game [[name, point], ...]
Global $g_aNezzPos[0] ;Nezz click positions for different village angles
Global $g_aImageLocations[0] ;Locations based upon image searches
Global $g_aAirshipPositions[0] ;Airship positions for detection of hidden trees and nezz
Global $g_aAirshipTrees[0] ;Airship hidden tree locations

Global $g_aScriptArgs = Null ;Arguments for running script.
Global $g_aLogSize[0] ;Log size info for when the log is detached
Global $g_vDebug = "" ;Extra information given after an execution of a select function.
Global $g_aData[0][3] ;Structure of the array is as follows:
Global $g_aOrder[0] ;Order of the array, based on name.
Global $g_aDpiSettings[0] ;Dpi settings for each monitor
Global $g_aStats[0] ;Stores the Cumulative stats.

Global $g_aComboMenu = Null ;Holds temporary context menus from combo type settings.
Global $g_aListEditor = Null ;Holds temporary gui and controls for list type settings.
Global $g_aLog[0][6] ;Stores the log structure
Global $g_aLOG_Function[1] = [0] ;Current function and level

Global $g_aConfigSettings[0]
Global $g_aDelaySettings[0]
Global $g_aGeneralSettings[0]
Global $g_aHourlySettings[0]
Global $g_aFilterSettings[0]
Global $g_aDragonFilterSettings[0]