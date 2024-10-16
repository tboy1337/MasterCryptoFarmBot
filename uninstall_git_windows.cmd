@echo off
setlocal enabledelayedexpansion

set "possibleInstalledPaths=C:\Program Files\Git C:\Program Files (x86)\Git C:\git"
set gitFound=false

echo Checking for GIT install.

for %%G in (%possibleInstalledPaths%) do (
    if exist "%%G" (
        taskkill /F /IM bash.exe /T >nul 2>&1
        taskkill /F /IM putty* /T >nul 2>&1
        
        echo Removing GIT from "%%G"

        for %%U in ("%%G\unins*.exe") do (
            "%%U" /SP- /VERYSILENT /SUPPRESSMSGBOXES /FORCECLOSEAPPLICATIONS
        )

        set gitFound=true
    )
)

if "!gitFound!"=="false" (
    echo No GIT install found.  Nothing to uninstall.
)

timeout /t 5
exit
