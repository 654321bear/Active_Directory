#SID to Username
$objSID = New-Object System.Security.Principal.SecurityIdentifier ("s-1-5-21-1708537768-764733703-1801674531-32462")
$objUser = $objSID.Translate( [System.Security.Principal.NTAccount])
$objUser.Value 

#Username to SID
$objUser = New-Object System.Security.Principal.NTAccount("<DomainNameHere>", "<GroupNameHere>")
$strSID = $objUser.Translate([System.Security.Principal.SecurityIdentifier])
$strSID.Value

#Local user account to SID
$objUser = New-Object System.Security.Principal.NTAccount("administrator")
$strSID = $objUser.Translate([System.Security.Principal.SecurityIdentifier])
$strSID.Value