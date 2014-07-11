<#
.SYNOPSIS 
    Stops all VMs in Shamirlab

.DESCRIPTION
    Stops all VMs in shamirlab

.NOTES
    AUTHOR: Shamir Charania
#>

workflow Stop-ShamirLab
{   
    $connectionName = 'ConnectionMSDN'
    $subscriptionName = 'Visual Studio Premium with MSDN'
    $serviceName = 'shamirlab'
    

    Connect-Azure   -azureConnectionName $connectionName `
                    -azureSubscriptionName $subscriptionName

    Select-AzureSubscription -SubscriptionName $subscriptionName
 

    $vmlist = (get-azurevm -ServiceName $serviceName | ? {$_.PowerState -ne "Stopped"})

    foreach($vm in $vmList){
        Write-Output "Stopping '$vm.Name'"
        $vm | Stop-AzureVM -Force
    }

    Write-Output "Successfully stopped lab"
}