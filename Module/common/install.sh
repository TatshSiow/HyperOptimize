##########################################################################################
#
# Hyper Optimize installer options
#
##########################################################################################

VOLUME_SELECT_TIMEOUT=30

choose_volume_option() {
  local prompt="$1"
  local default="$2"
  local event code

  ui_print " "
  ui_print "----------------------------------------"
  ui_print "$prompt"
  ui_print "Volume Up = Yes"
  ui_print "Volume Down = No"
  ui_print "Default after ${VOLUME_SELECT_TIMEOUT}s: $default"
  ui_print "----------------------------------------"

  while true; do
    event="$(timeout "$VOLUME_SELECT_TIMEOUT" getevent -qlc 1 2>/dev/null)"
    code="$?"

    if [ "$code" = "124" ] || [ "$code" = "143" ]; then
      [ "$default" = "Yes" ] && return 0 || return 1
    fi

    echo "$event" | grep -q "KEY_VOLUMEUP.*DOWN" && return 0
    echo "$event" | grep -q "KEY_VOLUMEDOWN.*DOWN" && return 1
  done
}

ui_print " "
ui_print "- Installer Options"
ui_print "  Use Volume Up for Yes, Volume Down for No."

choose_volume_option "Enable Vulkan renderer?" "No"
ENABLE_VULKAN="$?"

mkdir -p "$MODPATH/config"
{
  if [ "$ENABLE_VULKAN" = "0" ]; then
    echo "ENABLE_VULKAN=1"
  else
    echo "ENABLE_VULKAN=0"
  fi
} > "$MODPATH/config/user_options"

chmod 0644 "$MODPATH/config/user_options"

ui_print " "
ui_print "- Vulkan renderer: $([ "$ENABLE_VULKAN" = "0" ] && echo Enabled || echo Disabled)"
