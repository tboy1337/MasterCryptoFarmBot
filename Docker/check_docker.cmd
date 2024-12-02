@echo off

docker --version >nul 2>&1
if %ERRORLEVEL% equ 0 (
    echo Docker is installed!!!
) else (
    echo Docker is not installed.
)

exit
