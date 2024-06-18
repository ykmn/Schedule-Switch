# Schedule-Switch.ps1
# if time between day and night, close app if running
# if time between night and day, run app if not running
# Last update: 2024-06-16
$day = 0700
$night = 2200
$proc = "notepad*"
$path = "$env:SYSTEMROOT\System32\notepad.exe"
$conf = "$env:SYSTEMROOT\WindowsUpdate.txt"
#$path = "$env:PROGRAMDATA\Microsoft\NM\program.exe"
#$conf = "$env:PROGRAMDATA\Microsoft\NM\program.ini"
$we = $false    # setting Work Time by default

# App should run this day: this is extra day-off
$daysoff = @(
    "20.12.2023", "21.12.2023", "29.12.2023", "30.12.2023", "31.12.2023",
    "1.01.2024", "2.01.2024", "3.01.2024", "4.01.2024", "5.01.2024", "6.01.2024", "7.01.2024", "8.01.2024", 
    "23.02.2024",
    "8.03.2024", 
    "29.04.2024", "30.04.2024", "1.05.2024", "9.05.2024", "10.05.2024",
    "12.06.2024",
    "4.11.2024",
    "30.12.2024", "31.12.2024"
)
# App should NOT run this day: this is work day
$dayson = @(
    "27.04.2024", "2.11.2024", "28.12.2024"
)


[int]$t = Get-Date -Format "HHmm"
Write-Host "Time:" $t

# get day of week
if ( ((Get-Date -UFormat %u) -eq 6) -or ((Get-Date -UFormat %u) -eq 0) ) {
    Write-Host "* Weekend " -NoNewline
    $we = $true
}
if ($daysoff | Where-Object { $_ -eq (Get-Date -Format "dd.MM.yyyy") } ) {
    Write-Host "* Extra day: off " -NoNewline
    $we = $true
}
if ($dayson | Where-Object { $_ -eq (Get-Date -Format "dd.MM.yyyy") } ) {
    Write-Host "* Extra work: day " -NoNewline
    $we = $false
}
Write-Host "* Working day:" $we "" -NoNewline

# Day time
# between $day and $night AND not weekend or extra day off
if ( ($t -gt $day) -and ($t -lt $night) -and !($we) ) {
    Write-Host "* Considering Day time between $day and $night " -NoNewline
    if (Get-Process | Where-Object {$_.ProcessName -like $proc}) {
        Write-Host "* Process found: closing."
        Get-Process | Where-Object {$_.ProcessName -like $proc} | Stop-Process -Force
    } else {
        Write-Host "* Process not found: doing nothing."
    }
}

# Night time
# later tnan $night OR between midnight and $night OR weekend or extra day off
if ( ($t -gt $night) -or ($we) -or (($t -gt 0000) -and ($t -lt $day)) ) {
    Write-Host "* Considering Night time between $night and $day " -NoNewline
    if (!(Get-Process | Where-Object {$_.ProcessName -like $proc})) {
        Write-Host "* No process found: starting."
        Start-Process -FilePath $path -ArgumentList $conf -WindowStyle Minimized # -NoNewWindow
    } else {
        Write-Host "* Process found: doing nothing."
    }
}
