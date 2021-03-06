$capacity = Get-WmiObject -Class Win32_logicaldisk -Filter "DriveType = '3'" | Select-Object -Property DeviceID, DriveType, VolumeName, @{L='FreeSpaceGB';E={"{0:N2}" -f ($_.FreeSpace /1GB)}}, @{L="Capacity";E={"{0:N2}" -f ($_.Size/1GB)}}

#Generate email and add attachments

	$SmtpClient = New-Object system.net.mail.smtpClient
	$SmtpClient.host = "alerts.meritenergy.com"   #Change to a SMTP server in your environment
	$MailMessage = New-Object system.net.mail.mailmessage
	$MailMessage.from = "CerberusFTP@mertienergy.com"   #Change to email address you want emails to be coming from
	$MailMessage.To.add("john.thompson@meritenergy.comm")	#Change to email address you would like to receive emails.
	$MailMessage.Subject = "Cerberus Free Space"
	$MailMessage.Body = "Cerberus Free Space"
    $MailMessage.Body += $capacity
	$SmtpClient.Send($MailMessage)

echo "Done with Email"


# This section removes the reports after script completion
# If additional reports are added to this script, the Attachments field of this section must be updated
$SmtpClient.dispose()
$MailMessage.Dispose()

