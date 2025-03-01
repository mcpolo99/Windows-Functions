@echo off
REM Check if script is running as administrator
net session >nul 2>&1
if not %errorlevel% == 0 (
    echo Requesting administrator privileges...
    powershell -Command "Start-Process cmd -ArgumentList '/c %~f0' -Verb RunAs"
    exit /b
)

REM Define install path
set "InstallPath=%windir%\scripts\RenameProjectFolderAndXML"

REM Create install directory if it doesn't exist
if not exist "%InstallPath%" (
    mkdir "%InstallPath%"
)

REM Copy necessary files
copy /Y "%~dp0RenameProjectFolderAndXML.ps1" "%InstallPath%\"
copy /Y "%~dp0AddContextMenu.reg" "%InstallPath%\"

REM Add registry entries for the context menu
regedit /s "%InstallPath%\AddContextMenu.reg"

echo Installation complete. Right-click a folder to use 'Rename Project Folder'.
pause
exit
