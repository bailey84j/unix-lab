.\unix_master_draft.ps1 -ImageFilePath 'V:\Working Space\CentOS-7-x86_64-GenericCloud-1703.qcow2' -ParentVHDFolderPath H:\MasterVirtualHardDisks `
-vmPath H:\VirtualMachines -virtualSwitchName Surface.local -GuestAdminPassword "NePatriot5" -RootPassword "NePatriot5" -PackageManager yum -KeyboardLayout uk `
-InstanceID 0001 -LocalHostName "CENTOS-0001" -IPAddress 10.0.0.11 -Network 10.0.0.0 -Netmask 255.255.255.0 -Broadcast 10.0.0.255 -Gateway 10.0.0.1 `
-DNSNameServers 8.8.8.8 -DNSSearch Surface.local