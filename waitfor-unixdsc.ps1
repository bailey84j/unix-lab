$node = "10.0.0.11"
$n=0
do{


$Pingtest = $null
do{
$Pingtest = Test-Connection -ComputerName $node -Count 2
$N + 5 
if(-not($Pingtest)){Start-sleep 5}
"Ping"
$n
}until($Pingtest -or $n -eq 120)
#Ignore SSL certificate validation
$opt = New-CimSessionOption -UseSsl:$true -SkipCACheck:$true -SkipCNCheck:$true -SkipRevocationCheck:$true

#Options for a trusted SSL certificate$opt = New-CimSessionOption -UseSsl:$true 
$Sess=New-CimSession -Credential:$credential -ComputerName:$Node -Port:5986 -Authentication:basic -SessionOption:$opt -OperationTimeoutSec:90
if(-not($Sess)){
$n + 5
Start-sleep 5
"CIM"
$n
}
Else
{
$DSCReadyCheck = Get-CimInstance -CimSession $Sess -namespace root/omi -ClassName omi_identify
}
}until($DSCReadyCheck.SystemName = "$($Node).localdomain" -or $n -eq 240)

Start-DscConfiguration -Path:"C:\temp" -CimSession:$Sess -Wait -Verbose

