#!/system/bin/sh
MODDIR="${0%/*}"

####################################
# Functions
####################################
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

write() {
    local file="$1"
    shift
    [ -f "$file" ] && echo "$@" > "$file" 2>/dev/null
}


# $1:value $2:path
lock_val() {
    find "$2" -type f | while read -r file; do
        file="$(realpath "$file")"
        umount "$file"
        chmod +w "$file"
        echo "$1" >"$file"
        chmod -w "$file"
    done
}


lock_val_in_path() {
    if [ "$#" = "4" ]; then
        find "$2/" -path "*$3*" -name "$4" -type f | while read -r file; do
            lock_val "$1" "$file"
        done
    else
        find "$2/" -name "$3" -type f | while read -r file; do
            lock_val "$1" "$file"
        done
    fi
}

####################################
# Script Start
####################################
wait_until_login
sleep 30

debug_name="
*log_level*
*debug_level*
reglog_enable
*log_ue*
*log_ce*
enable_event_log
snapshot_crashdumper
tracing_on
*log_lvl
klog_lvl
ipc_log_lvl
log_level_sel
stats_enabled
debug_output
enable*dump*
reg_dump_option
pm_suspend_clk_dump
evtlog_dump
reg_dump_blk_mask
dump_mode
backlight_log
trace_printk
start*dump*
rcu_cpu_stall_ftrace_dump
logging_level
exception-trace
bpf_stats_enabled
ftrace_dump_on_oops
sched_schedstats
tracepoint_printk
traceoff_on_warning
oom_dump_tasks
migt_sched_debug
desc_option
logging_option
millet_debug
*log*mask
minidump_enable
doublecyc_debug
msm_vidc_fw_dump
cpas_dump
enable_bugon
suid_dumpable
nf_conntrack_log_invalid
nf_log_all_netns
*cpu_backtrace
mb_stats
compat-log
debug_mask
*debug_mode
enable_pkg_monitor
load_debug
fboost_debug
link_debug
metis_debug
tsched_debug
flw_debug
game_link_debug
migt_debug
stack_tracer_enabled"

#Fallback method
for i in $debug_name; do
    for o in $(find /sys/ /proc/sys -type f -name "$i" 2>/dev/null); do
        val=$(cat "$o" 2>/dev/null)
        
        case "$val" in
            "1")
                write "$o" "0"
                ;;
            "Y")
                write "$o" "N"
                ;;
            "enabled")
                write "$o" "disabled"
                ;;
            "on")
                write "$o" "off"
                ;;
            *)
                # Check if purely numeric (fallback regex using grep)
                if echo "$val" | grep -qE '^[0-9]+$'; then
                    write "$o" "0"
                fi
                ;;
        esac
    done
done

# Checks
# for i in $debug_name; do
#     for o in $(find /sys/ /proc/sys -type f -name "$i" 2>/dev/null); do
#         echo "$o $(cat $o)"
#     done
# done

debug_list_1="/sys/kernel/debug/dri/0/debug/enable
/kernel/debug/sde_rotator0/evtlog/enable
/sys/kernel/debug/kgsl/kgsl-3d0/profiling/enable
/sys/kernel/debug/kprobes/enabled
/sys/kernel/tracing/events/bpf_trace/bpf_trace_printk/enable
/sys/kernel/debug/tracing/events/bpf_trace/bpf_trace_printk/enable
/proc/sys/kernel/print-fatal-signals
/sys/kernel/debug/debug_enabled
/sys/kernel/debug/soc:qcom,pmic_glink_log/enable
/sys/module/kernel/parameters/initcall_debug
/sys/module/kiwi_v2/parameters/qdf_log_dump_at_kernel_enable
/sys/module/msm_drm/parameters/reglog
/sys/module/msm_drm/parameters/dumpstate
/sys/module/blk_cgroup/parameters/blkcg_debug_stats
/sys/kernel/debug/camera/smmu/cb_dump_enable
/sys/kernel/debug/camera/ife/enable_req_dump
/sys/kernel/debug/camera/smmu/map_profile_enable
/sys/kernel/debug/camera/memmgr/alloc_profile_enable
/sys/module/rcutree/parameters/dump_tree
/sys/kernel/debug/camera/cpas/full_state_dump
/sys/kernel/debug/camera/ife/per_req_reg_dump
/sys/kernel/debug/camera/cpas/smart_qos_dump
/sys/kernel/debug/mi_display/debug_log
/sys/module/ip6_tunnel/parameters/log_ecn_error
/sys/kernel/debug/dri/0/debug/reglog_enable
/sys/kernel/debug/msm_cvp/debug_level
/sys/kernel/debug/tracing/events/enable
/sys/kernel/tracing/events/enable"

