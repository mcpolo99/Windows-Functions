
#Set-ExecutionPolicy -ExecutionPolicy bypass -Scope Process
#compile: ps2exe '.\FormControl with Source and Destination.ps1' .\MKLinkCreator.exe -noConsole -STA -requireAdmin -exitOnCancel -title 'MK Link Creator'  -company 'Polos AB'  -product 'MKLinkCreator' -version '1.0.1' -iconFile ".\ico_resaved.ico" -verbose

param (
    [string]$InitialSource = "",
    [string]$InitialDestination = "",
    [switch]$help,
    [switch]$verbose
)
$script:verbose = $verbose


function Log {
  param([string]$message)
    if ($script:verbose) {
        Add-Content -Path $logFile1 -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $message"
    }
}
function Sanitize-PathInput {
    param ([string]$path)

    # Return null if input is null or empty
    if ([string]::IsNullOrWhiteSpace($path)) {
        return $null
    }

    # Remove surrounding single or double quotes if present
    $cleanPath = $path -replace '^(["''])?(.*?)\1$', '$2'

    # Validate and resolve
    if (Test-Path $cleanPath) {
        return (Resolve-Path $cleanPath).Path
    }

    return $null
}
function Show-HelpWindow {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    $helpForm = New-Object System.Windows.Forms.Form
    $helpForm.Text = "Help - MK Link Creator"
    $helpForm.Size = New-Object System.Drawing.Size(500, 400)
    $helpForm.StartPosition = "CenterScreen"

    $helpTextBox = New-Object System.Windows.Forms.TextBox
    $helpTextBox.Multiline = $true
    $helpTextBox.ReadOnly = $true
    $helpTextBox.ScrollBars = "Vertical"
    $helpTextBox.Dock = "Fill"
    $helpTextBox.Font = New-Object System.Drawing.Font("Consolas", 10)
    $helpTextBox.Text = @"
$helpTextBox.Text = @"
MK Link Creator Help

Usage (command line):
  MKLinkCreator.exe -help
    Show this help window.

  MKLinkCreator.exe -InitialSource "C:\Source" -InitialDestination "D:\Target"
    Create a symbolic link directly (no GUI).

  MKLinkCreator.exe -InitialSource "C:\Source" -InitialDestination "D:\Target" -verbose
    Same as above, but with logging to file.

Switches:
  -help       Show help window.
  -verbose    Enable logging of actions and errors to Script_DATE.log and manlog_DATE.log.

Usage (GUI):
  1. Select a source folder.
  2. Select a destination folder.
  3. Click OK to create a symbolic link at:
     Destination\SourceFolderName_Link

Notes:
  - This tool requires admin privileges.
  - Existing links with the same name will be overwritten.
"@
    $helpForm.Controls.Add($helpTextBox)
    [void]$helpForm.ShowDialog()
}

if (($args -contains '-help') -or ($help)) {
    Show-HelpWindow
    exit
}



$LogStamp = Get-Date -Format 'yyyy-MM-dd'
$executionPath = (Resolve-Path .\).Path
$logFile = ".\Script_$LogStamp.log "
$logFile1 = ".\manlog_$LogStamp.log "

if ($verbose) {
    Start-Transcript -Path $logFile -Append
}

# Self-elevation (must be first)
Add-Type -AssemblyName System.Windows.Forms


# Ensure the script is running in STA mode
if ([System.Threading.Thread]::CurrentThread.ApartmentState -ne 'STA') {
    [System.Windows.Forms.MessageBox]::Show("Restarting in STA mode...", "Info", "OK", "Information")
    powershell -STA -NoProfile -ExecutionPolicy Bypass -File "`"$PSCommandPath`"" @args
    exit
}


# Resolve relative paths to full paths
$InitialSource = Sanitize-PathInput $InitialSource
$InitialDestination = Sanitize-PathInput $InitialDestination


# If both source and destination are valid, create symlink directly and exit
if ($InitialSource -and $InitialDestination) {
    $sourcePath = $InitialSource
    $destPath = $InitialDestination

    #-PathType Container

    if ((Test-Path $sourcePath -PathType Container) -and (Test-Path $destPath -PathType Container)) {
        # Get the last directory name from the source path
        $sourceFolderName = Split-Path $sourcePath -Leaf
        $targetLinkPath = Join-Path $destPath "${sourceFolderName}_Link"

        Log "Source Path: $sourcePath"
        Log "Destination Path: $destPath"
        Log "Source Folder Name: $sourceFolderName"

        try {
            if (Test-Path $targetLinkPath) {
                Remove-Item $targetLinkPath -Force
            }

            New-Item -ItemType SymbolicLink -Path $targetLinkPath -Target $sourcePath -ErrorAction Stop

            [System.Windows.Forms.MessageBox]::Show("Link created at:`n$targetLinkPath", "Success", "OK", "Information")
        }
        catch {
            Log "`n$($_.Exception.Message)"
            [System.Windows.Forms.MessageBox]::Show("Failed to create symbolic link:`n$($_.Exception.Message)", "Error", "OK", "Error")
        }

        if ($verbose) { Stop-Transcript }
        exit
    }
}


if ($InitialSource -and (Test-Path $InitialSource)) {
    $InitialSource = (Resolve-Path $InitialSource).Path
    log "$InitialSource"
}

