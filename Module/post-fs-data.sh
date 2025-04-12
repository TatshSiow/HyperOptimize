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

# nomerges
# This enables the user to disable the lookup logic involved with IO merging requests in the block layer. 
# By default (0) all merges are enabled. When set to 1 only simple one-hit merges will be tried. 
# When set to 2 no merge algorithms will be tried (including one-hit or more complex tree/hash lookups).
# https://github.com/torvalds/linux/commit/488991e28e55b4fbca8067edf0259f69d1a6f92c
for nomerge in /sys/block/*/queue/nomerges /sys/devices/virtual/block/*/queue/nomerges; do
    write "$nomerge" "1"
done

# RQ_AFFINITY
# value : 0-2 Higher means more aggresive
# Try to have scheduler requests complete on the CPU core they were made from
# https://zhuanlan.zhihu.com/p/346966856
for rq in /sys/block/*/queue/rq_affinity $(find /sys/devices/ -name rq_affinity); do
    # echo "$(cat $rq)"
    write "$rq" "1"
done

# Disable heuristic read-ahead in exchange for I/O latency on ram
for queue in /sys/block/ram*/queue/read_ahead_kb
do
    write $queue "0"
done

# Disable heuristic read-ahead in exchange for I/O latency on zram
for queue in /sys/block/zram*/queue/read_ahead_kb
do
    write $queue "0"
done

# Disable heuristic read-ahead in exchange for I/O latency on loop
for queue in /sys/block/loop*/queue/read_ahead_kb
do
    write $queue "0"
done


####################################
# Misc Logs
####################################
# Spurious Debug
write "/sys/module/spurious/parameters/noirqdebug" "Y" 

# Audit Log
write "/sys/module/lsm_audit/parameters/disable_audit_log" "1"

