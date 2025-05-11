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

CONV="./file/$platform/traceconv"

if [ "$#" -eq 1 ]; then
    inputfile="$1"
    outputfile="${inputfile%.*}.decompressed-perfetto-trace"
    echo "Input file: $inputfile"
    echo "Output will be saved to: $outputfile"
elif [ "$#" -eq 2 ]; then
    inputfile="$1"
    outputfile="$2"
else
    echo "Usage: $0 <inputfile> [outputfile]"
    echo "Or drag a file onto this script."
    exit 1
fi

# 执行解压
echo "Decompressing '$inputfile' to '$outputfile'..."
$CONV decompress_packets "$inputfile" "$outputfile"