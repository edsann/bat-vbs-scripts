# Subscription Cleaner
#
# Author: Frank Boucher (https://dev.to/azure/keep-your-azure-subscription-clean-automatically-mmi)
# Modules required: Az.Accounts, Az.ResourceGraph, Az.Resources (in this order)
#
# To run it, create an Automation and a Runbook in your Azure subscription


# Run as Azure Account
$connectionName = "AzureRunAsConnection"
try
{
    # Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

    Connect-AzAccount `
        -ServicePrincipal `
        -Tenant $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
}
catch {
    if (!$servicePrincipalConnection)
    {
        $ErrorMessage = "... Connection $connectionName not found."
        throw $ErrorMessage
    } else{
        write-host -Message $_.Exception
        throw $_.Exception
    }
}

# Export expired resources' id from Azure Graph in JSON format
$expResources= Search-AzGraph -Query 'where todatetime(tags.expireOn) < now() | project id'

# Remove expired resources
foreach ($r in $expResources) {
    write-host "Deleting Resource with ID: $r.id"
    Remove-AzResource -ResourceId $r.id -Force -WhatIf #REMOVE THE WHATIF TO REALLY DELETE RESOURCES
}

# Get all Azure Resource Groups
$rgs = Get-AzResourceGroup;

# Remove empty Resource Groups
foreach($resourceGroup in $rgs){
    $name=  $resourceGroup.ResourceGroupName;
    $count = (Get-AzResource | Where-Object{ $_.ResourceGroupName -match $name }).Count;
    if($count -eq 0){
        write-host "... Deleting Resource Group: $name"
        Remove-AzResourceGroup -Name $name -Force
    }
}
