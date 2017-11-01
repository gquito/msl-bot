;Constants
    Global Const $g_aControlSize = [800, 552] ;Default emulator size.
    Global Const $g_aRandomClicks = [-5, 5] ;Random click spread

    Global Const $BKGD_NONE = 0, $BKGD_WINAPI = 1, $BKGD_ADB = 2
    Global Const $MOUSE_REAL = 0, $MOUSE_CONTROL = 1, $MOUSE_ADB = 2
    Global Const $SWIPE_KEYMAP = 0, $SWIPE_ADB = 1
    Global Const $LOG_NORMAL = 0, $LOG_DEBUG = 1, $LOG_ERROR = 2

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
    Global $g_aLog[0][3] ;Keeps track of [log, time, type]

;Config variables
    Global $g_sAdbPort = "62001" ;Android debug bridge port. Default is 62001 for nox
    Global $g_sAdbPath = "C:\Program Files (x86)\Nox\bin\nox_adb.exe" ;Android adb executable. Default for nox
    Global $g_sEmuSharedFolder[2] = ["/mnt/shared/App/", @UserProfileDir & "\Nox_share\App\"] ;Folder shared between emulator and computer. Default for nox
    Global $g_iBackgroundMode = $BKGD_ADB ;Type of background
    Global $g_iMouseMode = $MOUSE_ADB ;Type of mouse control
    Global $g_iSwipeMode = $SWIPE_ADB ;Type of swipe control

;MSL variables
    Global $g_aScripts = [] ;Script data [[script, description, [[config, value, description], [..., ..., ...]]], ...]
    Global $g_aLocations = [] ;Data locations [[location, value], ...]
    Global $g_aPixels = [] ;Individual pixel data [[name, pixel], ...]
    Global $g_aPoints = [] ;Significant Points in game [[name, point], ...]

;GUI variables
    Global $g_aComboMenu = Null ;Holds temporary context menus from combo type settings.
    Global $g_hEditConfig = Null ;Handle for the edit control created when editing a setting.
    Global $g_iEditConfig = Null ;Index for the item being edited