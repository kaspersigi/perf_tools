adb devices
adb root
adb remount

set NDK=C:\Users\kaspe\Downloads\android-ndk-r27c
set DRAW=FlameGraph
set SYMFS=C:\Users\kaspe\Downloads\shiba\symbols
set PERF=%NDK%\simpleperf\bin\windows\x86_64\simpleperf.exe
set FOLD=%NDK%\simpleperf\stackcollapse.py
set FOX=%NDK%\simpleperf\gecko_profile_generator.py
set PROG=android.hardware.camera.provider@2.7-service-google

adb shell /data/local/tmp/simpleperf record -e instructions -a --duration 10 -c 100000 -g -o /data/local/tmp/perf.data
adb pull /data/local/tmp/perf.data .

@echo off

::时间不是两位补0
if "%date:~5,2%" lss "10" (set mm=0%date:~6,1%) else (set mm=%date:~5,2%)
if "%date:~8,2%" lss "10" (set dd=0%date:~9,1%) else (set dd=%date:~8,2%)
if "%time:~0,2%" lss "10" (set hh=0%time:~1,1%) else (set hh=%time:~0,2%)
if "%time:~3,2%" lss "10" (set nn=0%time:~4,1%) else (set nn=%time:~3,2%)

:: 年月日_时分秒
set timer=%date:~0,4%%mm%%dd%_%hh%%nn%%time:~6,2%
echo %timer%.perf-data
rename perf.data %timer%.perf-data

::py -3 %FOLD% -i %timer%.perf-data --symfs %SYMFS% > %timer%.perf-folded
py -3 %FOLD% -i %timer%.perf-data > %timer%.perf-folded

::py -3 %FOX% -i %timer%.perf-data --symfs %SYMFS% > %timer%.json.gz
py -3 %FOLD% -i %timer%.perf-data > %timer%.json.gz

perl %DRAW%\flamegraph.pl --title "%timer%.perf-folded" %timer%.perf-folded > %timer%.svg

del %timer%.perf-folded

pause