Set-Location -Path (Split-Path -Parent $PSCommandPath)
$thispath= (Split-Path -Parent $PSCommandPath)

[System.Drawing.Icon]::ExtractAssociatedIcon("$thispath\ico.ico")


Add-Type -AssemblyName System.Drawing

$path = "$PSScriptRoot\ico.ico"
$icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)

# Save icon to new file
$newPath = "$PSScriptRoot\ico_resaved.ico"
$stream = [System.IO.File]::OpenWrite($newPath)
$icon.Save($stream)
$stream.Close()

Write-Host "Icon resaved to $newPath"