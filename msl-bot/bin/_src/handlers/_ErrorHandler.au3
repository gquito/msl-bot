;#=#INDEX#==================================================================#
;#  Title .........: _Error Handler.au3  v 1.2                              #
;#  Description....: AutoIt3 Error Handler & Debugger                       #
;#  Date ..........: 7.9.08                                                 #
;#  Authors .......: jennico (jennicoattminusonlinedotde)                   #
;#                   @MrCreatoR                                             #
;#                   MadExcept (GUI inspiration by mrRevoked)               #
;#==========================================================================#

#include-once
#include <INet.au3>
#include <Date.au3>
#include <File.au3>
#include "_eMail.au3"

Dim $s_msg,$s_icn[5],$s_lb1[5],$s_lb2[5],$s_old=1

_OnAutoItError()

;#=#Function#===============================================================#
;#  Name ..........: _OnAutoItError ( )                                     #
;#  Description....: AutoIt3 Error Handler & Debugger GUI                   #
;#  Parameters.....: (None)                                                 #
;#  Date ..........: 7.9.08                                                 #
;#  Authors .......: jennico (jennicoattminusonlinedotde)                   #
;#                   @MrCreatoR                                             #
;#                   MadExcept (GUI inspiration by mrRevoked)               #
;#==========================================================================#

;   this function is made to be customized !

