ARCH=$(uname -m)

./file/$ARCH/tracebox --txt -c ./file/trace_config.pbtxt -o trace.perfetto-trace

# 年月日_时分秒
timer=$(date +%Y%m%d_%H%M%S)
echo $timer.perfetto-trace
chmod a+rw trace.perfetto-trace
mv trace.perfetto-trace $timer.perfetto-trace