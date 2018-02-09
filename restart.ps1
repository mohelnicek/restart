$detected = @()

write-host "Gathering information`n" -foregroundcolor green
foreach($computer in Get-Content .\restart.txt) {
    write-host $computer -foregroundcolor yellow
    try {
        if( (Test-Connection $computer -quiet -count 2) ) {
            $adminCount = 0
            $userCount = 0
            @(Get-WmiObject -class win32_process -ComputerName $computer | `
                Where-Object {$_.Name -Match "explorer"}) | `
                    foreach-object {
                        if( ($_.getowner().domain -match $computer) -and ($_.getowner().user -match "Administrator") ) {
                            $adminCount = 1
                        }
                        if( ($_.getowner().domain -notmatch $computer) ) {
                            $userCount += 1
                        }
                    }
            write-host "Local administrator logged in: $adminCount"
            write-host "Domain users logged in: $userCount"
            if((($adminCount + $userCount) -eq 0) ) {
                $detected += $computer
            }
        } else {
            write-host "Computer is offline"
        }
    }
    catch {
        write-host "Unknown error" --foregroundcolor red
    }
    write-host ""
}

if($detected.count -gt 0) {
    Start-Sleep –Seconds 60
    write-host "`nRestarting computers with no users logged in`n" -foregroundcolor green

    foreach($computer in $detected) {
        write-host $computer -foregroundcolor yellow
        try {
            if( (Test-Connection $computer -quiet -count 2) ) {
                $adminCount = 0
                $userCount = 0
                @(Get-WmiObject -class win32_process -ComputerName $computer | `
                    Where-Object {$_.Name -Match "explorer"}) | `
                        foreach-object {
                            if( ($_.getowner().domain -match $computer) -and ($_.getowner().user -match "Administrator") ) {
                                $adminCount = 1
                            }
                            if( ($_.getowner().domain -notmatch $computer) ) {
                                $userCount += 1
                            }
                        }
                write-host "Local administrator logged in: $adminCount"
                write-host "Domain users logged in: $userCount"
                if( (($adminCount + $userCount) -eq 0) ) {
                    write-host "Restarting computer"
                    restart-computer -computername $computer
                } else {
                    write-host "Someone logged in while the script was running"
                }
            } else {
                write-host "Computer is offline"
            }
        }
        catch {
            write-host "Unknown error" --foregroundcolor red
        }
        write-host ""
    }
} else {
    write-host "There are no computers without any user logged in" -foregroundcolor green
}
