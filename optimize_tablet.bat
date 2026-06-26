@echo off
echo =======================================================
echo   BEESITTO K102 / K900 Tablet Optimization Script
echo =======================================================
echo.
echo Make sure your tablet is connected via USB, ADB is enabled,
echo and you have already flashed the rooted boot image and opened Magisk.
echo.
pause

echo.
echo 1. Removing Chinese bloatware and spoofed benchmarks...
adb shell su -c "pm uninstall -k --user 0 com.example"
adb shell su -c "pm uninstall -k --user 0 com.baidu.map.location"
adb shell su -c "pm uninstall -k --user 0 com.antutu.ABenchMark"
adb shell su -c "pm uninstall -k --user 0 com.cpuid.cpu_z"
adb shell su -c "pm uninstall -k --user 0 com.mediatek.mtklogger"
adb shell su -c "pm uninstall -k --user 0 com.mediatek.duraspeed"

echo.
echo 2. Pushing performance optimizations script...
adb push optimizations.sh /data/local/tmp/optimizations.sh
adb shell su -c "cp /data/local/tmp/optimizations.sh /data/adb/service.d/optimizations.sh"
adb shell su -c "chmod 755 /data/adb/service.d/optimizations.sh"
adb shell su -c "rm /data/local/tmp/optimizations.sh"

echo.
echo 3. Setting up Systemless Hosts Adblocker...
adb shell su -c "mkdir -p /data/adb/modules/hosts/system/etc"
adb shell su -c "echo 'id=hosts' > /data/adb/modules/hosts/module.prop"
adb shell su -c "echo 'name=Systemless Hosts' >> /data/adb/modules/hosts/module.prop"
adb shell su -c "echo 'version=1.0' >> /data/adb/modules/hosts/module.prop"
adb shell su -c "echo 'versionCode=1' >> /data/adb/modules/hosts/module.prop"
adb shell su -c "echo 'author=Magisk' >> /data/adb/modules/hosts/module.prop"
adb shell su -c "echo 'description=Systemless hosts redirection' >> /data/adb/modules/hosts/module.prop"
adb push hosts /data/local/tmp/hosts
adb shell su -c "cp /data/local/tmp/hosts /data/adb/modules/hosts/system/etc/hosts"
adb shell su -c "chmod 644 /data/adb/modules/hosts/system/etc/hosts"
adb shell su -c "chmod 755 /data/adb/modules/hosts"
adb shell su -c "rm /data/local/tmp/hosts"

echo.
echo 4. Applying optimizations right now...
adb shell su -c "sh /data/adb/service.d/optimizations.sh"

echo.
echo =======================================================
echo   Optimizations Applied Successfully!
echo   Please reboot your tablet to ensure everything loads.
echo =======================================================
pause
