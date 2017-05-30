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

		If setLogReplace("Trying to click for Nezz..") Then Return -1
		Local $splitCoords = StringSplit($village_coorNezz[$posVillage], "|", 2)
		For $point In $splitCoords
			clickPoint($point, 3, 100)
		Next
	    navigate("village", "")

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
		Case checkPixels("54,469,0x482E1F|306,449,0x54451E|616,422,0x3F3720/367,455,0x65552B|628,96,0x3D4340|282,23,0x485F72/738,394,0x705C36|13,413,0x6D4E38|74,382,0xBC9166", 50)
			Return 0
		Case checkPixels("64,488,0x393623|264,51,0x4D656F|18,414,0xB4AA74/192,465,0x52622E|261,47,0x597077|566,92,0x259558/54,98,0x6C7E8A|787,360,0x234923|297,545,0x2D3029", 50)
			Return 1
		Case checkPixels("32,449,0x26221A|81,430,0x944E41|715,409,0x3B2F1D/111,537,0x4F4526|87,124,0x71716F|259,349,0x177831/71,382,0x26221A|646,445,0x524E2B|775,105,0x716F58", 50)
			Return 2
		Case Else
			If setLog("Could not find village position! Using default 0.", 1) Then Return -1
			Return 0
	EndSelect
EndFunc