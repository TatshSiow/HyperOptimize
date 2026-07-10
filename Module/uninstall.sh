#!/system/bin/sh

delete_prop() {
  command -v resetprop >/dev/null 2>&1 || return 0
  resetprop -d "$1" >/dev/null 2>&1
  return 0
}

MODDIR="${0%/*}"

delete_props_from_system_prop() {
  local file="$1"
  local prop

  [ -f "$file" ] || return 0

  while IFS='=' read -r prop _; do
    case "$prop" in
      persist.*|debug.*|logd.*|media.*|db.*|dalvik.*|sys.*|service.*|vendor.*|traced.*)
        delete_prop "$prop"
        ;;
    esac
  done < "$file"

  return 0
}

delete_resetprop_targets_from_script() {
  local file="$1"
  local prop

  [ -f "$file" ] || return 0

  sed -n \
    -e 's/^[[:space:]]*resetprop[[:space:]]\+\(-n[[:space:]]\+\)\{0,1\}\([^[:space:]]\+\).*/\2/p' \
    -e 's/^[[:space:]]*setprop_if_present[[:space:]]\+\([^[:space:]]\+\).*/\1/p' \
    "$file" 2>/dev/null |
    while read -r prop; do
      case "$prop" in
        persist.*|debug.*|logd.*|media.*|db.*|dalvik.*|sys.*|service.*|vendor.*|traced.*|log.tag.*)
          delete_prop "$prop"
          ;;
      esac
    done

  return 0
}

# Re-enable framework looper statistics collection when supported.
cmd looper_stats enable >/dev/null 2>&1
delete_prop debug.sys.looper_stats_enabled

# Remove framework settings changed by the refined runtime script.
cmd settings delete system anr_debugging_mechanism >/dev/null 2>&1
cmd settings delete system send_security_reports >/dev/null 2>&1

# Restore the only service explicitly stopped by the refined service script.
start charge_logger >/dev/null 2>&1

# Remove persistent/module-owned props that were declared in system.prop or set
# through resetprop scripts. This prevents uninstall from leaving stale persist.*
# values on devices where resetprop stored them beyond the module lifetime.
delete_props_from_system_prop "$MODDIR/system.prop"
delete_resetprop_targets_from_script "$MODDIR/post-fs-data.sh"
delete_resetprop_targets_from_script "$MODDIR/scripts/10-services-logtags.sh"
delete_resetprop_targets_from_script "$MODDIR/scripts/11-runtime-config.sh"

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
