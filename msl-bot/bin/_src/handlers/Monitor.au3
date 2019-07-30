#include-once
#include "../imports.au3"

; ===================================================================================================================
; Func _GraphicsCreateDC($sDriver="DISPLAY",$sDevice=0,$pInitData=0)
;
; Function to create a Device Context. With default parameters, it will create a DC covering ALL monitors, rather
;    than getting only the default monitor with GetDC(0)
;    *NOTE: When done with the DC, must use DeleteDC on the returned DC (whereas GetDC uses ReleaseDC)
;
; Author: Ascend4nt
; ===================================================================================================================

Func _GraphicsCreateDC($sDriver="DISPLAY",$sDevice=0,$pInitData=0)
    If (Not(IsString($sDriver))) Then Return SetError(1,0,False)
    Local $aRet,$sDeviceType
    If ($sDevice="" Or Not(IsString($sDevice))) Then
        $sDeviceType="ptr"
        $sDevice=0
    Else
        $sDeviceType="wstr"
    EndIf
    $aRet=DllCall('gdi32.dll',"handle","CreateDCW","wstr",$sDriver,$sDeviceType,$sDevice,"ptr",0,"ptr",$pInitData)
    If (@error) Then Return SetError(2,@error,0)
    If ($aRet[0]=0) Then Return SetError(3,0,0)
    Return $aRet[0]
EndFunc

; ==========================================================================================================================
; Func _MonitorGetInfo($hMonitor,$hMonitorDC=0)
;
; Gets information about a monitor (given a monitor handle).
;
; $hMonitor = Handle to Monitor
; $hMonitorDC = Optional Monitor DC
;
; Returns:
;    Success: 10-element array, with @error=0:
;        $array[0]  = Monitor  upper-left corner X coordinate (this rect is same as full-screen size)
;        $array[1]  = Monitor  upper-left corner Y coordinate
;        $array[2]  = Monitor lower-right corner X coordinate
;        $array[3]  = Monitor lower-right corner Y coordinate
;        $array[4]  = Monitor Work Area  upper-left corner X coordinate (this rect is same as maximized size)
;        $array[5]  = Monitor Work Area  upper-left corner Y coordinate
;        $array[6]  = Monitor Work Area lower-right corner X coordinate
;        $array[7]  = Monitor Work Area lower-right corner Y coordinate
;        $array[8]  = Primary monitor boolean (0 = not, 1 = is)
;        $array[9]  = Monitor Or Display Device Name (usually '.DISPLAY#' where # starts at 1)
;        $array[10] = Bits Per Pixel
;        $array[11] = Vertical Refresh Rate
;    Failure: '' with @error set:
;        @error = 1 = invalid parameter
;        @error = 2 = DLLCall() error, with @extended set to DLLCall() error code (see AutoIt Help)
;        @error = 3 = API call failed
;
; Author: Ascend4nt
; ==========================================================================================================================

Func _MonitorGetInfo($hMonitor,$hMonitorDC=0)
    If (Not(IsPtr($hMonitor)) Or $hMonitor=0) Then Return SetError(1,0,'')
    ; cbSize, rcMonitor (virtual rect of monitor), rcWork (maximized state of window [minus taskbar, sidebar etc]), dwFlags
    Local $aRet,$stMonInfoEx=DllStructCreate('dword;long[8];dword;wchar[32]'),$bMonDCCreated=0
    DllStructSetData($stMonInfoEx,1,DllStructGetSize($stMonInfoEx))        ; set cbSize
    $aRet=DllCall('user32.dll','bool','GetMonitorInfoW','handle',$hMonitor,'ptr',DllStructGetPtr($stMonInfoEx))
    If (@error) Then Return SetError(2,0,'')
    If (Not($aRet[0])) Then Return SetError(3,0,'')
    Dim $aRet[6]
    ; Both RECT's
    For $i=0 To 3
        $aRet[$i]=DllStructGetData($stMonInfoEx,2,$i+1)
    Next
    ; 0 or 1 for Primary Monitor [MONITORINFOF_PRIMARY = 1]
    $aRet[4]=DllStructGetData($stMonInfoEx,3)
    ; Device String of type '.DISPLAY1' etc
    $aRet[5]=DllStructGetData($stMonInfoEx,4)
    Return $aRet
EndFunc

; ==========================================================================================================================
; Func _MonitorFromWindow($hWnd,$iFlags=2)
;
; Gets monitor handle based on Window handle
;
; $iFlags: 0-2:  (if window doesn't 'intersect' any monitor [i.e. - its off-screen])
;    MONITOR_DEFAULTTONULL (0)
;    MONITOR_DEFAULTTOPRIMARY (1)
;    MONITOR_DEFAULTTONEAREST (2)
;
; Author: Ascend4nt
; ==========================================================================================================================

Func _MonitorFromWindow($hWnd,$iFlags=2)
    If (Not(IsHWnd($hWnd)) Or $iFlags<0 Or $iFlags>2) Then Return SetError(1,0,0)
    Local $aRet=DllCall('user32.dll','handle','MonitorFromWindow','hwnd',$hWnd,'dword',$iFlags)
    If (@error) Then Return SetError(2,@error,0)
    If ($aRet[0]=0) Then Return SetError(3,0,0)
    Return $aRet[0]
EndFunc

Func GetScaleFromMonitor($monitorInfo)
    If (Not(IsArray($monitorInfo))) Then Return -1
    Local $logicalYSize = $monitorInfo[3] - $monitorInfo[1]
    Local $logicalXSize = $monitorInfo[2] - $monitorInfo[0]
    Local $DeviceEnumInfo = _WinAPI_EnumDisplaySettings($monitorInfo[5],$ENUM_CURRENT_SETTINGS)
    Local $physicalXSize = $DeviceEnumInfo[0]
    Local $physicalYSize = $DeviceEnumInfo[1]
    Return _RoundDown($physicalXSize / $logicalXSize, 2)
EndFunc

Func getScreenScaling()
    Local $aDpiSettings[0]
    Local $aMonitors = _WinAPI_EnumDisplayMonitors()
    If (Not(IsArray($aMonitors))) Then Exit MsgBox(0, "", "EnumDisplayMonitors error")
    Local $aCurrentMonitorInfo = _MonitorGetInfo(_MonitorFromWindow($g_hParent))
    For $i = 1 To $aMonitors[0][0]
        Local $aMonitorInfo = _MonitorGetInfo($aMonitors[$i][0])
        Local $fMonitorScale = GetScaleFromMonitor($aMonitorInfo)
        If ($aMonitorInfo[5] = $aCurrentMonitorInfo[5]) Then 
            $g_iCurrentMonitor = $i
            ;$g_iCurrentDpiRatio = $fMonitorScale
        EndIf
        _ArrayAdd($aDpiSettings, $fMonitorScale * 100)
    Next

    Return $aDpiSettings
EndFunc