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

		;Tries to close some GUI in-game that blocks the hourly rewards.
		clickPoint("74,333", 3, 100)
		clickPoint("744, 72", 3, 100)

		$posVillage = getVillagePos()
		If $posVillage = -1 Then
			setLogReplace("Collect hourly..Could not detect ship.")
			Return -1
		EndIf

		If setLogReplace("Trying to click for Nezz..") Then Return -1
		Local $splitCoords = StringSplit($village_coorNezz[$posVillage], "|", 2)
		For $point In $splitCoords
			clickPoint($point, 3, 100)
		Next
	    navigate("village")

		If setLogReplace("Collect hourly..Position: " & $posVillage, 1) Then Return -1
		Local $arrayCoor = StringSplit($village_coorHourly[$posVillage], "|", 2) ;format: {"#,#", "#,#"..}
		For $i = 0 To UBound($arrayCoor)-2 ;collecting the rewards
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

	navigate("village")
	Return 1
EndFunc

#cs
	Function: getVillagePos
	Checks village position and returns a value.

	Returns: 0, 1, 2 position of village
	Author: GkevinOD (2017)
#ce

Global $pixelShips = [ _
"54,469,0x482E1F|306,449,0x54451E|616,422,0x3F3720/367,455,0x65552B|628,96,0x3D4340|282,23,0x485F72/738,394,0x705C36|13,413,0x6D4E38|74,382,0xBC9166", _
"64,488,0x393623|264,51,0x4D656F|18,414,0xB4AA74/192,465,0x52622E|261,47,0x597077|566,92,0x259558/54,98,0x6C7E8A|787,360,0x234923|297,545,0x2D3029", _
"32,449,0x26221A|81,430,0x944E41|715,409,0x3B2F1D/111,537,0x4F4526|87,124,0x71716F|259,349,0x177831/71,382,0x26221A|646,445,0x524E2B|775,105,0x716F58", _
"658,402,0x604E31|229,410,0x304138|194,329,0x76C84E/623,266,0x296D6D|609,307,0x266769|619,47,0x328B9B/677,130,0x2E95A6|98,325,0x493827|126,402,0x252C25", _
"655,358,0x8CD75D|724,384,0x473627|160,159,0x28999D/254,388,0x353E32|291,472,0x43483E|491,544,0x1C201B/106,159,0x6B3D3A|32,157,0x209575|779,366,0x1D1911", _
"44,389,0x323F32|633,425,0xCBD0C2|267,127,0x7C55C4/133,316,0x11110A|481,348,0x84773D|551,47,0x4A5855/691,105,0x1E8645|373,455,0x425B4D|690,325,0x2B2815", _
"232,348,0x363630|390,147,0x434F3D|710,388,0x134B66/565,238,0x6D6D56|94,211,0x9E418B|359,104,0x146961/648,344,0x443A23|540,95,0x5F7479|182,468,0x363333"]
Func getVillagePos()
	_CaptureRegion()

	;Traverse through idShip checking the pixel sets.
	For $i = 0 To UBound($pixelShips)-1
		If checkPixels($pixelShips[$i], 20) Then Return $i
	Next

	;Return -1 if ship not found.
	Return -1
EndFunc