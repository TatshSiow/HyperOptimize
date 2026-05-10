#!/system/bin/sh
MODDIR="${MODDIR:-${0%/*}/..}"
. "$MODDIR/scripts/lib.sh"

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

# Present but protected on mayfly/HyperOS; repeated attempts only add noise.
debug_skip_path="dplh_log_level gplaf_log_level cpucp_log_level enable_pkg_monitor"

# Scan sysfs/procfs once, then reuse the path cache on later boots. This avoids
# repeatedly walking large debug trees during boot settle.
apply_debug_path_cache "$MODDIR/config/debug_paths"

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
