Param
(
    [Parameter(Mandatory=$true)]
    [Int]
    $NumberOfVMs
)
    
$serviceName = '-------'
$vmNamePrefix = 'AX2012R3-Demo-'
$imageName = "AX2013R3-Demo"
$storageLocation = '-----'
        
$vmlist = @(Get-AzureVm -ServiceName $serviceName | ? {$_.Name.StartsWith($vmNamePrefix)} )

if ($vmlist.count -eq $NumberOfVMs){
    Write-Output "The correct number of VMs have already been provisioned"
    return
}
    
if ($vmlist.count -gt $NumberOfVMs){
    $stoppedVms = @($vmlist | ? {$_.PowerState -eq "Stopped"})
    $numberToRemove = $vmlist.count - $NumberOfVMs
        
    Write-Output "Removing '$numberToRemove' VMs"
    Write-Output "Currently '$stoppedVMs.count' stopped VMs"
        
    if ($numberToRemove -gt $stoppedVMs.count){
        throw "Not enough stopped VMs to remove"
    }
        
    $vmsToStop = $stoppedVms[0..$numberToRemove]

    foreach($vm in $vmsToStop){
        Write-Output "Removing '$vm.Name'"
        Remove-AzureVm -ServiceName $serviceName -Name $vm.Name -DeleteVHD
    }

    $vmlist = @(Get-AzureVm -ServiceName $serviceName | ? {$_.Name.StartsWith($vmNamePrefix)} )
    Write-Output "Number of VMs remaining in $serviceName are '$vmlist.count'"
    return
}
    
if ($vmlist.count -lt $NumberOfVMs) {
    $dnsServer = New-AzureDns -Name "Localhost" -IPAddress "127.0.0.1"
    
    $numberToAdd = $NumberOfVMs - $vmlist.count
    "Adding '$numberToAdd' vms"
    
    while($numberToAdd -gt 0){
        $numberToAdd = $numberToAdd - 1
        $newName = $vmNamePrefix + [guid]::NewGuid()
        "Adding '$newName'"

        New-AzureVMConfig -Name $newName  -ImageName $imageName -InstanceSize A6 -MediaLocation $storageLocation `
            | Add-AzureProvisioningConfig -Windows `
            | New-AzureVM -ServiceName $serviceName -DnsSettings $dnsServer -DeploymentName $newName                
    }

    $vmlist = @(Get-AzureVm -ServiceName $serviceName | ? {$_.Name.StartsWith($vmNamePrefix)} )
    "Number of VMs remaining in $serviceName are '$vmlist.count'"
}
