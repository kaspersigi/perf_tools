DRAW=./FlameGraph
PROG=main

perf record -e instructions -p `pidof $PROG` --duration 10 -c 100000 -g -o perf.data

# 年月日_时分秒
timer=$(date +%Y%m%d_%H%M%S)
echo $timer.perf-data
mv perf.data $timer.perf-data

python3 $FOLD -i $timer.perf-data > $timer.perf-folded

python3 $FOX -i $timer.perf-data > $timer.json.gz

perl $DRAW/flamegraph.pl --title "$timer.perf-folded" $timer.perf-folded > $timer.svg

rm $timer.perf-folded