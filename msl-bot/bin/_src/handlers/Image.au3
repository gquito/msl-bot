#include-once
#include "../imports.au3"

#cs
 Function: Using ImageSearch find an image within the HBMP
 Parameters:
	$sImage - Image name without extension.
	$iTolerance - Tolerance of the image to look for.
	$iDuration - How long to keep checking for
 Returns:
	On image found - Returns array
	On image not found - Returns -1
#ce

Func findImage($sImage, $iTolerance = 30, $iDuration = 100, $iLeft = 0, $iTop = 0, $iWidth = 800, $iHeight = 552)
	If StringInStr($sImage, "-") Then ;image with specified folder
		$sImage = StringSplit($sImage, "-", 2)[0] & "\" & $sImage
	EndIf

	Local $aImages[0] ;images list to find

	If FileExists($g_sImagesPath & $sImage & ".bmp") Then
		_ArrayAdd($aImages, $g_sImagesPath & $sImage & ".bmp")

		Local $iDupCounter = 2; Ex: location-village2...
		While FileExists($g_sImagesPath & $sImage & $iDupCounter & ".bmp")
			_ArrayAdd($aImages, $g_sImagesPath & $sImage & $iDupCounter & ".bmp")
			$iDupCounter += 1
		WEnd
	EndIf

	Local $aPoint = [-1, -1]
	Local $iResult;

	Local $startTimer = TimerInit()
	Do
		captureRegion("", $iLeft, $iTop, $iWidth, $iHeight)
		$iResult = _ImagesSearch($aImages, 1, $aPoint[0], $aPoint[1], $iTolerance)

		If $iResult >= 0 Then
			Local $aResult = [$aPoint[0]+$iLeft, $aPoint[1]+$iTop, $iResult, StringReplace($aImages[$iResult], $g_sImagesPath & StringSplit($sImage, "-", 2)[0] & "\", "")]
			Return $aResult
		EndIf
	Until (TimerDiff($startTimer) >= $iDuration) Or (_Sleep(100))

	Return -1
EndFunc