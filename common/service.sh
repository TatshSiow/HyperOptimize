#!/system/bin/sh
# Please don't hardcode /magisk/modname/... ; instead, please use $MODDIR/...
# This will make your scripts compatible even if Magisk change its mount point in the future
am kill bootlogoupdater
killall -9 bootlogoupdater
am kill bootlogoupdater.rc
killall -9 bootlogoupdater.rc

sleep 5

#by longx
am kill mdnsd
killall -9 mdnsd
am kill mdnsd.rc
killall -9 mdnsd.rc

am kill mobile_log_d
killall -9 mobile_log_d
am kill mobile_log_d.rc
killall -9 mobile_log_d.rc

am kill dumpstate
killall -9 dumpstate
am kill dumpstate.rc
killall -9 dumpstate.rc


am kill emdlogger1
killall -9 emdlogger1
am kill emdlogger1.rc
killall -9 emdlogger1.rc

am kill emdlogger3
killall -9 emdlogger3
am kill emdlogger3.rc
killall -9 emdlogger3.rc

am kill mdlogger
killall -9 mdlogger
am kill mdlogger.rc
killall -9 mdlogger.rc

am kill aee.log-1-0
killall -9 aee.log-1-0
am kill aee.log-1-0.rc
killall -9 aee.log-1-0.rc

am kill connsyslogger
killall -9 connsyslogger
am kill connsyslogger.rc
killall -9 connsyslogger.rc

am kill bootlogoupdater
killall -9 bootlogoupdater
am kill bootlogoupdater.rc
killall -9 bootlogoupdater.rc

# This script will be executed in late_start service mode
# More info in the main Magisk thread
