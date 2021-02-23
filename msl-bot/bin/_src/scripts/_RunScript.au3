#include-once

;Name must not have whitespace and must be a function. Ex: "Farm_Golem"
;Param [optional] must have same number of settings
Func _RunScript($sName, $aParam = Null, $aStats = Null)
    Log_Level_Add("_RunScript")
    Local $aOutput = Null

    Local $aConfig = Script_DataByName($sName)
    If StringLeft($sName, 1) <> "_" And $aConfig <> "" Then
        ;Save State===========================
        Local $aCurrentParam[0][2]
        Local $aCurrentStats[0][2]

        Local $sCurrentScript = StringReplace($g_sScript, " ", "_")
        Local $aCurrentConfig = Script_DataByName($sCurrentScript)
        If isArray($aCurrentConfig) And UBound($aCurrentConfig) > 0 Then
            $aCurrentConfig = $aCurrentConfig[2] ;Get settings of script
            For $aSetting in $aCurrentConfig
                _ArrayAdd($aCurrentParam, $sCurrentScript & "_" & $aSetting[0] & "%" & Eval($sCurrentScript & "_" & $aSetting[0]), 0, "%")
            Next
            ;_ArrayDisplay($aCurrentParam)
        EndIf

        If isArray($g_aStats) And UBound($g_aStats) > 0 Then
            For $aStat In $g_aStats
                _ArrayAdd($aCurrentStats, $aStat[1] & "%" & Eval($aStat[1]), 0, "%")
            Next
            ;_ArrayDisplay($aCurrentStats)
        EndIf
        ;======================================

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
    
        If $bError = 0 Then 
            $aOutput = Call($sName, ($aParam=Null), $aStats)
        EndIf
        
        If (@error = 0xDEAD And @extended = 0xBEEF) Then
            Log_Add("Could not run script: " & $sName, $LOG_ERROR)
        Else
        ;Restore State===========================
            If isArray($aCurrentParam) And UBound($aCurrentParam) > 0 Then
                For $aArr In $aCurrentParam
                    Assign($aArr[0], $aArr[1], 2)
                Next
            EndIf
            If isArray($aCurrentStats) And UBound($aCurrentStats) > 0 Then
                For $aArr In $aCurrentStats
                    Assign($aArr[0], $aArr[1], 2)
                Next
            EndIf
            ;======================================
        EndIf
    Else
        Log_Add("Script does not exist or is not valid.", $LOG_ERROR)
    EndIf
    
    Log_Add("_RunScript (" & $sName & ") has ended.", $LOG_DEBUG)
    Log_Level_Remove()
    Return $aOutput
EndFunc