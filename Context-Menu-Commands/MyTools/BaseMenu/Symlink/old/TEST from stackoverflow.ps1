$command = {
    param
    (
        [Parameter(Mandatory)]
        [string[]]
        $MyList
    )
    $MyList | ForEach-Object { Write-Host $_ }
}

$bytes = [System.Text.Encoding]::Unicode.GetBytes($command)
$encodedCommand = [Convert]::ToBase64String($bytes)
"powershell.exe -noprofile -command `"'test1', 'test2', 'test3', ''`" | powershell.exe -encodedcommand $encodedCommand" | Set-Content '.\test.txt' -Encoding UTF8