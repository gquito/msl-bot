;Constants
    Global Const $g_aControlSize = [800, 552] ;Default emulator size.
    Global Const $g_aRandomClicks = [-5, 5] ;Random click spread

    Global Const $BKGD_NONE = 0, $BKGD_WINAPI = 1, $BKGD_ADB = 2
    Global Const $MOUSE_REAL = 0, $MOUSE_CONTROL = 1, $MOUSE_ADB = 2
    Global Const $SWIPE_KEYMAP = 0, $SWIPE_ADB = 1, $SWIPE_REAL = 2
    Global Const $LOG_NORMAL = 0, $LOG_DEBUG = 1, $LOG_ERROR = 2

;Application variables
    Global $g_sAppTitle = "MSL Bot v" & $aVersion[0] & "." & $aVersion[1] & "." & $aVersion[2] ;Bot app title
    Global $g_sErrorMessage = "" ;Message when functions calls error code.
    Global $g_sScript = "" ;Current name of the running script.
    Global $g_aScriptArgs = Null ;Arguments for running script.
    Global $g_hScriptTimer = Null ;Timer for script
    Global $g_vDebug = Null ;Extra information given after an execution of a select function.
    Global $g_bRunning = False ;If any scripts are running
    Global $g_bPaused = False ;If any scripts are paused
    Global $g_hHBitmap = Null ;WINAPI bitmap handle.
    Global $g_hBitmap = Null ;GDIPlus bitmap handle.
    Global $g_hWindow = Null ;Handle for emulator window
    Global $g_hControl = Null ;Handle for control window
    Global $g_aLog[0][3] ;Keeps track of [log, time, type]
    Global $g_aData[0][2] ;Keeps track of script data.

