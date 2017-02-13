#cs ----------------------------------------------------------------------------

 Function: clickPoint

 Clicks a point on the BlueStacks window

 Parameters:

	coorPoint - Point array.

	intNum - Number of times to click.

	intDuration - Duration in between clicks in milliseconds.

 See Also:

	<clickImage>
	<clickPointWait>

#ce ----------------------------------------------------------------------------

Func clickPoint($coorPoint, $intNum = 1, $intDuration = 500)
	If Not isArray($coorPoint) Then
		setLog("Error (clickPoint): variable passed in is not an Array.")
		Return
	EndIf

	For $i = 1 To $intNum
		ControlClick($hWindow, "", "", "left", 1, $coorPoint[0], $coorPoint[1])
		If _Sleep($intDuration) Then Return
	Next
EndFunc

#cs ----------------------------------------------------------------------------

 Function: clickPointUntil

 Clicks a point on the BlueStacks window until location is present

 Parameters:

	coorPoint - Point array.

	strLocation - Location to wait for.

	intNum - Number of times to click.

	intDuration - Duration in between clicks in milliseconds.

 See Also:

	<clickImage>
	<clickPointWait>

#ce ----------------------------------------------------------------------------

Func clickPointUntil($coorPoint, $strLocation, $intNum = 5, $intDuration = 2000)
	$startTime = TimerInit()
	While TimerDiff($startTime) < $intNum*$intDuration
		If _Sleep(100) Then Return
		If (getLocation() = $strLocation) = False Then
			clickPoint($coorPoint, 1, 0)
			If _Sleep($intDuration) Then Return
		Else
			Return 1
		EndIf
	WEnd
	Return 0
EndFunc

#cs ----------------------------------------------------------------------------

 Function: clickPointUntilImage

 Clicks a point on the BlueStacks window until Image is present

 Parameters:

	coorPoint - Point array.

	strImage - Image to wait for.

	intNum - Number of times to click.

	intDuration - Duration in between clicks in milliseconds.

 See Also:

	<clickImage>
	<clickPointWait>

#ce ----------------------------------------------------------------------------

Func clickPointUntilImage($coorPoint, $strImage, $intNum = 5, $intDuration = 2000)
	$startTime = TimerInit()
	While TimerDiff($startTime) < $intNum*$intDuration
		If _Sleep(100) Then Return
		If findImageWait($strImage, 1) Then
			clickPoint($coorPoint, 1, 0)
			If _Sleep($intDuration) Then Return
		Else
			Return 1
		EndIf
	WEnd
	Return 0
EndFunc

#cs ----------------------------------------------------------------------------

 Function: clickPointWait

 Waits a duration of time for a location and clicks when location pops up

 Parameters:

	coorPoint - Point array.

	strLocation - Location to wait for.

	intWaitDuration - Duration to wait for.

	intNum - Number of times to click.

	intDuration - Duration in between clicks in milliseconds.

 Returns

	On location show - Returns 1

	On location fail to show - Returns 0

 See Also:

	<clickPoint
	<clickImage>

#ce ----------------------------------------------------------------------------

Func clickPointWait($coorPoint, $strLocation, $intWaitDuration = 5, $intNum = 1, $intDuration = 500)
	$intWaitDuration = $intWaitDuration * 1000
	$startTime = TimerInit()
	While TimerDiff($startTime) < $intWaitDuration
		If _Sleep(100) Then Return
		If getLocation() = $strLocation Then
			For $i = 1 To $intNum
			clickPoint($coorPoint, 1, 0)
				If _Sleep($intDuration) Then Return
			Next
			Return 1
		EndIf
	WEnd
	Return 0
EndFunc

#cs ----------------------------------------------------------------------------

 Function: clickImage

 Clicks an image in the BlueStacks window.

 Parameters:

	strImage - Image file name without extension.

	intTolerance - Tolerance for imagesearch

	intNum - Number of times to click.

	intDuration - Duration in between clicks in milliseconds.

 Returns:

	On Success - Returns 1

	On Fail - Returns 0

 See Also:

	<clickPoint>
	<clickPointWait>

#ce ----------------------------------------------------------------------------

Func clickImage($strImage, $intTolerance = 10, $intNum = 1, $intDuration = 500)
	Local $pointImage = findImage($strImage, $intTolerance)

	If isArray($pointImage) = False Then Return 0

	clickPoint($pointImage, $intNum, $intDuration)
	Return 1
EndFunc

#cs ----------------------------------------------------------------------------

 Function: clickImageUntil

 Clicks an image on the BlueStacks window until location is present

 Parameters:

	strImage - Image name without extension

	strLocation - Location to wait for.

	intNum - Number of times to click.

	intDuration - Duration in between clicks in milliseconds.

 See Also:

	<clickImage>
	<clickPointWait>

#ce ----------------------------------------------------------------------------

Func clickImageUntil($strImage, $strLocation, $intTolerance = 10, $intNum = 5, $intDuration = 2000)
	$startTime = TimerInit()
	While TimerDiff($startTime) < $intNum*$intDuration
		If _Sleep(100) Then Return
		If (getLocation() = $strLocation) = False Then
			Dim $arrayPoint = findImage($strImage, $intTolerance)
			If Not isArray($arrayPoint) Then Return 0

			clickPointUntil($arrayPoint, $strLocation, $intNum, $intDuration)
			If _Sleep($intDuration) Then Return
		Else
			Return 1
		EndIf
	WEnd
	Return 0
EndFunc