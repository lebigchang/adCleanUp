
# -----------------------------------------------------------------------------------------
# Powershell Script to check for miss matching information in an Active Directory data base
# Written by: Aron Englundh (lebigchang)
# -----------------------------------------------------------------------------------------

$computerOu = Read-Host("What OU do you want to use?")
$resultsPath = Read-Host("Enter the filename that you want(example.csv)")
If($resultsPath -notcontains ".csv"){
    $resultsPath += ".csv"
}

function notMatching {

    $results = @()

    $missingArray = @()
    $pdonArray = @()
    $depArray = @()
    $companyArray = @()
    $computers2 = Get-ADComputer -Filter * -Properties managedBy, Company, Department, PhysicalDeliveryOfficeName -SearchBase "OU=$computerOu,DC=adm,DC=ovansiljan,DC=net"
    
    Foreach($computer2 in $computers2){
        If($null -ne $computer2.ManagedBy){
            $compUser2 = $computer2.managedBy
            $compUser2 = $compUser2.Substring(3, ($compUser2.IndexOf(',')-3))
            
            If($compUser2.Length -eq 10){
                $whatuser2 = Get-ADUser -Identity $compUser2 -Properties Company, Department, PhysicalDeliveryOfficeName
                
                If($null -eq $computer2.Company) {
                    $missingArray += $computer2.Name
                    $missingDetails = @{
                        User        = $whatuser2.Name
                        Computer    = $Computer2.Name
                        Problem     = "This computer doesen't have any company info"
                        Dn          = $whatuser2.DistinguishedName
                        computerDn  = $computer2.DistinguishedName
                    }
                    $results += New-Object PSObject -Property $missingDetails
                    continue
                }
                
                If($null -eq $whatuser2.Company) {
                    $missingArray += $whatuser2.Name
                    $missingDetails = @{
                        User        = $whatuser2.Name
                        Computer    = $Computer2.Name
                        Problem     = "This user doesen't have any company info"
                        Dn          = $whatuser2.DistinguishedName
                        computerDn  = $computer2.DistinguishedName
                    }
                    $results += New-Object PSObject -Property $missingDetails
                    continue
                }
                
                If($null -eq $computer2.Department) {
                    $missingArray += $computer2.Name
                    $missingDetails = @{
                        User        = $whatuser2.Name
                        Computer    = $Computer2.Name
                        Problem     = "This computer doesen't have any department info"
                        Dn          = $whatuser2.DistinguishedName
                        computerDn  = $computer2.DistinguishedName
                    }
                    $results += New-Object PSObject -Property $missingDetails
                    continue
                }

                If($null -eq $whatuser2.Department) {
                    $missingArray += $whatuser2.Name
                    $missingDetails = @{
                        User        = $whatuser2.Name
                        Computer    = $Computer2.Name
                        Problem     = "This user doesen't have any department info"
                        Dn          = $whatuser2.DistinguishedName
                        computerDn  = $computer2.DistinguishedName
                    }
                    $results += New-Object PSObject -Property $missingDetails
                    continue
                }

                If($null -eq $computer2.PhysicalDeliveryOfficeName) {
                    $missingArray += $computer2.Name
                    $missingDetails = @{
                        User        = $whatuser2.Name
                        Computer    = $Computer2.Name
                        Problem     = "This computer doesen't have any physicalDeliveryOfficeName info"
                        Dn          = $whatuser2.DistinguishedName
                        computerDn  = $computer2.DistinguishedName
                    }
                    $results += New-Object PSObject -Property $missingDetails
                    continue
                }
                
                If($null -eq $whatuser2.PhysicalDeliveryOfficeName) {
                    $missingArray += $computer2.Name
                    $missingDetails = @{
                        User        = $whatuser2.Name
                        Computer    = $Computer2.Name
                        Problem     = "This computer doesen't have any company info"
                        Dn          = $whatuser2.DistinguishedName
                        computerDn  = $computer2.DistinguishedName
                    }
                    $results += New-Object PSObject -Property $missingDetails
                    continue
                }

                If((($null -ne $computer2.Company) -and ($null -ne $computer2.Department) -and ($null -ne $computer2.PhysicalDeliveryOfficeName)) -and (($null -ne $whatuser2.Company) -and ($null -ne $whatuser2.Department) -and ($null -ne $whatuser2.PhysicalDeliveryOfficeName))){
                    
                    If(!($computer2.Company -eq $whatuser2.Company)) {
                        $companyArray += $whatuser2.Name
                        $company = $whatuser2.company
                        $ccompany = $computer2.company
                        $missingDetails = @{
                            User        = $whatuser2.Name
                            Computer    = $Computer2.Name
                            Problem     = "The companies $company and $ccompany don't match"
                            Dn          = $whatuser2.DistinguishedName
                            computerDn  = $computer2.DistinguishedName
                        }
                        $results += New-Object PSObject -Property $missingDetails
                    }
                    
                    If(!($computer2.Department -eq $whatuser2.Department)) {
                        $depArray += $whatuser2.Name
                        $dep = $whatuser2.department
                        $cdep = $computer2.department
                        $missingDetails = @{
                            User        = $whatuser2.Name
                            Computer    = $Computer2.Name
                            Problem     = "The departments $dep and $cdep isn't matching"
                            Dn          = $whatuser2.DistinguishedName
                            computerDn  = $computer2.DistinguishedName
                        }
                        $results += New-Object PSObject -Property $missingDetails
                    }
                    
                    If(!($computer2.PhysicalDeliveryOfficeName -eq $whatuser2.PhysicalDeliveryOfficeName)) {
                        $pdon = $whatuser2.PhysicalDeliveryOfficeName
                        $cpdon = $computer2.physicalDeliveryOfficeName
                        $missingDetails = @{
                            User        = $whatuser2.Name
                            Computer    = $Computer2.Name
                            Problem     = "The physicalDeliveryOfficeNames $pdon and $cpdon isn't matching"
                            Dn          = $whatuser2.DistinguishedName
                            computerDn  = $computer2.DistinguishedName
                        }
                        $pdonArray += $whatuser2.Name
                        $results += New-Object PSObject -Property $missingDetails
                    }
                }
            }
        }
    }

    $missingCount = $missingArray.Length
    $pdonCount = $pdonArray.Length
    $depCount = $depArray.Length
    $companyCount = $companyArray.Length
    
    Write-Output "$missingCount users have missing information `n"
    Write-Output "$pdonCount users don't have matching PhysicalDeliveryOfficeName data `n"
    Write-Output "$depCount users don't have matching department data `n"
    Write-Output "$companyCount users don't have matching company data `n"

    $results | export-csv -Path C:\Users\$env:username\Documents\$resultsPath -NoTypeInformation -encoding UTF8
}
notMatching