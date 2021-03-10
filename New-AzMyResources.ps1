# Dependencies
Install-Module -Name Az -Force -Verbose
Import-Module -Name Az

# Connect to Azure subscription
Connect-AzAccount

# Create ResourceGroup and VM
$ResourceGroup = 'dev-test'
$loc = 'westeurope'
$usr = "edoardo.sanna"
$passwd = ConvertTo-SecureString $(Read-Host "Password") -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential ($usr, $passwd);
New-AzResourceGroup -Name $ResourceGroup -Location $loc -Verbose
New-AzVM -ResourceGroupName $ResourceGroup -Location $loc -Name $ResourceGroup -Image Win2019Datacenter -Credential $Credential -Priority Spot -Verbose

# Save public IP address into variable $PublicIP
$PublicIP = (Get-AzPublicIpAddress | Select-Object {$_.ipAddress}).psobject.properties.value

# Open RDP
cmdkey /generic:$PublicIP /user:$usr /pass:$passwd
mstsc /v:$PublicIP /f

# Do stuff here
# ...

# Delete all
Remove-AzResourceGroup -Name 'dev-test' -Force
Remove-AzResourceGroup -Name 'NetworkWatcherRG' -Force
Remove-Module -Name Az