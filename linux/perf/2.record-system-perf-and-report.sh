DRAW=./FlameGraph
PROG=main

perf record -F 99 -a -g -- sleep 10
perf script > out.perf-txt

# 年月日_时分秒
timer=$(date +%Y%m%d_%H%M%S)
echo $timer.perf-data
mv perf.data $timer.perf-data
mv out.perf-txt $timer.perf-txt

perl $DRAW/stackcollapse-perf.pl $timer.perf-txt > $timer.perf-folded

perl $DRAW/flamegraph.pl --title "$timer.perf-folded" $timer.perf-folded > $timer.svg

rm $timer.perf-folded