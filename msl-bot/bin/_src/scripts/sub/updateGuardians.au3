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