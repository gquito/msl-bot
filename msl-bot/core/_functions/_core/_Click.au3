#cs ----------------------------------------------------------------------------

 Function: clickPoint
 Clicks a point on the emulator

 Parameters:
	coorPoint - Point array.
	intNum - Number of times to click.
	intDuration - Duration in between clicks in milliseconds.

 Return: Void
 Author: GkevinOD(2017)

#ce ----------------------------------------------------------------------------

Func clickPoint($coorPoint, $intNum = 1, $intDuration = 500, $boolRandom = True)
	If Not isArray($coorPoint) Then
		$coorPoint = StringSplit($coorPoint, ",", 2)
	EndIf

	If UBound($coorPoint) < 2 Then Return

	For $i = 1 To $intNum
		If $iniRealMouse = 1 Then
			WinActivate($hWindow)

			Dim $desktopCoor = WinGetPos($hControl)
			If $boolRandom = True Then
				MouseClick("left", $desktopCoor[0]+$coorPoint[0]+Random(0, 5, 1), $desktopCoor[1]+$coorPoint[1]+Random(0, 5, 1), 1, 0)
			Else
				MouseClick("left", $desktopCoor[0]+$coorPoint[0], $desktopCoor[1]+$coorPoint[1], 1, 0)
			EndIf
		Else
			If $boolRandom = True Then
				ControlClick($hWindow, "", "", "left", 1, $coorPoint[0]+Random(0, 5, 1)+$diff[0], $coorPoint[1]+Random(0, 5, 1)+$diff[1])
			Else
				ControlClick($hWindow, "", "", "left", 1, $coorPoint[0]+$diff[0], $coorPoint[1]+$diff[1])
			EndIf
		EndIf

		If _Sleep($intDuration) Then Return
	Next
EndFunc

#cs ----------------------------------------------------------------------------

 Function: clickUntil
 Clicks until location has been found

 Parameters:
	coorPoint - Point array [x, y] or string "x,y".
	strLocation - Location to wait for.
	num - Number of times to click until stopping.
	speed - Speed of clicking. (milliseconds)

 Returns: Boolean
	If location has been found.

 Author: GkevinOD (2017)

#ce ----------------------------------------------------------------------------

Func clickUntil($coorPoint, $strLocation, $num = 5, $speed = 500)
	For $numClick = 0 To $num-1
		Local $startTime = TimerInit()
		While TimerDiff($startTime) < $speed
			If getLocation() = $strLocation Then Return 1
			If _Sleep(100) Then Return 0
		WEnd

		clickPoint($coorPoint, 1, 0, False)
	Next
	Return 0
EndFunc

#cs ----------------------------------------------------------------------------

 Function: clickWhile
 Clicks while on a certain location

 Parameters:
	coorPoint - Point array [x, y] or string "x,y".
	strLocation - Location to wait for.
	num - Number of times to click until stopping.
	speed - Speed of clicking. (milliseconds)

 Returns: Boolean
	If location changed.

 Author: GkevinOD (2017)

#ce ----------------------------------------------------------------------------

Func clickWhile($coorPoint, $strLocation, $num = 5, $speed = 500)
	For $numClick = 0 To $num-1
		Local $startTime = TimerInit()
		While TimerDiff($startTime) < $speed
			If Not(getLocation() = $strLocation) Then Return 1
			If _Sleep(100) Then Return 0
		WEnd

		clickPoint($coorPoint, 1, 0, False)
	Next
	Return 0
EndFunc