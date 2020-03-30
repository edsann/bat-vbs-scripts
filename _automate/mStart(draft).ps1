cls
cd C:\MPW\GeneraAbl\
Start-process ./GeneraAbl.exe 

if (
# Systeminfo --> System Model = Physical 
# get-wmiobject win32_computersystem | fl model
){
$exec = "{TAB}{ENTER}"
} else {
# Systeminfo --> System Model = Virtual 
# get-wmiobject win32_computersystem | fl model
$exec = "{TAB}{ENTER}{ENTER}"
}
$wshshell = New-Object -ComObject WScript.Shell
Start-Sleep -Seconds 1
$wshshell.sendkeys($exec )

cd C:\MPW\MicronStart
Start-process ./mStart.exe -Wait
Write-Host "Going on..."