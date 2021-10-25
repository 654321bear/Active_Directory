Import-Module ActiveDirectory
get-aduser -ldapfilter "(&(objectCategory=person)(objectClass=user))" -properties * |select name,givenname, sn,enabled,created, description, office,ProxyAddress  | export-csv -path "c:\temp\Get-All_ADUsers_Results.csv"
#Get-ADUser -Filter * -SearchBase 'dc=COMPANY,dc=com' -Properties proxyaddresses | select name, @{L='ProxyAddress_1'; E={$_.proxyaddresses[0]}}, @{L='ProxyAddress_2';E={$_.ProxyAddresses[1]}}, @{L='ProxyAddress_3';E={$_.ProxyAddresses[2]}}, @{L='ProxyAddress_4'; E={$_.proxyaddresses[3]}}, @{L='ProxyAddress_5';E={$_.ProxyAddresses[4]}}, @{L='ProxyAddress_6';E={$_.ProxyAddresses[5]}}, @{L='ProxyAddress_7'; E={$_.proxyaddresses[6]}}, @{L='ProxyAddress_8';E={$_.ProxyAddresses[7]}}, @{L='ProxyAddress_9';E={$_.ProxyAddresses[8]}} | Export-Csv -Path c:\temp\proxyaddresses.csv -NoTypeInformation



#get-aduser USERNAME -properties * | select-object name, samaccountname, surname, enabled, @{"name"="proxyaddresses";"expression"={$_.proxyaddresses}}