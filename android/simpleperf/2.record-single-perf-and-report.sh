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

NDK=~/linux/android-ndk-r27c
DRAW=./FlameGraph
SYMFS=~/shiba/symbols
PERF=$NDK/simpleperf/bin/linux/x86_64/simpleperf
FOLD=$NDK/simpleperf/stackcollapse.py
FOX=$NDK/simpleperf/gecko_profile_generator.py
PROG=android.hardware.camera.provider@2.7-service-google

$ADB shell /data/local/tmp/simpleperf record -e instructions -p `pidof $PROG` --duration 10 -c 100000 -g -o /data/local/tmp/perf.data
$ADB pull /data/local/tmp/perf.data .

# 年月日_时分秒
timer=$(date +%Y%m%d_%H%M%S)
echo $timer.perf-data
mv perf.data $timer.perf-data

# python3 $FOLD -i $timer.perf-data --symfs $SYMFS > $timer.perf-folded
python3 $FOLD -i $timer.perf-data > $timer.perf-folded

# python3 $FOX -i $timer.perf-data --symfs $SYMFS > $timer.perf-profile
python3 $FOX -i $timer.perf-data > $timer.perf-profile

perl $DRAW/flamegraph.pl --title "$timer.perf-folded" $timer.perf-folded > $timer.svg

rm $timer.perf-folded