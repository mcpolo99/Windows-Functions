@echo off
REM echo %1
setlocal ENABLEDELAYEDEXPANSION
set "vDir=%~1"

REM :loop
REM for /f "delims=\ tokens=1,*" %%A in ("%vDir%") do (
	REM REM echo "loop start: %vDir%"
    REM set "_last=%%A"
    REM set "vDir=%%B"
	REM REM echo "Last: %_last%"
	REM REM echo "loop end: %%B"
	REM REM echo "  "
REM )
REM if NOT "%vDir%"=="" goto loop
REM echo Folder last name is :!_last!:

REM echo !_last!-Symlinkshortcut
REM echo %~1

REM mklink /d !_last!-Symlinkshortcut %~1


REM powershell.exe -NoExit -Command "$target = '%~1';
	REM $target = $target.Trim('\"'); 
	REM $name = Split-Path $target -Leaf; 
	REM $parentdir = Split-Path $target -Parent -Resolve; 
	REM $parentdir = Resolve-Path $parentdir
	REM $full = Resolve-Path $target;
	REM Write-Host($target); 
	REM Write-Host($name); 
	REM Write-Host($full); 
	REM Write-Host($parentdir);
	REM New-Item -ItemType SymbolicLink -Path $parentdir$name"link" -Value $full;" -Verb RunAs
	
	
REM powershell.exe -NoExit -Command "$target = '%~1';$target = $target.Trim('\"');$name = Split-Path $target -Leaf;$parentdir = Split-Path $target -Parent -Resolve;$parentdir = Resolve-Path $parentdir;$full = Resolve-Path $target;Write-Host($target);Write-Host($name);Write-Host($full);Write-Host($parentdir);New-Item -ItemType SymbolicLink -Path $parentdir+$name+"link" -Value $full;"

REM powershell.exe -Command "Start-Process powershell -ArgumentList '-NoExit','-Command','Write-Host Elevated session' -Verb RunAs"
REM powershell.exe -Command "Start-Process powershell -Verb RunAs -ArgumentList '-NoExit','-Command','`$target = ''%~1''; `$target = `$target.Trim(''\"''); `$name = Split-Path `$target -Leaf; `$parentdir = Split-Path `$target -Parent -Resolve; `$parentdir = Resolve-Path `$parentdir; `$full = Resolve-Path `$target; Write-Host `$target; Write-Host `$name; Write-Host `$full; Write-Host `$parentdir; New-Item -ItemType SymbolicLink -Path (`$parentdir.Path + ''\\'' + `$name + ''-link'') -Value `$full.Path'""



REM cABhAHIAYQBtACgAJAB0AGEAcgBnAGUAdAApAA0ACgANAAoAJAB0AGEAcgBnAGUAdAAgAD0AIAAkAHQAYQByAGcAZQB0AC4AVAByAGkAbQAoACcAIgAnACkADQAKACQAbgBhAG0AZQAgAD0AIABTAHAAbABpAHQALQBQAGEAdABoACAAJAB0AGEAcgBnAGUAdAAgAC0ATABlAGEAZgANAAoAJABwAGEAcgBlAG4AdABkAGkAcgAgAD0AIABTAHAAbABpAHQALQBQAGEAdABoACAAJAB0AGEAcgBnAGUAdAAgAC0AUABhAHIAZQBuAHQAIAAtAFIAZQBzAG8AbAB2AGUADQAKACQAZgB1AGwAbAAgAD0AIABSAGUAcwBvAGwAdgBlAC0AUABhAHQAaAAgACQAdABhAHIAZwBlAHQADQAKAA0ACgBXAHIAaQB0AGUALQBIAG8AcwB0ACAAIgB0AGEAcgBnAGUAdAAgACAAIAAgACAAPQAgACQAdABhAHIAZwBlAHQAIgANAAoAVwByAGkAdABlAC0ASABvAHMAdAAgACIAbgBhAG0AZQAgACAAIAAgACAAIAAgAD0AIAAkAG4AYQBtAGUAIgANAAoAVwByAGkAdABlAC0ASABvAHMAdAAgACIAZgB1AGwAbAAgAHAAYQB0AGgAIAAgAD0AIAAkAGYAdQBsAGwAIgANAAoAVwByAGkAdABlAC0ASABvAHMAdAAgACIAcABhAHIAZQBuAHQAIABkAGkAcgAgAD0AIAAkAHAAYQByAGUAbgB0AGQAaQByACIA


powershell.exe -NoProfile -Command "Start-Process powershell -ArgumentList '-NoExit -EncodedCommand   -ArgumentList \"\"\"%~1\"\"\"' -Verb RunAs"


Start-Process powershell -ArgumentList '-NoExit -EncodedCommand   -ArgumentList D:\02Development\01Source\02-Microsoft\Context-Menu\MyTools\BaseMenu\New folder\'
REM  \" 
REM  \"	



pause
		
REM This will elevat e from CMD to a new cmd with admin rights
REM powershell.exe -Command "Start-Process cmd \"/k cd /d %cd%\" -Verb RunAs" 


REM Powershell script
rem New-Item -ItemType SymbolicLink -Path "C:\Path\to\Link\Name" -Value "C:\Path\to\Target\Directory"
REM for %%f in ("%CD%") do set LastPartOfFolder=%%~nxf

REM echo %LastPartOfFolder%
