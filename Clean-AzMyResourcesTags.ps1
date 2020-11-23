# Connect to Azure with a browser sign-in token (not required if running within Azure Cloud Shell)
#Connect-AzAccount
#Wait-Debugger
#Provide the subscription Id where the VMs reside
#SubscriptionId = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

# Set current time and expiration time
$currentTime = get-Date -Format 'yyyy-MM-dd hh:mm'
$expirationTime = get-Date -Format 'yyyy-MM-dd 23:59'

# Get all the Azure resource groups
$resourceGroups = Get-AzResourceGroup

Write-Host "Subscription Cleanup: Iterating" $resourceGroups.count "resource groups"
foreach ($rg in $resourceGroups) {
	$tags = @{}
	Write-Host "Inspecting" $rg.ResourceGroupName
  # Creates tags if non-existent
	if ($null -ne $rg.Tags) {
		$tags = $rg.Tags
	}
	# Write to host the Project tag
	if ($tags.ContainsKey('Project')) {
		Write-Host $rg.ResourceGroupName ": Project Tag is " $tags["Project"]
	}
	# Set Project tag to unknown and set expiration date
	else {
		Write-Host $rg.ResourceGroupName ": Setting Project tag to unknown, setting expiration date"
		$tags.Add("Project","Unknown")
		$tags.Add("ExpirationDate",$expirationTime)
		Set-AzResourceGroup -Tag $tags -Name $rg.ResourceGroupName
	}
	# Check expired resource groups and remove them
	if (($null -ne $rg.Tags) -and ($rg.Tags.ContainsKey("ExpirationDate"))) {
		$myExpDate = $rg.Tags["ExpirationDate"]
		if ($myExpDate -lt $currentTime){
			Write-Host "!!! Time to delete Resource Group: " $rg.ResourceGroupName
			# WARNING: THIS WILL DELETE RESOURCE GROUPS
			# Remove-AzResourceGroup -Name $rg.ResourceGroupName -Force -AsJob
		}
	}

}
