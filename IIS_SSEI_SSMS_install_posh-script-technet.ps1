<# 
    .Synopsis 
     
    Script for installing iis,sqlexpress 2012,sqlmanagementstudio 2012  
     
    To Install iis,sqlexpress,sqlmanagementstudio2012 on windows 2008 r2 64 bit or windows 2012 64 bit servers on workstations 
    Installs required IIS components 
    Installs Sqlexpress 2012 
    Installs Sqlexpress management studio 2012 (optional) 
     
    Sqlexpress and Management studio will be installed to default paths ie c:\Program files (x86)\.... or c:\Program files .... 
          
    .Usage 
    Should work on Powershell 3 and above 
    Copy this script to $setupfile_path and launch the cmd prompt as run as administator 
    Navigate to $Setupfile_path folder and run below  
     
    Powershell.exe -file <Script file name> -setupfile_path "path of sqlexpress setup files" -Log_path "Path where you want the log to kept" 
    if you want only iis to be installed then 
    Powershell.exe -file <Script file name> -setupfile_path "path of sqlexpress setup files" -Log_path "Path where you want the log to kept" -installiis 
    If you want to install sqlexpress and studio then 
     
    Powershell.exe -file <Script file name> -setupfile_path "path of sqlexpress setup files" -Log_path "Path where you want the log to kept" -installstudio 
     
    Error logs will be at $log_path or $env:temp\sqlexpresssetup.log and %temp%\sqlsetup.log 
      
    If you want to install custom path please refer this article and un-comment the below lines in below script 
      
    http://kb.vmware.com/selfservice/microsites/search.do?language=en_US&cmd=displayKC&externalId=1025549 
     
    Modify the variable in Param section ie $sqlexpress_Path 
     
    #$Sqlexpressinstall.StartInfo.Arguments = " /Action=Install /q /IAcceptSQLServerLicenseTerms /INSTALLSQLDATADIR=`"$Sqlexpress_Path`" /INSTANCEDIR=`"$Sqlexpress_Path`" /INSTANCENAME=`"$Instance_Name`"  /ROLE=AllFeatures_WithDefaults  /SQLSYSADMINACCOUNTS=`"BUILTIN\Administrators`" `"NT AUTHORITY\Network Service`"" 
     
    #$Sqlstudioinstall.StartInfo.Arguments = "/q /ACTION=Install /IACCEPTSQLSERVERLICENSETERMS /INSTALLSQLDATADIR=`"$Sqlexpress_Path`" /FEATURES=Tools" 
           
    Best for fresh install of sqlexpress and sql management studio with default path 
     
    Takes input the $log_path and $Setupfile_path which should contain the files SQLEXPR_x64_ENU.exe,SQLManagementStudio_x64_ENU.exe for 64bit 
     
    or For 32bit "SQLEXPR_x86_ENU.exe","SQLManagementStudio_x86_ENU.exe" 
     
    You can download these files from http://www.microsoft.com/en-us/download/details.aspx?id=29062 
     
    Requires the user to be have Local administrator other default pre-requisites for sqlexpress 2012 install, 
             
    you can convert this to .exe using powergui-->tools-->compile script 
      
    Please suggest any modifications.     
    #> 
 
 
 
Param( 
     [Parameter(Mandatory=$True,Position=1)] 
     $Log_Path="$env:temp\sqlexpresssetup.log", 
     [Parameter(Mandatory=$True,Position=2)]  
     $SetupFile_Path="C:\Sqlexpress2012", 
     [Parameter(Mandatory=$false,Position=3)] 
     [switch]$InstallIIS, 
     [Parameter(Mandatory=$false,Position=4)] 
     [switch]$InstallStudio, 
     [Parameter(Mandatory=$false,Position=5)] 
     [switch]$installsqlexpress, 
     [Parameter(Mandatory=$false,Position=6)] 
      $Sqlexpress_Path="" 
) 
Set-Executionpolicy -ExecutionPolicy Unrestricted -Force -ErrorAction SilentlyContinue 
#Default setup file names for 64bit sqlexpress 2012 install 
$Sqlexpress_Setupfile="SQLEXPR_x64_ENU.exe" 
$Studio_Setupfile="SQLManagementStudio_x64_ENU.exe" 
$DebugPreference="continue" 
 
