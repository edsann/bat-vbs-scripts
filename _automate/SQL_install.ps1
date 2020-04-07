<#
.SYNOPSIS
    Installing SQL Server Express (and, optionally, the corresponding SSMS)
#>

Import-Module LogWrite

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
<# SQL Server installation 
    /Q - Silent installation, no GUI
    /IACCEPTSQLSERVERLICENSETERMS - Automatically accepts SQL Server license terms
    /ACTION="install" - Performs installation
    /FEATURES="SQLengine" - Only installs SQL Server engine
    /INSTANCENAME - Name of the instance
    /SECURITYMODE=SQL - Use SQL Authentication mode
    /SAPWD - System Administrator's password
#>
./SQL_Install/setup.exe /Q /IACCEPTSQLSERVERLICENSETERMS /ACTION="install" /FEATURES=SQLengine /INSTANCENAME="SQLEXPRESS" /SECURITYMODE=SQL /SAPWD="$SQLpassword" /INDICATEPROGRESS | Out-file ".\SQL_install.log"
Start-sleep -s 120

    # Check if installation was successful
    if (Get-Service -displayname "*$($SQLinstance)*" -ErrorAction SilentlyContinue){
        LogWrite "SQL instance $SQLinstance successfully installed"
    } else {
        LogWrite "ERROR - Something went wrong installing SQL instance $SQLinstance, please check SQL installation log"
        break
    }
