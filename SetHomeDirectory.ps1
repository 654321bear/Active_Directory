ForEach ($user in (Get-Aduser -Filter * -Properties Name, homeDirectory, samAccountName -Searchbase "DC=meritenergy, DC=com" | Where-object { $_. homeDirectory -match "\\SERVER1" })) {
    $dirPath = "\\SERVER2\Users$\" + $user.SamAccountName
    set-aduser $user -homedirectory $dirPath -homedrive U:
    echo $dirPath
}




#ForEach ($user in (Get-Aduser -Filter * -Properties Name, homeDirectory -Searchbase "DC=alonusa, DC=com" | Where-object { $_. homeDirectory -match "\\alns1219" } )) {