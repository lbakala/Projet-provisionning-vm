#!/usr/bin/pwsh
$ErrorActionPreference = "Stop"
#
Function Create-VM {

Param(
[String] $disksize,
[String] $vmName,
[String] $keys,
[String] $capability,
[String] $ip
)

$Tname = $vmName.Split(".")
$Nname = $Tname[1]

[xml]$xmldata = get-content "/root/.vmware/route.xml"
$obj = $xmldata.data.image | Where-Object {$_.nom -eq $Tname[0]}
$guest_id = $obj | %{$_.guestid}
$vmTemplate = $obj | %{$_.template}

$size = $xmldata | Select-XML -XPath "//type[@name='$capability']"
$memory = $size.node.memory
$cpu = $size.node.cpu

[xml]$xmldata = get-content "/root/.vmware/co.xml"
$obj = $xmldata.data.server | Where-Object {$_.ip -eq $ip}
$username= $obj | %{$_.user}
$pass = $obj | %{$_.pwd}
$password = $pass | ConvertTo-SecureString -asPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential $username,$password
$connected=Connect-VIServer -Server $ip -credential $credential

$VMM = Get-VM $vmTemplate
New-VM -Name $Nname -Location [datastore1]$Tname[1] -GuestId $guest_id -MemoryGB $memory  -DiskGB 8 -DiskStorageFormat Thin -numCpu $cpu -CD | Out-Null
Get-HardDisk -VM $Nname | Remove-HardDisk -DeletePermanently -Confirm:$false
$hdd = Get-HardDisk -VM $vmTemplate
Copy-HardDisk -HardDisk $hdd -DestinationPath "[datastore1] $Nname" | Out-Null
Get-VM $Nname | New-HardDisk -DiskPath "[datastore1] $Nname`/$vmTemplate`.vmdk" | Out-Null
$adapter = Get-NetworkAdapter -VM $Nname
Remove-NetworkAdapter $adapter -Confirm:$false
Get-VM $Nname | New-NetworkAdapter -NetworkName 'VM Network' -WakeOnLan -StartConnected | Out-Null

if ($disksize.indexOf(".") -gt 0 )
{

    $disque = $disksize.Split(".")
    $d = [Int] $disque[0]
    Get-VM $Nname | Get-HardDisk | Set-HardDisk -CapacityGB $d -Confirm:$false 
    for ( $i=1;$i -lt  $disque.Length;$i++)
    {
     $d = [Int] $disque[$i]
     Get-VM $Nname | New-HardDisk -CapacityGB $d -Persistence persistent  -StorageFormat Thin  -Confirm:$false 
    }
 }
 else
 {
     Get-VM $Nname | Get-HardDisk | Set-HardDisk -CapacityGB $disksize -Confirm:$false 
 }

Start-VM $Nname | Out-Null
Start-Sleep -s 60
$vmp = Get-VM $Nname
while(!$vmp.Guest.IPAddress[0]) {
$vmp = Get-VM $Nname
}
$n=$keys + ':' + $vmp.Guest.IpAddress[0]
Write-Host $n
ADD-Content -Path /home/user/op/pzK5HdpIxXTnB2Ml -Value $n
Write-Host $vmp.Guest.IpAddress[0]
}
