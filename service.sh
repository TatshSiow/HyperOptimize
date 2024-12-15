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
sleep 30

####################################
# Tweaking Android (Github:ionuttbara + Tatsh)
####################################
su -c "cmd settings put global activity_starts_logging_enabled 0"
su -c "cmd settings put global ble_scan_always_enabled 0"
su -c "cmd settings put global cached_apps_freezer enabled"
su -c "cmd settings put global enable_gpu_debug_layers 0"
su -c "cmd settings put global ecg_disable_logging 1"
su -c "cmd settings put global fast_connect_ble_scan_mode 0"
su -c "cmd settings put global hotword_detection_enabled 0" #OK Google
su -c "cmd settings put global mobile_data_always_on 0"
su -c "cmd settings put global netstats_enabled 0" #disable this if you want to track data network stats
su -c "cmd settings put global network_recommendations_enabled 0"
su -c "cmd settings put global passport_ad_status OFF"
su -c "cmd settings put global personalized_ad_enabled 0"
su -c "cmd settings put global pmiui_ambient_scan_support 0"
su -c "cmd settings put global TV_SENSOR_JAR_ENABLE 0"
su -c "cmd settings put global wifi_scan_always_enabled 0"
su -c "cmd settings put secure adaptive_sleep 0"
su -c "cmd settings put secure screensaver_activate_on_dock 0"
su -c "cmd settings put secure screensaver_activate_on_sleep 0" 
su -c "cmd settings put secure screensaver_enabled 0"
su -c "cmd settings put secure send_action_app_error 0"
su -c "cmd settings put system air_motion_engine 0"
su -c "cmd settings put system air_motion_wake_up 0"
su -c "cmd settings put system call_log 0" #won't affect miui caller
su -c "cmd settings put system intelligent_sleep_mode 0"
su -c "cmd settings put system master_motion 0"
su -c "cmd settings put system motion_engine 0"
su -c "cmd settings put system nearby_scanning_enabled 0"
su -c "cmd settings put system nearby_scanning_permission_allowed 0"
su -c "cmd settings put system send_security_reports 0"

#Another Another Another Testing
su -c "cmd settings put global settings_enable_monitor_phantom_procs false"
su -c "cmd device_config put runtime_native_boot disable_lock_profiling true"
su -c "cmd settings put global settings_enable_monitor_phantom_procs false"
su -c "cmd device_config put runtime_native_boot disable_lock_profiling true"
su -c "cmd device_config set_sync_disabled_for_tests persistent"
su -c "cmd device_config put runtime_native_boot iorap_readahead_enable true"
su -c "cmd settings put global fstrim_mandatory_interval 3600"
su -c "cmd device_config put activity_manager max_phantom_processes 2147483647"
su -c "cmd device_config put activity_manager max_cached_processes 256"
su -c "cmd device_config put activity_manager max_empty_time_millis 43200000"
su -c "cmd settings put system anr_debugging_mechanism 0"
su -c "cmd settings put secure doze_always_on 0" #turn off AOD

su -c "cmd appops set com.android.backupconfirm RUN_IN_BACKGROUND ignore",
su -c "cmd appops set com.google.android.setupwizard RUN_IN_BACKGROUND ignore",
su -c "cmd appops set com.android.printservice.recommendation RUN_IN_BACKGROUND ignore",
su -c "cmd appops set com.android.onetimeinitializer RUN_IN_BACKGROUND ignore",
su -c "cmd appops set com.qualcomm.qti.perfdump RUN_IN_BACKGROUND ignore",

####################################
# Useless Services 
####################################
su -c "pm disable com.google.android.gms/.chimera.GmsIntentOperationService"
su -c "pm disable com.google.android.gms/com.google.android.gms.mdm.receivers.MdmDeviceAdminReceiver"

####################################
# Disable Dual Apps Google Services
####################################
su -c "pm disable-user --user 999 com.google.android.gms"
su -c "pm disable-user --user 999 com.google.android.gsf"


####################################
# Kernel Debugging (thx to KTSR)
####################################
for i in "debug_mask" "log_level*" "debug_level*" "*debug_mode" "enable_ramdumps" "enable_mini_ramdumps" "edac_mc_log*" "enable_event_log" "*log_level*" "*log_ue*" "*log_ce*" "log_ecn_error" "snapshot_crashdumper" "seclog*" "compat-log" "*log_enabled" "tracing_on" "mballoc_debug"; do
    for o in $(find /sys/ -type f -name "$i"); do
        echo "0" > "$o"
    done
done
echo "1" > "/sys/module/spurious/parameters/noirqdebug"

####################################
# Printk (thx to KNTD-reborn)
####################################
echo "0 0 0 0" > "/proc/sys/kernel/printk"
echo "1" > "/sys/module/printk/parameters/console_suspend"
echo "1" > "/sys/module/printk/parameters/ignore_loglevel"
echo "off" > "/proc/sys/kernel/printk_devkmsg"

