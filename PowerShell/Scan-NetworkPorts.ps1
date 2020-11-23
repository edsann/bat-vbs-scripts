0..65535 | 
Foreach-Object { Test-NetConnection -Port $_ scanme.nmap.org -WA SilentlyContinue | 
Format-Table -Property ComputerName,RemoteAddress,RemotePort,TcpTestSucceeded }
