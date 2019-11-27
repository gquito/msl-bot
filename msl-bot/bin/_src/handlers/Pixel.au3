#include-once

#cs
    Function: Retrieves Color from bitmap handle and converts to 0xFFFFFF hex format
    Parameter:
        $iX: y-Coordinate
        $iY: x-Coordinate
        $hBitmap: Bitmap handle
    Return: Hex String => 0xFFFFFF.
#ce
Func getColor($iX, $iY, $hBitmap = $g_hBitmap)
    Return "0x" & Hex(_GDIPlus_BitmapGetPixel($hBitmap, $iX, $iY), 6)
EndFunc

#cs
    Function: Checks if pixel(s) equal or fit within the range of variation inside Bitmap
    Parameters:
        $vArg: Can be formated to be: [[x, y, color], [...]] or ["x, y, color", "..."] or "x,y,color|..."
        $iVariation: The maximum color variation compared to the actual pixel.
        $hBitmap: Bitmap to compare the pixels for.
    Returns: Boolean => if pixel(s) meet condition.
    Extended: List of color1, color2, and their variations.
#ce
Func isPixel($vArg, $iVariation = 10, $hBitmap = $g_hBitmap, $bDebug = False)
    Local $aPixels[0] ;pixels to check

    If ($vArg = "" Or $vArg = -1) Then ;returns early if vArg is empty
        $g_sErrorMessage = "isPixel() => No Arguments Found."
        Return -1
    EndIf

    Local $aDebug[0][4]
    $g_vDebug = $aDebug
    _ArrayAdd($g_vDebug, "Point|Color 1|Color 2|Variation")

    If (Not(isArray($vArg)) And StringLeft($vArg,1) = "%") Then $vArg = getPixelArg(StringTrimLeft($vArg,1))
    ;Fixing argument format to [[x, y, color], [...]]
    If (isArray($vArg)) Then
        If (isArray($vArg[0])) Then
            ;Expected format: "[[x, y, color], [...]]"
            Local $aPixel = $vArg
            Return comparePixels($aPixels, $iVariation, $hBitmap, $bDebug)
        Else
            If (StringInStr($vArg[0], ",")) Then
                ;Expected format: ["x,y,color", "..."]
                Local Const $iSize = UBound($vArg)
                ReDim $aPixels[$iSize]

                For $i = 0 To $iSize-1
                    Local $t_aPixel = StringSplit($vArg[$i], ",", $STR_NOCOUNT)
                    If (UBound($t_aPixel) <> 3) Then ContinueLoop

                    Local $t_iX = StringStripWS($t_aPixel[0], $STR_STRIPLEADING + $STR_STRIPTRAILING)
                    Local $t_iY = StringStripWS($t_aPixel[1], $STR_STRIPLEADING + $STR_STRIPTRAILING)
                    Local $t_cColor = StringStripWS($t_aPixel[2], $STR_STRIPLEADING + $STR_STRIPTRAILING)

                    Local $t_aFormatedPixel = [$t_iX, $t_iY, $t_cColor]

                    ReDim $aPixels[UBound($aPixels)+1]
                    $aPixels[UBound($aPixels)-1] = $t_aFormatedPixel
                Next
                Return comparePixels($aPixels, $iVariation, $hBitmap, $bDebug)
            Else
                ;Expected format: ["x", "y", "color"]
                If (UBound($vArg) <> 3) Then 
                    Log_Add("Error: isPixel => Could not identify data: " & _ArrayToString($vArg, "|"), $LOG_ERROR)
                    Return -1
                EndIf
                Local $t_aFormatedPixel = [$vArg[0], $vArg[1], $vArg[2]]

                ReDim $aPixels[UBound($aPixels)+1]
                $aPixels[UBound($aPixels)-1] = $t_aFormatedPixel
                
                Return comparePixels($aPixels, $iVariation, $hBitmap, $bDebug)
            EndIf
        EndIf
    Else
        If (StringInStr($vArg,'/', $STR_NOCASESENSE) <> 0) Then
            Local $t_aPixelOrSet = StringSplit($vArg,'/', $STR_NOCOUNT)
            Local $bOutput = False
            For $i = 0 To UBound($t_aPixelOrSet)-1
                $aPixels = splitPixelString($t_aPixelOrSet[$i])
                Local $bCompared = comparePixels($aPixels, $iVariation, $hBitmap, $bDebug)
                _ArrayAdd($g_vDebug, "-|-|-|-")
                If $bCompared = True Then $bOutput = True
                If $bDebug = False And $bOutput = True Then Return True
            Next
            Return $bOutput
        Else
            ;Expected format: "x,y,color|..."
            $aPixels = splitPixelString($vArg)
            Local $bCompared = comparePixels($aPixels, $iVariation, $hBitmap, $bDebug)
            Return $bCompared
        EndIf
    EndIf
EndFunc

