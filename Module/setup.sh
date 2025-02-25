#!/sbin/sh
SKIPMOUNT=false
PROPFILE=false
POSTFSDATA=true
LATESTARTSERVICE=true

info_print() {
  ui_print "*******************************"
  ui_print "        Hyper Optimize         "
  ui_print "       Created by:Tatsh        "
  ui_print "*******************************"
  ui_print "Uninstall this if stuck at boot"
  ui_print "*******************************"
}

init_main(){
  ui_print " "
}

set_permissions() {
  set_perm_recursive "$MODPATH" 0 0 0777 0755    
}

