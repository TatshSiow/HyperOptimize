####################################
# Functions
####################################

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
sleep 15


####################################
# Kernel Debugging (thx to KTSR)
####################################
for i in "debug_mask" "log_level*" "debug_level*" "*debug_mode" "enable_ramdumps" "enable_mini_ramdumps" "edac_mc_log*" "enable_event_log" "*log_level*" "*log_ue*" "*log_ce*" "log_ecn_error" "snapshot_crashdumper" "seclog*" "compat-log" "*log_enabled" "tracing_on" "mballoc_debug"; do
    for o in $(find /sys/ -type f -name "$i"); do
        echo "0" > "$o" 2>/dev/null
    done
done
echo "Y" > "/sys/module/spurious/parameters/noirqdebug"

####################################
# Printk (thx to KNTD-reborn)
####################################
echo "0 0 0 0" > "/proc/sys/kernel/printk"
echo "off" > "/proc/sys/kernel/printk_devkmsg"
echo "Y" > "/sys/module/printk/parameters/console_suspend"
echo "Y" > "/sys/module/printk/parameters/ignore_loglevel"
echo "N" > "/sys/module/printk/parameters/always_kmsg_dump"
echo "N" > "/sys/module/printk/parameters/time"

############################################################
# Ramdumps | File System | Kernel Panic | Driver Debugging #
#  Printk  |     CRC     | Kernel Debugging                #
############################################################
debug_list_1="
/proc/sys/debug/exception-trace
/proc/sys/dev/scsi/logging_level
/proc/sys/kernel/bpf_stats_enabled
/proc/sys/kernel/core_pattern
/proc/sys/kernel/ftrace_dump_on_oops
/proc/sys/kernel/nmi_watchdog
/proc/sys/kernel/panic
/proc/sys/kernel/panic_on_oops
/proc/sys/kernel/panic_on_rcu_stall
/proc/sys/kernel/panic_on_warn
/proc/sys/kernel/panic_print
/proc/sys/kernel/sched_schedstats
/proc/sys/kernel/tracepoint_printk
/proc/sys/kernel/traceoff_on_warning
/proc/sys/kernel/watchdog
/proc/sys/vm/panic_on_oom
/proc/sys/walt/panic_on_walt_bug
/proc/sys/migt/migt_sched_debug
/proc/sys/glk/load_debug
/sys/kernel/debug/charger_ulog/enable
/sys/kernel/debug/dri/0/debug/enable
/sys/kernel/debug/dri/0/debug/evtlog_dump
/sys/kernel/debug/dri/0/debug/reglog_enable
/sys/kernel/debug/mi_display/backlight_log
/sys/kernel/debug/mi_display/debug_log
/sys/kernel/debug/mi_display/disp_log
/sys/kernel/debug/sps/debug_level_option
/sys/kernel/debug/sps/desc_option
/sys/kernel/debug/sps/log_level_sel
/sys/kernel/debug/sps/logging_option
/sys/kernel/debug/sde_rotator0/evtlog/enable
/sys/kernel/debug/tracing/tracing_on
/sys/kernel/tracing/options/trace_printk
/sys/kernel/tracing/options/print-msg-only
/sys/module/alarm_dev/parameters/debug_mask
/sys/module/audio_plt_dlkm/parameters/debug_mask
/sys/module/binder/parameters/debug_mask
/sys/module/binder_alloc/parameters/debug_mask
/sys/module/msm_show_resume_irq/parameters/debug_mask
/sys/module/kernel/parameters/panic
/sys/module/kernel/parameters/panic_on_warn
/sys/module/kernel/parameters/panic_print
/sys/module/kernel/parameters/panic_on_oops
/sys/module/lowmemorykiller/parameters/debug_level
/sys/module/millet_core/parameters/millet_debug
/sys/module/mmc_core/parameters/crc
/sys/module/mmc_core/parameters/removable
/sys/module/mmc_core/parameters/use_spi_crc
/sys/module/powersuspend/parameters/debug_mask
/sys/module/sdhci/parameters/debug_quirks*
/sys/module/subsystem_restart/parameters/enable_mini_ramdumps
/sys/module/subsystem_restart/parameters/enable_ramdumps
/sys/module/rmnet_data/parameters/rmnet_data_log_level
/sys/module/xt_qtaguid/parameters/debug_mask"

for debug_1 in $debug_list_1; do
  if [ -f "$debug_1" ]; then
    echo "0" > "$debug_1" 2>/dev/null
  fi
done