Func _OnAutoItError()
    If (StringInStr($CmdLineRaw,"/AutoIt3ExecuteScript")) Then Return
    Opt("TrayIconHide",1)   ;   run a second instance
    Local $iPID=Run(@AutoItExe&' /ErrorStdOut /AutoIt3ExecuteScript "'&@ScriptFullPath&'"',@ScriptDir,0,6)
    Local $sErrorMsg,$GUI=GUICreate(@ScriptName,385,90,Default,Default,-2134376448)
        GUISetBkColor(0xE0DFE2) ;BitOR($WS_CAPTION,$WS_POPUP,$WS_SYSMENU)
        GUICtrlCreateIcon("user32.dll",103,11,11,32,32)
        GUICtrlSetBkColor(GUICtrlCreateLabel("",1,1,383,1),0x41689E)
        GUICtrlSetBkColor(GUICtrlCreateLabel("",1,88,383,1),0x41689E)
        GUICtrlSetBkColor(GUICtrlCreateLabel("",1,1,1,88),0x41689E)
        GUICtrlSetBkColor(GUICtrlCreateLabel("",383,1,1,88),0x41689E)
        GUICtrlSetBkColor(GUICtrlCreateLabel("An error occurred in the application.",52,21,175,15),-2)
        $s_lb1[0]=GUICtrlCreateLabel("",10,60,110,22)
            GUICtrlSetBkColor(-1,0xEFEEF2)
            GUICtrlSetState(-1,128)
        $s_lb2[0]=GUICtrlCreateLabel("   send bug report",28,64,92,15)
            GUICtrlSetBkColor(-1,-2)
            GUICtrlSetCursor(-1,0)
        $s_icn[0]=GUICtrlCreateIcon("explorer.exe",254,13,63,16,16)
            GUICtrlSetCursor(-1,0)
        $s_lb1[1]=GUICtrlCreateLabel("",126,60,114,22)
            GUICtrlSetBkColor(-1,0x706E63)
            GUICtrlSetState(-1,128)
        $s_lb2[1]=GUICtrlCreateLabel("   show bug report",145,64,95,15)
            GUICtrlSetColor(-1,0xFFFFFF)
            GUICtrlSetBkColor(-1,-2)
            GUICtrlSetCursor(-1,0)
        $s_icn[1]=GUICtrlCreateIcon("shell32.dll",-81,129,63,16,16)
            GUICtrlSetImage(-1,"shell32.dll",23)
            GUICtrlSetCursor(-1,0)
        $s_lb1[2]=GUICtrlCreateLabel("",246,8,131,22)
            GUICtrlSetBkColor(-1,0xEFEEF2)
            GUICtrlSetState(-1,128)
        $s_lb2[2]=GUICtrlCreateLabel("   continue application",265,12,115,15)
            GUICtrlSetBkColor(-1,-2)
            GUICtrlSetCursor(-1,0)
        $s_icn[2]=GUICtrlCreateIcon("shell32.dll",290,249,11,16,16)
            GUICtrlSetCursor(-1,0)
        $s_lb1[3]=GUICtrlCreateLabel("",246,34,131,22)
            GUICtrlSetBkColor(-1,0xEFEEF2)
            GUICtrlSetState(-1,128)
        $s_lb2[3]=GUICtrlCreateLabel("    restart application",265,38,115,15)
            GUICtrlSetBkColor(-1,-2)
            GUICtrlSetCursor(-1,0)
        $s_icn[3]=GUICtrlCreateIcon("shell32.dll",255,249,37,16,16)
            GUICtrlSetCursor(-1,0)
        $s_lb1[4]=GUICtrlCreateLabel("",246,60,131,22)
            GUICtrlSetBkColor(-1,0xEFEEF2)
            GUICtrlSetState(-1,128)
        $s_lb2[4]=GUICtrlCreateLabel("     close application",265,64,115,15)
            GUICtrlSetBkColor(-1,-2)
            GUICtrlSetCursor(-1,0)
        $s_icn[4]=GUICtrlCreateIcon("shell32.dll",240,249,63,16,16)
            GUICtrlSetCursor(-1,0)
    ProcessWait($iPID)
    While 1 ;   trap the error message
        $sErrorMsg&=StdoutRead($iPID)
        If (@error) Then ExitLoop
        Sleep(1)
    WEnd
    
    ;Need to parse because the STDOUT reads from ADB stdout as well.===
    Local $aSTDOUT_List = StringSplit($sErrorMsg, @CRLF)

    Local $bScriptWasRunning = False
    Local $bGotInfo = False
    Local $sParsed = ""

    For $i = $aSTDOUT_List[0] To 1 Step -1
        If (StringInStr($aSTDOUT_List[$i], "^ ERROR")) Then
            If ($i-4 >= 1) Then $sParsed &= $aSTDOUT_List[$i-4] & @CRLF & $aSTDOUT_List[$i-2] & @CRLF & $aSTDOUT_List[$i]
        EndIf

        If (StringInStr($aSTDOUT_List[$i], "~> Info stop")) Then $bGotInfo = True
        If (StringInStr($aSTDOUT_List[$i], "~> Script stopped") And Not($bGotInfo)) Then $bScriptWasRunning = True
    Next

    If ($sParsed <> "") Then ;has an error
        Local $sVersion = $aSTDOUT_List[1]
        $sParsed &= @CRLF & @CRLF & "=Script info=" & @CRLF
        $sParsed &= "Version: v" & $sVersion & @CRLF
        
        Local $aInfo_CONST = ["Current Script:", "Emulator Class:", "Emulator Instance:", "ADB Method:", "Display Scaling:", "Capture Mode:", "Mouse Mode:", "Swipe Mode:"]
        If (Not($bScriptWasRunning)) Then
            ;Adding script info to error message.
            For $i = $aSTDOUT_List[0] To 1 Step -1
                For $str In $aInfo_CONST
                    If (StringInStr($aSTDOUT_List[$i], $str)) Then $sParsed &= $aSTDOUT_List[$i] & @CRLF
                Next
                If (StringInStr($aSTDOUT_List[$i], "~> Info stop")) Then ExitLoop
            Next
        EndIf
    EndIf
    ;====

    $sErrorMsg = $sParsed
    If ($sErrorMsg="") Then Exit

    GUISetState()
    Opt("TrayIconHide",0)
    Opt("TrayAutoPause",0)
    WinSetOnTop(@ScriptName,"",1)
    SoundPlay(@WindowsDir&"\Media\chord.wav")
    TraySetToolTip(@ScriptName&@CRLF&"An error occurred in the application.")
    Do  ;   choose action to be taken
        Dim $s_msg=GUIGetMsg(),$mse=GUIGetCursorInfo($GUI)
        If (@error=0) Then
            For $i=0 To 4
                If ($i<>$s_old And ($mse[4]=$s_lb1[$i] Or $mse[4]=$s_lb2[$i] Or _
                    $mse[4]=$s_icn[$i])) Then __Select($i)
            Next
        EndIf
        If (WinActive($GUI) And $s_msg=0) Then
            HotKeySet("{ENTER}","__Hotkey")
            HotKeySet("{RIGHT}","__Hotkey")
            HotKeySet("{LEFT}","__Hotkey")
            HotKeySet("{DOWN}","__Hotkey")
            HotKeySet("{TAB}","__Hotkey")
            HotKeySet("{UP}","__Hotkey")
        Else
            HotKeySet("{ENTER}")
            HotKeySet("{RIGHT}")
            HotKeySet("{LEFT}")
            HotKeySet("{DOWN}")
            HotKeySet("{TAB}")
            HotKeySet("{UP}")
        EndIf
        If ($s_msg=$s_lb2[2] Or $s_msg=$s_icn[2]) Then MsgBox(270400,"Continue Application", _
            "I am afraid, not possible with AutoIt !     "&@CRLF&@CRLF& _
            "( No GoTo command )      :-( ")
        If ($s_msg=$s_lb2[0] Or $s_msg=$s_icn[0]) Then 
            MsgBox(270400,"Send Bug Report", "Email successfully sent !     ")
            #region SMTPInfo
                Local $SmtpServer = "smtp.gmail.com"          ; address for the smtp-server to use - REQUIRED
                Local $FromName = "Msl Bot"                   ; name from who the email was sent
                Local $FromAddress = "MslAutoBot@gmail.com"   ; address from where the mail should come
                Local $ToAddress = "MslAutoBot@gmail.com"   ; destination address of the email - REQUIRED
                Local $Subject = "v" & $sVersion & " - Bug Report"                 ; subject from the email - can be anything you want it to be
                Local $Body = $sErrorMsg                      ; the messagebody from the mail - can be left blank but then you get a blank mail
                Local $sFileOpenDialog = FileOpenDialog("Please attach the most recent log file.",@ScriptDir & "/" & "profiles", "All (*.*)|Text files (*.txt)", $FD_FILEMUSTEXIST)
                Local $AttachFiles = ""
                If (Not(@error)) Then $AttachFiles = $sFileOpenDialog           ; the file(s) you want to attach
                Local $CcAddress = ""                         ; address for cc - leave blank if not needed
                Local $BccAddress = ""                        ; address for bcc - leave blank if not needed
                Local $Importance = "Normal"                  ; Send message priority: "High", "Normal", "Low"
                Local $Username = "MslAutoBot@gmail.com"      ; username for the account used from where the mail gets sent - REQUIRED
                Local $Password = "MslBotPass"                ; password for the account used from where the mail gets sent - REQUIRED
                Local $IPPort=465                             ; GMAIL port used for sending the mail
                Local $ssl=1                                  ; GMAILenables/disables secure socket layer sending - put to 1 if using httpS
            #endregion
            Local $rc = _INetSmtpMailCom($SmtpServer, $FromName, $FromAddress, $ToAddress, $Subject, $Body, $AttachFiles, $CcAddress, $BccAddress, $Importance, $Username, $Password, $IPPort, $ssl)
            If (@error) Then
                MsgBox(0, "Error sending message", "Error code:" & @error & "  Description:" & $rc)
                Exit
            EndIf
            ; Local $iResponse = _INetSmtpMail("smtp.blazenet.net", "MSL BUG BOT", "mslbugbot@gmail.com", "eckserah@gmail.com" , "Bug found at: " & _DateTimeFormat(_NowCalc(), 1), $sErrorMsg)
            ; Local $iErr = @error
            ; If $iResponse = 1 Then
                ; MsgBox(270400,"Send Bug Report", "Email successfully sent !     ")
            ; Else
                ; MsgBox($MB_SYSTEMMODAL, "Error!", "Mail failed with error code " & $iErr)
            ; EndIf
        EndIf
        If ($s_msg=$s_lb2[1] Or $s_msg=$s_icn[1]) Then MsgBox(270400,"Show Bug Report",$sErrorMsg&"    ")
    Until $s_msg=-3 Or $s_msg=$s_lb2[3] Or $s_msg=$s_icn[3] Or $s_msg=$s_lb2[4] Or $s_msg=$s_icn[4]
    If ($s_msg=$s_lb2[3] Or $s_msg=$s_icn[3]) Then Run(@AutoItExe&' "'&@ScriptFullPath& _
        '"',@ScriptDir,0,6)
    SoundPlay(@WindowsDir&"\Media\start.wav")
    Exit
