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

normalize_toggle() {
    case "$1" in
        "1") echo "0" ;;
        "Y") echo "N" ;;
        "enabled") echo "disabled" ;;
        "on") echo "off" ;;
        *)
            if echo "$1" | grep -qE '^[0-9]+$'; then
                echo "0"
            else
                return 1
            fi
            ;;
    esac
}

apply_toggle() {
    local path="$1"
    [ -f "$path" ] || return 0

    local val new_val
    val=$(cat "$path" 2>/dev/null) || return 0
    new_val=$(normalize_toggle "$val") || return 0
    write "$path" "$new_val"
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

# Scan sysfs/procfs once instead of walking the full tree for every pattern.
find /sys /proc/sys -type f 2>/dev/null | while read -r path; do
    base="${path##*/}"
    for pattern in $debug_name; do
        case "$base" in
            $pattern)
                apply_toggle "$path"
                break
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
    apply_toggle "$path"
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
write "/sys/module/printk/parameters/ignore_loglevel" "0"

####################################
# Performance Tuning
####################################
# Docs : https://blog.xzr.moe/archives/15/#section-24

# Vendor Specific Tuning
# Qualcomm Tuning
if [ "$(getprop ro.hardware)" = "qcom" ]; then 
    BUS_DCVS="/sys/devices/system/cpu/bus_dcvs"

    # KGSL Tuning & GPU Tuning(GPU)
    # lock_val "2147483647" /sys/class/devfreq/*kgsl-3d0/max_freq
    lock_val "0" /sys/class/devfreq/*kgsl-3d0/min_freq
    lock_val "0" /sys/class/kgsl/kgsl-3d0/force_bus_on
    lock_val "0" /sys/class/kgsl/kgsl-3d0/force_clk_on
    lock_val "0" /sys/class/kgsl/kgsl-3d0/force_no_nap
    lock_val "0" /sys/class/kgsl/kgsl-3d0/force_rail_on
    # Heuristic and kernel-specific; leave disabled unless validated on target devices.
    # lock_val "0" /sys/class/kgsl/kgsl-3d0/bus_split
    lock_val "0" /sys/class/kgsl/kgsl-3d0/popp
    lock_val "0" /sys/class/kgsl/kgsl-3d0/bcl
    # lock_val "100" /sys/class/kgsl/kgsl-3d0/devfreq/mod_percent
    # Heuristic and kernel-specific; leave disabled unless validated on target devices.
    # lock_val "0" /sys/class/kgsl/kgsl-3d0/preemption
    # Heuristic and workload-sensitive; avoid forcing a global idle timer.
    # lock_val "30" /sys/class/kgsl/kgsl-3d0/idle_timer

    # lock_val "2147483647" /sys/kernel/gpu/gpu_max_clock
    lock_val "0" /sys/kernel/gpu/gpu_min_clock

    # RCU Tuning
    # https://www.kernel.org/doc/Documentation/RCU/Design/Expedited-Grace-Periods/Expedited-Grace-Periods.html
    write "/sys/kernel/rcu_expedited" "0"

    # PELT Multiplier
    # lock_val "4" "/proc/sys/kernel/sched_pelt_multiplier"

    # Enable LPM for all CPUs
    # qcom_lpm controls Qualcomm idle / cluster power-state entry. Forcing
    # these disables to 0 prefers allowing deeper idle states.
    for disable in $(find /sys/devices/system/cpu/qcom_lpm -type f -name '*disable*'); do
        write "$disable" "0"
    done

    # BUS Performance Control
    # bus_dcvs is Qualcomm DDR/L3 bandwidth + memlat scaling, not plain CPU
    # frequency control. Forcing it aggressively is device-sensitive, so only
    # light-touch tuning is left active here.
    # lock_val_in_path "2147483647" "$BUS_DCVS/DDR" "max_freq"
    # lock_val_in_path "2147483647" "$BUS_DCVS/L3" "max_freq"
    # Heuristic and platform-specific; avoid forcing DDRQOS nodes globally.
    # if [ -d "$BUS_DCVS/DDRQOS" ]; then
    #     lock_val_in_path "1" "$BUS_DCVS/DDRQOS" "max_freq"
    #     lock_val_in_path "1" "$BUS_DCVS/DDRQOS" "min_freq"
    #     lock_val "1" "$BUS_DCVS/DDRQOS/boost_freq"
    # fi


    lock_val_in_path "0" "/sys/devices/system/cpu/cpufreq" "hispeed_freq"
    lock_val_in_path "0" "/sys/devices/system/cpu/cpufreq" "rtg_boost_freq"
    lock_val_in_path "1000" "/sys/devices/system/cpu/cpufreq" "up_rate_limit_us"
    lock_val_in_path "1000" "/sys/devices/system/cpu/cpufreq" "down_rate_limit_us"

else 
#Mediatek Tuning
    write  "/sys/kernel/ged/hal/custom_upbound_gpu_freq" "0"
    write  "/sys/module/ged/parameters/is_GED_KPI_enabled" "1"
    write  "/sys/module/mtk_core_ctl/parameters/policy_enable" "0"
    lock_val "0" "/sys/kernel/ged/hal/dcs_mode"
    write "/proc/mtk_lpm/cpuidle/enable" "1"
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

    # Extra battery-biased WALT policy. Keep this limited to generic scheduler
    # hints and avoid the more aggressive per-task boost knobs.
    write "/proc/sys/walt/sched_sync_hint_enable" "0"
    # On fuxi these two remain at 1 0 after a clean reflash, so treat them as
    # ineffective in this module context unless a device-specific method is
    # proven.
    # The same applies to sched_wake_up_idle, which stayed at 1 0 after test.
    # write "/proc/sys/walt/sched_wake_up_idle" "0 0"
    # write "/proc/sys/walt/sched_low_latency" "0 0"
    # write "/proc/sys/walt/sched_pipeline" "0 0"

    write /proc/sys/walt/sched_pipeline_special "0"
else

# Schedutil config based in this patch: 
# https://patchwork.kernel.org/project/linux-pm/patch/c6248ec9475117a1d6c9ff9aafa8894f6574a82f.1479359903.git.viresh.kumar@linaro.org/
    for i in /sys/devices/system/cpu/cpu*/cpufreq/schedutil/up_rate_limit_us ; do
        write $i "1000"
    done
    for i in /sys/devices/system/cpu/cpu*/cpufreq/schedutil/down_rate_limit_us ; do
        write $i "1000"
    done
