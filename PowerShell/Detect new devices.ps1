$before = Get-PnpDevice
Write-Host "Now connect your device..."
Start-Sleep -Seconds 10  # Give you 10 seconds to plug it in
$after = Get-PnpDevice

Compare-Object $before $after -Property Name, Status, Class, InstanceId | 
    Where-Object SideIndicator -eq "=>" | 
    Select-Object Name, Status, Class, InstanceId | 
    Format-Table -AutoSize
