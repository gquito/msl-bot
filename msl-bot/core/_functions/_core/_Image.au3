#cs ----------------------------------------------------------------------------

 Function: findImage
 Using ImageSearch find an image within the HBMP

 Parameters:
	strImage - Image name without extension.
	intTolerance - Tolerance of the image to look for.
	duration - How long to keep checking for

 Returns:
	On image found - Returns array
	On image not found - Returns 0

 Author: GkevinOD (2017)

#ce ----------------------------------------------------------------------------

Func findImage($strImage, $intTolerance = 10, $duration = 100, $left = 0, $top = 0, $right = 800, $bottom = 600)
	If StringInStr($strImage, "-") Then ;image with specified folder
		$strImage = StringSplit($strImage, "-", 2)[0] & "\" & $strImage
	EndIf

	Local $arrayImages[0] ;images list to find

	If FileExists($strImageDir & $strImage & ".bmp") Then
		_ArrayAdd($arrayImages, $strImageDir & $strImage & ".bmp")

		Local $dupCounter = 2; Ex: location-village2...
		While FileExists($strImageDir & $strImage & $dupCounter & ".bmp")
			_ArrayAdd($arrayImages, $strImageDir & $strImage & $dupCounter & ".bmp")
			$dupCounter += 1
		WEnd
	EndIf

	Local $pointArray = [-1, -1]
	Local $tempSearch;

	Local $startTimer = TimerInit()
	While TimerDiff($startTimer) < $duration
		_CaptureRegion("", $left, $top, $right, $bottom)
		If _Sleep(100) Then Return 0

		$tempSearch = _ImagesSearch($arrayImages, 1, $pointArray[0], $pointArray[1], $intTolerance)

		If $tempSearch >= 0 Then
			Local $returnArray = [$pointArray[0]+$left, $pointArray[1]+$top, $tempSearch, StringReplace($arrayImages[$tempSearch], $strImageDir & StringSplit($strImage, "-", 2)[0] & "\", "")]
			Return $returnArray
		EndIf
	WEnd

	Return 0
EndFunc

#cs ----------------------------------------------------------------------------

 Function: findImages
 Using ImageSearch find images to show in a timespan.

 Parameters:
	strImages - Array of image name without extension.
	intTolerance - Tolerance of the image to look for.
	duration - How long to keep checking for

 Returns:
	On image found - Returns array
	On image not found - Returns 0

 Author: GkevinOD (2017)

#ce ----------------------------------------------------------------------------

Func findImages($strImages, $intTolerance = 10, $duration = 100, $left = 0, $top = 0, $right = 800, $bottom = 600)
	Local $arrayImages[0] ;images list to find

	If isArray($strImages) = False Then Return 0
	For $strImage In $strImages
		If StringInStr($strImage, "-") Then ;image with specified folder
			$strImage = StringSplit($strImage, "-", 2)[0] & "\" & $strImage
		EndIf

		If FileExists($strImageDir & $strImage & ".bmp") Then
			_ArrayAdd($arrayImages, $strImageDir & $strImage & ".bmp")

			Local $dupCounter = 2; Ex: location-village2...
			While FileExists($strImageDir & $strImage & $dupCounter & ".bmp")
				_ArrayAdd($arrayImages, $strImageDir & $strImage & $dupCounter & ".bmp")
				$dupCounter += 1
			WEnd
		EndIf
	Next

	Local $pointArray = [-1, -1]
	Local $tempSearch;

	Local $startTimer = TimerInit()
	While TimerDiff($startTimer) < $duration
		_CaptureRegion("", $left, $top, $right, $bottom)
		If _Sleep(100) Then Return 0

		$tempSearch = _ImagesSearch($arrayImages, 1, $pointArray[0], $pointArray[1], $intTolerance)

		If $tempSearch >= 0 Then
			Local $returnArray = [$pointArray[0]+$left, $pointArray[1]+$top, $tempSearch, StringReplace($arrayImages[$tempSearch], $strImageDir & StringSplit($strImage, "-", 2)[0] & "\", "")]
			Return $returnArray
		EndIf
	WEnd

	Return 0
EndFunc
