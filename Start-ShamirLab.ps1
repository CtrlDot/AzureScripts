<#
.SYNOPSIS 
    Starts Base ShamirLab Servers

.DESCRIPTION
    Starts the DC and any other required servers in the ShamirLab instance.  Not intended to start every server!

.NOTES
    AUTHOR: Shamir Charania
#>

workflow Start-ShamirLab
{   

    function GetPowerStateFor ($serviceName, $vmName){
        $vm = Get-AzureVM   -ServiceName $serviceName `
                            -Name $vmName
        $vm.PowerState
    }

    $connectionName = 'ConnectionMSDN'
    $subscriptionName = 'Visual Studio Premium with MSDN'
    $serviceName = 'shamirlab'
    $vmList = ('SLAB-DNS-001')

    Connect-Azure   -azureConnectionName $connectionName `
                    -azureSubscriptionName $subscriptionName

    Select-AzureSubscription -SubscriptionName $subscriptionName
 
    foreach($vmName in $vmList){
        $vm = Get-AzureVM   -ServiceName $serviceName `
                            -Name $vmName
        
        if ($vm.PowerState -ne "Stopped"){
            Write-Output "'$vmName' already running!"
        }
        else{
            Write-Output "Starting '$vmName'"
            $vm | Start-AzureVM
            $powerstate = GetPowerStateFor $serviceName $vmName
            $totalSleep = 0
            while ($powerstate -ne "Started"){
                Start-Sleep -Seconds 10
                $totalSleep = $totalSleep + 10
                $powerstate = GetPowerStateFor $serviceName $vmName 
                if ($totalSleep -gt 300){
                    Write-Output "Sleep Exceeded for '$vmName'"
                    $powerstate = "Started"
                } 
            }
        }

    }

    Write-Output "Successfully started lab"
}