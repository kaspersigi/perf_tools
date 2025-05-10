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
    source ~/.zshrc
else
    echo "未知系统: $system"
fi

$ADB devices
$ADB root
$ADB remount

$ADB shell -t /data/local/tmp/tracebox --txt -c /data/local/tmp/long_trace_config.pbtxt -o /data/local/tmp/trace.perfetto-trace