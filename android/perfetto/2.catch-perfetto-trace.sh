adb devices
adb root

adb shell -t /data/local/tmp/perfetto --txt -c /data/local/tmp/trace_config.pbtxt -o /data/local/tmp/trace.perfetto-trace
adb pull /data/local/tmp/trace.perfetto-trace

# 年月日_时分秒
timer=$(date +%Y%m%d_%H%M%S)
echo $timer.perfetto-trace
mv trace.perfetto-trace $timer.perfetto-trace

python3 ./analys/sql/analys.py -f $timer.perfetto-trace >> log.tsv
python3 ./analys/perfetto/analys.py -f $timer.perfetto-trace