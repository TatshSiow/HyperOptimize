#!/system/bin/sh
MODDIR="${MODDIR:-${0%/*}/..}"
. "$MODDIR/scripts/lib.sh"

# Individually benchmarked winners. Discovery patterns and rejected candidates
# live in refined/01-debug-toggles.sh, outside the production module.
for path in \
    /sys/devices/system/edac/qcom-llcc/log_ce \
    /sys/devices/system/edac/qcom-llcc/log_ue \
    /sys/kernel/tracing/events/bpf_trace/bpf_trace_printk/enable; do
    apply_toggle "$path"
done
