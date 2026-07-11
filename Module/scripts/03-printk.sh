#!/system/bin/sh
MODDIR="${MODDIR:-${0%/*}/..}"
. "$MODDIR/scripts/lib.sh"

# Rate-limit repeated kernel messages without disabling useful diagnostics.
write "/proc/sys/kernel/printk_ratelimit" "5"
