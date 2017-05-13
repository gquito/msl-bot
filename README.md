## Monster Super League AutoIT Bot

This is an open-sources bot designed to grind Monster Super League automatically, including capturing legendaries, super rares, rares, variants and grinding Golems while filtering unwanted gems. 

Mainly programmed to gain experience with GitHub and because of the enjoyment of coding.

### How to start bot

*Note: Make sure the display setting icon size for your windows is set to 100%

#### Choose Emulator, recommended: Nox

- For Nox:
   - Install from website (google that)
   
   - Optimal Settings: 
   ![settings](https://i.imgur.com/ck4kF1s.png)
   
   ![optimal settings](https://i.imgur.com/Nggy0H9.png)
   
   ![moresettings](https://i.imgur.com/MDZYlKH.png)
   
- Setting up key map:

   ![key map](https://i.imgur.com/DdErwbJ.png)

- Inside MSL turn off all settings.
  - Especially the Low-Res Mode and Low Power Mode have it set to 'OFF'
  
  ![settings](https://i.imgur.com/0KmRoIA.png)

### Changing bot setting for an Emulator
- Do this when you get the error "Cannot find instance".
- When using a different emulator than default, check in the "Config" tab.
   - You may also need to change the title based on your Nox version.

 ![check](https://i.imgur.com/Y9efB3b.png)
 
- To change look for your emulator:
   - **Title:** NoxPlayer **Instance:** [CLASS:AnglePlayer_0; INSTANCE:1]
   - **Title:** BlueStacks App Player **Instance:** [CLASS:BlueStacksApp; INSTANCE:1]
   
- To manually find it, use AutoIT Window Info

![manual](https://i.imgur.com/MZu5eWE.png)

*Note: You can rename the title with the multi-drive for Nox. Name it unique like NoxPlayer1. 'Nox' has many instances on it already so it may not find it.

### Optimizing the image recognition for the bot
- Some folders in the /core/images/.. may need to be changed for your computer.
   - Use the debug tab tools to create alternate images.

   ![recognition](https://i.imgur.com/BGwh6wU.png)
   
   - You can also just screenshot and crop the image and save as the image you want.
    
### License

This project is licensed under the terms of [GPL-3.0 Open Source License](https://github.com/GkevinOD/msl-bot/blob/master/LICENSE).