fi

# Round Robin Timeslice
# write "/proc/sys/kernel/sched_rr_timeslice_ms" "4"

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


# /sys/devices/system/cpu/cpu*/cpuidle/state*/disable to 0
# /sys/module/lpm_levels/parameters/sleep_disabled

####################################
# Xiaomi Tuning
####################################
# migt and metis are Xiaomi vendor scheduler / boost layers. These are among
# the highest-risk smoothness knobs in the module because they influence task
# placement, foreground boosting, and render-thread promotion.
write "/proc/sys/migt/enable_pkg_monitor" "0"
write "/sys/module/migt/parameters/enable_pkg_monitor" "0"
write "/sys/module/migt/parameters/glk_freq_limit_walt" "0"
write "/sys/module/metis/parameters/cluaff_control" "0"
# mist is absent on fuxi, so these writes are harmless no-ops on this device.
write "/sys/module/mist/parameters/dflt_bw_enable" "0" 
write "/sys/module/mist/parameters/dflt_lat_enable" "0" 
write "/sys/module/mist/parameters/dflt_ddr_boost" "0" 
write "/sys/module/mist/parameters/gflt_enable" "0" 
write "/sys/module/mist/parameters/mist_memlat_vote_enable" "0" 

# Xiaomi package/stat looks like vendor stats / tracing control rather than a
# primary performance path. Low risk compared with migt/metis.
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
for io in /sys/block/* ; do
    block="${io##*/}"

    # nomerges
    # Why not disable? Disabling merging (nomerges=1 or 2) might seem like it removes kernel overhead
    # but it typically floods the UFS controller with numerous tiny requests. 
    # This can lead to increased CPU usage from more frequent interrupts and command processing
    # ultimately increasing overall overhead and potentially degrading performance and battery life for general use.
    write "$io/queue/io_poll" "0"
    write "$io/queue/add_random" "0"
 
    case "$block" in
        sd*|mmcblk*|nvme*)
            # Physical block devices benefit from request merging and can keep iostats.
            write "$io/queue/nomerges" "0"
            write "$io/queue/iostats" "1"
            write "$io/queue/rq_affinity" "1"
            ;;
        dm-*|loop*|zram*|ram*|mtdblock*)
            # Virtual / translated devices do not benefit from merges or iostats.
            write "$io/queue/nomerges" "2"
            write "$io/queue/iostats" "0"
            write "$io/queue/rq_affinity" "0"
            ;;
        *)
            # Default to the conservative physical-device behavior for unknown block types.
            write "$io/queue/nomerges" "0"
            write "$io/queue/iostats" "1"
            write "$io/queue/rq_affinity" "1"
            ;;
    esac

    # write "$io/queue/read_ahead_kb" "128"
    # write "$io/bdi/read_ahead_kb" "128"
    # write "$io/queue/iosched/front_merges" "1"
    # write "$sd/queue/iosched/writes_starved" "1"
    # write "$sd/queue/iosched/write_expire" "3000"

