#include-once
#include "../imports.au3"

#region GuiControlCreate

    Func _GuiCreate($title, $width, $height, $left = -1, $top = -1, $style = -1, $exStyle = -1, $parent = 0)
        If ($width > 0) Then $width *= $g_iCurrentDpiRatio
        If ($height > 0 ) Then $height *= $g_iCurrentDpiRatio
        return GUICreate($title, $width, $height, $left, $top, $style, $exStyle, $parent)
    EndFunc

    Func _GUICtrlCreateTab($left, $top, $width = -1, $height = -1, $style = -1, $exStyle = -1)
        If ($width > 0) Then $width *= $g_iCurrentDpiRatio
        If ($height > 0 ) Then $height *= $g_iCurrentDpiRatio
        $left /= $g_iCurrentDpiRatio
        $top /= $g_iCurrentDpiRatio
        return GUICtrlCreateTab($left, $top, $width, $height, $style, $exStyle)
    EndFunc

    Func _GUICtrlCreateLabel($text, $left, $top, $width = -1, $height = -1, $style = -1, $exStyle = -1)
        If ($width > 0) Then $width *= $g_iCurrentDpiRatio
        If ($height > 0 ) Then $height *= $g_iCurrentDpiRatio
        $left /= $g_iCurrentDpiRatio
        $top /= $g_iCurrentDpiRatio
        return GUICtrlCreateLabel($text, $left, $top, $width, $height, $style, $exStyle)
    EndFunc

    Func _GUICtrlCreateCombo($text, $left, $top, $width = -1, $height = -1, $style = -1, $exStyle = -1)
        If ($width > 0) Then $width *= $g_iCurrentDpiRatio
        If ($height > 0 ) Then $height *= $g_iCurrentDpiRatio
        $left /= $g_iCurrentDpiRatio
        $top /= $g_iCurrentDpiRatio
        return GUICtrlCreateCombo($text, $left, $top, $width, $height, $style, $exStyle)
    EndFunc
    Func _GUICtrlCreateCheckbox($text, $left, $top, $width = -1, $height = -1, $style = -1, $exStyle = -1)
        If ($width > 0) Then $width *= $g_iCurrentDpiRatio
        If ($height > 0 ) Then $height *= $g_iCurrentDpiRatio
        $left /= $g_iCurrentDpiRatio
        $top /= $g_iCurrentDpiRatio
        return GUICtrlCreateCheckbox($text, $left, $top, $width, $height, $style, $exStyle)
    EndFunc

    Func _GUICtrlCreateButton($text, $left, $top, $width = -1, $height = -1, $style = -1, $exStyle = -1)
        If ($width > 0) Then $width *= $g_iCurrentDpiRatio
        If ($height > 0 ) Then $height *= $g_iCurrentDpiRatio
        $left /= $g_iCurrentDpiRatio
        $top /= $g_iCurrentDpiRatio
        return GUICtrlCreateButton($text, $left, $top, $width, $height, $style, $exStyle)
    EndFunc

    Func _GUICtrlCreateListView($text, $left, $top, $width = -1, $height = -1, $style = -1, $exStyle = -1)
        If ($width > 0) Then $width *= $g_iCurrentDpiRatio
        If ($height > 0 ) Then $height *= $g_iCurrentDpiRatio
        $left /= $g_iCurrentDpiRatio
        $top /= $g_iCurrentDpiRatio
        return GUICtrlCreateListView($text, $left, $top, $width, $height, $style, $exStyle)
    EndFunc

    Func __GUICtrlEdit_Create($text, $left, $top, $width = 150, $height = 150, $style = 0x003010C4, $exStyle = 0x00000200)
        If ($width > 0) Then $width *= $g_iCurrentDpiRatio
        If ($height > 0 ) Then $height *= $g_iCurrentDpiRatio
        $left /= $g_iCurrentDpiRatio
        $top /= $g_iCurrentDpiRatio
        return _GUICtrlEdit_Create($text, $left, $top, $width, $height, $style, $exStyle)
    EndFunc

#endregion

#region GuiTabFunctions
    Func __GUICtrlTab_SetItemSize($hWnd, $iWidth, $iHeight)
        If ($iWidth > 0) Then $iWidth *= $g_iCurrentDpiRatio
        If ($iHeight > 0 ) Then $iHeight *= $g_iCurrentDpiRatio
        _GUICtrlTab_SetItemSize($hWnd, $iWidth, $iHeight)
    EndFunc
#endregion

#region GuiListViewFunctions
    Func __GUICtrlListView_AddColumn($hWnd, $sText, $iWidth = 50, $iAlign = -1, $iImage = -1, $bOnRight = False)
        If ($iWidth > 0) Then $iWidth *= $g_iCurrentDpiRatio
        _GUICtrlListView_AddColumn($hWnd, $sText, $iWidth, $iAlign, $iImage, $bOnRight)
    EndFunc
#endregion

#region GuiSetFunctions
    Func _GUISetFont($size, $weight = 0, $attribute = 0, $fontname = "", $winhandle = $g_hParent, $quality = 0)
        GUISetFont($size*$g_iCurrentDpiRatio,$weight,$attribute, $fontname, $winhandle, $quality)
    EndFunc
#endregion

#region WinApiFunctions
    Func _WinMove($title, $text, $x, $y, $width = -1, $height = -1, $speed = 1)
        Local $aWinPos = WinGetPos($title)
        If ($width > 0) Then $width *= $g_iCurrentDpiRatio
        If ($height > 0 ) Then $height *= $g_iCurrentDpiRatio
        If ($width = -1) Then $width = $aWinPos[2]
        If ($height = -1) Then $height = $aWinPos[3]
        WinMove($title, $text, $x, $y, $width, $height, $speed)
    EndFunc

    Func _ControlMove($title, $text, $controlID, $x, $y, $width = -1, $height = -1)
        Local $aWinPos = ControlGetPos($title, $text, $controlID)
        If ($width > 0) Then $width *= $g_iCurrentDpiRatio
        If ($height > 0 ) Then $height *= $g_iCurrentDpiRatio
        If ($width = -1) Then $width = $aWinPos[2]
        If ($height = -1) Then $height = $aWinPos[3]
        $x /= $g_iCurrentDpiRatio
        $y /= $g_iCurrentDpiRatio
        ControlMove($title, $text, $controlID, $x, $y, $width, $height)
    EndFunc
#endregion



