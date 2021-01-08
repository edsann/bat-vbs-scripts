# pwsh-misc

Some useful scripts in [Powershell](https://github.com/PowerShell/PowerShell). [Azure Cloud Shell](https://shell.azure.com) is included as well. Other cmd and VBS scripts are stored in the corresponding folders.

## :book: Learning resources
### Books
- [ ] [Learn Powershell in a month of lunches](https://www.manning.com/books/learn-windows-powershell-in-a-month-of-lunches-third-edition), D. Jones, J. Hicks
- [ ] [Learn Powershell scripting in a month of lunches](https://www.manning.com/books/learn-powershell-scripting-in-a-month-of-lunches), D. Jones, J. Hicks
### Blogs
* [Adam Bertram](https://adamtheautomator.com/)
* [Jeffery Hicks](https://jdhitsolutions.com/blog/)
* [Josh Duffney](https://Duffney.io)
### Websites
* [Planet Powershell](http://planetpowershell.org) as a collector of web content
### Video courses
* John Cavill's [Powershell Masterclass]

## Some helpful functions:
* `Compare-FolderContent` : very simple command to compare the content of two similarly-structured folders
* `Get-DirectoryTreeSize` : from [The Sysadmin Channel](https://thesysadminchannel.com/get-directory-tree-size-using-powershell/); it gets file count, subdirectory count and folder size of a specific path
* `Get-PSFreeDrive`: it returns the free space of the system drives
* `Get-PublicIPAddress`: it returns your public IPv4 address
* `Install-PowershellCore`: it downloads and installs Powershell Core
* `New-AzMyResources`: it creates a spot VM in [Azure](https://portal.azure.com), providing the public IP address and opening a Windows Remote Desktop session
* `Run-AzVMscript`: it runs a specific Powershell script on an [Azure](https://portal.azure.com) VM
* `Test-ParallelPing`: it loops through an array of IPv4 addresses, continuously returning for each the result of `Test-Connection` (it's like multi-address ping)
* `Test-SQLConnection`: uses `sqlcmd` to continuously check the connection to SQL Server, then sends an email notification as soon as it gets down
