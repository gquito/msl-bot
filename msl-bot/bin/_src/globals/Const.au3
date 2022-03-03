#include-once
Global Const $EMULATOR_WIDTH = 800, $EMULATOR_HEIGHT = 552, $EMULATOR_DPI = 160

#Region Config
    Global Const $CONFIG_NAME = 0
    Global Const $CONFIG_DESCRIPTION = 1
    Global Const $CONFIG_SETTINGLIST = 2
    Global Const $SETTING_NAME = 0
    Global Const $SETTING_VALUE = 1
    Global Const $SETTING_DESCRIPTION = 2
    Global Const $SETTING_TYPE = 3
    Global Const $SETTING_DATA = 4
#EndRegion

#Region Control
    Global Const $BKGD_NONE = 0, $BKGD_WINAPI = 1, $BKGD_ADB = 2, $BKGD_STR[3] = ["None", "WinAPI", "ADB"]
    Global Const $MOUSE_REAL = 0, $MOUSE_CONTROL = 1, $MOUSE_ADB = 2, $MOUSE_STR[3] = ["Real", "Control", "ADB"]
    Global Const $SWIPE_CONTROL = 0, $SWIPE_ADB = 1, $SWIPE_REAL = 2, $SWIPE_STR[3] = ["Control", "ADB", "Real"]
    Global Const $BACK_REAL = 0, $BACK_CONTROL = 1, $BACK_ADB = 2, $BACK_STR[3] = ["Real", "Control", "ADB"]
#EndRegion

Global Const $ALIGN_LEFT = 0, $ALIGN_RIGHT = 1

Global Const $REFILL_TIMEOUT = -1, $REFILL_NOGEMS = -2, $REFILL_MAX = -3
Global Const $CATCH_MODE_NORMAL = 1, $CATCH_MODE_EXOTIC = 2

#Region Log
    Global Const $LOG_INFORMATION = "Information"
    Global Const $LOG_ERROR = "Error"
    Global Const $LOG_PROCESS = "Process"
    Global Const $LOG_DEBUG = "Debug"
#EndRegion

Global Const $g_sLocalFolder = @ScriptDir & "\bin\local\"
Global Const $g_sLocalOriginalFolder = $g_sLocalFolder & "original\"
Global Const $g_sLocalDataFolder = $g_sLocalFolder & "data\"
Global Const $g_sProfileFolder = @ScriptDir & "\profiles\"
Global Const $g_sRemoteUrl = "https://raw.githubusercontent.com/GkevinOD/msl-bot/version-check/data/"
Global Const $g_sFilterFolder = $g_sProfileFolder & "gem_filters\"

Global Const $g_sScriptListFile = @ScriptDir & "\bin\local\scriptlist.txt"

Global Const $g_aScriptList = ["_Config", "_Hourly", "_Filter", "Farm Rare", "Farm Golem", "Farm Gem", "Farm Astromon", "Farm Guardian", "Farm Starstone"]

Global Const $g_sScriptsSettings =  "custom.txt"
Global Const $g_sNezzPositions =    "nezz-locations.txt"
Global Const $g_sPoints =           "points.txt"
Global Const $g_sPixels =           "pixels.txt"
Global Const $g_sLocations =        "locations.txt"
Global Const $g_sLocationsMap =     "locations-map.txt"
Global Const $g_sImageLocations =   "location-images.txt"
Global Const $g_sAirshipPositions = "airship-positions.txt"
Global Const $g_sAirshipTrees =     "airship-trees.txt"
Global Const $g_sScripts =          "scripts_1.5.5.txt"

Global Const $g_sPackageName =      "com.ftt.msleague_gl"
Global Const $g_sPackageActivity =  "kr.co.smartstudy.tamagorpg.TamagoMainActivity"

