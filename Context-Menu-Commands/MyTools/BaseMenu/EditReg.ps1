<#
.SYNOPSIS
    Edits or deletes entries in a .reg file under a custom namespace.

.DESCRIPTION
    This script modifies a registry file (.reg) located in the same directory.
    It can:
    - Add or update a named registry key and associated command.
    - Remove a named registry key and its associated command.

.PARAMETER Name
    The identifier (subkey) name under 'shell'. Required for both adding/updating and deleting.

.PARAMETER Command
    The command to execute when the menu item is selected. Used only when adding or updating.

.PARAMETER Delete
    If specified, the script deletes the entry associated with -Name.

.EXAMPLE
    .\EditReg.ps1 -Name "Symlink" -Command "cmd.exe /c mklink"

.EXAMPLE
    .\EditReg.ps1 -Name "Symlink" -Delete

.NOTES
    This modifies only the .reg file. You must manually import it using `regedit /s Install.reg` to apply changes.



add option to specify CLAS like "*" or ".txt" or 

Add option to add icon. ??



#>

param(
    [Parameter(Mandatory = $true)]
    [string]$Name,

    [string]$Command,

    [switch]$Delete
)

# Define root path and regfile path
$RootGroup = "HKEY_CLASSES_ROOT\Directory\shell\MyTools"
$regfile = Join-Path -Path $PSScriptRoot -ChildPath "Install.reg"

# Check if .reg file exists, if not create it with minimal valid structure
if (-not (Test-Path $regfile)) {
    $initialContent = @"
Windows Registry Editor Version 5.00

[$RootGroup]
`"MUIVerb`"=`"My Tools`"
`"Icon`"=`"cmd.exe`"
`"Position`"=`"Top`"
`"ExtendedSubCommandsKey`"=`"`"
`"SubCommands`"=`"`"
"@

    Set-Content -Path $regfile -Value $initialContent -Encoding Unicode
    Write-Host "Created new registry file: $regfile"
} else {
    Write-Host "Registry file exists: $regfile"
}


# Load full content of the .reg file
$content = Get-Content $regfile -Raw

# Normalize line endings to avoid regex issues
$content = $content -replace "`r`n", "`n"

# Your full key paths, including extra 'shell' intentional:
$keyPath = "$RootGroup\shell\$Name"       # e.g. HKEY_CLASSES_ROOT\directory\shell\mytools\shell\test
$cmdPath = "$keyPath\command"

if ($Delete) {
    # Remove the command and key blocks
    $content = [Regex]::Replace($content, "(?ms)^\[$([Regex]::Escape($cmdPath))\].*?(\r?\n){2}", '')
    $content = [Regex]::Replace($content, "(?ms)^\[$([Regex]::Escape($keyPath))\].*?(\r?\n){2}", '')
}
elseif ($Command) {
    # Remove existing blocks before adding updated ones
    $content = [Regex]::Replace($content, "(?ms)^\[$([Regex]::Escape($cmdPath))\].*?(\r?\n){2}", '')
    $content = [Regex]::Replace($content, "(?ms)^\[$([Regex]::Escape($keyPath))\].*?(\r?\n){2}", '')

    # Escape backslashes and quotes for .reg format
    $escapedCommand = $Command -replace '\\', '\\\\' -replace '"', '\"'

    # Compose new entry block exactly once
    $newEntry = @"
[$keyPath]
@="$Name"

[$cmdPath]
@="$escapedCommand"

"@

    # Append the new entry properly (with two newlines before for separation)
    $content = $content.TrimEnd() + "`r`n`r`n" + $newEntry
}
else {
    Write-Error "Either -Command or -Delete must be specified"
    exit 1
}

# Write the modified content back as UTF-16 LE (Unicode) for .reg compatibility
Set-Content -Path $regfile -Value $content -Encoding Unicode