# Import the AD module and query AD for all users and their email addresses
import-module activedirectory
Get-ADUser -filter * -properties passwordlastset, passwordneverexpires, mail | sort-object name | select-object Name, passwordlastset, passwordneverexpires, mail | Export-csv -path C:\temp\user-password-info-%date%.csv -noType


$userobjects = Get-ADUser -filter * -properties passwordlastset, passwordneverexpires, mail | `
sort-object name | select-object Name, passwordlastset, passwordneverexpires, mail | `
where-object {$_.passwordneverexpires -eq 0 }
$body = "Your password is set to expire in x days."
ForEach ( $userobject in $userobjects ) {
#Assign the content to variables
$Username = $userobject.name
$Email = $userobject.mail
$passwordlastset = $userobject.passwordlastset
$passwordneverexpires = $userobject.passwordneverexpires

$SD = Get-Date -format MM/dd/yyyy $ALONpasswordlastset
$SD2 = Get-Date $ALONpasswordlastset
$curDate = get-date -format MM/dd/yyyy 
$curDate2 = get-date
$daystillexpire2 = $SD2.AddDays(60) 
$daystillexpire = Get-Date -format MM/dd/yyyy $daystillexpire2
$nts = ($daystillexpire2 - $curDate2).days



Write-Host "***********************************************************************************************"
Write-Host $FileUsername
Write-Host $SD " Password last set date."
Write-Host $curDate " is todays date."
Write-Host $daystillexpire " is when the password will expire."
write-Host $nts "days from today till the password expires."
Write-Host "***********************************************************************************************"


# Output the content to the screen
if($FileEmail -match "@COMPANY.com") {
# Write-Host $FileUsername has a username of $FileUsername with email $FileEmail
$record = $Username + "has a username of " + $Username + " with email " + $FileEmail  + "`n "
}
$body = $body + $record + "`n"

}

#Generate email
	IF ($record -ne ""){
	$SmtpClient = New-Object system.net.mail.smtpClient
	$SmtpClient.host = "smtp.COMPANY.com"   #Change to a SMTP server in your environment
	$MailMessage = New-Object system.net.mail.mailmessage
	$MailMessage.from = "AD.Automation@COMPANY.com"   #Change to email address you want emails to be coming from
	$MailMessage.To.add("USER@COMPANY.com")	#Change to email address you would like to receive emails.
	$MailMessage.IsBodyHtml = 0
	$MailMessage.Subject = "Your current Password is about to expire for AlonUSA."
	$MailMessage.Body = " Your password is set to expire on " + $daystillexpire + ". `n Please change your password." + "`n " + $body 
	$SmtpClient.Send($MailMessage)}

echo "Done with Email"

#
#Dear Cori,
#
#Your network password for user account F03084 will be expire in 6 days. 
#Please change your password before 9/5/2011 8:29:38 AM
#The new password must meet the following requirements:
#•	Min. nr. of characters in a PWD = '7 characters';
#(The minimum number of characters to be used in a password)
#•	Min. PWD age = '0 days';
#(Minimum number of days the new password must be used before it can be changed again)
#•	Max. PWD age = '90 days';
#(Maximum number of days the new password can be used before it must be changed again)
#•	Nr. of previous PWDs in history = '24';
#(Number of new and unique passwords required before an old password can be reused again)
#•	Password complexity enabled? = 'YES!
#(The new password must meet complexity requirements ONLY when configured to 'YES!')
#Password complexity is enabled, the new password must meet the following requirements:
#•	Not contain the user's account name or parts of the user's full name that exceed 2 consecutive characters
#•	Be at least 7 characters in length
#•	Contain characters from 3 of the following 4 categories
#o	Uppercase characters (A through Z) {JDE users See note below}
#o	Lowercase characters (a through z)
#o	Numeric characters (0 through 9)
#o	Non-alphabetic characters (for example, !, $, #, %)
#o	If you use JDE, start your password with a lower case character and olny use lower character
#To change your password use either one of the following steps:
#•	Employees connected to the network: Press [CTRL]+[ALT]+[DEL] and select the 'Change Password' option.
#Remote employees please connect to VPN then: Press [CTRL]+[ALT]+[DEL] and select the 'Change Password' option
#(Use this method ONLY when interactively logged on to the 'alonusa.com' AD domain in the office)
#•	Contractors click on the following link:  https://webmail.alonusa.com/owa/?ae=Options&opturl=ChangePassword
#(Use this method when NOT interactively logged on to the 'alonusa.com' AD domain or when at home or when at a customer)
#Never giveout your personal password to anyone!
#Thanks!
#IT Department
#