Global Const $g_aGem_Grade = ["6", "5", "4", "3", "2", "1", "any"]
Global Const $g_aGem_Shape = ["square", "triangle", "diamond", "any"]
Global Const $g_aGem_Type = ["leech", "siphon", "pugilist", "ruin", "intuition", "conviction", "protection", "valor", "vitality", "tenacity", "fortitude", "healing", "ferocity", "life", "any"]
Global Const $g_aGem_Stat = ["hp", "attack", "defense", "recovery", "critrate", "critdmg", "resist", "any"]

Global Const $g_aGemRanks = ["LEECH,SIPHON,PUGILIST", "RUIN", "INTUITION", "CONVICTION,PROTECTION,VALOR,VITALITY,TENACITY,FORTITUDE,HEALING,FEROCITY", "LIFE"]
Global Const $g_aGemGrade6Price = [[39600,37799,36000,34199], [24750,23624,22500,21374], [19800,18899,18000,17099]]
Global Const $g_aGemGrade5Price = [[26400,25199,24000,22799], [16500,15749,15000,14249], [13200,12599,12000,11399]]
Global Const $g_aGemGrade4Price = [[15401,14699,14000,13299], [9625,9187,8750,8312], [7700,7349,7000,6649]]
Global Const $g_aGemGrade = [ _
                        [[0,0,0,0,0],[0,0,0,0,0],[0,0,0,0,0]], _ ;Gem Rank 1
                        [[0,0,0,0,0],[0,0,0,0,0],[0,0,0,3000,0]], _ ;Gem Rank 2
                        [[0,0,0,0,0],[0,0,0,0,0],[0,0,0,0,0]], _ ;Gem Rank 3
                        [[0,15401,14699,14000,13299], [10500,9625,9187,8750,8312], [8400,7700,7349,7000,6649]], _         ;Gem Rank 4
                        [[28800,26400,25199,24000,22799], [18000,16500,15749,15000,14249], [14400,13200,12599,12000,11399]], _ ;Gem Rank 5
                        [[43200,39600,37799,36000,34199], [27000,24750,23624,22500,21374], [21600,19800,18899,18000,17099]]  _ ;Gem Rank 6 
                        ]

Global Const $g_aGem_pixelTypes = [ _
                            "LEECH:420,219,0xDAA255|420,227,0xE0A757|422,222,0x503026|427,225,0xDAA255|447,219,0xCF9951", _
                            "PUGILIST:414,219,0xDDA456|415,223,0xE9AE5A|419,223,0xDCA456|431,229,0xA17341|434,229,0xDFA657|438,219,0xD29C52", _
                            "SIPHON:418,219,0xDDA356|420,225,0xD69D54|422,224,0xD69D54|430,224,0xDCA356|446,224,0xE2A858", _
                            "RUIN:323,224,0xE8AE5A|411,223,0xEAAF5B|435,225,0xDCA456/363,223,0xE8AE5A|403,223,0xEFB45C|411,223,0xEAAF5B", _
                            "FORTITUDE:348,223,0xE8AE5A|396,223,0xEBB05B|446,224,0xF0B45D", _
                            "FEROCITY:352,223,0xE4AA58|400,223,0xEBB05B|446,224,0xE5AB59", _
                            "HEALING:354,224,0xE0A757|402,223,0xF0B45C|444,225,0xDFA657", _
                            "VALOR:360,224,0xE8AE5A|391,224,0xECB15B|436,225,0xECB15B", _
                            "INTUITION:351,223,0xDDA556|390,222,0xF4B75E|399,223,0xDAA255", _
                            "LIFE:366,223,0xDDA556|405,224,0xF4B75E|424,222,0xF4B75E/366,223,0xDDA556|405,222,0xF4B75E|414,222,0xDDA556/366,223,0xDDA556|405,222,0xF4B75E|414,222,0xDDA556", _
                            "VITALITY:355,223,0xE4AA58|395,223,0xE4AA58|443,224,0xE5AB59", _
                            "PROTECTION:345,224,0xE8AE5A|385,223,0xEFB45C|452,224,0xDAA255/345,223,0xE8AE5A|393,223,0xF5B85E|448,222,0xF6B95F", _
                            "CONVICTION:345,224,0xE4AA58|385,222,0xE9AE5A|453,224,0xDFA657/345,223,0xE4AA59|393,223,0xE4AA59|453,224,0xDFA757", _
                            "TENACITY:351,222,0xDDA556|401,222,0xDCA456|447,224,0xE2A858"]

