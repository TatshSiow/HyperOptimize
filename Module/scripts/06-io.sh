#!/system/bin/sh
MODDIR="${MODDIR:-${0%/*}/..}"
. "$MODDIR/scripts/lib.sh"

for io in /sys/block/*; do
    block=${io##*/}

    # Already selected on this device; avoids entropy-accounting work.
    write "$io/queue/add_random" "0"

    case "$block" in
        sd*|mmcblk*|nvme*)
            # Keep merging and completion affinity; both were already selected.
            write_if_writable "$io/queue/nomerges" "0"
            write "$io/queue/rq_affinity" "1"

            # A/B win versus iostats=1: less CPU/scheduler work, same latency.
            write_if_writable "$io/queue/iostats" "0"
            ;;
        dm-*|loop*|zram*|ram*|mtdblock*)
            # Keeping accounting off avoids instrumentation overhead.
            write_if_writable "$io/queue/iostats" "0"

            # No nomerges value (0/1/2) produced a reliable win.
            # write_if_writable "$io/queue/nomerges" "2"

            # A/B matrix winner: fewer CPU cycles/interrupts and lower GPU/jank.
            write "$io/queue/rq_affinity" "2"
            ;;
    esac
done
