# $1:value $2:filepaths
lock_val() {
    for p in $2; do
        if [ -f "$p" ]; then
            chown root:root "$p"
            chmod 0666 "$p"
            echo "$1" >"$p"
            chmod 0444 "$p"
        fi
    done
}

# $1:value $2:filepaths
mask_val() {
    touch /data/local/tmp/mount_mask
    for p in $2; do
        if [ -f "$p" ]; then
            umount "$p"
            chmod 0666 "$p"
            echo "$1" >"$p"
            mount --bind /data/local/tmp/mount_mask "$p"
        fi
    done
}

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


# Logs
su -c "cmd settings put global activity_starts_logging_enabled 0"
su -c "cmd settings put global ble_scan_always_enabled 0"
su -c "cmd settings put global enable_gpu_debug_layers 0"
su -c "cmd settings put global ecg_disable_logging 1"
su -c "cmd settings put global netstats_enabled 0" # won't affect mobile data usage record
su -c "cmd settings put secure send_action_app_error 0"
su -c "cmd settings put system call_log 0" #won't affect miui caller
su -c "cmd settings put system send_security_reports 0"
su -c "cmd settings put system anr_debugging_mechanism 0"
su -c "cmd device_config put runtime_native_boot disable_lock_profiling true"

# Ads Control
su -c "cmd settings put global passport_ad_status OFF"
su -c "cmd settings put global personalized_ad_enabled 0"

# System behaviour tuning
su -c "cmd settings put global fast_connect_ble_scan_mode 0"
su -c "cmd settings put global hotword_detection_enabled 0" #OK Google
su -c "cmd settings put global mobile_data_always_on 0"
su -c "cmd settings put global network_recommendations_enabled 0"
su -c "cmd settings put global TV_SENSOR_JAR_ENABLE 0"
su -c "cmd settings put global pmiui_ambient_scan_support 0"
su -c "cmd settings put global wifi_scan_always_enabled 0"
su -c "cmd settings put secure adaptive_sleep 0"
su -c "cmd settings put secure screensaver_activate_on_dock 0"
su -c "cmd settings put secure screensaver_activate_on_sleep 0" 
su -c "cmd settings put secure screensaver_enabled 0"
su -c "cmd settings put system air_motion_engine 0"
su -c "cmd settings put system air_motion_wake_up 0"
su -c "cmd settings put system master_motion 0"
su -c "cmd settings put system motion_engine 0"
su -c "cmd settings put system nearby_scanning_enabled 0"
su -c "cmd settings put system nearby_scanning_permission_allowed 0"
su -c "cmd settings put secure doze_always_on 0" # AOD
su -c "cmd settings put system low_battery_dialog_disabled 1" #Low Battery Dialog

# Memory/Process Management
su -c "cmd settings put global settings_enable_monitor_phantom_procs false"
su -c "cmd device_config set_sync_disabled_for_tests until_reboot"
su -c "cmd device_config put runtime_native_boot iorap_readahead_enable false"
su -c "cmd device_config put activity_manager max_phantom_processes 65535"
su -c "cmd device_config put activity_manager max_cached_processes 65535"
su -c "cmd device_config put activity_manager max_empty_time_millis 43200000"
su -c "cmd device_config put activity_manager use_compaction false"
su -c "cmd settings put system miui_app_cache_optimization 0"

