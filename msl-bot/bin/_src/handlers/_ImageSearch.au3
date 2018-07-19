#include-once
#include "../imports.au3"

; == FUNCTION LIST:
;   _ImageSearch()
;   _ImagesSearch()
;   _ImageSearchMultiple()
; ==

;Uses FindImage function from ImageSearchLibrary.dll to find a single image.
;
;   Parameters:
;       - $sImage: Full path to template image.
;       - $iTolerance: 0-100% matching.
;       - $iLeft, $iTop, $iWidth, $iHeight: Dimensions of the source image.
;       - $bCenter: Returns center of found image. Otherwise, returns left-top of location.
;       - $bUpdateBMP: Updates source image. When false, uses $g_hHBitmap for source image.
;       - $sSourcePath: Path to source image.
;       - $bUseColor: Default uses a single channel. This option enables comparison for color channels.
;   Return:
;       On success, Point Array if found, 0 if not found.
;       On error, <0 values..
;   Error Codes:
;       -1: Template image does not exist.
;       -2: ImageSearch Library could not be accessed.
;       -3: DllCall error.
;       -4: ImageSearch function did not work.
Func _ImageSearch($sImage, $iTolerance = 95, $iLeft = 0, $iTop = 0, $iWidth = 800, $iHeight = 552, $bCenter = True, $bUpdateBMP = True, $sSourcePath = "", $bUseColor = False)
	;SourcePath: \bin\images\temp\currentCapture.bmp
	;Log_Add("ImageSearch Attempt: Tolerance:" & $iTolerance & "|Path:" & $sImage & "|" & $iLeft & "," & $iTop & "," & $iWidth & "," & $iHeight, $LOG_DEBUG)

	;For compatibility
	$iLeft = Number($iLeft)
	$iTop = Number($iTop)
	$iWidth = Number($iWidth)
	$iHeight = Number($iHeight)
	$iTolerance = Number($iTolerance)

	;== Precoditions ==
	If FileExists($sImage) = False Then
		Log_Add("Imagesearch Error: '" & $sImage & "' does not exist.", $LOG_ERROR)
		Return -1
	EndIf

	;== Update bitmap ==
	If $sSourcePath = "" Then
		;Use HBITMAP
		If $bUpdateBMP = True Then captureRegion("", $iLeft, $iTop, $iWidth, $iHeight)
	Else
		;Use string path to source image file.
		If $bUpdateBMP = True Then
			captureRegion($sSourcePath, $iLeft, $iTop, $iWidth, $iHeight)
		Else
			saveHBitmap($sSourcePath)
		EndIf
	EndIf

	;== ImageSearch ==
	Local $hImageSearch = DllOpen($g_sImageSearchPath)
	If $hImageSearch = -1 Then
		Log_Add("Imagesearch Error: Could not open ImageSearch library.", $LOG_ERROR)
		Return -2
	EndIf

	Local $aResult ;Raw results
	If $sSourcePath = "" Then
		$aResult = DllCall($hImageSearch, "wstr:cdecl", "FindImageEX", "handle", $g_hHBitmap, "int", $iWidth, "int", $iHeight, "str", $sImage, "int", $iTolerance, "bool", Not ($bUseColor), "bool", False)
	Else
		$aResult = DllCall($hImageSearch, "wstr:cdecl", "FindImage", "str", @ScriptDir & $sSourcePath, "str", $sImage, "int", $iTolerance, "bool", Not ($bUseColor), "bool", False)
	EndIf
	DllClose($hImageSearch)

	If @error <> 0 Then
		Log_Add("Imagesearch Error: DllCall Error code " & @error & ".", $LOG_ERROR)
		Return -3
	EndIf

	; == Parsing result ==
	If IsArray($aResult) = False Then
		Log_Add("Imagesearch Error: ImageSearch did not work.", $LOG_ERROR)
		Return -4
	Else
		$aResult = StringSplit($aResult[0], "|", $STR_NOCOUNT) ;Converts to actual result
		;result, width, height, x, y, tolerance_found
		If $aResult[0] = "0" Or $aResult[0] = "" Then
			;Not found.
			Return 0
		Else
			Local $aPoint[2] = [Number($aResult[3]) + $iLeft, Number($aResult[4]) + $iTop] ;Found point

			If $bCenter = True Then
				$aPoint[0] = $aPoint[0] + Int($aResult[1] / 2)
				$aPoint[1] = $aPoint[1] + Int($aResult[2] / 2)
			EndIf
			Log_Add("Image found at (" & $aPoint[0] & ", " & $aPoint[1] & ") -> " & $sImage, $LOG_DEBUG)
			Return $aPoint
		EndIf
	EndIf
EndFunc   ;==>_ImageSearch

