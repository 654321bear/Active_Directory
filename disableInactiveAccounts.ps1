$date 		= Get-Date
$60DaysAgo 	= $date.AddDays(-60)						# Sets the criteria for a "stale" account
$userArray	= @()
$output		=	"" #"This report lists all AD user accounts that have been inactive for more than 60 days." + "`r`n"
#Set Date variable
$a = date

Import-Module ActiveDirectory
$input = Get-ADUser -Filter * -SearchScope Subtree -SearchBase 'DC=meritenergy,DC=com' -properties displayName, samAccountName, EmployeeID, lastLogonDate, Created, office  | `
Where-Object {$_.givenName -ne $null} | where {$_.EmployeeID -notlike "*SERVICE*"} | where {$_.displayname -notlike "*SA-*"} | where {$_.office -notlike "*ACCOUNT"} | where {$_.samAccountName -notlike "*svc_*"}

foreach ($user in $input) {
	IF ($user.enabled -eq $true) {						# If user is enabled
		if ($user.lastLogonDate -ne $null) {			# If user has ever logged in
			$lastLog = $user.lastLogonDate				# Last logon date variable
			if ($lastLog -lt $60DaysAgo) {				# Was the last login more than 60 days ago
				$userArray += $user.samAccountName		# If all conditions are met, the user is added to an array to be disabled
			}
		}
		$createDate = $user.created						# Date the user was created variable
		if ($createDate -lt $60DaysAgo) {				# Was the create date more than 60 days ago
			if ($user.lastLogonDate -eq $null) { 		# Catches enabled accounts created more than 60 days ago that never logged in
				$userArray += $user.samAccountName		# If all conditions are met, the user is added to an array to be disabled
			}
		}
		if ($user.displayName.length -gt $formatDisplay) {				# Formatting 
			$formatDisplay = $user.displayName.length
		}
		if ($user.samAccountName.length -gt $formatSamAccountName) {	# Formatting 
			$formatSamAccountName = $user.samAccountName.length
		}	
	}
} # End Foreach 

$userArray  			= $userArray | sort  
$count 					= $userArray.count
$formatDisplay			+= 3
$formatSamAccountName	+= 3
$output =  "Name" + ", " +  "samAccountName" + ", " +  "Employee ID" + ", " +  "Last Login Date" + ", " +  "Created Date" + ", " +  "Result" + "`r`n"

if ($count -gt 0) {
	foreach ($i in $userArray) {

		$account = Get-ADUser -Filter { samAccountName -eq $i } -Server meritenergy.com -Properties displayName, samAccountName, EmployeeID, lastLogonDate, Created, enabled
		if($account.LastLogonDate -eq $null){$userLogon = "Never"  | Out-Null }else{
			$userLogon = $account.lastLogonDate | Out-Null #Get-Date $account.lastLogonDate -f MM/dd/yyyy | Out-Null
		}
			$userCreated = $account.Created | Out-Null #Get-Date $account.Created -f MM/dd/yyyy | Out-Null
		
		#disable-ADAccount -Identity "$i"
		
		
		$enabled = Get-ADUser $i -Properties enabled
		if ($enabled.Enabled -eq $false) {
			$disabled = "Successfully Disabled"
		}
		else {$disabled = "Still Enabled"}

		$output +=  $account.displayName + ", " +  $account.samAccountName + ", " +  $account.EmployeeID + ", " +  $account.LastLogonDate + ", " +  $account.Created + ", " +  $disabled + "`r`n"
	
        } # End Foreach 
} # End If

$outLog  = "c:\temp\DisableInactiveAccounts_" + $a.Month + "_" + $a.Day + "_" + $a.Year + ".csv"
$outPath = "c:\temp\disableInactiveAccounts.txt"

New-Item $outLog -type file -force -Value $output | Out-Null


#Create attachments
$Masteratt = new-object Net.Mail.Attachment($outlog)

#Generate email and add attachments
	IF ($Report -ne ""){
	$SmtpClient = New-Object system.net.mail.smtpClient
	$SmtpClient.host = "alerts.meritenergy.com"   #Change to a SMTP server in your environment
	$MailMessage = New-Object system.net.mail.mailmessage
	$MailMessage.from = "AD.Automation@meritenergy.com"   #Change to email address you want emails to be coming from
	$MailMessage.To.add("john.thompson@meritenergy.com")	#Change to email address you would like to receive emails.
    #$MailMessage.To.add("john.thompson@meritenergy.com,jehad.alasad@meritenergy.com,earl.fischer@meritenergy.com")	#Change to email address you would like to receive emails.
	$MailMessage.IsBodyHtml = 1
	$MailMessage.Subject = "Report of Deleted Inactive Accounts"
	$MailMessage.Body = "Attached is a report of accounts that were disabled due to inactivity."
    $MailMessage.Attachments.Add($Masteratt)
	$SmtpClient.Send($MailMessage)}

#Delete files after email is sent
$Masteratt.Dispose()
Start-Sleep -s 10 
Remove-Item $outLog