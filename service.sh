#!/system/bin/sh
# Please don't hardcode /magisk/modname/... ; instead, please use $MODDIR/...
# This will make your scripts compatible even if Magisk change its mount point in the future
# This script will be executed in late_start service mode
# More info in the main Magisk thread

# Disable debug process
echo 0 > /sys/module/binder/parameters/debug_mask
echo 0 > /sys/module/binder_alloc/parameters/debug_mask
echo 0 > /sys/module/msm_show_resume_irq/parameters/debug_mask
echo 0 > /sys/module/millet_core/parameters/millet_debug
echo 0 > /proc/sys/migt/migt_sched_debug
echo N > /sys/kernel/debug/debug_enabled

#UFS Tuning
#Disable I/O stats
echo 0 > /sys/block/loop0/queue/iostats
echo 0 > /sys/block/loop1/queue/iostats
echo 0 > /sys/block/loop2/queue/iostats
echo 0 > /sys/block/loop3/queue/iostats
echo 0 > /sys/block/loop4/queue/iostats
echo 0 > /sys/block/loop5/queue/iostats
echo 0 > /sys/block/loop6/queue/iostats
echo 0 > /sys/block/loop7/queue/iostats
echo 0 > /sys/block/loop8/queue/iostats
echo 0 > /sys/block/loop9/queue/iostats
echo 0 > /sys/block/loop10/queue/iostats
echo 0 > /sys/block/loop11/queue/iostats
echo 0 > /sys/block/loop12/queue/iostats
echo 0 > /sys/block/loop13/queue/iostats
echo 0 > /sys/block/loop14/queue/iostats
echo 0 > /sys/block/loop15/queue/iostats
echo 0 > /sys/block/loop16/queue/iostats
echo 0 > /sys/block/loop17/queue/iostats
echo 0 > /sys/block/loop18/queue/iostats
echo 0 > /sys/block/loop19/queue/iostats
echo 0 > /sys/block/loop20/queue/iostats
echo 0 > /sys/block/loop21/queue/iostats
echo 0 > /sys/block/loop22/queue/iostats
echo 0 > /sys/block/loop23/queue/iostats
echo 0 > /sys/block/loop24/queue/iostats
echo 0 > /sys/block/loop25/queue/iostats
echo 0 > /sys/block/loop26/queue/iostats
echo 0 > /sys/block/loop27/queue/iostats
echo 0 > /sys/block/loop28/queue/iostats
echo 0 > /sys/block/loop29/queue/iostats
echo 0 > /sys/block/loop30/queue/iostats
echo 0 > /sys/block/loop31/queue/iostats
echo 0 > /sys/block/loop32/queue/iostats
echo 0 > /sys/block/loop33/queue/iostats
echo 0 > /sys/block/loop34/queue/iostats
echo 0 > /sys/block/loop35/queue/iostats
echo 0 > /sys/block/loop36/queue/iostats
echo 0 > /sys/block/loop37/queue/iostats
echo 0 > /sys/block/loop38/queue/iostats
echo 0 > /sys/block/loop39/queue/iostats
echo 0 > /sys/block/sda/queue/iostats
echo 0 > /sys/block/sda/queue/iostats
echo 0 > /sys/block/sdb/queue/iostats
echo 0 > /sys/block/sdc/queue/iostats
echo 0 > /sys/block/sdd/queue/iostats
echo 0 > /sys/block/sde/queue/iostats
echo 0 > /sys/block/sdf/queue/iostats

#Disable I/O Debug Helper
echo 0 > /sys/block/sda/queue/nomerges
echo 0 > /sys/block/sdb/queue/nomerges
echo 0 > /sys/block/sdc/queue/nomerges
echo 0 > /sys/block/sdd/queue/nomerges
echo 0 > /sys/block/sde/queue/nomerges
echo 0 > /sys/block/sdf/queue/nomerges

# disable transparent_hugepage(reduce memory fragmentation)
if [ -f /sys/kernel/mm/transparent_hugepage/enabled ]; then
echo never > /sys/kernel/mm/transparent_hugepage/enabled
fi

#kill bootlogoupdater
am kill bootlogoupdater
killall -9 bootlogoupdater
am kill bootlogoupdater.rc
killall -9 bootlogoupdater.rc

sleep 5

#kill useless logging service
am kill mdnsd
killall -9 mdnsd
am kill mdnsd.rc
killall -9 mdnsd.rc

am kill mobile_log_d
killall -9 mobile_log_d
am kill mobile_log_d.rc
killall -9 mobile_log_d.rc

am kill dumpstate
killall -9 dumpstate
am kill dumpstate.rc
killall -9 dumpstate.rc

am kill emdlogger1
killall -9 emdlogger1
am kill emdlogger1.rc
killall -9 emdlogger1.rc

am kill emdlogger3
killall -9 emdlogger3
am kill emdlogger3.rc
killall -9 emdlogger3.rc

am kill mdlogger
killall -9 mdlogger
am kill mdlogger.rc
killall -9 mdlogger.rc

am kill aee.log-1-0
killall -9 aee.log-1-0
am kill aee.log-1-0.rc
killall -9 aee.log-1-0.rc

am kill connsyslogger
killall -9 connsyslogger
am kill connsyslogger.rc
killall -9 connsyslogger.rc

am kill bootlogoupdater
killall -9 bootlogoupdater
am kill bootlogoupdater.rc
killall -9 bootlogoupdater.rc