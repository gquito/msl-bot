#include-once
#include "../imports.au3"

Global $Gems_To_Farm, $Catch_Image, $Astromon, $Finish_Round, $Final_Round, $Release_Evo3, $Map, $Difficulty, $Stage_Level, $Capture, $Gems_To_Sell, $Usable_Astrogems, $Guardian_Mode, $Collect_Quests, $Hourly_Script
Func Farm_Gem($Gems_To_Farm, $Catch_Image, $Astromon, $Finish_Round, $Final_Round, $Release_Evo3, $Map, $Difficulty, $Stage_Level, $Capture, $Gems_To_Sell, $Usable_Astrogems, $Guardian_Mode, $Collect_Quests, $Hourly_Script)
    Log_Level_Add("Farm_Gem")
    Log_Add("Farm Gem has started.")
    
    ;Declaring variables and data
    If (StringLeft(StringLower($Gems_To_Farm), 1) = "g") Then
        $Gems_To_Farm = Floor(Int(StringMid($Gems_To_Farm, 2))/330000)*100
    EndIf

    Data_Add("Status", $DATA_TEXT, "")
    Data_Add("Farmed Gems", $DATA_RATIO, "0/" & $Gems_To_Farm)

    Data_Add("Refill", $DATA_RATIO, "0/" & $Usable_Astrogems, True)

    Data_Add("Need Catch", $DATA_NUMBER, "0")
    Data_Add("Error", $DATA_NUMBER, "0")

    ;Adding to display order
    Data_Order_Insert("Status", 0)
    Data_Order_Insert("Farmed Gems", 1)
    Data_Order_Insert("Refill", 2)

    Data_Display_Update()

    ;Script Process
    #cs 
        Script will evolve in monsters location and catch astromons using Farm_Astormon script.
    #ce
    While Data_Get_Ratio("Farmed Gems") < 1
        $g_bSellGems = True
        $g_aGemsToSell = $Gems_to_Sell

        If $Hourly_Script = "Enabled" Then Common_Hourly($g_sLocation)
        If _Sleep(10) Then ExitLoop

        ;Handles catching process
        While Data_Get("Need Catch") > 0
            Log_Add("Going to catch " & Data_Get("Need Catch") & " astromons.", $LOG_INFORMATION)

            Local $aArg = [Data_Get("Need Catch"), $Catch_Image, $Finish_Round, $Final_Round, $Map, $Difficulty, $Stage_Level, $Capture, $Gems_To_Sell, $Usable_Astrogems, $Guardian_Mode, $Collect_Quests, $Hourly_Script]
            _RunScript("Farm_Astromon", $aArg, True, "Refill," & $Catch_Image, "Farmed Gems,Refill")

            If _Sleep(10) Then ExitLoop(2)
            If getLocation() = "astromon-full" And $g_sLocation = "battle-astromon-full" Then
                Data_Set("Need Catch", "0")
                ExitLoop
            Else
                If (Data_Get_Ratio("Caught") < 1) Then
                    Log_Add("Something went wrong with Farm Astromon.", $LOG_ERROR)
                    ExitLoop(2)
                EndIf
            EndIf

            Data_Increment("Need Catch", "-" & Data_Get($Catch_Image, True)[0])
        WEnd

        ;Handles evolving process
        Data_Set("Status", "Evolving astromon.")
        Local $sAlgorithm = getArg($g_aGeneralSettings, "Evolve_Algorithm")
        
        If ($sAlgorithm = "Algorithm 2" And $Astromon <> "Slime") Then
            Log_Add("Unable to use algorithm 2 because it will only work on Slimes. Switching to algorithm 1.", $LOG_ERROR)
            $sAlgorithm = "Algorithm 1"
        EndIf
        Local $bReleaseEvo3 = False;
        If ($Release_Evo3 = "Enabled") Then $bReleaseEvo3 = True
        Switch $sAlgorithm
            Case "Algorithm 1"
                $vResult = evolve1($Astromon, True,$bReleaseEvo3)
                Switch $vResult
                    Case -1, -2, -3, -4, -6 ;Normal errors.
                        Log_Add("Could not evolve, error code: " & $vResult, $LOG_ERROR)
                        Data_Increment("Error", 1)
                        If Data_Get("Error") > 5 Then 
                            Log_Add("Too many errors has occurred.", $LOG_ERROR)
                            ExitLoop
                        EndIf
                    Case -5 ;No currency.
                        Log_Add("Not enough gold to procceed.", $LOG_ERROR)
                        ExitLoop
                    Case Else ;Success
                        If $vResult = 0 Then Data_Increment("Farmed Gems", 100)
                        Log_Add("Farmed Gems " & Data_Get("Farmed Gems"), $LOG_INFORMATION)
                        Data_Set("Need Catch", $vResult)
                EndSwitch
            Case "Algorithm 2", "Algorithm 3"
                Local $aResult = Null
                If ($sAlgorithm = "Algorithm 2") Then $aResult = evolve2($bReleaseEvo3)
                If ($sAlgorithm = "Algorithm 3") Then $aResult = evolve3($Astromon, 85, $bReleaseEvo3)
                Switch $aResult[0]
                    Case -2 ; Not enough gold
                        Log_Add($aResult[1])
                        ExitLoop
                    Case -1 ;General Error
                        Log_Add($aResult[1])
                        ExitLoop
                    Case 0
                        Log_Add($aResult[1])
                        Stat_Increment($g_aStats, "Gold spent", 330000)
                    Case Else
                        Local $iCatchAmount = $aResult[0]                            ; Not enough astromons
                        If (Data_Get("Need Catch") < 0) Then $iCatchAmount -= Data_Get("Need Catch")
                        Data_Increment("Need Catch", $iCatchAmount)
                EndSwitch
        EndSwitch
    WEnd

    $g_bSellGems = False
    $g_aGemsToSell = Null

    ;End script
    Log_Add("Farm Astromon has ended.")
    Log_Level_Remove()
EndFunc