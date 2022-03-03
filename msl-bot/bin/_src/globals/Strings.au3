#include-once

Global $g_sAppTitle
$g_sAppTitle = "MSL Bot v" & $aVersion[0] & "." & $aVersion[1] & "." & $aVersion[2] ;Bot app title
If UBound($aVersion) > 3 Then
    $g_sAppTitle &= "." & $aVersion[3]
EndIf

Global $g_sErrorMessage = "" ;Message when functions calls error code.
Global $g_sScript = "" ;Current name of the running script.

Global $g_sImageSearchPath = @ScriptDir & "\bin\dll\ImageSearchLibrary.dll" ;ImageSearchDLL default path
Global $g_sImagesPath = @ScriptDir & "\bin\images\" ;Path to images

Global $g_sOldTime = ""
Global $g_sLocation = "" ;Global current location. Used for antiStuck
Global $Location = "" ;For status
Global $g_sLogFilter = "Information,Error,Process" ;Log filter

Global $g_sStatus = "" ;Saves old status to prevent spam. Used in Status() function in /handlers/Stats.au3