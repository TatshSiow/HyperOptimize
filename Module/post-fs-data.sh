#!/system/bin/sh
# Please don't hardcode /magisk/modname/... ; instead, please use $MODDIR/...
# This will make your scripts compatible even if Magisk change its mount point in the future
# This script will be executed in post-fs-data mode
# More info in the main Magisk thread
MODDIR=${0%/*}
# Some tools
# sysctl -a
# find "/sys/module/" -type f -name "debug_enabled"

# write "$file" "$val"
write() {
  local file="$1"
  shift
  [ -f "$file" ] && echo "$@" > "$file" 2>/dev/null
}

####################################
# Disable Debug and Logs
####################################
for i in "debug_mask" "*log_level*" "*debug_level*" "*debug_mode" "enable_ramdumps" "enable_mini_ramdumps" "edac_mc_log*" "enable_event_log" "*log_ue*" "*log_ce*" "log_ecn_error" "snapshot_crashdumper" "seclog*" "compat-log" "*log_enable*" "tracing_on" "mballoc_debug" "evtlog_dump" "klog_lvl" "ipc_log_lvl" "*stats_enabled" "enable_cmd_dma_stats" "debug_output"; do
    for path in /sys/kernel/ /sys/module/; do
        for o in $(find "$path" -type f -name "$i" 2>/dev/null); do
            write "$o" "0"
        done
    done
done

debug_list_1="
/proc/sys/debug/exception-trace
/proc/sys/dev/scsi/logging_level
/proc/sys/kernel/bpf_stats_enabled
/proc/sys/kernel/core_pattern
/proc/sys/kernel/ftrace_dump_on_oops
/proc/sys/kernel/sched_schedstats
/proc/sys/kernel/tracepoint_printk
/proc/sys/kernel/traceoff_on_warning
/proc/sys/vm/block_dump
/proc/sys/vm/oom_dump_tasks
/proc/sys/walt/panic_on_walt_bug
/proc/sys/migt/migt_sched_debug
/proc/sys/migt/enable_pkg_monitor
/proc/sys/glk/load_debug
/sys/kernel/debug/charger_ulog/enable
/sys/kernel/debug/mi_display/backlight_log
/sys/kernel/debug/mi_display/debug_log
/sys/kernel/debug/mi_display/disp_log
/sys/kernel/debug/sps/desc_option
/sys/kernel/debug/sps/logging_option
/sys/kernel/debug/sde_rotator0/evtlog/enable
/sys/kernel/debug/tracing/options/trace_printk
/sys/kernel/tracing/options/trace_printk
/sys/kernel/tracing/options/print-msg-only
/sys/module/kernel/parameters/panic
/sys/module/kernel/parameters/panic_on_warn
/sys/module/kernel/parameters/panic_print
/sys/module/kernel/parameters/panic_on_oops
/sys/module/millet_core/parameters/millet_debug
/sys/module/mmc_core/parameters/crc
/sys/module/mmc_core/parameters/removable
/sys/module/mmc_core/parameters/use_spi_crc
/sys/module/sdhci/parameters/debug_quirks*
/sys/module/scsi_mod/parameters/scsi_logging_level
/sys/kernel/debug/dri/0/debug/enable
/sys/kernel/debug/dri/0/debug/hw_log_mask
/sys/kernel/debug/dri/0/debug/evtlog_dump
/sys/kernel/debug/dri/0/debug/reglog_enable
/sys/module/microdump_collector/parameters/enable_microdump
/sys/module/microdump_collector/parameters/start_qcomdump
/sys/module/qcom_ramdump/parameters/enable_dump_collection
/sys/module/rcupdate/parameters/rcu_cpu_stall_ftrace_dump
/sys/kernel/debug/msm_cvp/minidump_enable
/sys/kernel/debug/msm_cvp/fw_debug_mode
/sys/module/metis/parameters/doublecyc_debug
/sys/module/metis/parameters/fboost_debug
/sys/module/metis/parameters/link_debug
/sys/module/metis/parameters/metis_debug
/sys/module/metis/parameters/tsched_debug
/sys/module/migt/parameters/enable_pkg_monitor
/sys/module/migt/parameters/flw_debug
/sys/module/migt/parameters/flw_enable
/sys/module/migt/parameters/game_link_debug
/sys/module/migt/parameters/migt_debug
/sys/module/camera/parameters/cpas_dump
/sys/kernel/debug/kgsl/kgsl-3d0/profiling/enable
/sys/kernel/debug/camera/isp_ctx/enable_cdm_cmd_buffer_dump
/sys/kernel/debug/camera/isp_ctx/enable_state_monitor_dump
/sys/kernel/debug/msm_vidc/enable_bugon
/sys/module/msm_video/parameters/msm_vidc_fw_dump
/sys/kernel/debug/kprobes/enabled
/sys/module/can/parameters/stats_timer
/sys/kernel/debug/gsi/enable_dp_stats
/proc/sys/net/netfilter/nf_conntrack_log_invalid
/proc/sys/net/netfilter/nf_log_all_netns
/proc/sys/kernel/hung_task_all_cpu_backtrace
/proc/sys/kernel/oops_all_cpu_backtrace
/proc/sys/kernel/softlockup_all_cpu_backtrace
/proc/sys/net/netfilter/nf_conntrack_log_invalid
/proc/sys/fs/suid_dumpable
/sys/module/ramoops/parameters/dump_oops"
# /sys/kernel/debug/gsi/enable_dp_stats is not accessible
for debug_1 in $debug_list_1; do
  write "$debug_1" "0"
done

debug_list_2="
/sys/module/cryptomgr/parameters/panic_on_fail
/sys/kernel/debug/debug_enabled
/sys/kernel/debug/soc:qcom,pmic_glink_log/enable
/sys/module/kernel/parameters/initcall_debug
/sys/module/printk/parameters/always_kmsg_dump
/sys/module/printk/parameters/time
/sys/module/kiwi_v2/parameters/qdf_log_dump_at_kernel_enable
/sys/module/msm_drm/parameters/reglog
/sys/module/msm_drm/parameters/dumpstate
/sys/module/blk_cgroup/parameters/blkcg_debug_stats
/sys/kernel/debug/camera/smmu/cb_dump_enable
/sys/kernel/debug/camera/ife/enable_req_dump
/sys/kernel/debug/camera/smmu/map_profile_enable
/sys/kernel/debug/camera/memmgr/alloc_profile_enable
/sys/module/drm_kms_helper/parameters/poll"

for debug_2 in $debug_list_2; do
  write "$debug_2" "N"
done

####################################
# Printk
####################################
write "/proc/sys/kernel/printk" "0 0 0 0"
write "/proc/sys/kernel/printk_devkmsg" "off"
write "/sys/module/printk/parameters/console_suspend" "Y"
write "/sys/module/printk/parameters/ignore_loglevel" "Y" 
write "/sys/module/spurious/parameters/noirqdebug" "Y" 

####################################
# Misc Optimization
####################################
# BT
# Lower BT Performance but Lower Power Consumption
write "/sys/module/bluetooth/parameters/disable_ertm" "Y"
# Lower the latency but might affect buffering (audio glitches)
write "/sys/module/bluetooth/parameters/disable_ertm" "Y"
write "/sys/module/bluetooth/parameters/disable_esco" "Y"

# Apple Peripherals You won't use it for 99.9% of time
write "/sys/module/hid_apple/parameters/fnmode" "0"
write "/sys/module/hid_apple/parameters/iso_layout" "0"
write "/sys/module/hid_magicmouse/parameters/emulate_3button" "N"
write "/sys/module/hid_magicmouse/parameters/emulate_scroll_wheel" "N"
write "/sys/module/hid_magicmouse/parameters/scroll_speed" "0"

# Disable Audit Log
write "/sys/module/lsm_audit/parameters/disable_audit_log" "1"

# Disable Event Tracing
write "/sys/kernel/debug/tracing/set_event" ""
write "/sys/kernel/debug/tracing/events/enable" "0"
write "/sys/kernel/tracing/events/enable" "0"

# Turn Off va-minidump
for minidump in /sys/kernel/va-minidump/*/enable;do
  write "$minidump" "0"
done

# disables watchdogs and panics (don't apply if your device frequently crashes)
# watchdog_cpumask : Watchdog will only use the CPU written
wps="/proc/sys/kernel/nmi_watchdog
/proc/sys/kernel/soft_watchdog
/proc/sys/kernel/watchdog
/proc/sys/kernel/hung_task_panic
/proc/sys/kernel/max_rcu_stall_to_panic
/proc/sys/kernel/panic
/proc/sys/kernel/panic_on_oops
/proc/sys/kernel/panic_on_rcu_stall
/proc/sys/kernel/panic_on_warn
/proc/sys/kernel/panic_print
/proc/sys/kernel/softlockup_panic
/proc/sys/vm/panic_on_oom
/proc/sys/walt/panic_on_walt_bug
/proc/sys/kernel/watchdog_cpumask"
for wp in $wps;do
  write "$wp" "0"
done

# ULPS tuning
for file in /sys/kernel/debug/*/*; do
    if [[ -f "$file" ]]; then
        if [[ "$file" == *dsi-phy-0_allow_phy_power_off* ]]; then
            write "$file" "Y"
        elif [[ "$file" == *ulps_feature_enable* ]]; then
            write "$file" "Y"
        elif [[ "$file" == *ulps_suspend_feature_enable* ]]; then
            write "$file" "Y"
        fi
    fi
done

write "/sys/module/cryptomgr/parameters/notests" "Y"
write "/sys/module/hid/parameters/ignore_special_drivers" "1"

# MGLRU
# if [ -d /sys/kernel/mm/lru_gen/ ]; then
#     lock_val "Y" /sys/kernel/mm/lru_gen/enabled
#     # 高：提升後台留存能力，吃內存，可以減少swap開銷
#     lock_val "5000" /sys/kernel/mm/lru_gen/min_ttl_ms
# fi

####################################
# I/O Tuning
####################################
# Doc:
# 1. https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/8/html/monitoring_and_managing_system_status_and_performance/factors-affecting-i-o-and-file-system-performance_monitoring-and-managing-system-status-and-performance#generic-block-device-tuning-parameters_factors-affecting-i-o-and-file-system-performance
# 2. https://brendangregg.com/blog/2015-03-03/performance-tuning-linux-instances-on-ec2.html
# 3. https://blog.csdn.net/yiyeguzhou100/article/details/100068115
# for file in /sys/devices/virtual/block/*/queue/read_ahead_kb; do echo "$file $(cat $file)"; done

####################################
# I/O Improvements
####################################

# Disable I/O stats, MB_Stats, No-Merge, Add-Random
for io in /sys/block/*/queue/iostats /sys/devices/virtual/block/*/queue/iostats /sys/fs/ext4/*/mb_stats /sys/block/*/queue/nomerges /sys/devices/virtual/block/*/queue/nomerges /sys/block/*/queue/add_random /sys/devices/virtual/block/*/queue/add_random; do
  write "$io" "0"
done;

# RQ_AFFINITY
# 0 : I/O completion requests can be processed by any CPU cores.
# 1 : I/O completion requests are handled only by the same CPU core that initiated the request.
# 2 : I/O completion requests are processed by any CPU core within the same NUMA node as the core that initiated the request.
for rq in /sys/block/*/queue/rq_affinity $(find /sys/devices -name rq_affinity); do
    write "$rq" "1"
done;

####################################
# Network Tuning
####################################
# Network tweaks for saving battery
write "/proc/sys/net/ipv4/tcp_timestamps" "0"
write "/proc/sys/net/ipv4/tcp_dsack" "0"
write "/proc/sys/net/ipv4/tcp_ecn" "0"
write "/proc/sys/net/ipv4/tcp_slow_start_after_idle" "0"

# Disable IPv6, saves battery and lower the exploit risk if not using
write "/proc/sys/net/ipv6/conf/all/disable_ipv6" "1"

####################################
# Transparent Hugepage
####################################
if [ -d "/sys/kernel/mm/transparent_hugepage/" ]; then
    write "/sys/kernel/mm/transparent_hugepage/enabled" "never"
    write "/sys/kernel/mm/transparent_hugepage/defrag" "never"
    write "/sys/kernel/mm/transparent_hugepage/khugepaged/defrag" "0"
    write "/sys/kernel/mm/transparent_hugepage/khugepaged/scan_sleep_millisecs" "1000000"
fi

####################################
# Misc Tuning
####################################
# 數字越高，安全等級越高，0等於完全不用 (Address Space Layout Randomization)
write "/proc/sys/kernel/randomize_va_space" "1"

# 不可被驱逐的内存是一种无法从内存中移除的内存，例如被锁定的内存或内核数据结构等。
write "/proc/sys/vm/compact_unevictable_allowed" "1"
# /proc/sys/vm/compact_memory

# never enable this unless you have special usage
write "/proc/sys/kernel/sched_child_runs_first" "0"

# timers on the OS CPUs can be migrated to one of the application CPUs
write "/proc/sys/kernel/timer_migration" "1"

# # Enable Power Efficient WQ
write "/sys/module/workqueue/parameters/power_efficient" "Y"

# RCU Tuning
write "/sys/kernel/rcu_expedited" "0"
write "/sys/kernel/rcu_normal" "1"

# 0 balanced
# 1 excessive swapping
# 2avoid memory overcommitment and reduce swapping
write "/proc/sys/vm/overcommit_memory" "2"

# Energy Efficient
write "/proc/sys/kernel/sched_energy_aware" "1"
