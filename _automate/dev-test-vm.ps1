# Connect to Azure subscription
Connect-AzAccount

# Create ResourceGroup and VM
$rg = 'dev-test'
$loc = 'westeurope'
New-AzResourceGroup -Name $rg -Location $loc
New-AzVM -ResourceGroupName $rg -Location $loc -Name $rg -Image Win2019Datacenter -Priority Spot

# Public IP address
Get-AzPublicIpAddress | Select {$_.ipAddress}

# Delete all
Remove-AzResourceGroup -ResourceGroupName $rg
Remove-AzResourceGroup -ResourceGroupName 'NetworkWatcherRG'
