#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.2
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here
Func getRound()

	Local $offset = 14
	Local $round = [0,0]

	; Find the Round Number
	If checkPixel($battle_Round1) Then 
		$round[0] = 1
	ElseIf checkPixel($battle_Round2) Then 
		$round[0] = 2
	ElseIf checkPixel($battle_Round3) Then 
		$round[0] = 3
	ElseIf checkPixel($battle_Round4) Then 
		$round[0] = 4
	EndIf
	
	; Calculate the offset for the number of rounds
	$battle_Final1 = $battle_Round1
	$battle_Final2 = $battle_Round2
	$battle_Final3 = $battle_Round3
	$battle_Final4 = $battle_Round4
	$battle_Final1[0] += $offset 
	$battle_Final2[0] += $offset 
	$battle_Final3[0] += $offset 
	$battle_Final4[0] += $offset 
	
	; Find the Total Round Number
	If checkPixel($battle_Final1) Then
		$round[1] = 1
	ElseIf checkPixel($battle_Final2) Then
		$round[1] = 2
	ElseIf checkPixel($battle_Final3) Then
		$round[1] = 3
	ElseIf checkPixel($battle_Final4) Then
		$round[1] = 4
	EndIf
	
	Return $round
EndFunc   ;==>farmAstromon