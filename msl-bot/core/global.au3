;define
	Global $globalStuckLocation = "";
	Global $globalStuckTimer = 0;
	Global $globalScriptTimer;
	Global $textOutput; output for gui
	Global $listLocation = ""; list of locations.
	Global $listScript; script data
	Global $globalData = ""; data output
	Global $nullVar = null;

;directory
	Global Const $strImageSearchDir = @ScriptDir & "\core\_functions\_core\imagesearch\ImageSearchDLL.dll"
	Global Const $strImageDir = @ScriptDir & "\core\_images\"

;bot data
	Global $boolPause = False ;bot state
	Global $boolRunning = False ;State of the bot.
	Global $pointDebug1 = ["?", "?"] ;Point in debug1
	Global $pointDebug2 = ["?", "?"] ;Point in debug2

;bitmaps
	Global $hBitmap; Image for pixel functions.
	Global $hHBitmap; Handle Image for pixel functions.

;image name arrays
	Global $imagesRareAstromon = ["battle-legendary", "battle-super-rare", "battle-rare", "battle-variant", "battle-exotic"]

;coordinations
	Global $game_coorTap = [793, 545]
	Global $game_coorConnectionRetry = [332, 322]
	Global $game_coorDialogueSkip = [755, 25]
	Global $game_coorRefill = [358, 422]
	Global $game_coorRefillConfirm = [396, 310]

	;village
		Global $village_coorAccept = [645, 190]
		Global $village_coorTab = [10, 247]
		Global $village_coorInbox = [163, 125]
		Global $village_coorPlay = [711, 507]
		Global $village_coorShop = [524, 503]
		Global $village_coorQuests = [459, 502]
		Global $village_coorSummon = [393, 501]
		Global $village_coorAstroguide = [324, 503]
		Global $village_coorMonsters = [253, 505]

		Global $village_coorArrayQuestsTab = ["717,127", "592,125", "463,126", "333,125", "213,127"]
		Global $village_coorHourly = ["296,115|486,67|683,107|685,289", "182,390|173,94|577,81|627,186", "686,123|503,113|241,160|166,402", "133,224|320,183|394,379|629,179", "290,309|470,430|684,240|524,100", "165,272|288,99|437,123|706,53|606,235", "157,210|327,48|528,401|225,241|540,138"]

		Global $village_coorManage = [739, 199]
		Global $village_coorUpgrade = [392, 415]
		Global $village_coor1Star = "325,389"
		Global $village_coor2Star = "363,389"
		Global $village_coor3Star = "401,389"
		Global $village_coor4Star = "439,389"
		Global $village_coor5Star = "475,389"
		Global $village_coorSell = [665, 394]
		Global $village_coorSellConfirm = [398, 331]
		Global $village_coorNezz = ["446,36|536,408|398,152", "360,159|26,78", "71,338|187,197", "460,443|679,54|460,148", "144,71|629,351|76,234", "", ""]

	;map
		Global $coorMaps = [["Phantom Forest", "map-astromon-league", -492, 46], ["Lunar Valley", "map-astromon-league", -289, -20], _
							["Aria Lake", "map-astromon-league", -199, 83], ["Mirage Ruins", "map-astromon-league", -225, 230], _
							["Dungeons", "map-astromon-league", -442, 327], ["Pagos Coast", "map-astromon-league", 244, 174], _
							["Seabed Caves", "map-astromon-league", 461, 15], ["Magma Crags", "map-astromon-league", 689, 221], _
							["Pagos Coast", "map-toc", -261, -135], ["Seabed Caves", "map-toc", -99, -316], _
							["Magma Crags", "map-toc", 132, -112], ["Star Sanctuary", "map-toc", 293, -192], _
							["Magma Crags", "map-golems", -355, -134], ["Star Sanctuary", "map-golems", -199, -221], _
							["Sky Falls", "map-golems", 253, -85], ["Slumbering City", "map-golems", 327, -226], _
							["Glacial Plains", "map-golems", 627, -179], ["Aurora Plateau", "map-golems", 737, -338], _
							["Astromon League", "map-astromon-league", 0, 0], ["Clan Plaza", "map-astromon-league", -17, 328], _
							["Tower of Chaos", "map-toc", 0, 0], ["Ancient Dungeon", "map-golems", 0, 0], _
							["Dragon Dungeon", "map-golems", 75, -226], ["Phantom Forest", "map-dungeons", -46, -265], _
							["Lunar Valley", "map-dungeons", 160, -331], ["Aria Lake", "map-dungeons", 233, -257], _
							["Mirage Ruins", "map-dungeons", 216, -103], ["Astromon League", "map-dungeons", 441, -305], _
							["Dungeons", "map-dungeons", 0, 0], ["Pagos Coast", "map-dungeons", 686, -143], _
							["Sky Falls", "map-sky-falls", 0, 0], ["Slumbering City", "map-sky-falls", 27, -193], _
							["Glacial Plains", "map-sky-falls", 338, -124], ["Aurora Plateau", "map-sky-falls", 446, -306]]

		Global $imageMarks = ["map-astromon-league", "map-toc", "map-golems", "map-4th-continent", "map-sky-falls"]

		Global $map_coorStarstoneDungeons = [169, 168]
		Global $map_coorElementDungeons = [178, 235]
		Global $map_coorGoldDungeons = [169, 309]
		Global $map_coorGuardianDungeons = [169, 373]
		Global $map_coorGolemDungeons = [176, 437]

		Global $map_coorMode = [671, 80]
		Global $map_coorNormal = [676, 111]
		Global $map_coorHard = [679, 140]
		Global $map_coorExtreme = [675, 170]

		Global $map_coorBattle = [705, 487]
		Global $map_coorConfirmAutoBattle = [329, 316]
		Global $map_coorCancelAutoBattle = [494, 316]

		Global $map_coorB10 = [627, 413]
		Global $map_coorB9 = [659, 360]
		Global $map_coorB8 = [667, 286]
		Global $map_coorB7 = [666, 215]

	;battle
		Global $battle_coorBoss = [409, 204]
		Global $battle_coorRestart = [455, 267]

		Global $battle_coorAuto = [33, 210]
		Global $battle_coorSpeed = [33, 274]
		Global $battle_coorPause = [32, 338]
		Global $battle_coorGiveUp = [470, 317]
		Global $battle_coorGiveUpConfirm = [395, 309]
		Global $battle_coorContinue = [323, 323]
		Global $battle_coorSell = [433, 384]
		Global $battle_coorSellCancel = [363, 384]

		Global $battle_coorCatch = [741, 275]
		Global $battle_coorCatchCancel = [739,119]

		Global $battle_coorAirship = [330, 395]
		Global $battle_coorMap = [399, 396]
		Global $battle_coorMonsters = [467, 401]

