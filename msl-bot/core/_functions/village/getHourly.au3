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
		Local $posVillage = null; The village position

		If _Sleep(5000) Then Return -1;checks for pop-ups when in village
		While navigate("village") = 0
			If _Sleep(2000) Then Return -1
		WEnd

		$posVillage = getVillagePos()

		If setLogReplace("Collect hourly...Position: " & $posVillage, 1) Then Return -1
		Local $arrayCoor = StringSplit($village_coorHourly[$posVillage], "|", 2) ;format: {"#,#", "#,#"..}
		For $i = 0 To 2 ;collecting the rewards
			If _Sleep(100) Then Return
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

		If setLogReplace("Collect hourly..Inbox", 1) Then Return -1
		;collect inbox
		clickPoint($village_coorTab, 3)
		clickUntil(findImage("misc-village-inbox", 30), "inbox")
		clickPoint($village_coorInbox, 3)
		clickPoint($village_coorAccept, 3, 1000)

		clickUntil("709,99", "village")
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
	Select
		Case checkPixels("54,469,0x482E1F|306,449,0x54451E|616,422,0x3F3720")
			Return 0
		Case checkPixels("64,488,0x393623|264,51,0x4D656F|18,414,0xB4AA74")
			Return 1
		Case Else
			Return 2
	EndSelect
EndFunc