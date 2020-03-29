cls
cd C:\MPW\GeneraAbl\
Start-process ./GeneraAbl.exe 

# How do I know it's virtual or physical?
# Systeminfo --> System Model

$exec = "{TAB}"
$wshshell = New-Object -ComObject WScript.Shell
Start-Sleep -Seconds 1
$wshshell.sendkeys($exec )

<#
cd C:\MPW\MicronStart
Start-process ./mStart.exe -Wait
#>
Write-Host "Continuing..."