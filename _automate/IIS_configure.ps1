<#
.Synopsis
    Automate IIS application pool configuration
#>

# Creating and updating a log file with timestamps
$Logpath = "C:\"
$Logfile = "$Logpath\IIS_configure.log"
$datetime = Get-Date -format "[dd-MM-yyyy HH:mm:ss]"
Function LogWrite
{
   Param ([string]$logstring)
   Add-content $Logfile -value "$datetime $logstring "
}

# Get IIS Version
$IISVersion = [System.Diagnostics.FileVersionInfo]::GetVersionInfo(“C:\Windows\system32\notepad.exe”).FileVersion
LogWrite "I Found IIS version $IISVersion on this machine"

# Global variables
$ApplicationPoolName = "MICRONTEL_Accessi"
$WebSiteName = "Default Web Site"
$ApplicationName = "/mpassw"
LogWrite "Starting configuration of $WebSiteName$ApplicationName in application pool $ApplicationPoolName"

# Import IIS admin modules
$IISShiftVersion = '10'
Import-Module WebAdministration -ErrorAction SilentlyContinue # For IIS 7.5 (Windows Server 2008 R2 on)
Import-Module IISAdministration # For IIS 10.0 (Windows Server 2016 and 2016-nano on)
$manager = Get-IISServerManager

# Create application pool, integrated pipeline, Runtime v4.0, Enable32bitApps, idleTimeout 8hrs
# Using IISAdministration (IIS 10.0)
if ($IISVersion.Substring(0,2) -ge $IISShiftVersion) {
	if ($manager.ApplicationPools["$ApplicationPoolName"] -eq $null) {
	$pool = $manager.ApplicationPools.Add("$ApplicationPoolName")
	$pool.ManagedPipelineMode = "Integrated"
	$pool.ManagedRuntimeVersion = "v4.0"
	$pool.Enable32BitAppOnWin64 = $true
	$pool.AutoStart = $true
	$pool.ProcessModel.IdentityType = "ApplicationPoolIdentity"
	$pool.ProcessModel.idleTimeout = "08:00:00"
	$manager.CommitChanges()
	LogWrite "Application pool $ApplicationPoolName successfully created"
	} else {LogWrite "Application pool $ApplicationPoolName already exists, please choose a different name"}
} 
# On WebAdministration (IIS 7.5)
else {
	if ((Test-Path "IIS:\AppPools\$ApplicationPoolName") -eq $False) {
	New-WebAppPool -name "$ApplicationPoolName"  -force
	$appPool = Get-Item IIS:\AppPools\$ApplicationPoolName 
	$appPool.processModel.identityType = "ApplicationPoolIdentity"
	$appPool.enable32BitAppOnWin64 = 1
	$appPool.processModel.idleTimeout = "08:00:00"
	$appPool | Set-Item
	LogWrite "Application Pool $ApplicationPoolName successfully created"
	} else {LogWrite "Application Pool $ApplicationPoolName already exists, please choose a different name"}
}

# Assign the web application mpassw to the application pool
# Using IISAdministration (IIS 10.0)
if ($IISVersion.Substring(0,2) - $IISShiftVersion) {
	$website = $manager.Sites["$WebSiteName"]
	$website.Applications["$ApplicationName"].ApplicationPoolName = "$ApplicationPoolName"
	$manager.CommitChanges()
	LogWrite "Application $WebSiteName$ApplicationName successfully assigned to Application pool $ApplicationPoolName"
}
# Using WebAdministration (IIS 7.5)
else {
	Set-ItemProperty -Path "IIS:\Sites\$WebSiteName\$ApplicationName" -name "applicationPool" -value "$ApplicationPoolName"
	LogWrite "Application $WebSiteName$ApplicationName successfully assigned to Application pool $ApplicationPoolName"
}