if ($InitialDestination -and (Test-Path $InitialDestination)) {
    $InitialDestination = (Resolve-Path $InitialDestination).Path
    log "$InitialDestination"
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create Form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Select Source and Destination Folders"
$form.Size = New-Object System.Drawing.Size(600,250)
$form.StartPosition = "CenterScreen"

# Source Label
$labelSource = New-Object System.Windows.Forms.Label
$labelSource.Text = "Source Folder:"
$labelSource.Location = New-Object System.Drawing.Point(10, 20)
$labelSource.Size = New-Object System.Drawing.Size(100, 20)
$form.Controls.Add($labelSource)

# Source TextBox
$textBoxSource = New-Object System.Windows.Forms.TextBox
$textBoxSource.Location = New-Object System.Drawing.Point(120, 20)
$textBoxSource.Size = New-Object System.Drawing.Size(350, 20)
$textBoxSource.Text = $InitialSource
$form.Controls.Add($textBoxSource)

# Source Button
$buttonSource = New-Object System.Windows.Forms.Button
$buttonSource.Text = "Browse..."
$buttonSource.Location = New-Object System.Drawing.Point(480, 18)
$buttonSource.Size = New-Object System.Drawing.Size(75, 23)
$buttonSource.Add_Click({
    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    if ($dialog.ShowDialog() -eq "OK") {
        $textBoxSource.Text = $dialog.SelectedPath
    }
})
$form.Controls.Add($buttonSource)

# Destination Label
$labelDest = New-Object System.Windows.Forms.Label
$labelDest.Text = "Destination Folder:"
$labelDest.Location = New-Object System.Drawing.Point(10, 60)
$labelDest.Size = New-Object System.Drawing.Size(110, 20)
$form.Controls.Add($labelDest)

# Destination TextBox
$textBoxDest = New-Object System.Windows.Forms.TextBox
$textBoxDest.Location = New-Object System.Drawing.Point(120, 60)
$textBoxDest.Size = New-Object System.Drawing.Size(350, 20)
$textBoxDest.Text = $InitialDestination
$form.Controls.Add($textBoxDest)

# Destination Button
$buttonDest = New-Object System.Windows.Forms.Button
$buttonDest.Text = "Browse..."
$buttonDest.Location = New-Object System.Drawing.Point(480, 58)
$buttonDest.Size = New-Object System.Drawing.Size(75, 23)
$buttonDest.Add_Click({
    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    if ($dialog.ShowDialog() -eq "OK") {
        $textBoxDest.Text = $dialog.SelectedPath
    }
})
$form.Controls.Add($buttonDest)

# OK Button
$buttonOK = New-Object System.Windows.Forms.Button
$buttonOK.Text = "OK"
$buttonOK.Location = New-Object System.Drawing.Point(250, 110)
$buttonOK.Size = New-Object System.Drawing.Size(75, 30)
$buttonOK.Add_Click({
    $sourcePath = $textBoxSource.Text
    $destPath = $textBoxDest.Text

    # === Your Logic Here ===
#    Write-Host "Source Path: $sourcePath"
#    Write-Host "Destination Path: $destPath"

    # Example logic:
    #if (Test-Path $sourcePath -and Test-Path $destPath) {

    
    #     Copy-Item -Path "$sourcePath\*" -Destination $destPath -Recurse
    #}

    if (!(Test-Path $sourcePath -PathType Container)) {
        #[System.Windows.Forms.MessageBox]::Show("Source path is invalid or does not exist.","Error","OK","Error")
        return
    }

    if (!(Test-Path $destPath -PathType Container)) {
        #[System.Windows.Forms.MessageBox]::Show("Destination path is invalid or does not exist.","Error","OK","Error")
        return
    }

        # Get the last directory name from the source path
    $sourceFolderName = Split-Path $sourcePath -Leaf

    # === Your Logic Here ===
    Log "Source Path: $sourcePath"
    Log "Destination Path: $destPath"
    Log "Source Folder Name: $sourceFolderName"

    # Build the full target path
    $targetLinkPath = Join-Path $destPath "${sourceFolderName}_Link"

    # Optional: Remove existing link if it exists
    if (Test-Path $targetLinkPath) {
        Remove-Item $targetLinkPath -Force
    }
    try {
        if (Test-Path $targetLinkPath) {
            Remove-Item $targetLinkPath -Force
        }

        New-Item -ItemType SymbolicLink -Path $targetLinkPath -Target $sourcePath -ErrorAction Stop

        [System.Windows.Forms.MessageBox]::Show("Link created at:`n$targetLinkPath", "Success", "OK", "Information")
    }
    catch {
        Log "`n$($_.Exception.Message)"
        [System.Windows.Forms.MessageBox]::Show("Failed to create symbolic link:`n$($_.Exception.Message)", "Error", "OK", "Error")
    }





    $form.Close()
    if ($verbose) { Stop-Transcript }
})
$form.Controls.Add($buttonOK)

# Help Button
$buttonHelp = New-Object System.Windows.Forms.Button
$buttonHelp.Text = "Help"
$buttonHelp.Location = New-Object System.Drawing.Point(340, 110)
$buttonHelp.Size = New-Object System.Drawing.Size(75, 30)
$buttonHelp.Add_Click({
    Show-HelpWindow
})
$form.Controls.Add($buttonHelp)



# Show the Form
[void]$form.ShowDialog()




