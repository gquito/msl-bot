#include-once
#include "../../imports.au3"

Func capture($aImages, ByRef $iAstrochips, $bLog = False)
    If getLocation() <> "capture-mode" Then Return False

    ;Format images to [image, image, image]
    If isArray($aImages) = False Then
        For $
    EndIf

    If $bLog Then addLog($g_aLog, "Beginning to catch astromons.", $LOG_NORMAL)
    If $bLog Then addLog($g_aLog, "-Looking for astromons.", $LOG_NORMAL)
EndFunc