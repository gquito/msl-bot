#include-once
#include "../imports.au3"

#cs 
    Function: Adds a log into the log array
    Parameters:
        $aLog: Log array stored in [##][3] array
        $sLog: Message to put into the log
        $iLevel: The log level. $LOG_NORMAL (0), $LOG_DEBUG (1), $LOG_ERROR (2)
#ce
Func addLog(ByRef $aLog, $sLog, $iLevel = $LOG_NORMAL, $iTimeStamp = NowTimeStamp())
    Local $iRowSize = UBound($aLog, $UBOUND_ROWS)
    ReDim $aLog[$iRowSize+1][3]

    $aLog[$iRowSize][0] = $sLog
    $aLog[$iRowSize][1] = $iLevel
    $aLog[$iRowSize][2] = $iTimeStamp
EndFunc

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