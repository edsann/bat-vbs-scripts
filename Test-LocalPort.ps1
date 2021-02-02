<#
.SYNOPSIS
	La funzione testa l'apertura delle porte TCP/UDP.
.DESCRIPTION
	La funzione restituisce un oggetto contenente il computer, il risultato, il protocollo e il numero di porta.
	Per ogni combinazione computer-porta-protocollo, restituisce il risultato del test di connettività.
	Ogni connessione si basa su un timeout che è modificabile tramite parametro.
.PARAMETER Computername
	Hostname di computer remoti, il valore di default è 'localhost'.
.PARAMETER Port
	Porte da testare, TCP o UDP, separate da virgola.
.PARAMETER Protocol
	Protocollo su cui testare le porte: solo i valori TCP e UDP sono ammessi.
.PARAMETER TcpTimeout
	Timeout in millisecondi dopo il quale la funzione dichiarerà chiusa la porta TCP.
.PARAMETER UdpTimeout
	Timeout in millisecondi dopo il quale la funzione dichiarerà chiusa la porta UDP.
.EXAMPLE
	PS> Test-Port -Computername 'LABDC','LABDC2' -Protocol TCP 80,443
	Testa le porte TCP 80 e 443 sui server remoti LABDC e LABDC2
.NOTES

	Known Issue: If this function is called within 10-20 consecutively on the same port
	and computer, the UDP port check will output $false when it can be
	$true.  I haven't figured out why it does this.
	
    https://adamtheautomator.com/one-server-port-testing-tool/
#>

function Test-LocalPort {

	[CmdletBinding(DefaultParameterSetName = 'TCP')]
	[OutputType([System.Management.Automation.PSCustomObject])]
	param (
		[string[]]$ComputerName = 'localhost',
		[Parameter(Mandatory)]
		[int[]]$Port,
		[ValidateSet('TCP', 'UDP')]
		[string]$Protocol = 'TCP',
		[Parameter(ParameterSetName = 'TCP')]
		[int]$TcpTimeout = 2000,
		[Parameter(ParameterSetName = 'UDP')]
		[int]$UdpTimeout = 2000
	)
	process {
		foreach ($Computer in $ComputerName) {
			foreach ($Portx in $Port) {

				# Inizializza risultato
				$Output = @{ 'Computername' = $Computer; 'Port' = $Portx; 'Protocol' = $Protocol; 'Result' = '' }
				Write-Verbose "$($MyInvocation.MyCommand.Name) - Beginning port test on '$Computer' on port '$Protocol<code>:$Portx'"

				# Protocollo TCP
				if ($Protocol -eq 'TCP') {

					# Inizializza oggetto Socket.TcpClient
					$TcpClient = New-Object System.Net.Sockets.TcpClient
					$Connect = $TcpClient.BeginConnect($Computer, $Portx, $null, $null)
					$Wait = $Connect.AsyncWaitHandle.WaitOne($TcpTimeout, $false)

					# Result
					if (!$Wait) {
						
						# Chiudi connessione
						$TcpClient.Close()
						Write-Verbose "$($MyInvocation.MyCommand.Name) - '$Computer' failed port test on port '$Protocol</code>:$Portx'"

						# Salva risultato
						$Output.Result = $false
					}
					else {
						# Chiudi connessione
						$TcpClient.EndConnect($Connect)
						$TcpClient.Close()
						Write-Verbose "$($MyInvocation.MyCommand.Name) - '$Computer' passed port test on port '$Protocol<code>:$Portx'"

						# Salva risultato
						$Output.Result = $true
					}

					# Close connection
					$TcpClient.Close()
					$TcpClient.Dispose()
				}
				elseif ($Protocol -eq 'UDP') {

					# Inizializza oggetto Socket.UdpClient
					$UdpClient = New-Object System.Net.Sockets.UdpClient
					$UdpClient.Client.ReceiveTimeout = $UdpTimeout
					$UdpClient.Connect($Computer, $Portx)
					Write-Verbose "$($MyInvocation.MyCommand.Name) - Sending UDP message to computer '$Computer' on port '$Portx'"

					$a = new-object system.text.asciiencoding
					$byte = $a.GetBytes("$(Get-Date)")
					[void]$UdpClient.Send($byte, $byte.length)
					#IPEndPoint object will allow us to read datagrams sent from any source.
					Write-Verbose "$($MyInvocation.MyCommand.Name) - Creating remote endpoint"
					$remoteendpoint = New-Object system.net.ipendpoint([system.net.ipaddress]::Any, 0)
					try {

						#Blocks until a message returns on this socket from a remote host.
						Write-Verbose "$($MyInvocation.MyCommand.Name) - Waiting for message return"
						$receivebytes = $UdpClient.Receive([ref]$remoteendpoint)
						[string]$returndata = $a.GetString($receivebytes)
						If ($returndata) {
							Write-Verbose "$($MyInvocation.MyCommand.Name) - '$Computer' passed port test on port '$Protocol</code>:$Portx'"
							$Output.Result = $true
						}
					}
					catch {
						Write-Verbose "$($MyInvocation.MyCommand.Name) - '$Computer' failed port test on port '$Protocol`:$Portx' with error '$($_.Exception.Message)'"
						$Output.Result = $false
					}
					$UdpClient.Close()
					$UdpClient.Dispose()
				}

				# Add result to custom object
				[pscustomobject]$Output
			}
		}
	}
}