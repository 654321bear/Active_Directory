Import-Module ActiveDirectory

#-------------------------------
# FIND EMPTY GROUPS
#-------------------------------

# Get empty AD Groups within a specific OU
$Groups = Get-ADGroup -Filter { Members -notlike "*" } -SearchBase "DC=COMPANY,DC=com" | Select-Object Name, GroupCategory, DistinguishedName

#-------------------------------
# REPORTING
#-------------------------------

# Export results to CSV
$Groups | Export-Csv C:\Temp\ADReports\Empty_AD_Groups.csv -NoTypeInformation

#-------------------------------
# INACTIVE GROUP MANAGEMENT
#-------------------------------

# Delete Inactive Groups (uncomment to execute)
#ForEach ($Item in $Groups){
#  Remove-ADGroup -Identity $Item.DistinguishedName -Confirm:$false
#  Write-Output "$($Item.Name) - Deleted"
#}