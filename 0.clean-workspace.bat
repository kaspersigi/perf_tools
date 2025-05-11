@echo off

powershell -Command "Get-ChildItem -Recurse -Filter *.pyc | Remove-Item; Get-ChildItem -Recurse -Directory -Filter __pycache__ | Remove-Item -Recurse"

pause