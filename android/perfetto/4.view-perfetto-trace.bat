@echo off

set PROC=.\file\windows\trace_processor_shell.exe

:: 检查是否通过拖拽文件运行
if "%~1"=="" (
    echo Usage: %~n0 inputfile [outputfile]
    echo Or drag a file onto this script.
    pause
    exit /b 1
)

set inputfile=%~1

%PROC% --httpd "%inputfile%"

pause