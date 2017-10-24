;Constants
    Global Const $g_aControlSize = [800, 552] ;Default emulator size.
    Global Const $g_aRandomClicks = [-5, 5] ;Random click spread

;Application variables
    Global $g_sErrorMessage = "" ;Message when functions calls error code.
    Global $g_vDebug = Null ;Extra information given after an execution of a select function.
    Global $g_bRunning = False ;If any scripts are running
    Global $g_bPaused = False ;If any scripts are paused
    Global $g_hHBitmap = Null ;WINAPI bitmap handle.
    Global $g_hBitmap = Null ;GDIPlus bitmap handle.
    Global $g_sWindowTitle = "" ;Emulator window title.
    Global $g_sControlInstance = "" ;OPENGL/DIRECTX Control instance.
    Global $g_hWindow = Null ;Handle for emulator window
    Global $g_hControl = Null ;Handle for control window

;Config variables
    Global $g_bBackground = True ;If ScreenCapture is done in the background.
    Global $g_bRealMouse = False ;To use real mouse instead of simulations.

;MSL variables
    Global $g_aLocations = [] ;Data locations
    Global $g_aPixels = [] ;Individual pixel data
    Global $g_aPoints = [] ;Significant Points in game