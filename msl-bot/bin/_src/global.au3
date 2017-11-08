;Constants
    Global Const $g_aControlSize = [800, 552] ;Default emulator size.
    Global Const $g_aRandomClicks = [-5, 5] ;Random click spread

    Global Const $BKGD_NONE = 0, $BKGD_WINAPI = 1, $BKGD_ADB = 2
    Global Const $MOUSE_REAL = 0, $MOUSE_CONTROL = 1, $MOUSE_ADB = 2
    Global Const $SWIPE_KEYMAP = 0, $SWIPE_ADB = 1
    Global Const $LOG_NORMAL = 0, $LOG_DEBUG = 1, $LOG_ERROR = 2

;Application variables
    Global $g_sErrorMessage = "" ;Message when functions calls error code.
    Global $g_sScript = "" ;Current name of the running script.
    Global $g_aScriptArgs = Null ;Arguments for running script.
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
    Global $g_sImageSearchPath = @TempDir & "\ImageSearchDLL.dll" ;ImageSearchDLL default path
    Global $g_sImagesPath = @ScriptDir & "\bin\images\" ;Path to images
    Global $g_sProfilePath = @ScriptDir & "\profiles\main\" ;Path to current seleted profile 
    Global $g_sAdbPort = "62001" ;Android debug bridge port. Default is 62001 for nox
    Global $g_sAdbPath = "C:\Program Files (x86)\Nox\bin\nox_adb.exe" ;Android adb executable. Default for nox
    Global $g_sEmuSharedFolder[2] = ["/mnt/shared/App/", @UserProfileDir & "\Nox_share\App\"] ;Folder shared between emulator and computer. Default for nox
    Global $g_iBackgroundMode = $BKGD_ADB ;Type of background
    Global $g_iMouseMode = $MOUSE_ADB ;Type of mouse control
    Global $g_iSwipeMode = $SWIPE_ADB ;Type of swipe control

;MSL variables/constants
    Global Const $g_aImageMarks = ["map-astromon-league", "map-toc", "map-golems", "map-4th-continent", "map-sky-falls"]
    Global Const $g_aCoorMaps =[["Phantom Forest", "map-astromon-league", -492, 46],    ["Lunar Valley", "map-astromon-league", -289, -20], _
                                ["Aria Lake", "map-astromon-league", -199, 83],         ["Mirage Ruins", "map-astromon-league", -225, 230], _
                                ["Dungeons", "map-astromon-league", -442, 327],         ["Pagos Coast", "map-astromon-league", 244, 174], _
                                ["Seabed Caves", "map-astromon-league", 461, 15],       ["Magma Crags", "map-astromon-league", 689, 221], _
                                ["Pagos Coast", "map-toc", -261, -135],                 ["Seabed Caves", "map-toc", -99, -316], _
                                ["Magma Crags", "map-toc", 132, -112],                  ["Star Sanctuary", "map-toc", 293, -192], _
                                ["Magma Crags", "map-golems", -355, -134],              ["Star Sanctuary", "map-golems", -199, -221], _
                                ["Sky Falls", "map-golems", 253, -85],                  ["Slumbering City", "map-golems", 327, -226], _
                                ["Glacial Plains", "map-golems", 627, -179],            ["Aurora Plateau", "map-golems", 737, -338], _
                                ["Astromon League", "map-astromon-league", 0, 0],       ["Clan Plaza", "map-astromon-league", -17, 328], _
                                ["Tower of Chaos", "map-toc", 0, 0],                    ["Ancient Dungeon", "map-golems", 0, 0], _
                                ["Dragon Dungeon", "map-golems", 75, -226],             ["Phantom Forest", "map-dungeons", -46, -265], _
                                ["Lunar Valley", "map-dungeons", 160, -331],            ["Aria Lake", "map-dungeons", 233, -257], _
                                ["Mirage Ruins", "map-dungeons", 216, -103],            ["Astromon League", "map-dungeons", 441, -305], _
                                ["Dungeons", "map-dungeons", 0, 0],                     ["Pagos Coast", "map-dungeons", 686, -143], _
                                ["Sky Falls", "map-sky-falls", 0, 0],                   ["Slumbering City", "map-sky-falls", 27, -193], _
                                ["Glacial Plains", "map-sky-falls", 338, -124],         ["Aurora Plateau", "map-sky-falls", 446, -306]]
    Global $g_aSwipeLeft = [600, 550, 200, 550]

    Global $g_aScripts = [] ;Script data [[script, description, [[config, value, description], [..., ..., ...]]], ...]
    Global $g_aLocations = [] ;Data locations [[location, value], ...]
    Global $g_aPixels = [] ;Individual pixel data [[name, pixel], ...]
    Global $g_aPoints = [] ;Significant Points in game [[name, point], ...]


;GUI variables
    Global $hLV_Log, $hLV_Stat

    Global $g_aComboMenu = Null ;Holds temporary context menus from combo type settings.
    
    Global $g_hEditConfig = Null ;Handle for the edit control created when editing a setting.
    Global $g_iEditConfig = Null ;Index for the item being edited

    Global $g_aListEditor = Null ;Holds temporary gui and controls for list type settings.