#Fallback Method
for path in $debug_list_1; do
    if [ -f "$path" ]; then
        val=$(cat "$path" 2>/dev/null)

        case "$val" in
            "1")
                write "$path" "0"
                ;;
            "Y")
                write "$path" "N"
                ;;
            "enabled")
                write "$path" "disabled"
                ;;
            "on")
                write "$path" "off"
                ;;
            *)
                if echo "$val" | grep -qE '^[0-9]+$'; then
                    write "$path" "0"
                fi
                ;;
        esac
    fi
done

# Checks
# for path in $debug_list_1; do
#     echo "$path $(cat $path)"
# done

####################################
# Misc
####################################
#core
write "/proc/sys/kernel/core_pattern" ""

# Event Tracing
write "/sys/kernel/debug/tracing/set_event" ""

# PERF Monitoring
write "/proc/sys/kernel/perf_cpu_time_max_percent" "0"

for coredump in /sys/kernel/debug/remoteproc/remoteproc*/coredump; do
    write "$coredump" "disabled"
done

# Spurious Debug
write "/sys/module/spurious/parameters/noirqdebug" "Y" 

# Audit Log (Not recommended for security concerns)
# write "/sys/module/lsm_audit/parameters/disable_audit_log" "1"

# va-minidump
for minidump in /sys/kernel/va-minidump/*/enable; do
    write "$minidump" "0"
done

# Transparent Hugepage
# https://blog.csdn.net/hbuxiaofei/article/details/128402495
write "/sys/kernel/mm/transparent_hugepage/enabled" "never"

# Bluetooth
# Lower BT Performance but Lower Power Consumption
write "/sys/module/bluetooth/parameters/disable_ertm" "Y"

# Lower the latency but might affect buffering (audio glitches)
write "/sys/module/bluetooth/parameters/disable_esco" "Y"

# Disable not so useful modules
write "/sys/module/cryptomgr/parameters/notests" "Y"

####################################
# Printk
####################################
write "/proc/sys/kernel/printk" "0 0 0 0"
write "/proc/sys/kernel/printk_delay" "0"
write "/proc/sys/kernel/printk_devkmsg" "off"
write "/proc/sys/kernel/printk_ratelimit" "5" # seconds
write "/proc/sys/kernel/printk_ratelimit_burst" "1" # message count
write "/proc/sys/kernel/tracepoint_printk" "0"
write "/sys/module/printk/parameters/always_kmsg_dump" "N"
write "/sys/module/printk/parameters/console_no_auto_verbose" "Y"
write "/sys/module/printk/parameters/time" "0"
write "/sys/module/printk/parameters/console_suspend" "1"
write "/sys/module/printk/parameters/ignore_loglevel" "1"

####################################
# Performance Tuning
####################################
# Docs : https://blog.xzr.moe/archives/15/#section-24

# Vendor Specific Tuning
# Qualcomm Tuning
if [ "$(getprop ro.hardware)" = "qcom" ]; then 
    # KGSL Tuning & GPU Tuning(GPU)
    lock_val "2147483647" /sys/class/devfreq/*kgsl-3d0/max_freq
    lock_val "0" /sys/class/devfreq/*kgsl-3d0/min_freq
    lock_val "0" /sys/class/kgsl/kgsl-3d0/force_bus_on
    lock_val "0" /sys/class/kgsl/kgsl-3d0/force_clk_on
    lock_val "0" /sys/class/kgsl/kgsl-3d0/force_no_nap
    lock_val "0" /sys/class/kgsl/kgsl-3d0/force_rail_on
    lock_val "0" /sys/class/kgsl/kgsl-3d0/bus_split
    lock_val "0" /sys/class/kgsl/kgsl-3d0/popp
    lock_val "0" /sys/class/kgsl/kgsl-3d0/bcl
    # lock_val "100" /sys/class/kgsl/kgsl-3d0/devfreq/mod_percent
    lock_val "0" /sys/class/kgsl/kgsl-3d0/preemption # might give slight overhead

    lock_val "2147483647" /sys/kernel/gpu/gpu_max_clock
    lock_val "0" /sys/kernel/gpu/gpu_min_clock

    # RCU Tuning
    # https://www.kernel.org/doc/Documentation/RCU/Design/Expedited-Grace-Periods/Expedited-Grace-Periods.html
    write "/sys/kernel/rcu_expedited" "0"

    # PELT Multiplier
    lock_val "4" "/proc/sys/kernel/sched_pelt_multiplier"

    # Enable LPM for all CPUs
    for disable in $(find /sys/devices/system/cpu/qcom_lpm -type f -name '*disable*'); do
        write "$disable" "0"
    done

    # BUS Performance Control 
    BUS_DCVS="/sys/devices/system/cpu/bus_dcvs"
    lock_val_in_path "2147483647" "$BUS_DCVS/DDR" "max_freq"
    lock_val_in_path "2147483647" "$BUS_DCVS/L3" "max_freq"
    lock_val_in_path "2147483647" "$BUS_DCVS/DDRQOS" "max_freq"
    lock_val_in_path "0" "$BUS_DCVS" "min_freq"
    lock_val_in_path "0" "$BUS_DCVS" "boost_freq"
    lock_val "1" "$BUS_DCVS/DDRQOS/boost_freq"
else 
#Mediatek Tuning
    write  "/sys/kernel/ged/hal/custom_upbound_gpu_freq" "0"
    write  "/sys/module/ged/parameters/is_GED_KPI_enabled" "1"
    write  "/sys/module/mtk_core_ctl/parameters/policy_enable" "0"
    lock_val "0" "/sys/kernel/ged/hal/dcs_mode"
fi

# WALT
if [ -d /proc/sys/walt/ ]; then

    # WALT disable boost
    for i in /proc/sys/walt/input_boost/* ; do
        write "$i" "0"
    done

    for i in /sys/devices/system/cpu/cpu*/cpufreq/walt/boost ; do
        write "$i" "0" 
    done

    write "/proc/sys/walt/input_boost/powerkey_input_boost_ms" "0"
    write "/proc/sys/walt/input_boost/input_boost_ms" "0"
    write "/proc/sys/walt/sched_boost" "0"
    write "/proc/sys/walt/sched_ed_boost" "0"
    write "/proc/sys/walt/sched_asymcap_boost" "0"
    write "/proc/sys/walt/input_boost/input_boost_freq" "0 0 0 0 0 0 0 0"

    # Conservative Predict Load
    write "/proc/sys/walt/sched_conservative_pl" "1"

    # Check WINDOW_STATS_RECENT | WINDOW_STATS_MAX | WINDOW_STATS_MAX_RECENT_AVG | WINDOW_STATS_AVG
    write "/proc/sys/walt/sched_window_stats_policy" "0"
    
    lock_val "99" "/proc/sys/walt/walt_rtg_cfs_boost_prio" #99=disabled
    # write "/proc/sys/walt/walt_low_latency_task_threshold" "0"

    # task
    # write "/proc/sys/walt/sched_task_unfilter_period" "20000000"
    write "/proc/sys/walt/sched_min_task_util_for_boost"  "51"
    write "/proc/sys/walt/sched_min_task_util_for_colocation"  "35"
    write "/proc/sys/walt/sched_downmigrate" "50 70"
    write "/proc/sys/walt/sched_upmigrate" "50 90"

    # Reduce the time to consider an idle
    write "/proc/sys/walt/sched_idle_enough" "10"
