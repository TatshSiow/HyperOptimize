#!/system/bin/sh
STATE_DIR=${HYPEROPTIMIZE_STATE_DIR:-/data/adb/hyperoptimize-state}

restore_files() {
    [ -f "$STATE_DIR/files" ] || return 0
    while IFS='|' read -r path value; do
        [ -f "$path" ] && printf '%s\n' "$value" > "$path" 2>/dev/null
    done < "$STATE_DIR/files"
}

restore_props() {
    [ -f "$STATE_DIR/props" ] || return 0
    while IFS='|' read -r prop had value; do
        if [ "$had" = 1 ]; then resetprop "$prop" "$value" >/dev/null 2>&1
        else resetprop -d "$prop" >/dev/null 2>&1
        fi
    done < "$STATE_DIR/props"
}

restore_settings() {
    [ -f "$STATE_DIR/settings" ] || return 0
    while IFS='|' read -r namespace name had value; do
        if [ "$had" = 1 ]; then cmd settings put "$namespace" "$name" "$value" >/dev/null 2>&1
        else cmd settings delete "$namespace" "$name" >/dev/null 2>&1
        fi
    done < "$STATE_DIR/settings"
}

restore_services() {
    [ -f "$STATE_DIR/services" ] || return 0
    while IFS='|' read -r name state; do
        case "$state" in running|restarting) start "$name" >/dev/null 2>&1 ;; stopped) stop "$name" >/dev/null 2>&1 ;; esac
    done < "$STATE_DIR/services"
}

# The looper command has no status API. Restore it only when the original
# property explicitly exposed its state; otherwise leave the framework default.
looper_original=
[ -f "$STATE_DIR/props" ] && looper_original=$(awk -F '|' '$1 == "debug.sys.looper_stats_enabled" { print $2 "|" $3; exit }' "$STATE_DIR/props")

restore_files
restore_settings
restore_props
restore_services

case "$looper_original" in 1\|true|1\|1) cmd looper_stats enable >/dev/null 2>&1 ;; 1\|false|1\|0) cmd looper_stats disable >/dev/null 2>&1 ;; esac
rm -rf "$STATE_DIR"

# Don't modify anything after this
if [ -f "$INFO" ]; then
  while read LINE; do
    if [ "$(echo -n "$LINE" | tail -c 1)" == "~" ]; then
      continue
    elif [ -f "$LINE~" ]; then
      mv -f "$LINE~" "$LINE"
    else
      rm -f "$LINE"
      while true; do
        LINE=$(dirname "$LINE")
        [ "$(ls -A "$LINE" 2>/dev/null)" ] && break 1 || rm -rf "$LINE"
      done
    fi
  done < "$INFO"
  rm -f "$INFO"
fi
