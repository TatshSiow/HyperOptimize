#!/system/bin/sh
MODDIR="${MODDIR:-${0%/*}/..}"
. "$MODDIR/scripts/lib.sh"

if [ -d /sys/module/migt ]; then
    # Three-round win across CPU/scheduler, GPU, and system_server metrics.
    write "/proc/sys/migt/enable_pkg_monitor" "0"
    write_if_writable "/sys/module/migt/parameters/enable_pkg_monitor" "0"

    # Already selected and compatible; retain portable no-boost states.
    write "/sys/module/migt/parameters/glk_freq_limit_walt" "0"
    write_if_writable "/sys/module/migt/parameters/boost_policy" "0"
    write "/sys/module/migt/parameters/glk_disable" "1"
    write "/sys/module/migt/parameters/force_stask_to_big" "0"

    # No reliable multi-metric win.
    # write_if_writable "/sys/module/migt/parameters/cpu_boost_cycle" "0"
    # write_if_writable "/sys/module/migt/parameters/sysctl_boost_stask_to_big" "0"
fi

if [ -d /sys/module/metis ]; then
    # Three-round win with unchanged launch time/jank.
    write_if_writable "/sys/module/metis/parameters/suspend_vip_enable" "0"

    # Already selected and compatible; retain portable no-link states.
    write_if_writable "/sys/module/metis/parameters/mi_link_enable" "0"
    write_if_writable "/sys/module/metis/parameters/mi_switch_enable" "0"

    # No reliable multi-metric win.
    # write_if_writable "/sys/module/metis/parameters/cluaff_control" "0"
    # write "/sys/module/metis/parameters/user_min_freq" "0,0,0"
    # write "/sys/module/metis/parameters/min_cluster_freqs" "0,0,0"
    # write "/sys/module/metis/parameters/limit_bgtask_sched" "1"
    # write_if_writable "/sys/module/metis/parameters/mi_fboost_enable" "0"
    # write_if_writable "/sys/module/metis/parameters/mi_freq_enable" "0"
    # write "/sys/module/metis/parameters/bug_detect" "0"
    # write_if_writable "/sys/module/metis/parameters/sched_doctor_enable" "0"

    # Live dynamic registry cannot be safely restored after clearing.
    # write_if_writable "/sys/module/metis/parameters/mi_viptask" "0"
fi

# Rejected: no measured win.
# write "/proc/package/stat/pause_mode" "1"

# MIST is absent on the test device; retain for another-device testing.
# write "/sys/module/mist/parameters/dflt_bw_enable" "0"
# write "/sys/module/mist/parameters/dflt_lat_enable" "0"
# write "/sys/module/mist/parameters/dflt_ddr_boost" "0"
# write "/sys/module/mist/parameters/gflt_enable" "0"
# write "/sys/module/mist/parameters/mist_memlat_vote_enable" "0"
