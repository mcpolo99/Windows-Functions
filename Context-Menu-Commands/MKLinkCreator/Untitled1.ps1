Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create Form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Select Source and Destination Folders"
$form.Size = New-Object System.Drawing.Size(600,200)
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
    # Example: Just printing to console/log (can be replaced with actual logic)
    Write-Host "Source Path: $sourcePath"
    Write-Host "Destination Path: $destPath"

    # You can replace the above with any processing logic, e.g., copying files
    # Copy-Item -Path "$sourcePath\*" -Destination $destPath -Recurse

    $form.Close()
})
$form.Controls.Add($buttonOK)

# Show the Form
[void]$form.ShowDialog()