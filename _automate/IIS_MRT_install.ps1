<# 
.SYNOPSIS
    Automate IIS installation on Windows client or server
    Automate MRT Application Suite installation
.INPUT
    CSV file with required IIS features
    MRTxxx.exe in same directory
.NOTE
    Tested on Windows Server 2016 Datacenter
    Tested on Windows Server 2019 Datacenter
    To be tested on Windows 10 Pro build 1809
    .Re-test all IIS features on Client
    
    .Add Set-ExecutionPolicy Unrestricted
        Set-Executionpolicy -ExecutionPolicy Unrestricted -Force -ErrorAction SilentlyContinue 
    .CheckIf-Installed is getting ugly, clean it up!
    ..Add a little more Write-Host
    ..Add speed-test
#>

# Function: Writes a Log
Function LogWrite {
   Param ([string]$logstring)
   $LogPath = ".\Install.log"
   $datetime = Get-Date -format "[dd-MM-yyyy HH:mm:ss]"
   Add-content $LogPath -value "$datetime $logstring "
}

# Check if the current user is Administrator
Function Check-IsAdmin { 
    param() 
    $principal = New-Object System.Security.Principal.WindowsPrincipal([System.Security.Principal.WindowsIdentity]::GetCurrent()) 
    $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator) 
}

# Check if feature installation is successful
function CheckIf-Installed($installedfeature,$command,$result) {
    if ($installedfeature.$command -eq $result){
        LogWrite "Windows Feature $installedfeature successfully installed"
    } else {
        LogWrite "ERROR - Something went wrong installing $feature, please check again!"
        # Exit installation at the first error
	    Exit
    }
}

# Function: Check if program is installed, based on Name
Function Check_Program_Installed($programName) {
    $Program = Get-WMIObject -Query "SELECT * FROM Win32_Product WHERE Name LIKE '%$programName%'"
    $wmi_check = $Program -ne $null
    return $wmi_check;
}
<# ------ #>

LogWrite "1. Starting installation of IIS Web Server"

# Check if current user is Administrator
If (!( Check-IsAdmin) ) {
    LogWrite "ERROR - The currently logged on user is not an Administrator! Exiting..."
    exit 
}

# Check OS type
LogWrite "Checking OS infos..."
$OSDetails = Get-ComputerInfo
$OSName = (Get-CimInstance -ClassName Win32_OperatingSystem).Caption
$OSType = $OSDetails.WindowsInstallationType
LogWrite "This is $OSName, so we're on a $OSType machine!"

# IIS Features loaded from CSV file
LogWrite "Gathering IIS specs..."
$IISFeaturesList = @(Import-CSV ".\IIS_features.csv" -Delimiter ';' -header 'FeatureName','Client','Server')
$IISFeaturesList = $IISFeaturesList.$OSType

LogWrite "Installing IIS features..."
# Workstation (DISM installation module)
if ($OSType -eq "Client"){
    $command = "State"
    $result = "Enabled"
    foreach ($feature in $IISFeaturesList){
        Enable-WindowsOptionalFeature -Online -FeatureName $feature | Out-Null
        $installedfeature = (Get-WindowsOptionalFeature -Online -FeatureName $feature).featureName
        CheckIf-Installed($installedfeature,$command)
        }
} 
# Server (ServerManager installation module)
elseif ($OSType -eq "Server"){
    $command = "Installed"
    $result = $True
    foreach ($feature in $IISFeaturesList){
        Install-WindowsFeature -Name $feature -ErrorAction SilentlyContinue | Out-Null
        $installedfeature = Get-WindowsFeature -name $feature
        CheckIf-Installed($installedfeature,$command)
        }
}

# Reset IIS
LogWrite "Resetting IIS..."
Invoke-Command -ScriptBlock { iisreset} -Verbose
# Get IIS version
$IISVersion = [System.Diagnostics.FileVersionInfo]::GetVersionInfo(“C:\Windows\system32\notepad.exe”).FileVersion
LogWrite "IIS $IISVersion successfully installed!"

<# ------ #>

LogWrite "2. Installing MRT Application Suite..."
# Create package msi in current dir
./mrt7526.exe /s /x /b"$PWD" /v"/qn"
# Wait for extraction
Start-sleep -s 15
# Silently install msi (cmd) and create low-level error log
$msiArguments = 
    '/qn', 
    '/i',
    '"Micronpass Application Suite.msi"',
    '/le ".\MRT_install.log"'
$Process = Start-Process -PassThru -Wait msiexec -ArgumentList $msiArguments
# Check if installation was successful
if (($Process.ExitCode -eq '0') -and (Check_Program_Installed("Micronpass Application Suite") -eq $True )) {
    LogWrite "MRT Application Suite $($Program.Version) successfully installed!"
} Else {
    LogWrite "ERROR - Something went wrong installing MRT Application Suite, please check MRT_Install.log"
}

<# ------ #>

# Open GeneraABL
cd C:\MPW\GeneraAbl\
Start-process ./GeneraAbl.exe 
# Check virtual or physical server
if ($(get-wmiobject win32_computersystem).model -match "virtual,*"){
    $keys = "{TAB}{TAB}{ENTER}"
} else {
    $keys = "{TAB}{ENTER}"
}
$wshshell = New-Object -ComObject WScript.Shell
Start-Sleep -Seconds 1
$wshshell.sendkeys($keys)

# Open MicronStart and wait for input
cd C:\MPW\MicronStart
Start-process ./mStart.exe -Wait
Write-Host "Going on..."