EndFunc

;#=#Function#===============================================================#
;#  Name ..........: __Debug ( $txt )                                       #
;#  Description....: Debug Function for _ErrorHandler.au3                   #
;#  Parameters.....: $txt = Error Message Text from StdoutRead              #
;#  Date ..........: 7.9.08                                                 #
;#  Authors .......: jennico (jennicoattminusonlinedotde)                   #
;#==========================================================================#

Func __Debug($txt)
    WinSetState(@ScriptName,"",@SW_HIDE)
    $a=StringSplit($txt,@CRLF,1)
    Dim $b=StringSplit($a[1],") : ==> ",1),$number=StringMid($b[1],StringInStr($b[1],"(")+1)
    Dim $code="Error Code: "&@TAB&StringTrimRight($b[2],2),$line="Line: "&@TAB&$number&" => "&$a[3]
    Dim $file="File: "&@TAB&StringReplace($b[1]," ("&$number,""),$count=StringLen($code),$height=180
    If (StringLen($file)>$count) Then $count=StringLen($file)
    If (StringLen($line)>$count) Then $count=StringLen($line)
    If (StringLen($a[2])>$count) Then $count=StringLen($a[2])
    If ($count*6>@DesktopWidth-50) Then Dim $count=(@DesktopWidth-50)/6,$height=240
    Run(RegRead("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\SciTE.exe","")& _
        ' "'&@ScriptFullPath&'" /goto:'&$number&","&StringLen($a[2])-1)
    $x=InputBox(" Please Correct this line:",$code&@CRLF&@CRLF&$file&@CRLF&@CRLF& _
        $line,StringTrimRight($a[2],1),"",$count*6,$height)
    WinSetState(@ScriptName,"",@SW_SHOW)
    If ($x="" Or $x=StringTrimRight($a[2],1)) Then Return
    $t=StringSplit(FileRead(@ScriptFullPath),@CRLF,1)
    $t[$number]=StringReplace($t[$number],StringTrimRight($a[2],1),$x)
    $open=FileOpen(@ScriptFullPath,2)
    For $i=1 to $t[0]
        FileWriteLine($open,$t[$i])
    Next
    FileClose($open)
    ControlSend(@ScriptDir,"","ToolbarWindow32","^R")
