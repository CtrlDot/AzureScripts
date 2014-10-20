param(
    [Parameter(Mandatory,ValueFromPipeline)][PSCredential]$Credential
)

$workingDir = Split-Path $MyInvocation.MyCommand.Path

$present = "Present"
$absent = "Absent"

Configuration CreateShamLab
{
    Import-DscResource -Module xAzure

    Node $AllNodes.NodeName
    {
        xAzureSubscription MSDN
        {
            Ensure = $present
            AzureSubscriptionName = $ConfigurationData.NonNodeData.AzureSubscriptionName
            AzurePublishSettingsFile = $ConfigurationData.NonNodeData.AzurePublishSettingsFile
        }

        xAzureAffinityGroup AGShamLab
        {
            Ensure = $present
            Name = $ConfigurationData.NonNodeData.AffinityGroupName
            Label = $ConfigurationData.NonNodeData.AffinityGroupName
            Description = $ConfigurationData.NonNodeData.AffinityGroupName
            Location = $ConfigurationData.NonNodeData.AffinityGroupLocation
            DependsOn = '[xAzureSubscription]MSDN'
        }

        xAzureStorageAccount StorageShamLab
        {
            Ensure = $present
            StorageAccountName = $ConfigurationData.NonNodeData.StorageAccountName
            AffinityGroup = $ConfigurationData.NonNodeData.AffinityGroupName
            Container = $ConfigurationData.NonNodeData.ContainerName
            Folder = Join-Path $workingDir $ConfigurationData.NonNodeData.ScriptsDirectory
            Label = $ConfigurationData.NonNodeData.StorageAccountName
            DependsOn = '[xAzureAffinityGroup]AGShamLab'
        }

        xAzureService ShamLabService
        {
            Ensure = $present
            ServiceName = $ConfigurationData.NonNodeData.ServiceName
            AffinityGroup = $ConfigurationData.NonNodeData.AffinityGroupName
            Label = $ConfigurationData.NonNodeData.ServiceName
            Description = $ConfigurationData.NonNodeData.ServiceName
            DependsOn = '[xAzureStorageAccount]StorageShamLab'
        }

        xAzureVM ShamDC1
        {
            Ensure = $present
            Name = "ShamDC1"
            ImageName = $ConfigurationData.NonNodeData.ImageName
            ServiceName = $ConfigurationData.NonNodeData.ServiceName
            StorageAccountName = $ConfigurationData.NonNodeData.StorageAccountName
            Windows = $True
            Credential = $Credential
            InstanceSize = "Small"
            DependsOn = '[xAzureService]ShamLabService'
        }

        xAzureVM ShamDC2
        {
            Ensure = $present
            Name = "ShamDC2"
            ImageName = $ConfigurationData.NonNodeData.ImageName
            ServiceName = $ConfigurationData.NonNodeData.ServiceName
            StorageAccountName = $ConfigurationData.NonNodeData.StorageAccountName
            Windows = $True
            Credential = $Credential
            InstanceSize = "Small"
            DependsOn = '[xAzureService]ShamLabService'
        }
    }
}

$ConfigData = @{
    AllNodes = @(
        @{
            NodeName = 'localhost'
            PSDscAllowPlainTextPassword=$true
        }
    );

    NonNodeData = @{
        AzureSubscriptionName = "Visual Studio Premium with MSDN"
        AzurePublishSettingsFile = "C:\users\schar_000\OneDrive\Documents\azure\DSCTesting\Pay-As-You-Go-Visual Studio Premium with MSDN-10-20-2014-credentials.publishsettings"
        AffinityGroupName = "AG-ShamLab"
        AffinityGroupLocation = "West US"
        StorageAccountName = "sshamlab"
        ContainerName = "scripts"
        ScriptsDirectory = "deployscripts"
        ServiceName = "Service-ShamLab"
        ImageName = "a699494373c04fc0bc8f2bb1389d6106__Windows-Server-2012-R2-201409.01-en.us-127GB.vhd"
    }

}

CreateShamLab -OutputPath $workingDir -ConfigurationData $ConfigData
Start-DscConfiguration -ComputerName 'localhost' -wait -force -verbose -path $workingDir