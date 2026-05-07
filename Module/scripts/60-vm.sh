#!/system/bin/sh
MODDIR="${MODDIR:-${0%/*}/..}"
. "$MODDIR/scripts/lib.sh"

####################################
# VM Tunables
####################################

# Scale VM policy by RAM size and swap/zram availability instead of forcing
# one set of ratios on every device.
apply_adaptive_vm_tunables

lock_val "7" "/sys/kernel/mm/lru_gen/enabled"
# lock_val "1000" "/sys/kernel/mm/lru_gen/min_ttl_ms"

