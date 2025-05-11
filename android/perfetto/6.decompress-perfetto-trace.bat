@echo off

set CONV=.\file\windows\traceconv.exe

:: 检查是否通过拖拽文件运行
if "%~1"=="" (
    echo Usage: %~n0 inputfile [outputfile]
    echo Or drag a file onto this script.
    pause
    exit /b 1
)

set inputfile=%~1

:: 如果没有提供输出文件名，改名decompressed-perfetto-trace
if "%~2"=="" (
    set outputfile=%~dpn1.decompressed-perfetto-trace
    echo Input file: %inputfile%
    echo Output will be saved to: %outputfile%
) else (
    set outputfile=%~2
)

:: 执行解压
echo Decompressing "%inputfile%" to "%outputfile%"...
%CONV% decompress_packets "%inputfile%" "%outputfile%"

pause