#cs ----------------------------------------------------------------------------

 Function: findImage

 Using ImageSearch find an image within the HBMP

 Parameters:

	strImage - Image name without extension.

	intTolerance - Tolerance of the image to look for.

 Returns:

	On image found - Returns array

	On image not found - Returns 0

 See Also:

	<findImages>

	<findImageWait>

	<findImagesWait>

#ce ----------------------------------------------------------------------------

Func findImage($strImage, $intTolerance = 10)
	If StringInStr($strImage, "-") Then ;image with specified folder
		$strImage = StringSplit($strImage, "-", 2)[0] & "\" & $strImage
	EndIf

	Local $pointArray = [-1, -1]
	Local $tempSearch = _ImageSearch($strImageDir & StringLower($strImage) & ".bmp", 1, $pointArray[0], $pointArray[1], $intTolerance)

	If $pointArray[0] = -1 Then Return 0

	If $tempSearch = 1 Then
		Return $pointArray
	Else
		Return 0
	EndIf
EndFunc

#cs ----------------------------------------------------------------------------

 Function: findImages

 Using ImageSearch find images to show in a timespan.

 Parameters:

	strImages - Array of image name without extension.

	intTolerance - Tolerance of the image to look for.

 Returns:

	On image found - Returns array

	On image not found - Returns 0

 See Also:

	<findImageWait>

	<findImagesWait>

	<findImage>

#ce ----------------------------------------------------------------------------

Func findImages($strImages, $intTolerance = 10)
	Local $arrayImages[UBound($strImages)]

	For $i = 0 To UBound($strImages)-1
		Dim $strTemp = ""
		If StringInStr($strImages[$i], "-") Then ;image with specified folder
			$strTemp = StringSplit($strImages[$i], "-", 2)[0] & "\" & $strImages[$i]
		EndIf
		$arrayImages[$i] = $strImageDir & StringLower($strTemp) & ".bmp"
	Next

	Local $pointArray = [-1, -1]
	Local $tempSearch = _ImagesSearch($arrayImages, 1, $pointArray[0], $pointArray[1], $intTolerance)

	If $pointArray[0] = -1 Then Return 0

	If $tempSearch >= 0 Then
		Local $returnArray = [$pointArray[0], $pointArray[1], $tempSearch]
		Return $returnArray
	Else
		Return 0
	EndIf
EndFunc

#cs ----------------------------------------------------------------------------

 Function: findImageFiles

 Using ImageSearch find images of files that contains 1 or more sets

 Parameters:

	strImage - Image of the first file without number. Ex: location-village -> This would also look for location-village2..

	intTolerance - Tolerance of the image to look for.

 Returns:

	On image found - Returns array

	On image not found - Returns 0

 See Also:

	<findImageWait>

	<findImagesWait>

	<findImage>

#ce ----------------------------------------------------------------------------

Func findImageFiles($strImage, $intTolerance = 10)
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
	Local $tempSearch = _ImagesSearch($arrayImages, 1, $pointArray[0], $pointArray[1], $intTolerance)

	If $pointArray[0] = -1 Then Return 0

	If $tempSearch >= 0 Then
		Local $returnArray = [$pointArray[0], $pointArray[1], $tempSearch]
		Return $returnArray
	Else
		Return 0
	EndIf
EndFunc

#cs ----------------------------------------------------------------------------

 Function: findImageWait

 Using ImageSearch wait for image to show in a timespan.

 Parameters:

	strImage - Image name without extension.

	intDuration - Duration of time to wait for image.

	intTolerance - Tolerance of the image to look for.

 Returns:

	On image found - Returns array

	On image not found - Returns 0

 See Also:

	<findImage>

	<findImages>

	<findImagesWait>

#ce ----------------------------------------------------------------------------

Func findImageWait($strImage, $intDuration = 5, $intTolerance = 10)
	If StringInStr($strImage, "-") Then ;image with specified folder
		$strImage = StringSplit($strImage, "-", 2)[0] & "\" & $strImage
	EndIf

	Local $pointArray = [-1, -1]
	Local $tempSearch = _WaitForImageSearch($strImageDir & StringLower($strImage) & ".bmp", $intDuration, 1, $pointArray[0], $pointArray[1], $intTolerance)

	If $pointArray[0] = -1 Then Return 0

	If $tempSearch = 1 Then
		Return $pointArray
	Else
		Return 0
	EndIf
EndFunc

#cs ----------------------------------------------------------------------------

 Function: findImagesWait

 Using ImageSearch wait for images to show in a timespan.

 Parameters:

	strImages - Array of image name without extension.

	intDuration - Duration of time to wait for image.

	intTolerance - Tolerance of the image to look for.

 Returns:

	On image found - Returns array

	On image not found - Returns 0

 See Also:

	<findImageWait>

	<findImage>

	<findImages>

#ce ----------------------------------------------------------------------------

Func findImagesWait($strImages, $intDuration = 5, $intTolerance = 10)
	Local $arrayImages[UBound($strImages)]

	For $i = 0 To UBound($strImages)-1
		Dim $strTemp = ""
		If StringInStr($strImages[$i], "-") Then ;image with specified folder
			$strTemp = StringSplit($strImages[$i], "-", 2)[0] & "\" & $strImages[$i]
		EndIf
		$arrayImages[$i] = $strImageDir & StringLower($strTemp) & ".bmp"
	Next

	Local $pointArray = [-1, -1]
	Local $tempSearch = _WaitForImagesSearch($arrayImages, $intDuration, 1, $pointArray[0], $pointArray[1], $intTolerance)

	If $pointArray[0] = -1 Then Return 0

	If $tempSearch >= 0 Then
		Local $returnArray = [$pointArray[0], $pointArray[1], $tempSearch]
		Return $returnArray
	Else
		Return 0
	EndIf
EndFunc
