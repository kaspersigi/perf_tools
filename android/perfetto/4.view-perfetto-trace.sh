system=$(uname)
platform="darwin"

if [ "$system" = "Linux" ]; then
    if grep -q "microsoft" /proc/sys/kernel/osrelease; then
        echo "当前系统是 WSL"
        ADB="adb.exe"
        platform="windows"
    else
        echo "当前系统是 Linux"
        ADB="adb"
        platform="linux"
    fi
    source ~/.bashrc
elif [ "$system" = "Darwin" ]; then
    echo "当前系统是 macOS"
    ADB="adb"
    platform="darwin"
    source ~/.zprofile
else
    echo "未知系统: $system"
fi

$ADB devices
$ADB root

$ADB pull /data/local/tmp/trace.perfetto-trace

# 年月日_时分秒
timer=$(date +%Y%m%d_%H%M%S)
echo $timer.perfetto-trace
mv trace.perfetto-trace $timer.perfetto-trace

if [ platform="windows" ]; then
    ./file/$platform/trace_processor_shell.exe --httpd $timer.perfetto-trace
else
    ./file/$platform/trace_processor_shell --httpd $timer.perfetto-trace
fi

# python3 ./analys/sql/analys.py -f $timer.perfetto-trace >> log.tsv
# python3 ./analys/perfetto/analys.py -f $timer.perfetto-trace