Global Const $g_aGem_pixelStats = [ _
    "F.HP:371,254,0xF2B65D|380,255,0xF7BA5F|397,254,0xF5B95E/366,254,0xECB15B|376,255,0xF6B95F|393,254,0xF0B45C", _
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

Global Const $g_aVillagePos = [ _
    "54,469,0x482E1F|306,449,0x54451E|616,422,0x3F3720/367,455,0x65552B|628,96,0x3D4340|282,23,0x485F72/738,394,0x705C36|13,413,0x6D4E38|74,382,0xBC9166", _
    "64,488,0x393623|264,51,0x4D656F|18,414,0xB4AA74/192,465,0x52622E|261,47,0x597077|566,92,0x259558/54,98,0x6C7E8A|787,360,0x234923|297,545,0x2D3029", _
    "32,449,0x26221A|81,430,0x944E41|715,409,0x3B2F1D/111,537,0x4F4526|87,124,0x71716F|259,349,0x177831/71,382,0x26221A|646,445,0x524E2B|775,105,0x716F58", _
    "658,402,0x604E31|229,410,0x304138|194,329,0x76C84E/623,266,0x296D6D|609,307,0x266769|619,47,0x328B9B/677,130,0x2E95A6|98,325,0x493827|126,402,0x252C25", _
    "655,358,0x8CD75D|724,384,0x473627|160,159,0x28999D/254,388,0x353E32|291,472,0x43483E|491,544,0x1C201B/106,159,0x6B3D3A|32,157,0x209575|779,366,0x1D1911", _
    "44,389,0x323F32|633,425,0xCBD0C2|267,127,0x7C55C4/133,316,0x11110A|481,348,0x84773D|551,47,0x4A5855/691,105,0x1E8645|373,455,0x425B4D|690,325,0x2B2815", _
    "232,348,0x363630|390,147,0x434F3D|710,388,0x134B66/565,238,0x6D6D56|94,211,0x9E418B|359,104,0x146961/648,344,0x443A23|540,95,0x5F7479|182,468,0x363333", _
    "150,430,0x7F4863|34,334,0xD298D5|635,182,0xDB82C9/790,350,0x00FFFF|4,381,0xC1C1AF|331,163,0x02FFFF/661,62,0x44575E|573,398,0x565D46|357,360,0x444D3F", _
    "221,87,0x44687A|41,395,0x00FFFF|476,163,0x01FFFF/221,87,0x424B44|41,395,0x00FFFF|476,163,0x00FFFF/104,451,0x44332E|784,401,0xC0C0AF|507,75,0x0885C7/104,451,0x44332E|784,401,0xC4C4B2|507,75,0x1079A7/272,374,0x444B44|755,457,0x4A4A39|8,194,0x2F3D46/272,374,0x444B44|755,457,0x0F0D0A|8,194,0x2D2D29"]

; 0,1,2: Normal | 3,4: Windsinger | 5,6: Albatross | 7,8: Hanamura
Global Const $g_aExpeditionPos = [ _ ; Use getVillagePos() function
    "231,246", _ ;      Index = 0
    "-1", _      ;      Index = 1
    "327,185", _ ;      Index = 2
    "256,229", _ ;      Index = 3
    "426,356", _ ;      Index = 4
    "-1", _ ; Needed.   Index = 5
    "-1", _ ; Needed.   Index = 6
    "299,254", _ ;      Index = 7
    "463,315"] ;        Index = 8

Global Const $g_aVillageTrees = [ _
    "296,115|486,67|683,107|685,289", _
    "182,390|194,122|577,81|627,186", _
    "686,123|503,113|241,160|166,402", _
    "133,224|320,183|394,379|629,179", _
    "290,309|470,430|684,240|524,100", _
    "146,270|283,81|390,139|440,99|732,50|606,235", _
    "521,413|220,220|227,227|221,225|331,45|540,138", _
    "607,146|735,169|789,103|479,68|71,304|259,422|478,211", _
    "80,160|256,34|425,124|325,114|574,442|740,335|577,140"]

Global Const $g_aSwipeLeft =    [350, 550, 100, 550, "left"]
Global Const $g_aSwipeDown =    [434, 317, 434, 406, "down"]
Global Const $g_aSwipeDown_Half =   [434, 317, 434, 370, "down"]
Global Const $g_aSwipeUp =      [434, 406, 434, 317, "up"]
Global Const $g_aSwipeUpFast =      [434, 406, 434, -10000, "up"]
Global Const $g_aSwipeRight =   [10, 550, 350, 550, "right"]
Global Const $g_aSwipeRightFast = [10, 550, 10000, 550, "right"]

Global Const $g_aDungeonsSwipeDown =    [175, 186, 175, 452, "down"]
Global Const $g_aDungeonsSwipeUp =      [175, 452, 175, 186, "up"]

Global Const $g_sLocationSearchRegex = "(^|,)%s($|,)"

Global Const $g_aMapMarkers = ["Astromon League", _ 
                               "Aria Lake", _ 
                               "Pagos Coast", _ 
                               "Apex Battles", _ 
                               "Ancient Dungeon", _ 
                               "Sky Falls", _ 
                               "Aurora Plateau", _ 
                               "Dimensional Rift"]
Global Const $g_aMapReference = [148, 175] ; Phantom Forest
Global Const $g_aMapDimensions[24][3] = [ _ 
    ["Ancient Dungeon",             "0,498,800,30", "1526,283"], _ 
    ["Apex Battles",                "0,124,800,30", "1130,-66"], _ 
    ["Aria Lake",                   "0,177,800,30", "291,42"], _ 
    ["Astromasters Association",    "0,285,800,30", "532,114"], _ 
    ["Astromon League",             "0,159,800,30", "479,-44"], _ 
    ["Aurora Plateau",              "0,122,800,30", "2282,-49"], _ 
    ["Clan Battle",                 "0,455,800,30", "510,289"], _ 
    ["Deserted Battlefield",        "0,318,800,30", "2655,141"], _ 
    ["Dimensional Rift",            "0,100,800,40", "2513,-55"], _ 
    ["Dragon Dungeon",              "0,260,800,40", "1606,63"], _ 
    ["Dungeons",                    "0,446,800,30", "41,295"], _ 
    ["Glacial Plains",              "0,309,800,30", "2147,124"], _ 
    ["Hero Dungeons",               "0,136,800,30", "670,-51"], _ 
    ["Lunar Valley",                "0,131,800,30", "202,-78"], _ 
    ["Magma Crags",                 "0,349,800,30", "1166,167"], _ 
    ["Mirage Ruins",                "0,342,800,30", "256,174"], _ 
    ["Pagos Coast",                 "0,294,800,30", "751,131"], _ 
    ["Phantom Forest",              "0,171,800,30", "0,0"], _ 
    ["Seabed Caves",                "0,145,800,30", "950,-32"], _ 
    ["Sky Falls",                   "0,397,800,30", "1797,233"], _ 
    ["Slumbering City",             "0,236,800,30", "1846,71"], _ 
    ["Star Sanctuary",              "0,264,800,30", "1337,77"], _ 
    ["Terrestrial Rift",            "0,241,800,30", "2825,74"], _ 
    ["Towers",                      "0,443,800,30", "1002,307"]]