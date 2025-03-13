@echo off
::rem net.exe session 1>NUL 2>NUL || (Echo This script requires elevated rights. & pause /b 1)
echo %time% start of bat file >> %temp%\FireWallAdd_debug.log
echo %time% passing parameters "%~1" "%~2" >> %temp%\FireWallAdd_debug.log

echo %time% Check if running with administrative privileges>> %temp%\FireWallAdd_debug.log


net session >nul 2>&1
echo %time%  Error level %errorlevel% >> %temp%\FireWallAdd_debug.log
if not %errorlevel% == 0  (
	echo %time% >> %temp%\FireWallAdd_debug.log
    echo %time% Not running as admin, restart as admin >> %temp%\FireWallAdd_debug.log
    powershell -Command "Start-Process cmd -ArgumentList '/c %~f0 \"%~1\"' -Verb RunAs"
	echo %time% >> %temp%\FireWallAdd_debug.log
	exit /b
)
echo %time% >> %temp%\FireWallAdd_debug.log
echo %time% Running as admin >> %temp%\FireWallAdd_debug.log



echo %time% Change Path to "%~1" >> %temp%\FireWallAdd_debug.log
cd /d "%~1"

echo %time% Running script with elevated permissions >> %temp%\FireWallAdd_debug.log
powershell.exe -NoExit -ExecutionPolicy Bypass -File "%systemroot%\scripts\AddFireWall\FireWallAdd.ps1" -Verb RunAS



echo %time% end of bat file >> %temp%\FireWallAdd_debug.log