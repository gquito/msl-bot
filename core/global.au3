;define
	Global $textOutput; output for gui

;core global variables
	Global Const $hWindow = WinGetHandle("BlueStacks App Player")
	Global Const $hControl = ControlGetHandle("BlueStacks App Player", "", "[CLASS:BlueStacksApp; INSTANCE:1]")

;directory
	Global Const $strImageSearchDir = @ScriptDir & "\core\_functions\_core\imagesearch\ImageSearchDLL.dll"
	Global Const $strImageDir = @ScriptDir & "\core\images\"

;bot data
	Global $boolRunning = False ;State of the bot.

;bitmaps
	Global $hBitmap; Image for pixel functions.
	Global $hHBitmap; Handle Image for pixel functions.

;image name arrays
	Global $imagesOneStarCombo = ["catch-legendary1", "catch-legendary2", "catch-legendary3", "catch-legendary4", "catch-legendary5", "catch-super-rare", "catch-super-rare2", "catch-exotic", "catch-exotic2", "catch-exotic3", "catch-rare", "catch-rare2", "catch-rare3", "battle-four-star", "catch-four-star", "catch-variant", "catch-variant2", "catch-variant3", "battle-one-star"]
	Global $imagesRareCombo = ["catch-legendary1", "catch-legendary2", "catch-legendary3", "catch-legendary4", "catch-legendary5", "catch-super-rare", "catch-super-rare2", "catch-exotic", "catch-exotic2", "catch-exotic3", "catch-rare", "catch-rare2", "catch-rare3", "battle-four-star", "catch-four-star", "battle-three-star", "catch-variant", "catch-variant2", "catch-variant3"]
	Global $imagesRareAstromon = ["battle-legendary1", "battle-legendary2", "battle-super-rare", "battle-rare", "battle-variant", "battle-exotic"]
	Global $imagesCatch = ["catch-normal-success", "catch-rare-success", "catch-super-rare-success", "catch-legendary-success"]
	Global $imagesClose = ["inbox-close", "dungeon-close", "stage-close", "manage-close", "village-close"]
	Global $imagesFarmMap = ["phantom-forest", "aria-lake", "mirage-ruins", "seabed-caves"]
	Global $imagesMap = ["dungeons", "phantom-forest", "lunar-valley", "aria-lake", "mirage-ruins", "astromon-league", "pagos-coast", "seabed-caves", "magma-crags", "star-sanctuary"]
	Global $imagesUnwantedGems = ["manage-one-star", "manage-two-star", "manage-three-star", "manage-four-star", "manage-new"]

	Global $imagesGemGrades = ["\gem record\six-star", "\gem record\five-star", "\gem record\four-star", "battle-three-star", "battle-two-star", "battle-one-star"]
	Global $imagesGemType = ["\gem record\conviction", "\gem record\ferocity", "\gem record\fortitude", "\gem record\healing", "\gem record\intuition", "\gem record\life", "\gem record\protection", "\gem record\ruin", "\gem record\tenacity", "\gem record\valor", "\gem record\vitality"]
	Global $imagesGemStat = ["\gem record\atk", "\gem record\def", "\gem record\rec", "\gem record\hp", "\gem record\crit dmg"]

;parallel arrays
	Global $parallel_imagesCatch = ["normal", "rare"]

;coordinations
	Global $game_coorTap = [759, 482]
	Global $game_coorConnectionRetry = [332, 322]

	;village
		Global $village_coorPlay = [711, 507]
		Global $village_coorShop = [524, 503]
		Global $village_coorQuests = [459, 502]
		Global $village_coorSummon = [393, 501]
		Global $village_coorAstroguide = [324, 503]
		Global $village_coorMonsters = [253, 505]

		Global $village_coorArrayQuestsTab = ["village_coorQuestsDaily", "village_coorQuestsWeekly", "village_coorQuestsMonthly", "village_coorQuestsChallenges", "village_coorQuestsCapture"]
		Global $village_coorQuestsDaily = [717, 127]
		Global $village_coorQuestsWeekly = [592, 125]
		Global $village_coorQuestsMonthly = [463, 126]
		Global $village_coorQuestsChallenges = [333, 125]
		Global $village_coorQuestsCapture = [213, 127]

		Global $village_coorManage = [739, 199]
		Global $village_coorUpgrade = [392, 415]
		Global $village_coorSell = [538, 394]
		Global $village_coorSellConfirm = [398, 331]

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

		Global $map_coorB10 = [663, 431]
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
		Global $battle_coorSellConfirm = [395, 329]

		Global $battle_coorCatch = [741, 278]
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

		Global $battle_pixelQuest = [343, 377, 0xE30A2D]