else

# Schedutil config based in this patch: 
# https://patchwork.kernel.org/project/linux-pm/patch/c6248ec9475117a1d6c9ff9aafa8894f6574a82f.1479359903.git.viresh.kumar@linaro.org/
    for i in /sys/devices/system/cpu/cpu*/cpufreq/schedutil/up_rate_limit_us ; do
        write $i "10000"
    done
    for i in /sys/devices/system/cpu/cpu*/cpufreq/schedutil/down_rate_limit_us ; do
        write $i "10000"
    done
fi

# Round Robin Timeslice
write "/proc/sys/kernel/sched_rr_timeslice_ms" "4"

# Boost and up down rate limits
write "/sys/devices/system/cpu/cpufreq/boost" "0"
# lock_val_in_path "10000" "/sys/devices/system/cpu/cpufreq" "up_rate_limit_us"
# lock_val_in_path "10000" "/sys/devices/system/cpu/cpufreq" "down_rate_limit_us"

####################################
# CPUSETS & IRQ
####################################

get_cpu_list_by_cluster() {
    local cluster_id="$1"
    for cpu in /sys/devices/system/cpu/cpu[0-9]*; do
        if [[ -f "$cpu/topology/physical_package_id" ]]; then
            cid="$(cat "$cpu/topology/physical_package_id")"
            if [ "$cid" == "$cluster_id" ]; then
                echo "${cpu##*/cpu}"
            fi
        fi
    done | sort -n | paste -sd,
}

