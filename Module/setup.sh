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
  ui_print "Extracting System Files..."
  unzip -o "$ZIPFILE" 'system/*' -d $MODPATH >&2
  ui_print " "
  ui_print "Replacing Apps"
  ui_print " "
  REPLACE="
    /system/app/BluetoothMidiService
    /system/app/CameraExtensionsProxy
    /system/app/CaptivePortalLoginGoogle
    /system/app/CertInstaller
    /system/app/CompanionDeviceManager
    /system/app/EasterEgg
    /system/app/Joyose
    /system/app/KeyChain
    /system/app/PacProcessor
    /system/app/SimAppDialog
    /system/app/Stk
    /system/app/Traceur
    /system/app/WallpaperBackup
    /system/app/WapiCertManage
    /system/priv-app/BackupRestoreConfirmation
    /system/priv-app/BlockedNumberProvider
    /system/priv-app/BuiltInPrintService
    /system/priv-app/CallLogBackup
    /system/priv-app/DeviceAsWebcam
    /system/priv-app/DeviceDiagnostics
    /system/priv-app/DynamicSystemInstallationService
    /system/priv-app/LocalTransport
    /system/priv-app/ManagedProvisioning
    /system/priv-app/MusicFX
    /system/priv-app/StatementService
    /system/priv-app/UserDictionaryProvider
    /system/product/app/Accessibility
    /system/product/app/AiasstVision
    /system/product/app/CameraTools
    /system/product/app/DeviceStatisticsService
    /system/product/app/Email
    /system/product/app/FrequentPhrase
    /system/product/app/GooglePrintRecommendationService
    /system/product/app/Health
    /system/product/app/Huanji
    /system/product/app/IFAAService
    /system/product/app/MiAONService
    /system/product/app/MiBugReport
    /system/product/app/MiGalleryLockscreen
    /system/product/app/MiLinkService
    /system/product/app/MiMacro
    /system/product/app/MipayService
    /system/product/app/MiuiCit
    /system/product/app/PaymentService
    /system/product/app/RideModeAudio
    /system/product/app/SoterService
    /system/product/app/TouchAssistant
    /system/product/app/XmsfKeeper
    /system/product/priv-app/AndroidAutoStub
    /system/product/priv-app/AutoRegistration
    /system/product/priv-app/PartnerSetup
    /system/product/priv-app/ConfigUpdater
    /system/product/priv-app/Huanji
    /system/product/priv-app/ImsServiceEntitlement
    /system/product/priv-app/MIService
    /system/product/priv-app/MiShare
    /system/product/priv-app/Mirror
    /system/product/priv-app/MiuiAICR
    /system/product/priv-app/MiuiBarrage
    /system/product/priv-app/PersonalAssistant
    /system/product/priv-app/SettingsIntelligence
    /system/system_ext/app/AccessibilityMenu
    /system/system_ext/app/BluetoothExtension
    /system/system_ext/app/CameraMind
    /system/system_ext/app/DeviceInfo
    /system/system_ext/app/MiuiPrintSpooler
    /system/system_ext/app/ModemTestBox
    /system/system_ext/app/NovaJarvis
    /system/system_ext/app/QCC
    /system/system_ext/app/QesdkSysService
    /system/system_ext/app/WAPPushManager
    /system/system_ext/app/workloadclassifier
    /system/system_ext/app/NovaJarvis
    /system/system_ext/priv-app/com.qualcomm.location
    /system/system_ext/priv-app/com.qualcomm.qti.services.systemhelper
    /system/system_ext/priv-app/TouchService"
    ui_print "Scripts will be executed on next boot."
    ui_print " "
}
#/system/app/Joyose
set_permissions() {
  set_perm_recursive "$MODPATH" 0 0 0777 0755    
}

