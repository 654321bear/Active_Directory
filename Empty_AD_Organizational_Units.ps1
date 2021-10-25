Import-Module ActiveDirectory

#-------------------------------
# FIND EMPTY OUs
#-------------------------------

# Get empty AD Organizational Units
$OUs = Get-ADOrganizationalUnit -Filter * | ForEach-Object { If ( !( Get-ADObject -Filter * -SearchBase $_ -SearchScope OneLevel) ) { $_ } } | Select-Object Name, DistinguishedName

#-------------------------------
# REPORTING
#-------------------------------

# Export results to CSV
$OUs | Export-Csv C:\Temp\ADReports\Empty_AD_OUs.csv -NoTypeInformation

#-------------------------------
# INACTIVE OUs MANAGEMENT
#-------------------------------

# Delete Inactive OUs  (Uncoment to execute)
#ForEach ($Item in $OUs){
#  Remove-ADOrganizationalUnit -Identity $Item.DistinguishedName -Confirm:$false
#  Write-Output "$($Item.Name) - Deleted"
#}