;Image search for multiple images. See _ImageSearch for more detail.
;   Parameters:
;       - $aImages: String array of full paths of each image.
;       - $iIndex: Output for found image index in $aImages.
Func _ImagesSearch($aImages, ByRef $iIndex, $iTolerance = 95, $iLeft = 0, $iTop = 0, $iWidth = 800, $iHeight = 552, $bCenter = True, $bUpdateBMP = True, $sSourcePath = "", $bUseColor = False)
	If IsArray($aImages) = False Then
		Log_Add("ImagesSearch Error: aImages parameter is not an array.", $LOG_ERROR)
		Return -1
	Else
		For $i = 0 To UBound($aImages) - 1
			$vResult = _ImageSearch($aImages[$i], $iTolerance, $iLeft, $iTop, $iWidth, $iHeight, $bCenter, $bUpdateBMP, $sSourcePath, $bUseColor)
			If IsArray($vResult) = True Then
				$iIndex = $i
				Return $vResult ;Point array.
			Else
				If $vResult < 0 Then Return $vResult
			EndIf

			$bUpdateBMP = False ;Update only once
		Next

		Return 0
	EndIf
EndFunc   ;==>_ImagesSearch

;Uses FindImageMultiple function from ImageSearchLibrary.dll to find multiple instances of a single image.
;   See _ImageSearch for more details.
;   Return:
;       On success, 2D array for point list, 0 if not found.
;   Note: Count will be stored in $g_vExtended after function call.
Func _ImageSearchMultiple($sImage, $iTolerance = 95, $iLeft = 0, $iTop = 0, $iWidth = 800, $iHeight = 552, $bCenter = True, $bUpdateBMP = True, $sSourcePath = "", $bUseColor = False)
	;SourcePath: \bin\images\temp\currentCapture.bmp
	;Log_Add("ImageSearch Attempt: Tolerance:" & $iTolerance & "|Path:" & $sImage, $LOG_DEBUG)

	;For compatibility
	$iLeft = Number($iLeft)
	$iTop = Number($iTop)
	$iWidth = Number($iWidth)
	$iHeight = Number($iHeight)
	$iTolerance = Number($iTolerance)

	;== Precoditions ==
	If FileExists($sImage) = False Then
		Log_Add("Imagesearch Error: '" & $sImage & "' does not exist.", $LOG_ERROR)
		Return -1
	EndIf

	;== Update bitmap ==
	If $sSourcePath = "" Then
		;Use HBITMAP
		If $bUpdateBMP = True Then captureRegion("", $iLeft, $iTop, $iWidth, $iHeight)
	Else
		;Use string path to source image file.
		If $bUpdateBMP = True Then
			captureRegion($sSourcePath, $iLeft, $iTop, $iWidth, $iHeight)
		Else
			saveHBitmap($sSourcePath)
		EndIf
	EndIf

	;== ImageSearch ==
	Local $hImageSearch = DllOpen($g_sImageSearchPath)
	If $hImageSearch = -1 Then
		Log_Add("Imagesearch Error: Could not open ImageSearch library.", $LOG_ERROR)
		Return -2
	EndIf

	Local $aResult ;Raw results
	If $sSourcePath = "" Then
		$aResult = DllCall($hImageSearch, "wstr:cdecl", "FindImageEX", "handle", $g_hHBitmap, "int", $iWidth, "int", $iHeight, "str", $sImage, "int", $iTolerance, "bool", True, "bool", Not ($bUseColor))
	Else
		$aResult = DllCall($hImageSearch, "wstr:cdecl", "FindImage", "str", @ScriptDir & $sSourcePath, "str", $sImage, "int", $iTolerance, "bool", True, "bool", Not ($bUseColor))
	EndIf
	DllClose($hImageSearch)

	If @error <> 0 Then
		Log_Add("Imagesearch Error: DllCall Error code " & @error & ".", $LOG_ERROR)
		Return -3
	EndIf

	; == Parsing result ==
	If IsArray($aResult) = False Then
		Log_Add("Imagesearch Error: ImageSearch did not work.", $LOG_ERROR)
		Return -4
	Else
		$aResult = StringSplit($aResult[0], "|", $STR_NOCOUNT) ;Converts to actual result
		If $aResult[0] = "0" Or $aResult[0] = "" Then
			;Not found.
			Return 0
		Else
			; count, width, height, x1, y1, tolerance_found1, x2, y2, tolerance_found2...
			Local $iCount = $aResult[0]
			Local $aTemplateSize = [$aResult[1], $aResult[2]]

			$g_vExtended = $iCount ;Extended info count.

			Local $aPoints[$iCount][2]
			Local $tempCount = 0 ;For $aPoints

			For $i = 3 To UBound($aResult) - 1 Step 3
				$aPoints[$tempCount][0] = Number($aResult[$i]) + $iLeft
				$aPoints[$tempCount][1] = Number($aResult[$i + 1]) + $iTop

				If $bCenter = True Then
					$aPoints[$tempCount][0] = $aPoints[$tempCount][0] + Int($aTemplateSize[0] / 2)
					$aPoints[$tempCount][1] = $aPoints[$tempCount][1] + Int($aTemplateSize[1] / 2)
				EndIf

				Log_Add("Image found at (" & $aPoints[$tempCount][0] & ", " & $aPoints[$tempCount][1] & ") -> " & $sImage, $LOG_DEBUG)
				$tempCount += 1

				;=DEBUG=
				;clickPoint($aPoints[$tempCount-1][0] & "," & $aPoints[$tempCount-1][1], 1, 0, NULL, $MOUSE_REAL)
				;If _Sleep(1000) Then ExitLoop
				;=======
			Next

			Return $aPoints
		EndIf
	EndIf
EndFunc   ;==>_ImageSearchMultiple
