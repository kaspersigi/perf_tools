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

$ADB shell -t /data/local/tmp/tracebox --txt -c /data/local/tmp/short_trace_config.pbtxt -o /data/local/tmp/trace.compressed-perfetto-trace
$ADB pull /data/local/tmp/trace.compressed-perfetto-trace

# 年月日_时分秒
timer=$(date +%Y%m%d_%H%M%S)
echo $timer.compressed-perfetto-trace
mv trace.compressed-perfetto-trace $timer.compressed-perfetto-trace

# python3 ./analys/sql/analys_common.py -f $timer.decompressed-perfetto-trace >> log.tsv
# python3 ./analys/perfetto/analys.py -f $timer.decompressed-perfetto-trace