Global $aVersion = [3, 3, 0] ;Major, Minor, Build

#AutoIt3Wrapper_UseX64=n
#include-once
#include "bin/_src/imports.au3"

HotKeySet("+!^q", "ForceQuit")
HotKeySet("+!^d", "Debug")
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
            MsgBox($MB_ICONERROR+$MB_OK, "Function call error", "Function for the script does not exist or does not meet parameter count: " & StringReplace($g_sScript, " ", "_"))
            Stop()
        EndIf
    EndIf
EndFunc

Func ForceQuit()
    Local $aWindows = WinList()

    Local $sBotsList = "" ;List of opened instances, used if more than one instance
    Local $iSize = 0 ;size of aBots
    Local $aBots[0][2]

    For $i = 0 To UBound($aWindows, $UBOUND_ROWS)-1
        If StringLeft($aWindows[$i][0], 9) = "MSL Bot v" Then
            $iSize = UBound($aBots, $UBOUND_ROWS)
            ReDim $aBots[$iSize+1][2]

            $aBots[$iSize][0] = $aWindows[$i][0]
            $aBots[$iSize][1] = $aWindows[$i][1]

            $sBotsList &= "[" & $iSize & "] " & $aWindows[$i][0] & " (" & $aWindows[$i][1] & ")" & @CRLF
        EndIf
    Next

    Local $iResult = 0
    If $iSize > 1 Then 
        Do 
            $iResult = InputBox("Multiple instances detected.", "Select which # bot to close: " & @CRLF & @CRLF & $sBotsList)
            If $iResult = "" Then Return
        Until ($iResult >= 0) And ($iResult <= $iSize)
    EndIf

    ProcessClose(WinGetProcess($aBots[$iResult][1]))
EndFunc

;calls for debug prompt
Func Debug()
    If $g_bRunning = False Then
        $g_sScript = "_Debug"
        $g_aScriptArgs = Null

        Start()
    EndIf
EndFunc

Func _Debug()
    ;Prompting for code
    Local $aLines = StringSplit(InputBox("Debug Input", "Enter an expression: " & @CRLF & "- Lines of expressions can be separated by '|' character.", default, default, default, 150), "|", $STR_NOCOUNT)

    addLog($g_aLog, "```Debug script has started.", $LOG_NORMAL)
    ;Process each line of code
    For $i = 0 To UBound($aLines, $UBOUND_ROWS)-1
        If $aLines[$i] = "" Then ContinueLoop
        Local $sResult = Execute($aLines[$i])
        If $sResult = "" Then $sResult = "N/A"

        If isArray($sResult) Then
            _ArrayDisplay($sResult)
            addLog($g_aLog, "{Array} <= " & $aLines[$i], $LOG_NORMAL)
        Else
            addLog($g_aLog, $sResult & " <= " & $aLines[$i], $LOG_NORMAL)
        EndIf
        
    Next

    ;Exit
    addLog($g_aLog, "Debug script has stopped.```")
    Stop()
EndFunc