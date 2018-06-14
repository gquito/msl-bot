# Monster Super League AutoIT Bot

### Join the discord server to get help in setting up: https://discord.gg/UQGRnwf

A free open-sourced bot for Monster Super League using AutoIT programming language. This bot can do the tedious tasks of catching rare astromons, farming golems while selling the unwanted gems, and more. 

#### Features:
  - Capture Legendary, Exotic, Super Rare, Rare, and Variant monsters.
  - Collect trees every hour. 
  - Buy items from shady shop.
  - Attack Guardian Dungeons.
  - Farm Golem Dungeons and filter out unwanted gems.
  - Slime farming and gem/gold conversion.
  - And more.

### Table of Contents

[How to use bot](https://github.com/GkevinOD/msl-bot#how-to-use-bot) <br>
[Manually updating](https://github.com/GkevinOD/msl-bot#manually-updating) <br>
[Common Issues](https://github.com/GkevinOD/msl-bot#common-issues) <br>
[Setting up multiple emulators](https://github.com/GkevinOD/msl-bot#setting-up-multiple-emulators) <br>
[Troubleshooting](https://github.com/GkevinOD/msl-bot#troubleshooting) <br>
[Reporting an issue](https://github.com/GkevinOD/msl-bot#reporting-an-issue)

## How to use bot
### Requirements:
* Windows 7/8/8.1/10.
* Latest updates from your Graphics Drivers.
* Latest version of [Nox](https://www.bignox.com/). Recommended versions: 5.0.0.1 and above.
* AutoIT: [Download here](https://www.autoitscript.com/site/autoit/).
* The bot app: [Download here](https://github.com/GkevinOD/msl-bot/archive/v3.0.zip).

---
### Before you start:
* When running the bot app through .au3, Run Script (x86) by right clicking on the file.
* Set your Windows Display Scaling to 100%. 
* Enable Windows Aero Mode (Windows 7).

---
### Configuring your Nox Settings:
**Step 1**: Enable `Fixed window size` in the Interface settings tab.

![Interface settings](https://i.imgur.com/uVKIVTc.png)

**Step 2**: Change the resolution to custom with **Width: 800**, **Height: 552**, and **DPI: 160**

![Resolution](https://i.imgur.com/tlirVWL.png)

**Step 3**: Change Graphics Rendering mode according to Windows version. Check by pressing `Win+R` and typing **winver**.
  - Version 1709 **OpenGL**.
  - Other versions require **DirectX**.

![Windows version 1709](https://i.imgur.com/acU6Al9.png)

![Graphics Rendering Mode](https://i.imgur.com/2H9WuG5.png)

**Step 4**: Save settings.

---
### Monster Super League Game Settings:
**Step 1**: Change language to `English`.

![Language Setting](https://i.imgur.com/52pN9fo.png)

**Step 2**: Turn off all settings, **except Low-Res Mode**.

![Game Setting](https://i.imgur.com/r9IzT5w.png)

---
### Changing Bot Config:
**Step 1**: Change Emulator Title, Class and Instance according the the info provided by the AutoIt Window Info *Finder Tool*.

*Note: If your title is 'Nox', you need to edit it to a different name such as NoxPlayer or Nox1. The bot will not be able to detect the instance if the title is 'Nox'.

![Title Class Instance](https://i.imgur.com/WDYfeJ3.png)

![Bot Config Emulator Settings](https://i.imgur.com/dicFkhe.png)

**Step 2**: Run desired script. Descriptions of each script is available on the bot app.

  - For any errors, refer to the *Common Issues*.

<br>

## Manually updating
**Step 1**: Download the latest version from the same [link](https://github.com/GkevinOD/msl-bot/archive/v3.0.zip).

**Step 2**: Open the ZIP file and extract the contents into the old version.

![Drag files](https://i.imgur.com/Ui9kDFf.png)

**Step 3**: When the Replace or Skip Files prompt appear, select the option to replace.
  
  Your existing configs will be saved.
  
![Replace All](https://i.imgur.com/K3gVPeF.png)

<br>

## Common Issues
### Window/Control Handle not found.
  - This issue can be fixed by correctly setting the Bot config. Refer to [*Changing Bot Config*](https://github.com/GkevinOD/msl-bot#changing-bot-config), Step 1 of **How to use bot** section.

![Window/Control handle error](https://i.imgur.com/m21F7iP.png)

---
### Nox path does not exist.
  - Locate file location of the Nox.exe and in the same folder lies **nox_adb.exe** or **adb.exe**. Use the path to the file and enter it in *ADB Path* config.
  
![Nox path error](https://i.imgur.com/GxtuL61.png)

![Nox adb path](https://i.imgur.com/1fHkUAl.png)

---
### Nox device does not exist.
  - This error will usually provide a list of all available devices. Chances are one of the device is the Nox emulator. If device is not listed, restart nox.
  
![Nox device](https://i.imgur.com/zUg57e5.png)

<br>
<br>
<br>

## Setting up multiple emulators
**Step 1**: Create a new profile by editing the `Profile Name` setting in \_Config.

**Step 2**: Change the ADB Device field to the device name connected to the second emulator.

  - To find the list of devices, open Debug Input (`Ctrl+D`) and enter `MsgBox(0, "", adbCommand("devices"))`.
  
  - If no new device shows up, then restart Nox.
  
![Device List](https://i.imgur.com/8V4X5qK.png)
  
**Step 3**: Run a script.

<br>

## Troubleshooting
### Script looping in airship or doing nothing.
#### Before troubleshooting for this problem:
  - Open Debug Input `Ctrl+D` and enter `getLocation()` in airship and the map.
  - If the locations say 'unknown' on the log, proceed with the following troubleshooting.
  - If the location is `village` in the airship and `map` in the map, your problem is different.

---
**Using the RestartNox() function**: 

  - If you have the Nox emulator, you can open Debug Input `Ctrl+D` and enter `RestartNox()`. <br>
  - This function will close and open the Nox process with correct resolution, dpi, and language set. <br>
  - After restarting, try running a script. <br>
  - If the issue still occurs, continue with other methods.
  
**Using other Capture Mode**:

  - If `WinAPI` does not work for you, try switching to `ADB` or `None` capture mode.
  - If none of the modes work for you, ask help in Discord or create an issue report on Github.
  
<br>

## Reporting an issue
Issue report can be made on Github or Discord.

#### Include the following:
  - Nox version. Ex. version 6.0.0.0
  - Bot app version. Ex. version 3.8.0
  - Script that you used. Ex. Farm Rare
  - Description of the problem.
  - A screenshot if possible.

## License

This project is licensed under the terms of [GPL-3.0 Open Source License](https://github.com/GkevinOD/msl-bot/blob/master/LICENSE).
