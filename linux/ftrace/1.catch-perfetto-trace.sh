./file/tracebox --txt -c ./file/trace_config.pbtxt -o trace.perfetto-trace

# 年月日_时分秒
timer=$(date +%Y%m%d_%H%M%S)
echo $timer.perfetto-trace
mv trace.perfetto-trace $timer.perfetto-trace