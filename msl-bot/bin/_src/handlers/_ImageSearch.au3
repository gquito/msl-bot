#include-once

; == FUNCTION LIST:
;   _ImageSearch()
;   _ImagesSearch()
;   _ImageSearchMultiple()
; ==

;Uses FindImage function from ImageSearchLibrary.dll to find a single image.
;
;   Parameters:
;       - $sImage: Full path to template image.
;       - $iTolerance: 0-100% matching.
;       - $iLeft, $iTop, $iWidth, $iHeight: Dimensions of the source image.
;       - $bCenter: Returns center of found image. Otherwise, returns left-top of location.
;       - $bUpdateBMP: Updates source image. When false, uses $g_hHBitmap for source image.
;       - $sSourcePath: Path to source image.
;       - $bUseColor: Default uses a single channel. This option enables comparison for color channels.
;   Return:
;       On success, Point Array if found, 0 if not found.
;       On error, <0 values..
;   Error Codes:
;       -1: Template image does not exist.
;       -2: ImageSearch Library could not be accessed.
;       -3: DllCall error.
;       -4: ImageSearch function did not work.
Func _ImageSearch($sImage, $bMultiple = False, $iTolerance = 95, $iLeft = 0, $iTop = 0, $iWidth = 800, $iHeight = 552, $bCenter = True, $bUpdateBMP = True, $sSourcePath = "", $bUseColor = False)
    ;SourcePath: \bin\images\temp\currentCapture.bmp
    ;Log_Add("ImageSearch Attempt: Tolerance:" & $iTolerance & "|Path:" & $sImage & "|" & $iLeft & "," & $iTop & "," & $iWidth & "," & $iHeight, $LOG_DEBUG)

    ;For compatibility
    $iLeft = Number($iLeft)
    $iTop = Number($iTop)
    $iWidth = Number($iWidth)
    $iHeight = Number($iHeight)
    $iTolerance = Number($iTolerance)

    ;== Precoditions ==
    If (Not(FileExists($sImage))) Then
        Log_Add("Imagesearch Error: '"  & $sImage & "' does not exist.", $LOG_ERROR)
        Return -1
    EndIf

    ;== Update bitmap ==
    If ($sSourcePath == "") Then
        ;Use HBITMAP
        If ($bUpdateBMP) Then CaptureRegion("", $iLeft, $iTop, $iWidth, $iHeight)
    Else
        ;Use string path to source image file.
        If ($bUpdateBMP) Then
            CaptureRegion($sSourcePath, $iLeft, $iTop, $iWidth, $iHeight)
        Else
            saveHBitmap($sSourcePath)
        EndIf
    EndIf

    ;== ImageSearch ==
    Local $aResult = _FindImage($sSourcePath, $sImage, $iTolerance, $iLeft, $iTop, $iWidth, $iHeight, $bUseColor, $bMultiple)
    If ($aResult = -2 Or $aResult = -3) Then Return $aResult

    ; == Parsing result ==
    Local $tResult = ProcessImageReturn($aResult, $iLeft, $iTop, $bCenter, $sImage, $bMultiple)
    Local $aImageResult = $aResult ;Raw results
    If ($tResult = -5) Then
        Local $iCounter = 0
        While $tResult = -5 And $iCounter < 5
            $aImageResult = _FindImage($sSourcePath, $sImage, $iTolerance, $iLeft, $iTop, $iWidth, $iHeight, $bUseColor, $bMultiple)
            $tResult = ProcessImageReturn($aImageResult, $iLeft, $iTop, $bCenter, $sImage, $bMultiple)
            $iCounter += 1
        WEnd
    EndIf

    If ($tResult = -5) Then
        ScriptTest_Handles()
        Local $sError = StringFormat("_ImageSearch Error: Parameters (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)", $sImage, $bMultiple, $iTolerance, $iLeft, $iTop, $iWidth, $iHeight, $bCenter, $bUpdateBMP, $sSourcePath, $bUseColor)
        Log_Add($sError, $LOG_ERROR)
    EndIf

    Return $tResult
EndFunc

