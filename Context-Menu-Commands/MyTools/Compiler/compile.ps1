#compile: ps2exe '.\compile.ps1' .\Compile.exe -noConsole -STA -exitOnCancel -title 'compile'  -company 'Polos AB'  -product 'compiler' -version '1.0.1.0' -verbose


Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
function CheckPS2Exe {
    # Check if ps2exe function or module is available
    if (-not (Get-Command ps2exe -ErrorAction SilentlyContinue)) {
        $result = [System.Windows.Forms.MessageBox]::Show(
            "ps2exe module is not installed. Do you want to install it now?",
            "Missing Dependency",
            [System.Windows.Forms.MessageBoxButtons]::OKCancel,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        )
        if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
            try {
                Write-Host "Installing ps2exe module from PSGallery..."
                Install-Module -Name ps2exe -Scope CurrentUser -Force -AllowClobber
                Write-Host "ps2exe installed successfully."
            } catch {
                [System.Windows.Forms.MessageBox]::Show(
                    "Failed to install ps2exe module.`nError: $_",
                    "Installation Error",
                    [System.Windows.Forms.MessageBoxButtons]::OK,
                    [System.Windows.Forms.MessageBoxIcon]::Error
                )
                exit
            }
        }
        else {
            Write-Host "ps2exe module not installed. Exiting."
            exit
        }
    }
}

# Call the check early
CheckPS2Exe


$xmlFile = "assemblyinfo.xml"

function Show-InputForm {
    param (
        [bool]$ReadOnly = $false,
        [xml]$XmlData = $null
    )

    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    $form = New-Object Windows.Forms.Form
    $form.Text = if ($ReadOnly) { "Assembly Info (Read-Only)" } else { "Enter Assembly Info" }
    $form.Size = New-Object Drawing.Size(500, 500)
    $form.StartPosition = "CenterScreen"

    $fields = @(
        "AssemblyDescription", "AssemblyCompany", "AssemblyProduct",
        "AssemblyCopyright", "AssemblyTrademark", "AssemblyCulture",
        "AssemblyVersion", "AssemblyFile", "AssemblyIcon"
    )

    $textBoxes = @{}

    for ($i = 0; $i -lt $fields.Count; $i++) {
        $fieldName = $fields[$i]
        $top = 20 + $i * 40

        # Label
        $label = New-Object Windows.Forms.Label
        $label.Text = $fieldName
        $label.Location = New-Object Drawing.Point(10, $top)
        $label.Size = New-Object Drawing.Size(120, 20)
        $form.Controls.Add($label)

        if ($fieldName -eq "AssemblyFile" -and -not $ReadOnly) {
            # Create a separate TextBox for AssemblyFile
            $tbf = New-Object Windows.Forms.TextBox
            $tbf.Location = New-Object Drawing.Point(140, $top)
            $tbf.Size = New-Object Drawing.Size(250, 20)

            # Prefill from XML if available
            if ($XmlData) {
                $node = $XmlData.SelectSingleNode("//assemblyinfo/$fieldName")
                if ($node) { $tbf.Text = $node.InnerText }
            }

            # Button for AssemblyFile
            $btn = New-Object Windows.Forms.Button
            $btn.Text = "..."
            $btn.Size = New-Object Drawing.Size(30, 20)
            $btn.Location = New-Object Drawing.Point(400, $top)
            $btn.Add_Click({
                $ofd = New-Object Windows.Forms.OpenFileDialog
                $ofd.InitialDirectory = Get-Location
                $ofd.Filter = "PowerShell Scripts (*.ps1)|*.ps1"
                if ($ofd.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
                    $tbf.Text = $ofd.FileName
                }
            })

            $form.Controls.Add($tbf)
            $form.Controls.Add($btn)
            $textBoxes[$fieldName] = $tbf
        }
        elseif ($fieldName -eq "AssemblyIcon" -and -not $ReadOnly) {
            # Create TextBox for AssemblyIcon
            $tb = New-Object Windows.Forms.TextBox
            $tb.Location = New-Object Drawing.Point(140, $top)
            $tb.Size = New-Object Drawing.Size(250, 20)

            # Prefill from XML if available
            if ($XmlData) {
                $node = $XmlData.SelectSingleNode("//assemblyinfo/$fieldName")
                if ($node) { $tb.Text = $node.InnerText }
            }

            # Button for AssemblyIcon
            $btn = New-Object Windows.Forms.Button
            $btn.Text = "..."
            $btn.Size = New-Object Drawing.Size(30, 20)
            $btn.Location = New-Object Drawing.Point(400, $top)
            $btn.Add_Click({
                $ofd = New-Object Windows.Forms.OpenFileDialog
                $ofd.InitialDirectory = Get-Location
                $ofd.Filter = "Icons (*.ico)|*.ico"
                if ($ofd.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
                    $tb.Text = $ofd.FileName
                }
            })

            $form.Controls.Add($tb)
            $form.Controls.Add($btn)
            $textBoxes[$fieldName] = $tb
        }
        else {
            # For all other fields or if readonly, just a normal TextBox
            $tb = New-Object Windows.Forms.TextBox
            $tb.Location = New-Object Drawing.Point(140, $top)
            $tb.Size = New-Object Drawing.Size(250, 20)

            # Prefill from XML if available
            if ($XmlData) {
                $node = $XmlData.SelectSingleNode("//assemblyinfo/$fieldName")
                if ($node) { $tb.Text = $node.InnerText }
            }

            if ($ReadOnly) { $tb.ReadOnly = $true }

            $form.Controls.Add($tb)
            $textBoxes[$fieldName] = $tb
        }
    }

    # OK button
    $okButton = New-Object Windows.Forms.Button
    $okButton.Text = if ($ReadOnly) { "Compile" } else { "Ok" }
    $okButton.Location = New-Object Drawing.Point(180, 420)
    $okButton.Add_Click({ $form.DialogResult = [System.Windows.Forms.DialogResult]::OK; $form.Close() })
    $form.Controls.Add($okButton)

    # Cancel button
    $cancelButton = New-Object Windows.Forms.Button
    $cancelButton.Text = "Cancel"
    $cancelButton.Location = New-Object Drawing.Point(260, 420)
    $cancelButton.Add_Click({ $form.DialogResult = [System.Windows.Forms.DialogResult]::Cancel; $form.Close() })
    $form.Controls.Add($cancelButton)

    # Show form once and store result
    $result = $form.ShowDialog()

    if ($ReadOnly) {
        if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
            return $null
        } else {
            exit
        }
    }

    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        return $textBoxes
    } else {
        exit
    }
}


