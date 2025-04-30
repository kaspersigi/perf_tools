adb devices
adb root
adb remount

adb shell -t /data/local/tmp/tracebox --txt -c /data/local/tmp/long_trace_config.pbtxt -o /data/local/tmp/trace.perfetto-trace