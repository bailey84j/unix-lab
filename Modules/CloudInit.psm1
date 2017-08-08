function New-CloudInitUserdata
{
Param(
    [System.String]$SSHKey,
    [System.String]$GuestAdminPassword,
    [System.String]$RootPassword,
    [System.String]$PackageManager = "yum",
    [System.String]$KeyboardLayout = "UK"
)


$userdata = @"
#cloud-config
ssh_authorized_keys:
  - ssh-rsa $($SSHKey)
password: $($GuestAdminPassword)

runcmd:
 - [ifdown, eth0]
 - [ifup, eth0]
 - [$($PackageManager), update, -y]
 - [$($PackageManager), install, -y, wget]
 - [mkdir, /tmp/dsc]
 - wget -O /tmp/dsc/omi.rpm https://github.com/Microsoft/omi/releases/download/v1.1.0-0/omi-1.1.0.ssl_100.x64.rpm
 - wget -O /tmp/dsc/dsc.rpm https://github.com/Microsoft/PowerShell-DSC-for-Linux/releases/download/v1.1.1-294/dsc-1.1.1-294.ssl_100.x64.rpm
 - rpm -Uvh /tmp/dsc/omi.rpm /tmp/dsc/dsc.rpm
 - loadkeys uk
 - passwd -u root -f
 - echo "$($RootPassword)" | passwd --stdin root
"@

return $userdata

}

function New-CloudInitMetadata
{
Param(
    [System.String]$InstanceID,
    [System.String]$LocalHostName,
    [System.String]$IPAddress,
    [System.String]$Network,
    [System.String]$Netmask,
    [System.String]$Broadcast,
    [System.String]$Gateway,
    [System.String]$DNSNameServers,
    [System.String]$DNSSearch
)

$metadata = @"
instance-id: $($InstanceID)
local-hostname: $($LocalHostName)
network-interfaces: |
  auto eth0
  iface eth0 inet static
  address $($IPAddress)
  network $($Network)
  netmask $($Netmask)
  broadcast $($Broadcast)
  gateway $($Gateway)
  dns-nameservers $($DNSNameServers)
  dns-search $($DNSSearch)
"@

return $metadata
}
