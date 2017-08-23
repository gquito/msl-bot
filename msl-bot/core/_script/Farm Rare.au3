#cs
	Function: farmRare
	Calls farmRareMain function with config settings

	Author: GkevinOD (2017)
#ce
Func farmRare()
	Local $buyEggs = Int(IniRead($botConfigDir, "Farm Rare", "buy-eggs", 0))
	Local $buySoulstones = Int(IniRead($botConfigDir, "Farm Rare", "buy-soulstones", 1))
	Local $maxGoldSpend = Int(IniRead($botConfigDir, "Farm Rare", "max-gold-spend", 100000))
	Local $maxGemRefill = Int(IniRead($botConfigDir, "Farm Rare", "max-spend-gem", 0))
	Local $map = "map-" & StringReplace(IniRead($botConfigDir, "Farm Rare", "map", "phantom forest"), " ", "-")
	Local $guardian = IniRead($botConfigDir, "Farm Rare", "guardian-dungeon", "0")
	Local $difficulty = IniRead($botConfigDir, "Farm Rare", "difficulty", "normal")
	Local $stage = IniRead($botConfigDir, "Farm Rare", "stage", "gold")
	Local $sellGems = StringSplit(IniRead($botConfigDir, "Farm Rare", "sell-gems-grade", "1,2,3"), ",", 2)
	Local $rawCapture = StringSplit(IniRead($botConfigDir, "Farm Rare", "capture", "legendary,super rare,rare,exotic,variant"), ",", 2)
	Local $quest = IniRead($botConfigDir, "Farm Rare", "collect-quest", "1")
	Local $hourly = IniRead($botConfigDir, "Farm Rare", "collect-hourly", "1")

	setLog("~~~Starting 'Farm Rare' script~~~", 2)
		Local $monster = [null, null, $map, $stage, $difficulty]
		Local $shoppingList = [1, $buySoulstones, $buyEggs]
		_farmAstromonMain($monster, 0, $rawCapture, 1, 0, $maxGemRefill, $quest, $hourly, $shoppingList, 0, $maxGoldSpend, $guardian, $sellGems)
	setLog("~~~Finished 'Farm Rare' script~~~", 2)
EndFunc   ;==>farmRare