Func comparePixels($aPixels, $iVariation, $hBitmap, $bDebug = False)
    ;checking if pixel is within variation
    Local Const $iTotalPixels = UBound($aPixels) ;Total pixels

    If $iTotalPixels = 0 Then
        Log_Add("isPixel(): Invalid pixel data", $LOG_ERROR)
        Return -1
    EndIf

    Local $bOutput = True
    For $i = 0 To $iTotalPixels-1
        Local $t_aCurrPixel = $aPixels[$i]

        If UBound($t_aCurrPixel) <> 3 Then
            Log_Add("isPixel(): Invalid pixel data", $LOG_ERROR)
            Return -1
        EndIf

        Local $t_iX = $t_aCurrPixel[0] ;x coordinate
        Local $t_iY = $t_aCurrPixel[1] ;y coordinate
        Local $t_cColor = $t_aCurrPixel[2] ;color

        Local $t_cColor2 = getColor($t_iX, $t_iY, $hBitmap) ;current color in position
        Local $t_iColorDifference = compareColors($t_cColor, $t_cColor2)
        
        _ArrayAdd($g_vDebug, StringFormat("(%s, %s)", $t_iX, $t_iY) & "|" & $t_cColor & "|" & $t_cColor2 & "|" & $t_iColorDifference)
        ;====================================================

        If ($t_iColorDifference > $iVariation) Then $bOutput = False
        If $bDebug = False And $bOutput = False Then Return False
    Next

    Return $bOutput
EndFunc

Func splitPixelString($sPixels)
    Local $aPixels[0]
    Local $t_aPixelSet = StringSplit($sPixels, "|", $STR_NOCOUNT)
    Local Const $t_eSize = UBound($t_aPixelSet)

    For $i = 0 To $t_eSize-1
        Local $t_aPixel = StringSplit($t_aPixelSet[$i], ",", $STR_NOCOUNT)
        If (UBound($t_aPixel) <> 3) Then ContinueLoop

        Local $t_iX = StringStripWS($t_aPixel[0], $STR_STRIPLEADING + $STR_STRIPTRAILING)
        Local $t_iY = StringStripWS($t_aPixel[1], $STR_STRIPLEADING + $STR_STRIPTRAILING)
        Local $t_cColor = StringStripWS($t_aPixel[2], $STR_STRIPLEADING + $STR_STRIPTRAILING)

        Local $t_aFormatedPixel = [$t_iX, $t_iY, $t_cColor]

        ReDim $aPixels[UBound($aPixels)+1]
        $aPixels[UBound($aPixels)-1] = $t_aFormatedPixel
    Next
    
    Return $aPixels
EndFunc

#cs
    Function: Calculates difference of two color.
    Parameter:
        $cColor1: First color.
        $cColor2: Second color.
        $nRetType: Return type.
    Returns: $nRetType:: 1=Returns max variation. 0=Returns array of max variation between Red, Green, Blue
#ce
Func compareColors($nColor1, $nColor2, $nRetType=1)
	Local $nRet[3]
	$nRet[0] = Abs(_ColorGetRed($nColor1) - _ColorGetRed($nColor2))
	$nRet[1] = Abs(_ColorGetGreen($nColor1) - _ColorGetGreen($nColor2))
	$nRet[2] = Abs(_ColorGetBlue($nColor1) - _ColorGetBlue($nColor2))
	If ($nRetType = 1) Then Return _Max($nRet[0], _Max($nRet[1], $nRet[2]))

    Return $nRet
EndFunc

Func Pixel_TotalVar($nColor1, $nColor2, $nRetType=1)
	Local $nRet[3]
	$nRet[0] = Abs(_ColorGetRed($nColor1) - _ColorGetRed($nColor2))
	$nRet[1] = Abs(_ColorGetGreen($nColor1) - _ColorGetGreen($nColor2))
	$nRet[2] = Abs(_ColorGetBlue($nColor1) - _ColorGetBlue($nColor2))
	If ($nRetType = 1) Then Return $nRet[0]+$nRet[1]+$nRet[2]

    Return $nRet
EndFunc
;So we have a the predefined x and y and color. 
;We also have the real time color from getColor
Func Pixel($iX, $iY, $nColor)
    Return Pixel_TotalVar($nColor, getColor($iX, $iY))
EndFunc

;[[x, y, c], ...]
; [][3]
;Percent of pixel fit variation
Func Pixels($aPixels)
    Local $iCounter = 0
    Local $iSize = UBound($aPixels)
    For $i = 0 To $iSize-1
        Local $iCur = Pixel($aPixels[$i][0], $aPixels[$i][1], $aPixels[$i][2])
        $iCounter += ((150-$iCur)/150) ;The lower the value the greater the effect
    Next
    Local $iResult = ($iCounter/$iSize)*100
    If $iResult < 0 Then Return 0
    Return $iResult
EndFunc

