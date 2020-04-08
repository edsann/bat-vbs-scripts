<# 
.SYNOPSIS
    Install IIS on Windows client or server
    Install MRT Application Suite
    Install SQL Server Express (if needed)
    Install SQL Server Management Studio (if needed)
    Configure IIS Application Pool
    Configure MPW initial parameters by using external query
.TESTED ON
    -
.INPUT
    CSV file with required IIS features in the same directory
    SQLEXPR_x64_ENU.exe in same directory (English only for now)
    SSMS-SETUP-ENU.exe in same directory (English only for now)
    MRTxxx.exe in same directory
.NEXT
    .Clean up IIS installation function
    .Add initial installation switches
    ..Add speed-test
    ..Add DSC test at the end of the script
#>

Set-Executionpolicy -ExecutionPolicy Unrestricted -Force -ErrorAction SilentlyContinue 

# Write Log and write host
function Write-Log {
    param ([string]$logstring)
    $LogPath = ".\install.log"
    $datetime = Get-Date -format "[dd-MM-yyyy HH:mm:ss]"
    Add-content $LogPath -value "$datetime $logstring "
    Write-Host $logstring
}

<# ------------------------------------ #>

$step = 1

# Check if current user is Administrator
function Check-IsAdmin { 
    param() 
    $principal = New-Object System.Security.Principal.WindowsPrincipal([System.Security.Principal.WindowsIdentity]::GetCurrent()) 
    $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator) 
}
if (!( Check-IsAdmin) ) {
    Write-Log "ERROR - The currently logged on user is not an Administrator!"
    break 
}

# Check current execution policy
if ((Get-ExecutionPolicy) -ne "Unrestricted" ) {
    Write-Log "ERROR - The Execution Policies on the current session prevents this script from working!"
    break 
}

# Check OS type 
$OSDetails = Get-ComputerInfo
$OSType = $OSDetails.WindowsInstallationType

# Check .NET Framework version 
# (379893 corresponds to .NET Framework 4.5.2)
$MinimumFramework = '379893'
$InstalledFramework = Get-ItemProperty "HKLM:SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full"
if (!($InstalledFramework).Release -ge $MinimumFramework){
    Write-Log "ERROR - The installed .NET Framework $($InstalledFramework.Version) does not meet the minimum requirements."
    break 
}



$step++
Write-Log "$step. Loading CSV and installing IIS features"

# Check if features file is present
if(!(Test-Path ".\IIS_features.csv")) { 
    Write-Log "ERROR - IIS feature list not found! Please copy it to root folder."  
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
            Write-Log "Windows Feature $feature successfully installed"
        } else {
            Write-Log "ERROR - Something went wrong installing $feature, please check again!"
	        break
        }
    }
} 
# Server (ServerManager installation module)
elseif ($OSType -eq "Server"){
    foreach ($feature in $IISFeaturesList){
        Install-WindowsFeature -Name $feature  | Out-Null
        if ((Get-WindowsFeature -name $feature).Installed -eq $True){
            Write-Log "Windows Feature $feature successfully installed"
        } else {
            Write-Log "ERROR - Something went wrong installing $feature, please check again!"
	        break
        }
    }
}

# Reset IIS
Invoke-Command -ScriptBlock { iisreset} -Verbose
$IISVersion = [System.Diagnostics.FileVersionInfo]::GetVersionInfo(“C:\Windows\system32\notepad.exe”).FileVersion
Write-Log "IIS $IISVersion successfully installed!"

<# ------------------------------------ #>

# Do you want to install SQLExpr ?
$SQLswitch = Read-Host -prompt "Do you want to install SQLExpr ? [Y] Yes [N] No"

if ($SQLswitch -eq "Y"){

    $step++
    Write-Log "$step. Installing SQL Server Express"
    $SQLexpress_Setupfile = (Get-Item SQLEXPR_x64_*.exe).Name
    
    # Prompt user input
    $SQLpassword = Read-Host -prompt "Insert SQL system administrator password: "
        # Check password complexity
    $SQLinstance = Read-Host -prompt "Insert SQL Server instance name: "
    
    # Check if setup file is present
    if(!(Test-Path ".\$Sqlexpress_Setupfile")) { 
        Write-Log "ERROR - Sqlexpress setup file not found! Please copy it to root folder."  
        break
    } 
    
    # Check if an instance with the same name already exists
    if (!(Get-Service -displayname "*$($SQLinstance)*")){
        continue
    } else {
        Write-Log "ERROR - Service $SQLinstance is already installed:"
        Get-Service -displayname "*$($SQLinstance)*"
        break
    }
    
    # Silently extract setup media file
    Rename-Item $SQLexpress_Setupfile -NewName sql_install.exe
    ./sql_install.exe /q /x:".\SQL_Install"
    Start-sleep -s 5
    # SQL Server Express installation
    ./SQL_Install/setup.exe /Q /IACCEPTSQLSERVERLICENSETERMS /ACTION="install" /FEATURES=SQLengine /INSTANCENAME="$SQLinstance" /SECURITYMODE=SQL /SAPWD="$SQLpassword" /INDICATEPROGRESS | Out-file ".\SQLEXPR_install.log"
    Start-sleep -s 30
    
    # Check if installation was successful by verifying the instance in the service name
    if (Get-Service -displayname "*$($SQLinstance)*" -ErrorAction SilentlyContinue){
       Write-Log "SQL instance $SQLinstance successfully installed"
    } else {
       Write-Log "ERROR - Something went wrong installing SQL instance $SQLinstance, please check SQL installation log"
       break
    }
    
} else { 
    Write-Log "SQL Server installation skipped. Proceeding with the following steps..."
}

