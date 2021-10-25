param(
[string]$terminatedUser
)
#Initialise Array
$Report = @()

#Set Date variable
$a = date

#################################
### To use script
### .\terminatedUser.ps1 jothomps
#################################

Import-Module ActiveDirectory

### Disable Account
Disable-ADAccount -Identity $terminatedUser
echo $terminatedUser

### Generate Random Password
Add-Type -AssemblyName System.Web
$newpass = [System.Web.Security.Membership]::GeneratePassword(20, 3)
echo $newpass
$newpwd = ConvertTo-SecureString -String $newpass -AsPlainText –Force

### Set Password
Set-ADAccountPassword $terminatedUser -NewPassword $newpwd

### Gather information on user to export to file
Get-ADUser $terminatedUser -Properties * | %{

$Term = {} | Select Name, WhenCreated,UserPrincipalName,Title,OfficePhone,physicalDeliveryOfficeName,Manager,Department,Enabled,WhenChanged,PasswordLastSet,givenName,sn
$Term.givenName = $_.givenName
$Term.sn = $_.sn
$Term.Name = $_.Name
$Term.WhenCreated = $_.WhenCreated
$Term.UserPrincipalName = $_.UserPrincipalName
$Term.Title = $_.Title
$Term.OfficePhone = $_.OfficePhone
$Term.physicalDeliveryOfficeName = $_.physicalDeliveryOfficeName
$Term.Manager = $_.Manager
$Term.Department = $_.Department
$Term.Enabled = $_.Enabled
$Term.WhenChanged = $_.WhenChanged
$Term.PasswordLastSet = $_.PasswordLastSet

}
$ClearName = $Term.givenName + " " + $Term.sn
$Report += "##################################################################" 
$Report += "### Termination Report for " +  $Term.givenName + " " + $Term.sn
$Report += "##################################################################" 
$Report += ""
$Report += ""
$Report += ""

#Display Report
$Report += "                      Name:   " + "" + $ClearName
$Report += "               WhenCreated:   " + "" + $Term.WhenCreated
$Report += "         UserPrincipalName:   " + "" + $Term.UserPrincipalName
$Report += "                     Title:   " + "" + $Term.Title
$Report += "               OfficePhone:   " + "" + $Term.OfficePhone
$Report += "physicalDeliveryOfficeName:   " + "" + $Term.physicalDeliveryOfficeName
$Report += "                   Manager:   " + "" + $Term.Manager
$Report += "                Department:   " + "" + $Term.Department
$Report += "                   Enabled:   " + "" + $Term.Enabled 
$Report += "               WhenChanged:   " + "" + $Term.WhenChanged
$Report += "           PasswordLastSet:   " + "" + $Term.PasswordLastSet
$Report += ""

###Get Group Memberships
$Report += "Group Memberships"
$memberOf = (Get-ADUser $terminatedUser -Properties memberOf).memberOf | Sort-Object 
foreach ($group in $memberOf) {$Report += "" + (Get-ADGroup $group).Name }

$TermExport = $terminatedUser + "_" + $a.Month + "_" + $a.Day + "_" + $a.Year + ".txt" 
$Report | Set-Content c:\temp\$TermExport
echo "Done with Report"

### Remove user from all groups (except Domain Users, that one is mandetory)
Get-ADUser -Identity $terminatedUser -Properties MemberOf | ForEach-Object {
    $_.MemberOf | Remove-ADGroupMember -Member $_.DistinguishedName -Confirm:$false
}

### EOF