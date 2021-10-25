Import-Module ActiveDirectory
$LegalHoldList = Get-Content C:\temp\LH.txt
foreach($user in $LegalHoldList) {try {#echo $user    get-aduser -Filter { Displayname -like $user } -Properties Description | ForEach-Object { 
    if ($_.userPrincipalName.Endswith("meritenergy.com")) {
    echo $_.userPrincipalName
        if ($_.Description -eq $null) {
            Set-ADUser $_ -Description "Legal Hold"
        } else { 
            if ($_.Description.Startswith("Legal Hold")){

            }  else {     
            Set-ADUser $_ -Description "Legal Hold - $($_.Description)" 
            }
        }}
      }
    } catch {echo $Error[0].Exception}

    }

