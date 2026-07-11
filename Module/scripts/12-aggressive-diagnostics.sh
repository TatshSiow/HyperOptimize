#!/system/bin/sh
MODDIR="${MODDIR:-${0%/*}/..}"
. "$MODDIR/scripts/lib.sh"

# Optional only: these controls did not produce a repeatable normal-runtime
# power win. They reduce accounting or fault-time troubleshooting information.

# Continuous diagnostic accounting.
write_if_writable "/proc/sys/kernel/sched_schedstats" "0"
write_in_path_if_writable "0" "/sys/fs/f2fs" "iostat_enable"

# Fault/OOM/resume dump generation.
write_if_writable "/proc/sys/vm/oom_dump_tasks" "0"
write_if_writable "/proc/sys/kernel/ftrace_dump_on_oops" "0"
write_if_writable "/sys/module/qcom_ramdump/parameters/enable_dump_collection" "0"
write_if_writable "/sys/module/msm_show_resume_irq/parameters/debug_mask" "0"
write_in_path_if_writable "0" "/sys/devices/platform" "snapshot_crashdumper"
write_in_path_if_writable "N" "/sys/module" "qdf_log_dump_at_kernel_enable"

# Multimedia diagnostic masks. Short camera/UI compatibility tests passed, but
# repeated performance confirmation found no stable benefit.
write_if_writable "/sys/module/msm_video/parameters/msm_vidc_debug" "0"
write_in_path_if_writable "0" "/sys/devices/platform" "qcom,mmrm" "debug"
