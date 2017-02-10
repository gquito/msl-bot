#include "core/imports.au3"

Opt("GUIOnEventMode", 1)
#Region ### START Koda GUI section ### Form=
Global $frmMain = GUICreate("MSL Bot v1.0.0", 286, 300, 392, 427, -1, BitOR($WS_EX_TOPMOST,$WS_EX_WINDOWEDGE))
GUISetOnEvent($GUI_EVENT_CLOSE, "frmMainClose")
GUISetOnEvent($GUI_EVENT_MINIMIZE, "frmMainMinimize")
GUISetOnEvent($GUI_EVENT_MAXIMIZE, "frmMainMaximize")
GUISetOnEvent($GUI_EVENT_RESTORE, "frmMainRestore")
Global $textOutput = GUICtrlCreateEdit("", 0, 185, 284, 113)
GUICtrlSetData(-1, "* Welcome to MSL Bot v1.0.0 *")
GUICtrlSetOnEvent(-1, "textOutputChange")
Global $Tab1 = GUICtrlCreateTab(0, 0, 284, 161)
Global $TabSheet1 = GUICtrlCreateTabItem("Scripts")
Global $btnLoad = GUICtrlCreateButton("Load:", 4, 28, 43, 25, $BS_CENTER)
GUICtrlSetFont(-1, 8, 400, 0, "Arial")
GUICtrlSetOnEvent(-1, "btnLoadClick")
Global $listScript = GUICtrlCreateList("", 4, 53, 276, 104)
GUICtrlSetData(-1, "")
GUICtrlSetFont(-1, 8, 400, 0, "Arial")
Global $btnEdit = GUICtrlCreateButton("Edit", 228, 29, 43, 25)
GUICtrlSetFont(-1, 8, 400, 0, "Arial")
GUICtrlSetOnEvent(-1, "btnEditClick")
Global $lblScript = GUICtrlCreateLabel("No Script Selected.", 52, 34, 96, 17)
GUICtrlSetFont(-1, 8, 400, 0, "Arial")
Global $TabSheet2 = GUICtrlCreateTabItem("Config")
Global $Group1 = GUICtrlCreateGroup("config.ini", 4, 21, 265, 129)
GUICtrlSetFont(-1, 8, 400, 0, "Arial")
Global $chkOutput = GUICtrlCreateCheckbox("Output All Process", 16, 68, 113, 17)
GUICtrlSetOnEvent(-1, "chkOutputClick")
Global $chkBackground = GUICtrlCreateCheckbox("Background Mode", 16, 44, 105, 17)
GUICtrlSetOnEvent(-1, "chkBackgroundClick")
Global $btnAdjust = GUICtrlCreateButton("Adjust Bot...", 172, 117, 91, 25)
GUICtrlSetOnEvent(-1, "btnAdjustClick")
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $TabSheet3 = GUICtrlCreateTabItem("Debug")
Global $chkDebugLocation = GUICtrlCreateCheckbox("Location: *Unknown*", 4, 29, 265, 17)
GUICtrlSetFont(-1, 8, 400, 0, "Arial")
GUICtrlSetOnEvent(-1, "chkDebugLocationClick")
Global $chkDebugFindImage = GUICtrlCreateCheckbox("Find Image:", 4, 53, 73, 17)
GUICtrlSetFont(-1, 8, 400, 0, "Arial")
GUICtrlSetOnEvent(-1, "chkDebugFindImageClick")
Global $lblDebugImage = GUICtrlCreateLabel("Found: false", 204, 53, 62, 17)
GUICtrlSetFont(-1, 8, 400, 0, "Arial")
GUICtrlSetOnEvent(-1, "lblDebugImageClick")
Global $textDebugImage = GUICtrlCreateInput("", 84, 51, 113, 22)
GUICtrlSetFont(-1, 8, 400, 0, "Arial")
Global $btnDebugTestCode = GUICtrlCreateButton("Test Code:", 4, 77, 59, 25)
GUICtrlSetFont(-1, 8, 400, 0, "Arial")
GUICtrlSetOnEvent(-1, "btnDebugTestCodeClick")
Global $textDebugTestCode = GUICtrlCreateInput("", 68, 79, 201, 22)
GUICtrlSetFont(-1, 8, 400, 0, "Arial")
GUICtrlCreateTabItem("")
Global $btnRun = GUICtrlCreateButton("Start", 8, 160, 75, 25)
GUICtrlSetOnEvent(-1, "btnRunClick")
Global $btnClear = GUICtrlCreateButton("Clear", 200, 160, 75, 25)
GUICtrlSetOnEvent(-1, "btnClearClick")
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

While 1
	Sleep(100)
WEnd

Func btnClearClick()

EndFunc
Func btnDebugTestCodeClick()

EndFunc
Func btnEditClick()

EndFunc
Func btnLoadClick()

EndFunc
Func btnRunClick()

EndFunc
Func btnAdjustClick()

EndFunc
Func chkBackgroundClick()

EndFunc
Func chkDebugFindImageClick()

EndFunc
Func chkDebugLocationClick()

EndFunc
Func chkOutputClick()

EndFunc
Func frmMainClose()
	Exit 0
EndFunc
Func lblDebugImageClick()

EndFunc
Func lblScriptClick()

EndFunc
Func listScriptClick()

EndFunc