;pixels
	Global $game_pixelBack = [20, 24, 0xF3C645]

	;village
		Global $village_pixelCompass = [771, 82, 0x2C7F60]

	;map
		Global $map_pixelAutoBattle20xUnchecked = [652, 422, 0x281B17]

	;battle
		Global $battle_pixelVictory = [397, 72, 0x6D94F3]
		Global $battle_pixelDefeat = [409, 107, 0x99A5DE]
		Global $battle_pixelBoss = [68, 17, 0xCA322D]

		Global $battle_pixelCatchMode = [417, 88, 0x2E1E19]
		Global $battle_pixelUnavailable = [743, 279, 0x53100C]

		Global $battle_pixelQuest = [344, 365, 0xE80B35]

	;gems
		Global $gemRanks = ["RUIN", "INTUITION", "CONVICTION,PROTECTION,VALOR,VITALITY,TENACITY,FORTITUDE,HEALING,FEROCITY", "LIFE"]
		Global $gemGrade6Price = [[39600,37799,36000,34199], [24750,23624,22500,21374], [19800,18899,18000,17099]]
		Global $gemGrade5Price = [[26400,25199,24000,22799], [16500,15749,15000,14249], [13200,12599,12000,11399]]
		Global $gemGrade4Price = [[15401,14699,14000,13299], [9625,9186,8750,8312], [7701,7349,7000,6649]]

		Global $gem_pixelTypes = ["RUIN:323,224,0xE8AE5A|411,223,0xEAAF5B|435,225,0xDCA456/363,223,0xE8AE5A|403,223,0xEFB45C|411,223,0xEAAF5B", _
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

		Global $gem_pixelStats = ["F.HP:371,254,0xF2B65D|380,255,0xF7BA5F|397,254,0xF5B95E/366,254,0xECB15B|376,255,0xF6B95F|393,254,0xF0B45C", _
								  "F.ATK:358,255,0xE3AA58|395,255,0xF7BA5F|411,254,0xF3B75E", _
								  "F.DEF:352,255,0xD59F53|401,256,0xF4B75E|416,254,0xF3B75E", _
								  "P.ATK:361,255,0xEEB35C|371,255,0xF2B65D|414,254,0xEEB25C/383,255,0xE3AA58|393,255,0xF7BA5F|209,254,0xF3B75E/366,255,0xE5AC59|385,256,0xF2B65D|393,255,0xF7BA5F", _
								  "F.REC:352,255,0xD59F53|378,255,0xEFB45C|403,255,0xF3B75E/348,255,0xEEB35C|379,255,0xEEB35C|410,255,0xF5B85E/348,255,0xEDB25C|366,255,0xEBB15B|410,255,0xF6B95E", _
								  "P.DEF:350,254,0xD59F53|370,255,0xE9AF5A|399,256,0xF4B75E/355,254,0xEEB35C|404,256,0xEEB35C|418,254,0xF1B55D/350,255,0xD59F53|388,256,0xEDB25C|394,254,0xF3B75E", _
								  "P.HP:373,255,0xECB15B|383,254,0xF4B85E|400,254,0xF0B45C/368,254,0xDEA656|378,254,0xF6B95F|384,254,0xEBB05B", _
								  "P.REC:346,255,0xF5B85E|407,255,0xF7BA5F|418,254,0xF5B95E/360,256,0xF4B85E|376,256,0xEFB35C|412,256,0xF6B95F", _
								  "CRIT RATE:351,254,0xE6AC59|383,254,0xCC9850|407,256,0xF6B95E/346,255,0xE4AB59|379,255,0xE4AB59|403,255,0xEBB05B", _
								  "RESIST:356,255,0xF5B85E|393,254,0xEAB05B|588,372,0xF5B95E/360,255,0xD59F53|397,253,0xF4B85E|413,254,0xF3B75E/356,225,0xF4B85E|380,225,0xF7BA5F|393,225,0xE2AA58/356,255,0xF4B85E|380,255,0xF7BA5F|393,255,0xE2AA58", _
								  "CRIT DMG:350,255,0xD59F53|383,254,0xD59F53|413,256,0xC9964F/346,253,0xE6AD59|379,254,0xE6AD59|398,256,0xEBB15A"]