#cs ----------------------------------------------------------------------------

 Function: getLocation

 Find location within the game.

 Returns:

	One of the main location or unknown.

#ce ----------------------------------------------------------------------------

Func getLocation()
	_CaptureRegion()

	;battle
	If isArray(findImageFiles("location-pause")) = True Then Return "pause"
	If isArray(findImageFiles("location-defeat")) = True Then Return "defeat"
	If isArray(findImageFiles("location-battle-sell")) = True Then Return "battle-sell"
	If isArray(findImageFiles("location-battle-end")) = True Then Return "battle-end"
	If isArray(findImageFiles("location-battle-end-exp")) = True Then Return "battle-end-exp"
	If isArray(findImageFiles("location-catch-mode")) = True Then Return "catch-mode"
	If isArray(findImageFiles("location-battle-astromon-full")) = True Then Return "battle-astromon-full"
	If isArray(findImageFiles("location-battle-gem-full")) = True Then Return "battle-gem-full"
	If isArray(findImageFiles("location-battle-pause"))= True Then Return "battle-pause"

	If isArray(findImageFiles("location-battle"))= True Then Return "battle"

	;map
	If isArray(findImageFiles("location-map-stage")) = True Then Return "map-stage"
	If isArray(findImageFiles("location-astroleague")) = True Then Return "astroleague"
	If isArray(findImageFiles("location-association")) = True Then Return "association"
	If isArray(findImageFiles("location-clan")) = True Then Return "clan"
	If isArray(findImageFiles("location-map-battle")) = True Then Return "map-battle"
	If isArray(findImageFiles("location-guardian-dungeons")) = True Then Return "guardian-dungeons"
	If isArray(findImageFiles("location-gold-dungeons")) = True Then Return "gold-dungeons"
	If isArray(findImageFiles("location-golem-dungeons")) = True Then Return "golem-dungeons"
	If isArray(findImageFiles("location-starstone-dungeons")) = True Then Return "starstone-dungeons"
	If isArray(findImageFiles("location-map-astromon-full")) = True Then Return "map-astromon-full"
	If isArray(findImageFiles("location-map-gem-full")) = True Then Return "map-gem-full"
	If isArray(findImageFiles("location-autobattle-prompt")) = True Then Return "autobattle-prompt"

	If isArray(findImageFiles("location-map")) = True Then Return "map"

	;village
	If isArray(findImageFiles("location-manage")) Then Return "manage"
	If isArray(findImageFiles("location-monsters")) = True Then Return "monsters"
	If isArray(findImageFiles("location-quests")) = True Then Return "quests"
	If isArray(findImageFiles("location-esc")) = True Then Return "esc"

	If isArray(findImageFiles("location-village")) = True Then Return "village"

	;other
	If isArray(findImageFiles("location-inbox")) = True Then Return "inbox"
	If isArray(findImageFiles("location-buy-gem")) = True Then Return "buy-gem"
	If isArray(findImageFiles("location-refill")) = True Then Return "refill"
	If isArray(findImageFiles("location-refill-confirm")) = True Then Return "refill-confirm"
	If isArray(findImageFiles("location-dialogue")) = True Then Return "dialogue"
	If isArray(findImageFiles("location-lost-connection")) = True Then Return "lost-connection"

	Return "unknown"
EndFunc