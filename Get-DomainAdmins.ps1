 Import-Module ActiveDirectory
 Get-ADGroupMember -identity "Domain Admins" | select name | Sort-Object -Property name