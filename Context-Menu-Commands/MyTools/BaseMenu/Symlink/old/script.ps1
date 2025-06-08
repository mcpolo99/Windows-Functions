#Set-ExecutionPolicy -ExecutionPolicy bypass -Scope Process

#param($target)
param(

    [Parameter(Mandatory)]
    [string[]]
    $target
    )

# Get the current Execution Time
$LogStamp = Get-Date -Format 'yyyy-MM-dd_HH_mm'
$executionPath = (Resolve-Path .\).Path
$logFile = ".\Script_$LogStamp.log "

Start-Transcript -Path $logFile  -Append

#used for debuging
#Set-Location -Path D:\02Development\01Source\02-Microsoft\Context-Menu\MyTools\BaseMenu\
#Set-Location -Path "$env:USERPROFILE\OneDrive - Jon Stenberg AB\02Development\01Source\02-microsoft\Windows-Functions\Context-Menu-Commands\MyTools\BaseMenu"
#$target=".\New folder"



$target = $target.Trim('\"')
$name = Split-Path $target -Leaf
$parentdir = Split-Path $target -Parent -Resolve
$full = Resolve-Path $target

$linkName = [System.IO.Path]::GetFileNameWithoutExtension($full) + "_link" + [System.IO.Path]::GetExtension($full)

$linkPath = Join-Path $parentdir $linkName

Write-Output  "target     = $target"
Write-Output  "name       = $name"
Write-Output  "full path  = $full"
Write-Output  "parent dir = $parentdir"

Write-Output  "linkNamer = $linkName"
Write-Output  "linkPath = $linkPath"

New-Item -ItemType SymbolicLink -Path $linkPath -Target $full

Stop-Transcript

pause