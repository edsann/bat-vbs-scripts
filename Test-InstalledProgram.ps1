<#
.SYNOPSIS
    It tests if a program is installed.
.DESCRIPTION
    The script reads the Registry Keys containing the list of installed programs.
    Both the 32-bit and the 64-bit lists are read.
    For each record, the DisplayName property is matched with the input string.
    The results, if present, are printed with the DisplayName, DisplayVersion, InstallDate and Version properties.
.PARAMETER NAME
    Name of the program to be searched in the OS.
.EXAMPLE
    PS> Test-InstalledProgram Notepad
    It tests the existence of any installed program with description matching "Notepad" 
#>

function Test-InstalledProgram {
    [CmdletBinding()]
    Param(
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        $Name
    )

    # Programmi a 64 bit
    $app64 = Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" |
    Where-Object { $_.DisplayName -match $Name } | 
    Select-Object DisplayName, DisplayVersion, InstallDate, Version

    # Programmi a 32 bit
    $app32 = Get-ItemProperty -Path "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" | 
    Where-Object { $_.DisplayName -match $Name } | 
    Select-Object DisplayName, DisplayVersion, InstallDate, Version
    
    if ($app32 -or $app64) {
        return $app32, $app64 | Format-Table
    } else {
        Write-Error "Non è stato trovato alcun programma installato con descrizione $Name"
    }
}
