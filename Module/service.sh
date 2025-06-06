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

####################################
# Script Start
####################################
wait_until_login
sleep 15

debug_name="debug_mask
*log_level*
*debug_level*
*debug_mode
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
iostats
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
enable_pkg_monitor
load_debug
desc_option
logging_option
millet_debug
*log*mask
minidump_enable
doublecyc_debug
msm_vidc_fw_dump
fboost_debug
link_debug
metis_debug
tsched_debug
flw_debug
flw_enable
game_link_debug
migt_debug
cpas_dump
enable_bugon
suid_dumpable
nf_conntrack_log_invalid
nf_log_all_netns
*cpu_backtrace
mb_stats"

# Failed Lines (Permission denied)
# "debug_quirks*"
# "stats_timer"
# "dump_oops"

for i in $debug_name; do
    for o in $(find /sys/ /proc/sys -type f -name "$i"); do
        write "$o" "0"
    done
done

debug_list_1="/sys/kernel/debug/dri/0/debug/enable
/kernel/debug/sde_rotator0/evtlog/enable
/sys/kernel/debug/kgsl/kgsl-3d0/profiling/enable
/sys/kernel/debug/kprobes/enabled
/sys/kernel/tracing/events/bpf_trace/bpf_trace_printk/enable
/sys/kernel/debug/tracing/events/bpf_trace/bpf_trace_printk/enable
/proc/sys/kernel/print-fatal-signals"

for debug_1 in "$debug_list_1"; do
    write "$debug_1" "0"
done

debug_list_2="/sys/kernel/debug/debug_enabled
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
/sys/module/ip6_tunnel/parameters/log_ecn_error"

# /sys/module/drm_kms_helper/parameters/poll
# /sys/kernel/debug/qcom,mdss_dsi_m3_38_0c_0a_dsc_cmd/dsi-ctrl-0/enable_cmd_dma_stats : N

for debug_2 in "$debug_list_2"; do
    write "$debug_2" "N"
done

####################################
# Misc
####################################
#some other parameters
write "/sys/kernel/debug/dri/0/debug/reglog_enable" "0"
write "/sys/kernel/debug/msm_cvp/debug_level" "0"

#core
write "/proc/sys/kernel/core_pattern" ""

# Event Tracing
write "/sys/kernel/debug/tracing/set_event" ""
write "/sys/kernel/debug/tracing/events/enable" "0"
write "/sys/kernel/tracing/events/enable" "0"

for coredump in /sys/kernel/debug/remoteproc/remoteproc*/coredump; do
    write "$coredump" "disabled"
done

#Kernel Panic & Watchdogs
panic="hung_task_panic
max_rcu_stall_to_panic
panic
panic_on_oops
panic_on_rcu_stall
panic_on_warn
panic_print
softlockup_panic
nmi_watchdog
soft_watchdog
watchdog
watchdog_cpumask
watchdog_thresh"
for i in $panic; do
    for o in $(find /proc/sys/kernel/ -type f -name "$i"); do
        write "$o" "0"
    done
done

#Watchdogs

####################################
# Printk
####################################
write "/proc/sys/kernel/printk" "0 0 0 0"
write "/proc/sys/kernel/printk_delay" "0"
write "/proc/sys/kernel/printk_devkmsg" "off"
write "/proc/sys/kernel/printk_ratelimit" "1"
write "/proc/sys/kernel/printk_ratelimit_burst" "1"
write "/proc/sys/kernel/tracepoint_printk" "0"
write "/sys/module/printk/parameters/always_kmsg_dump" "N"
write "/sys/module/printk/parameters/console_no_auto_verbose" "N"
write "/sys/module/printk/parameters/time" "0"
write "/sys/module/printk/parameters/console_suspend" "1"
write "/sys/module/printk/parameters/ignore_loglevel" "1"

####################################
# Performance Tuning
####################################

if [ "$(getprop ro.hardware)" = "qcom" ]; then 
    # KGSL Tuning (GPU)
    lock_val "2147483647" /sys/class/devfreq/*kgsl-3d0/max_freq
    lock_val "0" /sys/class/devfreq/*kgsl-3d0/min_freq
    lock_val "0" /sys/class/kgsl/kgsl-3d0/force_bus_on
    lock_val "0" /sys/class/kgsl/kgsl-3d0/force_clk_on
    lock_val "0" /sys/class/kgsl/kgsl-3d0/force_no_nap
    lock_val "0" /sys/class/kgsl/kgsl-3d0/force_rail_on
    lock_val "0" /sys/class/kgsl/kgsl-3d0/bus_split
    lock_val "0" /sys/class/kgsl/kgsl-3d0/popp
    lock_val "65" /sys/class/kgsl/kgsl-3d0/devfreq/mod_percent
fi


# Xiaomi Config
# stop mimd-service
# stop mimd-service2_0
write "/sys/module/migt/parameters/enable_pkg_monitor" "0"
write "/proc/sys/migt/enable_pkg_monitor" "0"
write "/sys/module/migt/parameters/glk_freq_limit_walt" "0"
write "/sys/module/metis/parameters/cluaff_control" "0"
write "/proc/sys/walt/sched_ed_boost" "0"
write "/proc/sys/walt/input_boost/powerkey_input_boost_ms" "0"
write "/proc/sys/walt/input_boost/input_boost_ms" "0"

# PELT Multiplier
write "/proc/sys/kernel/sched_pelt_multiplier" "8"

# PERF Monitoring
write "/proc/sys/kernel/perf_cpu_time_max_percent" "0"

# VM Tunable
write "/proc/sys/vm/stat_interval" "20"
write "/proc/sys/vm/vfs_cache_pressure" "120"
write "/proc/sys/vm/page-cluster" "0"
write "/proc/sys/vm/dirty_ratio" "15"
write "/proc/sys/vm/dirty_background_ratio" "3"

# Require dirty memory to stay in memory for longer
write "/proc/sys/vm/dirty_expire_centisecs 3000"

# Run the dirty memory flusher threads less often
write "/proc/sys/vm/dirty_writeback_centisecs 3000"

if [ -d /sys/kernel/mm/lru_gen/ ]; then
    lock_val "Y" /sys/kernel/mm/lru_gen/enabled
    lock_val "5000" /sys/kernel/mm/lru_gen/min_ttl_ms
fi

####################################
# Kill and Stop Services
####################################

sleep 3 
process="charge_logger
logcat
statsd
traced
traced_probes
vendor.ipacm-diag
vendor.modemManager
vendor.qesdk-mgr
update_engine
tombstoned
vendor.mi_misight
vendor.perfservice
vendor.miperf
misight
miuibooster
vendor.servicetracker-1-2"

#killing "mi_thermald" will cause fast-charging to malfunctioned


for name in $process; do
    su -c stop "$name" 2>/dev/null 
done

exit