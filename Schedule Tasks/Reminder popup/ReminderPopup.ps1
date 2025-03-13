# Configuration file location
$ConfigFile = "C:\Windows\Scripts\ReminderPopup\config.xml"
$INSTALL=0

# Check if configuration exists, else ask for input
if (-Not (Test-Path $ConfigFile)) {
    $INSTALL=1
    Add-Type -AssemblyName System.Windows.Forms
    $Form = New-Object System.Windows.Forms.Form
    $Form.Text = "Reminder Configuration"
    $Form.Size = New-Object System.Drawing.Size(300,300)
    $Form.StartPosition = "CenterScreen"

    # Time selection
    $TimeLabel = New-Object System.Windows.Forms.Label
    $TimeLabel.Text = "Select Time (HH:mm):"
    $TimeLabel.Location = New-Object System.Drawing.Point(20,20)
    $TimeLabel.AutoSize = $true
    $Form.Controls.Add($TimeLabel)

    $TimeInput = New-Object System.Windows.Forms.MaskedTextBox
    $TimeInput.Mask = "00:00"
    $TimeInput.Location = New-Object System.Drawing.Point(150,20)
    $Form.Controls.Add($TimeInput)

    # Reminder Message Input
    $MessageLabel = New-Object System.Windows.Forms.Label
    $MessageLabel.Text = "Message:"
    $MessageLabel.Location = New-Object System.Drawing.Point(20, 40)
    $MessageLabel.AutoSize = $true
    $Form.Controls.Add($MessageLabel)

    $MessageInput = New-Object System.Windows.Forms.TextBox
    $MessageInput.Location = New-Object System.Drawing.Point(20, 60)
    $MessageInput.Size = New-Object System.Drawing.Size(240, 20)
    $Form.Controls.Add($MessageInput)


    # Days selection
    $DaysLabel = New-Object System.Windows.Forms.Label
    $DaysLabel.Text = "Select Days:"
    $DaysLabel.Location = New-Object System.Drawing.Point(20,60)
    $DaysLabel.AutoSize = $true
    $Form.Controls.Add($DaysLabel)

    $Days = "MON,TUE,WED,THU,FRI,SAT,SUN"
    $CheckBoxes = @{ }
    $YPos = 80
    foreach ($Day in $Days -split ",") {
        $CheckBox = New-Object System.Windows.Forms.CheckBox
        $CheckBox.Text = $Day
        $CheckBox.Location = New-Object System.Drawing.Point(20, $YPos)
        $Form.Controls.Add($CheckBox)
        $CheckBoxes[$Day] = $CheckBox
        $YPos += 20
    }


    # Submit button
    $SubmitButton = New-Object System.Windows.Forms.Button
    $SubmitButton.Text = "Save"
    $SubmitButton.Location = New-Object System.Drawing.Point(100,230)
    $SubmitButton.Add_Click({
        $SelectedDays = ($CheckBoxes.GetEnumerator() | Where-Object { $_.Value.Checked }).Key -join ","

        # Create XML configuration file
        $xml = New-Object -TypeName System.Xml.XmlDocument
        $configNode = $xml.CreateElement("config")

        $timeNode = $xml.CreateElement("TIME")
        $timeNode.InnerText = $TimeInput.Text
        $configNode.AppendChild($timeNode)

        $daysNode = $xml.CreateElement("DAYS")
        $daysNode.InnerText = $SelectedDays
        $configNode.AppendChild($daysNode)

        $messageNode = $xml.CreateElement("MESSAGE")
        $messageNode.InnerText = $MessageInput.Text
        $configNode.AppendChild($messageNode)

        $xml.AppendChild($configNode)
        $xml.Save($ConfigFile)

        # Task Creation Logic
        # Convert days to Task Scheduler format
        $DaysArray = $SelectedDays -split ","
        $DaysNumeric = @()
        $DaysMap = @{
            "MON" = 1
            "TUE" = 2
            "WED" = 3
            "THU" = 4
            "FRI" = 5
            "SAT" = 6
            "SUN" = 7
        }

        foreach ($Day in $DaysArray) {
            if ($DaysMap.ContainsKey($Day)) {
                $DaysNumeric += $DaysMap[$Day]
            }
        }

        # Create scheduled task to show the popup reminder
        $Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -NoProfile -File C:\Windows\Scripts\ReminderPopup\ReminderPopup.ps1"
        $Trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek $DaysNumeric -At $TimeInput.Text
        $Principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -RunLevel Highest
        $Task = New-ScheduledTask -Action $Action -Principal $Principal -Trigger $Trigger
        Register-ScheduledTask -TaskName "ReminderPopup" -InputObject $Task

        # Close the form after saving the config and creating the task
        $Form.Close()
    })
    $Form.Controls.Add($SubmitButton)

    $Form.ShowDialog()
}

# Read configuration from XML
[xml]$Config = Get-Content $ConfigFile
$Time = $Config.config.TIME
$Days = $Config.config.DAYS
$Message = $Config.config.MESSAGE

# Show reminder message
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.MessageBox]::Show($Message, "Reminder", "OK", "Information")
