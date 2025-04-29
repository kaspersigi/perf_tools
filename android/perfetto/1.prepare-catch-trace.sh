system=$(uname)

if [ "$system" = "Linux" ]; then
    if grep -q "microsoft" /proc/sys/kernel/osrelease; then
        echo "当前系统是 WSL"
        ADB="adb.exe"
    else
        echo "当前系统是 Linux"
        ADB="adb"
    fi
    source ~/.bashrc
elif [ "$system" = "Darwin" ]; then
    echo "当前系统是 macOS"
    ADB="adb"
    source ~/.zprofile
else
    echo "未知系统: $system"
fi

$ADB devices

$ADB push ./file/trace_config.pbtxt /data/local/tmp/
$ADB push ./file/perfetto /data/local/tmp/
$ADB shell chmod a+x /data/local/tmp/perfetto

$ADB root
$ADB remount

$ADB shell mkdir -p /data/vendor/gpu
$ADB shell chmod 777 /data/vendor/gpu
$ADB push ./file/adreno_config.txt /data/vendor/gpu/

$ADB shell setprop persist.traced.enable 1
# $ADB shell setprop persist.oplus.aps.trace true

$ADB shell setprop persist.vendor.camera.logWarningMask 0x50080
$ADB shell setprop persist.vendor.camera.logEntryExitMask 0
$ADB shell setprop persist.vendor.camera.logCoreCfgMask 0x50080
$ADB shell setprop persist.vendor.camera.logConfigMask 0
$ADB shell setprop persist.vendor.camera.logDumpMask 0
$ADB shell setprop persist.vendor.camera.logInfoMask 0x50080
$ADB shell setprop persist.vendor.camera.logPerfInfoMask 0x50080
$ADB shell setprop persist.vendor.camera.logVerboseMask 0
$ADB shell setprop persist.vendor.camera.logDRQEnable 0
$ADB shell setprop persist.vendor.camera.logMetaEnable 0
$ADB shell setprop persist.vendor.camera.logRequestMapping 1
$ADB shell setprop persist.vendor.camera.enableAsciiLogging 0

$ADB shell setprop persist.vendor.camera.chiLogWarningMask 0
$ADB shell setprop persist.vendor.camera.chiLogCoreCfgMask 0x40FF
$ADB shell setprop persist.vendor.camera.chiLogConfigMask 0
$ADB shell setprop persist.vendor.camera.chiLogInfoMask 0x40FF
$ADB shell setprop persist.vendor.camera.chiLogDumpMask 0
$ADB shell setprop persist.vendor.camera.chiLogVerboseMask 0
$ADB shell setprop persist.vendor.camera.chiLogFullMask 0

$ADB shell setprop persist.vendor.camera.autoImageDump 0
$ADB shell setprop persist.vendor.camera.autoImageDumpMask 0x4082
$ADB shell setprop persist.vendor.camera.autoImageDumpIPEoutputPortMask 0x100
$ADB shell setprop persist.vendor.camera.autoImageDumpOFEoutputPortMask 0x20

$ADB shell setprop persist.vendor.camera.enableFeature2BinaryGraphDump 0
$ADB shell setprop persist.vendor.camera.enableFeature2PrunedGraphDump 0

$ADB shell setprop persist.vendor.camera.traceGroupsEnable 0x81050482
$ADB shell setprop persist.vendor.camera.chiLogTraceMask 0x40FF

$ADB shell stop perf2-hal-1-0
$ADB shell setprop vendor.debug.trace.perf.level 2
$ADB shell setprop vendor.debug.trace.perf 1
$ADB shell setprop debug.trace.perf 1
$ADB shell start perf2-hal-1-0

$ADB shell pkill -f camera*

# adb shell "echo 0 > /sys/kernel/tracing/tracing_on"
# ls -la /sys/kernel/tracing/events/*/enable
# adb shell "echo 1 > /sys/kernel/tracing/tracing_on"

# adb shell "echo 1 > /proc/oplus_scheduler/sched_assist/debug_enabled"

# adb shell "echo 0x140003A > /sys/module/camera/parameters/debug_mdl"

# CAM_CORE    1
# CAM_ISP     3
# CAM_CRM     4
# CAM_SENSOR  5
# CAM_MEM     22
# CAM_REQ     24

# atrace_categories: "bionic"  shows dlopen

# smomo log
# adb shell "service call display.smomoservice 3 i32 0 i32 0 i32 1 i32 1"

# smomo trace
# adb shell "service call display.smomoservice 7 i32 1"

# turboraw debug log
# adb shell setprop "persist.vendor.oplus.turbo.hdr.log" 2

# turbosn debug log
# adb shell setprop "com.oplus.turbo.fusion.log" 2

# 依赖systrace pywin32 six
# https://dl.google.com/android/repository/platform-tools_r33.0.0-windows.zip
# https://pypi.org/project/six/
# Download files
# C:\\Python27\python.exe setup.py install
# https://sourceforge.net/projects/pywin32/
# adb shell "atrace -z -b 20960 -t 5 adb aidl am audio binder_driver binder_lock bionic camera dalvik database freq gfx hal idle input ion memreclaim network nnapi pm power res rro rs sched sm ss sync vibrator video view webview wm workq" > atrace.out
# C:\\Python27\python.exe systrace\systrace\systrace.py --from-file=atrace.out -o trace.html
# del /Q atrace.out

# app trace 掩码 *#2872*324*66#

# 算法可视化 ot#es#my#oa#co

# adb pull /sdcard/Android/data/com.oplus.logkit/files/Log .

# osvelte meminfo `pidof vendor.qti.camera.provider@2.7-service_64`;osvelte meminfo `pidof cameraserver`;osvelte meminfo `pidof com.oplus.camera`

# adb shell -t /data/local/tmp/perfetto --txt -c /data/local/tmp/trace_config.pbtxt -o /data/local/tmp/trace.perfetto-trace
# adb pull /data/local/tmp/trace.perfetto-trace