#include-once
#include "../imports.au3"

#cs 
    Function: Retrieves timestamp of now.
    Returns: String format=yyyymmddhhmmss
#ce
Func NowTimeStamp()
    Local $sTimeStamp = ""

    ;Getting time information: yyyy/mm/dd hh:mm:ss
    Local $aRawDate = StringSplit(_NowCalc(), " ", $STR_NOCOUNT)
    If UBound($aRawDate, $UBOUND_ROWS) <> 2 Then
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
    Return getHour($sTimeStamp) & ":" & getMinute($sTimeStamp) & ":" & getSecond($sTimeStamp)
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

#cs 
    Function: Converts seconds to formated string. EX: 00 H 00 M 00 S
    Parameters:
        $iSeconds: Seconds.
#ce
Func getTimeString($iSeconds)
	If $iSeconds >= 3600 Then
		Return Int($iSeconds / 60 / 60) & "H " & Int(Mod($iSeconds / 60, 60)) & "M " & Int(Mod($iSeconds, 60)) & "S"
	Else
		Return Int($iSeconds / 60) & "M " & Int(Mod($iSeconds, 60)) & "S"
	EndIf
EndFunc