;[][][3]
Func PixelSet($aPixelSet)
    Local $iSize = UBound($aPixelSet)
    Local $iHighest = -1
    For $i = 0 To $iSize-1
        Local $aPixels = $aPixelSet[$i]
        Local $iResult = Pixels($aPixels)
        If $iHighest < $iResult Then $iHighest = $iResult
    Next
    Return $iHighest
EndFunc

Func CreateLocationArr($iIndex)
    Local $sRaw = $g_aLocations[$iIndex][1]
    Local $aPixelSet = StringSplit($sRaw, "/", 2)
    For $i = 0 To UBound($aPixelSet)-1
        Local $aPixelsRaw = StringSplit($aPixelSet[$i], "|", 2)
        Local $aPixels[UBound($aPixelsRaw)][3]
        For $x = 0 To UBound($aPixelsRaw)-1
            Local $aPixel = StringSplit($aPixelsRaw[$x], ",", 2)
            $aPixels[$x][0] = $aPixel[0]
            $aPixels[$x][1] = $aPixel[1]
            $aPixels[$x][2] = $aPixel[2]
        Next
        $aPixelSet[$i] = $aPixels
    Next
    Return $aPixelSet
EndFunc

#cs
	Function: Looks for a color within a certion boundary
	Parameters:
		$startingPoint: A point array [x, y] or string "x,y" of the top left of the boundary
		$size: A point array [x, y] or string "x,y" of the size of the boundary
		$variation: Maximum variation from the original color
		$skipx: Number of pixels to skip on the x axis
	    $skipy: Number of pixels to skip on the y axis
	Return:
		- The point array of the pixel.
		*Returns -1 if not found.
#ce

Func findColor($startingPoint, $size, $color, $variation = 10, $skipx = 1, $skipy = 1)
	Local $x, $y
	Local $width, $height

	;Split starting point array/string to its variables
	If (Not(isArray($startingPoint))) Then
		Local $split = StringSplit(StringStripWS($startingPoint, 8), ",", 2)
		$x = $split[0]
		$y = $split[1]
	Else
		$x = $startingPoint[0]
		$y = $startingPoint[1]
	EndIf

	If (Not(isArray($size))) Then
		Local $split = StringSplit(StringStripWS($size, 8), ",", 2)
		$width = $split[0]
		$height = $split[1]
	Else
		$width = $size[0]
		$height = $size[1]
	EndIf

	;Process
	For $x1 = $x to $x+$width Step $skipx
		For $y1 = $y to $y+$height Step $skipy
			Local $tempPixel = [$x1, $y1, $color]
			If (isPixel($tempPixel, $variation)) Then
				Local $tempPoint = [$x1, $y1]
				Return $tempPoint
			EndIf
		Next
	Next

	;If not found
	Return -1
EndFunc

Func setPixel($sPixels, $aData = Null, $bUpdate = True)
	Local $aPixela = getPixelArg($sPixels)
	Local $aPoints[0][2] ;Will store points to find colors for.
	
	If ($aPixela = -1) Then
		;Creates new location.
		If (Not(isArray($aData))) Then $aData = StringSplit($aData, "|", $STR_NOCOUNT)

		For $sData In $aData
			Local $aPoint = StringSplit($sData, ",", $STR_NOCOUNT)

			ReDim $aPoints[UBound($aPoints)+1][2]
			$aPoints[UBound($aPoints)-1][0] = $aPoint[0]
			$aPoints[UBound($aPoints)-1][1] = $aPoint[1]
		Next
	Else
		;Creates local version of the location. This location will be prioritized versus the remote location.
		Local $sPixelSet = $aPixela
		If (StringInStr($sPixelSet, "/")) Then $sPixelSet = StringSplit($sPixelSet, "/", $STR_NOCOUNT)[0]

		Local $aPixels = StringSplit($sPixelSet, "|", $STR_NOCOUNT)
		ReDim $aPoints[UBound($aPixels)][2]
		For $i = 0 To UBound($aPixels)-1
			Local $aPixel = StringSplit($aPixels[$i], ",", $STR_NOCOUNT)

			$aPoints[$i][0] = $aPixel[0]
			$aPoints[$i][1] = $aPixel[1]
		Next
	EndIf

	If $bUpdate = True Then CaptureRegion()

	Local $sNewPixels = "" ;Will store new pixel set
	For $i = 0 To UBound($aPoints)-1
		$sNewPixels &= "|" & $aPoints[$i][0] & "," & $aPoints[$i][1] & "," & getColor($aPoints[$i][0], $aPoints[$i][1])
	Next
	$sNewPixels = StringMid($sNewPixels, 2)

	Local $hFile = FileOpen($g_sLocalDataFolder & $g_sPixels, $FO_APPEND+$FO_CREATEPATH)
	Local $bOutput = (FileWrite($hFile, @CRLF & $sPixels & ":" & $sNewPixels) = 1)
	FileClose($hFile)

	mergeArgFromTo(getArgsFromFile($g_sLocalDataFolder & $g_sPixels), $g_aPixels, "/")
	Return $bOutput
EndFunc