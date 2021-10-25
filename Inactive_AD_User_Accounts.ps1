Import-Module ActiveDirectory

# Set the number of days since last logon
$DaysInactive = 90
$InactiveDate = (Get-Date).Adddays(-($DaysInactive))
  
#-------------------------------
# FIND INACTIVE USERS
#-------------------------------
# Below are four options to find inactive users. Select the one that is most appropriate for your requirements:

# Get AD Users that haven't logged on in xx days
$Users = Get-ADUser -Filter { LastLogonDate -lt $InactiveDate -and Enabled -eq $true } -Properties LastLogonDate, Description, WhenCreated | Select-Object @{ Name="Username"; Expression={$_.SamAccountName} }, Name, LastLogonDate, WhenCreated, DistinguishedName, Description

# Get AD Users that haven't logged on in xx days and are not Service Accounts
$Users1 = Get-ADUser -Filter { LastLogonDate -lt $InactiveDate -and Enabled -eq $true -and SamAccountName -notlike "*svc*" -and SamAccountName -notlike "*ftp*" -and Description -notlike "*service*" -and Description -notlike "*ftp*" -and Description -notlike "*Built-in*"} -Properties LastLogonDate, Description, WhenCreated | Select-Object @{ Name="Username"; Expression={$_.SamAccountName}}, Name, LastLogonDate, WhenCreated, DistinguishedName, Description

# Get AD Users that haven't logged on in xx days and are Service Accounts
$Users4 = Get-ADUser -Filter {SamAccountName -like "*svc*" -or SamAccountName -like "*ftp*" -or Description -like "*service*" -or Description -like "*ftp*" -and LastLogonDate -lt $InactiveDate -and Enabled -eq $true} -Properties LastLogonDate, Description, WhenCreated | Select-Object @{ Name="Username"; Expression={$_.SamAccountName}}, Name, LastLogonDate, WhenCreated, DistinguishedName, Description

# Get AD Users that have never logged on
$Users2 = Get-ADUser -Filter { LastLogonDate -notlike "*" -and Enabled -eq $true } -Properties LastLogonDate, Description, WhenCreated | Select-Object @{ Name="Username"; Expression={$_.SamAccountName} }, Name, LastLogonDate, WhenCreated , DistinguishedName, Description

# Get AD Users that have never logged on and are not Service Accounts
$Users3 = Get-ADUser -Filter { LastLogonDate -notlike "*" -and Enabled -eq $true -and SamAccountName -notlike "*svc*" -and SamAccountName -notlike "*ftp*" -and Description -notlike "*service*" -and Description -notlike "*ftp*" -and Description -notlike "Built-in" } -Properties LastLogonDate, Description, WhenCreated | Select-Object @{ Name="Username"; Expression={$_.SamAccountName} }, Name, LastLogonDate, WhenCreated , DistinguishedName, Description


#-------------------------------
# REPORTING
#-------------------------------
# Export results to CSV
$Users | Export-Csv C:\Temp\ADReports\InactiveUsers_NotLoggedOnRecently.csv -NoTypeInformation
$Users1 | Export-Csv C:\Temp\ADReports\InactiveUsers_NotLoggedOnRecentlyNOTSVC.csv -NoTypeInformation
$Users2 | Export-Csv C:\Temp\ADReports\InactiveUsers_NeverLoggedOn.csv -NoTypeInformation
$Users3 | Export-Csv C:\Temp\ADReports\InactiveUsers_NeverLoggedOnNOTSVC.csv -NoTypeInformation
$Users4 | Export-Csv C:\Temp\ADReports\InactiveUsers_NotLoggedOnRecently_IS_A_SVC.csv -NoTypeInformation
#-------------------------------
# INACTIVE USER MANAGEMENT
#-------------------------------
# Below are two options to manage the inactive users that have been found. Either disable them, or delete them. Select the option that is most appropriate for your requirements:
# Uncomment to execute

# # Disable Inactive Users
# ForEach ($Item in $Users){
  # $DistName = $Item.DistinguishedName
  # Disable-ADAccount -Identity $DistName
  # Get-ADUser -Filter { DistinguishedName -eq $DistName } | Select-Object @{ Name="Username"; Expression={$_.SamAccountName} }, Name, Enabled
# }

# # Delete Inactive Users
# ForEach ($Item in $Users){
  # Remove-ADUser -Identity $Item.DistinguishedName -Confirm:$false
  # Write-Output "$($Item.Username) - Deleted"
# }