done

####################################
# VM Tunables
####################################

# This can help reduce the frequency of statistics updates and improve performance for workloads that benefit from less frequent updates.
# However, it can also increase the latency of statistics reporting and reduce the accuracy of the statistics.
write "/proc/sys/vm/stat_interval" "60"

# Swappiness
# Higher means more aggressive swapping, lower means less aggressive swapping.
write "/proc/sys/vm/swappiness" "40"

# Page-Cluster
# This parameter controls the number of pages that are reclaimed in a single operation.
# Lower value : More aggressive swapping
# Higher value : Less aggressive swapping
# value is in 2^n pages, so 0 means 1 page, 1 means 2 pages, 2 means 4 pages, etc.
write "/proc/sys/vm/page-cluster" "3"

# Vfs Cache Pressure
write "/proc/sys/vm/vfs_cache_pressure" "80"

# Dirty Settings
write "/proc/sys/vm/dirty_ratio" "14"
write "/proc/sys/vm/dirty_background_ratio" "6"
write "/proc/sys/vm/dirty_expire_centisecs" "2000"
write "/proc/sys/vm/dirty_writeback_centisecs" "3000"
write "/proc/sys/vm/dirtytime_expire_seconds"  "43200"

lock_val "7" "/sys/kernel/mm/lru_gen/enabled"
# lock_val "1000" "/sys/kernel/mm/lru_gen/min_ttl_ms"



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

# Prefer the deeper suspend backend when the kernel exposes it.
# Revert this first if you see delayed wake, missed notifications, or suspend instability.
write "/sys/power/mem_sleep" "deep"

####################################
# Network Tuning
####################################

write "/proc/sys/net/ipv4/tcp_slow_start_after_idle" "0"
write "/proc/sys/net/ipv4/tcp_tw_reuse" "1"
write "/proc/sys/net/ipv4/tcp_no_metrics_save" "1"

# Enable this if you want to get vulnerable to attacks (especially the ones without networking knowledge)
write "/proc/sys/net/ipv4/ip_forward" "0"

####################################
# Kill and Stop Services
####################################

kill_services_once() {
    for name in $1; do
        stop "$name" 2>/dev/null
        pkill -f "$name" 2>/dev/null
    done
}

suppress_dynamic_logtags() {
    local round tag
    round=0

    while [ "$round" -lt 90 ]; do
        logcat -d -v brief 2>/dev/null \
            | sed -n 's#^[VDIWEF]/\([^(: ]*\).*#\1#p' \
            | grep -E '^(RectFSpringAnim_[0-9]+|MultiSpringDynamicAnimation[0-9a-f]+|WindowElement[0-9a-f]+|VRI\[[^]]+\]|MediaSyncManager_[0-9]+_[0-9]+|VolumePanelViewController_(true|false)|TimeTracker_[0-9]+_[0-9]+|TimeTracker_[0-9]+|NavStubViewcom\..*|TaskViewThumbnail_[0-9]+|WindowElement[0-9A-Fa-f]+)$' \
            | sort -u \
            | while read -r tag; do
                [ -n "$tag" ] && resetprop -n "log.tag.$tag" S
            done

        sleep 10
        round=$((round + 1))
    done
}

