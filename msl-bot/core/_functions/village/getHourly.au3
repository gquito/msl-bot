#cs
 Function: getHourly
 Goes into village and gets hourly rewards

 Return:
	1: Success
	0: Fail
	-1: Bot Stop

 Author: GkevinOD (2017)
#ce

Func getHourly()
	If navigate("village") = 1 Then

		If setLogReplace("Collect hourly..", 1) Then Return -1
		Local $posVillage = null ; The village position

		If _Sleep(5000) Then Return -1 ; Checks for pop-ups when in village
		While navigate("village") = 0
			If _Sleep(2000) Then Return -1
		WEnd

		$posVillage = getVillagePos()

		If setLogReplace("Trying to click for Nezz..") Then Return -1
		Local $splitCoords = StringSplit($village_coorNezz[$posVillage], "|", 2)
		For $point In $splitCoords
			clickPoint($point, 3, 100)
		Next
	    navigate("village", "")

		If setLogReplace("Collect hourly...Position: " & $posVillage, 1) Then Return -1
		Local $arrayCoor = StringSplit($village_coorHourly[$posVillage], "|", 2) ;format: {"#,#", "#,#"..}
		For $i = 0 To 2 ;collecting the rewards
			If _Sleep(100) Then Return -1
			Local $getReward = findImage("misc-hourly", 30)
			Local $tempCount = 0
			clickWhile(StringSplit($arrayCoor[$i], ",", 2), "village", 20)

			Local $checkFriend = findImage("misc-close", 30)
			If isArray($checkFriend) = True Then
				clickUntil($checkFriend, "village")
				$i -= 1

				ContinueLoop
			EndIf

			$getReward = findImage("misc-hourly", 30)
			clickUntil($getReward, "village")
		Next
	EndIf

	If setLogReplace("Collect hourly..Done!", 1) Then Return -1
	logUpdate()
	
	Return 1
EndFunc

#cs
	Function: getVillagePos
	Checks village position and returns a value.

	Returns: 0, 1, 2 position of village
	Author: GkevinOD (2017)
#ce
Func getVillagePos()
	_CaptureRegion()
	
	; Default = 1, 2, 3 ; Wind = 4, 5, Albatross = 6, 7
	For $i = 1 To 7
		If isArray(findImage("misc-village-pos" & $i, 50)) Then Return $i-1
	Next
EndFunc