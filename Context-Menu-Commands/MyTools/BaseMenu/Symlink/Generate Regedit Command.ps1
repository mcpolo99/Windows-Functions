#Set-ExecutionPolicy -ExecutionPolicy bypass -Scope Process
$Namespace ="hkey_classes_root\directory\shell\mytools\shell\Symlink"
Set-Location -Path $PSScriptRoot

$scriptContent = {
    param(

        [Parameter(Mandatory)]
        [string] #single string and not a array!
        $target
    )
    
    
    # Get the current Execution Time
    $LogStamp = Get-Date -Format 'yyyy-MM-dd_HH_mm'
    $executionPath = (Resolve-Path .\).Path
    $logFile = "$target\..\Script_$LogStamp.log "

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
}

# Path to the output file
$outputPath = ".\encoded.txt"
#$scriptContent = Get-Content -Raw -Path $scriptPath
$bytes = [System.Text.Encoding]::Unicode.GetBytes($scriptContent)
$encodedCommand = [Convert]::ToBase64String($bytes)

# Write-Output $encodedCommand
# Output the result


#Set-Content -Path $outputPath -Value $encodedCommand -NoNewline -Encoding UTF8

#Set-Clipboard -Value $encodedCommand

#This is a regedit ready command:
$regrel = "cmd.exe /v /c powershell -Command `"Start-Process cmd -Verb RunAs -ArgumentList '/v /c  echo `"%1`" | powershell.exe -NoExit  -EncodedCommand $encodedCommand        '`"        "
$regdbg = "cmd.exe /v /c powershell -Command `"Start-Process cmd -Verb RunAs -ArgumentList '/v /k  echo `"%1`" | powershell.exe -NoExit  -EncodedCommand $encodedCommand  &pause'`" & pause"
$regedt = "@=`"cmd.exe /v /c powershell -Command \`"Start-Process cmd -Verb RunAs -ArgumentList '/v /c  echo \`"%1\`" | powershell.exe -NoExit  -EncodedCommand $encodedCommand'\`" `" "
$regrel | Set-Content '.\Debug.txt' -Encoding UTF8
$regrel | Set-Content '.\Release.txt' -Encoding UTF8
$regedt | Set-Content '.\RegEdit.txt' -Encoding UTF8

#for regedit:


# now is possible to do in powershell: "now .\New Folder and later automatic %~1" | powershell.exe -NoExit -EncodedCommand $Encoded
# regedit command
# cmd.exe /v /c  powershell -Command "Start-Process cmd -Verb RunAs -ArgumentList '/v /k  echo "%1" | powershell.exe -NoExit  -EncodedCommand <encodedCommand>  &pause'" & pause


# Modify Installer regfile
..\EditReg.ps1 -Name "Symlink" -Command $regrel