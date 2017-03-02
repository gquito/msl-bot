;required imports
#include <Date.au3>
#include <File.au3>
#include <WinAPI.au3>
#include <WinAPIProc.au3>
#include <ScreenCapture.au3>
#include <GDIPlus.au3>
#include <Array.au3>
#include <FileConstants.au3>
#include <MsgBoxConstants.au3>
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <TabConstants.au3>
#include <WindowsConstants.au3>
#include <WinAPIGdi.au3>
#include <Color.au3>
#include <Math.au3>
#include <GuiEdit.au3>
#include <String.au3>

;global variables
#include "global.au3"

;_functions
	#include "_functions/getLocation.au3"
	#include "_functions/navigate.au3"
	#include "_functions/waitLocation.au3"
	#include "_functions/checkLocations.au3"

	;_core
		;imagesearch
			#include "_functions/_core/imagesearch/ImageSearch.au3"

		#include "_functions/_core/_CaptureRegion.au3"
		#include "_functions/_core/_Click.au3"
		#include "_functions/_core/_Image.au3"
		#include "_functions/_core/_Pixel.au3"
		#include "_functions/_core/_Sleep.au3"
		#include "_functions/_core/setLog.au3"

	;battle
		#include "_functions/battle/catch.au3"
		#include "_functions/battle/sellGem.au3"
		#include "_functions/battle/recordGem.au3"

	;map
		#include "_functions/map/enterStage.au3"

	;village
		#include "_functions/village/sellGems.au3"
		#include "_functions/village/getHourly.au3"