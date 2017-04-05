;function: getHourly()
;-Goes into village and gets hourly rewards
;author: GkevinOD (2017)
;returns:
;	-if success: return 1
;	-if fail: return 0

Func getHourly()
	If navigate("village") = 1 Then
		If setLogReplace("Collect hourly..", 1) Then Return
		Local $posVillage = null; The village position

		While navigate("village") = 0
			If _Sleep(2000) Then Return 0
		WEnd

		_CaptureRegion()
		If isArray(findImage("misc-village-pos1", 50)) Then
			$posVillage = 0
		ElseIf isArray(findImage("misc-village-pos2", 50)) Then
			$posVillage = 1
		ElseIf isArray(findImage("misc-village-pos3", 50)) Then
			$posVillage = 2
		EndIf

		If $posVillage = null Then
			If setLogReplace("Collect hourly..Failed.", 1) Then Return
			Return 0
		EndIf

		If setLogReplace("Collect hourly...Position: " & $posVillage, 1) Then Return
		Local $arrayCoor = StringSplit($village_coorHourly[$posVillage], "|", 2) ;format: {"#,#", "#,#"..}
		For $i = 0 To 2 ;collecting the rewards
			If _Sleep(100) Then Return
			Local $getReward = findImage("misc-hourly", 30)
			While Not isArray($getReward)
				clickWhile(StringSplit($arrayCoor[$i], ",", 2), "village", 20)
				clickPoint(findImage("misc-close", 30))

				$getReward = findImage("misc-hourly", 30)
			WEnd
		Next

		If setLogReplace("Collect hourly..Inbox", 1) Then Return
		;collect inbox
		clickPoint($village_coorTab)
		clickUntil(findImage("misc-village-inbox", 30), "inbox")
		clickPoint($village_coorInbox)
		clickPoint($village_coorAccept, 3, 1000)

		ControlSend($hWindow, "", "", "{ESC}")
	EndIf

	If setLogReplace("Collect hourly..Done!", 1) Then Return
	Return 1
EndFunc