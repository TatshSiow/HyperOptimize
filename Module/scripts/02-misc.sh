#!/system/bin/sh
MODDIR="${MODDIR:-${0%/*}/..}"
. "$MODDIR/scripts/lib.sh"

# Five-round A/B test: lower CPU, context switches, interrupts, and block I/O.
write "/sys/module/spurious/parameters/noirqdebug" "Y"

# Compatible, but versus madvise it increased block I/O in the repeated test.
# write "/sys/kernel/mm/transparent_hugepage/enabled" "never"

# Compatible, but no normal-runtime CPU/I/O saving over the current setup.
# write "/proc/sys/kernel/core_pattern" ""

# perf=0 disables the kernel's perf-event throttling guard; it is not a power tweak.
# write "/proc/sys/kernel/perf_cpu_time_max_percent" "0"

# Module-load self-tests have already run by service time; no runtime benefit measured.
# write "/sys/module/cryptomgr/parameters/notests" "Y"

# Missing on the test device; retained for compatibility testing on other kernels.
# write "/sys/kernel/debug/tracing/set_event" ""
# for coredump in /sys/kernel/debug/remoteproc/remoteproc*/coredump; do
#     write "$coredump" "disabled"
# done
# for minidump in /sys/kernel/va-minidump/*/enable; do
#     write "$minidump" "0"
# done

# Security audit logging stays enabled.
# write "/sys/module/lsm_audit/parameters/disable_audit_log" "1"
