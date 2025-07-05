class EventLog {

    <#
    .SYNOPSIS
    A helper class to manage Windows Event Log sources and entries.

    .DESCRIPTION
    Provides functionality to create, write to, and remove Windows Event Log sources.
    Automatically elevates when creating/removing sources. Supports logging different event types.

    .EXAMPLE
    $event = [EventLog]::new("MyAppName", "Application")
    $event.Log("Startup completed")

    .EXAMPLE
    $event.Log("Warning issued", 1002, [System.Diagnostics.EventLogEntryType]::Warning)

    .EXAMPLE
    $event.removeEventLogger()

    .NOTES
    Requires admin privileges to create or remove event sources.
    #>
    
    [string] $StoredSource = ""
    [string] $StoredLogName = "Application"

    <#
    .SYNOPSIS
    Constructor for the EventLog class.

    .PARAMETER source
    The source name to register and use for logging.

    .PARAMETER logName
    The name of the log (e.g., "Application"). Defaults to "Application".

    .EXCEPTION
    Throws if source or logName are null or empty.

    .NOTES
    Automatically creates the source if it doesn't already exist.
    #>
    EventLog([string]$source, [string]$logName = "Application") {
        if ([string]::IsNullOrWhiteSpace($source)) {
            throw "You must provide a non-empty string for the event log source."
        }

        if ([string]::IsNullOrWhiteSpace($logName)) {
            throw "You must provide a valid log name."
        }

        $this.StoredSource = $source
        $this.StoredLogName = $logName

        if (-not $this.DoExsist()){
            $this.addEventLogger()
        }
    }

    <#
    .SYNOPSIS
    Dynamically sets a property value by name.

    .PARAMETER property
    The name of the property to set.

    .PARAMETER value
    The value to assign.
    #>
    [void] SetProp([string] $property, [string] $Value) {
        $this::$property = $Value
    }

    <#
    .SYNOPSIS
    Writes an informational event with ID 1.

    .PARAMETER message
    The message to write.
    #>
    [void] Log([string]$message) {
        Write-EventLog -LogName $this.StoredLogName -Source $this.StoredSource -EntryType Information -EventId 1 -Message $message
    }

    <#
    .SYNOPSIS
    Writes an informational event with a custom event ID.

    .PARAMETER message
    The message to write.

    .PARAMETER id
    The event ID to assign.
    #>
    [void] Log([string]$message, [int]$id) {
        Write-EventLog -LogName $this.StoredLogName -Source $this.StoredSource -EntryType Information -EventId $id -Message $message
    }

    <#
    .SYNOPSIS
    Writes an event with custom ID and entry type.

    .PARAMETER message
    The message to write.

    .PARAMETER id
    The event ID.

    .PARAMETER type
    The event type ([System.Diagnostics.EventLogEntryType]) such as Information, Warning, Error.
    #>
    [void] Log([string]$message, [int]$id, [System.Diagnostics.EventLogEntryType] $type) {
        Write-EventLog -LogName $this.StoredLogName -Source $this.StoredSource -EntryType $type -EventId $id -Message $message
    }

    <#
    .SYNOPSIS
    Removes the event source from the system.

    .NOTES
    Requires administrator privileges.
    Will launch an elevated PowerShell process to perform the action.
    #>
    [void] removeEventLogger() {
        if ($this.StoredSource -and $this.DoExsist()) {
            $source = $this.StoredSource
            try {
                $scriptBlock = @"
            if ([System.Diagnostics.EventLog]::SourceExists('$source')) {
                Remove-EventLog -Source '$source'
            }
"@
                $encodedCommand = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($scriptBlock))

                $startInfo = New-Object System.Diagnostics.ProcessStartInfo
                $startInfo.FileName = "powershell.exe"
                $startInfo.Arguments = "-NoProfile -EncodedCommand $encodedCommand"
                $startInfo.Verb = "runas"
                $startInfo.UseShellExecute = $true

                $process = [System.Diagnostics.Process]::Start($startInfo)
                $process.WaitForExit()
            } catch {
                throw "removeEventLogger not successful"
            }
        }
    }

    <#
    .SYNOPSIS
    Internal check if the source already exists.

    .OUTPUTS
    [bool] True if the source exists; otherwise, false.
    #>
    hidden [boolean] DoExsist() {
        try {
            [System.Diagnostics.EventLog]::SourceExists($this.StoredSource)
        } catch {
            return $false
        }
        return $true
    }

    <#
    .SYNOPSIS
    Internal method to create an event source.

    .NOTES
    Elevates privileges automatically using a separate PowerShell process.
    #>
    hidden [void] addEventLogger() {
        $source = $this.StoredSource
        $logName = $this.StoredLogName

        if (-not $this.DoExsist()) {
            try {
                $scriptBlock = @"
                if (-not [System.Diagnostics.EventLog]::SourceExists('$source')) {
                    New-EventLog -LogName $logName -Source '$source'
                }
"@
                $encodedCommand = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($scriptBlock))

                $startInfo = New-Object System.Diagnostics.ProcessStartInfo
                $startInfo.FileName = "powershell.exe"
                $startInfo.Arguments = "-NoProfile -EncodedCommand $encodedCommand"
                $startInfo.Verb = "runas"
                $startInfo.UseShellExecute = $true

                $process = [System.Diagnostics.Process]::Start($startInfo)
                $process.WaitForExit()

                [System.Diagnostics.EventLog]::SourceExists($this.StoredSource)
            } catch {
                throw "addEventLogger not successful"
            }
        }
    }
}
