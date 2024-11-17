@echo off
setlocal enabledelayedexpansion

set "DOWNLOAD_URL=https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe"
set "INSTALLER_NAME=Docker Desktop Installer.exe"

set "TEMP_DIR=%TEMP%\DockerInstall_%RANDOM%"
set "DOWNLOAD_TASK=DownloadTask_%RANDOM%"

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo This script requires administrator privileges.
    echo Please right-click and select "Run as administrator".
    timeout /t 5 /nobreak
    exit /b 4
)

mkdir "%TEMP_DIR%" >nul 2>nul
if %errorlevel% neq 0 (
    echo Failed to create temporary Docker install directory.
    timeout /t 5 /nobreak
    exit /b 3
)

cd /d "%TEMP_DIR%" >nul 2>nul
if %errorlevel% neq 0 (
    echo Failed to change to temporary Docker install directory.
    timeout /t 5 /nobreak
    exit /b 2
)

where curl >nul 2>nul
if %errorlevel% equ 0 (
    echo Attempting to download Docker Desktop with curl...
    curl -o "%INSTALLER_NAME%" -L "%DOWNLOAD_URL%" >nul 2>nul
    if %errorlevel% equ 0 goto :verify_download
    echo Curl download failed, trying PowerShell...
)

where powershell >nul 2>nul
if %errorlevel% equ 0 (
    echo Attempting to download Docker Desktop with PowerShell...
    start /wait powershell -WindowStyle Hidden -Command "$ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest -OutFile '%INSTALLER_NAME%' -Uri '%DOWNLOAD_URL%'"
    if %errorlevel% equ 0 goto :verify_download
    echo PowerShell download failed, trying bitsadmin...
)

echo Attempting to download Docker Desktop with bitsadmin...
(
echo bitsadmin /transfer %DOWNLOAD_TASK% /download /priority FOREGROUND /DYNAMIC "%DOWNLOAD_URL%" "%TEMP_DIR%\%INSTALLER_NAME%"
) > "set_task.cmd" 2>nul

if %errorlevel% neq 0 (
    echo Failed to write to temporary directory.
    goto :dockererror
)

start /wait schtasks /create /tn "RunAsSystemTask" /tr "cmd /c %TEMP_DIR%\set_task.cmd" /sc once /st 23:59 /ru SYSTEM >nul 2>nul
if %errorlevel% neq 0 (
    echo All download methods failed.
    goto :dockererror
)

start /wait schtasks /run /tn "RunAsSystemTask" >nul 2>nul
if %errorlevel% neq 0 (
    echo All download methods failed.
    start /wait schtasks /delete /tn "RunAsSystemTask" /f >nul 2>nul
    if %errorlevel% neq 0 (
        echo Failed to delete scheduled task, please delete "RunAsSystemTask" manually.
    )
    goto :dockererror
)

:waitloop
if not exist "%TEMP_DIR%\%INSTALLER_NAME%" (
    timeout /t 2 /nobreak >nul 2>nul
    goto waitloop
)

timeout /t 2 /nobreak >nul 2>nul

start /wait schtasks /delete /tn "RunAsSystemTask" /f >nul 2>nul
if %errorlevel% neq 0 (
    echo Failed to delete scheduled task, please delete "RunAsSystemTask" manually.
)

:verify_download
if not exist "%TEMP_DIR%\%INSTALLER_NAME%" (
    echo Download appears to have failed - installer not found.
    goto :dockererror
)

echo Installing Docker Desktop...
start /wait "" "%INSTALLER_NAME%" install --quiet --accept-license >nul 2>nul
if %errorlevel% neq 0 (
    echo Failed to install Docker.
    goto :dockererror
)

echo Docker installation completed successfully.
goto :dockercleanup

:dockererror
echo An error occurred during the Docker installation process.
call :dockercleanup
exit /b 1

:dockercleanup
echo Cleaning up...
timeout /t 2 /nobreak >nul 2>nul
cd /d "%TEMP%" >nul 2>nul
if %errorlevel% neq 0 (
    echo Failed to change to temporary directory for Docker install cleanup.
)
rd /s /q "%TEMP_DIR%" >nul 2>nul
if %errorlevel% neq 0 (
    echo Failed to remove temporary Docker install directory. Please delete "%TEMP_DIR%" manually.
) else (
    echo Clean up successful.
)
timeout /t 5 /nobreak

exit /b 0
