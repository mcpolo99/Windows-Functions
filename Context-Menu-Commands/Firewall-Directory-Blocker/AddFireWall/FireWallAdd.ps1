$Today = Get-Date -Format 'yyyy-MM-dd'
$logFilePath = "$env:TEMP\FireWallAdd_debug-$Today.log"
$scriptPath = (Resolve-Path .\).Path 
$exeFiles = Get-ChildItem -Path $scriptPath -Recurse -Include *.exe | Where-Object {! $_.PSIsContainer}
$maxDots=$exeFiles.Length


function Write-Log {
    param (
        [string]$Message,
        [string]$LogLevel = "INFO"
    )

    # Get the current timestamp
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'

    # Construct the log entry with timestamp and log level
    $logEntry = "$timestamp [$LogLevel] - $Message"

    # Specify the path to the log file
    # $logFilePath = "$env:TEMP\FireWallAdd_debug.log"

    # Append the log entry to the log file
    #$logEntry | Out-File -NoClobber -Append -FilePath $logFilePath
    Add-Content -Path $logFilePath -Value $logEntry

}
function Is-Elevated {
    # Check if the script is running with administrative privileges
    $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object System.Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

Write-Log("Executing path: ",$scriptPath)

function Main-Menu
{
    if (-not (Is-Elevated)) {
        Write-Host "This script requires administrative privileges. Please run as administrator."
        Write-Log -Message "Script run attempt without administrative privileges." -LogLevel "ERROR"
        Pause
        return
    }
    else{
        Write-Log -Message "Script run attempt with administrative privileges." -LogLevel "Info"
    }

    Write-Log("Start of main menu")



    param (
        [string]$Title = 'My Menu'
    )
    Clear-Host
    Write-Host "================ $Title ================"
    write-host "Current Working Dir $pwd"
    #Write-Host "1: Just a Menu that does nothing"
    Write-Host "2: FirewallCheck."
    Write-Host "3: FirewallRemove"
    Write-Host "4: FirewallAdd"
    Write-Host "5: open log file"
    
    #Write-Host "5: FirewallAddNew"
    #Write-Host "6: FirewallRemoveNew"
    Write-Host "Q: Press 'Q' to quit."
}

Function FirewallCheck 
{

    #$scriptPath = (Resolve-Path .\).Path

    #$FWRNameContainer = get-childitem -Path $scriptPath -Recurse -Include *.exe| where {! $_.PSIsContainer}

    $exist=$false
    $noexist=$false
    $dotCount = 0
    

    foreach ($exefile in $exeFiles)
    {
    

        $dots = '.' * (($dotCount % $maxDots) + 1)
        #Write-Log("Checking: ", ($pwd.Path.Length.ToString() +'\'+$FWRName1.Name))
        if($(Get-NetFirewallRule –DisplayName ($pwd.Path.Length.ToString() +'\'+$exefile.Name) -ErrorAction SilentlyContinue))
        {
            Write-Log(($pwd.Path.Length.ToString() +'\'+$exefile.Name) , " - Exists")
            Write-Host -NoNewline "Checking: - Exists $dots`r"
            $exist=$true
            #return
        }
        else
        {
            Write-Log(($pwd.Path.Length.ToString() +'\'+$exefile.Name) , " - does not Exists")
            Write-Host -NoNewline "Checking: - does not Exist $dots`r"
            $noexist=$true
            #return
       }
       $dotCount++
    }

    if($exist -and $noexist){
        Write-Log("rules Partialy existing, returning")
            write-host "-------------------------------"  
            write-host "Partial Existing rules"  
            write-host "-------------------------------"
            pause
    }
    elseif(!$exist -and $noexist){
        Write-Log("no rules existing, returning")
            write-host "-------------------------------"
            write-host "Firewall rule does not already exist"
            write-host "-------------------------------"
            pause

    }
    elseif($exist -and !$noexist){
        Write-Log("all rules Exist, returning")
            write-host "-------------------------------"  
            write-host "ALL RULES EXIST"  
            write-host "-------------------------------"
            pause

    }
}

function FirewallAddNew {
    #$scriptPath = (Resolve-Path .\).Path

    # Gather all .exe files in the directory
    #$exeFiles = Get-ChildItem -Path $scriptPath -Recurse -Include *.exe | Where-Object {! $_.PSIsContainer}

    # Initialize a list to hold the names of new firewall rules
    $dotCount = 0
    $rulesToAdd = @()

    # Check each EXE file and determine if a firewall rule already exists
    foreach ($exeFile in $exeFiles) {

        $dots = '.' * (($dotCount % $maxDots) + 1)


        $ruleName = Join-Path -Path $pwd.Path.Length -ChildPath $exeFile.Name
        if (-not (Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue)) {
            $rulesToAdd += $exeFile
            Write-Log -Message "Rule for $ruleName does not exist. Will add new rule." -LogLevel "INFO"
            Write-Host -NoNewline "$dots`r"
        } else {
            Write-Log -Message "Rule for $ruleName already exists. Skipping." -LogLevel "INFO"
            Write-Host -NoNewline "$dots`r"
        }
        $dotCount++
    }

    # If there are rules to add, create them
    $dotCount = 0
    if ($rulesToAdd.Count -gt 0) {
        foreach ($rule in $rulesToAdd) {
        $dots = '.' * (($dotCount % $maxDots) + 1)

            try{
                $ruleName = Join-Path -Path $pwd.Path.Length -ChildPath $rule.Name
                New-NetFirewallRule -DisplayName $ruleName -Description $pwd.Path -Action Block -Direction Outbound -Program $rule.FullName
                New-NetFirewallRule -DisplayName $ruleName -Description $pwd.Path -Action Block -Direction Inbound -Program $rule.FullName
                Write-Log -Message "Added new firewall rules for $ruleName" -LogLevel "INFO"
                Write-Host -NoNewline "$dots`r"
                #$rulesToAdd -= $rule
            }
            catch{
                Write-Log -Message "Failed to Add firewall rule for $($rule.DisplayName). Error: $_" -LogLevel "ERROR"
                Write-Host "Failed to add firewall rule for $($rule.DisplayName). Check the log for details."
                Write-Host -NoNewline "$dots`r"
            }  
            $dotCount++
        }
        $dotCount=0
        Write-Host -NoNewline "$dots`r"
        Write-Host "-------------------------------"
        Write-Host "ALL NEW RULES ADDED"
        Write-Host "-------------------------------"
        Write-Log -Message "ALL NEW RULES ADDED" -LogLevel "INFO"
    } 
    else {
        Write-Host "-------------------------------"
        Write-Host "All Rules Already Exist"
        Write-Host "-------------------------------"
        Write-Log -Message "All Rules Already Exist" -LogLevel "INFO"
    }

    Pause
}

function FirewallRemoveNew {
    #$scriptPath = (Resolve-Path .\).Path

    # Gather all .exe files in the directory
    #$exeFiles = Get-ChildItem -Path $scriptPath -Recurse -Include *.exe | Where-Object {! $_.PSIsContainer}

    # Initialize a list to hold the names of rules to remove
    $rulesToRemove = @()
    $dotCount = 0

    # Check each EXE file and determine if a firewall rule exists
    foreach ($exeFile in $exeFiles) {
        $dots = '.' * (($dotCount % $maxDots) + 1)

        $ruleName = Join-Path -Path $pwd.Path.Length -ChildPath $exeFile.Name
        $existingRule = Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue
        if ($existingRule) {
            $rulesToRemove += $existingRule
            Write-Log -Message "Rule for $ruleName exists. Will remove rule." -LogLevel "INFO"
            Write-Host -NoNewline  "- $dots`r"
            
        } else {
            Write-Log -Message "Rule for $ruleName does not exist. Skipping." -LogLevel "INFO"
            Write-Host -NoNewline "- $dots`r"
        }
        $dotCount++
    }


    # If there are rules to remove, delete them
    Write-Host ""
    $dotCount = 0
    if ($rulesToRemove.Count -gt 0) {

         $rulesToRemove.ForEach({

            $dots = '.' * (($dotCount % $maxDots) + 1)
            try {
                Remove-NetFirewallRule -Name $_.Name
                Write-Log -Message "Successfully removed firewall rule for $($_.Name)" -LogLevel "INFO"
                Write-Host -NoNewline "$dots`r"
            } catch {
                Write-Log -Message "Failed to remove firewall rule for $($_.Name). Error: $_" -LogLevel "ERROR"
                Write-Host "Failed to remove firewall rule for $($_.Name). Check the log for details."
                Write-Host -NoNewline "$dots`r"
            }
            $dotCount++
        })

        <#

        foreach ($rule in $rulesToRemove) {
            try {
                Remove-NetFirewallRule -Name $rule.Name
                Write-Log -Message "Successfully removed firewall rule for $($rule.DisplayName)" -LogLevel "INFO"
                $rulesToRemove -= $rule
            } 
            catch {
                Write-Log -Message "Failed to remove firewall rule for $($rule.DisplayName). Error: $_" -LogLevel "ERROR"
                Write-Host "Failed to remove firewall rule for $($rule.DisplayName). Check the log for details."
            }
        }
        #>


        Write-Host "-------------------------------"
        Write-Host "ALL REMOVED RULES"
        Write-Host "-------------------------------"
        $rulesToRemove = @()
        Write-Log -Message "ALL REMOVED RULES" -LogLevel "INFO"
    } else {
        Write-Host "-------------------------------"
        Write-Host "No Rules To Remove"
        Write-Host "-------------------------------"
        Write-Log -Message "No Rules To Remove" -LogLevel "INFO"
    }

    Pause
}

Function End{
clear
write-host "Done! all EXE´s Added To firewall.!"
Read-Host -Prompt "Press any key to continue"
}

do{
     Main-Menu
     $selection = Read-Host "Please make a selection"
     switch ($selection)
     {
         '2' 
         {
            Write-Log("Firewall check")
            FirewallCheck     
         } 
         '3' 
         {
            Write-Log("Firewall remove")
            FirewallRemoveNew
         }
         '4' 
         {
            Write-Log("Firewall add")
            FirewallAddNew
         }
         '5'
         {
            Start-Process notepad.exe -ArgumentList $logFilePath
         }
         
         'q'
         {
         }
     }
 }
 until ($selection -eq 'q')

 pause