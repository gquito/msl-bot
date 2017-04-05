;define
	Global $textOutput; output for gui
	Global $listLocation[0]; list of locations.

;directory
	Global Const $strImageSearchDir = @ScriptDir & "\core\_functions\_core\imagesearch\ImageSearchDLL.dll"
	Global Const $strImageDir = @ScriptDir & "\core\images\"

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

;location coordinates and size
Global $strKnownLocation = "association,astroleague,autobattle_prompt,battle,battle_astromon_full,battle_gem_full,battle_end,battle_end_exp,battle_sell,buy_gem,dialogue,catch_mode,clan,defeat,inbox,gold_dungeons,golem_dungeons,guardian_dungeons,lost_connection,manage,map,map_battle,map_stage,map_astromon_full,map_gem_full,monsters,pause,quests,refill,refill_confirm,starstone_dungeons,village"

Global $dim_association = "106,273,98,27"
Global $dim_astroleague = "96,464,86,10"
Global $dim_autobattle_prompt = "400,195,118,11"
Global $dim_battle = "33,338,25,10"
Global $dim_battle_astromon_full = "398,239,293,7"
Global $dim_battle_gem_full = "313,227,33,9"
Global $dim_battle_end = "399,396,9,18"
Global $dim_battle_end_exp = "246,330,38,14"
Global $dim_battle_sell = "405,467,53,45"
Global $dim_buy_gem = "241,310,22,16"
Global $dim_dialogue = "755,24,61,9"
Global $dim_esc = "505,254,29,13"
Global $dim_catch_mode = "463,72,22,65"
Global $dim_clan = "749,187,44,12"
Global $dim_defeat = "328,331,75,7"
Global $dim_inbox = "410,127,43,7"
Global $dim_gold_dungeons = "341,135,82,7"
Global $dim_golem_dungeons = "347,137,88,8"
Global $dim_guardian_dungeons = "358,135,119,7"
Global $dim_lost_connection = "428,317,35,24"
Global $dim_manage = "748,456,22,130"
Global $dim_map = "450,18,16,20"
Global $dim_map_battle = "149,384,262,7"
Global $dim_map_stage = "738,199,61,9"
Global $dim_map_astromon_full = "340,230,179,8"
Global $dim_map_gem_full = "311,230,106,6"
Global $dim_monsters = "747,507,62,15"
Global $dim_pause = "40,508,1,15"
Global $dim_quests = "70,220,30,144"
Global $dim_refill = "398,91,53,6"
Global $dim_refill_confirm = "398,185,122,7"
Global $dim_starstone_dungeons = "356,137,110,9"
Global $dim_village = "775,86,14,14"

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

		Global $battle_pixelQuest = [343, 379, 0xDA071E]
