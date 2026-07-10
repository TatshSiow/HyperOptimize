#!/system/bin/sh
MODDIR="${MODDIR:-${0%/*}/..}"
. "$MODDIR/scripts/lib.sh"

####################################
# Performance Tuning
####################################
# Docs : https://blog.xzr.moe/archives/15/#section-24

# Vendor Specific Tuning
# Qualcomm Tuning
if [ "$(getprop ro.hardware)" = "qcom" ]; then 
    # KGSL Tuning & GPU Tuning(GPU)
    # GPU devfreq min/max are vendor policy knobs. Avoid forcing them globally;
    # PowerHAL, thermal, and game/display modes may need to adjust them.
    # write_in_path_excluding "0" "/sys/devices/platform" "kgsl-3d0/devfreq" "kgsl-busmon" "min_freq"
    write "/sys/class/kgsl/kgsl-3d0/force_bus_on" "0"
    write "/sys/class/kgsl/kgsl-3d0/force_clk_on" "0"
    write "/sys/class/kgsl/kgsl-3d0/force_no_nap" "0"
    write "/sys/class/kgsl/kgsl-3d0/force_rail_on" "0"
    # Heuristic and kernel-specific; leave disabled unless validated on target devices.
    # lock_val "0" /sys/class/kgsl/kgsl-3d0/bus_split
    # Read-protected on some kernels; avoid forcing permissions for this GPU
    # policy knob unless validated on target devices.
    # write "/sys/class/kgsl/kgsl-3d0/popp" "0"
    # Battery/current-limit behavior is kernel-specific; avoid forcing it
    # globally unless the target device's KGSL bcl node is validated.
    # write "/sys/class/kgsl/kgsl-3d0/bcl" "0"
    # lock_val "100" /sys/class/kgsl/kgsl-3d0/devfreq/mod_percent
    # Heuristic and kernel-specific; leave disabled unless validated on target devices.
    # lock_val "0" /sys/class/kgsl/kgsl-3d0/preemption
    # Heuristic and workload-sensitive; avoid forcing a global idle timer.
    # lock_val "30" /sys/class/kgsl/kgsl-3d0/idle_timer

    # lock_val "2147483647" /sys/kernel/gpu/gpu_max_clock
    # write "/sys/kernel/gpu/gpu_min_clock" "0"

    # RCU Tuning
    # https://www.kernel.org/doc/Documentation/RCU/Design/Expedited-Grace-Periods/Expedited-Grace-Periods.html
    write_if_writable "/sys/kernel/rcu_expedited" "0"

    # PELT Multiplier
    # lock_val "4" "/proc/sys/kernel/sched_pelt_multiplier"

    # Enable LPM for all CPUs
    # qcom_lpm controls Qualcomm idle / cluster power-state entry. Forcing
    # these disables to 0 prefers allowing deeper idle states.
    for disable in $(find /sys/devices/system/cpu/qcom_lpm -type f -name '*disable*' 2>/dev/null); do
        write "$disable" "0"
    done


    write_in_path "0" "/sys/devices/system/cpu/cpufreq" "hispeed_freq"
    write_in_path "0" "/sys/devices/system/cpu/cpufreq" "rtg_boost_freq"
    write_in_path "5000" "/sys/devices/system/cpu/cpufreq" "up_rate_limit_us"
    write_in_path "1000" "/sys/devices/system/cpu/cpufreq" "down_rate_limit_us"

else 
#Mediatek Tuning
    write  "/sys/kernel/ged/hal/custom_upbound_gpu_freq" "0"
    write  "/sys/module/ged/parameters/is_GED_KPI_enabled" "0"
    # Keep MTK core_ctl policy active; disabling it can prevent normal
    # battery-oriented core management.
    # write  "/sys/module/mtk_core_ctl/parameters/policy_enable" "0"
    write "/sys/kernel/ged/hal/dcs_mode" "0"
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
    
    write "/proc/sys/walt/walt_rtg_cfs_boost_prio" "99" #99=disabled
    # write "/proc/sys/walt/walt_low_latency_task_threshold" "0"

    # task
    # write "/proc/sys/walt/sched_task_unfilter_period" "20000000"
    write "/proc/sys/walt/sched_min_task_util_for_boost"  "51"
    write "/proc/sys/walt/sched_min_task_util_for_colocation"  "35"
    write "/proc/sys/walt/sched_downmigrate" "60 75"
    write "/proc/sys/walt/sched_upmigrate" "70 90"

    # Reduce the time to consider an idle
    write "/proc/sys/walt/sched_idle_enough" "25"

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
        write $i "5000"
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

# Cluster-derived cpuset and IRQ affinity tuning is intentionally disabled.
# CPU topology layouts vary too much across devices, and hard-coded cluster
# assumptions can exclude higher clusters on 4-cluster SoCs.
# /sys/devices/system/cpu/cpu*/cpuidle/state*/disable to 0
# /sys/module/lpm_levels/parameters/sleep_disabled