EndFunc

;#=#Function#===============================================================#
;#  Name ..........: __Select ( $i )                                        #
;#  Description....: Select Function for _ErrorHandler.au3                  #
;#  Parameters.....: $i = Element from Mouse Hover ID                       #
;#  Date ..........: 7.9.08                                                 #
;#  Authors .......: jennico (jennicoattminusonlinedotde)                   #
;#==========================================================================#

Func __Select($i)
    GUICtrlSetBkColor($s_lb1[$i],0x706E63)
    GUICtrlSetColor($s_lb2[$i],0xFFFFFF)
    GUICtrlSetBkColor($s_lb1[$s_old],0xEFEEF2)
    GUICtrlSetColor($s_lb2[$s_old],0)
    $s_old=$i
EndFunc

;#=#Function#===============================================================#
;#  Name ..........: __Hotkey ( )                                           #
;#  Description....: Hotkey Functions for _ErrorHandler.au3                 #
;#  Parameters.....: None                                                   #
;#  Date ..........: 7.9.08                                                 #
;#  Authors .......: jennico (jennicoattminusonlinedotde)                   #
;#==========================================================================#

Func __Hotkey()
    If (@HotKeyPressed="{DOWN}" And $s_old>1 And $s_old<4) Then __Select($s_old+1)
    If (@HotKeyPressed="{RIGHT}" And $s_old<2) Then __Select(1+3*($s_old=1))
    If (@HotKeyPressed="{TAB}") Then __Select(($s_old+1)*($s_old<4))
    If (@HotKeyPressed="{LEFT}" And $s_old) Then __Select($s_old>1)
    If (@HotKeyPressed="{UP}" And $s_old>2) Then __Select($s_old-1)
    If (@HotKeyPressed="{ENTER}") Then $s_msg=$s_icn[$s_old]
EndFunc