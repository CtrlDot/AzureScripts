<#
.SYNOPSIS 
    Sets up the connection to an Azure subscription

.DESCRIPTION
    Connect to an azure subscription via an automation connection and certificate.

.PARAMETER azureConnectionName
    The azure automation connection asset to use.

.PARAMETER azureSubscriptionName
    The azure subscription name to connect to, if different from the
    azure connection name

.EXAMPLE
    Connect-Azure -AzureConnectionName "Visual Studio Ultimate with MSDN"

.NOTES
    AUTHOR: Shamir Charania
#>

workflow Connect-Azure
{    
    Param
    (
        [Parameter(Mandatory=$true)]
        [String]
        $AzureConnectionName,
        
        [String]
        $AzureSubscriptionName
    )
    
    if ($AzureSubscriptionName -eq $null){
        $AzureSubscriptionName = $AzureConnectionName
    }

    $connection = Get-AutomationConnection -Name $AzureConnectionName
    if ($connection -eq $null)
    {
        throw "Could not retrieve '$AzureConnectionName' connection asset. Check that you created this first in the Automation service."
    }

    $certificate = Get-AutomationCertificate -Name $connection.AutomationCertificateName
    if ($certificate -eq $null)
    {
        throw "Could not retrieve '$connection.AutomationCertificateName' certificate asset. Check that you created this first in the Automation service."
    }

    # Set the Azure subscription configuration
    Set-AzureSubscription   -SubscriptionName $AzureSubscriptionName `
                            -SubscriptionId $connection.SubscriptionID `
                            -Certificate $certificate
}