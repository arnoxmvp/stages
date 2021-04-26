<#
    testPassword v1
   This script will test user passwords of a specified Windows AD domain.
   Passwords are tested via a custom dictionary containing "Weak" passwords and correlated directly with the password registered in the domain DB.
   Result is the number of user having a weak password.
   Data is sent over MQTT to a server.
   Script writeen by Arnaud Collart the 15/04/2021.
   Documentation can be found on : https://www.temporaryURL.com/doc/mydoc 
#>

$serverName = "DC_DNSName"
$namingContext = ""
$dictionnary = Get-Content "passwords-dict-2021.txt"


$nbWeakPasswords = (Get-ADReplAccount -All -Server $serverName -NamingContext $namingContext | Test-PasswordQuality -WeakPasswordsFile $dictionnary -IncludeDisabledAccounts).count
$nbWeakRemotePasswords = (Get-ADReplAccount -