# va-minidump
for minidump in /sys/kernel/va-minidump/*/enable; do
    write "$minidump" "0"
done

####################################
# Network Tuning
####################################
# Network tweaks to reduce power
write "/proc/sys/net/ipv4/tcp_timestamps" "0"
write "/proc/sys/net/ipv4/tcp_dsack" "1"
write "/proc/sys/net/ipv4/tcp_sack" "1"
write "/proc/sys/net/ipv4/tcp_ecn" "1"
write "/proc/sys/net/ipv4/tcp_slow_start_after_idle" "0"
write "/proc/sys/net/ipv4/udp_early_demux" "1"
write "/proc/sys/net/ipv4/fwmark_reflect" "1"
write "/proc/sys/net/ipv4/fib_notify_on_flag_change" "0"
write "/proc/sys/net/ipv4/icmp_echo_enable_probe" "0"
write "/proc/sys/net/ipv4/icmp_msgs_per_sec" "100"
write "/proc/sys/net/ipv4/icmp_ratelimit" "100"
write "/proc/sys/net/ipv4/tcp_tw_reuse" "1"
write "/proc/sys/net/ipv4/tcp_mtu_probing" "1"
write "/proc/sys/net/ipv4/tcp_low_latency" "0"
write "/proc/sys/net/ipv4/tcp_no_metrics_save" "1"
write "/proc/sys/net/ipv4/tcp_no_ssthresh_metrics_save" "1"
write "/proc/sys/net/ipv4/tcp_moderate_rcvbuf" "1"
write "/proc/sys/net/core/netdev_tstamp_prequeue" "0"
write "/proc/sys/net/ipv4/ipfrag_time" "25"
write "/proc/sys/net/ipv4/tcp_fastopen" "3"
write "/proc/sys/net/core/netdev_max_backlog" "128"
write "/proc/sys/net/ipv4/tcp_fack" "1"
write "/proc/sys/net/ipv4/tcp_fwmark_accept" "0"
write "/proc/sys/net/ipv4/tcp_keepalive_intvl" "180"
write "/proc/sys/net/ipv4/tcp_keepalive_time" "21600"
write "/proc/sys/net/ipv6/ip6frag_time" "48"
write "/sys/module/tcp_cubic/parameters/hystart_detect" "2"

# Unless your system is acting as a router (IP forwarding device) , this should be set to 0
write "/proc/sys/net/ipv4/ip_forward" "0"

# TCP congestion
for CC in bbr westwood cubic reno; do
    if grep -qw "$CC" /proc/sys/net/ipv4/tcp_available_congestion_control; then
        write "/proc/sys/net/ipv4/tcp_congestion_control" "$CC"
        break
    fi
done

####################################
# Transparent Hugepage
# https://blog.csdn.net/hbuxiaofei/article/details/128402495
####################################
write "/sys/kernel/mm/transparent_hugepage/enabled" "never"

####################################
# Misc Tuning
# https://sysctl-explorer.net/vm/compact_unevictable_allowed/
####################################
# 不可被驱逐的内存是一种无法从内存中移除的内存，例如被锁定的内存或内核数据结构等。
write "/proc/sys/vm/compact_unevictable_allowed" "1"

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
write "/proc/sys/kernel/timer_migration" "1"

# Energy Efficient
write "/proc/sys/kernel/sched_energy_aware" "1"

# PERF Monitoring
write "/proc/sys/kernel/perf_cpu_time_max_percent" "0"

# Round Robin Timeslice
write "/proc/sys/kernel/sched_rr_timeslice_ms" "200"

# PELT Multiplier
write "/proc/sys/kernel/sched_pelt_multiplier" "8"

#Boeffla Wakelock
if [ -f /sys/devices/virtual/misc/boeffla_wakelock_blocker/wakelock_blocker ]; then
    echo "wlan_pno_wl;wlan_ipa;wcnss_filter_lock;hal_bluetooth_lock;IPA_WS;sensor_ind;wlan;netmgr_wl;qcom_rx_wakelock;wlan_wow_wl;wlan_extscan_wl;NETLINK;bam_dmux_wakelock;IPA_RM12;[timerfd];wlan;SensorService_wakelock;tftp_server_wakelock" > /sys/devices/virtual/misc/boeffla_wakelock_blocker/wakelock_blocker 
elif [ -f /sys/class/misc/boeffla_wakelock_blocker/wakelock_blocker ]; then
    echo "wlan_pno_wl;wlan_ipa;wcnss_filter_lock;hal_bluetooth_lock;IPA_WS;sensor_ind;wlan;netmgr_wl;qcom_rx_wakelock;wlan_wow_wl;wlan_extscan_wl;NETLINK;bam_dmux_wakelock;IPA_RM12;[timerfd];wlan;SensorService_wakelock;tftp_server_wakelock" > /sys/class/misc/boeffla_wakelock_blocker/wakelock_blocker
fi


# Disable CPU watchdog
write "/proc/sys/kernel/watchdog_cpumask" ""

####################################
# Additional Props Config
####################################

# SoC Config
if [ "$(getprop ro.hardware)" = "qcom" ]; then
    #Qualcomm stm events
    resetprop -n persist.debug.coresight.config ""
    # RCU Tuning
    # https://www.kernel.org/doc/Documentation/RCU/Design/Expedited-Grace-Periods/Expedited-Grace-Periods.html
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
        # task
        write "/proc/sys/walt/sched_min_task_util_for_boost"  "60"
        write "/proc/sys/walt/sched_min_task_util_for_colocation"  "40"
        write "/proc/sys/walt/sched_task_unfilter_period" "20000000"

    # Tune for All Cores
        echo "0" > /sys/devices/system/cpu/cpu*/cpufreq/walt/boost
    fi
    if [ -d /proc/sys/schedutil/ ]; then
    # Schedutil config based in this patch: https://patchwork.kernel.org/project/linux-pm/patch/c6248ec9475117a1d6c9ff9aafa8894f6574a82f.1479359903.git.viresh.kumar@linaro.org/
        echo "10000" > /sys/devices/system/cpu/cpu*/cpufreq/schedutil/up_rate_limit_us
        echo "40000" > /sys/devices/system/cpu/cpu*/cpufreq/schedutil/down_rate_limit_us
    fi
else
    #MediaTeK
    resetprop -n ro.vendor.mtk_prefer_64bit_proc 1
    resetprop -n persist.vendor.duraspeed.support 0
    resetprop -n persist.vendor.duraspeed.lowmemory.enable 0
    resetprop -n persist.vendor.duraeverything.support 0
    resetprop -n persist.vendor.duraeverything.lowmemory.enable 0
fi

# Enable APTX Adaptive 2.2 Support (Only for 8gen1+)
# Credit : The Voyager
resetprop -n persist.vendor.qcom.bluetooth.aptxadaptiver2_2_support true