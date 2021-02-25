# Restituisce i record dell'Event Viewer compresi tra le due date-ore specificate
#
# Utilizzabile solo su PowerShell <6.0
# Per PowerShell >=6.0, utilizzare:
#   Get-WinEvent -LogName Application,Security | Where { ($_.TimeCreated -ge $Before) -and ($_.TimeCreated -le $After) }

$Logs = @("Application","Security","Setup","System","Forwarded Events")
$Begin = Get-Date -Date "25-02-2021 09:43:00"
$End = Get-Date -Date "25-02-2021 09:46:00"

$Logs | ForEach-Object { $LogName = $_; Get-EventLog -LogName $_ -After $Begin -Before $End } | `
Select-Object -Property @{Name="Log";Expression={$Logname}}, * | `
Sort-Object TimeGenerated -Descending | `
Format-Table # Format-Table per chiarezza, altrimenti Format-List per dettaglio