debug_list_2="
/sys/module/cryptomgr/parameters/panic_on_fail
/sys/kernel/debug/debug_enabled
/sys/kernel/debug/soc:qcom,pmic_glink_log/enable
/sys/module/kernel/parameters/initcall_debug
"

for debug_2 in $debug_list_2; do
  if [ -f "$debug_2" ]; then
    echo "N" > "$debug_2" 2>/dev/null
  fi
done


# Change permissions of /proc/kmsg to make it read-only
if [ -f /proc/kmsg ]; then
    chmod 0400 /proc/kmsg
fi

####################################
# Wakelocks
####################################
wakelocks1="
/sys/module/wakeup/parameters/enable_ipa_ws
/sys/module/wakeup/parameters/enable_qcom_rx_wakelock_ws
/sys/module/wakeup/parameters/enable_wlan_extscan_wl_ws
/sys/module/wakeup/parameters/enable_wlan_wow_wl_ws
/sys/module/wakeup/parameters/enable_wlan_ws
/sys/module/wakeup/parameters/enable_netmgr_wl_ws
/sys/module/wakeup/parameters/enable_wlan_ipa_ws
/sys/module/wakeup/parameters/enable_wlan_pno_wl_ws
/sys/module/wakeup/parameters/enable_wcnss_filter_lock_ws"

for wakelock1 in $wakelocks1; do
  if [ -f "$wakelock1" ]; then
    echo "N" > "$wakelock1" 2>/dev/null
  fi
done

wakelocks2="
/sys/module/wakeup/parameters/enable_bluetooth_timer
/sys/module/wakeup/parameters/enable_netlink_ws
/sys/module/wakeup/parameters/enable_timerfd_ws"

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

####################################
# Transparent Hugepage
####################################
if [ -d "/sys/kernel/mm/transparent_hugepage/" ]; then
  echo never > /sys/kernel/mm/transparent_hugepage/enabled 2>/dev/null
  echo never > /sys/kernel/mm/transparent_hugepage/defrag 2>/dev/null
fi

####################################
# UFS Tuning
####################################
# Disable All I/O stats
echo 0 > /sys/block/*/queue/iostats 2>/dev/null

# Disable All I/O Debug Helper
echo 0 > /sys/block/*/queue/nomerges 2>/dev/null

#Tune
echo 0 > /sys/block/*/queue/add_random 2>/dev/null
echo 64 > /sys/block/*/queue/rq_affinity 2>/dev/null
echo 128 > /sys/block/*/queue/read_ahead_kb 2>/dev/null

####################################
# Performance Tuning
####################################

stop perf-hal-2-3
stop vendor.perfservice

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
lock_val "1" /sys/class/kgsl/kgsl-3d0/bus_split
lock_val "92" /sys/class/kgsl/kgsl-3d0/devfreq/mod_percent

start vendor.perfservice
start perf-hal-2-3

# Laptop-Mode
echo 150 > /proc/sys/vm/dirty_writeback_centisecs 2>/dev/null
echo 1 > /proc/sys/vm/laptop_mode 2>/dev/null

# MGLRU
if [ -f "/sys/kernel/mm/lru_gen/enabled" ]; then
  lock_val "N" /sys/kernel/mm/lru_gen/enabled
  lock_val "" /sys/kernel/mm/lru_gen/min_ttl_ms
fi


# Ensure deeper C-states are allowed to save power
echo 1 > /sys/module/cpuidle/parameters/enable 2>/dev/null

if [ -f "/sys/module/workqueue/parameters/power_efficient" ]; then
  echo "Y" > /sys/module/workqueue/parameters/power_efficient 2>/dev/null
fi

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

# # Kernel Tuning
# echo 1 > /proc/sys/kernel/sched_energy_aware
# echo 1 > /proc/sys/kernel/sched_child_runs_first
# echo 0 > /proc/sys/kernel/sched_iowait_expires

####################################
# Kill and Stop Services
####################################

sleep 3 
process="
logcat
logd
tombstoned
traced
traced_probes
diag-router
ipacm-diag
mi-thermald
ssgqmigd
subsystem_ramdump
statsd
"

for name in $process; do
  stop "$name" 2>/dev/null
  am kill "$name" 2>/dev/null
  killall -9 "$name" 2>/dev/null
done

exit

# /proc/sys/glk/freq_break_enable
# 1 : aggresive scaling GPU frequency
# 0 : avoid frequent GPU performance jumps

# /proc/sys/glk/glk_disable
# 1 : reduce GPU-related overhead
# 0 : Graphics Lock or synchronization features are active