# Write Log and write host
function LogWrite {
    param ([string]$logstring)
    $LogPath = ".\install.log"
    $datetime = Get-Date -format "[dd-MM-yyyy HH:mm:ss]"
    Add-content $LogPath -value "$datetime $logstring "
    Write-Host $logstring
 }