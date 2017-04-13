#cs
 Function: buyItem
 Navigate to shady shop and search and buy an item.

 Parameters:
	item: (String) Item to buy
	maxGold: (Int) Max gold to be able to spend

 Returns: An array: ["item,cost", "item,cost"...]
#ce

Func buyItem($item, $maxGold)
	Local $itemsBought[0]

	Local $itemImage;
	Switch $item
		Case "egg"
			$itemImage = "shop-egg"
		Case "soulstone"
			$itemImage = "shop-soulstone"
		Case Else
			setLog("Did not recognize the item: " & $item)
			Return $itemsBought
	EndSwitch

	If navigate("village", "shop") = True Then
		;going through rest of items
		Local $soulNoBuy = 0;
		While isArray(findImage("shop-end", 30, 1000, 388, 395, 526, 490)) = False
			Local $timerStart = TimerInit()
			If setLogReplace("Buying items... Looking for item.") Then Return -1

			Local $findItem = "";
			While isArray($findItem) = False
				If setLogReplace("Buying items... Swiping..") Then Return -1

				ControlSend($hWindow, "", "", "{RIGHT}")
				If TimerDiff($timerStart) > 10000 Then
					If setLogReplace("Buying items... Done!") Then Return -1
					navigate("village")
					Return $itemsBought
				EndIf

				If _Sleep(1000) Then Return -1
				$findItem = findImage($itemImage, 50, 100, 192, 310, 521, 468)

				If isArray($findItem) = True And $soulNoBuy > 0 Then ;check for the nobuy soul
					If $findItem[1] <= $soulNoBuy Then
						$soulNoBuy = $findItem[1]
						$findItem = findImage($itemImage, 50, 100, 192, $soulNoBuy+10, 521, 468)

						If isArray($findItem) Then
							$soulNoBuy = 0
							ExitLoop
						EndIf
					Else
						$soulNoBuy = 0
					EndIf
				EndIf
			WEnd

			If setLogReplace("Buying items... An item found") Then Return -1
			clickPoint($findItem, 5, 250) ;select item

			If $item = "soulstone" Then ;prevent buy 3* soul
				If isArray(findImage("shop-x5", 50, 100, 533, 209, 755, 268)) = True Then
					If isArray(findImage("shop-10k", 50, 100, 537, 414, 773, 477)) = True Then
						$soulNoBuy = $findItem[1] ;save y-coord
					EndIf
				ElseIf isArray(findImage("shop-x1", 50, 100, 533, 209, 755, 268)) = True Then
					If isArray(findImage("shop-10k", 50, 100, 537, 414, 773, 477)) = False Then
						$soulNoBuy = $findItem[1]
					EndIf
				EndIf

				If Not($soulNoBuy = 0) Then
					If setLogReplace("Buying items... Not a 4* soulstone.") Then Return -1
				EndIf
			EndIf

			If $soulNoBuy = 0 Then ;buy
				If setLogReplace("Buying items... Checking prices.") Then Return -1

				Local $price = 0
				Select
					Case isArray(findImage("shop-10k", 50, 100, 537, 414, 773, 477)) = True
						$price = 10000
					Case isArray(findImage("shop-50k", 50, 100, 537, 414, 773, 477)) = True
						$price = 50000
					Case isArray(findImage("shop-120k", 50, 100, 537, 414, 773, 477)) = True
						$price = 100000
					Case isArray(findImage("shop-150k", 50, 100, 537, 414, 773, 477)) = True
						$price = 120000
					Case Else
						If setLogReplace("Buying items... Could not check price!") Then Return -1
						navigate("village")
						logUpdate()
						Return $itemsBought
				EndSelect

				If $price <= $maxGold Then ;make purchase
					If setLogReplace("Buying items... Making purchase.") Then Return -1
					logUpdate()
					clickUntil("650, 446", "unknown") ;until prompt shows up
					clickWhile("412, 310", "unknown", 3, 1000) ;until prompt disappears

					_ArrayAdd($itemsBought, $item & "," & $price)
				EndIf
			EndIf
		WEnd

		If setLogReplace("Buying items... Done!") Then Return -1
		navigate("village")
		logUpdate()
	EndIf

	Return $itemsBought
EndFunc