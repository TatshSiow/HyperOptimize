#!/system/bin/sh
MODDIR="${MODDIR:-${0%/*}/..}"
. "$MODDIR/scripts/lib.sh"

####################################
# Xiaomi Tuning
####################################
# migt and metis are Xiaomi vendor scheduler / boost layers. These are among
# the highest-risk smoothness knobs in the module because they influence task
# placement, foreground boosting, and render-thread promotion.
write "/proc/sys/migt/enable_pkg_monitor" "0"
write "/sys/module/migt/parameters/enable_pkg_monitor" "0"
write "/sys/module/migt/parameters/glk_freq_limit_walt" "0"
write "/sys/module/metis/parameters/cluaff_control" "0"
# mist is absent on fuxi, so these writes are harmless no-ops on this device.
write "/sys/module/mist/parameters/dflt_bw_enable" "0" 
write "/sys/module/mist/parameters/dflt_lat_enable" "0" 
write "/sys/module/mist/parameters/dflt_ddr_boost" "0" 
write "/sys/module/mist/parameters/gflt_enable" "0" 
write "/sys/module/mist/parameters/mist_memlat_vote_enable" "0" 

# Xiaomi package/stat looks like vendor stats / tracing control rather than a
# primary performance path. Low risk compared with migt/metis.
write "/proc/package/stat/pause_mode" "1"

write "/sys/module/migt/parameters/boost_policy" "0"
write "/sys/module/migt/parameters/cpu_boost_cycle" "0"
write "/sys/module/migt/parameters/glk_disable" "1"
write "/sys/module/migt/parameters/sysctl_boost_stask_to_big" "0"
write "/sys/module/migt/parameters/force_stask_to_big" "0"
write "/sys/module/migt/parameters/flw_enable" "0"
write "/sys/module/migt/parameters/flw_freq_enable" "0"

write "/sys/module/metis/parameters/user_min_freq" "0,0,0"
write "/sys/module/metis/parameters/min_cluster_freqs" "0,0,0"
write "/sys/module/metis/parameters/is_link_enable" "0"
write "/sys/module/metis/parameters/limit_bgtask_sched" "1"
write "/sys/module/metis/parameters/mi_fboost_enable" "0"
write "/sys/module/metis/parameters/mi_freq_enable" "0"
write "/sys/module/metis/parameters/mi_link_enable" "0"
write "/sys/module/metis/parameters/mi_switch_enable" "0"
write "/sys/module/metis/parameters/mi_viptask" "0"
write "/sys/module/metis/parameters/mpc_fboost_enable" "0"
write "/sys/module/metis/parameters/vip_link_enable" "0"
write "/sys/module/metis/parameters/bug_detect" "0"
write "/sys/module/metis/parameters/suspend_vip_enable" "0"
write "/sys/module/metis/parameters/sched_doctor_enable" "0"
