Import-Module ActiveDirectory

# Set the number of days since last logon
$DaysInactive = 90
$InactiveDate = (Get-Date).Adddays(-($DaysInactive))

#Initialise Array
$Report1 = @()
$Users1Report = @()

###################################################################################################################################################################################################################
#-------------------------------------------------------------------------------------------
# FIND INACTIVE USERS that haven't logged on in xx days and are not Service Accounts
#-------------------------------------------------------------------------------------------
# Below are four options to find inactive users. Select the one that is most appropriate for your requirements:

# Get AD Users that haven't logged on in xx days and are not Service Accounts
$Users1 = Get-ADUser -Filter { LastLogonDate -lt $InactiveDate -and Enabled -eq $true -and SamAccountName -notlike "*svc*" -and SamAccountName -notlike "*ftp*" -and Description -notlike "*service*" -and Description -notlike "*ftp*"} -Properties LastLogonDate, Description, WhenCreated | %{ 
$Report1 = "" | Select-Object @{ Name="Username"; Expression={$_.SamAccountName}}, Name, LastLogonDate, WhenCreated, DistinguishedName, Description
$Report1.Username = $_.SamAccountName
$Report1.Name = $_.Name
$Report1.LastLogonDate = $_.LastLogonDate
$Report1.WhenCreated = $_.WhenCreated
$Report1.DistinguishedName = $_.DistinguishedName
$Report1.Description = $_.Description
$Users1Report += $Report1

}

#--------------------------------------------------------Users1 REPORT SECTION------------------------------------------------------------
#Global Functions
#This function generates a nice HTML output that uses CSS for style formatting.
function Generate-Report1 {
	Write-Output "<html><head><title></title><style type=""text/css"">.Error {color:#FF0000;font-weight: bold;}.Title {background: #0077D4;color: #FFFFFF;text-align:center;font-weight: bold;border-collapse: collapse;}.SubTitle {background: #DBDDEC;color: #000000;text-align:center;font-weight: bold;border-collapse: collapse;}.Normal {} .Table{border: 1px solid black;border-collapse: collapse;width: 100%;}</style></head><body>"
                
                #Add Computer DESCRIPTION Table
                Write-Output "<table border="1" class="table"><tr class=""Title""><td colspan=""6"">All Inactive Users In The Last 30 Days Excluding Service Accounts</td></tr><tr class=SubTitle><td>UserName</td><td>Name</td><td>Last Logon Date </td><td>When Created</td><td>Description</td><td>DistinguishedName</td></tr>"
                Foreach ($Report1 in $Users1Report){
					Write-Output "<tr><td>$($Report1.Username)</td><td>$($Report1.Name)</td><td>$($Report1.LastLogonDate)</td><td>$($Report1.WhenCreated)</td><td>$($Report1.Description)</td><td>$($Report1.DistinguishedName)</td></tr> " }
                Write-Output "</table>"                

        #End Report Table
		Write-Output "</table></body></html>" 
	}
echo "Done with Users1 Report"

$Master = Generate-Report1 

###################################################################################################################################################################################################################


#-------------------------------
# REPORTING
#-------------------------------
#Create locations for files
$users1_file = "C:\Temp\ADReports\InactiveUsers_NotLoggedOnRecentlyNOTSVC.csv"


# Export results to CSV
$Users1Report | Export-Csv $users1_file -NoTypeInformation

# Create Mail attachments
$Users1att = new-object Net.Mail.Attachment($Users1_file)


#Generate email and add attachments
	IF ($Report -ne ""){
	$SmtpClient = New-Object system.net.mail.smtpClient
	$SmtpClient.host = "alerts.COMPANY.com"   #Change to a SMTP server in your environment
	$MailMessage = New-Object system.net.mail.mailmessage
	$MailMessage.from = "AD.Automation@Company.com"   #Change to email address you want emails to be coming from
	$MailMessage.To.add("john.thompson@Company.com")	#Change to email address you would like to receive emails.
	$MailMessage.IsBodyHtml = 1
	$MailMessage.Subject = "Report of Inactive Users that are not Service Accounts"
	$MailMessage.Body = $Master
    $MailMessage.Attachments.Add($Users1att)
	$SmtpClient.Send($MailMessage)}

#Delete files after email is sent
$Users1att.Dispose()
Start-Sleep -s 10 
Remove-Item $Users1_file



#-------------------------------
# INACTIVE USER MANAGEMENT
#-------------------------------
# Below are two options to manage the inactive users that have been found. Either disable them, or delete them. Select the option that is most appropriate for your requirements:
# Uncomment to execute

# # Disable Inactive Users
# ForEach ($Item in $Users){
  # $DistName = $Item.DistinguishedName
  # Disable-ADAccount -Identity $DistName
  # Get-ADUser -Filter { DistinguishedName -eq $DistName } | Select-Object @{ Name="Username"; Expression={$_.SamAccountName} }, Name, Enabled
# }

# # Delete Inactive Users
# ForEach ($Item in $Users){
  # Remove-ADUser -Identity $Item.DistinguishedName -Confirm:$false
  # Write-Output "$($Item.Username) - Deleted"
# }