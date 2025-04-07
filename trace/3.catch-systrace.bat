adb devices
adb root

:: 依赖systrace pywin32 six
:: https://dl.google.com/android/repository/platform-tools_r33.0.0-windows.zip
:: https://pypi.org/project/six/
:: Download files
:: C:\\Python27\python.exe setup.py install
:: https://sourceforge.net/projects/pywin32/
adb shell "atrace -z -b 20960 -t 5 adb aidl am audio binder_driver binder_lock bionic camera dalvik database freq gfx hal idle input memreclaim network nnapi pm power res rro rs sched sm ss sync vibrator video view webview wm workq" > atrace.out
:: py -2 systrace\systrace\systrace.py --from-file=atrace.out -o trace.html
:: del /Q atrace.out

@echo off

::时间不是两位补0
if "%date:~5,2%" lss "10" (set mm=0%date:~6,1%) else (set mm=%date:~5,2%)
if "%date:~8,2%" lss "10" (set dd=0%date:~9,1%) else (set dd=%date:~8,2%)
if "%time:~0,2%" lss "10" (set hh=0%time:~1,1%) else (set hh=%time:~0,2%)
if "%time:~3,2%" lss "10" (set nn=0%time:~4,1%) else (set nn=%time:~3,2%)

:: 年月日_时分秒
set timer=%date:~0,4%%mm%%dd%_%hh%%nn%%time:~6,2%
echo %timer%.atrace
rename atrace.out %timer%.atrace

pause