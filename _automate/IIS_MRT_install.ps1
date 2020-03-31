<# 
.SYNOPSIS
    Automate IIS installation on Windows client or server
    Automate MRT Application Suite installation
.TESTED ON
    See EOF
.INPUT
    CSV file with required IIS features
    MRTxxx.exe in same directory
.NOTE
    .Manually re-test all IIS features on Client
    .Clean up IIS installation function
    ..Add speed-test
    ..Add DSC test at the end of the script
#>

Set-Executionpolicy -ExecutionPolicy Unrestricted -Force -ErrorAction SilentlyContinue 

# Function: Writes a Log
Function LogWrite {
   Param ([string]$logstring)
   $LogPath = ".\install.log"
   $datetime = Get-Date -format "[dd-MM-yyyy HH:mm:ss]"
   Add-content $LogPath -value "$datetime $logstring "
   Write-Host $logstring
}

# Check if the current user is Administrator
Function Check-IsAdmin { 
    param() 
    $principal = New-Object System.Security.Principal.WindowsPrincipal([System.Security.Principal.WindowsIdentity]::GetCurrent()) 
    $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator) 
}

<# ------------------------------------ #>

LogWrite "1. Check environment info"

# Check if current user is Administrator
If (!( Check-IsAdmin) ) {
    LogWrite "ERROR - The currently logged on user is not an Administrator!"
    exit 
}

# Check current execution policy
If ((Get-ExecutionPolicy) -ne "Unrestricted" ) {
    LogWrite "ERROR - The Execution Policies on the current session prevents this script to operate!"
    exit 
}

# Check OS type 
$OSDetails = Get-ComputerInfo
$OSName = (Get-CimInstance -ClassName Win32_OperatingSystem).Caption
$OSType = $OSDetails.WindowsInstallationType

# Load IIS Features from CSV file
$IISFeaturesList = @(Import-CSV ".\IIS_features.csv" -Delimiter ';' -header 'FeatureName','Client','Server')
$IISFeaturesList = $IISFeaturesList.$OSType

LogWrite "2. Install IIS features"

# Workstation (DISM installation module)
if ($OSType -eq "Client"){
    foreach ($feature in $IISFeaturesList){
        Enable-WindowsOptionalFeature -Online -FeatureName $feature | Out-Null
        if ((Get-WindowsOptionalFeature -Online -FeatureName $feature).State -eq "Enabled"){
            LogWrite "Windows Feature $feature successfully installed"
        } else {
            LogWrite "ERROR - Something went wrong installing $feature, please check again!"
	        Exit
        }
    }
} 
# Server (ServerManager installation module)
elseif ($OSType -eq "Server"){
    foreach ($feature in $IISFeaturesList){
        Install-WindowsFeature -Name $feature  | Out-Null
        if ((Get-WindowsFeature -name $feature).Installed -eq $True){
            LogWrite "Windows Feature $feature successfully installed"
        } else {
            LogWrite "ERROR - Something went wrong installing $feature, please check again!"
	        Exit
        }
    }
}

# Reset IIS
Invoke-Command -ScriptBlock { iisreset} -Verbose | LogWrite
$IISVersion = [System.Diagnostics.FileVersionInfo]::GetVersionInfo(“C:\Windows\system32\notepad.exe”).FileVersion
LogWrite "IIS $IISVersion successfully installed!"

<# ------------------------------------ #>

LogWrite "3. Install MRT Application Suite..."

# Create package msi in current dir
./mrt7526.exe /s /x /b"$PWD" /v"/qn"
# Wait for extraction
Start-sleep -s 20
# Silently install msi (cmd) and create low-level error log
$msiArguments = 
    '/qn', 
    '/i',
    '"Micronpass Application Suite.msi"',
    '/l*e ".\MRT_install.log"'
$Process = Start-Process -PassThru -Wait msiexec -ArgumentList $msiArguments
# Check if installation was successful
$Program = Get-WMIObject -Query "SELECT * FROM Win32_Product WHERE Name LIKE '%$programName%'"
$wmi_check = $Program -ne $null
if (($Process.ExitCode -eq '0') -and ($wmi_check -eq $True )) {
    LogWrite "MRT Application Suite $($Program.Version) successfully installed!"
} Else {
    LogWrite "ERROR - Something went wrong installing MRT Application Suite, please check MRT_Install.log"
}

<# ------------------------------------ #>

LogWrite "4. Activating product"

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
Start-Sleep -Seconds 2
$wshshell.sendkeys($keys)

# Open MicronStart and wait for input
Start-sleep -Seconds 5
cd C:\MPW\MicronStart
Start-process ./mStart.exe -Wait
Write-Host "Going on..."


<#
.TESTED ON
    Windows Server 2019
    Windows Server 2016
#>