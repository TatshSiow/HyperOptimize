DEV NOTES: FIXING BOOTLOOP ISSUES 
![test](https://github.com/user-attachments/assets/5cf75f24-5993-4e64-b3b2-328f30d4ff31)
<div align="center">
<a href="https://t.me/TatshSecretCave" ><img height="50" src="https://www.vectorlogo.zone/logos/telegram/telegram-tile.svg"/></a>

<a href="https://t.me/TatshSecretCave" >Telegram</a>
</div>

# What is this?
This is a Magisk Module for HyperOS based devices\
Reduce Power and RAM consumption by optimizing system parameters, disabling Apps & System Process

## What it does?
- **Hides Detection : Zygisk Injected** (with ReZygisk)
- **Hides Detection : Debugging Environment**
- Debloat Apps
- Debloat system process
- Disable logging
- Disable Wakelocks
- CPU Optimization
- GPU Optimization
- I/O Optimization
- Surface Flinger Tweaks
- Memory Management Tweaks
- System parameters Optimization
- HyperOS System Optimization

## Requirements
- Device using HyperOS

## Dev Notes
- **Bootloop Rescue Module** is always recommended
- **MIUI** not tested
- **Tablets/Pads** not tested
- **NOT GUARANTEED** to work on all builds
- **CONFLICT** with module with same purpose

## FAQ

### Customize debloat list
- Edit `replace=""` section in the `setup.sh` file if you want specific apps to not be disabled (eg. Gboard)

### How to install?
- Flash the zip in Magisk.

### My Magisk break after uninstalled, what should I do?
- Force close and launch again
- If still fails, reboot again

### I bricked my phone, what should I do?!
1. boot into TWRP **or** `adb reboot recovery` **or** `fastboot reboot recovery`
3. Open File manager
4. Go to `data/adb/modules`
5. delete the module and reboot

## Disclaimer
* I'm not responsible for bricked devices, dead SD cards, thermonuclear war, or you getting fired because the alarm app failed (like it did for me...).
* YOU are choosing to make these modifications, and if you point the finger at me for messing up your device, I will laugh at you.
* Your warranty will be void if you tamper with any part of your device / software.


## This project is protected under GPL 3.0 License
<a href="https://github.com/TatshSiow/HyperOptimize/blob/main/LICENSE" ><img height=100 src="https://upload.wikimedia.org/wikipedia/commons/9/93/GPLv3_Logo.svg"/></a>