;Config variables
    Global $g_sImageSearchPath = @TempDir & "\ImageSearchDLL.dll" ;ImageSearchDLL default path
    Global $g_sImagesPath = @ScriptDir & "\bin\images\" ;Path to images
    Global $g_sProfilePath = @ScriptDir & "\profiles\Default\" ;Path to current seleted profile 
    Global $g_sAdbDevice = "127.0.0.1:62001" ;Android debug bridge device name. Default is 127.0.0.1:62001 for nox
    Global $g_sAdbPath = "C:\Program Files (x86)\Nox\bin\nox_adb.exe" ;Android adb executable. Default for nox
    Global $g_sEmuSharedFolder[2] = ["/mnt/shared/App/", @UserProfileDir & "\Nox_share\App\"] ;Folder shared between emulator and computer. Default for nox
    Global $g_iBackgroundMode = $BKGD_ADB ;Type of background
    Global $g_iMouseMode = $MOUSE_ADB ;Type of mouse control
    Global $g_iSwipeMode = $SWIPE_ADB ;Type of swipe control
    Global $g_sWindowTitle = "NoxPlayer" ;Emulator window title.
    Global $g_sControlInstance = "[CLASS:subWin; INSTANCE:1]" ;OPENGL/DIRECTX Control instance.

    Global $d_sProfilePath = @ScriptDir & "\profiles\Default\" ;Path to current seleted profile 
    Global $d_sAdbDevice = "127.0.0.1:62001" ;Android debug bridge device name. Default is 127.0.0.1:62001 for nox
    Global $d_sAdbPath = "C:\Program Files (x86)\Nox\bin\nox_adb.exe" ;Android adb executable. Default for nox
    Global $d_sEmuSharedFolder[2] = ["/mnt/shared/App/", @UserProfileDir & "\Nox_share\App\"] ;Folder shared between emulator and computer. Default for nox
    Global $d_iBackgroundMode = $BKGD_ADB ;Type of background
    Global $d_iMouseMode = $MOUSE_ADB ;Type of mouse control
    Global $d_iSwipeMode = $SWIPE_ADB ;Type of swipe control
    Global $d_sWindowTitle = "NoxPlayer" ;Emulator window title.
    Global $d_sControlInstance = "[CLASS:subWin; INSTANCE:1]" ;OPENGL/DIRECTX Control instance.

;MSL variables/constants
    Global $g_aGemRanks = ["RUIN", "INTUITION", "CONVICTION,PROTECTION,VALOR,VITALITY,TENACITY,FORTITUDE,HEALING,FEROCITY", "LIFE"]
    Global $g_aGemGrade6Price = [[39600,37799,36000,34199], [24750,23624,22500,21374], [19800,18899,18000,17099]]
    Global $g_aGemGrade5Price = [[26400,25199,24000,22799], [16500,15749,15000,14249], [13200,12599,12000,11399]]
    Global $g_aGemGrade4Price = [[15401,14699,14000,13299], [9625,9187,8750,8312], [7700,7349,7000,6649]]

    Global $g_aGem_pixelTypes = [  "RUIN:323,224,0xE8AE5A|411,223,0xEAAF5B|435,225,0xDCA456/363,223,0xE8AE5A|403,223,0xEFB45C|411,223,0xEAAF5B", _
                                "FEROCITY:352,223,0xE4AA58|400,223,0xEBB05B|446,224,0xE5AB59", _
                                "FORTITUDE:348,223,0xE8AE5A|396,223,0xEBB05B|446,224,0xF0B45D", _
                                "HEALING:354,224,0xE0A757|402,223,0xF0B45C|444,225,0xDFA657", _
                                "VALOR:360,224,0xE8AE5A|391,224,0xECB15B|436,225,0xECB15B", _
                                "INTUITION:351,223,0xDDA556|390,222,0xF4B75E|399,223,0xDAA255", _
                                "LIFE:366,223,0xDDA556|405,224,0xF4B75E|424,222,0xF4B75E/366,223,0xDDA556|405,222,0xF4B75E|414,222,0xDDA556/366,223,0xDDA556|405,222,0xF4B75E|414,222,0xDDA556", _
                                "VITALITY:355,223,0xE4AA58|395,223,0xE4AA58|443,224,0xE5AB59", _
                                "PROTECTION:345,224,0xE8AE5A|385,223,0xEFB45C|452,224,0xDAA255/345,223,0xE8AE5A|393,223,0xF5B85E|448,222,0xF6B95F", _
                                "CONVICTION:345,224,0xE4AA58|385,222,0xE9AE5A|453,224,0xDFA657/345,223,0xE4AA59|393,223,0xE4AA59|453,224,0xDFA757", _
                                "TENACITY:351,222,0xDDA556|401,222,0xDCA456|447,224,0xE2A858"]

    Global $g_aGem_pixelStats = [  "F.HP:371,254,0xF2B65D|380,255,0xF7BA5F|397,254,0xF5B95E/366,254,0xECB15B|376,255,0xF6B95F|393,254,0xF0B45C", _
                                "F.ATK:358,255,0xE3AA58|395,255,0xF7BA5F|411,254,0xF3B75E", _
                                "F.DEF:352,255,0xD59F53|401,256,0xF4B75E|416,254,0xF3B75E", _
                                "P.ATK:361,255,0xEEB35C|371,255,0xF2B65D|414,254,0xEEB25C/383,255,0xE3AA58|393,255,0xF7BA5F|209,254,0xF3B75E/366,255,0xE5AC59|385,256,0xF2B65D|393,255,0xF7BA5F", _
                                "F.REC:352,255,0xD59F53|378,255,0xEFB45C|403,255,0xF3B75E/348,255,0xEEB35C|379,255,0xEEB35C|410,255,0xF5B85E/348,255,0xEDB25C|366,255,0xEBB15B|410,255,0xF6B95E/366,256,0xE9AF5A|409,262,0xEDB25C|379,256,0xEEB35C", _
                                "P.DEF:350,254,0xD59F53|370,255,0xE9AF5A|399,256,0xF4B75E/355,254,0xEEB35C|404,256,0xEEB35C|418,254,0xF1B55D/350,255,0xD59F53|388,256,0xEDB25C|394,254,0xF3B75E", _
                                "P.HP:373,255,0xECB15B|383,254,0xF4B85E|400,254,0xF0B45C/368,254,0xDEA656|378,254,0xF6B95F|384,254,0xEBB05B", _
                                "P.REC:346,255,0xF5B85E|407,255,0xF7BA5F|418,254,0xF5B95E/360,256,0xF4B85E|376,256,0xEFB35C|412,256,0xF6B95F", _
                                "CRIT RATE:351,254,0xE6AC59|383,254,0xCC9850|407,256,0xF6B95E/346,255,0xE4AB59|379,255,0xE4AB59|403,255,0xEBB05B", _
                                "RESIST:356,255,0xF5B85E|393,254,0xEAB05B|588,372,0xF5B95E/360,255,0xD59F53|397,253,0xF4B85E|413,254,0xF3B75E/356,225,0xF4B85E|380,225,0xF7BA5F|393,225,0xE2AA58/356,255,0xF4B85E|380,255,0xF7BA5F|393,255,0xE2AA58", _
                                "CRIT DMG:350,255,0xD59F53|383,254,0xD59F53|413,256,0xC9964F/346,253,0xE6AD59|379,254,0xE6AD59|398,256,0xEBB15A"]

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