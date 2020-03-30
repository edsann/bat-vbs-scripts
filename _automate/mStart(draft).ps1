# Open GeneraABL
cd C:\MPW\GeneraAbl\
Start-process ./GeneraAbl.exe 

if (
    # Systeminfo --> System Model = Physical 
    # get-wmiobject win32_computersystem | fl model
){
    $keys = "{TAB}{ENTER}"
} else {
    # Systeminfo --> System Model = Virtual 
    # get-wmiobject win32_computersystem | fl model
    $keys = "{TAB}{TAB}{ENTER}"
}
$wshshell = New-Object -ComObject WScript.Shell
Start-Sleep -Seconds 1
$wshshell.sendkeys($keys)

# Open MicronStart and wait for input
cd C:\MPW\MicronStart
Start-process ./mStart.exe -Wait
Write-Host "Going on..."