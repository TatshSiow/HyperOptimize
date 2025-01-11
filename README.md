# Developer Notice
To adapt HyperOS 2 and eliminate compatibility problems\
I decided to revise everything again\
Hoping it will be another good start on next release

![test](https://github.com/user-attachments/assets/5cf75f24-5993-4e64-b3b2-328f30d4ff31)
<div align="center">
<a href="https://t.me/TatshSecretCave" ><img height="50" src="https://www.vectorlogo.zone/logos/telegram/telegram-tile.svg"/></a>

<a href="https://t.me/TatshSecretCave" >Telegram</a>
</div>

# What is this?
This is a Magisk Module for HyperOS based devices\
Reduce Power and RAM consumption by optimizing system parameters, disabling Apps & System Process

## What's inside?
- Debloat PreInstalled Apps
- Disable logging services
- Debloat Android core process
- GPU/KGSL Optimization
- CPU/Core Optimization
- Load Balancing Tweaks
- Linux I/O Tweaks
- Hardware Optimization
- HyperOS System Optimization

## Requirements
- Device using HyperOS
- Android 13+

## Dev Notes
- **Brick Rescue Module** is always recommended
- **MIUI** not tested
- **Tablets/Pads** not tested
- **NOT GUARANTEED** to work on all builds
- **CONFLICT** with module with same purpose

## Customize debloat list
- Edit `replace=""` section in the `setup.sh` file if you want specific apps to not be disabled (eg. Gboard)

## How to install?
- Flash the zip in Magisk.

## How to uninstall?
- Uninstall it in Magisk. (No leftovers)

## My Magisk break after uninstalling, what should I do?
- Reboot again

## Just in case you bricked it
1. boot into TWRP or `adb reboot recovery` or `fastboot reboot recovery`
2. Open File manager
3. Goto data/adb/modules
4. delete the module

## Disclaimer
* I'm not responsible for bricked devices, dead SD cards, thermonuclear war, or you getting fired because the alarm app failed (like it did for me...).
* YOU are choosing to make these modifications, and if you point the finger at me for messing up your device, I will laugh at you.
* Your warranty will be void if you tamper with any part of your device / software.
