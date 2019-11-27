#include-once

#cs 
    Function: Retrieves timestamp of now.
    Returns: String format=yyyymmddhhmmss
#ce
Func NowTimeStamp()
    Local $sTimeStamp = ""

    ;Getting time information: yyyy/mm/dd hh:mm:ss
    Local $aRawDate = StringSplit(_NowCalc(), " ", $STR_NOCOUNT)
    If (UBound($aRawDate, $UBOUND_ROWS) <> 2) Then
        $g_sErrorMessage = "NowTimeStamp() => Could not get date time."
        Return -1
    EndIf

    ;Splitting into sections 
    Local $aDate = StringSplit($aRawDate[0], "/", $STR_NOCOUNT) ; [yyyy, mm, dd]
    Local $aTime = StringSplit($aRawDate[1], ":", $STR_NOCOUNT) ; [hh, mm, ss]

    $sTimeStamp = $aDate[0] & $aDate[1] & $aDate[2] & $aTime[0] & $aTime[1] & $aTime[2]
    Return $sTimeStamp
EndFunc

#cs 
    Function: Formats time to readable string
    Returns: HH:MM:SS
#ce
Func formatTime($sTimeStamp = NowTimeStamp())
    Return getHour($sTimeStamp) & ":" & getMinute($sTimeStamp) & ":" & getSecond($sTimeStamp) ;& ":" & @MSEC
EndFunc

#cs
    Function: Formats the date to a readable string
    Returns: MM-DD-YYYY
#ce
Func formatDate($sTimeStamp = NowTimeStamp())
    Return getMonth($sTimeStamp) & "-" & getDay($sTimeStamp) & "-" & getYear($sTimeStamp) ;& ":" & @MSEC
EndFunc

Func formatDateTime($sTimeStamp = NowTimeStamp())
    Return formatDate($sTimeStamp) & " " & formatTime($sTimeStamp)
EndFunc

#cs 
    Function: Retrieves hour from timestamp
    Returns: ## hour.
#ce
Func getHour($sTimeStamp = NowTimeStamp())
    Return StringMid($sTimeStamp, 9, 2)
EndFunc

#cs 
    Function: Retrieves minute from timestamp
    Returns: ## minute.
#ce
Func getMinute($sTimeStamp = NowTimeStamp())
    Return StringMid($sTimeStamp, 11, 2)
EndFunc

#cs 
    Function: Retrieves second from timestamp
    Returns: ## second.
#ce
Func getSecond($sTimeStamp = NowTimeStamp())
    Return StringMid($sTimeStamp, 13, 2)
EndFunc

Func getMonth($sTimeStamp = NowTimeStamp())
    Return StringMid($sTimeStamp, 5, 2)
EndFunc

Func getDay($sTimeStamp = NowTimeStamp())
    Return StringMid($sTimeStamp, 7, 2)
EndFunc

Func getYear($sTimeStamp = NowTimeStamp())
    Return StringMid($sTimeStamp, 1, 4)
EndFunc

#cs 
    Function: Converts seconds to formated string. EX: 00 H 00 M 00 S
    Parameters:
        $iSeconds: Seconds.
#ce
Func getTimeString($iSeconds)
	If ($iSeconds >= 86400) Then ;a day
        Return Int($iSeconds / 60 / 60 / 24) & "D " & Int(Mod($iSeconds / 60 / 60, 24)) & "H " & Int(Mod($iSeconds / 60, 60)) & "M " & Int(Mod($iSeconds, 60)) & "S"
    ElseIf ($iSeconds >= 3600) Then ;an hour
		Return Int($iSeconds / 60 / 60) & "H " & Int(Mod($iSeconds / 60, 60)) & "M " & Int(Mod($iSeconds, 60)) & "S"
	Else
		Return Int($iSeconds / 60) & "M " & Int(Mod($iSeconds, 60)) & "S"
	EndIf
EndFunc

Func getSecondsFromString($sTime, $iIndex = 1, $iCount = 1)
    If $sTime = "" Or $sTime = -1 Then Return -1
    Local $sCur = StringMid(StringStripWS($sTime, 8), $iIndex, $iCount)
    Switch StringRight($sCur, 1)
        Case "D"
            Return StringMid($sCur, 1, StringLen($sCur)-1)*86400 + getSecondsFromString($sTime, $iIndex+StringLen($sCur), 1)
        Case "H"
            Return StringMid($sCur, 1, StringLen($sCur)-1)*3600 + getSecondsFromString($sTime, $iIndex+StringLen($sCur), 1)
        Case "M"
            Return StringMid($sCur, 1, StringLen($sCur)-1)*60 + getSecondsFromString($sTime, $iIndex+StringLen($sCur), 1)
        Case "S"
            Return StringMid($sCur, 1, StringLen($sCur)-1)
        Case Else
            Return getSecondsFromString($sTime, $iIndex, $iCount+1)
    EndSwitch
EndFunc

Func _RoundDown($nVar, $iCount)
    Return Round((Int($nVar * (10 ^ $iCount))) / (10 ^ $iCount), $iCount)
EndFunc