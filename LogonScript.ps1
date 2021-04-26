<#
    LongonScript v1.2
   This script will retrieve the user data which logs to an Active Directory domain for logging purposes.
   Data retrieved contains Date(yyyyMMdd HH:ss), Domain used, Username, Computer name, IP Address and is wroten each time an user connect. 
   Data is stored on a shared drive.
   Script writeen by Arnaud Collart the 15/04/2021.
   Documentation can be found on : https://www.temporaryURL.com/doc/mydoc 
#>

#Variables definition

$filePath = ""
$date = Get-Date -Format yyyyMM
$Header = "LogonDate;DomainName;PCName;LoginName;IPAddress"
$logonDate = Get-Date -Format yyyy/MM/dd-HH:mm:ss
$domainName = $env:USERDOMAIN
$computerName = $env:COMPUTERNAME
$userName = $env:USERNAME
$ipAdress = (
    Get-NetIPConfiguration |
    Where-Object {
        $_.IPv4DefaultGateway -ne $null -and
        $_.NetAdapter.Status -ne "Disconnected"
    }
).IPv4Address.IPAddress
$OutInfo = $logonDate + ";" + $domainName + ";" + $computerName + ";" + $userName + ";" + $ipAdress

#Checks if CSV has already been created for the day/is accessible. If already exists, appends existing file.

if (Test-path $filePath) {
    Add-Content -Value $OutInfo -Path $filePath
}
else {
    $OutFile = $filePath
    Add-Content -Value $Header -Path $OutFile
    Add-Content -Value $OutInfo -Path $OutFile 
} 