# Do you want to install SSMS?
$SSMSSwitch = Read-Host -prompt "Do you want to install SSMS with default parameters ? [Y] Yes [N] No"

if ($SSMSSwitch -eq "Y"){

    $step++
    Write-Log "$step. Installing SQL Server Management Studio"
    Write-Log "This may take a while... ..."
    $SSMS_Setupfile = (Get-Item SSMS*.exe).Name

    # Check if setup file is present
    if(!(Test-Path ".\$SSMS_Setupfile")) { 
        Write-Log "ERROR - SSMS setup file not found! Please copy it to root folder."  
        break
    } 

    # Move SSMS setup file into SQL install folder
    Rename-Item $SSMS_Setupfile -NewName SSMS_setup.exe
    if (!(Get-Item .\SQL_install)){
        New-Item -ItemType Directory -Path .\SQL_install
    } else {
        continue
    }
    Move-Item -Path .\SSMS_setup.exe -Destination .\SQL_install\SSMS_Setup.exe
    # Silently installing SSMS with no restart, create SSMS_install.log
    # ./SQL_install/SSMS_setup.exe /INSTALL /QUIET /NORESTART /LOG SSMS_install.log
    $SSMSArguments = '/INSTALL','/QUIET','/NORESTART','/LOG "SSMS_install.log"'
    $SSMSInstallProcess = Start-Process -PassThru -Wait ./SQL_install/SSMS_Setup.exe -ArgumentList $SSMSArguments
    Start-sleep -s 30

    # Check if install was good
    $Program = Get-CimInstance -Query "SELECT * FROM Win32_Product WHERE Name LIKE '%SQL Server Management Studio%'"
    Start-sleep -s 10
    $wmi_check = $Program -ne $null
    if (($InstallProcess.ExitCode -eq '0') -and ($wmi_check -eq $True )) {
        Write-Log "$($Program.Name) $($Program.Version) successfully installed!"
        continue
    } else {
        Write-Log "ERROR - Something went wrong installing $($Program.Name), please check install log"
        break
    }  

} else { 
    Write-Log "SQL Server Management Studio not needed. Proceeding with the following steps..."
}

<# ------------------------------------ #>

$step++ 
Write-Log "$step. Install MRT Application Suite"

# Check if setup file is present
$mrtsetupfile = (Get-Item mrt*.exe).Name
if(!(Test-Path ".\$mrtsetupfile")) {
    Write-Log "ERROR - MRT setup file not found! Please copy it to root folder."  
    break
} 

# Create package msi in current dir
Rename-Item $mrtsetupfile -NewName mrt_install.exe
.\mrt_install.exe /s /x /b"$PWD" /v"/qn"
Start-sleep -s 20
# Silently install msi (cmd) and create error log
$msiArguments = '/qn','/i','"Micronpass Application Suite.msi"','/l*e ".\msi_install.log"'
$InstallProcess = Start-Process -PassThru -Wait msiexec -ArgumentList $msiArguments
Start-sleep -s 20
# Check if installation was successful
$Program = Get-CimInstance -Query "SELECT * FROM Win32_Product WHERE Name LIKE '%Micronpass Application Suite%'"
Start-sleep -s 10
$wmi_check = $Program -ne $null
if (($InstallProcess.ExitCode -eq '0') -and ($wmi_check -eq $True )) {
    Write-Log "$($Program.Name) $($Program.Version) successfully installed!"
    continue
} else {
    Write-Log "ERROR - Something went wrong installing $($Program.Name), please check install log"
    break
}  

<# ------------------------------------ #>

$step++
Write-Log "$step. Activating product"

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

    # Check if Connection Strings have been updated before continuing

<# ------------------------------------ #>

$step++
Write-Log "$step. Configuring IIS application pool"