LITTLE_LIST="$(get_cpu_list_by_cluster 0)"
BIG_LIST="$(get_cpu_list_by_cluster 1)"
PRIME_LIST="$(get_cpu_list_by_cluster 2)"
ALL_LIST="$(cat /sys/devices/system/cpu/present)"

# pkill -f irqbalance

lock_val "$LITTLE_LIST" "/dev/cpuset/background/cpus"
lock_val "$LITTLE_LIST" "/dev/cpuset/system-background/cpus"
lock_val "$LITTLE_LIST,$BIG_LIST" "/dev/cpuset/foreground/cpus"
lock_val "$ALL_LIST" "/dev/cpuset/top-app/cpus"
lock_val "$LITTLE_LIST" /proc/irq/default_smp_affinity
lock_val_in_path "$LITTLE_LIST" "/proc/irq" "smp_affinity_list"


####################################
# Xiaomi Tuning
####################################
write "/proc/sys/migt/enable_pkg_monitor" "0"
write "/sys/module/migt/parameters/enable_pkg_monitor" "0"
write "/sys/module/migt/parameters/glk_freq_limit_walt" "0"
write "/sys/module/metis/parameters/cluaff_control" "0"
write "/sys/module/mist/parameters/dflt_bw_enable" "0" 
write "/sys/module/mist/parameters/dflt_lat_enable" "0" 
write "/sys/module/mist/parameters/dflt_ddr_boost" "0" 
write "/sys/module/mist/parameters/gflt_enable" "0" 
write "/sys/module/mist/parameters/mist_memlat_vote_enable" "0" 

write "/proc/package/stat/pause_mode" "1"

write "/sys/module/migt/parameters/boost_policy" "0"
write "/sys/module/migt/parameters/cpu_boost_cycle" "0"
write "/sys/module/migt/parameters/glk_disable" "1"
write "/sys/module/migt/parameters/sysctl_boost_stask_to_big" "0"
write "/sys/module/migt/parameters/force_stask_to_big" "0"
write "/sys/module/migt/parameters/flw_enable" "0"
write "/sys/module/migt/parameters/flw_freq_enable" "0"

