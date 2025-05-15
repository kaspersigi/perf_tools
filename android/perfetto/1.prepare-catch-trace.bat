@echo off

adb devices

adb push ./file/short_trace_config.pbtxt /data/local/tmp/
adb push ./file/long_trace_config.pbtxt /data/local/tmp/
adb push ./file/tracebox /data/local/tmp/
adb shell chmod a+x /data/local/tmp/tracebox

adb root
adb remount

adb shell mkdir -p /data/vendor/gpu
adb shell chmod 777 /data/vendor/gpu
adb push ./file/adreno_config.txt /data/vendor/gpu/

adb shell setprop persist.traced.enable 1
::adb shell setprop persist.oplus.aps.trace true

adb shell setprop persist.log.tag V

adb shell setprop persist.vendor.camera.logWarningMask 0x50080
adb shell setprop persist.vendor.camera.logEntryExitMask 0
adb shell setprop persist.vendor.camera.logCoreCfgMask 0x50080
adb shell setprop persist.vendor.camera.logConfigMask 0
adb shell setprop persist.vendor.camera.logDumpMask 0
adb shell setprop persist.vendor.camera.logInfoMask 0x50080
adb shell setprop persist.vendor.camera.logPerfInfoMask 0x50080
adb shell setprop persist.vendor.camera.logVerboseMask 0
adb shell setprop persist.vendor.camera.logDRQEnable 0
adb shell setprop persist.vendor.camera.logMetaEnable 0
adb shell setprop persist.vendor.camera.logRequestMapping 1
adb shell setprop persist.vendor.camera.enableAsciiLogging 0

adb shell setprop persist.vendor.camera.chiLogWarningMask 0
adb shell setprop persist.vendor.camera.chiLogCoreCfgMask 0x40FF
adb shell setprop persist.vendor.camera.chiLogConfigMask 0
adb shell setprop persist.vendor.camera.chiLogInfoMask 0x40FF
adb shell setprop persist.vendor.camera.chiLogDumpMask 0
adb shell setprop persist.vendor.camera.chiLogVerboseMask 0
adb shell setprop persist.vendor.camera.chiLogFullMask 0

adb shell setprop persist.vendor.camera.autoImageDump 0
adb shell setprop persist.vendor.camera.autoImageDumpMask 0x4082
adb shell setprop persist.vendor.camera.autoImageDumpIPEoutputPortMask 0x100
adb shell setprop persist.vendor.camera.autoImageDumpOFEoutputPortMask 0x20

adb shell setprop persist.vendor.camera.enableFeature2BinaryGraphDump 0
adb shell setprop persist.vendor.camera.enableFeature2PrunedGraphDump 0

adb shell setprop persist.vendor.camera.traceGroupsEnable 0x81050082
adb shell setprop persist.vendor.camera.chiLogTraceMask 0x40FF

adb shell stop perf2-hal-1-0
adb shell setprop persist.vendor.debug.trace.perf.level 2
adb shell setprop persist.vendor.debug.trace.perf 1
adb shell setprop persist.debug.trace.perf 1
adb shell start perf2-hal-1-0

adb shell pkill -f camera*

::adb shell "echo 0 > /sys/kernel/tracing/tracing_on"
::ls -la /sys/kernel/tracing/events/*/enable
::adb shell "echo 1 > /sys/kernel/tracing/tracing_on"

::adb shell "echo 1 > /proc/oplus_scheduler/sched_assist/debug_enabled"

adb shell "echo 0x1000028 > /sys/module/camera/parameters/debug_mdl"

:: CAM_ISP     3
:: CAM_SENSOR  5
:: CAM_REQ     24

:: StreamingOn for pipeline|CAM_START_DEV|cam_sensor_apply_settings|all fences done|cam_ife_hw_mgr_handle_csid_event|__cam_isp_ctx_handle_buf_done_for_request_verify_addr

::atrace_categories: "bionic" shows dlopen

::smomo log
::adb shell "service call display.smomoservice 3 i32 0 i32 0 i32 1 i32 1"

::smomo trace
::adb shell "service call display.smomoservice 7 i32 1"

::turboraw debug log
::adb shell setprop "persist.vendor.oplus.turbo.hdr.log" 2

::turbosn debug log
::adb shell setprop "com.oplus.turbo.fusion.log" 2

::依赖systrace pywin32 six
::https://dl.google.com/android/repository/platform-tools_r33.0.0-windows.zip
::https://pypi.org/project/six/
::Download files
::C:\\Python27\python.exe setup.py install
::https://sourceforge.net/projects/pywin32/
::adb shell "atrace -z -b 20960 -t 5 adb aidl am audio binder_driver binder_lock bionic camera dalvik database freq gfx hal idle input ion memreclaim network nnapi pm power res rro rs sched sm ss sync vibrator video view webview wm workq" > atrace.out
::C:\\Python27\python.exe systrace\systrace\systrace.py --from-file=atrace.out -o trace.html
::del /Q atrace.out

::app trace 掩码 *#2872*324*66#

::算法可视化 ot#es#my#oa#co

::adb pull /sdcard/Android/data/com.oplus.logkit/files/Log .

::osvelte meminfo `pidof vendor.qti.camera.provider@2.7-service_64`;osvelte meminfo `pidof cameraserver`;osvelte meminfo `pidof com.oplus.camera`

::adb shell -t /data/local/tmp/perfetto --txt -c /data/local/tmp/trace_config.pbtxt -o /data/local/tmp/trace.compressed-perfetto-trace
::adb pull /data/local/tmp/trace.compressed-perfetto-trace

pause