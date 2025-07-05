# bSolidMacroCompiler.ps1

# Input Handling
param (
    [switch]$help,
    [ValidateSet("info", "error", "debug")]
    [string]$loglevel = "info",
    # [string]$folderPath = (Get-Location)
    [string]$folderPath = $pwd.path
)


if (-not (Test-Path $folderPath)) {
    Write-Error "Directory '$folderPath' does not exist."
    exit 1
}
Set-Location -Path $folderPath
$script:ApplicationName = if ($MyInvocation.MyCommand.Name) {[IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)} else {"SCRIPT"}
$script:logStamp = Get-Date -Format 'yyyy-MM-dd'


# $script:logPath = $pwd.path+"\logs\$ApplicationName"+"_"+"$logStamp.log"
$script:logPath = "logs\$ApplicationName"+"_"+"$logStamp.log"
$script:logger = [Logger]::new($loglevel,$logPath)
$script:logName = "Application"
##check if IDE
if( ([AppUtility]::IsIDE($script:logger,$Host.Name ,$PSEditor))){
    $script:IDE = $true

    <#
        Value	Behavior
        'SilentlyContinue' Suppresses output
        'Continue'	Shows message in the console
        'Ignore'	Ignores the message entirely
        'Stop'	Throws an error when information is written
        'Inquire'	Prompts the user whether to display the message
        'Suspend'	Suspends execution 
    #>
    $ErrorActionPreference = 'Continue'	#Controls how errors are handled.
    $WarningPreference = 'Continue'	#Controls display of Write-Warning output.
    $InformationPreference = 'Continue'	#Controls display of Write-Information output.
    $VerbosePreference = 'Continue'	#Controls display of Write-Verbose output.
    $DebugPreference = 'Continue'	#Controls display of Write-Debug output.
    $ProgressPreference = 'Continue'	#Controls progress bar display (e.g. Write-Progress).

    & {

        $logStamp = Get-Date -Format 'yyyy-MM-dd_HH_mm'
        $logPath = ".\logs\IDE_$logStamp.txt"
        Write-Debug "Startign IDE logging"
        Start-Transcript -Path $logPath -Append
        
    }
}

# # create a event logger
# $Script:Event = [EventLog]::new($ApplicationName, "Application")
# $Event.Log("Event With ONLY msg")
# $Event.Log("Event With ID",2)
# $Event.Log("Event With ID and Type",2,[System.Diagnostics.EventLogEntryType]::Warning)
# $eventer.removeEventLogger()


$logger.Debug("Script is starting $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")
$logger.info("Script started with log level: $loglevel")
# if (-not (Test-Path $folderPath)) {
#     Write-Error "Directory '$folderPath' does not exist."
#     exit 1
# }
# Set-Location -Path $folderPath


# Initialization
$script:winrarPath = "C:\Program Files\WinRAR\WinRAR.exe"  # Default WinRAR path




if (-Not (Test-Path $winrarPath)) {
    $logger.Warning("winrar was not found in default path, will search for it.")
    $search = [AppUtility]::Get_AppPath("Winrar")

    if($search){
        $logger.info("winrar was found.")
        $logger.Debug($($search | ConvertTo-Json -Depth 3))
        $winrarPath = $search.InstallPath
    }else{
        $logger.Error("Winrar could not be found, Please install WinRar")
        throw [System.IO.FileNotFoundException]::new("WinRAR executable was not found in the registry or default location.")
    }
}




# Validate Folder Structure
$script:expectedFiles = @( ".bSolid", ".det", ".png", "_Descr.xml")
$script:folders = Get-ChildItem -Path $folderPath -Directory
$logger.info("Folders found: $folders")
$script:versionedFolders = @{}
$script:baseFolderName = (Get-Item $pwd.path).Name
$logger.info("basefolder $baseFolderName")
$script:sfxFolderName=""

foreach ($folder in $folders) {
    $hasRequiredFiles = $true
    # $baseFolderName1 = $folder.Name -replace "_REV\d+\.\d+$", ""  # Remove version suffix for pattern matching
    # $expectedFilesPatterns = @("$baseFolderName.*")  # Create dynamic pattern based on folder name
    #check for folderstructure
    foreach ($file in $expectedFiles) {
        if (-Not (Test-Path (Join-Path $folder.FullName "$($baseFolderName)$file"))) {
            $hasRequiredFiles = $false
            # $logger.Debug("$file not found")
            break
        } else {
            $logger.Debug("$file found")
        }
    }

    if (-Not $hasRequiredFiles) {
        $logger.Warning("Missing required files in folder: $($folder.Name)")
        continue
    }else{
        $logger.Debug("All files found in  $($folder.Name)")

    }

    # Extract base folder name and version
    if ($folder.Name -match "^(.*?)(_REV(\d+\.\d+))?$") {
        $baseFolderName = $matches[1]
        $version = $matches[3]


        #add all versioned folders to a hashtable
        $versionedFolders[$folder.Name] = $version

    }
}
$logger.Debug("versionedFolders $($versionedFolders | ConvertTo-Json -Depth 3)")
# Filter out null or empty versions just in case
$script:versionedFolders = $script:versionedFolders.GetEnumerator() | Where-Object { $_.Value -ne $null -and $_.Value -ne "" }

# Sort by version (converted to [version] type for correct numeric comparison)
$highest = $script:versionedFolders | Sort-Object { [version]$_.Value } -Descending | Select-Object -First 1

# Example usage
if ($highest) {
    $logger.Info("Highest versioned folder: $($highest.Key) with version $($highest.Value)")
    $sfxFolderName = $highest.Key
} else {
    $logger.Warning("No valid versioned folders found.")
    throw ""
}






