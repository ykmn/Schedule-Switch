# Schedule-Switch.ps1
# if time between day and night, close app if running
# if time between night and day, run app if not running
# Last update: 2024-10-25
$day = 0930
$night = 1900
$currentdir = Split-Path $MyInvocation.MyCommand.Path -Parent
$we = $false # setting Weekend default to disable accidental start
$logfile = "$currentdir\$env:computername.log"

$procquit = "Calc"
$proc = "notepad*"
$path = "$env:SYSTEMROOT\System32\notepad.exe"
$conf = "$env:SYSTEMROOT\WindowsUpdate.txt"

# $procquit = "vmix64"
# $proc = "nnnnn*"
# $path = "$env:LOCALAPPDATA\NM\nnnnn.exe"
# $conf = "$env:LOCALAPPDATA\NM\config.ini"

function Write-Log {
    [CmdletBinding()]
    Param(
        [parameter(Mandatory=$true)]
        [string]$Message,
        
        [parameter(Mandatory=$false)]
        [ValidateSet("INFO","WARN","ERROR","FATAL","DEBUG")]
        [String]$Level = "INFO",

        [parameter(Mandatory=$false)]
        [string]$File
    )

    $timestamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
    $line = "$timestamp $Level $Message"
    Add-Content $File -Value $line
    Write-Host $line
}


# Extra day-off: App should run this day
$daysoff = @(
    "20.12.2023", "21.12.2023", "29.12.2023", "30.12.2023", "31.12.2023",
    "1.01.2024", "2.01.2024", "3.01.2024", "4.01.2024", "5.01.2024", "6.01.2024", "7.01.2024", "8.01.2024", 
    "23.02.2024",
    "8.03.2024", 
    "29.04.2024", "30.04.2024", "1.05.2024", "9.05.2024", "10.05.2024",
    "12.06.2024",
"22.10.2024",
"25.10.2024", 
    "4.11.2024",
    "30.12.2024", "31.12.2024",
    "1.01.2025", "2.01.2025", "3.01.2025", "4.01.2025", "5.01.2025", "6.01.2025", "7.01.2025", "8.01.2025",
    "8.05.2025", "9.05.2025",
    "12.06.2025", "13.06.2025",
    "3.11.2025", "4.11.2025",
    "31.12.2025"
)
# Extra work-day: App should NOT run this day
$dayson = @(
    "27.04.2024", "2.11.2024", "28.12.2024",
    "1.11.2025"
)


[int]$t = Get-Date -Format "HHmm"
Write-Log -Message "Time: $t" -Level "DEBUG" -File $logfile

# get day of week
if ( ((Get-Date -UFormat %u) -ge 6) -or ((Get-Date -UFormat %u) -eq 0) ) {
    Write-Log -Message "It's Weekend " -Level "INFO" -File $logfile
    $we = $true
} else {
    Write-Log -Message "It's Work Day " -Level "INFO" -File $logfile
    $we = $false
}
if ($daysoff | Where-Object { $_ -eq (Get-Date -Format "dd.MM.yyyy") } ) {
    Write-Log -Message "Found EXTRA DAY-OFF " -Level "INFO" -File $logfile
    $we = $true
}
if ($dayson | Where-Object { $_ -eq (Get-Date -Format "dd.MM.yyyy") } ) {
    Write-Log -Message "FOUND EXTRA WORK-DAY " -Level "INFO" -File $logfile
    $we = $false
}
Write-Log -Message "Is Weekend: $we " -Level "DEBUG" -File $logfile 

# Day time
# between $day and $night AND not weekend or extra day off
if ( ($t -gt $day) -and ($t -lt $night) -and !($we) ) {
    Write-Log -Message "Considering it's Day Time between $day and $night (Weekend is $we)" -Level "INFO" -File $logfile
    if (Get-Process | Where-Object {$_.ProcessName -like $proc}) {
        Write-Log -Message "Run-Process proc found: closing." -Level "WARN" -File $logfile
        Get-Process | Where-Object {$_.ProcessName -like $proc} | Stop-Process -Force
    } else {
        Write-Log -Message "Run-Process not found: doing nothing." -Level "INFO" -File $logfile
    }
}

# Night time
# later tnan $night OR between midnight and $night OR weekend or extra day off
if (      (  ($t -gt $night) -or (($t -gt 0000) -and ($t -lt $day))  ) -or ($we)     ) {
    Write-Log -Message "Considering it's Night Time between $night and $day (Weekend is $we)" -Level "INFO" -File $logfile
     
#   Quit process
    if (Get-Process | Where-Object {$_.ProcessName -like $procquit}) {
        Write-Log -Message "Quit-Process found: closing." -Level "WARN" -File $logfile
        Get-Process | Where-Object {$_.ProcessName -like $procquit} | Stop-Process -Force
	Start-Sleep -Seconds 3	
    }
#   Start process
    if (!(Get-Process | Where-Object {$_.ProcessName -like $proc})) {
        Write-Log -Message "No Run-Process found: starting." -Level "INFO" -File $logfile
        Start-Process -FilePath $path -ArgumentList $conf -WindowStyle Minimized # -NoNewWindow
        # Start screensaver
        & $([System.Environment]::SystemDirectory+"\scrnsave.scr")
    } else {
        Write-Log -Message "Run-Process already found: doing nothing." -Level "INFO" -File $logfile
    }
}
