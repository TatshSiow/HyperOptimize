#!/system/bin/sh
# Please don't hardcode /magisk/modname/... ; instead, please use $MODDIR/...
# This will make your scripts compatible even if Magisk change its mount point in the future
# This script will be executed in post-fs-data mode
# More info in the main Magisk thread
MODDIR=${0%/*}

write() {
    local file="$1"
    shift
    [ -f "$file" ] && echo "$@" > "$file" 2>/dev/null
}

####################################
# I/O Tuning
####################################
# Doc:
# 1. https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/8/html/monitoring_and_managing_system_status_and_performance/factors-affecting-i-o-and-file-system-performance_monitoring-and-managing-system-status-and-performance#generic-block-device-tuning-parameters_factors-affecting-i-o-and-file-system-performance
# 2. https://brendangregg.com/blog/2015-03-03/performance-tuning-linux-instances-on-ec2.html
# 3. https://blog.csdn.net/yiyeguzhou100/article/details/100068115
# 4. https://github.com/chbatey/tobert.github.io/blob/c98e69267d84aea557e8f6e9bdc62c0d305b7454/src/pages/cassandra_tuning_guide.md?plain=1#L1090

# Disable Add-Random
for io in  /sys/block/*/queue/add_random /sys/devices/virtual/block/*/queue/add_random; do
    write "$io" "0"
done

#nomerges
for nomerge in /sys/block/*/queue/nomerges /sys/devices/virtual/block/*/queue/nomerges; do
    write "$nomerge" "0"
done

# RQ_AFFINITY
# 0 : I/O completion requests can be processed by any CPU cores.
# 1 : I/O completion requests are handled only by the same CPU core that initiated the request.
# 2 : I/O completion requests are processed by any CPU core within the same NUMA node as the core that initiated the request. (multi CPU socket platform)
for rq in /sys/block/*/queue/rq_affinity $(find /sys/devices/ -name rq_affinity); do
    # echo "$(cat $rq)"
    write "$rq" "1"
done

####################################
# Misc Logs
####################################
# Spurious Debug
write "/sys/module/spurious/parameters/noirqdebug" "Y" 

# Audit Log
write "/sys/module/lsm_audit/parameters/disable_audit_log" "1"

# va-minidump
for minidump in /sys/kernel/va-minidump/*/enable;do
    write "$minidump" "0"
done

####################################
# Network Tuning
####################################
# Network tweaks for saving battery
write "/proc/sys/net/ipv4/tcp_timestamps" "0"
write "/proc/sys/net/ipv4/tcp_dsack" "1"
write "/proc/sys/net/ipv4/tcp_sack" "1"
write "/proc/sys/net/ipv4/tcp_ecn" "0"
write "/proc/sys/net/ipv4/tcp_slow_start_after_idle" "1"
write "/proc/sys/net/ipv4/udp_early_demux" "1"
write "/proc/sys/net/ipv4/fwmark_reflect" "1"
write "/proc/sys/net/ipv4/fib_notify_on_flag_change" "0"
write "/proc/sys/net/ipv4/icmp_echo_enable_probe" "0"
write "/proc/sys/net/ipv4/icmp_msgs_per_sec" "100"
write "/proc/sys/net/ipv4/icmp_ratelimit" "100"
write "/proc/sys/net/ipv4/tcp_tw_reuse" "2"
write "/proc/sys/net/ipv4/tcp_mtu_probing" "1"
write "/proc/sys/net/ipv4/tcp_low_latency" "0"
write "/proc/sys/net/ipv4/tcp_no_metrics_save" "1"
write "/proc/sys/net/ipv4/tcp_no_ssthresh_metrics_save" "1"
write "/proc/sys/net/ipv4/tcp_moderate_rcvbuf" "1"

# Unless your system is acting as a router, this should be set to 0
write "/proc/sys/net/ipv4/ip_forward" "0"

# TCP congestion
for CC in westwood bbr cubic reno; do
    if grep -qw "$CC" /proc/sys/net/ipv4/tcp_available_congestion_control; then
        write "/proc/sys/net/ipv4/tcp_congestion_control" "$CC"
        break
    fi
done

# # Disable IPv6, saves battery and lower the exploit risk if not using
write "/proc/sys/net/ipv6/conf/all/disable_ipv6" "1"

####################################
# Transparent Hugepage
####################################
write "/sys/kernel/mm/transparent_hugepage/enabled" "never"

####################################
# Misc Tuning
####################################
# 不可被驱逐的内存是一种无法从内存中移除的内存，例如被锁定的内存或内核数据结构等。
write "/proc/sys/vm/compact_unevictable_allowed" "1"

# Halved backlog
backlog=$(( $(cat /proc/sys/net/core/netdev_max_backlog) / 2 ))
write "/proc/sys/net/core/netdev_max_backlog" "$backlog"

# BT
# Lower BT Performance but Lower Power Consumption
write "/sys/module/bluetooth/parameters/disable_ertm" "Y"
# Lower the latency but might affect buffering (audio glitches)
write "/sys/module/bluetooth/parameters/disable_esco" "Y"

# Apple Peripherals You won't use it for 99.9% of time
write "/sys/module/hid_apple/parameters/fnmode" "0"
write "/sys/module/hid_apple/parameters/iso_layout" "0"
write "/sys/module/hid_magicmouse/parameters/emulate_3button" "N"
write "/sys/module/hid_magicmouse/parameters/emulate_scroll_wheel" "N"
write "/sys/module/hid_magicmouse/parameters/scroll_speed" "0"

# Disable not so useful modules
write "/sys/module/cryptomgr/parameters/notests" "Y"
write "/sys/module/hid/parameters/ignore_special_drivers" "1"

####################################
# Kernel Parameters
####################################

# # Enable Power Efficient WQ
write "/sys/module/workqueue/parameters/power_efficient" "Y"

# # 0,1,2 數字越高，安全性越高 (Address Space Layout Randomization)
# # 僅影響開App速度
# write "/proc/sys/kernel/randomize_va_space" "2"

# never enable this unless you have special usage
write "/proc/sys/kernel/sched_child_runs_first" "0"

# timers on the OS CPUs can be migrated to one of the application CPUs
write "/proc/sys/kernel/timer_migration" "0"

# Energy Efficient
write "/proc/sys/kernel/sched_energy_aware" "1"

#Boeffla Wakelock
if [ -f /sys/devices/virtual/misc/boeffla_wakelock_blocker/wakelock_blocker ]; then
    echo "wlan_pno_wl;wlan_ipa;wcnss_filter_lock;hal_bluetooth_lock;IPA_WS;sensor_ind;wlan;netmgr_wl;qcom_rx_wakelock;wlan_wow_wl;wlan_extscan_wl;NETLINK;bam_dmux_wakelock;IPA_RM12" > /sys/devices/virtual/misc/boeffla_wakelock_blocker/wakelock_blocker 
elif [ -f /sys/class/misc/boeffla_wakelock_blocker/wakelock_blocker ]; then
    echo "wlan_pno_wl;wlan_ipa;wcnss_filter_lock;hal_bluetooth_lock;IPA_WS;sensor_ind;wlan;netmgr_wl;qcom_rx_wakelock;wlan_wow_wl;wlan_extscan_wl;NETLINK;bam_dmux_wakelock;IPA_RM12" > /sys/class/misc/boeffla_wakelock_blocker/wakelock_blocker
fi

####################################
# Additional Props Config
####################################

# SoC Config
if [ "$(getprop ro.hardware)" = "qcom" ]; then
    #Qualcomm stm events
    resetprop -n persist.debug.coresight.config ""
    # RCU Tuning
    write "/sys/kernel/rcu_expedited" "0"
    write "/sys/kernel/rcu_normal" "1"
    # WALT
    if [ -d /proc/sys/walt/ ]; then
    # WALT disable boost
        for i in /proc/sys/walt/input_boost/* ; do
            write "$i" "0"
        done
        write "/proc/sys/walt/sched_boost" "0"
        # 高：省電，但響應速降低
        # WALT的conservative，省電
        write "/proc/sys/walt/sched_conservative_pl" "1"
        # Colcation
        write "/proc/sys/walt/sched_min_task_util_for_boost"  "51"
        write "/proc/sys/walt/sched_min_task_util_for_colocation"  "35"
        # write "/proc/sys/walt/sched_min_task_util_for_colocation"  "0"
        write "/proc/sys/walt/sched_task_unfilter_period" "20000000"
    fi
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

# # disables watchdogs and panics (don't apply if your device frequently crashes)
# wps="/proc/sys/kernel/nmi_watchdog
# /proc/sys/kernel/soft_watchdog
# /proc/sys/kernel/watchdog
# /proc/sys/kernel/watchdog_thresh
# /proc/sys/kernel/max_rcu_stall_to_panic
# /proc/sys/kernel/panic
# /proc/sys/kernel/panic_on_oops
# /proc/sys/kernel/panic_on_rcu_stall
# /proc/sys/kernel/panic_on_warn
# /proc/sys/kernel/panic_print
# /proc/sys/kernel/softlockup_panic
# /proc/sys/vm/panic_on_oom
# /proc/sys/walt/panic_on_walt_bug
# /proc/sys/kernel/print-fatal-signals
# /sys/module/kernel/parameters/panic
# /sys/module/kernel/parameters/panic_on_warn
# /sys/module/kernel/parameters/panic_print
# /sys/module/kernel/parameters/panic_on_oops
# /sys/module/cryptomgr/parameters/panic_on_fail"
# for wp in $wps;do
#    write "$wp" "0"
# done

# ####################################
# # Hung Tasks
# ####################################
# write "/proc/sys/kernel/hung_task_check_count" "0"
# write "/proc/sys/kernel/hung_task_panic" "0"
# write "/proc/sys/kernel/hung_task_warnings" "0"
# write "/proc/sys/kernel/hung_task_timeout_secs" "15"

# watchdog_cpumask : Watchdog will only use the CPU written
write "/proc/sys/kernel/watchdog_cpumask" ""

###### IO TUNING ########
# if [ -d /sys/block/sda ]; then
#     # UFS
#     for i in /sys/block/sd*/queue/nr_requests; do 
#         write "$i" "16"
#     done

#     for i in /sys/block/sd*/queue/read_ahead_kb; do 
#         write "$i" "64"
#     done
# else
#     # eMMC
#     for i in /sys/block/mmcblk*/queue/nr_requests; do 
#         write "$i" "8"
#     done
#     for i in /sys/block/mmcblk*/queue/read_ahead_kb; do 
#         write "$i" "32"
#     done
# fi

# # DM
# for i in /sys/block/dm-*/queue/nr_requests /sys/devices/virtual/block/dm-*/queue/nr_requests; do 
#     write "$i" "16"
# done

# for i in /sys/block/dm-*/queue/read_ahead_kb /sys/devices/virtual/block/dm-*/queue/read_ahead_kb; do 
#     write "$i" "64"
# done

# # RAM
# for i in /sys/block/ram*/queue/nr_requests /sys/devices/virtual/block/ram*/queue/nr_requests; do 
#     write "$i" "8" 
# done

# for i in /sys/block/ram*/queue/read_ahead_kb /sys/devices/virtual/block/ram*/queue/read_ahead_kb; do 
#     write "$i" "16" 
# done

# # ZRAM
# write "/sys/block/zram0/queue/nr_requests" "8"
# write "/sys/block/zram0/queue/read_ahead_kb" "32"
# write "/sys/devices/virtual/block/zram0/queue/nr_requests" "8"
# write "/sys/devices/virtual/block/zram0/queue/read_ahead_kb" "32"