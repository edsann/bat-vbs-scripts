<#
.SYNOPSIS
    It's a very simple equivalent of performing multiple ping commands at once.
.DESCRIPTION
    The script calls the Test-Connection function from the NetTCPIP Powershell module.
    A foreach function loops all the IP addresses provided in the input array.
    The output is the destination address, the corresponding latency and the status of the connection.
    The whole function is within a while loop that goes on forever: stop with [Ctrl]+[C].  
.PARAMETER IPLIST
    List of IPv4 addresses to reach. The addresses must be double quoted ("127.0.0.1") and separated by comma.
.EXAMPLE
    PS> Test-ParallelPing "192.168.1.1", "192.168.10.1", "127.0.0.1"
.NOTES
    Only available on Powershell Core, since it's using Test-Connection instead of Test-NetConnection.
#>

function Test-ParallelPing {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, 
        HelpMessage="Type all your IPv4 addresses with double quotes, separated by comma: ")] 
        [array] $IPList
    )

    while(1) { 
        foreach ( $ip in $IPList ) { 
            $ipnet = $ip -as [NEt.IPAddress]
            Test-Connection $ipnet -Count 1 | Select-Object Destination,Latency,Status
        } 
    }

}

