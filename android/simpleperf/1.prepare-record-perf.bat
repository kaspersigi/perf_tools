@echo off

adb devices

set NDK=%USERPROFILE%\Downloads\android-ndk-r27c
adb push %NDK%/simpleperf/bin/android/arm64/simpleperf /data/local/tmp/
adb shell chmod a+x /data/local/tmp/simpleperf

pause