    <# 
    .Author 
    Abdul Wajid 
    .SYNOPSIS 
    Queries a remote computer to get Current Date & Time including Time Zone information. 
    .DESCRIPTION 
    Queries a remote computer to get Current Date & Time including Time Zone information. Queries thorugh WMI so the WMI ports through the firewall should be open. 
    .PARAMTERER ComputerName 
    The Host Name or IP Address of the Computer 
    .EXAMPLE 
    .\Get-RemoteDate -Computername WHATEVER 
    This will query a remote computer named WHATEVER and fetch the required information 
    .EXAMPLE 
    .\Get-RemoteDate -ComputerName WHATEVER | Format-Table * 
    This will display the information in a tabular format. 
    #> 
  
    [CmdletBinding()] 
    param( 
        [Parameter(Mandatory=$True, 
                   ValueFromPipeLine=$True, 
                   ValueFromPipeLineByPropertyName=$True,  
                   HelpMessage="ComputerName or IP Address to query via WMI")] 
        [string[]]$ComputerName 
    )  
    
    foreach($computer in $ComputerName) 
        { 

        $timeZone=Get-WmiObject -Class win32_timezone -ComputerName $computer 
        $localTime = Get-WmiObject -Class win32_localtime -ComputerName $computer 
        $output =@{'ComputerName' = $localTime.__SERVER; 
                    'Time Zone' = $timeZone.Caption; 
                    'Current Time' = (Get-Date -Day $localTime.Day -Month $localTime.Month); 
                   } 
        $object = New-Object -TypeName PSObject -Property $output 
        Write-Output $object 
 
        }