# 检查是否通过拖拽文件运行

system=$(uname)
platform="darwin"

if [ "$system" = "Linux" ]; then
    platform="linux"
    source ~/.bashrc
elif [ "$system" = "Darwin" ]; then
    echo "当前系统是 macOS"
    platform="darwin"
    source ~/.zshrc
else
    echo "未知系统: $system"
fi

PROC="./file/$platform/trace_processor_shell"

if [ "$#" -eq 1 ]; then
    inputfile="$1"
    echo "Input file: $inputfile"
else
    echo "Usage: $0 <inputfile> [outputfile]"
    echo "Or drag a file onto this script."
    exit 1
fi

$PROC --httpd $inputfile