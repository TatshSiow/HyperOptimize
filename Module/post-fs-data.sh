#!/system/bin/sh
# Please don't hardcode /magisk/modname/... ; instead, please use $MODDIR/...
# This will make your scripts compatible even if Magisk change its mount point in the future
# This script will be executed in post-fs-data mode
# More info in the main Magisk thread
MODDIR=${0%/*}

####################################
# I/O Tuning
####################################
# Doc:
# 1. https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/8/html/monitoring_and_managing_system_status_and_performance/factors-affecting-i-o-and-file-system-performance_monitoring-and-managing-system-status-and-performance#generic-block-device-tuning-parameters_factors-affecting-i-o-and-file-system-performance
# 2. https://brendangregg.com/blog/2015-03-03/performance-tuning-linux-instances-on-ec2.html
# 3. https://blog.csdn.net/yiyeguzhou100/article/details/100068115
# Disable All I/O stats
echo 0 > /sys/block/*/queue/iostats 2>/dev/null

#Enable Merging
echo 0 > /sys/block/*/queue/nomerges 2>/dev/null

# Disable add_random can slightly reduce overhead
echo 0 > /sys/block/*/queue/add_random 2>/dev/null

# Set rq_affinity to 2 will evenly distribute load to all cores
echo 2 > /sys/block/*/queue/rq_affinity 2>/dev/null

####################################
# Kernel Tuning
####################################
# never enable this unless you have special usage
echo 0 > /proc/sys/kernel/sched_child_runs_first 2>/dev/null

# 1 : Optimize for multi core
echo 1 > /proc/sys/kernel/timer_migration 2>/dev/null

# Enable Power Efficient WQ
echo "Y" > /sys/module/workqueue/parameters/power_efficient 2>/dev/null


# Use vendor default
# echo 128 > /sys/block/*/queue/nr_requests
# echo 128 > /sys/block/*/queue/read_ahead_kb
# 
#  find / -name '*power_efficient*' 2>/dev/null
# 
# sysctl -a


#################
# Memory Tuning
#################
echo 50 > /proc/sys/vm/vfs_cache_pressure 2>/dev/null
echo 30 > /proc/sys/vm/stat_interval 2>/dev/null
echo 0 > /proc/sys/vm/compaction_proactiveness 2>/dev/null

####################################
# Net Tuning
####################################
echo 0 > /proc/sys/net/ipv4/tcp_timestamps 2>/dev/null


####################################
# Transparent Hugepage
####################################
if [ -d "/sys/kernel/mm/transparent_hugepage/" ]; then
  echo never > /sys/kernel/mm/transparent_hugepage/enabled 2>/dev/null
  echo never > /sys/kernel/mm/transparent_hugepage/defrag 2>/dev/null
fi

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


####################################
# Printk (thx to KNTD-reborn)
####################################
echo "0 0 0 0" > "/proc/sys/kernel/printk"
echo "off" > "/proc/sys/kernel/printk_devkmsg"
echo "Y" > "/sys/module/printk/parameters/console_suspend"
echo "Y" > "/sys/module/printk/parameters/ignore_loglevel"
echo "N" > "/sys/module/printk/parameters/always_kmsg_dump"
echo "N" > "/sys/module/printk/parameters/time"

####################################
# Kernel Debugging (thx to KTSR)
####################################
for i in "debug_mask" "log_level*" "debug_level*" "*debug_mode" "enable_ramdumps" "enable_mini_ramdumps" "edac_mc_log*" "enable_event_log" "*log_level*" "*log_ue*" "*log_ce*" "log_ecn_error" "snapshot_crashdumper" "seclog*" "compat-log" "*log_enabled" "tracing_on" "mballoc_debug"; do
    for o in $(find /sys/ -type f -name "$i"); do
        echo "0" > "$o" 2>/dev/null
    done
done
echo "Y" > "/sys/module/spurious/parameters/noirqdebug"

# Change permissions of /proc/kmsg to make it read-only
if [ -f /proc/kmsg ]; then
    chmod 0400 /proc/kmsg
fi


####################################
# Wakelock Control
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

# Boeffla
if [ -f /sys/devices/virtual/misc/boeffla_wakelock_blocker/wakelock_blocker ]; then
  echo "wlan_pno_wl;wlan_ipa;wcnss_filter_lock;hal_bluetooth_lock;IPA_WS;sensor_ind;wlan;netmgr_wl;qcom_rx_wakelock;wlan_wow_wl;wlan_extscan_wl;NETLINK;bam_dmux_wakelock;IPA_RM12" > /sys/devices/virtual/misc/boeffla_wakelock_blocker/wakelock_blocker 
elif [ -f /sys/class/misc/boeffla_wakelock_blocker/wakelock_blocker ]; then
  echo "wlan_pno_wl;wlan_ipa;wcnss_filter_lock;hal_bluetooth_lock;IPA_WS;sensor_ind;wlan;netmgr_wl;qcom_rx_wakelock;wlan_wow_wl;wlan_extscan_wl;NETLINK;bam_dmux_wakelock;IPA_RM12" > /sys/class/misc/boeffla_wakelock_blocker/wakelock_blocker
fi

####################################
# Additional Props Config
####################################
# getprop | grep -i (prop-properties)

# SoC Config
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

# Enables ZRAM 1:1 if device is Hyper OS 2.0
if [ "$(getprop ro.mi.os.version.name)" = "OS2.0" ]; then
    resetprop -n persist.miui.extm.dm_opt.enable true
fi

# Enables LZ4asm if LZ4 ZRAM Compression is present
if [ -f "/sys/block/zram0/comp_algorithm" ] && grep -q "\[lz4\]" /sys/block/zram0/comp_algorithm; then
    resetprop -n persist.sys.stability.lz4asm on
else
    resetprop -n persist.sys.stability.lz4asm off
fi

# Enables FBO service if HAL and props found, only for UFS
if [ -d "/sys/block/sda" ] && [ "$(getprop init.svc.vendor.fbo-hal-1-0)" ] && [ "$(getprop persist.sys.stability.miui_fbo_enable)" = "true" ]; then
    resetprop -n persist.sys.stability.fbo_hal_stop false
    resetprop -n persist.sys.fboservice.ctrl true
    resetprop -n persist.sys.stability.miui_fbo_start_count 1
fi


# 有些設定system.prop吃不到，我放這裡總可以了吧（？
#Disable Power Monitor Tools
su -c "resetprop -n debug.power.monitor_tools false"
# LMK
su -c "resetprop -n persist.sys.lmk.reportkills false"

# statsd
su -c "resetprop -n persist.device_config.runtime_native.metrics.write-to-statsd false"
su -c "resetprop -n persist.device_config.statsd_native_boot.enable_restricted_metrics false"
