#!/system/bin/sh
# Please don't hardcode /magisk/modname/... ; instead, please use $MODDIR/...
# This will make your scripts compatible even if Magisk change its mount point in the future
# This script will be executed in late_start service mode
# More info in the main Magisk thread

#Enable MGLRU (Improve App Launch Time, much power efficient)
#After testing, it uses more power to maintain background process
#if [ -f /sys/kernel/mm/lru_gen/enabled ]; then
#  echo "0x0003" > /sys/kernel/mm/lru_gen/enabled
#  chmod 444 /sys/kernel/mm/lru_gen/enabled
#fi
#
#if [ -f /sys/kernel/mm/lru_gen/min_ttl_ms ]; then
#  echo "1000" > /sys/kernel/mm/lru_gen/min_ttl_ms
#  chmod 444 /sys/kernel/mm/lru_gen/min_ttl_ms
#fi
#
# Disable debug process
if [ -f /sys/module/binder/parameters/debug_mask ]; then
  echo "0" > /sys/module/binder/parameters/debug_mask
fi

if [ -f /sys/module/binder_alloc/parameters/debug_mask ]; then
  echo "0" > /sys/module/binder_alloc/parameters/debug_mask
fi

if [ -f /sys/module/msm_show_resume_irq/parameters/debug_mask ]; then
  echo "0" > /sys/module/msm_show_resume_irq/parameters/debug_mask
fi

if [ -f /sys/module/millet_core/parameters/millet_debug ]; then
  echo "0" > /sys/module/millet_core/parameters/millet_debug
fi

if [ -f /proc/sys/migt/migt_sched_debug ]; then
  echo "0" > /proc/sys/migt/migt_sched_debug
fi

if [ -f /sys/kernel/debug/debug_enabled ]; then
  echo "N" > /sys/kernel/debug/debug_enabled
fi

if [ -f /proc/sys/kernel/printk_devkmsg ]; then
  echo "off" > /proc/sys/kernel/printk_devkmsg
fi

if [ -f /proc/sys/kernel/sched_schedstats ]; then
  echo "0" > /proc/sys/kernel/sched_schedstats
fi

if [ -f /sys/fs/f2fs/sda32/iostat_enable ]; then
  echo "0" > /sys/fs/f2fs/sda32/iostat_enable
fi

if [ -f /sys/module/millet_core/parameters/millet_debug ]; then
  echo "0" > /sys/module/millet_core/parameters/millet_debug
fi

#Disable RAMDUMP
if [ -f sys/module/subsystem_restart/parameters/enable_ramdumps ]; then
  echo "0" > sys/module/subsystem_restart/parameters/enable_ramdumps
fi

if [ -f /sys/module/subsystem_restart/parameters/enable_mini_ramdumps ]; then
  echo "0" > /sys/module/subsystem_restart/parameters/enable_mini_ramdumps
fi

#Kernel Tuning
if [ -f /proc/sys/vm/page-cluster ]; then
  echo "3" > /proc/sys/vm/page-cluster
fi
if [ -f /proc/sys/kernel/msgmni ]; then
  echo "256" > /proc/sys/kernel/msgmni
fi
if [ -f /proc/sys/kernel/msgmax ]; then
  echo "32768" > /proc/sys/kernel/msgmax
fi
if [ -f /proc/sys/vm/page-cluster ]; then
  echo "3" > /proc/sys/vm/page-cluster
fi
if [ -f /proc/sys/fs/lease-break-time ]; then
  echo "30" > /proc/sys/fs/lease-break-time
fi
if [ -f /proc/sys/kernel/sem ]; then
  echo "200,16000,16,64" > /proc/sys/kernel/sem
fi

# disable transparent_hugepage(reduce memory fragmentation)
if [ -f /sys/kernel/mm/transparent_hugepage/enabled ]; then
  echo never > /sys/kernel/mm/transparent_hugepage/enabled
fi

#UFS Tuning
#Disable All I/O stats
echo 0 > /sys/block/*/queue/iostats

#Disable All I/O Debug Helper
echo 0 > /sys/block/*/queue/nomerges

###The script Above is moved from post-fs-data.sh

sleep 5

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