# Global variables
$ApplicationPoolName = "MICRONTEL_Accessi"
$WebSiteName = "Default Web Site"
$ApplicationName = "/mpassw"
Write-Log "Starting configuration of $WebSiteName$ApplicationName in application pool $ApplicationPoolName"

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
	Write-Log "Application pool $ApplicationPoolName successfully created"
	} else {Write-Log "Application pool $ApplicationPoolName already exists, please choose a different name"}
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
	Write-Log "Application Pool $ApplicationPoolName successfully created"
	} else {Write-Log "Application Pool $ApplicationPoolName already exists, please choose a different name"}
}

# Assign the web application mpassw to the application pool
# Using IISAdministration (IIS 10.0)
if ($IISVersion.Substring(0,2) -ge $IISShiftVersion) {
	$website = $manager.Sites["$WebSiteName"]
	$website.Applications["$ApplicationName"].ApplicationPoolName = "$ApplicationPoolName"
	$manager.CommitChanges()
	Write-Log "Application $WebSiteName$ApplicationName successfully assigned to Application pool $ApplicationPoolName"
}
# Using WebAdministration (IIS 7.5)
else {
	Set-ItemProperty -Path "IIS:\Sites\$WebSiteName\$ApplicationName" -name "applicationPool" -value "$ApplicationPoolName"
	Write-Log "Application $WebSiteName$ApplicationName successfully assigned to Application pool $ApplicationPoolName"
}    

<# ------------------------------------ #>

$step++ 
Write-Log "$step. Configuring application"

# Translated XML config 
$ConfigFile = "C:\MPW\MicronConfig\config.exe.config"
$ConfigXml = [xml] (Get-Content $ConfigFile) # Converts .config to .xml

# Read value from dbengine
$DBEngine = $ConfigXml.SelectSingleNode('//add[@key="dbEngine"]').Value
$MyDBEngine = "$("//add[@key='")$($DBEngine)$("Str']")"

# Read value from SqlStr and print it on file
$ConnectionString = $ConfigXml.SelectSingleNode($MyDBEngine).Value

# Get Connection String parameters
$DBDataSource = [regex]::Match($ConnectionString, 'Data Source=([^;]+)').Groups[1].Value
$DBInitialCatalog = [regex]::Match($ConnectionString, 'Initial Catalog=([^;]+)').Groups[1].Value
$DBUserId = [regex]::Match($ConnectionString, 'User ID=([^;]+)').Groups[1].Value
$DBPassword = [regex]::Match($ConnectionString, 'Password=([^;]+)').Groups[1].Value

# Import SQL PowerShell module
Get-Command -Module SQLPS

# Extract SQL Server version as connection test
Invoke-Sqlcmd -ServerInstance $DBDataSource -Database $DBInitialCatalog -Query "SELECT @@VERSION"

# Configuration query 
# (this will be outsourced to an external file)
$InitialConfigurationQuery = "
    /* Set GDPR flags to default */
    UPDATE T05COMFLAGS SET T05VALORE='1' WHERE T05TIPO='GDPRMODEDIP'
    UPDATE T05COMFLAGS SET T05VALORE='1' WHERE T05TIPO='GDPRMODEEST'
    UPDATE T05COMFLAGS SET T05VALORE='1' WHERE T05TIPO='GDPRMODEVIS'
    UPDATE T05COMFLAGS SET T05VALORE='1' WHERE T05TIPO='GDPRMODEUSR'
    UPDATE T05COMFLAGS SET T05VALORE='ANONYMOUS' WHERE T05TIPO='GDPRANONYMTEXT'
    /* Create utilities internal company */
    INSERT INTO T71COMAZIENDEINTERNE VALUES (N'UTIL',N'_UTILITIES',N'INSTALLATORE',N'20000101000000',N'',N'')
    /* Create reference employee */
    INSERT INTO T26COMDIPENDENTI VALUES (N'00000001',N'_DIP.RIF', N'_DIP.RIF', N'', N'', N'', N'', N'0', N'', N'INSTALLATORE', N'20000101000000', N'', N'', N'', N'', N'20000101', N'', N'0', N'', N'UTIL', N'M', N'', N'1', N'20000101000000', N'99991231235959', N'', N'', N'', N'', N'', N'', N'', N'', N'', N'', N'')
    /* Assign ref.empl. to admin user */
    INSERT INTO T21COMUTENTI (T21DEFDIPRIFEST,T21DEFAZINTEST,T21DEFDIPRIFVIS,T21DEFAZINTVIS) VALUES ('00000001','UTIL','00000001','UTIL')
"

# Apply query
Invoke-Sqlcmd -ServerInstance $DBDataSource -Database $DBInitialCatalog -Query $InitialConfigurationQuery

<# ------------------------------------ #>

# Insert final DSC checks here

<# ------------------------------------ #>

Set-ExecutionPolicy -ExecutionPolicy Restricted
