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
