param (
    [string]$FolderPath,
    [switch]$DebugMode  # New switch parameter to control debug output
)

# Function to display debug messages based on the DebugMode
function Show-DebugMessage {
    param (
        [string]$Message
    )
    if ($DebugMode) {
        Write-Host "DEBUG: $Message"
    }
}

# Debug: Check if the script is receiving the correct folder path
Show-DebugMessage "Received folder path: $FolderPath. Press Enter to continue."

# Ensure a folder path is provided
if (-not (Test-Path $FolderPath -PathType Container)) {
    [System.Windows.MessageBox]::Show("Invalid folder path: $FolderPath", "Error", "OK", "Error")
    exit 1
}

# Extract old folder name
$ParentPath = Split-Path -Path $FolderPath -Parent
$OldFolderName = Split-Path -Path $FolderPath -Leaf

# Debug: Check extracted folder name
Show-DebugMessage "Old folder name is $OldFolderName. Press Enter to continue."

# Show prompt for new folder name
Add-Type -AssemblyName Microsoft.VisualBasic
$NewFolderName = [Microsoft.VisualBasic.Interaction]::InputBox("Enter new name for '$OldFolderName':", "Rename Folder", $OldFolderName)

# Debug: Check user input
Show-DebugMessage "User entered new name: $NewFolderName. Press Enter to continue."

# Validate user input
if (-not $NewFolderName -or $NewFolderName -eq $OldFolderName) {
    exit 0  # No change or canceled
}

# Define new folder path
$NewFolderPath = Join-Path -Path $ParentPath -ChildPath $NewFolderName

# Rename the folder
Rename-Item -Path $FolderPath -NewName $NewFolderName

# Debug: Check if rename was successful
Show-DebugMessage "Folder renamed to $NewFolderName. Press Enter to continue."

# Process XML files inside the folder
$XmlFiles = Get-ChildItem -Path $NewFolderPath -Filter "*.bwkl"

# Debug: List found XML files
foreach ($XmlFile in $XmlFiles) {
    Show-DebugMessage "Found XML file: $XmlFile. Press Enter to continue."
}

foreach ($XmlFile in $XmlFiles) {
    [xml]$XmlContent = Get-Content -Path $XmlFile.FullName

    # Find and update 'File' attributes that start with the old folder name
    $Nodes = $XmlContent.SelectNodes("//*[@File]")
    foreach ($Node in $Nodes) {
        $FilePath = $Node.File

        # Manually escape special regex characters in the old folder name
        $OldFolderNameEscaped = [regex]::Escape($OldFolderName)
        Show-DebugMessage "Matching pattern: $OldFolderNameEscaped"

        # Create the regex pattern to match the old folder name, preserving the separator
        $RegexPattern = "^(?:$OldFolderNameEscaped)(/|\\)"

        # Debug: Show the regex pattern
        Show-DebugMessage "Matching pattern: $RegexPattern"
        Show-DebugMessage "NewFolderName: $NewFolderName$1"
        Show-DebugMessage "FilePath: $FilePath"

        if ($FilePath -match $RegexPattern) {
            # Replace only the old folder name, leaving separators intact
            $UpdatedFilePath = $FilePath -replace $RegexPattern, "$NewFolderName/"

            # Debug: Show the updated file path
            Show-DebugMessage "Updated File attribute to: $UpdatedFilePath"

            # Update the XML node with the new file path
            $Node.File = $UpdatedFilePath
        } else {
            Show-DebugMessage "No match in $FilePath"
        }
    }

    # Save changes
    $XmlContent.Save($XmlFile.FullName)
    Show-DebugMessage "XML file $XmlFile.FullName saved."
}

# Add the Windows Forms assembly to use MessageBox
Add-Type -AssemblyName 'System.Windows.Forms'

# Show message box after the script has completed
[System.Windows.Forms.MessageBox]::Show("Folder and XML references updated successfully!", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)

