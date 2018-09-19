#include <GUIListView.au3>
#include <WinAPIProc.au3>
#include <String.au3>
#RequireAdmin

;Global Variables
Global $g_bUpdating = True ;updating status
Global $sParentPath = Null

;Checking for all command line parameters before successfully running
Local Const $aRequired = ["hwnd", "list", "rdir", "ldir"]
If _checkCMDLine($CMDLine, $aRequired) = True Then
	Update(getParameter($CMDLine, "list"), getParameter($CMDLine, "rdir"), getParameter($CMDLine, "ldir"), getParameter($CMDLine, "hwnd"))
Else
	MsgBox(16, "MSL Bot Updater: Error", "Parameters invalid.")
EndIf

;Main Update function
Func Update($sRemoteFileListURL, $sRemoteDirURL, $sLocalDirPath, $hParentHandle = Null)
	If $hParentHandle <> Null Then
		$hParentHandle = Hwnd($hParentHandle)
		$sParentPath = _WinAPI_GetProcessFileName(WinGetProcess($hParentHandle)) & " " & _WinAPI_GetProcessCommandLine(WinGetProcess($hParentHandle))
		ProcessClose(WinGetProcess($hParentHandle))
	EndIf

	If Execute($sRemoteFileListURL) <> "" Then $sRemoteFileListURL = Execute($sRemoteFileListURL)
	If Execute($sRemoteDirURL) <> "" Then $sRemoteDirURL = Execute($sRemoteDirURL)
	If Execute($sLocalDirPath) <> "" Then $sLocalDirPath = Execute($sLocalDirPath)

	$sRemoteDirURL = StringReplace($sRemoteDirURL, "\", "/")
	$sLocalDirPath = StringReplace($sLocalDirPath, "/", "\")
	If StringRight($sRemoteDirURL, 1) <> "/" Then $sRemoteDirURL &= "/"
	If StringRight($sLocalDirPath, 1) <> "\" Then $sLocalDirPath &= "\"

	;GUI, events are in the _Sleep function
	Local $hWindow = GUICreate("MSL Bot Updater: Updating", 500, 200)
	Local $hListView = GUICtrlGetHandle(GUICtrlCreateListView("", 0, 0, 500, 200, $LVS_REPORT+$LVS_SINGLESEL+$LVS_NOSORTHEADER))
	_GUICtrlListView_AddColumn($hListView, "File", 350)
	_GUICtrlListView_AddColumn($hListView, "Size", 150)
	GUISetState(@SW_SHOW)

	;variables
	Local $aFiles = StringSplit(BinaryToString(InetRead($sRemoteFileListURL)), @CRLF, 2)

	#Region Process
		For $sFile In $aFiles
			$sFile = StringReplace($sFile, "/", "\")
			Switch StringLeft($sFile, 1)
				Case "!"
					$sFile = StringMid($sFile, 2)
				Case "?"
					$sFile = StringMid($sFile, 2)
					If FileExists($sLocalDirPath & $sFile) = False Then
						ContinueLoop
					EndIf
				Case "-"
					$sFile = StringMid($sFile, 2)
					FileDelete($sLocalDirPath & $sFile)
					ContinueLoop
				Case Else
					If FileExists($sLocalDirPath & $sFile) = True Then ContinueLoop
			EndSwitch

			If StringInStr($sFile, "\") = True Then
				;Create directory for file
				Local $sRemove = StringSplit($sFile, "\", 2)
				$sRemove = $sRemove[UBound($sRemove)-1]
				DirCreate($sLocalDirPath & StringReplace($sFile, $sRemove, ""))
			EndIf

			Local $hFile = InetGet($sRemoteDirURL & $sFile, $sLocalDirPath & $sFile, 1, 1)
			Local $iTries = 0

			_GUICtrlListView_InsertItem($hListView, $sFile, 0)
			While InetGetInfo($hFile, 3) = False
				If InetGetInfo($hFile, 4) <> 0 Then
					;Error occured
					InetClose($hFile)
					
					If FileExists($sLocalDirPath & $sFile) = True Then
						If FileRead($sLocalDirPath & $sFile) = "" Then
							_GUICtrlListView_SetItemText($hListView, 0, "Empty", 1)
							ContinueLoop(2)
						EndIf
					EndIf
					If $iTries <= 3 Then
						$iTries += 1
						_GUICtrlListView_SetItemText($hListView, 0, "Error, trying again (" & $iTries & ").", 1)
						_Sleep(3000)

						$hFile = InetGet($sRemoteDirURL & $sFile, $sLocalDirPath & $sFile, 1, 1)
					Else
						_GUICtrlListView_SetItemText($hListView, 0, "Error", 1)
						ContinueLoop(2)
					EndIf
				EndIf

				;updating listview control
				If InetGetInfo($hFile, 1) <> 0 Then
					_GUICtrlListView_SetItemText($hListView, 0, Round(InetGetInfo($hFile, 0)/1000) & "/" & Round(InetGetInfo($hFile, 0)/1000) & " KB", 1)
				Else
					_GUICtrlListView_SetItemText($hListView, 0, Round(InetGetInfo($hFile, 0)/1000) & " KB", 1)
				EndIf
				_Sleep(50)
			WEnd

			;final update
			If InetGetInfo($hFile, 1) <> 0 Then
				_GUICtrlListView_SetItemText($hListView, 0, Round(InetGetInfo($hFile, 0)/1000) & "/" & Round(InetGetInfo($hFile, 0)/1000) & " KB", 1)
			Else
				_GUICtrlListView_SetItemText($hListView, 0, Round(InetGetInfo($hFile, 0)/1000) & " KB", 1)
			EndIf

			InetClose($hFile)
		Next
	#EndRegion Process

	$g_bUpdating = False
	WinSetTitle($hWindow, "", "MSL Bot Updater: Complete")
	_Sleep(30000, 30, $hWindow)
	_Exit()
EndFunc

;---Functions---

Func _Exit()
	Local $aParameters = ["sd"]
	If _checkCMDLine($CMDLine, $aParameters) = True Then FileDelete(@ScriptFullPath) ;self-destruct
	Run($sParentPath)
	
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