Func ProcessImageReturn($aResult, $iLeft, $iTop, $bCenter, $sImage, $bMultiple = False)
    If isArray($aResult) <= 0 Or UBound($aResult) = 0 Then
        If ($aResult == "0" Or $aResult == "") Or ($aResult = 0 Or $aResult = -1) Then Return 0
        Log_Add("Imagesearch Error: ImageSearch did not work. aResult = " & $aResult, $LOG_ERROR)
        Return -4
    Else
        Local $aSplitResult = StringSplit($aResult[0], "|", $STR_NOCOUNT) ;Converts to actual result
        ; count, width, height, x1, y1, tolerance_found1, x2, y2, tolerance_found2...
        If ($aSplitResult[0] == "0" Or $aSplitResult[0] == "") Or ($aSplitResult[0] == "-1" Or $aSplitResult[0] = -1) Then Return 0 ; Not Found

        If UBound($aSplitResult) < 5 Then
            ;_ArrayDisplay($aResult) ;DEBUG
            ;_ArrayDisplay($aSplitResult) ;DEBUG
            Local $sError = StringFormat("ProcessImageReturn Error: Invalid array size (Result Size = %d)", UBound($aSplitResult))
            Log_Add($sError, $LOG_ERROR)
            Return -5
        EndIf

        If ($bMultiple) Then
            Local $iCount = $aSplitResult[0]
            Local $aTemplateSize = [$aSplitResult[1], $aSplitResult[2]]

            $g_iExtended = $iCount ;Extended info count.

            Local $aPoints[$iCount][2]
            Local $tempCount = 0  ;For $aPoints

            For $i = 3 To UBound($aSplitResult)-1 Step 3
                if ($i+1 >= UBound($aSplitResult)) Then
                    ;Log_Add("$i = " & $i+1 & ", $aResult = " & Ubound($aSplitResult) & ", Result = " & $tmpResult, $LOG_DEBUG)
                    ExitLoop
                EndIf
                $aPoints[$tempCount][0] = Number($aSplitResult[$i])+$iLeft
                $aPoints[$tempCount][1] = Number($aSplitResult[$i+1])+$iTop

                If ($bCenter > 0) Then
                    $aPoints[$tempCount][0] = $aPoints[$tempCount][0] + Int($aTemplateSize[0]/2)
                    $aPoints[$tempCount][1] = $aPoints[$tempCount][1] + Int($aTemplateSize[1]/2)
                EndIf

                ;Log_Add("Image found at (" & $aPoints[$tempCount][0] & ", " & $aPoints[$tempCount][1] & ") -> " & $sImage, $LOG_DEBUG)
                $tempCount += 1
            Next

            Return $aPoints
        Else
            Local $aPoint[2] = [Number($aSplitResult[3])+$iLeft, Number($aSplitResult[4])+$iTop] ;Found point

            If ($bCenter > 0) Then
                $aPoint[0] = $aPoint[0] + Int($aSplitResult[1]/2)
                $aPoint[1] = $aPoint[1] + Int($aSplitResult[2]/2)
            EndIf
            Log_Add("Image found at (" & $aPoint[0] & ", " & $aPoint[1] & ") -> " & $sImage, $LOG_DEBUG)
            Return $aPoint
        EndIf
    EndIf
EndFunc

;Image search for multiple images. See _ImageSearch for more detail.
;   Parameters:
;       - $aImages: String array of full paths of each image.
;       - $iIndex: Output for found image index in $aImages.
Func _ImagesSearch($aImages, ByRef $iIndex,  $iTolerance = 95, $iLeft = 0, $iTop = 0, $iWidth = 800, $iHeight = 552, $bCenter = True, $bUpdateBMP = True, $sSourcePath = "", $bUseColor = False)
    If isArray($aImages) <= 0 Then
        Log_Add("_ImagesSearch Error: aImages parameter is not an array.", $LOG_ERROR)
        Return -1
    Else
        For $i = 0 To UBound($aImages)-1
            Local $vResult = _ImageSearch($aImages[$i], False, $iTolerance, $iLeft, $iTop, $iWidth, $iHeight, $bCenter, $bUpdateBMP, $sSourcePath, $bUseColor)
            If (isArray($vResult)) Then
                $iIndex = $i
                Return $vResult ;Point array.
            Else
                If ($vResult < 0) Then Return $vResult
            EndIf

            $bUpdateBMP = False ;Update only once
        Next

        Return 0
    EndIf
EndFunc

Global $g_hImageSearch = DllOpen($g_sImageSearchPath)
Func _FindImage($sSourcePath = "", $sImage = "", $iTolerance = 95, $iLeft = 0, $iTop = 0, $iWidth = 800, $iHeight = 552, $bUseColor = False, $bMultiple = False)
    If $g_hImageSearch = -1 Then
        $g_hImageSearch = DllOpen($g_sImageSearchPath)
        If $g_hImageSearch = -1 Then
            Log_Add("Imagesearch error: Could not open DLL.", $LOG_ERROR)
            Return -2
        EndIf
    EndIf

    Local $aResult ;Raw results
    If $sSourcePath == "" Then
        $aResult = DllCall(Eval("g_hImageSearch"), "wstr:cdecl", "FindImageEX", "handle", $g_hHBitmap, "int", $iWidth, "int", $iHeight, "str", $sImage, "int", $iTolerance, "bool", Not($bUseColor), "bool", True, "bool", True)
    Else
        $aResult = DllCall(Eval("g_hImageSearch"), "wstr:cdecl", "FindImage", "str", @ScriptDir & $sSourcePath, "str", $sImage, "int", $iTolerance, "bool", Not($bUseColor), "bool", True, "bool", True)
    EndIf

    If (@error <> 0) Then
        Log_Add("Imagesearch Error: DllCall Error code " & @error & ".", $LOG_ERROR)
        Return -4
    EndIf

    Return $aResult
 EndFunc