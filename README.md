![test](https://github.com/user-attachments/assets/5cf75f24-5993-4e64-b3b2-328f30d4ff31)
<div align="center">
<a href="https://t.me/TatshSecretCave" ><img height="50" src="https://www.vectorlogo.zone/logos/telegram/telegram-tile.svg"/></a>
  
<a href="https://t.me/TatshSecretCave" >Telegram</a>
</div>

# What is this?
This is a Magisk Module for HyperOS based devices\
Reduce Power and RAM consumption by optimizing system parameters, disabling Apps & System Process

## Changes made in this module
- Debloat Apps (Replace Apps with empty folder)
- Disable logging services
- Debloat Android core process
- GPU/KGSL Optimization
- CPU/Core Optimization
- Load Balancing Tweaking
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

## Customize debloat list
- Edit `replace=""` section in the `setup.sh` file if you want specific apps to not be disabled (eg. Gboard)

## How to install?
- Flash the zip in Magisk.

## How to uninstall?
- Uninstall it in Magisk. (No leftovers)

## My Magisk break after uninstalling, what should I do?
- AFter remove the module, you might face this at the first time
- Reboot again will fix it

## Just in case you bricked it
1. boot into TWRP or `adb reboot recovery` or `fastboot reboot recovery`
2. Open File manager
3. Goto data/adb/modules
4. delete the module

## Stay Awake Idle Power Drain Result
- Device: Xiaomi 13(Snapdragon 8 Gen 2)
- ROM: EliteHyper Lite 1.0.17.0.UMCCNXM (Android 14)
- Kernel: hfdem GKI 5.15.167
- Device already debloated

|  Without HyperOptimize (Minimum:115)  |  With HyperOptimize (Minimum:100) |
:-------------------------:|:-------------------------:
![](https://github.com/user-attachments/assets/60b8279a-e5e1-48ce-b5b2-f6c7e6662e3d)  |  ![](https://github.com/user-attachments/assets/016c0850-e8fa-43e6-99b5-b12312524a44)

Don't compare it with different configuration and device

## Disclaimer
* I'm not responsible for bricked devices, dead SD cards, thermonuclear war, or you getting fired because the alarm app failed (like it did for me...).
* YOU are choosing to make these modifications, and if you point the finger at me for messing up your device, I will laugh at you.
* Your warranty will be void if you tamper with any part of your device / software.
