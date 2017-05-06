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
			clickPoint($getQuest, 3, 100)

			If $getQuest[0] < 400 Then ;capture, challenges
				clickPoint("729,190")
			Else ;monthly, weekly, daily
				clickPoint("717,247")
				clickPoint("731,194") ;the top get reward
			EndIf

			If _Sleep(500) Then Return -1

			If Not(getLocation() = "quests") Then
				navigate("village")
				navigate("village", "quests")
			EndIf

			_CaptureRegion()
			$getQuest = findColor(747,167,116,116,0xDA101B,20,-1,1)
		WEnd
	Else
		If setLogReplace("Collecting quests..Fail to go to quests.", 1) Then Return False
		logUpdate()
		Return False
	EndIf
	navigate("village")
	If setLogReplace("Collecting quests..Done!", 1) Then Return False
	logUpdate()
	Return True
EndFunc