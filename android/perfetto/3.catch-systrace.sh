adb devices
adb root

# 依赖systrace pywin32 six
# https://dl.google.com/android/repository/platform-tools_r33.0.0-windows.zip
# https://pypi.org/project/six/
# Download files
# C:\\Python27\python.exe setup.py install
# https://sourceforge.net/projects/pywin32/
adb shell "atrace -z -b 20960 -t 5 adb aidl am audio binder_driver binder_lock bionic camera dalvik database freq gfx hal idle input memreclaim network nnapi pm power res rro rs sched sm ss sync vibrator video view webview wm workq" > atrace.out
# python2 systrace\systrace\systrace.py --from-file=atrace.out -o trace.html
# rm -r atrace.out

# 年月日_时分秒
timer=$(date +%Y%m%d_%H%M%S)
echo $timer.ctrace
mv atrace.out $timer.ctrace