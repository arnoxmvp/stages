<#
    ADScript v1.6
   This script will retrieve some security data about the Windows AD domain of specified domain.
   Data retrieved contains :
            .Quantity of disabled, enabled, expired, unused, never used and locked users.
            .Quantity of users which passwords are allowed to never change.
            .Quantity of domain admins, admins and disabled admins.
            .Quantity of computers.
   Data is sent over MQTT to a server.
   Script writeen by Arnaud Collart the 15/04/2021.
   Documentation can be found on : https://www.temporaryURL.com/doc/mydoc 
#>



#Establishing variables
param($broker, $server, $cafile, $certfile, $keyfile) 
$6months = 180
$12months = 365
$topics = @{
    Disabled = "Security/ADDomain/$server/IAM/Disabled"
    Enabled = "Security/ADDomain/$server/IAM/Enabled"
    UnusedAccounts = "Security/ADDomain/$server/IAM/UnusedAccount6Months"
    NeverUsed = "Security/ADDomain/$server/IAM/NeverUsed"
    PwdUnchanged = "Security/ADDomain/$server/IAM/PasswordUnchanged1Year"
    PwdLocked = "Security/ADDomain/$server/IAM/Locked"
    Expired = "Security/ADDomain/$server/IAM/Expired"
    PwdNeverChange = "Security/ADDomain/$server/IAM/PwdNeverChange"
    DomainAdmins = "Security/ADDomain/$server/IAM/DomainAdmins"
    Admins = "Security/ADDomain/$server/IAM/Admins"
    DisabledProtected = "Security/ADDomain/$server/IAM/DisabledProtected"
    Computers = "Security/ADDomain/$server/IAM/Computers"
    Gpos = "Security/ADDomain/$server/IAM/UnlinkedGpos"
}
$since6months = [DateTime]::Today.AddDays($6months)
$since12months = [DateTime]::Today.AddDays($12months)

#Users
$nbDisabled = (Get-ADUser -filter{enabled -eq $false} -Server $server).count
$nbEnabled = (Get-ADUser -filter{enabled -eq $true} -Server $server).count
$nb6monthsNotUsed = (Get-ADUser -filter {(enabled -eq $True) -and (LastLogonTimestamp -lt $since6months)} -Server $server).count
$nbNeverUsed = (Get-ADUser -filter {-not (LastLogonTimestamp -like "*" -and (enabled -eq $true))} -Server $server).count
$nbYearUnchangedPwd = (Get-ADUser -Filter {(PasswordLastSet -LT $since12months) -and (enabled -eq $True)} -Properties PasswordLastSet).count

#Accounts
$nbLocked = (Search-ADAccount -LockedOut -Server $server).count
$nbExpired = (Search-ADAccount -AccountExpired -Server $server).count
$nbPassNeverChange = (Search-ADAccount -PasswordNeverExpires -Server $server).count 

#Admins
$nbDomainAdmins = (Get-ADGroupMember -Server $server 'Admins du domaine').count
$nbAdmins = (Get-ADGroupMember -Server $server 'Administrateurs').count
$nbDisabledProtected = (Get-ADUser -filter {(AdminCount -eq 1) -and (enabled -eq $false)} -Server $server -Properties *).count

#Computers
$nbComputers = (Get-ADComputer -filter * -Server $server).count

#Count for unlinked GPOs
[xml]$GPOXmlReport = Get-GPOReport -Server $server -All -ReportType Xml
$nbUnlinkedGPO = ($GPOXmlReport.GPOS.GPO | Where-Object {$_.LinksTo -eq $null}).count 


.\Mosquitto\mosquitto_pub.exe -p 8883 --cafile $cafile --cert $certfile --key $keyfile -t $topics.Enabled -m $nbEnabled -h $broker
.\Mosquitto\mosquitto_pub.exe -p 8883 --cafile $cafile --cert $certfile --key $keyfile -t $topics.Disabled -m $nbDisabled -h $broker
.\Mosquitto\mosquitto_pub.exe -p 8883 --cafile $cafile --cert $certfile --key $keyfile -t $topics.PwdLocked -m $nbLocked -h $broker
.\Mosquitto\mosquitto_pub.exe -p 8883 --cafile $cafile --cert $certfile --key $keyfile -t $topics.UnusedAccounts -m $nb6monthsNotUsed -h $broker
.\Mosquitto\mosquitto_pub.exe -p 8883 --cafile $cafile --cert $certfile --key $keyfile -t $topics.NeverUsed -m $nbNeverUsed -h $broker
.\Mosquitto\mosquitto_pub.exe -p 8883 --cafile $cafile --cert $certfile --key $keyfile -t $topics.Expired -m $nbExpired -h $broker
.\Mosquitto\mosquitto_pub.exe -p 8883 --cafile $cafile --cert $certfile --key $keyfile -t $topics.PwdUnchanged -m $nbYearUnchangedPwd -h $broker
.\Mosquitto\mosquitto_pub.exe -p 8883 --cafile $cafile --cert $certfile --key $keyfile -t $topics.PwdNeverChange -m $nbPassNeverChange -h $broker

.\Mosquitto\mosquitto_pub.exe -p 8883 --cafile $cafile --cert $certfile --key $keyfile -t $topics.DomainAdmins -m $nbDomainAdmins -h $broker
.\Mosquitto\mosquitto_pub.exe -p 8883 --cafile $cafile --cert $certfile --key $keyfile -t $topics.Admins -m $nbAdmins -h $broker
.\Mosquitto\mosquitto_pub.exe -p 8883 --cafile $cafile --cert $certfile --key $keyfile -t $topics.DisabledProtected -m $nbDisabledProtected -h $broker
.\Mosquitto\mosquitto_pub.exe -p 8883 --cafile $cafile --cert $certfile --key $keyfile -t $topics.Computers -m $nbComputers -h $broker
.\Mosquitto\mosquitto_pub.exe -p 8883 --cafile $cafile --cert $certfile --key $keyfile -t $topics.Gpos -m $nbUnlinkedGPO -h $broker
