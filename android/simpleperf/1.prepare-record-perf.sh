system=$(uname)

if [ "$system" = "Linux" ]; then
    if grep -q "microsoft" /proc/sys/kernel/osrelease; then
        echo "当前系统是 WSL"
        ADB="adb.exe"
    else
        echo "当前系统是 Linux"
        ADB="adb"
    fi
    source ~/.bashrc
elif [ "$system" = "Darwin" ]; then
    echo "当前系统是 macOS"
    ADB="adb"
    source ~/.zshrc
else
    echo "未知系统: $system"
fi

$ADB devices

NDK=~/linux/android-ndk-r27c
$ADB push $NDK/simpleperf/bin/android/arm64/simpleperf /data/local/tmp/
$ADB shell chmod a+x /data/local/tmp/simpleperf