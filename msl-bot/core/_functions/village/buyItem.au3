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

	If setLogReplace("Buying items... Navigating to shop.") Then Return -1
	If navigate("village", "shop") = True Then
		Local $arrayAreas = [[185, 156, 262, 244], [185, 243, 256, 321], [189, 320, 261, 398], [187, 398, 260, 480]]

		Do
			If setLogReplace("Buying items... Searching for item.") Then Return -1

			clickPoint("223,433", 3, 100)
			_CaptureRegion()
			Local $firstPixel = _GDIPlus_BitmapGetPixel($hBitmap, 653, 202)

			For $area = 0 To 3
				Local $findItem = findImage($itemImage, 50, 500, $arrayAreas[$area][0], $arrayAreas[$area][1], $arrayAreas[$area][2], $arrayAreas[$area][3])
				If isArray($findItem) Then
					If setLogReplace("Buying items... An item found") Then Return -1
					clickPoint($findItem, 5, 250) ;select item

					If $item = "soulstone" Then ;prevent buy 3* soul
						If isArray(findImage("shop-x5", 50, 100, 533, 209, 755, 268)) = True Then
							If isArray(findImage("shop-10k", 50, 100, 537, 414, 773, 477)) = True Then
								If setLogReplace("Buying items... Not a 4* soulstone.") Then Return -1
								ContinueLoop
							EndIf
						ElseIf isArray(findImage("shop-x1", 50, 100, 533, 209, 755, 268)) = True Then
							If isArray(findImage("shop-10k", 50, 100, 537, 414, 773, 477)) = False Then
								If setLogReplace("Buying items... Not a 4* soulstone.") Then Return -1
								ContinueLoop
							EndIf
						EndIf
					EndIf

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
						Local $fileCounter = 1
						While FileExists(@ScriptDir & "/item-bought" & $fileCounter & ".bmp")
							$fileCounter += 1
						WEnd
						_CaptureRegion("item-bought" & $fileCounter & ".bmp", 529, 154, 778, 478)

						If setLogReplace("Buying items... Purchasing " & $item & " for " & $price & " gold.") Then Return -1
						logUpdate()
						clickUntil("650, 446", "unknown") ;until prompt shows up
						clickWhile("412, 310", "unknown", 3, 1000) ;until prompt disappears

						_ArrayAdd($itemsBought, $item & "," & $price)
					EndIf
				EndIf
			Next

			For $i = 0 To 2
				If _Sleep(1000) Then Return -1
				ControlSend($hWindow, "", "", "{RIGHT}")
			Next
			If _Sleep(1000) Then Return -1

			clickPoint("223,433", 3, 100)
			_CaptureRegion()
			Local $secondPixel = _GDIPlus_BitmapGetPixel($hBitmap, 653, 202)
		Until $firstPixel = $secondPixel

		If setLogReplace("Buying items... Done!") Then Return -1
		navigate("village")
		logUpdate()
	Else
		If setLogReplace("Buying items... Could not navigate to shop!") Then Return -1
	EndIf

	Return $itemsBought
EndFunc