# First-time setup
if (-not (Test-Path $xmlFile)) {
    $inputs = Show-InputForm -ReadOnly:$false

    if ($inputs) {
        $xml = New-Object xml
        $root = $xml.CreateElement("assemblyinfo")
        $xml.AppendChild($root) | Out-Null

        foreach ($k in $inputs.Keys) {
            $node = $xml.CreateElement($k)
            $node.InnerText = $inputs[$k].Text
            $root.AppendChild($node) | Out-Null
        }

        $xml.Save($xmlFile)
        Write-Host "Assembly info created."
        exit
    }
}

# Load existing info
[xml]$xml = Get-Content $xmlFile

# Bump version
$ver = $xml.assemblyinfo.AssemblyVersion
if ($ver -match '(\d+)\.(\d+)\.(\d+)\.(\d+)') {
    $v1 = [int]$matches[1]
    $v2 = [int]$matches[2]
    $v3 = [int]$matches[3]
    $v4 = [int]$matches[4] + 1
    $newVer = "$v1.$v2.$v3.$v4"
    $xml.assemblyinfo.AssemblyVersion = $newVer
    $xml.Save($xmlFile)
    #Write-Host "Version incremented to $newVer"
} else {
    Write-Host "Invalid version format format should be (\d+)\.(\d+)\.(\d+)\.(\d+). Skipping increment."
}

# Show read-only form
Show-InputForm -ReadOnly:$true -XmlData:$xml

# Compile
$assemblyFile = $xml.assemblyinfo.AssemblyFile
$exeFile = [IO.Path]::ChangeExtension($assemblyFile, ".exe")
$iconFile = $xml.assemblyinfo.AssemblyIcon

ps2exe $assemblyFile $exeFile `
    -noConsole -sta -requireAdmin -exitOnCancel `
    -title $xml.assemblyinfo.AssemblyDescription `
    -company $xml.assemblyinfo.AssemblyCompany `
    -product $xml.assemblyinfo.AssemblyProduct `
    -version $xml.assemblyinfo.AssemblyVersion `
    -description $xml.assemblyinfo.AssemblyDescription `
    -copyright $xml.assemblyinfo.AssemblyCopyright `
    -trademark $xml.assemblyinfo.AssemblyTrademark `
    -iconFile $iconFile `
    -verbose `
    | Out-Null
