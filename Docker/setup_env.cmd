@echo off
setlocal enabledelayedexpansion

:: Time zones list file
set TZ_FILE=timezones.txt

:: Check if timezones.txt exists
if not exist "%TZ_FILE%" (
    echo Error: timezones.txt not found in the current directory.
    echo Please make sure timezones.txt contains the list of time zones and is in the format: Region/Area (e.g., Africa/Bujumbura).
    pause
    exit /b 1
)

:: Function to filter input
:filter_input
cls
echo %~2
set "filtered="
for /f "delims=" %%G in ('findstr /i "^%~1" "%TZ_FILE%"') do (
    set "filtered=!filtered! %%G"
)

:: Display matches
for %%G in (!filtered!) do echo %%G

:: Check remaining matches
set "match="
for %%G in (!filtered!) do (
    set "match=%%G"
)

if "!filtered!" == "" (
    echo No matches found. Please try again.
    pause
    exit /b 1
) else (
    if "!filtered!" == "!match!" (
        set "%~3=!match!"
        exit /b 0
    )
)
goto :filter_input

:: Ask for region
:ask_region
call :filter_input "" "Type your region (e.g., Europe, Pacific):" "REGION"
if errorlevel 1 goto :ask_region

:: Ask for subregion
:ask_subregion
call :filter_input "!REGION!/" "Type your subregion (e.g., London):" "SUBREGION"
if errorlevel 1 goto :ask_subregion

:: Ask for Docker save location
:ask_location
cls
echo Please specify the full path where Docker will run (e.g., C:\Docker):
set /p "SAVE_LOCATION=Save location: "
if not exist "%SAVE_LOCATION%" (
    echo The specified path does not exist. Please try again.
    pause
    goto :ask_location
)

:: Create .env file
set ENV_FILE=.env
echo MCF_PATH=%SAVE_LOCATION%>%ENV_FILE%
echo TZ=%REGION%/%SUBREGION%>>%ENV_FILE%

:: Copy files
if not exist "%SAVE_LOCATION%" (
    mkdir "%SAVE_LOCATION%"
)

copy /y "%ENV_FILE%" "%SAVE_LOCATION%"
copy /y "Dockerfile" "%SAVE_LOCATION%"
copy /y "docker-compose.yml" "%SAVE_LOCATION%"

cls
echo Configuration complete!
echo .env file and Docker files have been copied to: %SAVE_LOCATION%
pause
exit /b 0
