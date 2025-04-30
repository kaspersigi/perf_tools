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
$ADB root

# 依赖systrace pywin32 six
# https://dl.google.com/android/repository/platform-tools_r33.0.0-windows.zip
# https://pypi.org/project/six/
# Download files
# C:\\Python27\python.exe setup.py install
# https://sourceforge.net/projects/pywin32/

# $ADB shell "atrace -z -b 20960 -t 5 adb aidl am audio binder_driver binder_lock bionic camera dalvik database freq gfx hal idle input memreclaim network nnapi pm power res rro rs sched sm ss sync vibrator video view webview wm workq" > atrace.out
# python2 systrace\systrace\systrace.py --from-file=atrace.out -o trace.html
# rm -r atrace.out

$ADB shell "atrace -b 20960 -t 5 adb aidl am audio binder_driver binder_lock bionic camera dalvik database freq gfx hal idle input memreclaim network nnapi pm power res rro rs sched sm ss sync vibrator video view webview wm workq" > atrace.systrace

# 年月日_时分秒
timer=$(date +%Y%m%d_%H%M%S)
# echo $timer.ctrace
# mv atrace.out $timer.ctrace

echo $timer.systrace
mv atrace.systrace $timer.systrace