# Disable not so useful apps to run in backgroud
su -c "cmd appops set com.android.backupconfirm RUN_IN_BACKGROUND ignore"
su -c "cmd appops set com.google.android.setupwizard RUN_IN_BACKGROUND ignore"
su -c "cmd appops set com.android.printservice.recommendation RUN_IN_BACKGROUND ignore"
su -c "cmd appops set com.android.onetimeinitializer RUN_IN_BACKGROUND ignore"
su -c "cmd appops set com.qualcomm.qti.perfdump RUN_IN_BACKGROUND ignore"

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
/sys/kernel/debug/dri/0/debug/enable
/sys/kernel/debug/sde_rotator0/evtlog/enable
/sys/kernel/debug/tracing/tracing_on
/sys/module/alarm_dev/parameters/debug_mask
/sys/module/binder/parameters/debug_mask
/sys/module/binder_alloc/parameters/debug_mask
/sys/module/kernel/parameters/initcall_debug
/sys/module/kernel/parameters/panic
/sys/module/kernel/parameters/panic_on_warn
/sys/module/kernel/parameters/panic_on_oops
/sys/module/lowmemorykiller/parameters/debug_level
/sys/module/millet_core/parameters/millet_debug
/sys/module/mmc_core/parameters/crc
/sys/module/mmc_core/parameters/removable
/sys/module/mmc_core/parameters/use_spi_crc
/sys/module/msm_show_resume_irq/parameters/debug_mask
/sys/module/powersuspend/parameters/debug_mask
/sys/module/printk/parameters/cpu
/sys/module/printk/parameters/pid
/sys/module/printk/parameters/printk_ratelimit
/sys/module/printk/parameters/time
/sys/module/subsystem_restart/parameters/enable_mini_ramdumps
/sys/module/subsystem_restart/parameters/enable_ramdumps
/sys/module/rmnet_data/parameters/rmnet_data_log_level
/sys/module/xt_qtaguid/parameters/debug_mask
/sys/vm/panic_on_oom"

for debug in $debug_list; do
  if [ -f "$debug" ]; then
    echo "0" > "$debug" 2>/dev/null
  fi
done


echo "N" > /sys/kernel/debug/debug_enabled
echo "N" > /sys/kernel/debug/seclog/seclog_debug
echo "0" > /sys/kernel/debug/tracing/tracing_on


# Change permissions of /proc/kmsg to make it read-only
if [ -f /proc/kmsg ]; then
    chmod 0400 /proc/kmsg
fi



wakelocks1="
/sys/module/wakeup/parameters/enable_ipa_ws
/sys/module/wakeup/parameters/enable_qcom_rx_wakelock_ws
/sys/module/wakeup/parameters/enable_wlan_extscan_wl_ws
/sys/module/wakeup/parameters/enable_wlan_wow_wl_ws
/sys/module/wakeup/parameters/enable_wlan_ws
/sys/module/wakeup/parameters/enable_netmgr_wl_ws
/sys/module/wakeup/parameters/enable_wlan_wow_wl_ws
/sys/module/wakeup/parameters/enable_wlan_ipa_ws
/sys/module/wakeup/parameters/enable_wlan_pno_wl_ws
/sys/module/wakeup/parameters/enable_wcnss_filter_lock_ws
"
for wakelock1 in $wakelocks1; do
  if [ -f "$wakelock1" ]; then
    echo "N" > "$wakelock1" 2>/dev/null
  fi
done


wakelocks2="
/sys/module/wakeup/parameters/enable_bluetooth_timer
/sys/module/wakeup/parameters/enable_netlink_ws
/sys/module/wakeup/parameters/enable_netmgr_wl_ws
/sys/module/wakeup/parameters/enable_timerfd_ws
"

for wakelock2 in $wakelocks2; do
  if [ -f "$wakelock2" ]; then
    echo "Y" > "$wakelock2" 2>/dev/null
  fi
done

if [ -f /sys/devices/virtual/misc/boeffla_wakelock_blocker/wakelock_blocker ]; then
  echo "wlan_pno_wl;wlan_ipa;wcnss_filter_lock;hal_bluetooth_lock;IPA_WS;sensor_ind;wlan;netmgr_wl;qcom_rx_wakelock;wlan_wow_wl;wlan_extscan_wl;NETLINK;bam_dmux_wakelock;IPA_RM12" > /sys/devices/virtual/misc/boeffla_wakelock_blocker/wakelock_blocker 
elif [ -f /sys/class/misc/boeffla_wakelock_blocker/wakelock_blocker ]; then
  echo "wlan_pno_wl;wlan_ipa;wcnss_filter_lock;hal_bluetooth_lock;IPA_WS;sensor_ind;wlan;netmgr_wl;qcom_rx_wakelock;wlan_wow_wl;wlan_extscan_wl;NETLINK;bam_dmux_wakelock;IPA_RM12" > /sys/class/misc/boeffla_wakelock_blocker/wakelock_blocker
fi

# disable THP(reduce memory fragmentation)
echo never > /sys/kernel/mm/transparent_hugepage/enabled
echo never > /sys/kernel/mm/transparent_hugepage/defrag

