
Global $ASTROMON_INFO_NAME = 0
Global $ASTROMON_INFO_IMAGE = 1
Global $ASTROMON_INFO_MAP = 2
Global $ASTROMON_INFO_STAGE = 3
Global $ASTROMON_INFO_DIFFICULTY = 4

Func getAstromonInfo($monster)

	Local $imageName = null, $map = null, $stage = null, $difficulty = null
	Switch $monster
		Case "slime"
			$imageName = "catch-one-star"
			$map = "map-phantom-forest"
			$stage = "gold"
			$difficulty = "normal"
		Case "mimic"
			$imageName = "catch-one-star"
			$map = "map-pagos-coast"
			$stage = "exp"
			$difficulty = "extreme"
		Case "sparkler"
			$imageName = "catch-one-star"
			$map = "map-magma-crags"
			$stage = "exp"
			$difficulty = "extreme"
		Case "", null
			$monster = null
		Case Else
			setLog("Unknown Monster: " & $monster, 1, $LOG_WARN)
	EndSwitch
	
	Local $monInfo = [$monster, $imageName, $map, $stage, $difficulty]
	return $monInfo
EndFunc