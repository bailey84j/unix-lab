$tempPath = [System.IO.Path]::GetTempPath() + [System.Guid]::NewGuid().ToString()
$oscdimgPath = 'v'
'C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg\oscdimg.exe'
# Download qemu-img from here: http://www.cloudbase.it/qemu-img-windows/
$qemuImgPath = "V:\Working Space\qemu-img.exe"

$GuestOSID = "iid-000001"
$GuestAdminPassword = "P@ssw0rd"
$n = 3
$VMName = "RHEL_00$($n)"
$IP = "10.0.0.2$($n)"
$GuestOSName = $VMName
$virtualSwitchName = "Surface.local"

$vmPath = "V:\Working Space\VM"
$imageCachePath = "V:\Working Space"
$ImageFileName = "rhel-guest-image-7.3-35.x86_64.qcow2"
$vhdx = "$($vmPath)\$($VMNAme).vhdx"
$metaDataIso = "$($vmPath)\$($VMName)-metadata.iso"

$SSHKey = "AAAAB3NzaC1yc2EAAAABJQAAAQEAzMTuRoAf5kpHR43hbJwdjuLb9BOIguBRACyMe8BU5gcADkq4X6GICkvHkaQDZo0/jYg1AJwW8MfaBnEu88Zzz9VmGjcR1zyLkiALQj0Ck05MbB8tRjsRhWu6aDLihNwpdM1j7lLbmSS986arVgCkQ/GU5Gt6UrR8PsKbfDsrbYvuWemH7C4t7TTGYbPGFvl696ZNVWBzg3kGUcKrh7q2xGMfzwKxBXrrc9AYgqxpg78PAyw+EjHDFwzyAbf4oMxp2iQaFvCS7M+9cNQJUR+DCVEOVYGqN08dUMU3QlGeF5fDIl5azRQPjaKZgfbLxLStdMHBhAfroIOJM0FRmdSaZw== "


$metadata = @"
instance-id: $($GuestOSID)
local-hostname: $($GuestOSName)
network-interfaces: |
  auto eth0
  iface eth0 inet static
  address $($IP)
  network 10.0.0.0
  netmask 255.255.255.0
  broadcast 10.0.0.255
  gateway 10.0.0.1
  dns-nameservers 10.0.0.1
  dns-search SURFACE.LOCAL
"@

$userdata = @"
#cloud-config
ssh_pwauth: True
ssh_authorized_keys:
  - ssh-rsa $($SSHKEY)
password: $($GuestAdminPassword)
runcmd:
 - [ useradd, -m, -p, "", ben ]
 - [ chage, -d, 0, ben ]
 - [ifdown, eth0]
 - [ifup, eth0]
 - [yum, update, -y]
 - [yum, install, -y, wget]
 - [mkdir, /tmp/dsc]
 - wget -O /tmp/dsc/omi.rpm https://github.com/Microsoft/omi/releases/download/v1.1.0-0/omi-1.1.0.ssl_100.x64.rpm
 - wget -O /tmp/dsc/dsc.rpm https://github.com/Microsoft/PowerShell-DSC-for-Linux/releases/download/v1.1.1-294/dsc-1.1.1-294.ssl_100.x64.rpm
 - rpm -Uvh /tmp/dsc/omi.rpm /tmp/dsc/dsc.rpm
 - loadkeys uk
 - passwd -u root -f
 - echo "NePatriot5" | passwd --stdin root
"@

# Check Paths
if (!(test-path $vmPath)) {mkdir $vmPath}
if (!(test-path $imageCachePath)) {mkdir $imageCachePath}

# Helper function for no error file cleanup
Function cleanupFile ([string]$file) {if (test-path $file) {Remove-Item $file}}

# Delete the VM if it is around
If ((Get-VM | ? name -eq $VMName).Count -gt 0)
      {stop-vm $VMName -TurnOff -Confirm:$false -Passthru | Remove-VM -Force}

cleanupFile $vhdx
cleanupFile $metaDataIso

# Make temp location
mkdir -Path $tempPath
mkdir -Path "$($tempPath)\Bits"


# Output meta and user data to files
Set-Content "$($tempPath)\Bits\meta-data" ([byte[]][char[]] "$metadata") -Encoding Byte
Set-Content "$($tempPath)\Bits\user-data" ([byte[]][char[]] "$userdata") -Encoding Byte

# Convert cloud image to VHDX
& $qemuImgPath convert -f qcow2 "$($imageCachePath)\$($ImageFileName)" -O vhdx -o subformat=dynamic $vhdx
Resize-VHD -Path $vhdx -SizeBytes 50GB
#GET-DISKIMAGE $metaDataIso| GET-VOLUME
Dismount-DiskImage -ImagePath $metaDataIso
# Create meta data ISO image
& $oscdimgPath "$($tempPath)\Bits" $metaDataIso -j2 -lcidata


# Clean up temp directory
remove-item -Path $tempPath -Recurse -Force

# Create new virtual machine and start it
new-vm $VMName -MemoryStartupBytes 1024mb -VHDPath $vhdx -Generation 1 `
               -SwitchName $virtualSwitchName -Path $vmPath | Out-Null
set-vm -Name $VMName -ProcessorCount 2
Set-VMDvdDrive -VMName $VMName -Path $metaDataIso 
Start-VM $VMName

# Open up VMConnect
Invoke-Expression "vmconnect.exe localhost `"$VMName`""

Mount-DiskImage -ImagePath $metaDataIso