# Default: logging / diagnostics / tracing suppression.
default_services="charge_logger
vendor.tcpdump
vendor.atrace-hal-1-0"

# Optional:
# incidentd
# mediametrics
# vendor.mi_misight
# vendor.diag.tcpdump
# qlogd
# qseelogd
# logcatlog
# bootlog

# Experimental:
# qadaemon
# misight
# vendor.xiaomi.hardware.misight.service

# One pass after boot settle, then a few retries for services that tend to respawn.
sleep 10
kill_services_once "$default_services"

retry_round=0
while [ "$retry_round" -lt 6 ]; do
    sleep 20
    kill_services_once "$default_services"
    retry_round=$((retry_round + 1))
done

####################################
# SHUT UP !!! LOGTAGS !!!
####################################
# Keep broad platform tags visible enough for future debugging.
# Suppress vendor/UI spam first; avoid muting core Android tags unless the
# tag is consistently useless on this device.
resetprop -n log.tag.HWComposer S
resetprop -n log.tag.HWC2On1Adapter S
resetprop -n log.tag.SDM S
resetprop -n log.tag.vendor.qti.hardware.display.composer-service S
resetprop -n log.tag.libsensor-parseRGB S
resetprop -n log.tag.SyncRtSurfaceTransactionApplierCompat S
resetprop -n log.tag.MiuiSplitInputMethodImpl S
resetprop -n log.tag.RefreshRateSelector S
resetprop -n log.tag.NavStubView S
resetprop -n log.tag.AnimStateManager S
resetprop -n log.tag.GestureStateMachine S
resetprop -n log.tag.WindowAnimImplementorDispatcher S
resetprop -n log.tag.LocalWindowAnimImplementor S
resetprop -n log.tag.MIUIInput S
resetprop -n log.tag.BroadcastQueue S
resetprop -n log.tag.BarFollowAnimation S
resetprop -n log.tag.MiuiFreeformModeSettingsObserver S
resetprop -n log.tag.MiuiFreeformModeGestureHandler S
resetprop -n log.tag.TransitionImpl S
resetprop -n log.tag.MiuiRefreshRatePolicy S
resetprop -n log.tag.MiuiDecorationBottom S
resetprop -n log.tag.MiuiDecorationDot S
resetprop -n log.tag.MiuiDecorationHomeBottom S
resetprop -n log.tag.WallpaperControllerImpl S
resetprop -n log.tag.TransitionController S
resetprop -n log.tag.TransitionChain S
resetprop -n log.tag.RTMode S
resetprop -n log.tag.vendor.xiaomi.sensor.citsensorservice@2.0-service S
resetprop -n log.tag.BT_OneTrack_I/F S
resetprop -n log.tag.cnss-daemon S
resetprop -n log.tag.WifiHAL S
resetprop -n log.tag.wificond S
resetprop -n log.tag.QESDK_SESSION_MANAGER S
resetprop -n log.tag.modemManager S
resetprop -n log.tag.vendor.qti.bluetooth@1.1-wake_lock S
resetprop -n log.tag.DeviceGuardManagerService S
resetprop -n log.tag.AmlWifiScoreReportInjector S
resetprop -n log.tag.WifiStaIfaceHidlImpl S
resetprop -n log.tag.WifiOptimizationImpl S
resetprop -n log.tag.SlaveWifiManager S
resetprop -n log.tag.ActivityManagerServiceImpl S
resetprop -n log.tag.CachedAppOptimizer S
resetprop -n log.tag.MiuiStatusIconContainer S
resetprop -n log.tag.ControlCenterHeaderExpandController S
resetprop -n log.tag.ControlCenterControllerImpl S
resetprop -n log.tag.NotificationHeaderExpandController S
resetprop -n log.tag.NotificationPanelExpandController S
resetprop -n log.tag.MiuiClockController S
resetprop -n log.tag.MiuiClockController\ Aod S
resetprop -n log.tag.msys S
resetprop -n log.tag.secondary_dns S
resetprop -n log.tag.msgr.DeviceInfoPeriodicReporter S
resetprop -n log.tag.MI-SF S
resetprop -n log.tag.SLM-SRV-SLAService S
resetprop -n log.tag.Modem_ModemEnhanceMain S
resetprop -n log.tag.Modem_MEModuleSignal S
resetprop -n log.tag.QCNEA S
resetprop -n log.tag.Qesdkenv-info S
resetprop -n log.tag.LanguageHelper S
resetprop -n log.tag.BatteryHistoryManager S
resetprop -n log.tag.ServiceDeliveryReplaceHelper S
resetprop -n log.tag.ServiceDeliveryCompat S
resetprop -n log.tag.ServiceDeliveryCapability S
resetprop -n log.tag.ServiceDeliverSystemProvider S
resetprop -n log.tag.PowerSaveService S
resetprop -n log.tag.PowerManagerService S
resetprop -n log.tag.PowerRankHelperHolder S
resetprop -n log.tag.ThermalObserver S
resetprop -n log.tag.SmartPower S
resetprop -n log.tag.AccessibilityWindowsPopulator S
resetprop -n log.tag.AppCompatLetterboxPolicy S
resetprop -n log.tag.AnimInterruptController S
resetprop -n log.tag.MultiTaskingTaskInfo S
resetprop -n log.tag.DisplayPolicyStubImpl S
resetprop -n log.tag.FileUtil S
resetprop -n log.tag.SRE S
resetprop -n log.tag.backgroundBlur S
resetprop -n log.tag.qdgralloc S
resetprop -n log.tag.MulWinSwitchEventHandler S
resetprop -n log.tag.MultiTaskingTaskRepository S
resetprop -n log.tag.MiuiDecorationRootViewHost S
resetprop -n log.tag.OneHandedController S
resetprop -n log.tag.OnLongClickAgent S
resetprop -n log.tag.VibratorManagerService S
resetprop -n log.tag.GestureStubView_Left S
resetprop -n log.tag.GestureStubView_Right S
resetprop -n log.tag.GestureBackArrowView_Left S
resetprop -n log.tag.NotificationIconContainerInject S
resetprop -n log.tag.WindowManagerShell S
resetprop -n log.tag.InputMethodManagerServiceImpl S
resetprop -n log.tag.IME-account S
resetprop -n log.tag.TaskViewThumbnail S
resetprop -n log.tag.TaskSnapshotCompatVV S
resetprop -n log.tag.MultiTaskingAnimTarget S
resetprop -n log.tag.TransitionCallback S
resetprop -n log.tag.ReflectUtils S
resetprop -n log.tag.RemoteTransitionHandlerStubImpl S
resetprop -n log.tag.miuiElementAnimation S
resetprop -n log.tag.miuiBarFollowAnimation S
resetprop -n log.tag.BlurUtils S
resetprop -n log.tag.ShadeWindowBlurController S
resetprop -n log.tag.ScanManager S
resetprop -n log.tag.ScanController S
resetprop -n log.tag.bt_shim_scanner S
resetprop -n log.tag.BluetoothAdapter S
resetprop -n log.tag.BluetoothUtils S
resetprop -n log.tag.BluetoothPluginCloud S
resetprop -n log.tag.BluetoothLeScanner S
resetprop -n log.tag.WallpaperWindowTokenImpl S
resetprop -n log.tag.TaskStubImpl S
resetprop -n log.tag.MultiTaskingFolmeControl S
resetprop -n log.tag.Aurogon S
resetprop -n log.tag.CloudControlUtil S
resetprop -n log.tag.NetworkMetricsTracker S
resetprop -n log.tag.NetworkBoostStatusManager S
resetprop -n log.tag.NetworkScheduler.Stats S
resetprop -n log.tag.ProcessManager S
resetprop -n log.tag.MagicTether S
resetprop -n log.tag.MiuiNetworkPolicy S
resetprop -n log.tag.MiuiGallery2_AiCoreSupportHelper S
resetprop -n log.tag.MiuiGallery2_AlgoProgressManager S
resetprop -n log.tag.Wth2:WeatherProvider S
resetprop -n log.tag.ITouchFeature S
resetprop -n log.tag.CrossProfileSender S
resetprop -n log.tag.BroadcastExecutor S
resetprop -n log.tag.MultiSenceManagerInternalStub S
resetprop -n log.tag.DisplayContentStubImpl S
resetprop -n log.tag.ViewRootImplStubImpl S
resetprop -n log.tag.MiuiPerfServiceClient S
resetprop -n log.tag.PerfShielderService S
resetprop -n log.tag.JavaheapMonitor S
resetprop -n log.tag.ImeTracker S
resetprop -n log.tag.Launcher S
resetprop -n log.tag.VRI S
resetprop -n log.tag.ShortcutMenuLayerElement S
resetprop -n log.tag.EventBus S
resetprop -n log.tag.OnGlobalListenerError S
resetprop -n log.tag.TaskViewsElement S
resetprop -n log.tag.RecentsImpl S
resetprop -n log.tag.NavStubView_Touch S
resetprop -n log.tag.TaskStackLayoutAlgorithm S
resetprop -n log.tag.ANDR-PERF-LM S
resetprop -n log.tag.VolumeShowHideAnimator S
resetprop -n log.tag.VolumeExpandCollapsedAnimator S
resetprop -n log.tag.SearchOverlayTransitionController S
resetprop -n log.tag.FeedOverlayTransitionController S
resetprop -n log.tag.RecentsView S
resetprop -n log.tag.ScreenView_Workspace S
resetprop -n log.tag.ActivityManagerWrapper S
resetprop -n log.tag.RecentsTaskLoader S
resetprop -n log.tag.MulWinSwitchDecorViewModel S
resetprop -n log.tag.MiuiFreeformModeController S
resetprop -n log.tag.Launcher.UserPresentAnimation S
resetprop -n log.tag.BackGestureBreakController S
resetprop -n log.tag.SfAnimApiProxy S
resetprop -n log.tag.SfAnimController S
resetprop -n log.tag.PreviewDisappear S
resetprop -n log.tag.StateManager S
resetprop -n log.tag.SwipeDetector S
resetprop -n log.tag.RecentsContainer S
resetprop -n log.tag.TaskView S
resetprop -n log.tag.TaskStackViewTouchHandler S
resetprop -n log.tag.SystemWallpaperElement S
resetprop -n log.tag.LauncherStateManager S
resetprop -n log.tag.Launcher.Workspace S
resetprop -n log.tag.Launcher.StatusBarController S
resetprop -n log.tag.GestureDispatcher S
resetprop -n log.tag.GestureObserver S
resetprop -n log.tag.DynamicIslandWindowViewController S
resetprop -n log.tag.DynamicIslandWindowViewImpl S
resetprop -n log.tag.DynamicIslandEventCoordinator S
resetprop -n log.tag.DynamicIslandEventDebug S
resetprop -n log.tag.AssistantOverlaySwipeController S
resetprop -n log.tag.FeedSwipeController S
resetprop -n log.tag.NPVCInjector S
resetprop -n log.tag.Tile.MiuiCellularTile S
resetprop -n log.tag.Launcher.Boost S
resetprop -n log.tag.ControlCenterEventHandler S
resetprop -n log.tag.MiuiBubbleController S
resetprop -n log.tag.BlurController S
resetprop -n log.tag.VsyncModulator S
resetprop -n log.tag.IPCThreadState S
resetprop -n log.tag.egip S
resetprop -n log.tag.StateNotifyUtils S
resetprop -n log.tag.IBarFollowAnimationRunnerImpl S
resetprop -n log.tag.RecentBlurViewElement S
resetprop -n log.tag.ControlCenterExpandController S
resetprop -n log.tag.ControlCenterWindowViewImpl S
resetprop -n log.tag.VolumePanelViewController_true S
resetprop -n log.tag.VolumePanelViewController_false S
resetprop -n log.tag.ControlCenterWindowViewController S
resetprop -n log.tag.ControlCenterContainerController S
resetprop -n log.tag.ControlCenterItemAnimator S
resetprop -n log.tag.RecentsModel S
resetprop -n log.tag.PowerKeeperManager S
resetprop -n log.tag.JobScheduler.SSRU S
resetprop -n log.tag.MiuiGestureDetector S
resetprop -n log.tag.FinishToAppAndWaitTaskStackChange S
resetprop -n log.tag.ScenarioRecognitionUtil S
resetprop -n log.tag.TransitionUtil S
resetprop -n log.tag.AdapterProperties S
resetprop -n log.tag.PolicyMaker S
resetprop -n log.tag.BtGatt.GattService S
resetprop -n log.tag.ActionExecute S
resetprop -n log.tag.RotationHelper S
resetprop -n log.tag.GnssSsruImpl S
resetprop -n log.tag.SettingsProvider S
resetprop -n log.tag.NetlinkEvent S
resetprop -n log.tag.MiuiBatteryServiceImpl S
resetprop -n log.tag.MiuiBatteryStatsService S
resetprop -n log.tag.BatteryStatsImpl S
resetprop -n log.tag.MiuiDecorationController S
resetprop -n log.tag.MiuiWallpaperSurfaceAnimation S
resetprop -n log.tag.LockScreenMagazinePreView S
resetprop -n log.tag.ThemeUtils S
resetprop -n log.tag.EasternArtBAodClock S
resetprop -n log.tag.MiuiFaceManager S
resetprop -n log.tag.ClockPalette S
resetprop -n log.tag.DreamService[MiuiDozeService] S
resetprop -n log.tag.InetDiagMessage S
resetprop -n log.tag.MiuiNearbyOnScanResult_Plugin S
resetprop -n log.tag.MiuiMiHomeConnectController S
resetprop -n log.tag.MiuiFastConnectService_Plugin S
resetprop -n log.tag.MiuiConfigNetConnectController S
resetprop -n log.tag.MiuiBluetoothUtil_Plugin S
resetprop -n log.tag.DeviceNickName_Plugin S
resetprop -n log.tag.MiuiDataControllerImpl[0] S
resetprop -n log.tag.MiuiDataServiceManagerImpl[0] S
resetprop -n log.tag.PhoneAdapter S
resetprop -n log.tag.Phone-0 S
resetprop -n log.tag.RequestManager S
resetprop -n log.tag.qcrilNrd S
resetprop -n log.tag.Phone-1 S
resetprop -n log.tag.NetworkTypeController S
resetprop -n log.tag.QtiGsmCdmaPhone S
resetprop -n log.tag.QtiDSMGR-0 S
resetprop -n log.tag.QtiDSMGR-1 S
resetprop -n log.tag.RILJ S
resetprop -n log.tag.RILUtils S
resetprop -n log.tag.SST S
resetprop -n log.tag.DNC-0 S
resetprop -n log.tag.DNC-1 S
resetprop -n log.tag.DIC-1 S
resetprop -n log.tag.DN-103-C S
resetprop -n log.tag.DN-102-C S
resetprop -n log.tag.QOSCT-103 S
resetprop -n log.tag.QOSCT-102 S
resetprop -n log.tag.NitzStateMachineImpl S
resetprop -n log.tag.LocaleTracker-0 S
resetprop -n log.tag.DPM-0 S
resetprop -n log.tag.MiuiNetworkControllerImpl S
resetprop -n log.tag.MiuiNetworkControllerImpl[0] S
resetprop -n log.tag.PhoneReceiver S
resetprop -n log.tag.NRM-I-0 S
resetprop -n log.tag.NRM-C-0 S
resetprop -n log.tag.RILC S
resetprop -n log.tag.MiuiCellSignalStrength S
resetprop -n log.tag.GSSTInjector S
resetprop -n log.tag.ServiceProvider S
resetprop -n log.tag.RoamingUtils S
resetprop -n log.tag.PAL S
resetprop -n log.tag.AGM S
resetprop -n log.tag.AHAL S
resetprop -n log.tag.View S
resetprop -n persist.log.tag.misight S
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

# Current-boot dynamic MIUI Home animation tags seen in logs; optional and may
# change across boots, so they are not enabled by default.
# resetprop -n log.tag.RectFSpringAnim_58783152 S
# resetprop -n log.tag.MultiSpringDynamicAnimationee46c29 S
# resetprop -n log.tag.WindowElementecbbae S

# MIUI Home uses per-boot dynamic suffixes for several animation tags.
# Sweep the recent log buffer for a few minutes after boot and suppress the
# current-boot names automatically.
suppress_dynamic_logtags &

exit 0

#killing "mi_thermald" will cause fast-charging malfunctioned
