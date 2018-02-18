#include-once
#include "../imports.au3"

#cs 
    Function: Run script with some flags on the data.
    Parameters:
        $sScript: Script function name.
        $aScriptArgs: Function parameters.
        $b2ndData: Use a temporary data to store new Data
        $aSaveData: Save data specified as one of the element into primary global data $g_aData
        $aKeepData: Keep data from primary global data to the temporary data
    Return:

#ce
Func _RunScript($sScript, $aScriptArgs, $b2ndData = True, $aSaveData = Null, $aKeepData = Null)
    If _Sleep(10) Then Return False
    Log_Level_Add("_RunScript")
    Local $sSaveData = $aSaveData; Stores string version of aSaveData
    If isArray($aSaveData) Then $sSaveData = _ArrayToString($aSaveData, ",")

    Local $sKeepData = $aKeepData; Stores string version of aKeepData
    If isArray($aKeepData) Then $sKeepData = _ArrayToString($aKeepData, ",")
    Log_Add("Running script= Script:" & $sScript & ", Use 2nd Data: " & $b2ndData & ", Save Data: " & $sSaveData & ", Keep Data: " & $sKeepData, $LOG_DEBUG)

    ;Defining variables
    $bOutput = True

    ;Temporarily save Data
    If $b2ndData = True Then
        Local $t_aData = $g_aData
        Data_Clear()

        Local $t_aOrder = $g_aOrder
        Data_Order_Clear()

        If $aKeepData <> "Null" Then
            If isArray($aKeepData) = False Then $aKeepData = StringSplit($aKeepData, ",", $STR_NOCOUNT)
            For $i = 0 To UBound($aKeepData)-1
                For $x = 0 To UBound($t_aData)-1
                    Local $aSub = $t_aData[$x]
                    If $aSub[0] = $aKeepData[$i] Then
                        Data_Add($aSub[0], $aSub[1], $aSub[2])
                        Data_Order_Add($aSub[0])
                    EndIf
                Next
            Next
        EndIf

        Data_Display_Update()
    EndIf

    _ArrayInsert($aScriptArgs, 0, "CallArgArray")
    Local $vOutput = Call(StringReplace($sScript, " ", "_"), $aScriptArgs)

    ;Reset global Data back to before calling the function
    If $b2ndData = True Then
        Local $aSave = $g_aData
        $g_aData = $t_aData
        $g_aOrder = $t_aOrder

        ;Find data from temporary Data and append into $g_aData and $g_aOrder
        If $aSaveData <> Null Then
            If isArray($aSaveData) = False Then
                $aSaveData = StringSplit($aSaveData, ",", $STR_NOCOUNT)
            EndIf

            If isArray($aSaveData) = True Then
                For $x = 0 To UBound($aSaveData)-1
                    For $i = 0 To UBound($aSave)-1
                        Local $aSub = $aSave[$i]
                        If $aSaveData[$x] = $aSub[0] Then
                            Data_Add($aSub[0], $aSub[1], $aSub[2])
                            Data_Order_Add($aSub[0])
                        EndIf
                    Next
                Next
            EndIf
        EndIf

        Data_Display_Update()
    EndIf

    If @error = 0xDEAD And @extended = 0xBEEF Then
        Log_Add("Function for the script does not exist or does not meet parameter count: " & StringReplace($g_sScript, " ", "_"), $LOG_ERROR)
        $bOutput = False
    EndIf
    
    Log_Add("Script result: " & $bOutput & ", " & $vOutput & ".", $LOG_DEBUG)
    Log_Level_Remove()
    Return $bOutput
EndFunc