<# 
.Synopsis
    Automate IIS installation on Windows client or server
.Next
    Complete IIS Features list
#>

# Creating and updating a log file with timestamps
$Logpath = "C:\MPW_INSTALL"
$Logfile = "$Logpath\IIS_install.log"
$datetime = Get-Date -format "[dd-MM-yyyy HH:mm:ss]"
Function LogWrite
{
   Param ([string]$logstring)
   Add-content $Logfile -value "$datetime $logstring "
}


LogWrite "Starting installation of IIS Web Server"
LogWrite "Checking OS infos..."
# Check OS type
$OSDetails = Get-ComputerInfo
$OSName = (Get-CimInstance -ClassName Win32_OperatingSystem).Caption
$OSType = $OSDetails.WindowsInstallationType
LogWrite "This is $OSName, so we're on a $OSType machine!"

# IIS Components list
$IIS_Client_Features_List=@(
    # NetFx4 components
    "NetFx4-AdvSrvs",
    "NetFx4Extended-ASPNET45",
    # Web Server role
    "IIS-WebServerRole",
    "IIS-WebServer",
    # Application Development
    "IIS-ApplicationDevelopment",
    "IIS-ASPNET",
    "IIS-ASPNET45", # To be fixed
    "IIS-NetFxExtensibility47", # To be fixed
    "IIS-ISAPIExtensions",
    "IIS-ISAPIFilter",
    "IIS-ApplicationInit",
    "IIS-WebSockets",
    # IIS 6 Compatibility
    "IIS-IIS6ManagementCompatibility",
    # Authentications
    "IIS-BasicAuthentication",
    "IIS-WindowsAuthentication",
    # Misc.
    "TelnetClient"
)
$IIS_Server_Features_List=@(
    # Web Server Role
    "Web-Server",
    # Web Server feature
    "Web-WebServer",
    # Application Development
    "Web-Net-Ext45",
    "Web-Asp-Net45",
    # IIS 6 Management compatibility
    "Web-Mgmt-Compat",
    # .NET Framework 4 features
    "NET-Framework-45-features",
    "NET-Framework-45-Core",
    "NET-Framework-45-ASPNET",
    # Telnet client
    "Telnet-Client"
)

# Check if installation is successful
function CheckIf-Installed($installedfeature) {
    if ($installedfeature.Installed -eq $True){
        LogWrite "Windows Feature $feature successfully installed"
    } else {
        LogWrite "Something went wrong installing $feature, please check again"
        Exit
    }
}

# Workstation (dism installation module)
if ($OSType -eq "Client"){
    foreach ($feature in $IIS_Client_Features_List){
        Enable-WindowsOptionalFeature -Online -FeatureName $feature
        $installedfeature = Get-WindowsOptionalFeature -name $feature
        CheckIf-Installed($installedfeature)
        }

} 
# Server (ServerManager installation module)
elseif ($OSType -eq "Server"){
    foreach ($feature in $IIS_Server_Features_List){
        Install-WindowsFeature -Name $feature
        $installedfeature = Get-WindowsFeature -name $feature
        CheckIf-Installed($installedfeature)
        }
}


# Reset IIS
Invoke-Command -ScriptBlock { iisreset} -Verbose
# Get IIS version
$IISVersion = [System.Diagnostics.FileVersionInfo]::GetVersionInfo(“C:\Windows\system32\notepad.exe”).FileVersion
LogWrite "IIS $IISVersion successfully installed"



