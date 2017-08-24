;function: checkPixel
;-Takes a coordinate and compares that pixel with a specified pixel
;parameters:
;-pixel: An array [x, y, color] or a string "x,y,color"
;returns: boolean
;author: GkevinOD (2017)

Func checkPixel($pixel, $intVariation = 10)
	If $pixel = "" Then Return False
	If Not(isArray($pixel)) Then ;if in text form
		$pixel = StringSplit($pixel, ",", 2)
	EndIf

	Return _ColorCheckVariation("0x" & Hex(_GDIPlus_BitmapGetPixel($hBitmap, $pixel[0], $pixel[1]), 6), "0x" & Hex($pixel[2], 6), $intVariation)
EndFunc

;function: checkPixels
;-Takes an array of pixels and compares it with hBitmap
;parameters:
;-pixels: An array of pixels [[x, y, color], [x, y, color]] or an array of string ["x,y,color", "x,y,color"]
;-intVariation: Variation threshold between pixels
;returns: boolean
;author: GkevinOD (2017)

Func checkPixels($pixels, $intVariation = 10)
	Local $result = True

	$pixels = StringSplit($pixels, "/", 2)
	For $pixelList In $pixels
		$result = True

		$pixelList = StringSplit($pixelList, "|", 2)
		For $pixel In $pixelList

			$result = True
			If checkPixel($pixel, $intVariation) = False Then
				$result = False
				ExitLoop
			EndIf
		Next

		If $result = True Then Return True
	Next

	Return False
EndFunc


#cs ----------------------------------------------------------------------------

 Function: findColor

 Checks if pixel is what is specified in an area

 Parameters:
	x1 - Left x-position.
	x2 - Right x-position.
	y1 - Left y-position.
	y2 - Right y-position.
	intVariation - Variation limit.
	skipx - Number of pixels to skip at a time on the x axis.
	skipy - Number of pixels to skip at a time on the y axis.

 Returns:
	Color found - Return point array

	Not Found - Return 0

#ce ----------------------------------------------------------------------------

Func findColor($x1, $x2, $y1, $y2, $color, $intVariation = 10, $skipx = 1, $skipy = 1)
	For $x = $x1 to $x2 Step $skipx
		For $y = $y1 to $y2 Step $skipy
			Local $tempPixel = [$x, $y, $color]
			If checkPixel($tempPixel, $intVariation) = true Then
				Local $tempPoint = [$x, $y]
				Return $tempPoint
			EndIf
		Next
	Next

	; return if not found
	Return False
EndFunc

;===============================================================================
;
; Description:      Check if the two color's are within a variation
; Syntax:           _ColorCheckVariation($nColor, $sCompare, $sVari=5)
; Parameter(s):     $nColor1	- The first RGB color to work with.
;					$nColor2	- The second RGB color to work with.
;					$nVari		- An integer to check the difference with
; Requirement(s):   Color.au3
; Return Value(s):  On True		- Means the two colors are within the variation
;                   On Failure	- Means the two colors have a greater difference
; Author(s):        McGod
; Note(s):          None
;
;===============================================================================
Func _ColorCheckVariation($nColor1, $nColor2, $sVari=5)
	If Abs(_ColorGetRed($nColor1) - _ColorGetRed($nColor2)) > $sVari Then Return False
	If Abs(_ColorGetBlue($nColor1) - _ColorGetBlue($nColor2)) > $sVari Then Return False
	If Abs(_ColorGetGreen($nColor1) - _ColorGetGreen($nColor2)) > $sVari Then Return False
	Return True
EndFunc

;===============================================================================
;
; Description:      Check if the two color's are within a variation
; Syntax:           _ColorGetVariation($nColor1, $nColor2, $nRetType=1)
; Parameter(s):     $nColor1	- The first RGB color to work with.
;					$nColor2	- The second RGB color to work with.
;					$nRetType	- 0 - Returns an array with Red, Blue and Green variations
;								  1 - Returns the maximum variation
; Requirement(s):   Color.au3, Math.au3
; Return Value(s):  Depends on $nRetType
; Author(s):        McGod
; Note(s):          None
;
;===============================================================================
Func _ColorGetVariation($nColor1, $nColor2, $nRetType=1)
	Local $nRet[3]
	$nRet[0] = Abs(_ColorGetRed($nColor1) - _ColorGetRed($nColor2))
	$nRet[1] = Abs(_ColorGetGreen($nColor1) - _ColorGetGreen($nColor2))
	$nRet[2] = Abs(_ColorGetBlue($nColor1) - _ColorGetBlue($nColor2))
	If $nRetType = 1 Then
		Return _Max($nRet[0], _Max($nRet[1], $nRet[2]))
	Else
		Return $nRet
	EndIf
EndFunc

;===============================================================================
;
; Description:      Check if the two color's are within a variation
; Syntax:           _ColorRGBToHex($nRed=0, $nGreen=0, $nBlue=0)
; Parameter(s):     $nRed		- The Red value of the color (Between 0 and 255)
;					$nGreen		- The Green value of the color (Between 0 and 255)
;					$nBlue		- The Blue value of the color (Between 0 and 255)
; Requirement(s):   None
; Return Value(s):	On Success - Returns a color hex
;					On failure - Returns 0 and sets error
;								@error = 1 - Invalid red value
;								@error = 2 - Invalid green value
;								@error = 3 - Invalid blue value
; Author(s):        McGod
; Note(s):          None
;
;===============================================================================
Func _ColorRGBToHex($nRed=0, $nGreen=0, $nBlue=0)
	If $nRed < 0 Or $nRed > 255 Or IsInt($nRed) = 0 Then Return SetError(1, 0, 0)
	If $nGreen < 0 Or $nGreen > 255 Or IsInt($nGreen) = 0 Then Return SetError(2, 0, 0)
	If $nBlue < 0 Or $nBlue > 255 Or IsInt($nBlue) = 0 Then Return SetError(3, 0, 0)
	Return "0x" & Hex($nRed,2) & Hex($nGreen,2) & Hex($nBlue,2)
EndFunc

;===============================================================================
;
; Description:      Check if the two color's are within a variation
; Syntax:           _ColorHexToRGB($nColor)
; Parameter(s):     $nColor - The hex color to work with.
; Requirement(s):   Color.au3
; Return Value(s):	Returns a array with Red, Blue, Green
; Author(s):        McGod
; Note(s):          None
;
;===============================================================================
Func _ColorHexToRGB($nColor)
	Local $sRet[3] = [_ColorGetRed($nColor), _ColorGetGreen($nColor), _ColorGetBlue($nColor)]
	Return $sRet
EndFunc