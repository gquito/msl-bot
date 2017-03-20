#include-once
; ------------------------------------------------------------------------------
;
; AutoIt Version: 3.0
; Language:       English
; Description:    Functions that assist with Image Search
;                 Require that the ImageSearchDLL.dll be loadable
;
; ------------------------------------------------------------------------------

;===============================================================================
;
; Description:      Find the position of an image on the desktop
; Syntax:           _ImageSearchArea, _ImageSearch
; Parameter(s):
;                   $findImage - the image file location or HBitmap to locate on the
;									desktop or in the Specified HBitmap
;                   $tolerance - 0 for no tolerance (0-255). Needed when colors of
;                                image differ from desktop. e.g GIF
;                   $resultPosition - Set where the returned x,y location of the image is.
;                                     1 for centre of image, 0 for top left of image
;                   $x $y - Return the x and y location of the image
;
;					$HBMP - optional hbitmap to search in. sending 0 will search the desktop.
;
; Return Value(s):  On Success - Returns 1
;                   On Failure - Returns 0
;
; Note: Use _ImageSearch to search the entire desktop, _ImageSearchArea to specify
;       a desktop region to search
;
;===============================================================================
Func _ImageSearch($findImage, $resultPosition, ByRef $x, ByRef $y, $tolerance = 30, $HBMP = $hHBitmap)
	Return _ImageSearchArea($findImage, $resultPosition, 0, 0, 800, 600, $x, $y, $tolerance, $HBMP)
EndFunc   ;==>_ImageSearch

Func _ImageSearchArea($findImage, $resultPosition, $x1, $y1, $right, $bottom, ByRef $x, ByRef $y, $tolerance, $HBMP = 0)
	;MsgBox(0,"asd","" & $x1 & " " & $y1 & " " & $right & " " & $bottom)

	If IsString($findImage) Then
		If $tolerance > 0 Then $findImage = "*" & $tolerance & " " & $findImage
		If $HBMP = 0 Then
			$result = DllCall($strImageSearchDir, "str", "ImageSearch", "int", $x1, "int", $y1, "int", $right, "int", $bottom, "str", $findImage)
		Else
			$result = DllCall($strImageSearchDir, "str", "ImageSearchEx", "int", $x1, "int", $y1, "int", $right, "int", $bottom, "str", $findImage, "ptr", $HBMP)
		EndIf
	Else
		$result = DllCall($strImageSearchDir, "str", "ImageSearchExt", "int", $x1, "int", $y1, "int", $right, "int", $bottom, "int", $tolerance, "ptr", $findImage, "ptr", $HBMP)
	EndIf

	; If error exit
	If $result[0] = "0" Then Return 0

	; Otherwise get the x,y location of the match and the size of the image to
	; compute the centre of search
	$array = StringSplit($result[0], "|")

	$x = Int(Number($array[2]))
	$y = Int(Number($array[3]))
	If $resultPosition = 1 Then
		$x = $x + Int(Number($array[4]) / 2)
		$y = $y + Int(Number($array[5]) / 2)
	EndIf
	Return 1
EndFunc   ;==>_ImageSearchArea

;===============================================================================
;
; Description:      Find one of the images from a set of images on the screen
;
; Syntax:           _ImagesSearch
; Parameter(s):
;                   $findImage - the ARRAY of images to locate on the desktop
;                   $tolerance - 0 for no tolerance (0-255). Needed when colors of
;                                image differ from desktop. e.g GIF
;                   $resultPosition - Set where the returned x,y location of the image is.
;                                     1 for centre of image, 0 for top left of image
;                   $x $y - Return the x and y location of the image
;
; Return Value(s):  On Success - Returns the index of the successful find
;                   On Failure - Returns -1
;
;
;===============================================================================
Func _ImagesSearch($findImage, $resultPosition, ByRef $x, ByRef $y, $tolerance = 30, $HBMP = $hHBitmap)
	For $i = 0 To UBound($findImage)-1
		$result = _ImageSearch($findImage[$i], $resultPosition, $x, $y, $tolerance, $HBMP)
		If $result > 0 Then
			Return $i
		EndIf
	Next
	Return -1
EndFunc   ;==>_WaitForImagesSearch


;===============================================================================
;
; Description:      Wait for a specified number of seconds for an image to appear
;
; Syntax:           _WaitForImageSearch, _WaitForImagesSearch
; Parameter(s):
;					$waitSecs  - seconds to try and find the image
;                   $findImage - the image to locate on the desktop
;                   $tolerance - 0 for no tolerance (0-255). Needed when colors of
;                                image differ from desktop. e.g GIF
;                   $resultPosition - Set where the returned x,y location of the image is.
;                                     1 for centre of image, 0 for top left of image
;                   $x $y - Return the x and y location of the image
;
; Return Value(s):  On Success - Returns 1
;                   On Failure - Returns 0
;
;
;===============================================================================
Func _WaitForImageSearch($findImage, $waitSecs, $resultPosition, ByRef $x, ByRef $y, $tolerance = 30, $HBMP = $hHBitmap)
	$waitSecs = $waitSecs * 1000
	$startTime = TimerInit()
	While TimerDiff($startTime) < $waitSecs
		If _Sleep(100) Then Return
		_CaptureRegion()
		$HBMP = $hHBitmap
		$result = _ImageSearch($findImage, $resultPosition, $x, $y, $tolerance, $HBMP)
		If $result > 0 Then
			Return 1
		EndIf
	WEnd
	Return 0
EndFunc   ;==>_WaitForImageSearch

;===============================================================================
;
; Description:      Wait for a specified number of seconds for any of a set of
;                   images to appear
;
; Syntax:           _WaitForImagesSearch
; Parameter(s):
;					$waitSecs  - seconds to try and find the image
;                   $findImage - the ARRAY of images to locate on the desktop
;                   $tolerance - 0 for no tolerance (0-255). Needed when colors of
;                                image differ from desktop. e.g GIF
;                   $resultPosition - Set where the returned x,y location of the image is.
;                                     1 for centre of image, 0 for top left of image
;                   $x $y - Return the x and y location of the image
;
; Return Value(s):  On Success - Returns the index of the successful find
;                   On Failure - Returns -1
;
;
;===============================================================================
Func _WaitForImagesSearch($findImage, $waitSecs, $resultPosition, ByRef $x, ByRef $y, $tolerance = 30, $HBMP = $hHBitmap)
	$waitSecs = $waitSecs * 1000
	$startTime = TimerInit()
	While TimerDiff($startTime) < $waitSecs
		For $i = 0 To UBound($findImage)-1
			If _Sleep(100) Then Return
			_CaptureRegion()
			$HBMP = $hHBitmap
			$result = _ImageSearch($findImage[$i], $resultPosition, $x, $y, $tolerance, $HBMP)
			If $result > 0 Then
				Return $i
			EndIf
		Next
	WEnd
	Return -1
EndFunc   ;==>_WaitForImagesSearch