############################################################
# Ramdumps | File System | Kernel Panic | Driver Debugging #
#  Printk  |     CRC     | Kernel Debugging                #
############################################################
debug_list="
/proc/sys/debug/exception-trace
/proc/sys/fs/by-name/userdata/iostat_enable
/proc/sys/fs/dir-notify-enable
/proc/sys/kernel/core_pattern
/proc/sys/kernel/panic
/proc/sys/kernel/panic_on_oops
/proc/sys/kernel/panic_on_rcu_stall
/proc/sys/kernel/panic_on_warn
/proc/sys/kernel/sched_schedstats
/proc/sys/migt/migt_sched_debug
/sys/fs/f2fs/sda32/iostat_enable
/sys/kernel/debug/sde_rotator0/evtlog/enable
/sys/kernel/debug/dri/0/debug/enable
/sys/kernel/printk_mode/printk_mode
/sys/module/binder/parameters/debug_mask
/sys/module/binder_alloc/parameters/debug_mask
/sys/module/kernel/parameters/panic
/sys/module/kernel/parameters/panic_on_warn
/sys/module/kernel/parameters/panic_on_oops
/sys/module/millet_core/parameters/millet_debug
/sys/module/mmc_core/parameters/crc
/sys/module/mmc_core/parameters/removable
/sys/module/mmc_core/parameters/use_spi_crc
/sys/module/msm_show_resume_irq/parameters/debug_mask
/sys/module/printk/parameters/cpu
/sys/module/printk/parameters/pid
/sys/module/printk/parameters/printk_ratelimit
/sys/module/printk/parameters/time
/sys/module/subsystem_restart/parameters/enable_mini_ramdumps
/sys/module/subsystem_restart/parameters/enable_ramdumps
/sys/module/rmnet_data/parameters/rmnet_data_log_level
/sys/vm/panic_on_oom"

for debug in $debug_list; do
  if [ -f "$debug" ]; then
    echo "0" > "$debug"
  fi
done


if [ -f /sys/kernel/debug/debug_enabled ]; then
  echo "N" > /sys/kernel/debug/debug_enabled
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


if [ -f /proc/sys/fs/lease-break-time ]; then
  echo "30" > /proc/sys/fs/lease-break-time
fi

if [ -f /proc/sys/kernel/sem ]; then
  echo "200,16000,16,64" > /proc/sys/kernel/sem
fi

# disable transparent_hugepage(reduce memory fragmentation)
echo never > /sys/kernel/mm/transparent_hugepage/enabled

####################################
# UFS Tuning
####################################
# Disable All I/O stats
echo 0 > /sys/block/*/queue/iostats

# Disable All I/O Debug Helper
echo 0 > /sys/block/*/queue/nomerges


echo 1 > /proc/sys/kernel/sched_energy_aware

echo 1 > /proc/sys/kernel/sched_child_runs_first
echo 1 > /proc/sys/kernel/sched_autogroup_enabled
echo 1000 > /proc/sys/kernel/sched_deadline_period_min_us
echo 50 > /sched_rr_timeslice_ms
echo 3150000 > /proc/sys/kernel/sched_rt_period_us
echo 3000000 > /proc/sys/kernel/sched_rt_runtime_us
echo 512 > /proc/sys/kernel/sched_util_clamp_min

####################################
# Kill and Stop Services
####################################

sleep 5

process="
aee.log-1-0
aee.log-1-0.rc
aee.log-1-1
aplogd
bootlogoupdater
bootlogoupdater.rc
bt_dump
cnss_diag
charge_logger
connsyslogger
connsyslogger.rc
dumpstate
dumpstate.rc
emdlogger
emdlogger1
emdlogger1.rc
emdlogger3
emdlogger3.rc
idd-logreader
idd-logreadermain
ipacm-diag
ipacm-diag.rc
logcat
logcatd
logd
logd.rc
mdlogger
mdlogger.rc
mdnsd
mdnsd.rc
mobile_log_d
mobile_log_d.rc
ramdump
stats
statsd
subsystem_ramdump
tcpdump
traced
vendor.tcpdump
vendor_tcpdump
vendor.cnss_diag
vendor.ipacm-diag
wifi_dump
com.miui.daemon"

for name in $process; do
  am kill "$name" 2> /dev/null
  killall -9 "$name" 2> /dev/null
done

#cpu的应用分配
#用户的后台应用（减少使用核心省电，影响后台下载，不过流畅）
echo "0-1" > /dev/cpuset/background/cpus
#系统的后台应用（减少使用核心省电）
echo "0-1" > /dev/cpuset/system-background/cpus
#前台的应用（不限制使用核心）
echo "0-6" > /dev/cpuset/foreground/cpus
#显示在上层的应用（不限制使用核心）
echo "0-7" > /dev/cpuset/top-app/cpus

#调节cpu激进度百分比%
#前台的应用（100%会把cpu拉满）
echo "5" > /dev/stune/foreground/schedtune.boost
#显示在上层的应用
echo "0" > /dev/stune/top-app/schedtune.boost
#用户的后台应用（减少cpu乱跳，省电）
echo "0" > /dev/stune/background/schedtune.boost

#核心分配优化
#大核 提高这个值有利于性能，不利于降低功耗。
echo "50 50" > /proc/sys/kernel/sched_downmigrate
#小核 提高这个值有利于降低功耗，不利于性能。
echo "75 75" > /proc/sys/kernel/sched_upmigrate


#cpu boost这项技术可以理解为自动超频，可以在主频不够用的情况,自动对CPU进行超频。
#除了0代表关闭boost以外，其他3个等级灵活地控制功耗和性能的不同倾向程度。
#0代表默认关闭，1代表QCOM建议为app第一次冷启，设置flag2秒
#2代表QCOM建议在滑屏、按键、系统唤醒等场景使用
#3代表QCOM建议为启动超过2秒的app设置2-15秒，如游戏，开机
#等级越高，耗电越高
echo "1" > /proc/sys/kernel/sched_boost

####################################
# Logs Removal
####################################
# Wifi Logs
rm -rf /data/vendor/wlan_logs
touch /data/vendor/wlan_logs
chmod 000 /data/vendor/wlan_logs

# Magisk Logs
rm -rf /cache/magisk.log
touch   /cache/magisk.log
chmod 000  /cache/magisk.log

#MIUI Home Debug Log
rm -rf /data/user_de/0/com.miui.home/cache/debug_log
touch   /data/user_de/0/com.miui.home/cache/debug_log
chmod 000  /data/user_de/0/com.miui.home/cache/debug_log