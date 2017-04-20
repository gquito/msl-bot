#cs
 Function: getQuest
 Goes into village and collects quest rewards

 Return: (Boolean) Whether successful or fail

 Author: GkevinOD (2017)
#ce

Func getQuest()
	If setLogReplace("Collecting quests..Navigating to Quests", 1) Then Return False
	If navigate("village", "quests") = True Then
		_CaptureRegion()
		Local $getQuest = findColor(747,167,116,116,0xDA101B,20,-1,1)
		While isArray($getQuest)
			If $getQuest[0] < 400 Then
				clickPoint("729,190")
			Else
				clickPoint("717,247")
			EndIf

			If _Sleep(500) Then Return -1

			If getLocation() = "unknown" Then clickWhile("573,197", "unknown")

			_CaptureRegion()
			$getQuest = findColor(747,167,116,116,0xDA101B,20,-1,1)
		WEnd
	Else
		If setLogReplace("Collecting quests..Fail to go to quests.", 1) Then Return False
		logUpdate()
		Return False
	EndIf
	If setLogReplace("Collecting quests..Done!", 1) Then Return False
	logUpdate()
	Return True
EndFunc