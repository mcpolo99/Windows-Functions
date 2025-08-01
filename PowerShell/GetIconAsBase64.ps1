param (
    [string]$path = ""
    
    )

$img = (Resolve-Path $path).Path

$bytes = [System.IO.File]::ReadAllBytes($img)
$base64 = [Convert]::ToBase64String($bytes) 
Set-Clipboard -Value $base64