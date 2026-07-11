#!/system/bin/sh
MODDIR="${MODDIR:-${0%/*}/..}"
. "$MODDIR/scripts/lib.sh"

for io in /sys/block/*; do
    block=${io##*/}
    write "$io/queue/add_random" "0"
    case "$block" in
        sd*|mmcblk*|nvme*)
            write_if_writable "$io/queue/nomerges" "0"
            write "$io/queue/rq_affinity" "1"
            write_if_writable "$io/queue/iostats" "0"
            ;;
        dm-*|loop*|zram*|ram*|mtdblock*)
            write_if_writable "$io/queue/iostats" "0"
            write "$io/queue/rq_affinity" "2"
            ;;
    esac
done
