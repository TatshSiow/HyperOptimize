#!/system/bin/sh
MODDIR="${MODDIR:-${0%/*}/..}"
. "$MODDIR/scripts/lib.sh"

####################################
# IO Tuning
####################################
# Docs:
# 1. https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/8/html/monitoring_and_managing_system_status_and_performance/factors-affecting-i-o-and-file-system-performance_monitoring-and-managing-system-status-and-performance#generic-block-device-tuning-parameters_factors-affecting-i-o-and-file-system-performance
# 2. https://brendangregg.com/blog/2015-03-03/performance-tuning-linux-instances-on-ec2.html
# 3. https://blog.csdn.net/yiyeguzhou100/article/details/100068115
# 4. https://github.com/chbatey/tobert.github.io/blob/c98e69267d84aea557e8f6e9bdc62c0d305b7454/src/pages/cassandra_tuning_guide.md?plain=1#L1090
# 5. https://github.com/torvalds/linux/commit/488991e28e55b4fbca8067edf0259f69d1a6f92c
# 6. https://zhuanlan.zhihu.com/p/346966856
for io in /sys/block/* ; do
    block="${io##*/}"

    # nomerges
    # Why not disable? Disabling merging (nomerges=1 or 2) might seem like it removes kernel overhead
    # but it typically floods the UFS controller with numerous tiny requests. 
    # This can lead to increased CPU usage from more frequent interrupts and command processing
    # ultimately increasing overall overhead and potentially degrading performance and battery life for general use.
    write "$io/queue/add_random" "0"
 
    case "$block" in
        sd*|mmcblk*|nvme*)
            # Physical block devices benefit from request merging and can keep
            # iostats. Many Android kernels expose these as read-only, so leave
            # readonly nodes intact.
            write_if_writable "$io/queue/nomerges" "0"
            write_if_writable "$io/queue/iostats" "1"
            write "$io/queue/rq_affinity" "1"
            ;;
        dm-*|loop*|zram*|ram*|mtdblock*)
            # Virtual / translated devices often expose nomerges/iostats as
            # read-only. Apply only when the kernel allows normal writes.
            write_if_writable "$io/queue/nomerges" "2"
            write_if_writable "$io/queue/iostats" "0"
            write "$io/queue/rq_affinity" "0"
            ;;
        *)
            # Default to conservative physical-device behavior for unknown block types.
            write_if_writable "$io/queue/nomerges" "0"
            write_if_writable "$io/queue/iostats" "1"
            write "$io/queue/rq_affinity" "1"
            ;;
    esac

    # write "$io/queue/read_ahead_kb" "128"
    # write "$io/bdi/read_ahead_kb" "128"
    # write "$io/queue/iosched/front_merges" "1"
    # write "$sd/queue/iosched/writes_starved" "1"
    # write "$sd/queue/iosched/write_expire" "3000"

done