# SFX Archive Creation
$sfxFilePath = Join-Path $pwd.path "sfx.txt"
if (Test-Path $sfxFilePath) {
    Remove-Item $sfxFilePath
}

# Create SFX properties
$sfxContent = @"
;The comment below contains SFX script commands
Path=C:\Biesse\bSuite\Macro
Text=  This will extract Macro "$($script:baseFolderName)" to: C:\Biesse\bSuite\Macro\
Title=$($script:baseFolderName) REV $($highest.Value)
Overwrite=1
Silent=0
License= License and Agreement
"@
# Presetup=<hide>PowerShell -Command "Add-Type -AssemblyName PresentationFramework;[System.Windows.MessageBox]::Show('CLOSE BSOLID!!!!')"
# Setup=<hide>PowerShell -Command "Add-Type -AssemblyName PresentationFramework;[System.Windows.MessageBox]::Show('RESTART BSOLID!!!!')"


Set-Content -Path $sfxFilePath -Value $sfxContent

if (Test-Path $($script:baseFolderName)) {
    Remove-Item -recurse $($script:baseFolderName) 
}
Copy-Item -Path "$($highest.Key)" -Destination "$($script:baseFolderName)" -Recurse

# Compilation Command
$exeFileName = "$($highest.Key).exe"
$compilationCommand = "`"$winrarPath\winrar.exe`" a -sfx -r -z`"$sfxFilePath`" $exeFileName .\$($script:baseFolderName) "

$arguments = "a -sfx -r -z`"$sfxFilePath`" $exeFileName .\$($script:baseFolderName)"
Start-Process -FilePath "$winrarPath\rar.exe" `
              -ArgumentList $arguments `
              -NoNewWindow `
              -Wait `
              -RedirectStandardOutput "Ignore" `
              -RedirectStandardError "SilentlyContinue" 
Remove-Item -recurse $($script:baseFolderName) 

Remove-Item $sfxFilePath
Remove-Item "$folderPath\Ignore"
Remove-Item "$folderPath\SilentlyContinue"
# # # # Execute Compilation
# Invoke-Expression $compilationCommand

$logger.Info( "Compilation completed.")

if($script:IDE){Stop-Transcript} ##exit transcript
$logger.Debug("Script ended $(Get-Date)")






### END OF FILE ###
#below here is just som classes

class AppUtility {
    static [object[]] Get_AppPath ([string]$AppName) {
        $registryPaths = @(
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
            "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall",
            "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
        )

        $appPathKeys = @(
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths",
            "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths"
        )

        $results = @()

        foreach ($path in $registryPaths) {
            Get-ChildItem -Path $path -ErrorAction SilentlyContinue | ForEach-Object {
                $app = Get-ItemProperty $_.PSPath -ErrorAction SilentlyContinue
                if ($app.DisplayName -and $app.DisplayName -like "*$AppName*") {
                    $results += [PSCustomObject]@{
                        Name         = $app.DisplayName
                        Version      = $app.DisplayVersion
                        InstallPath  = $app.InstallLocation
                        UninstallCmd = $app.UninstallString
                        RegistryKey  = $_.PSPath
                    }
                }
            }
        }

        foreach ($key in $appPathKeys) {
            Get-ChildItem -Path $key -ErrorAction SilentlyContinue | ForEach-Object {
                $exeName = $_.PSChildName
                if ($exeName -like "*$AppName*") {
                    $app = Get-ItemProperty $_.PSPath -ErrorAction SilentlyContinue
                    $results += [PSCustomObject]@{
                        Name         = $exeName
                        Version      = $null
                        InstallPath  = Split-Path -Path $app.'(default)' -Parent
                        UninstallCmd = $null
                        RegistryKey  = $_.PSPath
                    }
                }
            }
        }

        return $results
    }

    static [bool] IsIDE([Logger]$logger , [string]$hostname ,[string]$PSEditor ) {
        $logger.Debug("Check IDE")

        # $hostName = $Host.Name

        return (
            $hostName -match 'ISE' -or
            $hostName -match 'Visual Studio' -or
            $hostName -match 'VSCode' #-or
            # $env:TERM_PROGRAM -eq 'vscode' 
            # -or $null -ne $PSEditor
        )
    }



}

# function IsIDE {
#     $logger.Debug("Check IDE")
#     $hostName = $Host.Name
#     return (
#         $hostName -match 'ISE' -or
#         $hostName -match 'Visual Studio' -or
#         $hostName -match 'VSCode' -or
#         $env:TERM_PROGRAM -eq 'vscode' -or
#         $null -ne $PSEditor
#     )
# }


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
    Logger([LogLevelEnum]$logLevel = [LogLevelEnum]::Info, [string]$logFile =$null) {


        # $pwd.path+"\logs\$ApplicationName"+"_"+"$logStamp.log"
        $this.LogLevel = $logLevel
        
        # Resolve relative path to full path
        $resolvedPath = if ([IO.Path]::IsPathRooted($logFile)) {
            $logFile
        } else {
            Join-Path -Path $PWD.Path -ChildPath $logFile
        }
        $this.LogFile = $resolvedPath

        # Ensure the parent directory exists
        $logDir = [IO.Path]::GetDirectoryName($this.LogFile)
        if (-not (Test-Path $logDir)) {
            New-Item -ItemType Directory -Path $logDir -Force | Out-Null
        }

        # Ensure the log file exists
        if (-not (Test-Path $this.LogFile)) {
            New-Item -ItemType File -Path $this.LogFile -Force | Out-Null
        }
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
            # Write-Information $message
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
        if ($this.LogLevel -in @([LogLevelEnum]::Error, [LogLevelEnum]::Debug)) {
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
