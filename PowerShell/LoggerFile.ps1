enum LogLevelEnum {
    Info
    Error
    Debug
}
<#
.SYNOPSIS
    Logger class for writing messages to a log file with optional console output.

.DESCRIPTION
    This class supports logging messages at various levels: Info, Error, Warning, and Debug.
    Log output is written to a file, and optionally to the console depending on the log level.
    Uses the LogLevelEnum to control verbosity.

.EXAMPLE
    $logger = [Logger]::new([LogLevelEnum]::Debug)
    $logger.Info("This is an info message.")
    $logger.Error("An error occurred.")
    $logger.Warning("This is a warning.")
    $logger.Debug("Debug details.")

.NOTES
    Default log file path is .\logs\default.log
#>
class Logger {
    [LogLevelEnum]$LogLevel
    [string]$LogFile

    <#
    .SYNOPSIS
        Constructs a new instance of the Logger class.

    .PARAMETER logLevel
        The minimum logging level. Accepts Info, Error, or Debug. Defaults to Info.

    .PARAMETER logFile
        The path to the log file. Defaults to .\logs\default.log.

    .EXAMPLE
        $logger = [Logger]::new([LogLevelEnum]::Error, "C:\Logs\app.log")
    #>
    Logger([LogLevelEnum]$logLevel = [LogLevelEnum]::Info, [string]$logFile = ".\logs\default.log") {
        $this.LogLevel = $logLevel
        $this.LogFile = $logFile
    }

    <#
    .SYNOPSIS
        Logs an informational message.

    .PARAMETER message
        The message to log.

    .EXAMPLE
        $logger.Info("Application started.")
    #>
    [void] Info([string]$message) {
        if ($this.LogLevel -in @([LogLevelEnum]::Info, [LogLevelEnum]::Debug)) {
            $this.WriteLog("INFO", $message)
            Write-Information $message
        }
    }

    <#
    .SYNOPSIS
        Logs an error message.

    .PARAMETER message
        The error message to log.

    .EXAMPLE
        $logger.Error("File not found.")
    #>
    [void] Error([string]$message) {
        if ($this.LogLevel -in @([LogLevelEnum]::Error, [LogLevelEnum]::Debug)) {
            $this.WriteLog("ERROR", $message)
            Write-Error $message
        }
    }

    <#
    .SYNOPSIS
        Logs a warning message.

    .PARAMETER message
        The warning message to log.

    .EXAMPLE
        $logger.Warning("Low disk space.")
    #>
    [void] Warning([string]$message) {
        if ($this.LogLevel -in @([LogLevelEnum]::Info, [LogLevelEnum]::Error, [LogLevelEnum]::Debug)) {
            $this.WriteLog("WARNING", $message)
            Write-Warning $message
        }
    }

    <#
    .SYNOPSIS
        Logs a debug message.

    .PARAMETER message
        The debug message to log.

    .EXAMPLE
        $logger.Debug("Debugging variable x: $x")
    #>
    [void] Debug([string]$message) {
        if ($this.LogLevel -eq [LogLevelEnum]::Debug) {
            $this.WriteLog("DEBUG", $message)
            Write-Debug $message
        }
    }

    <#
    .SYNOPSIS
        Internal method to write a log entry to file.

    .DESCRIPTION
        Prepends a timestamp and log level to the message and appends it to the log file.

    .PARAMETER level
        The log level label (e.g., INFO, ERROR).

    .PARAMETER message
        The message to write.

    .EXAMPLE
        $this.WriteLog("INFO", "Service started.")
    #>
    hidden [void] WriteLog([string]$level, [string]$message) {
        $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
        $entry = "$timestamp [$level] $message"
        Add-Content -Path $this.LogFile -Value $entry
    }
}
