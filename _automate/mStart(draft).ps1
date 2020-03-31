# Open GeneraABL
cd C:\MPW\GeneraAbl\
Start-process ./GeneraAbl.exe 
# Check virtual or physical server
if ($(get-wmiobject win32_computersystem).model -match "virtual,*"){
    $keys = "{TAB}{TAB}{ENTER}"
} else {
    $keys = "{TAB}{ENTER}"
}
$wshshell = New-Object -ComObject WScript.Shell
Start-Sleep -Seconds 1
$wshshell.sendkeys($keys)

# Open MicronStart and wait for input
cd C:\MPW\MicronStart
Start-process ./mStart.exe -Wait
Write-Host "Going on..."