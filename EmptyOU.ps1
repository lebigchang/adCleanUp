
# -----------------------------------------------------------------------------------------
# Powershell Script to check for empy OU's in AD DataBase
# Written by: Aron Englundh (lebigchang)
# -----------------------------------------------------------------------------------------

$resultsPath = Read-Host("Enter the filename that you want(example.csv)")
$ous = Get-ADOrganizationalUnit -Filter * -SearchScope Subtree
$results = @()

If($resultsPath -notcontains ".csv"){
        $resultsPath += ".csv"
}

ForEach($ou in $ous){
        $ouName = $ou.name
        $ouUsers = Get-ADUser -Filter * -SearchBase $ou
        $ouComputers = Get-ADComputer -Filter * -SearchBase $ou
        $subOus = Get-ADOrganizationalUnit -Filter * -SearchBase $ou
        $ouGroups = Get-ADGroup -Filter * -SearchBase $ou

        [Int32[]]$usrCount = $ouUsers.count
        [Int32[]]$groupCount = $ouGroups.count
        [Int32[]]$subOuCount = $subOus.count
        [Int32[]]$comCount = $ouComputers.count

        $count = ($usrCount + $comCount + $groupCount + $subOuCount)
        If($count -lt 10) {
                $details = @{
                    Objects   = $count
                    OuName    = $ouName
                }
                $results += New-Object PSObject -Property $details
        }
}

$results | export-csv -Path C:\Users\$env:USERNAME\Documents\$resultsPath -NoTypeInformation -encoding UTF8