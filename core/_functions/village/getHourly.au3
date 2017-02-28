;function: getHourly()
;-Goes into village and gets hourly rewards
;author: GkevinOD (2017)

Func getHourly()
	If navigate("village") = 1 Then 
		If setLog("Collecting hourly rewards..", 1) Then Return 0
		Local $posVillage = null; The village position

		_CaptureRegion()
		If isArray(findImage("misc-village-pos1")) Then
			$posVillage = 0
		ElseIf isArray(findImage("misc-village-pos2")) Then
			$posVillage = 1
		ElseIf isArray(findImage("misc-village-pos3")) Then
			$posVillage = 2
		EndIf

		If $posVillage = null Then 
			setLog("Could not recognize village position.", 1)
			Return 0
		EndIf

		setLog("Village position recognized: " & $posVillage, 2)
		Local $arrayCoor = StringSplit($village_coorHourly[$posVillage], "|", 2) ;format: {"#,#", "#,#"..}
		For $i = 0 To 2 ;collecting the rewards
			clickPointUntilImage(StringSplit($arrayCoor[$i], ",", 2), "misc-hourly", 10, 1000)
			clickImage("misc-hourly")

			Local $checkRecommended = findImage("misc-close")
			If isArray($checkRecommended) Then
				clickImage($checkRecommended)
				$i -= 1
			EndIf
		Next
	EndIf

	setLog("Complete collecting hourly rewards.")
EndFunc