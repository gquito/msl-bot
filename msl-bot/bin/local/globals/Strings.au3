#include-once
#include "../../_src/global.au3"

Global $g_sAppTitle
if (Ubound($aVersion) <=4) Then
    $g_sAppTitle = "MSL Bot v" & $aVersion[0] & "." & $aVersion[1] & "." & $aVersion[2] ;Bot app title
    ;If ($aVersion[3] <> 0) Then $g_sAppTitle &= "." & $aVersion[3]; & " BETA"
Else
    ;$g_sAppTitle = "MSL Bot v" & $aVersion[0] & "." & $aVersion[1] & "." & $aVersion[2] & "b" & $aVersion[3] & "r" & $aVersion[4] ;Bot beta app title
EndIf

Global $g_sErrorMessage = "" ;Message when functions calls error code.
Global $g_sScript = "" ;Current name of the running script.
Global $g_sEvent = Null
Global $g_sControlID = Null

Global $g_sImageSearchPath = @ScriptDir & "\bin\dll\ImageSearchLibrary.dll" ;ImageSearchDLL default path
Global $g_sImagesPath = @ScriptDir & "\bin\images\" ;Path to images

Global $g_sProfileName = $d_sProfile ;Current Profile Name
Global $g_sProfilePath = $d_sProfilePath ;Path to current seleted profile
Global $g_sProfileImagePath = $d_sProfilePath & "images\"
Global $g_sProfileImageErrorPath = $g_sProfileImagePath & "Error\"
Global $g_sAdbDevice = $d_sAdbDevice ;Android debug bridge device name. Default is 127.0.0.1:62001 for nox
Global $g_sAdbPath = $d_sAdbPath ;Android adb executable. Default for nox
Global $g_sAdbMethod = $d_sAdbMethod ;Method to send clicks and keypresses to the ADB.
Global $g_sEmuSharedFolder[2] = [$d_sEmuSharedFolder[0], $d_sEmuSharedFolder[1]] ;Folder shared between emulator and computer. Default for nox

Global $g_sWindowTitle = "NoxPlayer" ;Emulator window title.
Global $g_sControlInstance = "[CLASS:subWin; INSTANCE:1]" ;OPENGL/DIRECTX Control instance.
Global $g_sScheduledRestartMode = "Never" ;Number of minutes until bot app decides to restart from logged out.

Global $g_sOldTime = ""

Global $g_sLocation = "" ;Global current location. Used for antiStuck

Global $g_sLogFilter = "Information,Error,Process" ;Log filter

Global $g_sADBEvent = Null