#Try the below code if works all is well not we will review the log file and go ahead. 
#Function by 
Function Check-IsAdmin { 
    #[CmdletBinding(SupportsShouldProcess = $True, SupportsPaging = $True)] 
    param() 
    $principal = New-Object System.Security.Principal.WindowsPrincipal([System.Security.Principal.WindowsIdentity]::GetCurrent()) 
    $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator) 
} # end function Check-isAdmin 
 
 
Try { 
 
#Check if the operating system is 64 bit windows 2008/2012 if not exit 
If ([System.IntPtr]::Size -eq 4) { 
write-debug -message "Operating system is 32-bit .." -Verbose 
$Sqlexpress_Setupfile="SQLEXPR_x86_ENU.exe" 
$Studio_Setupfile="SQLManagementStudio_x86_ENU.exe" 
 }else { write-debug -message "Operating system is 64bit..." -Verbose } 
 
#Check if this is windows 2008/2012 if not exit 
$OSVersion = Get-WMIObject -class Win32_OperatingSystem 
[bool]$IsServ2012R2 = $OSVersion.Version -match "6.3.960" 
[bool]$IsServ2012 = $OSVersion.Version -match "6.2.920" 
[bool]$IsServ2008R2 = $OSVersion.Version -match "6.1.760" 
 
If(!($IsServ2012R2 -or $IsServ2012 -or $IsServ2008R2)){ write-debug "Not a windows 2008r2 or windows 2012 r2 or windows 2012 exiting....";exit } 
 
#check if the user is admin 
If (!( Check-IsAdmin) ) 
{ 
    write-debug -message "Logged on user is not an admin exiting..." 
    exit 
 
}#Endif  check-isadmin  
 
 
 
#Check whether sql setup files exist to proceed minumum required SQLEXPR_x64_ENU.exe 
 
if(Test-path $Setupfile_path){ 
 
                if(!(Test-path "$SetupFile_Path\$Sqlexpress_Setupfile")) 
                { 
                  write-debug -message  "Sqlexpress setup file not found please copy it to $setupfile_path and run the script again exiting...."  
                  exit 
                } 
     
 
}else { write-debug -message "Sqlexpress setup files path not exist exiting...."  ; exit } 
 
Set-Location -Path $SetupFile_Path -Verbose -ErrorAction Stop  
 
#Remove the previous log file if already exists 
 
If(Test-path $Log_Path) 
{ 
 
write-debug -Message "Removing old log file..." 
Remove-Item $Log_Path -verbose 
 
}#endif 
 
if ( $InstallIIS -eq $True) 
{ 
#List of IIS components including .net 3.5 sp1 enabled 
write-debug -message "Installing IIS components please wait....." 
$IIS_Components_List=@("AS-NET-Framework", 
"Web-Common-Http", 
"Web-Static-Content", 
"Web-Default-Doc", 
"Web-Dir-Browsing", 
"Web-Http-Errors", 
"Web-Asp-Net", 
"Web-Net-Ext", 
"Web-Http-Logging", 
"Web-Log-Libraries", 
"Web-Request-Monitor", 
"Web-Windows-Auth", 
"Web-Stat-Compression", 
"Web-Filtering", 
"Web-Stat-Compression", 
"Web-Mgmt-Tools", 
"Web-Mgmt-Console", 
"Web-Scripting-Tools", 
"Web-Mgmt-Service", 
"Web-Mgmt-Compat", 
"Web-Metabase", 
"Web-WMI", 
"Web-Lgcy-Scripting", 
"Web-Lgcy-Mgmt-Console", 
"NET-Framework", 
"NET-Framework-Core", 
"RSAT-Web-Server") 
 
 
#Installs default IIS components required for web applications based on asp.net  
 
#$IIS_Components_List|Add-WindowsFeature -LogPath $Log_Path -Verbose  -ErrorAction SilentlyContinue  
 
 
Invoke-Command -ScriptBlock { iisreset} -Verbose 
} 
#Install Sqlexpress 2012 
if ( $installsqlexpress -eq $true ) 
{ 
write-debug -message "Installing Sqlexpress 2012 Please wait......"  
 
$SqlExpressInstall = new-object System.Diagnostics.Process 
$Sqlexpressinstall.StartInfo.Filename = "$setupfile_path\$Sqlexpress_Setupfile" 
$Sqlexpressinstall.StartInfo.Arguments = " /Action=Install /q /IAcceptSQLServerLicenseTerms /InstanceName=SQLEXPRESS  /ROLE=AllFeatures_WithDefaults  /SQLSYSADMINACCOUNTS=`"BUILTIN\Administrators`" `"NT AUTHORITY\Network Service`"" 
#$Sqlexpressinstall.StartInfo.Arguments = " /Action=Install /q /IAcceptSQLServerLicenseTerms /INSTALLSQLDATADIR=`"$Sqlexpress_Path`" /INSTANCEDIR=`"$Sqlexpress_Path`" /INSTANCENAME=`"$Instance_Name`"  /ROLE=AllFeatures_WithDefaults  /SQLSYSADMINACCOUNTS=`"BUILTIN\Administrators`" `"NT AUTHORITY\Network Service`"" 
$SqlexpressInstall.StartInfo.RedirectStandardOutput = $True 
$Sqlexpressinstall.StartInfo.UseShellExecute = $false 
$Sqlexpressinstall.start() 
#$Sqlexpressinstall.WaitForExit() 
While(!($Sqlexpressinstall.HasExited)) 
{ 
 
write-debug -message "Installing Sqlexpress 2012 Please wait......"  
$SqlExpressInstall 
 
start-sleep -Seconds 10 
 
} 
[string] $Out = $Sqlexpressinstall.StandardOutput.ReadToEnd(); 
if (($sqlexpressinstall.exitcode) -eq 0 ) 
{ $sqlexpress_status="Successful"} 
else 
{ 
write-debug -message "SQlexpress install failed please check %temp%\sqlsetup.log"  
 } 
 
#$message1="Sqlexpress install exit code is`t" + $sqlexpress_status 
 
#write-debug  -Verbose -Message $message1 
 
Add-content -Path $SetupFile_Path -Value $out -ErrorAction SilentlyContinue 
} 
#Install Sqlexpress Management Studio 2012 requires file SQLManagementStudio_x64_ENU.exe 
 
if ( $Installstudio -eq $True) 
{ 
write-debug "Installing Sql Management studio 2012 Please wait....." 
 
$SqlstudioInstall = new-object System.Diagnostics.Process 
$Sqlstudioinstall.StartInfo.Filename = "$setupfile_path\$Studio_Setupfile" 
$Sqlstudioinstall.StartInfo.Arguments = "/q /ACTION=Install /IACCEPTSQLSERVERLICENSETERMS /FEATURES=Tools" 
#$Sqlstudioinstall.StartInfo.Arguments = "/q /ACTION=Install /IACCEPTSQLSERVERLICENSETERMS /INSTALLSQLDATADIR=`"$Sqlexpress_Path`" /FEATURES=Tools" 
$SqlstudioInstall.StartInfo.RedirectStandardOutput = $True 
$Sqlstudioinstall.StartInfo.UseShellExecute = $false 
$Sqlstudioinstall.start() 
#$Sqlstudioinstall.WaitForExit() 
While(!($Sqlstudioinstall.HasExited)) 
{ 
 
start-sleep -Seconds 10 
write-debug "Installing Sql Management studio 2012 Please wait....." 
$SqlstudioInstall 
} 
 
[string] $Out = $Sqlstudioinstall.StandardOutput.ReadToEnd(); 
 
if (($sqlstudioinstall.exitcode) -eq 0 ){ $sqlstudio_status="Successful"} 
else  
{write-debug -message "SQlstudio install failed please check %temp%\sqlsetup.log"  } 
 
#$message2="Sql management studio 2012 install exit code is   " + $sqlstudio_status 
 
#write-debug  -Verbose -Message $message2 
 
Add-content -Path $SetupFile_Path -value $out -ErrorAction SilentlyContinue -Verbose 
 
}#endif studioinstall 
 
 
} #End Try Block 
 
 
Catch [system.exception] { 
Write-host "Error occured`n" 
write-host  $Error[0]  
Add-content -Path $Log_Path -value $Error[0] -ErrorAction SilentlyContinue 
 
} 