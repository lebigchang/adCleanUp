
# -----------------------------------------------------
# Powershell script to check for empty groups to remove
# Written by: Aron Englundh (lebigchang)
# -----------------------------------------------------

$fileName = Read-Host("Enter the filename that you want(example.csv)")

If($fileName -notcontains ".csv"){
    $fileName += ".csv"
}

Get-ADGroup -SearchScope Subtree -LDAPFilter '(!(member=*))' | Select-Object -Property Name | Export-Csv C:\Users\$env:USERNAME\Documents\$fileName -NoTypeInformation
