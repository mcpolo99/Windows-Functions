@echo off
setlocal EnableDelayedExpansion

:: Define installation directory
set "INSTALL_DIR=C:\Windows\Scripts\ReminderPopup"

:: Remove existing directory if it exists (to reset config and files)
if exist "%INSTALL_DIR%" (
    echo "already installed, reinstalling"
    rmdir /s /q "%INSTALL_DIR%"
    :: Delete existing task if any
    schtasks /delete /tn "ReminderPopup" /f >nul 2>&1
)

:: Create directory
mkdir "%INSTALL_DIR%"

:: Copy necessary files (overwrite if exists)
xcopy /Y "%~dp0ReminderPopup.ps1" "%INSTALL_DIR%"

:: Run PowerShell script to configure schedule
powershell -ExecutionPolicy Bypass -File "%INSTALL_DIR%\ReminderPopup.ps1"


:: Done
echo Installation complete.