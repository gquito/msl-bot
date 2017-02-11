#cs ----------------------------------------------------------------------------

 Function: getLocation

 Find location within the game.

 Returns:

	One of the main locations or unknown.

#ce ----------------------------------------------------------------------------

Func getLocation()
	_CaptureRegion()
	
	;village
	If isArray(findImage("locations/location-manage")) = True Then Return "manage"
	If isArray(findImage("locations/location-monsters")) = True Then Return "monsters"
	If isArray(findImage("locations/location-quests")) = True Then Return "quests"

	If isArray(findImage("locations/location-village")) = True Then Return "village"
	
	;battle
	If isArray(findImage("locations/location-pause")) = True Then Return "pause"
	If isArray(findImage("locations/location-battle-sell")) = True Then Return "battle-sell"
	If isArray(findImage("locations/location-battle-end")) = True Then Return "battle-end"
	If isArray(findImage("locations/location-battle-end-exp")) = True Then Return "battle-end-exp"
	If isArray(findImage("locations/location-catch-mode")) = True Then Return "catch-mode"
	If isArray(findImage("locations/location-battle-astromon-full")) = True Then Return "battle-astromon-full"
	If isArray(findImage("locations/location-battle-gem-full")) = True Then Return "battle-gem-full"
	If isArray(findImage("locations/location-battle-pause"))= True Then Return "battle-pause"
	
	If isArray(findImage("locations/location-battle"))= True Then Return "battle"
	
	;map
	If isArray(findImage("locations/location-map-stage")) = True Then Return "map-stage"
	If isArray(findImage("locations/location-astroleague")) = True Then Return "astroleague"
	If isArray(findImage("locations/location-association")) = True Then Return "association"
	If isArray(findImage("locations/location-map-battle")) = True Then Return "map-battle"
	If isArray(findImage("locations/location-guardian-dungeons")) = True Then Return "guardian-dungeons"
	If isArray(findImage("locations/location-gold-dungeons")) = True Then Return "gold-dungeons"
	If isArray(findImage("locations/location-golem-dungeons")) = True Then Return "golem-dungeons"
	If isArray(findImage("locations/location-starstone-dungeons")) = True Then Return "starstone-dungeons"
	If isArray(findImage("locations/location-map-astromon-full")) = True Then Return "map-astromon-full"
	If isArray(findImage("locations/location-map-gem-full")) = True Then Return "map-gem-full"
	
	If isArray(findImage("locations/location-map")) = True Then Return "map"
	
	;other
	If isArray(findImage("locations/location-lost-connection")) = True Then Return "lost-connection"
	
	Return "unknown"
EndFunc