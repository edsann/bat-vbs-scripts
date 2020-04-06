<# 
.SYNOPSIS
    Install IIS on Windows client or server
    Install MRT Application Suite
.TESTED ON
    Windows Server 2016, Windows Server 2019, Windows 10 Pro build 1809
.INPUT
    CSV file with required IIS features in the same directory
    SQLEXPR_x64_ENU.exe in same directory
    MRTxxx.exe in same directory
.NEXT
    .Clean up IIS installation function
    .Add initial installation switches
    ..Add speed-test
    ..Add DSC test at the end of the script
#>

Set-Executionpolicy -ExecutionPolicy Unrestricted -Force -ErrorAction SilentlyContinue 

# Write Log and write host
function LogWrite {
   param ([string]$logstring)
   $LogPath = ".\install.log"
   $datetime = Get-Date -format "[dd-MM-yyyy HH:mm:ss]"
   Add-content $LogPath -value "$datetime $logstring "
   Write-Host $logstring
}

# Check if the current user is Administrator
function Check-IsAdmin { 
    param() 
    $principal = New-Object System.Security.Principal.WindowsPrincipal([System.Security.Principal.WindowsIdentity]::GetCurrent()) 
    $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator) 
}

<# ------------------------------------ #>

$step = 1
LogWrite "$step. Check environment info"

# Check if current user is Administrator
if (!( Check-IsAdmin) ) {
    LogWrite "ERROR - The currently logged on user is not an Administrator!"
    break 
}

# Check current execution policy
if ((Get-ExecutionPolicy) -ne "Unrestricted" ) {
    LogWrite "ERROR - The Execution Policies on the current session prevents this script from working!"
    break 
}

# Check OS type 
$OSDetails = Get-ComputerInfo
$OSType = $OSDetails.WindowsInstallationType

<# ------------------------------------ #>

$step = $step +1; 
LogWrite "$step. Loading CSV and installing IIS features"

# Check if features file is present
if(!(Test-Path ".\IIS_features.csv")) { 
    LogWrite "ERROR - IIS feature list not found! Please copy it to root folder."  
    break
} 

# Load IIS Features from CSV file
$IISFeaturesList = @(Import-CSV ".\IIS_features.csv" -Delimiter ';' -header 'FeatureName','Client','Server')
$IISFeaturesList = $IISFeaturesList.$OSType

# Workstation (DISM installation module)
if ($OSType -eq "Client"){
    foreach ($feature in $IISFeaturesList){
        # The -all switch automatically installs all the parent features
        Enable-WindowsOptionalFeature -All -Online -FeatureName $feature | Out-Null 
        if ((Get-WindowsOptionalFeature -Online -FeatureName $feature).State -eq "Enabled"){
            LogWrite "Windows Feature $feature successfully installed"
        } else {
            LogWrite "ERROR - Something went wrong installing $feature, please check again!"
	        break
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
	        break
        }
    }
}

# Reset IIS
Invoke-Command -ScriptBlock { iisreset} -Verbose
$IISVersion = [System.Diagnostics.FileVersionInfo]::GetVersionInfo(“C:\Windows\system32\notepad.exe”).FileVersion
LogWrite "IIS $IISVersion successfully installed!"

<# ------------------------------------ #>

# Do you want to install SQLExpr and SSMS?
$SQLswitch = Read-Host -prompt "Do you want to install SQLExpr and SSMS? [Y] Yes [N] No"

if ($SQLswitch -eq "Y"){

    $step = $step +1; 
    LogWrite "$step. Installing SQL Server Express"
    $SQLexpress_Setupfile = "SQLEXPR_x64_*.exe"

    # Prompt user input
    $SQLpassword = Read-Host -prompt "Insert SQL system administrator password: "
        # Check password complexity
    $SQLinstance = Read-Host -prompt "Insert SQL Server instance name: "

    # Check if setup file is present
    if(!(Test-Path ".\$Sqlexpress_Setupfile")) { 
        LogWrite "ERROR - Sqlexpress setup file not found! Please copy it to root folder."  
        break
    } 

    # Check if an instance with the same name already exists
    if (!(Get-Service -displayname "*$($SQLinstance)*")){
        continue
    } else {
        LogWrite "ERROR - Service $SQLinstance is already installed:"
        Get-Service -displayname "*$($SQLinstance)*" | LogWrite
        break
    }

    # Silently extract setup media file
    ./SQLEXPR_x64_ENU.exe /q /x:".\SQL_Install"
    Start-sleep -s 30
    # SQL Server installation 
    #  /Q - Silent installation, no GUI
    #  /IACCEPTSQLSERVERLICENSETERMS - Automatically accepts SQL Server license terms
    #  /ACTION="install" - Performs installation
    #  /FEATURES="SQLengine" - Only installs SQL Server engine
    #  /INSTANCENAME - Name of the instance
    #  /SECURITYMODE=SQL - Use SQL Authentication mode
    #  /SAPWD - System Administrator's password
    ./SQL_Install/setup.exe /Q /IACCEPTSQLSERVERLICENSETERMS /ACTION="install" /FEATURES=SQLengine /INSTANCENAME="SQLEXPRESS" /SECURITYMODE=SQL /SAPWD="$SQLpassword" /INDICATEPROGRESS | Out-file ".\SQL_install.log"
    Start-sleep -s 120

    # Check if installation was successful
    if (Get-Service -displayname "*$($SQLinstance)*" -ErrorAction SilentlyContinue){
        LogWrite "SQL instance $SQLinstance successfully installed"
    } else {
        LogWrite "ERROR - Something went wrong installing SQL instance $SQLinstance, please check SQL installation log"
        break
    }

} else { 
    LogWrite "SQL Server installation skipped. Proceeding with the following steps..."
}

<# ------------------------------------ #>

$step = $step+1; 
LogWrite "$step. Install MRT Application Suite"

# Check if setup file is present
$mrtsetupfile = (Get-Item mrt*.exe)
if(!(Test-Path ".\$mrtsetupfile")) { 
    LogWrite "ERROR - MRT setup file not found! Please copy it to root folder."  
    break
} 

# Create package msi in current dir
Rename-Item $mrtsetupfile -NewName mrt_install.exe
.\mrt_install.exe /s /x /b"$PWD" /v"/qn"
Start-sleep -s 20
# Silently install msi (cmd) and create error log
$msiArguments = '/qn','/i','"Micronpass Application Suite.msi"','/l*e ".\msi.log"'
$Install = Start-Process -PassThru -Wait msiexec -ArgumentList $msiArguments
# Check if installation was successful
$Program = Get-WMIObject -Query "SELECT * FROM Win32_Product WHERE Name LIKE '%$programName%'"
Start-sleep -s 10
$wmi_check = $Program -ne $null
if (($Install.breakCode -eq '0') -and ($wmi_check -eq $True )) {
    LogWrite "MRT Application Suite $($Program.Version) successfully installed!"
} Else {
    LogWrite "ERROR - Something went wrong installing MRT Application Suite, please check msi log"
    break
}

<# ------------------------------------ #>

$step = $step +1; 
LogWrite "$step. Activating product"

# Open GeneraABL
Set-Location C:\MPW\GeneraAbl\
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
Set-Location C:\MPW\MicronStart
Start-process ./mStart.exe -Wait

    # Check if Connection Strings have been updated



<# ------------------------------------ #>

Set-ExecutionPolicy -ExecutionPolicy Restricted
