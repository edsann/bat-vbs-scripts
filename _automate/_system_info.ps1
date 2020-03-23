# Create a .ps1 returning info about the current session 
# Username:
# Computer name:
# Operating system:
# IP address (InterfaceAlias, IPaddress)
# Last 5 Powershell commands (Id,CommandLine)
cls
Write-Host "Current User: " $env:USERNAME
Write-Host "Computer Name: " $env:COMPUTERNAME
# Write-Host "Operating System: " # $env:OS
(Get-CimInstance -ClassName Win32_OperatingSystem).Caption
Write-Host "IP addresses: "
Get-NetIPConfiguration | Select-Object InterfaceAlias, IPv4Address |  Out-host
Write-Host "Last 5 Powershell commands: "
Get-History | Select-Object -Last 5 | Out-host
