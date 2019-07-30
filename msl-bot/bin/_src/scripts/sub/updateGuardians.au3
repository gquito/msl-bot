#include-once
#include "../../imports.au3"

Func updateGuardians()
    Local $sCurrentVersion ;Store current version of the guardian dungeon images.
    If FileExists(@ScriptDir & "\bin\images\misc\guardian-info.txt") Then
        $sCurrentVersion = FileRead(@ScriptDir & "\bin\images\misc\guardian-info.txt")
    Else
        $sCurrentVersion = "-1"
    EndIf

    Local $sRemoteVersion = BinaryToString(INetRead("https://raw.githubusercontent.com/GkevinOD/msl-bot/version-check/msl-bot/guardian-dungeons/info.txt", $INET_FORCERELOAD))
    If Int($sCurrentVersion) <> Int($sRemoteVersion) Then
        Log_Add("New guardian dungeon images detected, downloading new images..", $LOG_INFORMATION)
        
        InetGet("https://raw.githubusercontent.com/GkevinOD/msl-bot/version-check/msl-bot/guardian-dungeons/misc-guardian-left.bmp", @ScriptDir & "\bin\images\misc\misc-guardian-left.bmp", $INET_FORCERELOAD, $INET_DOWNLOADWAIT)
        InetGet("https://raw.githubusercontent.com/GkevinOD/msl-bot/version-check/msl-bot/guardian-dungeons/misc-guardian-left2.bmp", @ScriptDir & "\bin\images\misc\misc-guardian-left2.bmp", $INET_FORCERELOAD, $INET_DOWNLOADWAIT)
        InetGet("https://raw.githubusercontent.com/GkevinOD/msl-bot/version-check/msl-bot/guardian-dungeons/misc-guardian-left3.bmp", @ScriptDir & "\bin\images\misc\misc-guardian-left3.bmp", $INET_FORCERELOAD, $INET_DOWNLOADWAIT)
        InetGet("https://raw.githubusercontent.com/GkevinOD/msl-bot/version-check/msl-bot/guardian-dungeons/misc-guardian-left4.bmp", @ScriptDir & "\bin\images\misc\misc-guardian-left4.bmp", $INET_FORCERELOAD, $INET_DOWNLOADWAIT)
        InetGet("https://raw.githubusercontent.com/GkevinOD/msl-bot/version-check/msl-bot/guardian-dungeons/misc-guardian-right.bmp", @ScriptDir & "\bin\images\misc\misc-guardian-right.bmp", $INET_FORCERELOAD, $INET_DOWNLOADWAIT)
        InetGet("https://raw.githubusercontent.com/GkevinOD/msl-bot/version-check/msl-bot/guardian-dungeons/misc-guardian-right2.bmp", @ScriptDir & "\bin\images\misc\misc-guardian-right2.bmp", $INET_FORCERELOAD, $INET_DOWNLOADWAIT)
        InetGet("https://raw.githubusercontent.com/GkevinOD/msl-bot/version-check/msl-bot/guardian-dungeons/misc-guardian-right3.bmp", @ScriptDir & "\bin\images\misc\misc-guardian-right3.bmp", $INET_FORCERELOAD, $INET_DOWNLOADWAIT)
        InetGet("https://raw.githubusercontent.com/GkevinOD/msl-bot/version-check/msl-bot/guardian-dungeons/misc-guardian-right4.bmp", @ScriptDir & "\bin\images\misc\misc-guardian-right4.bmp", $INET_FORCERELOAD, $INET_DOWNLOADWAIT)

        Log_Add("Finished updating guardian dungeon images.", $LOG_INFORMATION)

        Local $hFile = FileOpen(@ScriptDir & "\bin\images\misc\guardian-info.txt", 10) ;Store handle to file
        FileWrite($hFile, $sRemoteVersion)
        FileClose($hFile)
    EndIf
EndFunc

Func updateGuardiansFromDungeon()
    If (Not(isLocation("guardian-dungeons"))) Then 
        If (Not(navigate("guardian-dungeons",True,3))) Then Return buildNavOutput(-1, False)
    EndIf

    If (Not(FileExists(@ScriptDir & "\bin\images\misc\misc-guardian-left2.bmp"))) Then 
        Local $aImageLeft = findImage("misc-guardian-left", 90, 0, 312, 174, 138, 58, True, True)
        Local $aImageRight = findImage("misc-guardian-right", 90, 0, 312, 174, 138, 58, True, True)
        If (isArray($aImageLeft)) Then
            If (isArray($aImageRight)) Then Return True
        EndIf
    EndIf

    DeleteOldGuardianImages()

    captureRegion("bin\images\misc\misc-guardian-left", 328, 180, 44, 40)
    captureRegion("bin\images\misc\misc-guardian-right", 391, 180, 44, 40)
    captureRegion()
    Return True
EndFunc

Func DeleteOldGuardianImages()
    Local $t_leftFile = @ScriptDir & "\bin\images\misc\misc-guardian-left"
    Local $t_rightFile = @ScriptDir & "\bin\images\misc\misc-guardian-right"
    Local $t_fileType = ".bmp"
    If (FileExists($t_leftFile & $t_fileType)) Then FileDelete($t_leftFile & $t_fileType)
    If (FileExists($t_rightFile & $t_fileType)) Then FileDelete($t_rightFile & $t_fileType)
    For $i = 1 To 5
        If (FileExists($t_leftFile & $i & $t_fileType)) Then FileDelete($t_leftFile & $i & $t_fileType)
        If (FileExists($t_rightFile & $i & $t_fileType)) Then FileDelete($t_rightFile & $i & $t_fileType)
    Next
    If (FileExists(@ScriptDir & "\bin\images\misc\guardian-info.txt")) Then FileDelete(@ScriptDir & "\bin\images\misc\guardian-info.txt")
EndFunc