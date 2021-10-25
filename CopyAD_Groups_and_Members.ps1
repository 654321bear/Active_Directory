$newGrpName = "System Admins"
$grpScope = "Global"
$description = "System admin group to temporarily remove people from Domain Admins"
$grpCat = "Security"
$path = "OU=Admins,DC=COMPANY,DC=com"
$existingGrpName = "Domain Admins"
New-ADGroup -name $newGrpName -GroupScope $grpScope -Description $description -GroupCategory `
$grpCat -Path $path -PassThru  | Add-ADGroupMember -Members (Get-ADGroupMember $existingGrpName) `
-PassThru | Get-ADGroupMember | Select Name