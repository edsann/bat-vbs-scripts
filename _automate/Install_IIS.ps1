# Source: https://weblog.west-wind.com/posts/2017/may/25/automating-iis-feature-installation-with-powershell
# This script installs IIS and the features required to run our web application
#
# Tested on PowerShell 5.1

# * Make sure you run this script from a Powershel Admin Prompt!
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


# To list all Windows Features: 
# dism /online /Get-Features
# or:
# Get-WindowsOptionalFeature -Online 
# LIST All IIS FEATURES: 
# Get-WindowsOptionalFeature -Online | where FeatureName -like 'IIS-*'

Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerRole
Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServer
Enable-WindowsOptionalFeature -Online -FeatureName IIS-CommonHttpFeatures
Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpErrors
Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpRedirect
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ApplicationDevelopment
# Watch out for these two:
Enable-WindowsOptionalFeature -online -FeatureName NetFx4Extended-ASPNET45
Enable-WindowsOptionalFeature -Online -FeatureName IIS-NetFxExtensibility45
#
Enable-WindowsOptionalFeature -Online -FeatureName IIS-HealthAndDiagnostics
Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpLogging
Enable-WindowsOptionalFeature -Online -FeatureName IIS-LoggingLibraries
Enable-WindowsOptionalFeature -Online -FeatureName IIS-RequestMonitor
Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpTracing
Enable-WindowsOptionalFeature -Online -FeatureName IIS-Security
Enable-WindowsOptionalFeature -Online -FeatureName IIS-RequestFiltering
Enable-WindowsOptionalFeature -Online -FeatureName IIS-Performance
Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerManagementTools
Enable-WindowsOptionalFeature -Online -FeatureName IIS-IIS6ManagementCompatibility
Enable-WindowsOptionalFeature -Online -FeatureName IIS-Metabase
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ManagementConsole
Enable-WindowsOptionalFeature -Online -FeatureName IIS-BasicAuthentication
Enable-WindowsOptionalFeature -Online -FeatureName IIS-WindowsAuthentication
Enable-WindowsOptionalFeature -Online -FeatureName IIS-StaticContent
Enable-WindowsOptionalFeature -Online -FeatureName IIS-DefaultDocument
Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebSockets
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ApplicationInit
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ISAPIExtensions
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ISAPIFilter
Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpCompressionStatic

Enable-WindowsOptionalFeature -Online -FeatureName IIS-ASPNET45

# If you need classic ASP (not recommended)
#Enable-WindowsOptionalFeature -Online -FeatureName IIS-ASP

# Import WebAdministration module
# It depends on the OS version, maybe insert a check with:
(Get-WMIObject win32_operatingsystem).name
Import-Module WebAdministration -ErrorAction SilentlyContinue # For IIS 7.5 (Windows Server 2008 R2 on)
Import-Module IISAdministration # For IIS 10.0 (Windows Server 2016 and 2016-nano on)

# To create an Application Pool
New-WebAppPool -name "NewWebSiteAppPool"  -force

# Reconfiguring the new Application Pool
# Source: https://docs.microsoft.com/en-us/iis/configuration/system.applicationhost/applicationpools/add/processmodel
$appPool = Get-Item IIS:\AppPools\NewWebSiteAppPool 
# Identity type
$appPool.processModel.identityType = "ApplicationPoolIdentity"
# Enable 32-bit applications
$appPool.enable32BitAppOnWin64 = 1
# Set processModel.idleTimeout to 8 hours
$appPool.processModel.idleTimeout = "08:00:00"
# Apply previous changes
$appPool | Set-Item



# Check if IIS is installed, and which version
# Still to be tested!
# -----------------------------
try {
  # Is IIS installed?
	$iisFeature = Get-WindowsFeature Web-WebServer -ErrorAction Stop
	if ($iisFeature -eq $null -or $iisFeature.Installed -eq $false) {
    # IIS not installed, print error
		Write-Error "It looks like IIS is not installed on this server and the deployment is likely to fail."
		Write-Error "Tip: You can use PowerShell to ensure IIS is installed: 'Install-WindowsFeature Web-WebServer'"
		Write-Error "     You are likely to want more IIS features than just the web server. Run 'Get-WindowsFeature *web*' to see all of the features you can install."
		exit 1
	}
	else {
    # IIS installed, get version from Registry Key
		$iisVersion = Get-ItemProperty HKLM:\SOFTWARE\Microsoft\InetStp\  | Select VersionString
		Write-Host "Detected IIS $($iisVersion.VersionString)"
	}
} catch {
  # IIS not installable
	Write-Host "Call to `Get-WindowsFeature Web-WebServer` failed."
	Write-Host "Unable to determine if IIS is installed on this server but will optimistically continue."
}

