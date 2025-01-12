#!/system/bin/sh
# Please don't hardcode /magisk/modname/... ; instead, please use $MODDIR/...
# This will make your scripts compatible even if Magisk change its mount point in the future
# This script will be executed in post-fs-data mode
# More info in the main Magisk thread
MODDIR=${0%/*}

if [ "$(getprop ro.hardware)" = "qcom" ]; then
    #Qualcomm
    resetprop -n persist.debug.coresight.config ""
else
    #MediaTeK
    resetprop -n ro.vendor.mtk_prefer_64bit_proc 1
    resetprop -n persist.vendor.duraspeed.support 0
    resetprop -n persist.vendor.duraspeed.lowmemory.enable 0
    resetprop -n persist.vendor.duraeverything.support 0
    resetprop -n persist.vendor.duraeverything.lowmemory.enable 0
fi

if [ "$(getprop ro.mi.os.version.name)" = "OS2.0" ]; then
    # ZRAM 1:1
    resetprop -n persist.miui.extm.dm_opt.enable true
fi

# getprop | grep -i (prop-properties)