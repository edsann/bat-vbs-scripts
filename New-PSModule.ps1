# Create a new PSmodule template
# Root folder in C:\
function New-PSModule {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$ModuleName,
        [Parameter(Mandatory = $true)]
        [string]$Description
    )

    # We cloned our project to C:\
    $Path = "C:\$ModuleName"
    $Author = 'Edoardo Sanna'

    # Create the module and private function directories
    mkdir $Path\$ModuleName
    mkdir $Path\$ModuleName\Private
    mkdir $Path\$ModuleName\Public
    mkdir $Path\$ModuleName\en-US # For about_Help files
    mkdir $Path\Tests

    # Create the module and related files
    New-Item "$Path\$ModuleName\$ModuleName.psm1" -ItemType File
    New-Item "$Path\$ModuleName\$ModuleName.Format.ps1xml" -ItemType File
    New-Item "$Path\$ModuleName\en-US\about_$ModuleName.help.txt" -ItemType File
    New-Item "$Path\Tests\$ModuleName.Tests.ps1" -ItemType File
    New-ModuleManifest -Path $Path\$ModuleName\$ModuleName.psd1 `
        -RootModule $ModuleName.psm1 `
        -Description $Description `
        -PowerShellVersion 5.1 `
        -Author $Author `
        -FormatsToProcess "$ModuleName.Format.ps1xml"

}

