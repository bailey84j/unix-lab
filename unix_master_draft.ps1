[CmdletBinding()]

Param(
    [System.String]$ImageFilePath = "v:\working space\rhel-guest-image-7.3-35.x86_64.qcow2",
    [System.String]$ParentVHDFolderPath = "H:\MasterVirtualHardDisks",
    [System.String]$vmPath = "V:\Working Space\VM",
    [System.String]$virtualSwitchName = "Surface.local",
    [System.String]$SSHKey = "AAAAB3NzaC1yc2EAAAABJQAAAQEAzMTuRoAf5kpHR43hbJwdjuLb9BOIguBRACyMe8BU5gcADkq4X6GICkvHkaQDZo0/jYg1AJwW8MfaBnEu88Zzz9VmGjcR1zyLkiALQj0Ck05MbB8tRjsRhWu6aDLihNwpdM1j7lLbmSS986arVgCkQ/GU5Gt6UrR8PsKbfDsrbYvuWemH7C4t7TTGYbPGFvl696ZNVWBzg3kGUcKrh7q2xGMfzwKxBXrrc9AYgqxpg78PAyw+EjHDFwzyAbf4oMxp2iQaFvCS7M+9cNQJUR+DCVEOVYGqN08dUMU3QlGeF5fDIl5azRQPjaKZgfbLxLStdMHBhAfroIOJM0FRmdSaZw== ",
    [System.String]$GuestAdminPassword,
    [System.String]$RootPassword,
    [System.String]$PackageManager = "yum",
    [System.String]$KeyboardLayout = "UK",

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

Import-Module $(Join-path -Path $PSScriptRoot -ChildPath Modules\CloudInit.psm1)



# ADK Download - https://www.microsoft.com/en-us/download/confirmation.aspx?id=39982
# You only need to install the deployment tools
#$oscdimgPath = "C:\Program Files (x86)\Windows Kits\8.1\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg\oscdimg.exe"
$oscdimgPath = $(Join-path -Path $PSScriptRoot -ChildPath 'Executables\Oscdimg\oscdimg.exe')
# Download qemu-img from here: http://www.cloudbase.it/qemu-img-windows/
$qemuImgPath = $(Join-path -Path $PSScriptRoot -ChildPath 'Executables\qemu-img\qemu-img.exe')

$metadata = New-CloudInitMetadata -InstanceID $InstanceID -LocalHostName $LocalHostName -IPAddress $IPAddress `
-Network $Network -Netmask $Netmask -Broadcast $Broadcast -Gateway $Gateway `
-DNSNameServers $DNSNameServers -DNSSearch $DNSSearch

$userdata = New-CloudInitUserdata -SSHKey $SSHKey -GuestAdminPassword $GuestAdminPassword -RootPassword $RootPassword -PackageManager yum -KeyboardLayout uk 
#$SSHKey = 



# Check Paths
if (!(test-path $vmPath)) {mkdir $vmPath}
if (!(test-path $ParentVHDFolderPath)) {mkdir $ParentVHDFolderPath}

$ImageFileName = (get-item -Path $ImageFilePath).BaseName
$Parentvhdx = Join-Path -Path ($ParentVHDFolderPath) -ChildPath "$($ImageFileName).vhdx"
$DifferencingDisk = Join-Path -Path $vmPath -ChildPath "$($LocalHostName).vhdx"
$metaDataIso = Join-Path -Path $vmPath -ChildPath "$($LocalHostName)-metadata.iso"

# Helper function for no error file cleanup
Function cleanupFile ([string]$file) {if (test-path $file) {Remove-Item $file}}

# Delete the VM if it is around
If ((Get-VM | Where-Object {$_.name -eq $LocalHostName}).Count -gt 0)
      {stop-vm $LocalHostName -TurnOff -Confirm:$false -Passthru | Remove-VM -Force}

cleanupFile $DifferencingDisk
cleanupFile $metaDataIso



#region cloud init Config files
# Generate temp file path
$tempPath = [System.IO.Path]::GetTempPath() + [System.Guid]::NewGuid().ToString()
# Make temp location
mkdir -Path $tempPath
mkdir -Path "$($tempPath)\Bits"

# Output meta and user data to files
Set-Content "$($tempPath)\Bits\meta-data" ([byte[]][char[]] "$metadata") -Encoding Byte
Set-Content "$($tempPath)\Bits\user-data" ([byte[]][char[]] "$userdata") -Encoding Byte
#GET-DISKIMAGE $metaDataIso| GET-VOLUME
Dismount-DiskImage -ImagePath $metaDataIso
# Create meta data ISO image
& $oscdimgPath "$($tempPath)\Bits" $metaDataIso -j2 -lcidata

# Clean up temp directory
remove-item -Path $tempPath -Recurse -Force

#endregion cloud init Config files
if((Test-Path -Path $Parentvhdx) -eq $False){
# Convert cloud image to a Parent VHDX
& $qemuImgPath convert -f qcow2 "$($ImageFilePath)" -O vhdx -o subformat=dynamic $Parentvhdx
Resize-VHD -Path $Parentvhdx -SizeBytes 50GB
}
New-VHD -Path $DifferencingDisk -ParentPath $Parentvhdx -Differencing

# Create new virtual machine and start it
new-vm $LocalHostName -MemoryStartupBytes 1024mb -VHDPath $DifferencingDisk -Generation 1 `
               -SwitchName $virtualSwitchName -Path $vmPath | Out-Null
set-vm -Name $LocalHostName -ProcessorCount 2
Set-VMDvdDrive -VMName $LocalHostName -Path $metaDataIso 
Start-VM $LocalHostName

# Open up VMConnect
Invoke-Expression "vmconnect.exe localhost `"$LocalHostName`""

Mount-DiskImage -ImagePath $metaDataIso