adb devices
adb root

adb shell -t /data/local/tmp/perfetto --txt -c /data/local/tmp/trace_config.pbtxt -o /data/local/tmp/trace.perfetto-trace
adb pull /data/local/tmp/trace.perfetto-trace

@echo off

::时间不是两位补0
if "%date:~5,2%" lss "10" (set mm=0%date:~6,1%) else (set mm=%date:~5,2%)
if "%date:~8,2%" lss "10" (set dd=0%date:~9,1%) else (set dd=%date:~8,2%)
if "%time:~0,2%" lss "10" (set hh=0%time:~1,1%) else (set hh=%time:~0,2%)
if "%time:~3,2%" lss "10" (set nn=0%time:~4,1%) else (set nn=%time:~3,2%)

:: 年月日_时分秒
set timer=%date:~0,4%%mm%%dd%_%hh%%nn%%time:~6,2%
echo %timer%.perfetto-trace
rename trace.perfetto-trace %timer%.perfetto-trace

:: py -3 ./analys/sql/analys.py -f %timer%.perfetto-trace >> log.tsv
:: py -3 ./analys/perfetto/analys.py -f %timer%.perfetto-trace

pause