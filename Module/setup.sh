#!/sbin/sh
SKIPMOUNT=false
PROPFILE=true
POSTFSDATA=true
LATESTARTSERVICE=true

info_print() {
  ui_print " "
  ui_print "==============================="
  ui_print "        Hyper Optimize         "
  ui_print "       Created by: Tatsh       "
  ui_print "==============================="
  ui_print "Uninstall this if stuck at boot"
  ui_print "==============================="
  ui_print " "
  # ROM Info
  ui_print "Device Name     : $(getprop ro.product.name)"
  ui_print " "
  ui_print "Android Version : $(getprop ro.build.version.release)"
  ui_print " "
  ui_print "Build ID        : $(getprop ro.build.id)"
  ui_print " "
  ui_print "OS Info         : $(getprop ro.build.version.incremental)"
  ui_print " "
  ui_print "Build Date      : $(getprop ro.build.date)"
  ui_print " "
  ui_print "==============================="
}

init_main(){
  ui_print " "
}

set_permissions() {
  set_perm_recursive "$MODPATH" 0 0 0777 0755    
}

