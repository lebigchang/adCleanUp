
# -----------------------------------------------------------------------------------------
# Powershell Script to check for inactive users in AD DataBase
# Written by: Aron Englundh (lebigchang)
# -----------------------------------------------------------------------------------------

$computerOu = Read-Host("What OU do you want to use?")
$resultsPath = Read-Host("Enter the filename that you want(example.csv)")
If($resultsPath -notcontains ".csv"){
    $resultsPath += ".csv"
}

function inactiveUsers {

    $results = @()

    $OUPath = "OU=$computerOu,[DC's HERE]"
    $computers = Get-ADComputer -Filter * -Properties managedBy -SearchBase $OUPath
    $userArray = @()
    $inactiveUserArray = @()
    $inactive = 0
    
    Foreach($computer in $computers){
        If($null -ne $computer.ManagedBy){
            $compUser = $computer.managedBy
            $compUser = $compUser.Substring(3, ($compUser.IndexOf(',')-3))
            If($compUser.Length -eq 10){
                $userArray += $compUser
            }
        }
    }

    Foreach($user in $userArray){
        $whatuser = Get-ADUser -Identity $user -Properties lastLogonDate
        If($whatuser.lastLogonDate -and $whatuser.Enabled){
            If($whatuser.LastLogonDate -lt (Get-Date).AddDays(-356)){
                $inactive++
                $inactiveUserArray += $whatuser
                $inactiveDetails = @{
                    User        = $whatuser.Name
                    Lastlogin = $whatuser.LastLogonDate
                }
                $results += New-Object PSObject -Property $inactiveDetails
            }
        }
    }
    
    $results | export-csv -Path C:\Users\$env:USERNAME\Documents\$resultsPath -NoTypeInformation -encoding UTF8
    Write-Output "$inactive users hasen't used their accounts in one year and has computers"

}
inactiveUsers
