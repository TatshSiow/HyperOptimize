#!/system/bin/sh
MODDIR="${MODDIR:-${0%/*}/..}"
. "$MODDIR/scripts/lib.sh"

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
