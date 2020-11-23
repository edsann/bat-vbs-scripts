# Connect to Azure subscription
Connect-AzAccount

# Create ResourceGroup and VM
$rg = 'dev-test'
$loc = 'westeurope'
$usr = "edoardo.sanna"
$passwd = ConvertTo-SecureString "" -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential ($usr, $passwd);
New-AzResourceGroup -Name $rg -Location $loc
New-AzVM -ResourceGroupName $rg -Location $loc -Name $rg -Image Win2019Datacenter -Credential $Credential -Priority Spot
# Save public IP address into variable $PublicIP
$PublicIP = (Get-AzPublicIpAddress | Select-Object {$_.ipAddress}).psobject.properties.value
# Open RDP
cmdkey /generic:$PublicIP /user:$usr /pass:$passwd
mstsc /v:$PublicIP /f

# Do stuff here

# Delete all
Remove-AzResourceGroup -Name 'dev-test' -Force
Remove-AzResourceGroup -Name 'NetworkWatcherRG' -Force
