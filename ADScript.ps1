<#
    ADScript v1.4
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



#Establishing today -X months
$hostip = 'broker_address'
$6months = 180
$12months = 365
$domainName = "fqdnname"
$topics = @{
    Disabled = "/Security/ADDomain/$domainName/IAM/Disabled"
    Enabled = "/Security/ADDomain/$domainName/IAM/Enabled"
    UnusedAccounts = "/Security/ADDomain/$domainName/IAM/UnusedAccount6Months"
    NeverUsed = "/Security/ADDomain/$domainName/IAM/NeverUsed"
    PwdUnchanged = "/Security/ADDomain/$domainName/IAM/PasswordUnchange1Year"
    PwdLocked = "/Security/ADDomain/$domainName/IAM/Locked"
    Expired = "/Security/ADDomain/$domainName/IAM/Expired"
    PwdNeverChange = "/Security/ADDomain/$domainName/IAM/PwdNeverChange"
    DomainAdmins = "/Security/ADDomain/$domainName/IAM/DomainAdmins"
    Admins = "/Security/ADDomain/$domainName/IAM/Admins"
    DisabledProtected = "/Security/ADDomain/$domainName/IAM/DisabledProtected"
    Computers = "/Security/ADDomain/$domainName/IAM/Computers"
    Gpos = "/Security/ADDomain/$domainName/IAM/UnlinkedGpos"
}
$server = "domain"
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


#Sending the data over MQTT with Mosquitto
.\Mosquitto\mosquitto_pub.exe -t $topics.Enabled -m $nbEnabled -h $hostip
.\Mosquitto\mosquitto_pub.exe -t $topics.Disabled -m $nbDisabled -h $hostip
.\Mosquitto\mosquitto_pub.exe -t $topics.PwdLocked -m $nbLocked -h $hostip
.\Mosquitto\mosquitto_pub.exe -t $topics.UnusedAccounts -m $nb6monthsNotUsed -h $hostip
.\Mosquitto\mosquitto_pub.exe -t $topics.NeverUsed -m $nbNeverUsed -h $hostip
.\Mosquitto\mosquitto_pub.exe -t $topics.Expired -m $nbExpired -h $hostip
.\Mosquitto\mosquitto_pub.exe -t $topics.PwdUnchanged -m $nbYearUnchangedPwd -h $hostip


.\Mosquitto\mosquitto_pub.exe -t $topics.DomainAdmins -m $nbDomainAdmins -h $hostip
.\Mosquitto\mosquitto_pub.exe -t $topics.Admins -m $nbAdmins -h $hostip
.\Mosquitto\mosquitto_pub.exe -t $topics.DisabledProtected -m $nbDisabledProtected -h $hostip

.\Mosquitto\mosquitto_pub.exe -t $topics.Computers -m $nbComputers -h $hostip

.\Mosquitto\mosquitto_pub.exe -t $topics.Gpos -m $nbUnlinkedGPO -h $hostip
