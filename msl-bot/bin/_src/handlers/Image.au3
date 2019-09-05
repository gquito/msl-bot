#include-once

#cs
 Function: Using ImageSearch find an image within the HBMP
 Parameters:
	$sImage - Image name without extension.
	$iTolerance - Tolerance of the image to look for. 0-100% matching.
	$iDuration - How long to keep checking for
	$iLeft, $iTop, $iWidth, $iHeight - Dimension of the BMP
	$bUpdate - Updates current hBitmap
	$bUseColor - Use color for imagesearch algorithm.
 Returns:
	On image found - Returns array
	On image not found - Returns -1
#ce
Func findImage($sImage, $iTolerance = 90, $iDuration = 100, $iLeft = 0, $iTop = 0, $iWidth = 800, $iHeight = 552, $bUpdate = True, $bUseColor = True)
	If (StringInStr($sImage, "-")) Then $sImage = StringSplit($sImage, "-", 2)[0] & "\" & $sImage ;image with specified folder

	Local $aImages[0] ;images list to find

	If (FileExists($g_sImagesPath & $sImage & ".bmp")) Then
		_ArrayAdd($aImages, $g_sImagesPath & $sImage & ".bmp")

		Local $iDupCounter = 2; Ex: location-village2...
		While FileExists($g_sImagesPath & $sImage & $iDupCounter & ".bmp")
			_ArrayAdd($aImages, $g_sImagesPath & $sImage & $iDupCounter & ".bmp")
			$iDupCounter += 1
		WEnd
	EndIf

	Local $aPoint = [-1, -1] ;Final point.
	Local $iIndex = -1 ;Index of found image.

	Local $startTimer = TimerInit()
	Do
		Local $vResult = _ImagesSearch($aImages, $iIndex, $iTolerance, $iLeft, $iTop, $iWidth, $iHeight, True, $bUpdate, "", $bUseColor) ;'True' is for return center.

		If (isArray($vResult)) Then
			$aPoint = $vResult
			Local $aFinal = [$aPoint[0], $aPoint[1], $iIndex, StringReplace($aImages[$iIndex], $g_sImagesPath & StringSplit($sImage, "-", 2)[0] & "\", "")]
			Log_Add("Found " & $sImage & " at (" & $aPoint[0] & ", " & $aPoint[1] & ").", $LOG_DEBUG)
			Return $aFinal
		Else
			;There is an error
			If ($vResult < 0) Then ExitLoop
		EndIf
	Until (TimerDiff($startTimer) >= $iDuration) Or (_Sleep(100))

	Return -1
EndFunc

#cs
Function will find a single or multiple instances of an image inside a BMP.
Parameters:
	$sImage - Image name without extension.
	$iTolerance - Tolerance of the image to look for. 0-100% matching.
	$iWidthTolerance - Number of pixel to check for similarities. The first instance in that area will be saved. All others will be removed.
	$iHeightTolerance - Number of pixels to check for similarities. The first instance in that area will be saved. All others will be removed.
	$iLimit - Number of elements to find before stopping. 0 Means no limit.
	$iLeft, $iTop, $iWidth, $iHeight - Dimension of the BMP
	$bUpdate - Updates current hBitmap
	$bUseColor - Use color for imagesearch algorithm.
Returns:
	Returns 2D array of all points.
	Returns 0 if no instance is found.
Note:
	Width and Height tolerance exist because multiple images of the 'same' image are being scanned and could be scanned at the same spot multiple
		times. The same instance could also be scanned not at the same exact point, but in the same area within 1-2 pixels at times.
#ce
Func findImageMultiple($sImage, $iTolerance = 90, $iWidthTolerance = 5, $iHeightTolerance = 5, $iLimit = 0, $iLeft = 0, $iTop = 0, $iWidth = 800, $iHeight = 552, $bUpdate = True, $bUseColor = False)
	If (StringInStr($sImage, "-")) Then $sImage = StringSplit($sImage, "-", 2)[0] & "\" & $sImage

	Local $aImages[0] ;images list to find

	If (FileExists($g_sImagesPath & $sImage & ".bmp")) Then
		_ArrayAdd($aImages, $g_sImagesPath & $sImage & ".bmp")

		Local $iDupCounter = 2; Ex: location-village2...
		While FileExists($g_sImagesPath & $sImage & $iDupCounter & ".bmp")
			_ArrayAdd($aImages, $g_sImagesPath & $sImage & $iDupCounter & ".bmp")
			$iDupCounter += 1
		WEnd
	EndIf

	Local $aPoints[0][2] ;Point list
	Local $vResult ;Result of each image search

	Local $iSize = 0 ;Size of aPoints
	Local $bCurrentExists = False ;If current point exists in list
		
	For $sImage in $aImages
		$vResult = _ImageSearch($sImage, True, $iTolerance, $iLeft, $iTop, $iWidth, $iHeight, True, $bUpdate, "", $bUseColor) ;'True' is for return center.
		If (isArray($vResult)) Then
			For $x = 0 To UBound($vResult)-1
				$bCurrentExists = False

				;Check if point already exists in list. Also checks the area around the point.
				For $i = 0 To $iSize-1
					If ($vResult[$x][0] > $aPoints[$i][0]-$iWidthTolerance And $vResult[$x][0] < $aPoints[$i][0]+$iWidthTolerance) Then
						If ($vResult[$x][1] > $aPoints[$i][1]-$iHeightTolerance And $vResult[$x][1] < $aPoints[$i][1]+$iHeightTolerance) Then
							$bCurrentExists = True
							ExitLoop
						EndIf
					EndIf
				Next

				;Adds to point list if it does not exist.
				If (Not($bCurrentExists)) Then
					ReDim $aPoints[$iSize+1][2]

					$aPoints[$iSize][0] = $vResult[$x][0]
					$aPoints[$iSize][1] = $vResult[$x][1]
					$iSize += 1

					If ($iSize = $iLimit And $iLimit > 0) Then ExitLoop(2)
				EndIf
			Next
		EndIf
	Next

	If ($iSize <> 0) Then
		Log_Add("Found " & $iSize & " matches for " & $sImage & ".", $LOG_DEBUG)
		Return $aPoints 
	EndIf
	Return -1
EndFunc