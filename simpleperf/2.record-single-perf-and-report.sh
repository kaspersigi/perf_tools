adb devices
adb root

NDK=~/android-ndk-r27c
DRAW=~/FlameGraph
# SYMFS=~/shiba/symbols
SYMFS=
PERF=$NDK/simpleperf/bin/linux/x86_64/simpleperf
FOLD=$NDK/simpleperf/stackcollapse.py
FOX=$NDK/simpleperf/gecko_profile_generator.py
PROG=android.hardware.camera.provider@2.7-service-google

adb shell /data/local/tmp/simpleperf record -e instructions -p `pidof %PROG%` --duration 10 -c 100000 -g -o /data/local/tmp/perf.data
adb pull /data/local/tmp/perf.data .

# 年月日_时分秒
timer=$(date +%Y%m%d_%H%M%S)
echo $timer.perf-data
mv perf.data $timer.perf-data

python3 $FOLD -i $timer.perf-data --symfs $SYMFS > $timer.perf-folded

python3 $FOX -i $timer.perf-data --symfs $SYMFS > $timer.json.gz

perl $DRAW/flamegraph.pl --title "$timer.perf-folded" $timer.perf-folded > $timer.svg

rm $timer.perf-folded