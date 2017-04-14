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

	Global $imagesGemGrades = ["gem-six-star", "gem-five-star", "gem-four-star", "gem-three-star", "gem-two-star", "gem-one-star"]
	Global $imagesGemType = ["gem-conviction", "gem-ferocity", "gem-fortitude", "gem-healing", "gem-intuition", "gem-life", "gem-protection", "gem-ruin", "gem-tenacity", "gem-valor", "gem-vitality"]
	Global $imagesGemStat = ["gem-atk", "gem-def", "gem-rec", "gem-hp", "gem-crit-dmg"]

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
		Global $village_nezz= ["", "360,159|26,78", ""] ;pos1, pos2, pos3

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
	Global $game_pixelBack = [21, 24, 0xF3C645]

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
