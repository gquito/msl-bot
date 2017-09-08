Func pixelRecordSearch($pixelRecord, $left, $top, $right, $bottom)
	Local $width = $pixelRecord[1], $height = $pixelRecord[2]
	Local $pixels = StringSplit($pixelRecord[3], ",", 2)

	Local $checkPixel[0]
	For $pixel In $pixels
		_ArrayAdd($checkPixel, "0x" & StringSplit($pixel, "x", 2)[1])
	Next

	For $y = $top To $bottom-$top Step $height
		For $x = $left To $right-$left Step $width
			For $pixel In $pixels
				If checkPixel($x & "," & $y & "," & "0x" & StringSplit($pixel, "x", 2)[1], 10) Then

				EndIf
			Next
		Next
	Next
EndFunc


;functions: loadPixelRecords
;-Reads pixel record text file into array global variable
;parameters:
;-path: Path to the text file
;returns: boolean
;author: GkevinOD(2017)

;[name, startingpoint, width, height, ""]
Global $pixelRecords[0]
Func loadPixelRecords($path = @ScriptDir & "/core/pixel-records.txt")
	Local $lineCount = _FileCountLines($path)
	Local $fileHandle = FileOpen($path, $FO_READ)

	Global $pixelRecords[0]

	For $i = 1 To $lineCount
		If FileReadLine($fileHandle, $i) = "" Then ContinueLoop
		Local $pixelList = StringSplit(FileReadLine($fileHandle, $i), "|", 2)[1]
		Local $pixelRecord = StringSplit(StringSplit(FileReadLine($fileHandle, $i), "|", 2)[0], ",", 2)

		_ArrayAdd($pixelRecords, $pixelRecord[0] & "," & $pixelRecord[1] & "," & $pixelRecord[2] & "|" & $pixelList, 0, null, null, 1)
	Next

	FileClose($fileHandle)
Endfunc

;function: recordPixel
;-Records set of pixels within a rectangle border and saves into a txt
;parameters:
;-name: String for set of pixel.
;-startingPoint: Array or String for top left point of rectangle
;-width: Width of rectangle
;-height: Height of rectangle
;-filePath: Path to txt file
;returns: boolean
;author: GkevinOD (2017)

Func recordPixel($name, $startingPoint, $width, $height, $filePath = @ScriptDir & "/core/pixel-records.txt")
	_CaptureRegion()

	$startingPoint = StringStripWS($startingPoint, 8)
	If Not isArray($startingPoint) Then
		$startingPoint = StringSplit($startingPoint, ",", 2)
	EndIf

	;name,x,y,width,height|...
	Local $pixelRecord = $name & "," & $width & "," & $height & "|"

	Local $oldPixel = Hex(_GDIPlus_BitmapGetPixel($hBitmap, $startingPoint[0], $startingPoint[1]), 6)
	Local $samePixel = 0
	For $y = $startingPoint[1] To $height+$startingPoint[1]-1
		For $x = $startingPoint[0] To $width+$startingPoint[0]-1
			Local $newPixel = Hex(_GDIPlus_BitmapGetPixel($hBitmap, $x, $y), 6)

			If $newPixel = $oldPixel Then
				$samePixel += 1
			Else
				$pixelRecord &=  $samePixel & "x" & $oldPixel & ","
				$oldPixel = $newPixel
				$samePixel = 1
			EndIf
		Next
	Next
	$pixelRecord &=  $samePixel & "x" & $oldPixel & ","

	$pixelRecord = StringTrimRight($pixelRecord, 1)
	FileWrite($filePath, @CRLF & $pixelRecord)

	loadPixelRecords()
EndFunc

;function: getPixelRecord
;-Returns the set of pixels recorded from recordPixel
;parameters:
;-name: String of the set of pixel
;returns: pixelRecord
;author: GkevinOD (2017)

Func getPixelRecord($name)
	For $pixelRecord In $pixelRecords
		If StringSplit($pixelRecord, ",", 2)[0] = $name Then
			Local $pixelList = StringSplit($pixelRecord, "|", 2)[1]
			Local $pixelSplit = StringSplit(StringSplit($pixelRecord, "|", 2)[0], ",", 2)

			Local $newPixelRecord[4] = [$pixelSplit[0], $pixelSplit[1], $pixelSplit[2], $pixelList]
			Return $newPixelRecord
		EndIf
	Next
	Return Null
EndFunc

;function: checkPixelRecord
;-Checks if pixel record matches, with a tolerance rate.
;parameters:
;-pixelRecord: pixelRecord(String)
;-startingPoint: Array or String for top left point of rectangle
;-rate: 0-1, the percentage of pixels in order to be accepted.
;returns: rate-percentage of pixels that are correct
;author: GkevinOD (2017)

Func checkPixelRecord($pixelRecord, $startingPoint)
	If isArray($pixelRecord) = False Then Return 0

	;variables for calculating rate
	Local $totalSize, $correctPixels = 0

	;if starting point is string, convert to array
	$startingPoint = StringStripWS($startingPoint, 8)
	If Not isArray($startingPoint) Then
		$startingPoint = StringSplit($startingPoint, ",", 2)
	EndIf

	;process
	Local $pixels = StringSplit($pixelRecord[3], ",", 2)
	$totalSize = $pixelRecord[1] * $pixelRecord[2]

	Local $counter = 0 ;To traverse through pixels
	Local $numLoop = Int(StringSplit($pixels[$counter], "x", 2)[0])
	_CaptureRegion()

	;Local $timerInit = TimerInit()

	For $y = $startingPoint[1] To $pixelRecord[2]+$startingPoint[1]-1
		For $x = $startingPoint[0] To $pixelRecord[1]+$startingPoint[0]-1
			If $numLoop > 0 Then
				$numLoop -= 1
			EndIf

			If checkPixel($x & "," & $y & ",0x" & StringSplit($pixels[$counter], "x", 2)[1], 10) Then
				$correctPixels += 1
			EndIf

			If $numLoop = 0 Then
				If $counter < UBound($pixels)-1 Then $counter += 1
				$numLoop = Int(StringSplit($pixels[$counter], "x", 2)[0])
			EndIf
		Next
	Next

	;setLog("Dim: " & $pixelRecord[1] & "x" & $pixelRecord[2] & " - " & TimerDiff($timerInit))

	Return $correctPixels/$totalSize*100
EndFunc

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

