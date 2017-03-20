## Monster Super League AutoIT Bot

This is an open-sources bot designed to grind Monster Super League automatically, including capturing legendaries, super rares, rares, variants and grinding Golems while filtering unwanted gems. 

Mainly programmed to gain experience with GitHub and because of the enjoyment of coding.

### How to start bot
- Install BlueStacks Files:
BlueStacks Rooted 0.10.7.5601 (google that)
   - Note that there are graphical bugs in this version of bluestacks and it is normal.
   - Other emulators may have different graphic that is not optimized for the current bot.
 
- Change the resolution to 800x600:
  - Open up the Registry Editor (WIN+R -> regedit)
  - Navigate to HKEY_LOCATION_MACHINE -> SOFTWARE -> BlueStacks -> Guests -> Android -> FrameBuffer -> 0
  - Edit the GuestHeight, GuestWidth, WindowHeight, WindowWidth 
  - Make sure the Base is 'Decimal' and the heights is 600 and width is 800.
  - Note: If you are using other emulators, the resolution is 800x550 (BlueStacks has the bar at the bottom which is -50 height)

- Setting up BlueStacks key map for bot:

![steps](http://i.imgur.com/8f98olQ.gif "Step-by-Step")

- Inside MSL turn off all settings.
  - Especially the Low-Res Mode and Low Power Mode have it set to 'OFF'
  
- Load a script and edit the configs to your liking.

- Start the bot and let it grind for you.

### Optimizing the image recognition for the bot
- If certain locations or objects are not recognized within game you will need to replace them.

- To replace or create alternative images for locations:
   - Using the Location checkbox, check it and see if the location is 'unknown'
   - If it is 'unknown' then uncheck and the 'Set Location' button will be enabled.
   - Enter whichever location the screen is suppose to be.
      - There is a list of the available locations you can enter.
   - Test the location again. If it does not work create an issue on this GitHub.

- To replace an image you can use various methods:
  - The bot has a debug tab in which you can use to replace images.
    - Use F6 to target the top-left of the image you want to save, F7 for the bottom-right.
    - Use 'Save Image As' button to save image in a certain folder. Format: [folder]-[imagename]
  - Use a third-party software such as Greenshot to replace the image.
  - Lastly just print screen and crop the portion you want.
  
- When running Farm Rare script, the bot will not attack the rares that show up.
  - If it gets stuck on the battle screen with a rare, you must replace the images that recognize the rares. The folder location is located in core/images/battle/.. Ex: battle-rare, battle-super-rare..
  - In situations where the bot recognizes there is a rare, but does not recognize the images in catch-mode. The bot will create a NotRecognized.bmp file in the main folder. You can use that to replace images in catch folder.
  - Inside the catch mode, you will can replace the images in core/images/catch/.. Ex: catch-rare, catch-super-rare..
    - You will notice there are numbers on some, those are just alternative images. If you do not want to replace, just add a new image with the next number available. The bot will automatically recognize the new images.
    
### License

This project is licensed under the terms of [GPL-3.0 Open Source License](https://github.com/GkevinOD/msl-bot/blob/master/LICENSE).
