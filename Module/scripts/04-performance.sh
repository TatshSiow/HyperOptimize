#!/system/bin/sh
MODDIR="${MODDIR:-${0%/*}/..}"
. "$MODDIR/scripts/lib.sh"

if [ "$(getprop ro.hardware)" = qcom ]; then
    # Portable already-safe states: do not force GPU bus/clock/rail on.
    write "/sys/class/kgsl/kgsl-3d0/force_bus_on" "0"
    write "/sys/class/kgsl/kgsl-3d0/force_clk_on" "0"
    write "/sys/class/kgsl/kgsl-3d0/force_rail_on" "0"

    # Three-round multi-metric wins.
    write "/sys/class/kgsl/kgsl-3d0/force_no_nap" "0"
    write_if_writable "/sys/kernel/rcu_expedited" "0"
    write_in_path "1000" "/sys/devices/system/cpu/cpufreq" "down_rate_limit_us"

    # Keep Qualcomm low-power states available on other kernels too.
    for disable in $(find /sys/devices/system/cpu/qcom_lpm -type f -name '*disable*' 2>/dev/null); do
        write "$disable" "0"
    done

    # No reliable multi-metric win on this device.
    # write_in_path "0" "/sys/devices/system/cpu/cpufreq" "hispeed_freq"
    # write_in_path "0" "/sys/devices/system/cpu/cpufreq" "rtg_boost_freq"
    # write_in_path "5000" "/sys/devices/system/cpu/cpufreq" "up_rate_limit_us"
fi

if [ -d /proc/sys/walt ]; then
    # Already disabled on the test device; retain portable no-boost states.
    write "/proc/sys/walt/sched_boost" "0"
    write "/proc/sys/walt/sched_asymcap_boost" "0"
    for path in /sys/devices/system/cpu/cpu*/cpufreq/walt/boost; do write "$path" "0"; done

    # No reliable multi-metric win on this device.
    # write "/proc/sys/walt/input_boost/input_boost_freq" "0 0 0 0 0 0 0 0"
    # write "/proc/sys/walt/sched_conservative_pl" "1"
    # write "/proc/sys/walt/sched_window_stats_policy" "0"
    # write "/proc/sys/walt/sched_downmigrate" "60 75"
    # write "/proc/sys/walt/sched_upmigrate" "70 90"
    # write "/proc/sys/walt/sched_sync_hint_enable" "0"

    # Missing or already identical; retained for another-device testing.
    # write "/proc/sys/walt/sched_ed_boost" "0"
    # write "/proc/sys/walt/sched_idle_enough" "25"
    # write "/proc/sys/walt/sched_pipeline_special" "0"
else
    write_in_path "1000" "/sys/devices/system/cpu/cpufreq" "down_rate_limit_us"
fi

# Missing on the test device; retain for another-device testing.
# write "/sys/devices/system/cpu/cpufreq/boost" "0"
