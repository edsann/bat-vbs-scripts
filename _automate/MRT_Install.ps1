<#
.SYNOPSIS
    Installing MRT App Suite
.NOTES
    Tested on Windows 10 Pro Build 1809

    ..To be tested on Windows Server!
    ..CRNET still missing, install manually
#>

cd C:\MPW_INSTALL
# Create package msi in current dir
./mrt7526.exe /s /x /b"$PWD" /v"/qn"
# Silently install msi (cmd) and create low-error log (run as admin!)
$msiArguments = 
    '/qn', 
    '/i',
    '"Micronpass Application Suite.msi"',
    '/le "C:\MPW_INSTALL\MRT_setup.log"'
$Process = Start-Process -PassThru -Wait msiexec -ArgumentList $msiArguments

# Check if everything has been correctly installed (still WIP)
if ($Process.ExitCode -eq "0") {"Successfully installed"}
if (Test-Path C:\MPW) {"MPW folder exists"}
if (get-service -name btService) {"btService exists"}

# Run MicronStart
./Micronstart/mStart.exe