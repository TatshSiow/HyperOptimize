#!/system/bin/sh
# Please don't hardcode /magisk/modname/... ; instead, please use $MODDIR/...
# This will make your scripts compatible even if Magisk change its mount point in the future
# This script will be executed in late_start service mode
# More info in the main Magisk thread

wait_until_login() {
  while [[ "$(getprop sys.boot_completed)" != "1" ]]; do
    sleep 3
  done

  test_file="/storage/emulated/0/Android/.PERMISSION_TEST"
  true >"$test_file"
  while [[ ! -f "$test_file" ]]; do
    true >"$test_file"
    sleep 1
  done
  rm -f "$test_file"
}

wait_until_login
sleep 60

####################################
# Tweaking Android (thx to Melody Script https://github.com/ionuttbara/melody_android)
####################################
su -c "cmd settings put global activity_starts_logging_enabled 0"
su -c "cmd settings put global ble_scan_always_enabled 0"
su -c "cmd settings put global hotword_detection_enabled 0"
su -c "cmd settings put global mobile_data_always_on 0"
su -c "cmd settings put global network_recommendations_enabled 0"
su -c "cmd settings put global wifi_scan_always_enabled 0"
su -c "cmd settings put secure adaptive_sleep 0"
su -c "cmd settings put secure screensaver_activate_on_dock 0"
su -c "cmd settings put secure screensaver_activate_on_sleep 0" 
su -c "cmd settings put secure screensaver_enabled 0"
su -c "cmd settings put secure send_action_app_error 0"
su -c "cmd settings put system air_motion_engine 0"
su -c "cmd settings put system air_motion_wake_up 0"
su -c "cmd settings put system intelligent_sleep_mode 0"
su -c "cmd settings put system master_motion 0"
su -c "cmd settings put system motion_engine 0"
su -c "cmd settings put system nearby_scanning_enabled 0"
su -c "cmd settings put system nearby_scanning_permission_allowed 0"
#this is start of custom line
su -c "cmd settings put system send_security_reports 0"
su -c "cmd settings put global debug.gralloc.enable_fb_ubwc 1"
su -c "cmd settings put global debug.sf.hw 1"
su -c "cmd settings put global enable_gpu_debug_layers 0"
su -c "cmd settings put global ecg_disable_logging 1"
su -c "cmd settings put system call_log 0"
su -c "cmd settings put global debug.sf.enable_gl_backpressure 1"
su -c "cmd settings put global personalized_ad_enabled 0"
su -c "cmd settings put global passport_ad_status OFF"
su -c "cmd settings put global pmiui_ambient_scan_support 1"
su -c "cmd settings put global netstats_enabled 0" #disable this if you want to track network stats
su -c "cmd settings put global fast_connect_ble_scan_mode 0"
su -c "cmd settings put global TV_SENSOR_JAR_ENABLE 0"
su -c "cmd settings put global cached_apps_freezer enabled" #Cache AppFreeze
su -c "cmd settings put system intelligent_sleep_mode 1"
####################################
# Services
####################################
su -c "stop logcat logcatd logd tcpdump cnss_diag statsd traced idd-logreader idd-logreadermain stats dumpstate aplogd tcpdump vendor.tcpdump vendor_tcpdump vendor.cnss_diag"

####################################
# Wi-Fi Logs (thx to @LeanHijosdesusMadres)
####################################
rm -rf /data/vendor/wlan_logs
touch /data/vendor/wlan_logs
chmod 000 /data/vendor/wlan_logs

####################################
# Useless Services 
####################################
su -c "pm disable com.google.android.gms/.chimera.GmsIntentOperationService"
su -c "pm disable com.google.android.gms/com.google.android.gms.mdm.receivers.MdmDeviceAdminReceiver"

####################################
# Kernel Debugging (thx to KTSR)
####################################
for i in "debug_mask" "log_level*" "debug_level*" "*debug_mode" "enable_ramdumps" "enable_mini_ramdumps" "edac_mc_log*" "enable_event_log" "*log_level*" "*log_ue*" "*log_ce*" "log_ecn_error" "snapshot_crashdumper" "seclog*" "compat-log" "*log_enabled" "tracing_on" "mballoc_debug"; do
    for o in $(find /sys/ -type f -name "$i"); do
        echo "0" > "$o"
    done
done

for sys in /sys; do
    echo "1" > "$sys/module/spurious/parameters/noirqdebug"
    echo "0" > "$sys/kernel/debug/sde_rotator0/evtlog/enable"
  echo "0" > "$sys/kernel/debug/dri/0/debug/enable"
  echo "0" > "$sys/module/rmnet_data/parameters/rmnet_data_log_level"
done

echo "0" > "/proc/sys/debug/exception-trace"
echo "0" > "/proc/sys/kernel/sched_schedstats"
  
####################################
# CRC
####################################
for parameters in /sys/module/mmc_core/parameters/*; do
    echo "0" > "$parameters/crc"
    echo "0" > "$parameters/removable"
    echo "0" > "$parameters/use_spi_crc"
done

####################################
# Printk (thx to KNTD-reborn)
####################################
echo "0 0 0 0" > "/proc/sys/kernel/printk"
echo "0" > "/sys/kernel/printk_mode/printk_mode"
echo "0" > "/sys/module/printk/parameters/cpu"
echo "0" > "/sys/module/printk/parameters/pid"
echo "0" > "/sys/module/printk/parameters/printk_ratelimit"
echo "0" > "/sys/module/printk/parameters/time"
echo "1" > "/sys/module/printk/parameters/console_suspend"
echo "1" > "/sys/module/printk/parameters/ignore_loglevel"
echo "off" > "/proc/sys/kernel/printk_devkmsg"

####################################
# Ramdumps
####################################
for parameters in /sys/module/subsystem_restart/parameters; do
    echo "0" > "$parameters/enable_mini_ramdumps"
    echo "0" > "$parameters/enable_ramdumps"
done

####################################
# File System
####################################
for fs in /proc/sys/fs; do
    echo "0" > "$fs/by-name/userdata/iostat_enable"
    echo "0" > "$fs/dir-notify-enable"
done

####################################
# Disable Kernel Panic
####################################
echo "0" > /proc/sys/kernel/panic
echo "0" > /proc/sys/kernel/panic_on_oops
echo "0" > /proc/sys/kernel/panic_on_rcu_stall
echo "0" > /proc/sys/kernel/panic_on_warn
echo "0" > /sys/module/kernel/parameters/panic
echo "0" > /sys/module/kernel/parameters/panic_on_warn
echo "0" > /sys/module/kernel/parameters/panic_on_oops
echo "0" > /sys/vm/panic_on_oom

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

if [ -f /sys/fs/f2fs/sda32/iostat_enable ]; then
  echo "0" > /sys/fs/f2fs/sda32/iostat_enable
fi

if [ -f /sys/module/millet_core/parameters/millet_debug ]; then
  echo "0" > /sys/module/millet_core/parameters/millet_debug
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

am kill bootlogoupdater
killall -9 bootlogoupdater
am kill bootlogoupdater.rc
killall -9 bootlogoupdater.rc

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