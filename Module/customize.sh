##########################################################################################
#
# MMT Extended Config Script
#
##########################################################################################

##########################################################################################
# Config Flags
##########################################################################################

# Uncomment and change 'MINAPI' and 'MAXAPI' to the minimum and maximum android version for your mod
# Uncomment DYNLIB if you want libs installed to vendor for oreo+ and system for anything older
# Uncomment PARTOVER if you have a workaround in place for extra partitions in regular magisk install (can mount them yourself - you will need to do this each boot as well). If unsure, keep commented
# Uncomment PARTITIONS and list additional partitions you will be modifying (other than system and vendor), for example: PARTITIONS="/odm /product /system_ext"
#MINAPI=21
#MAXAPI=25
#DYNLIB=true
#PARTOVER=true
#PARTITIONS=""

##########################################################################################
# Replace list
##########################################################################################

# List all directories you want to directly replace in the system
# Check the documentations for more info why you would need this

# Construct your list in the following format
# This is an example
REPLACE_EXAMPLE="
/system/app/Youtube
/system/priv-app/SystemUI
/system/priv-app/Settings
/system/framework
"

# Construct your own list here
REPLACE="
"

##########################################################################################
# Permissions
##########################################################################################

set_permissions() {
  : # Remove this if adding to this function

  # Note that all files/folders in magisk module directory have the $MODPATH prefix - keep this prefix on all of your files/folders
  # Some examples:
  
  # For directories (includes files in them):
  # set_perm_recursive  <dirname>                <owner> <group> <dirpermission> <filepermission> <contexts> (default: u:object_r:system_file:s0)
  
  # set_perm_recursive $MODPATH/system/lib 0 0 0755 0644
  # set_perm_recursive $MODPATH/system/vendor/lib/soundfx 0 0 0755 0644

  # For files (not in directories taken care of above)
  # set_perm  <filename>                         <owner> <group> <permission> <contexts> (default: u:object_r:system_file:s0)
  
  # set_perm $MODPATH/system/lib/libart.so 0 0 0644
  # set_perm /data/local/tmp/file.txt 0 0 644
}

ui_print " "
ui_print "═════════════════════════════════"
ui_print "         Hyper Optimize          "
ui_print "        Created by: Tatsh        "
ui_print "═════════════════════════════════"
ui_print "Uninstall this if stucked at boot"
ui_print "═════════════════════════════════"
ui_print " "
ui_print "Device Model      : $(getprop ro.product.odm.marketname)"
ui_print
ui_print "Device codename   : $(getprop ro.product.name)"
ui_print " "
ui_print "Device Model Name : $(getprop ro.product.odm.model)"
ui_print " "
ui_print "OS Info           : $(getprop ro.build.version.incremental)"
ui_print " "
ui_print "Build ID          : $(getprop ro.build.id)"
ui_print " "
ui_print "Android Version   : $(getprop ro.build.version.release)"
ui_print " "
ui_print "VNDK Version      : $(getprop ro.vndk.version)"
ui_print " "
ui_print "Build Date        : $(getprop ro.build.date)"
ui_print " "
ui_print "Kernel version    : $(uname -r)"
ui_print "═════════════════════════════════"

##########################################################################################
# MMT Extended Logic - Don't modify anything after this
##########################################################################################

SKIPUNZIP=1
unzip -qjo "$ZIPFILE" 'common/functions.sh' -d $TMPDIR >&2
. $TMPDIR/functions.sh
