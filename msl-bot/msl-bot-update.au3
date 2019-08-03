#include <WinAPIProc.au3>
#include <String.au3>
#include <File.au3>
#RequireAdmin

;Global Variables
Global $g_bUpdating = True 
Global $g_iStatus = 0
Global $sParentPath = Null

;Checking for all command line parameters before successfully running
Local Const $aRequired = ["hwnd"]
Local Const $temp_release = "https://github.com/GkevinOD/msl-bot/archive/release.zip"
If _checkCMDLine($CMDLine, $aRequired) = True Then
	Update($temp_release, getParameter($CMDLine, "hwnd"))
Else
	MsgBox(16, "MSL Bot Updater: Error", "Parameters invalid.")
EndIf

;Main Update function
Func Update($sRemoteZIP, $hParentHandle)
	If $hParentHandle <> Null Then
		$hParentHandle = Hwnd($hParentHandle)
		$sParentPath = _WinAPI_GetProcessFileName(WinGetProcess($hParentHandle)) & " " & _WinAPI_GetProcessCommandLine(WinGetProcess($hParentHandle))
		ProcessClose(WinGetProcess($hParentHandle))
	EndIf

	;GUI, events are in the _Sleep function
	Local $hWindow = GUICreate("MSL Bot Updater: Updating", 500, 100)
	Local $hLabel = GUICtrlCreateLabel("Downloading zip file...", 0, 25, 500, 100, 0x01)
	GUICtrlSetFont($hLabel, 13, 700)
	Local $hProgress = GUICtrlCreateProgress(10, 50, 480, 25)
	GUISetState(@SW_SHOW)

	#Region Process
		Local $hFile = InetGet($sRemoteZIP, @ScriptDir & "\" & "msl-bot.zip", 1, 1)
		Local $iTries = 0

		While InetGetInfo($hFile, 3) = False
			If InetGetInfo($hFile, 4) <> 0 Then
				;Error occured
				InetClose($hFile)
				
				If $iTries <= 3 Then
					$iTries += 1
					GUICtrlSetData($hLabel, "Error, trying again (" & $iTries & ").")
					_Sleep(3000)

					$hFile = InetGet($sRemoteZIP, @ScriptDir & "\" & "msl-bot.zip", 1, 1)
				Else
					GUICtrlSetData($hLabel, "Error could not download zip file.")
					ExitLoop
				EndIf
			EndIf

			;updating listview control
			If InetGetInfo($hFile, 1) <> 0 Then
				GUICtrlSetData($hLabel, "Downloading msl-bot.zip: " & Round(InetGetInfo($hFile, 0)/1000) & "/" & Round(InetGetInfo($hFile, 1)/1000) & " KB")
				GUICtrlSetData($hProgress, 90*(Round(InetGetInfo($hFile, 0)/1000) / Round(InetGetInfo($hFile, 1)/1000)))
			Else
				GUICtrlSetData($hLabel, "Downloading msl-bot.zip: " & Round(InetGetInfo($hFile, 0)/1000) & " KB")
				GUICtrlSetData($hProgress, 90*(Round(InetGetInfo($hFile, 0)/1000) / 7300)) ;estimate
			EndIf
			_Sleep(200)
		WEnd

		;final update
		If InetGetInfo($hFile, 1) <> 0 Then
			GUICtrlSetData($hLabel, "Downloading msl-bot.zip: " & Round(InetGetInfo($hFile, 0)/1000) & "/" & Round(InetGetInfo($hFile, 1)/1000) & " KB")
		Else
			GUICtrlSetData($hLabel, "Downloading msl-bot.zip: " & Round(InetGetInfo($hFile, 0)/1000) & " KB")
		EndIf

		InetClose($hFile)
	#EndRegion Process

	$g_bUpdating = False
	WinSetTitle($hWindow, "", "MSL Bot Updater: Extracting")
	If FileExists(@ScriptDir & "\msl-bot.zip") = True Then
		GUICtrlSetData($hLabel, "Extracting zip file...")
		$g_iStatus = 1
		
		_ExtractZip(@ScriptDir & "\msl-bot.zip", "msl-bot-release\msl-bot", "README.txt", @ScriptDir)
		If _ExtractZip(@ScriptDir & "\msl-bot.zip", "msl-bot-release\msl-bot", "msl-bot.au3", @ScriptDir) = 0 Then $giStatus = 0
		If _ExtractZip(@ScriptDir & "\msl-bot.zip", "msl-bot-release\msl-bot", "bin", @ScriptDir) = 0 Then $giStatus = 0

		If $g_iStatus = 1 Then
			GUICtrlSetData($hLabel, "Updated successfully.")
			GUICtrlSetData($hProgress, 100)
		EndIf
	Else
		GUICtrlSetData($hLabel, "Failed to update.")
		MsgBox(48, "MSL Bot Update: Failed", "Failed to update." & @CRLF & "Update manually through the GitHub page.")
	EndIf

	WinSetTitle($hWindow, "", "MSL Bot Updater: Complete")
	_Sleep(30000, 30, $hWindow)
	_Exit()
EndFunc

;---Functions---

Func _Exit()
	Local $aParameters = ["sd"]
	If _checkCMDLine($CMDLine, $aParameters) = True Then 
		FileDelete(@ScriptDir & "\msl-bot.zip")
		FileDelete(@ScriptFullPath) ;self-destruct
	EndIf
	If $g_iStatus = 1 Then Run($sParentPath)
	
	Exit
EndFunc

Func _Sleep($iDuration, $iClose = -1, $hWindow = Null)
	Local $hTimer = TimerInit()
	While TimerDiff($hTimer) < $iDuration
		If $iClose <> -1 Then
			CloseIn($iClose, $hWindow)
		EndIf

        Switch GUIGetMsg()
            Case -3 ;event close
                If $g_bUpdating And MsgBox(48+4, "MSL Bot Updater: Exit", "Updater is still running, would you like to exit?") = 6 Then Exit
				If $g_bUpdating = False Then _Exit()
        EndSwitch
	WEnd
EndFunc

Func CloseIn($iClose = -1, $hWindow = Null)
	Local Static $iCloseIn = $iClose
	Local Static $hCloseTimer = TimerInit()
	Local Static $sTitle = WinGetTitle($hWindow)

	WinSetTitle($hWindow, "", $sTitle & " (" & $iCloseIn-Int(TimerDiff($hCloseTimer)/1000) & ")")
	If $iCloseIn-Int(TimerDiff($hCloseTimer)/1000) <= 0 Then _Exit()
EndFunc

;Checks if command line has all the parameters in required array
Func _checkCMDLine($aCL, $aRequired)
	Local $sParameters = ""

	For $sPar In $aCL
		If StringLeft($sPar, 1) = "-" Then
			$sParameters &= StringMid($sPar, 2) & ","
		EndIf
	Next

	For $sPar In $aRequired
		If StringInStr($sParameters, $sPar) = False Then Return False
	Next

	Return True
EndFunc

;Retrieves parameter value from command line
Func getParameter($aCL, $sParameter)
	For $i = 0 To UBound($aCL)-1
		If StringLeft($aCL[$i], 1) = "-" Then
			If StringMid($aCL[$i], 2) = $sParameter Then
				If $i+1 < UBound($aCL) Then
					If StringLeft($aCL[$i+1], 1) <> "-" Then
						Return $aCL[$i+1]
					Else
						Return -1
					EndIf
				Else
					Return -1
				EndIf
			EndIf
		EndIf
	Next

	Return -2
EndFunc

; #FUNCTION# ;===============================================================================
;
; Name...........: _ExtractZip
; Description ...: Extracts file/folder from ZIP compressed file
; Syntax.........: _ExtractZip($sZipFile, $sFolderStructure, $sFile, $sDestinationFolder)
; Parameters ....: $sZipFile - full path to the ZIP file to process
;                  $sFolderStructure - 'path' to the file/folder to extract inside ZIP file
;                  $sFile - file/folder to extract
;                  $sDestinationFolder - folder to extract to. Must exist.
; Return values .: Success - Returns 1
;                          - Sets @error to 0
;                  Failure - Returns 0 sets @error:
;                  |1 - Shell Object creation failure
;                  |2 - Destination folder is unavailable
;                  |3 - Structure within ZIP file is wrong
;                  |4 - Specified file/folder to extract not existing
; Author ........: trancexx
;
;==========================================================================================
Func _ExtractZip($sZipFile, $sFolderStructure, $sFile, $sDestinationFolder)

    Local $i
    Do
        $i += 1
        $sTempZipFolder = @TempDir & "\Temporary Directory " & $i & " for " & StringRegExpReplace($sZipFile, ".*\\", "")
    Until Not FileExists($sTempZipFolder) ; this folder will be created during extraction

    Local $oShell = ObjCreate("Shell.Application")

    If Not IsObj($oShell) Then
        Return SetError(1, 0, 0) ; highly unlikely but could happen
    EndIf

    Local $oDestinationFolder = $oShell.NameSpace($sDestinationFolder)
    If Not IsObj($oDestinationFolder) Then
        Return SetError(2, 0, 0) ; unavailable destionation location
    EndIf

    Local $oOriginFolder = $oShell.NameSpace($sZipFile & "\" & $sFolderStructure) ; FolderStructure is overstatement because of the available depth
    If Not IsObj($oOriginFolder) Then
        Return SetError(3, 0, 0) ; unavailable location
    EndIf

    ;Local $oOriginFile = $oOriginFolder.Items.Item($sFile)
    Local $oOriginFile = $oOriginFolder.ParseName($sFile)
    If Not IsObj($oOriginFile) Then
        Return SetError(4, 0, 0) ; no such file in ZIP file
    EndIf

    ; copy content of origin to destination
    $oDestinationFolder.CopyHere($oOriginFile, 20) ;https://docs.microsoft.com/en-us/previous-versions/windows/desktop/sidebar/system-shell-folder-copyhere

    DirRemove($sTempZipFolder, 1) ; clean temp dir

    Return 1 ; All OK!

EndFunc
