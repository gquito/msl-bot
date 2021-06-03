#include-once

Func getColor($iX, $iY, $aMap = $g_aMap)
    Local $sHex = Hex(DllStructGetData($aMap, 1, ($EMULATOR_WIDTH * $iY + $iX) + 1), 6)
    Return "0x" & $sHex
EndFunc

Func _getColor($iX, $iY, $aMap = $g_aMap)
    Return DllStructGetData($aMap, 1, ($EMULATOR_WIDTH * $iY + $iX) + 1)
EndFunc

Func compareColors($iColor1, $iColor2)
    Local $iRed = Abs(_ColorGetRed($iColor1) - _ColorGetRed($iColor2))
	Local $iGreen = Abs(_ColorGetGreen($iColor1) - _ColorGetGreen($iColor2))
	Local $iBlue = Abs(_ColorGetBlue($iColor1) - _ColorGetBlue($iColor2))

	Return _Max($iRed, _Max($iGreen, $iBlue))
EndFunc

Func TestIsPixel($x)
    Local $hTimer = TimerInit()
    CaptureRegion()
    For $i = 0 To $x
        isPixel("98,471,0x322013|231,464,0x805632|312,478,0x8E6037|701,471,0x321E11/98,471,0x352213|231,464,0x775030|312,478,0x6D4424|701,471,0x321E11", 3)
    Next
    Return TimerDiff($hTimer)
EndFunc

Func isPixel($vArg, $iVariation = 5, $aMap = $g_aMap)
    Local $aPixels[0] ;pixels to check

    If ((isArray($vArg) <= 0 And $vArg == "") Or (isArray($vArg) > 0 And UBound($vArg) <= 0) Or $vArg = -1) Then ;returns early if vArg is empty
        Return -1
    EndIf

    If (Not(isArray($vArg)) And StringLeft($vArg,1) == "%") Then $vArg = getPixelArg(StringTrimLeft($vArg,1))
    ;Fixing argument format to [[x, y, color], [...]]
    If (isArray($vArg)) Then
        If (isArray($vArg[0])) Then
            ;Expected format: "[[x, y, color], [...]]"
            Local $aPixel = $vArg
            Return comparePixels($aPixels, $iVariation, $aMap)
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
                Return comparePixels($aPixels, $iVariation, $aMap)
            Else
                ;Expected format: ["x", "y", "color"]
                If (UBound($vArg) <> 3) Then 
                    Log_Add("Error: isPixel => Could not identify data: " & _ArrayToString($vArg, "|"), $LOG_ERROR)
                    Return -1
                EndIf
                Local $t_aFormatedPixel = [$vArg[0], $vArg[1], $vArg[2]]

                ReDim $aPixels[UBound($aPixels)+1]
                $aPixels[UBound($aPixels)-1] = $t_aFormatedPixel
                
                Return comparePixels($aPixels, $iVariation, $aMap)
            EndIf
        EndIf
    Else
        If (StringInStr($vArg,'/', $STR_NOCASESENSE) <> 0) Then
            Local $t_aPixelOrSet = StringSplit($vArg,'/', $STR_NOCOUNT)
            For $i = 0 To UBound($t_aPixelOrSet)-1
                $aPixels = splitPixelString($t_aPixelOrSet[$i])
                Local $bCompared = comparePixels($aPixels, $iVariation, $aMap)
                If $bCompared > 0 Then Return True
            Next
            Return False
        Else
            ;Expected format: "x,y,color|..."
            $aPixels = splitPixelString($vArg)
            Local $bCompared = comparePixels($aPixels, $iVariation, $aMap)
            Return $bCompared
        EndIf
    EndIf
EndFunc

Func comparePixels($aPixels, $iVariation, $aMap = $g_aMap)
    ;checking if pixel is within variation
    Local Const $iTotalPixels = UBound($aPixels) ;Total pixels
    If $iTotalPixels = 0 Then
        Log_Add("isPixel(): Invalid pixel data", $LOG_ERROR)
        Return -1
    EndIf

    For $i = 0 To $iTotalPixels-1
        Local $t_aCurrPixel = $aPixels[$i]

        If UBound($t_aCurrPixel) <> 3 Then
            Log_Add("isPixel(): Invalid pixel data", $LOG_ERROR)
            Return -1
        EndIf

        Local $t_iX = $t_aCurrPixel[0] ;x coordinate
        Local $t_iY = $t_aCurrPixel[1] ;y coordinate
        Local $t_cColor = Dec(Hex($t_aCurrPixel[2])) ;color

        Local $t_cColor2 = _getColor($t_iX, $t_iY, $aMap) ;current color in position
        Local $t_iColorDifference = compareColors($t_cColor, $t_cColor2)

        ;====================================================
        If ($t_iColorDifference > $iVariation) Then Return False
    Next

    Return True
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

	If $bUpdate > 0 Then CaptureRegion()

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