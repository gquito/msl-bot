#include-once

;Name must not have whitespace and must be a function. Ex: "Farm_Golem"
;Param [optional] must have same number of settings
Func _RunScript($sName, $aParam = Null, $aStats = Null)
    Log_Level_Add("_RunScript")
    Local $aOutput = Null

    Local $aConfig = Script_DataByName($sName)
    If StringLeft($sName, 1) <> "_" And $aConfig <> "" Then
        Local $aSettings = formatArgs(Script_DataByName($sName)[2])
        Local $bError = False

        ;-Create variables for parameters
        If $aParam <> Null Then
            Local $iSize = UBound($aParam)
            If $iSize = UBound($aSettings) Then
                For $i = 0 To $iSize-1
                    Assign($sName & "_" & $aSettings[$i][0], $aParam[$i], 2)
                Next
            Else
                Log_Add("Number of parameters does not match.", $LOG_ERROR)
                $bError = True
            EndIf
        EndIf
        ;---------------------------------
    
        If $bError = False Then 
            $aOutput = Call($sName, ($aParam=Null), $aStats)
        EndIf
        
        If (@error = 0xDEAD And @extended = 0xBEEF) Then
            Log_Add("Could not run script: " & $sName, $LOG_ERROR)
        EndIf
    Else
        Log_Add("Script does not exist or is not valid.", $LOG_ERROR)
    EndIf
    
    Log_Add("_RunScript (" & $sName & ") has ended.", $LOG_DEBUG)
    Log_Level_Remove()
    Return $aOutput
EndFunc