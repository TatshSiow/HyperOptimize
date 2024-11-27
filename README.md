![test](https://github.com/user-attachments/assets/5cf75f24-5993-4e64-b3b2-328f30d4ff31)

# What is this?
This is a Magisk Module for HyperOS based devices\
Reduce Power and RAM consumption by optimizing system parameters, disabling Apps & System Process

## Requirements
Device using HyperOS

## Dev Notes
* **MIUI** not tested
* **Brick Rescue Module** is always recommended
* **NOT GUARANTEED** to work on all builds
Tested on EliteROM 1.0.17.0 (Android 14)

## Customize the disable applist
* Edit `replace=""` section in the `install.sh` file if you want specific apps to not be disabled (eg. Gboard)

## How to install?
Flash the zip in Magisk.

## How to uninstall?
Uninstall it in Magisk. (No leftovers)

## Just in case you bricked it
1. boot into TWRP or `adb reboot recovery` or `fastboot reboot recovery`
2. Open File manager
3. Goto data/adb/modules
4. delete the module

## Disclaimer
* I'm not responsible for bricked devices, dead SD cards, thermonuclear war, or you getting fired because the alarm app failed (like it did for me...).
* YOU are choosing to make these modifications, and if you point the finger at me for messing up your device, I will laugh at you.
* Your warranty will be void if you tamper with any part of your device / software.
