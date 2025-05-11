ARCH=$(uname -m)

./file/$ARCH/tracebox --txt -c ./file/trace_config.pbtxt -o trace.compressed-perfetto-trace

# 年月日_时分秒
timer=$(date +%Y%m%d_%H%M%S)
echo $timer.compressed-perfetto-trace
chmod a+rw trace.compressed-perfetto-trace
mv trace.compressed-perfetto-trace $timer.compressed-perfetto-trace