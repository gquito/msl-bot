#cs
 Function: getQuest
 Goes into village and collects quest rewards

 Return: (Boolean) Whether successful or fail

 Author: GkevinOD (2017)
#ce

Func getQuest()
	If setLogReplace("Collecting quests..Navigating to Quests", 1) Then Return False
	If navigate("village", "quests") = 1 Then
		For $questTab In $village_coorArrayQuestsTab ;quest tabs
			clickPoint(StringSplit($questTab, ",", 2))
			While IsArray(findImage("misc-quests-get-reward", 100, 3)) = True
				If _Sleep(10) Then Return False
				clickPoint(findImage("misc-quests-get-reward", 100))
			WEnd
		Next
	Else
		If setLogReplace("Collecting quests..Fail to go to quests.", 1) Then Return False
		Return False
	EndIf
	If setLogReplace("Collecting quests..Done!", 1) Then Return False
	Return True
EndFunc