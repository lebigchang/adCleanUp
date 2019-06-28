
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
        $ouName = $ou.distinguishedname

        $obj = Get-ADObject -Filter * -SearchBase $ou
        $subOus = Get-ADOrganizationalUnit -Filter * -SearchBase $ou

        [Int32[]]$subOuCount = $subOus.count
        [Int32[]]$objCount = $obj.count
        
        If($subOuCount -ne 0) {
                continue
        }

        If($objcount -eq 0) {
                $details = @{
                    Objects   = $count
                    OuName    = $ouName
                }
                $results += New-Object PSObject -Property $details
        }
}

$results | export-csv -Path C:\Users\$env:USERNAME\Documents\$resultsPath -NoTypeInformation -encoding UTF8