####################################
# UFS Tuning
####################################
# Disable All I/O stats
echo 0 > /sys/block/*/queue/iostats

# Disable All I/O Debug Helper
echo 0 > /sys/block/*/queue/nomerges

#Tune
echo 0 > /sys/block/*/queue/add_random
echo 64 > /sys/block/*/queue/rq_affinity
echo 128 > /sys/block/*/queue/read_ahead_kb



stop perf-hal-2-3
stop vendor.perfservice

# Kernel Tuning
echo 1 > /proc/sys/kernel/sched_energy_aware
echo 1 > /proc/sys/kernel/sched_child_runs_first
echo 0 > /proc/sys/kernel/sched_iowait_expires

# disable WALT CPU Boost
mask_val "0" /proc/sys/walt/sched_boost
mask_val "0" /proc/sys/walt/input_boost/*

# WALT Adjustment
mask_val "5 70" "/proc/sys/walt/sched_downmigrate"
mask_val "15 90" "/proc/sys/walt/sched_upmigrate"

# CPUset Adjustment
sleep 2
lock_val "0-2" /dev/cpuset/background/cpus
lock_val "0-2" /dev/cpuset/system-background/cpus
lock_val "0-6" /dev/cpuset/foreground/cpus
lock_val "0-7" /dev/cpuset/top-app/cpus


# KGSL Tuning (GPU)
sleep 2
lock_val "0" /sys/class/kgsl/kgsl-3d0/force_bus_on
lock_val "0" /sys/class/kgsl/kgsl-3d0/force_clk_on
lock_val "0" /sys/class/kgsl/kgsl-3d0/force_no_nap
lock_val "0" /sys/class/kgsl/kgsl-3d0/force_rail_on
lock_val "10" /sys/class/kgsl/kgsl-3d0/idle_timer
lock_val "0" /sys/class/devfreq/*kgsl-3d0/min_freq
lock_val "2147483647" /sys/class/devfreq/*kgsl-3d0/max_freq
lock_val "0" /sys/class/kgsl/kgsl-3d0/force_no_nap
lock_val "1" /sys/class/kgsl/kgsl-3d0/bus_split
lock_val "92" /sys/class/kgsl/kgsl-3d0/devfreq/mod_percent

start vendor.perfservice
start perf-hal-2-3

# Laptop-Mode
echo 150 > /proc/sys/vm/dirty_writeback_centisecs
echo 1 > /proc/sys/vm/laptop_mode

# MGLRU
lock_val "Y" /sys/kernel/mm/lru_gen/enabled
lock_val "1000" /sys/kernel/mm/lru_gen/min_ttl_ms


# Ensure deeper C-states are allowed to save power
echo 1 > /sys/module/cpuidle/parameters/enable

if [ -f "/sys/module/workqueue/parameters/power_efficient" ]; then
  echo "Y" > /sys/module/workqueue/parameters/power_efficient
fi

mount -t debugfs none /sys/kernel/debug
echo "5000000" >/sys/kernel/debug/sched/migration_cost_ns
echo "12500000" >/sys/kernel/debug/sched/wakeup_granularity_ns

# Xiaomi Config
mask_val "0" /sys/module/migt/parameters/enable_pkg_monitor
mask_val "0" /proc/sys/migt/enable_pkg_monitor
mask_val "0" /sys/module/migt/parameters/glk_freq_limit_walt
mask_val "0" /sys/module/metis/parameters/cluaff_control

# echo 1000 > /proc/sys/kernel/sched_deadline_period_min_us
# echo 50 >  /proc/sys/kernel/sched_rr_timeslice_ms
# echo 3150000 > /proc/sys/kernel/sched_rt_period_us
# echo 3000000 > /proc/sys/kernel/sched_rt_runtime_us
# echo 512 > /proc/sys/kernel/sched_util_clamp_min
# echo "5000000" >/sys/kernel/debug/sched/migration_cost_ns
# echo "12500000" >/sys/kernel/debug/sched/wakeup_granularity_ns
# lock_val "0" /sys/kernel/rcu_expedited
# mask_val "2" /proc/sys/kernel/sched_pelt_multiplier

# Linux Scheduler
echo "NEXT_BUDDY" > /sys/kernel/debug/sched_features
echo "TTWU_QUEUE" > /sys/kernel/debug/sched_features
echo "NO_WAKEUP_PREEMPTION" > /sys/kernel/debug/sched_features
echo "NO_GENTLE_FAIR_SLEEPERS" > /sys/kernel/debug/sched_features
echo "ARCH_POWER" > /sys/kernel/debug/sched_features

# Google play services wakelocks
su -c "pm disable com.google.android.gms/.ads.AdRequestBrokerService"
su -c "pm disable com.google.android.gms/.ads.identifier.service.AdvertisingIdService"
su -c "pm disable com.google.android.gms/.ads.social.GcmSchedulerWakeupService"
su -c "pm disable com.google.android.gms/.analytics.AnalyticsService"
su -c "pm disable com.google.android.gms/.analytics.service.PlayLogMonitorIntervalService"
su -c "pm disable com.google.android.gms/.backup.BackupTransportService"
su -c "pm disable com.google.android.gms/.update.SystemUpdateActivity"
su -c "pm disable com.google.android.gms/.update.SystemUpdateService"
su -c "pm disable com.google.android.gms/.update.SystemUpdateActivity"
su -c "pm disable com.google.android.gms/.update.SystemUpdateService"
su -c "pm disable com.google.android.gms/.update.SystemUpdateService$ActiveReceiver"
su -c "pm disable com.google.android.gms/.update.SystemUpdateService$Receiver"
su -c "pm disable com.google.android.gms/.update.SystemUpdateService$SecretCodeReceiver"
su -c "pm disable com.google.android.gms/.thunderbird.settings.ThunderbirdSettingInjectorService"
su -c "pm disable com.google.android.gsf/.update.SystemUpdateActivity"
su -c "pm disable com.google.android.gsf/.update.SystemUpdatePanoActivity"
su -c "pm disable com.google.android.gsf/.update.SystemUpdateService"
su -c "pm disable com.google.android.gsf/.update.SystemUpdateService$Receiver"
su -c "pm disable com.google.android.gsf/.update.SystemUpdateService$SecretCodeReceiver"

####################################
# Kill and Stop Services
####################################

sleep 2

process="
aee.log-1-0
aee.log-1-0.rc
aee.log-1-1
aplogd
athdiag
atrace.rc
boot_logo_updater
bootlogoupdater.rc
bootlog.sh
bootstat
bootstat.rc
bugreport
bugreport_procdump
bugreportz
bt_dump
bt_logger
charge_logger
cnss_diag
connsyslogger
connsyslogger.rc
debug-diag
debuggerd
diag_dci_sample
diag_dci_sample_system
diag_klog
diag_mdlog
diag_mdlog_system
diag_socket_log
diag_uart_log
diag-router
dmesgd
dmesgd.rc
dmpd
dpmd.rc
dumpstate
dumpstate.rc
dumpstate
dumpsys
emdlogger
emdlogger1
emdlogger1.rc
emdlogger2
emdlogger2.rc
emdlogger3
emdlogger3.rc
emdlogger5
emdlogger5.rc
fsync
i2cdump
idd-logreader
idd-logreadermain
init.charge_logger.rc
init.nativedebug.rc
init.offline.log.rc
init.qseelogd.rc
init.qti.bt.logger.rc
iorap.cmd.compiler
iostat
ipacm-diag
ipacm-diag.rc
log
logcat
logcatkernel.sh
logcatlog.sh
logcatd
logd
logd.rc
logger
logname
logwrapper
lpdump
lpdumpd
lpdumpd.rc
mdlogger
mdlogger.rc
mdnsd
mdnsd.rc
mobile_log_d
mobile_log_d.rc
mtdoopslog.sh
minidump64
miuiupdater.rc
netdiag
netdiag.rc
pktlogconf
poweroff_charger_log.sh
qesdk-manager
qesdk-manager.rc
ramdump
ssr_diag
ssr_setup
stats
statsd
subsystem_ramdump
tcpdump
test_diag
test_diag_system
tombstoned
traced
vendor.tcpdump
vendor_tcpdump
vendor.cnss_diag
vendor.ipacm-diag
vendor.qti.diag_userdebug.rc
wifi_dump
com.miui.daemon"

for name in $process; do
  stop "$name"
  am kill "$name"
  killall -9 "$name"
done

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