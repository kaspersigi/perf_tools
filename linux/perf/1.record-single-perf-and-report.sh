DRAW=./FlameGraph
PROG=main

perf record -F 999 -g -p `pidof $PROG` -- sleep 10
perf script > out.perf-txt

# 年月日_时分秒
timer=$(date +%Y%m%d_%H%M%S)
echo $timer.perf-data
mv perf.data $timer.perf-data
mv out.perf-txt $timer.perf-txt

perl $DRAW/flamegraph.pl --title "$timer.perf-folded" $timer.perf-folded > $timer.svg