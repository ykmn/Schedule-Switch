# Schedule-Update.ps1
# Update Scheduled Task time, enable and disable task
# Last update: 2024-10-24

param (
    [Parameter(Mandatory=$true)]
    [ValidateSet("time","stop","start")]
    [String]$command
)

$computer = "REMOTE-PC"      # remote PC. 
$taskname = "Scheduler Job"  # expected task name
$taskpath = "\Microsoft"     # expected scheduler folder

switch ($command) {
    time { 
        Write-Host "Updating task time +5 minutes"
        Invoke-Command -ComputerName $Computer -ScriptBlock {
            $t1 = New-ScheduledTaskTrigger -Daily -At $('{0:yyyy-MM-dd HH:mm:ss}' -f (Get-Date).AddMinutes(5))
            # do the magic
            $t2 = New-ScheduledTaskTrigger -Once -RepetitionInterval (New-TimeSpan -Minutes 5) -At 00:00
            $t1.Repetition = $t2.Repetition
            # end of magic
            Set-ScheduledTask -TaskName "$using:taskname" -TaskPath $using:taskpath -Trigger $t1 -EA Continue
        }
    }
    start {
        Write-Host "Enabling task and updating task time +5 minutes"
        Invoke-Command -ComputerName $Computer -ScriptBlock {
            $t1 = New-ScheduledTaskTrigger -Daily -At $('{0:yyyy-MM-dd HH:mm:ss}' -f (Get-Date).AddMinutes(5))
            # do the magic
            $t2 = New-ScheduledTaskTrigger -Once -RepetitionInterval (New-TimeSpan -Minutes 5) -At 00:00
            $t1.Repetition = $t2.Repetition
            # end of magic
            Enable-ScheduledTask -TaskName "$using:taskname" -TaskPath $using:taskpath -EA Continue
            Set-ScheduledTask -TaskName "$using:taskname" -TaskPath $using:taskpath -Trigger $t1 -EA Continue
        }
    }
    stop {
        Write-Host "Disabling task"
        Invoke-Command -ComputerName $Computer -ScriptBlock {
            Disable-ScheduledTask -TaskName "$using:taskname" -TaskPath $using:taskpath -EA Continue
        }
    }
    Default {}
}
