# Source: https://weblog.west-wind.com/posts/2017/may/25/automating-iis-feature-installation-with-powershell
# This script installs IIS and the features required to run our web application
#
# Tested on PowerShell 5.1
# Run as Administrator!

# * Make sure Powershell Execution Policy is bypassed to run these scripts:
# * YOU MAY HAVE TO RUN THIS COMMAND PRIOR TO RUNNING THIS SCRIPT!
Set-ExecutionPolicy Bypass -Scope Process

# To begin with: Creating and updating a log file with timestamps
$Logpath = "C:\_TEMP"
$Logfile = "$Logpath\IIS_install.log"
$datetime = Get-Date -format "[dd-MM-yyyy HH:mm:ss]"
Function LogWrite
{
   Param ([string]$logstring)
   Add-content $Logfile -value "$datetime $logstring "
}
LogWrite "Start logging"

# ---------------------------------------------------- 
# Install IIS
#
# To list all Windows Features: 
# 	dism /online /Get-Features
# or:
# 	Get-WindowsOptionalFeature -Online 
# LIST All IIS FEATURES: 
# 	Get-WindowsOptionalFeature -Online | where FeatureName -like 'IIS-*'

# .NET Framework 3.5 and 4.7
Enable-WindowsOptionalFeature -Online -FeatureName NetFx3
Enable-WindowsOptionalFeature -online -FeatureName NetFx4-AdvSrvs
Enable-WindowsOptionalFeature -online -FeatureName NetFx4Extended-ASPNET45
# Web Server Role and Web Server Role Service (with default features, included management tools)
Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerRole
Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServer
# Web Server features > ApplicationDevelopment
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ApplicationDevelopment
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ASPNET
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ASPNET45
Enable-WindowsOptionalFeature -Online -FeatureName IIS-NetFxExtensibility47
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ISAPIExtensions
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ISAPIFilter
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ApplicationInit
Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebSockets
# Web Server features > II6 MAnagement Compatibility
Enable-WindowsOptionalFeature -Online -FeatureName IIS-IIS6ManagementCompatibility
# [Optional] Web Server features > Authentications
Enable-WindowsOptionalFeature -Online -FeatureName IIS-BasicAuthentication
Enable-WindowsOptionalFeature -Online -FeatureName IIS-WindowsAuthentication
# Misc.
Enable-WindowsOptionalFeature -Online -FeatureName TelnetClient
# If you need classic ASP (not recommended)
#Enable-WindowsOptionalFeature -Online -FeatureName IIS-ASP

# ---------------------------------------------------- 
# Insert mpassw setup here

# ----------------------------------------------------
# IIS Configuration

# Global variables
$ApplicationPoolName = "MICRONTEL_Accessi"
$WebSiteName = "Default Web Site"
$ApplicationName = "/mpassw"
# Get IIS Version as string and import admin modules
$IISVersion = [System.Diagnostics.FileVersionInfo]::GetVersionInfo(“C:\Windows\system32\notepad.exe”).FileVersion
$IISShiftVersion = '10'
Import-Module WebAdministration -ErrorAction SilentlyContinue # For IIS 7.5 (Windows Server 2008 R2 on)
Import-Module IISAdministration # For IIS 10.0 (Windows Server 2016 and 2016-nano on)
$manager = Get-IISServerManager

# Create application pool, integrated pipeline, Runtime v4.0, Enable32bitApps, idleTimeout 8hrs
# Using IISAdministration (IIS 10.0)
if ($IISVersion.Substring(0,2) >= $IISShiftVersion) {
	if ($manager.ApplicationPools["$ApplicationPoolName"] -eq $null) {
	$pool = $manager.ApplicationPools.Add("$ApplicationPoolName")
	$pool.ManagedPipelineMode = "Integrated"
	$pool.ManagedRuntimeVersion = "v4.0"
	$pool.Enable32BitAppOnWin64 = $true
	$pool.AutoStart = $true
	$pool.ProcessModel.IdentityType = "ApplicationPoolIdentity"
	$pool.ProcessModel.idleTimeout = "08:00:00"
	$manager.CommitChanges()
	LogWrite "Application Pool '$ApplicationPoolName' successfully created"
	} else {LogWrite "Application Pool '$ApplicationPoolName' already exists, please choose a different name"}
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
	LogWrite "Application Pool '$ApplicationPoolName' successfully created"
	} else {LogWrite "Application Pool '$ApplicationPoolName' already exists, please choose a different name"}
}

# Assign the web application mpassw to the application pool
# Using IISAdministration (IIS 10.0)
if ($IISVersion.Substring(0,2) >= $IISShiftVersion) {
	$website = $manager.Sites["$WebSiteName"]
	$website.Applications["$ApplicationName"].ApplicationPoolName = "$ApplicationPoolName"
	$manager.CommitChanges()
	LogWrite "Application '$WebSiteName$ApplicationName' successfully assigned to Application pool '$ApplicationPoolName'"
}
# Using WebAdministration (IIS 7.5)
else {
	Set-ItemProperty -Path "IIS:\Sites\$WebSiteName\$ApplicationName" -name "applicationPool" -value "$ApplicationPoolName"
	LogWrite "Application '$WebSiteName$ApplicationName' successfully assigned to Application pool '$ApplicationPoolName'"
}

# Next steps: enabling application-level logging
# Next steps: add authentication modes as parameters