write "/sys/module/metis/parameters/user_min_freq" "0,0,0"
write "/sys/module/metis/parameters/min_cluster_freqs" "0,0,0"
write "/sys/module/metis/parameters/is_link_enable" "0"
write "/sys/module/metis/parameters/limit_bgtask_sched" "1"
write "/sys/module/metis/parameters/mi_fboost_enable" "0"
write "/sys/module/metis/parameters/mi_freq_enable" "0"
write "/sys/module/metis/parameters/mi_link_enable" "0"
write "/sys/module/metis/parameters/mi_switch_enable" "0"
write "/sys/module/metis/parameters/mi_viptask" "0"
write "/sys/module/metis/parameters/mpc_fboost_enable" "0"
write "/sys/module/metis/parameters/vip_link_enable" "0"
write "/sys/module/metis/parameters/bug_detect" "0"
write "/sys/module/metis/parameters/suspend_vip_enable" "0"
write "/sys/module/metis/parameters/sched_doctor_enable" "0"
####################################
# IO Tuning
####################################
# Docs:
# 1. https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/8/html/monitoring_and_managing_system_status_and_performance/factors-affecting-i-o-and-file-system-performance_monitoring-and-managing-system-status-and-performance#generic-block-device-tuning-parameters_factors-affecting-i-o-and-file-system-performance
# 2. https://brendangregg.com/blog/2015-03-03/performance-tuning-linux-instances-on-ec2.html
# 3. https://blog.csdn.net/yiyeguzhou100/article/details/100068115
# 4. https://github.com/chbatey/tobert.github.io/blob/c98e69267d84aea557e8f6e9bdc62c0d305b7454/src/pages/cassandra_tuning_guide.md?plain=1#L1090
# 5. https://github.com/torvalds/linux/commit/488991e28e55b4fbca8067edf0259f69d1a6f92c
# 6. https://zhuanlan.zhihu.com/p/346966856
for io in /sys/block/* /sys/devices/virtual/block/*; do
    # nomerges
    # Why not disable? Disabling merging (nomerges=1 or 2) might seem like it removes kernel overhead
    # but it typically floods the UFS controller with numerous tiny requests. 
    # This can lead to increased CPU usage from more frequent interrupts and command processing
    # ultimately increasing overall overhead and potentially degrading performance and battery life for general use.
    write "$io/queue/nomerges" "0"

    # lock_val "none" "$sd/queue/scheduler" # (use xiaomi cpq, which introduce in smartfocusio in props)

    write "$io/queue/io_poll" "0"
    write "$io/queue/add_random" "0"
    write "$io/queue/iostats" "0"


    # NAND Flash don't need scheduler, use none for better battery life
    write "$io/queue/scheduler" "none"

    # write "$io/queue/read_ahead_kb" "128"
    # write "$io/bdi/read_ahead_kb" "128"
    # write "$io/queue/iosched/front_merges" "1"
    # write "$sd/queue/iosched/writes_starved" "1"
    # write "$sd/queue/iosched/write_expire" "3000"

    # RQ_AFFINITY
    # Higher values will force scheduler requests complete on initiated core
    # This can reduce latency and improve performance for workloads that benefit from CPU affinity.
    # However, it can also lead to suboptimal CPU utilization and increased context switching.
    # Setting it to 1 is a good balance for most workloads, as it allows some flexibility while still maintaining a degree of CPU affinity.
    # Setting it to 0 can lead to better CPU utilization in scenarios where tasks are distributed across multiple cores.
    # However, it can also increase the likelihood of context switching, which can reduce performance and battery life.
    write "$io/rq_affinity" "1"
done


####################################
# VM Tunables
####################################

# This can help reduce the frequency of statistics updates and improve performance for workloads that benefit from less frequent updates.
# However, it can also increase the latency of statistics reporting and reduce the accuracy of the statistics.
write "/proc/sys/vm/stat_interval" "60"

# Swappiness
# Higher means more aggressive swapping, lower means less aggressive swapping.
write "/proc/sys/vm/swappiness" "60"

# Page-Cluster
# This parameter controls the number of pages that are reclaimed in a single operation.
# Lower value : More aggressive swapping
# Higher value : Less aggressive swapping
# value is in 2^n pages, so 0 means 1 page, 1 means 2 pages, 2 means 4 pages, etc.
write "/proc/sys/vm/page-cluster" "3"

# Vfs Cache Pressure
write "/proc/sys/vm/vfs_cache_pressure" "80"

# Dirty Settings
write "/proc/sys/vm/dirty_ratio" "5"
write "/proc/sys/vm/dirty_background_ratio" "3"
write "/proc/sys/vm/dirty_expire_centisecs" "3000"
write "/proc/sys/vm/dirty_writeback_centisecs" "3000"

lock_val "Y" "/sys/kernel/mm/lru_gen/enabled"
lock_val "1000" "/sys/kernel/mm/lru_gen/min_ttl_ms"



####################################
# Kernel Parameters
####################################

# # Enable Power Efficient WQ
write "/sys/module/workqueue/parameters/power_efficient" "Y"

# never enable this unless you need to really reduce the latency
# write "/proc/sys/kernel/sched_child_runs_first" "0"

# This parameter controls whether timer interrupts can be migrated between CPU cores
# https://blog.csdn.net/qq_33471732/article/details/144695236

# Enabling timer migration can help reduce latency and improve performance for workloads that benefit from more efficient timer handling.
# However, it can also increase the overhead of timer handling and reduce overall performance for workloads that do not benefit from timer migration.
# Setting it to 1 is a good balance for most workloads
# as it allows for more efficient timer handling while still maintaining a degree of flexibility.
# Setting it to 0 can lead to better performance in scenarios where timer migration is not beneficial
# but it can also increase latency and reduce overall performance for workloads that benefit from timer migration.
write "/proc/sys/kernel/timer_migration" "1"

# Energy Aware
write "/proc/sys/kernel/sched_energy_aware" "1"

#Boeffla Wakelock
wakelock_list="enable_wlan_ws;enable_wlan_wow_wl_ws;enable_wlan_extscan_wl_ws;wlan_pno_wl;wlan_ipa;wcnss_filter_lock;hal_bluetooth_lock;IPA_WS;sensor_ind;wlan;netmgr_wl;qcom_rx_wakelock;enable_qcom_rx_wakelock_ws;wlan_wow_wl;wlan_extscan_wl;NETLINK;bam_dmux_wakelock;IPA_RM12;wlan;SensorService_wakelock;tftp_server_wakelock;enable_timerfd_ws;[timerfd];enable_netmgr_wl_ws;enable_netlink_ws;enable_ipa_ws;"
write "/sys/devices/virtual/misc/boeffla_wakelock_blocker/wakelock_blocker" "$wakelock_list"
write "/sys/class/misc/boeffla_wakelock_blocker/wakelock_blocker" "$wakelock_list"

####################################
# Network Tuning
####################################

write "/proc/sys/net/ipv4/tcp_slow_start_after_idle" "0"
write "/proc/sys/net/ipv4/tcp_tw_reuse" "1"
write "/proc/sys/net/ipv4/tcp_no_metrics_save" "1"

# Enable this unless you want to get vulnerable to attacks (especially the ones without networking knowledge)
write "/proc/sys/net/ipv4/ip_forward" "0"

####################################
# Kill and Stop Services
####################################

sleep 3 
process="charge_logger
logcat
logd
statsd
traced
traced_probes
tombstoned
update_engine
vendor.cnss_diag
vendor.tcpdump
miuibooster
perfservice
mimd-service2_0
vendor.xiaomi.aidl.minet
minetd
misight
vendor.atrace-hal-1-0
vendor.perfservice
vendor.qesdk-mgr
vendor.servicetracker-1-2
cnss-daemon
mimd-service"

for name in $process; do
    stop "$name" 2>/dev/null
    pkill -f "$name" 2>/dev/null
done

#vendor.xiaomi.aidl.miwill

####################################
# SHUT UP !!! LOGTAGS !!!
####################################

resetprop -n log.tag.AF::MmapTrack S
resetprop -n log.tag.AF::OutputTrack S
resetprop -n log.tag.AF::PatchRecord S
resetprop -n log.tag.AF::PatchTrack S
resetprop -n log.tag.AF::RecordHandle S
resetprop -n log.tag.AF::RecordTrack S
resetprop -n log.tag.AF::Track S
resetprop -n log.tag.AF::TrackBase S
resetprop -n log.tag.AF::TrackHandle S
resetprop -n log.tag.APM::AudioCollections S
resetprop -n log.tag.APM::AudioInputDescriptor S
resetprop -n log.tag.APM::AudioOutputDescriptor S
resetprop -n log.tag.APM::AudioPatch S
resetprop -n log.tag.APM::AudioPolicyEngine S
resetprop -n log.tag.APM::AudioPolicyEngine::Base S
resetprop -n log.tag.APM::AudioPolicyEngine::Config S
resetprop -n log.tag.APM::AudioPolicyEngine::ProductStrategy S
resetprop -n log.tag.APM::AudioPolicyEngine::VolumeGroup S
resetprop -n log.tag.APM::Devices S
resetprop -n log.tag.APM::IOProfile S
resetprop -n log.tag.APM::Serializer S
resetprop -n log.tag.APM::VolumeCurve S
resetprop -n log.tag.APM_AudioPolicyManager S
resetprop -n log.tag.APM_ClientDescriptor S
resetprop -n log.tag.AudioAttributes S
resetprop -n log.tag.AudioEffect S
resetprop -n log.tag.AudioFlinger S
resetprop -n log.tag.AudioFlinger::DeviceEffectProxy S
resetprop -n log.tag.AudioFlinger::DeviceEffectProxy::ProxyCallback S
resetprop -n log.tag.AudioFlinger::EffectBase S
resetprop -n log.tag.AudioFlinger::EffectChain S
resetprop -n log.tag.AudioFlinger::EffectHandle S
resetprop -n log.tag.AudioFlinger::EffectModule S
resetprop -n log.tag.AudioFlingerImpl S
resetprop -n log.tag.AudioFlinger_Threads S
resetprop -n log.tag.AudioHwDevice S
resetprop -n log.tag.AudioPolicy S
resetprop -n log.tag.AudioPolicyEffects S
resetprop -n log.tag.AudioPolicyIntefaceImpl S
resetprop -n log.tag.AudioPolicyManagerImpl S
resetprop -n log.tag.AudioPolicyService S
resetprop -n log.tag.AudioProductStrategy S
resetprop -n log.tag.AudioRecord S
resetprop -n log.tag.AudioSystem S
resetprop -n log.tag.AudioTrack S
resetprop -n log.tag.AudioTrackImpl S
resetprop -n log.tag.AudioTrackShared S
resetprop -n log.tag.AudioVolumeGroup S
resetprop -n log.tag.FastCapture S
resetprop -n log.tag.FastMixer S
resetprop -n log.tag.FastMixerState S
resetprop -n log.tag.FastThread S
resetprop -n log.tag.IAudioFlinger S
resetprop -n log.tag.ToneGenerator S

# Other Props
resetprop -n events.cpu false

# This likely refers to trace options or trace optimization
resetprop -n persist.sys.traceopt 0

# WiFi Tracing
resetprop sys.wifitracing.started 0

exit

#killing "mi_thermald" will cause fast-charging malfunctioned