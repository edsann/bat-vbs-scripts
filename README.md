# pwsh-misc

Some useful scripts in [Powershell](https://github.com/PowerShell/PowerShell). [Azure Cloud Shell](https://shell.azure.com) is included as well. Other cmd and VBS scripts are stored in the corresponding folders.

[Kevin Marquette's Chronometer module](https://powershellexplained.com/2017-02-05-Powershell-Chronometer-line-by-line-script-execution-times/?utm_source=blog&utm_medium=blog&utm_content=projects) can be used to troubleshoot the scripts' time performances.

### Some helpful functions:
* `Get-DirectoryTreeSize` : from [The Sysadmin Channel](https://thesysadminchannel.com/get-directory-tree-size-using-powershell/); it gets file count, subdirectory count and folder size of a specific path
* `Get-PSFreeDrive`: it returns the free space of the system drives
* `Get-PublicIPAddress`: it returns your public IPv4 address
* `Install-PowershellCore`: it downloads and installs Powershell Core
* `New-AzMyResources`: it creates a spot VM in [Azure](https://portal.azure.com), providing the public IP address and opening a Windows Remote Desktop session
* `Run-AzVMscript`: it runs a specific Powershell script on an [Azure](https://portal.azure.com) VM
* `Test-ParallelPing`: it loops through an array of IPv4 addresses, continuously returning for each the result of `Test-Connection` (it's like multi-address ping)
* `Test-SQLConnection`: uses `sqlcmd` to continuously check the connection to SQL Server, then sends an email notification as soon as it gets down

