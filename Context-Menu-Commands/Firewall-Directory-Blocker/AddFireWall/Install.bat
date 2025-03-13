@echo off

rem Check if the script is running as administrator
net session >nul 2>&1
if not %errorlevel% == 0 (
    echo.
    echo This script needs to be run as an administrator.
    echo.
    echo Requesting elevated privileges...
    
    rem Re-run the script as an administrator
	powershell -Command "Start-Process 'cmd.exe' -ArgumentList '/k \"%~f0\" %*' -Verb RunAs"
    rem cmd /k -ArgumentList %~f0 -Verb RunAs
	echo  %~f0
	echo  %*
	
	exit /b
)

REM Check if directory exists
if not exist "%windir%\scripts\AddFireWall" (
    echo Directory %windir%\scripts\AddFireWall does not exist. Creating directory...
    mkdir "%windir%\scripts\AddFireWall"
) else (
    echo Directory %windir%\scripts\AddFireWall already exists.
)

REM Copy files from the current directory to the target directory
echo Copying files to %windir%\scripts\AddFireWall...
copy /Y "%~dp0Add.reg" "%windir%\scripts\AddFireWall\"
copy /Y "%~dp0FireWallAdd.ps1" "%windir%\scripts\AddFireWall\"
copy /Y "%~dp0run.bat" "%windir%\scripts\AddFireWall\"

REM Execute the .reg file to add entries to the registry
echo Executing Add.reg...
regedit /s "%windir%\scripts\AddFireWall\Add.reg"

echo Installation complete.
exit 
exit 