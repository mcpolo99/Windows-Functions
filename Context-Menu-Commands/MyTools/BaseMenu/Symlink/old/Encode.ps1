#Create a command context menu command to run encode and set encoded scring to clipboard. should only work for files ending with a extension, and maybe write to file. 

# Path to the script to encode
$scriptPath = ".\script.ps1"

# Path to the output file
$outputPath = ".\encoded.txt"

# Read and encode the script
$scriptContent = Get-Content -Raw -Path $scriptPath
$bytes = [System.Text.Encoding]::Unicode.GetBytes($scriptContent)
$encodedCommand = [Convert]::ToBase64String($bytes)

# Output the result
Write-Output $encodedCommand
# Write to file as a single line
Set-Content -Path $outputPath -Value $encodedCommand -NoNewline
Set-Clipboard -Value $encodedCommand






