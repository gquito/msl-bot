;define
	Global $textOutput; output for gui
	Global $listLocation = ""; list of locations.

;directory
	Global Const $strImageSearchDir = @ScriptDir & "\core\_functions\_core\imagesearch\ImageSearchDLL.dll"
	Global Const $strImageDir = @ScriptDir & "\core\_images\"

;bot data
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
		Global $village_coorHourly = ["296,115|486,67|683,107|685,289", "182,390|173,94|577,81|627,186", "686,123|503,113|241,160|166,402"] ;pos1, pos2, pos3 -> hourly1|hourly2|hourly3|shop

		Global $village_coorManage = [739, 199]
		Global $village_coorUpgrade = [392, 415]
		Global $village_coor1Star = "325,389"
		Global $village_coor2Star = "363,389"
		Global $village_coor3Star = "401,389"
		Global $village_coor4Star = "439,389"
		Global $village_coor5Star = "475,389"
		Global $village_coorSell = [665, 394]
		Global $village_coorSellConfirm = [398, 331]
		Global $village_coorNezz = ["446,36|536,408|398,152", "360,159|26,78", "71,338|187,197"] ;pos1, pos2, pos3

	;map
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

		Global $battle_coorAuto = [33, 210]
		Global $battle_coorSpeed = [33, 274]
		Global $battle_coorPause = [32, 338]
		Global $battle_coorGiveUp = [470, 317]
		Global $battle_coorGiveUpConfirm = [395, 309]
		Global $battle_coorContinue = [323, 323]
		Global $battle_coorSell = [726, 326]
		Global $battle_coorSellConfirm = [479, 330]

		Global $battle_coorCatch = [741, 275]
		Global $battle_coorCatchCancel = [741, 118]

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

		Global $battle_pixelQuest = [343, 379, 0xDA071E]

	;gems
		Global $gemRanks = ["RUIN", "INTUITION", "CONVICTION,PROTECTION,VALOR,VITALITY,TENACITY,FORTITUDE,HEALING,FEROCITY", "LIFE"]
		Global $gemGrade6Price = [[39600,37799,36000,34199], [24750,23624,22500,21374], [19800,18899,18000,17099]]
		Global $gemGrade5Price = [[26400,25199,24000,22799], [16500,15749,15000,14249], [13200,12599,12000,11399]]
		Global $gemGrade4Price = [[15401,14699,14000,13299], [9625,9186,8750,8312], [7701,7349,7000,6649]]

		Global $gem_pixelTypes = ["RUIN:503,304,0xE8AE5A|591,303,0xEAAF5B|615,305,0xDCA456/543,303,0xE8AE5A|583,303,0xEFB45C|591,303,0xEAAF5B", "FEROCITY:532,303,0xE4AA58|580,303,0xEBB05B|626,304,0xE5AB59", "FORTITUDE:528,303,0xE8AE5A|576,303,0xEBB05B|626,304,0xF0B45D", "HEALING:534,304,0xE0A757|582,303,0xF0B45C|624,305,0xDFA657", "VALOR:540,304,0xE8AE5A|571,304,0xECB15B|616,305,0xECB15B", "INTUITION:531,303,0xDEA556|570,303,0xEAAF5A|579,303,0xDAA255", "LIFE:546,303,0xDEA556|585,304,0xDBA355|613,304,0xCC9650", "VITALITY:535,303,0xE4AA58|575,303,0xE4AA58|623,304,0xE5AB59", "PROTECTION:525,304,0xE8AE5A|565,303,0xEFB45C|632,304,0xDAA255", "CONVICTION:525,304,0xE4AA58|565,302,0xE9AE5A|633,304,0xDFA657", "TENACITY:531,303,0xDEA556|581,303,0xDCA456|627,305,0xE3A958"]
		Global $gem_pixelStats = ["F.HP:551,372,0xF2B65D|560,373,0xF7BA5F|577,372,0xF5B95E/546,372,0xECB15B|556,373,0xF6B95F|573,372,0xF0B45C", "F.ATK:538,373,0xE3AA58|575,373,0xF7BA5F|591,372,0xF3B75E", "F.DEF:532,373,0xD59F53|581,374,0xF4B75E|596,372,0xF3B75E", "F.REC:528,373,0xEEB35C|590,375,0xF5B85E|600,372,0xF1B55D", "P.ATK:541,373,0xEEB35C|551,373,0xF2B65D|594,372,0xEEB25C/563,373,0xE3AA58|573,373,0xF7BA5F|389,372,0xF3B75E/546,373,0xE5AC59|565,374,0xF2B65D|573,373,0xF7BA5F", "P.DEF:535,372,0xEEB35C|584,374,0xEEB35C|598,372,0xF1B55D/530,373,0xD59F53|568,374,0xEDB25C|574,372,0xF3B75E", "P.HP:553,373,0xECB15B|563,372,0xF4B85E|580,372,0xF0B45C/548,372,0xDEA656|558,372,0xF6B95F|564,372,0xEBB05B", "P.REC:530,373,0xD59F53|592,373,0xF6B95F|603,373,0xF0B45D/526,373,0xF5B85E|587,373,0xF7BA5F|598,372,0xF5B95E", "CRIT RATE:531,372,0xE6AC59|563,372,0xCC9850|587,374,0xF6B95E/525,304,591,303,0xE8AE5A|559,373,0xE4AB59|583,374,0xF0B55D/526,373,0xE4AB59|559,373,0xE4AB59|583,373,0xEBB05B", "RESIST:536,373,0xF5B85E|573,372,0xEAB05B|588,372,0xF5B95E/540,373,0xD59F53|577,371,0xF4B85E|593,372,0xF3B75E", "CRIT DMG:530,373,0xD59F53|563,372,0xD59F53|593,374,0xC9964F"]