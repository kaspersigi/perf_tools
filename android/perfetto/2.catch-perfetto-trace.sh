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

$ADB shell -t /data/local/tmp/perfetto --txt -c /data/local/tmp/trace_config.pbtxt -o /data/local/tmp/trace.perfetto-trace
$ADB pull /data/local/tmp/trace.perfetto-trace

# 年月日_时分秒
timer=$(date +%Y%m%d_%H%M%S)
echo $timer.perfetto-trace
mv trace.perfetto-trace $timer.perfetto-trace

# python3 ./analys/sql/analys.py -f $timer.perfetto-trace >> log.tsv
# python3 ./analys/perfetto/analys.py -f $timer.perfetto-trace