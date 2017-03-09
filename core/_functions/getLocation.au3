#cs ----------------------------------------------------------------------------

 Function: getLocation

 Find location within the game.

 Returns:

	One of the main location or unknown.

#ce ----------------------------------------------------------------------------

Func getLocation()
	_CaptureRegion()

	;village
	If isArray(findImage("location-manage")) = True Then Return "manage"
	If isArray(findImage("location-monsters")) = True Then Return "monsters"
	If isArray(findImage("location-quests")) = True Then Return "quests"

	If isArray(findImage("location-village")) = True Then Return "village"

	;battle
	If isArray(findImage("location-pause")) = True Then Return "pause"
	If isArray(findImage("location-defeat")) = True Then Return "defeat"
	If isArray(findImage("location-battle-sell")) = True Then Return "battle-sell"
	If isArray(findImage("location-battle-sell2")) = True Then Return "battle-sell"
	If isArray(findImage("location-battle-end")) = True Then Return "battle-end"
	If isArray(findImage("location-battle-end-exp")) = True Then Return "battle-end-exp"
	If isArray(findImage("location-battle-end-exp2")) = True Then Return "battle-end-exp"
	If isArray(findImage("location-catch-mode")) = True Then Return "catch-mode"
	If isArray(findImage("location-battle-astromon-full")) = True Then Return "battle-astromon-full"
	If isArray(findImage("location-battle-gem-full")) = True Then Return "battle-gem-full"
	If isArray(findImage("location-battle-pause"))= True Then Return "battle-pause"

	If isArray(findImage("location-battle"))= True Then Return "battle"

	;map
	If isArray(findImage("location-map-stage")) = True Then Return "map-stage"
	If isArray(findImage("location-astroleague")) = True Then Return "astroleague"
	If isArray(findImage("location-association")) = True Then Return "association"
	If isArray(findImage("location-clan")) = True Then Return "clan"
	If isArray(findImage("location-map-battle")) = True Then Return "map-battle"
	If isArray(findImage("location-guardian-dungeons")) = True Then Return "guardian-dungeons"
	If isArray(findImage("location-gold-dungeons")) = True Then Return "gold-dungeons"
	If isArray(findImage("location-golem-dungeons")) = True Then Return "golem-dungeons"
	If isArray(findImage("location-starstone-dungeons")) = True Then Return "starstone-dungeons"
	If isArray(findImage("location-map-astromon-full")) = True Then Return "map-astromon-full"
	If isArray(findImage("location-map-gem-full")) = True Then Return "map-gem-full"
	If isArray(findImage("location-autobattle-prompt")) = True Then Return "autobattle-prompt"

	If isArray(findImage("location-map")) = True Then Return "map"

	;other
	If isArray(findImage("location-inbox")) = True Then Return "inbox"
	If isArray(findImage("location-buy-gem")) = True Then Return "buy-gem"
	If isArray(findImage("location-refill")) = True Then Return "refill"
	If isArray(findImage("location-refill2")) = True Then Return "refill"
	If isArray(findImage("location-refill-confirm")) = True Then Return "refill-confirm"
	If isArray(findImage("location-refill-confirm2")) = True Then Return "refill-confirm"
	If isArray(findImage("location-dialogue")) = True Then Return "dialogue"
	If isArray(findImage("location-lost-connection")) = True Then Return "lost-connection"

	Return "unknown"
EndFunc