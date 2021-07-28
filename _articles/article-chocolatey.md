## Intro

During my automation journey, I had the chance to start using [Chocolatey](https://chocolatey.org/) as _the_ Windows package manager. Microsoft just started a new open-source project called [winget](https://github.com/microsoft/winget-cli), although it seems a bit in its early days to be already integrated into a production-like environment.

Automating the deployment and configuration of a .NET applications suite requires a lot of manual step. The deployment procedures vary with the new releases and should be versioned into some automation instructions, hence the need to include the install scripts together with the binaries themselves. However, in a complex N-tier architecture made of several IIS-based web applications, Windows services and WPF apps, some additional steps may be needed in order for Chocolatey to fully perform the installation and upgrade. 

Plus, the long-term maintenance of the applications also need the usage of operational tasks, often trivial (such as copying and pasting, repeating the same configuration for multiple instances of the same application, etc.) or just too repetitive to be performed manually.

For both these reasons, we decided to implement an _ad-hoc_ PowerShell module to fully manage our application suite. The PowerShell module should be used by the Chocolatey scripts when installing, upgrading or removing software, _and_ by any operator wanting to perform maintenance tasks on the suite itself.

## Extensions

[Chocolatey extensions](https://docs.chocolatey.org/en-us/features/extensions) are a way to make your customized PowerShell modules available to the Chocolatey scripts. More specifically, Chocolatey installs or upgrades or uninstalls the applications using PowerShell scripts (called `ChocolateyInstall`, `ChocolateyUninstall` and `ChocolateyBeforeModify` - [here](https://docs.chocolatey.org/en-us/create/create-packages#during-which-scenarios-will-my-custom-scripts-be-triggered) a table of various conditions where these scripts are called) that may be extended with additional custom-made public and private functions.

Our scenario is a bit different - the requirement is that the custom functions should be available not only to the Chocolatey scripts, but also to the current user opening a PowerShell session and starting any administration task on the applications... basically anything from retrieving data about the applications suite architecture (such as a list of running Windows services, database instance information, or the value of specific parameters in the configuration) to performing actual operational tasks (running a database backup, executing a query, changing a set of configuration values, upgrading applications, etc.).

## Starting with your PowerShell module

In the following paragraphs we'll assume you already have such a PowerShell module, and we'll see how to embed it into a Chocolatey package to deploy it across multiple destinations. There are multiple helpful guides on the web on how to build a PowerShell module, although I strongly recommend the [Rambling Cookie Monster's post](http://ramblingcookiemonster.github.io/Building-A-PowerShell-Module/) about a proper PowerShell module structure.

Creating an extension is as simple as following the [install instructions](https://docs.chocolatey.org/en-us/create/create-packages#during-which-scenarios-will-my-custom-scripts-be-triggered) on the Chocolatey website: you simply need to put all your module's files and folders, starting from the root folder (which is usually called with the module's name), into a new folder called `extension`. This is what your Chocolatey package folder would look like:

```
your-ps-module
├── extension
│   ├── functions
│   │   ├── public
|   |   |   └── your-public-function.ps1
|   |   └── private
|   |       └── your-private-function.ps1
│   ├── your-ps-module.psd1
|   ├── your-ps-module.psm1
|   ├── ChocolateyInstall.ps1
|   ├── ChocolateyBeforeModify.ps1
|   └── ChocolateyUninstall.ps1
└── your-ps-module.nuspec
```

Where you may recognize:

* the `.psm1` [module script](https://docs.microsoft.com/en-us/powershell/scripting/developer/module/understanding-a-windows-powershell-module?view=powershell-7.1#script-modules) and the `.psd1` [module manifest](https://docs.microsoft.com/en-us/powershell/scripting/developer/module/understanding-a-windows-powershell-module?view=powershell-7.1#module-manifests) file, containing respectively any instructions to be followed during the module import procedure and the module specifications; no PowerShell module is complete without these files. Although it's beyond the scope of this article, a typical PowerShell module script would look like:

```powershell
# Module requirements
#Requires -Version 5.1
#Requires -RunAsAdministrator

# Export public functions
$PublicFunctionsFiles = [System.IO.Path]::Combine($PSScriptRoot, "Functions", "Public", "*.ps1")
Get-ChildItem -Path $PublicFunctionsFiles -Exclude *.tests.ps1, *profile.ps1 | ForEach-Object {
    try {
        . $_.FullName
        Write-Verbose "Exporting public function $($_.FullName)"
    }
    catch {
        Write-Warning "$($_.Exception.Message)"
    }
}

# Export private functions
$PrivateFunctionsFiles = [System.IO.Path]::Combine($PSScriptRoot, "Functions", "Private", "*.ps1")
Get-ChildItem -Path $PrivateFunctionsFiles -Exclude *.tests.ps1, *profile.ps1 | ForEach-Object {
    try {
        . $_.FullName
        Write-Verbose "Exporting private function $($_.FullName)"
    }
    catch {
        Write-Warning "$($_.Exception.Message)"
    }
}
```

* the `functions\` folder, hosting multiple public and private functions, exported in the shell session by the main `.psm1` module script - as stated in the previous point.
* the `Chocolatey*.ps1` scripts, with the install, upgrade and uninstall instructions when using Chocolatey
* the `.nuspec` file, containing the Chocolatey package's specifications such as title, description, author, version, dependencies, etc. Remember that some items in the spec file are mandatory and needs to be filled: you may find a quick guide [here](https://docs.chocolatey.org/en-us/create/create-packages#nuspec). Below my example (notice the `<files>` section):

```xml
<?xml version="1.0" encoding="utf-8"?>
<package xmlns="http://schemas.microsoft.com/packaging/2015/06/nuspec.xsd">
  <metadata>
    <id>your-ps-module.extension</id>
    <version>0.0.1</version>
    <title>your-ps-module</title>
    <authors>You, my friend</authors>
    <copyright>If any!</copyright>
    <summary>Your marvelous PowerShell module</summary>
    <description>A longer description of your marvelous PowerShell module</description>
    <dependencies>
      <dependency id="any-other-dependency" version="the.package.version"/>
    </dependencies>
  </metadata>
  <files>
    <!-- this section controls what actually gets packaged into the Chocolatey package -->
    <file src="extension\**" target="extension" />
  </files>
</package>
```

## Installing the extension

So, if you have a PowerShell module already, you can quickly pack it into a Chocolatey extension, then put it in your package source and install it with Chocolatey like any other package by using:
```powershell
choco install your-ps-module --yes --source your-source
```
Where the `--yes` options skips any question prompted to the user during the installation, and `--source` overrides the default source (i.e. the [Chocolatey Community Repository](https://community.chocolatey.org/)) - unless you want to publish in it.

What's the purpose of installing an extension? As we said before, the extension _extends_ the functions that are natively available in Chocolatey, by making available to the Chocolatey CLI the functions in _your_ new module.

As said in the Chocolatey documentation,

> _Extensions allow you to package up PowerShell functions that you may reuse across packages as a package that other packages can use and depend on. This allows you to use those same functions as if they were part of Chocolatey itself. Chocolatey loads these PowerShell modules up as part of the regular module import load that it does for built-in PowerShell modules._

## Making it available to the current PS session

So far, the PowerShell module we developed will only be available as a Chocolatey extension. What if we want to distribute it to any admin user who would like to take advantage of the custom PowerShell functions?

We can force this sort of behavior during the extension's installation.

As described in Microsoft Docs' [official documentation about installing PowerShell modules](https://docs.microsoft.com/en-us/powershell/scripting/developer/module/installing-a-powershell-module?view=powershell-7.1), you just need to add the module in all the paths specified by the `$Env:PSModulePath` environment variable.

**Warning:** not all these paths are directly usable, and sometimes they _shouldn't_ be available for installing new modules. In the following example we'll only use the Program Files location (`$Env:ProgramFiles\WindowsPowershell\Modules\`), to make the module available to all user accounts on the computer.

From the `ChocolateyInstall.ps1` script's point of view, the `extension` folder is reachable with:
```powershell
$extensionDir = Split-Path $MyInvocation.MyCommand.Definition
```
Therefore, we'll proceed with copying all the files in the module root folder (except for the Chocolatey scripts) with:
```powershell
# ModuleName
$moduleName = 'your-ps-module'

# Source and destination variables
$destination = "$Env:ProgramFiles\WindowsPowerShell\Modules\$moduleName\"
$ExcludeFiles = $(Get-item "$extensionDir\*Chocolatey*.ps1").Name
$source = "$extensionDir\*"

# Copy-Item results differ depending on if destination exists or not, therefore we're creating it if non-existent
if (-not (Test-Path $destination)) { mkdir $destination | Out-Null }
Get-item $source | 
    Where-Object {$_.Name -notin $ExcludeFiles} | 
    Foreach-Object { Copy-Item $_ -Destination $destination -Force -Recurse }
```
Then, we'll need to import the module itself in the open shell session, so that we'll be able to immediately use it:
```powershell
# Import module in current shell session
Import-Module your-ps-module
```
And finally, we want to make it available to any following session, by automatically adding it to the current user's PowerShell `$profile`:
```powershell
# Create $profile file if it doesn't exist
if (!(Test-Path $profile)) { New-Item $profile -ItemType File}

# Add automatic Import-module to the $profile
if (!(Get-Content -Path $profile -Filter "your-ps-module")) {
    Write-Verbose "Adding automatic Import-Module in PowerShell profile file."
    Add-Content -Value "Import-Module your-ps-module" -Path $Profile
}
```
The other users of the computer may run the same script, or add the `Import-module your-ps-module` manually in their `$profile` file, in order to have it available when opening any new PowerShell session.

## Using the PS module
### ...in Chocolatey
To recall your custom functions during the install, upgrade or uninstall procedure of other Chocolatey packages, you may just add the extension among your package dependencies. Open the spec file of the package whose `ChocolateyInstall.ps1` is going to use those function, and paste in the `<dependencies>` section:
```xml
    <dependency id="your-ps-module.extension" version="your.extension.version"/>
```

Installing our package will then return the following output:

```powershell
PS C:\> $source = "Path/to/source"
PS C:\> choco install your-package --source $source --yes
Chocolatey v0.10.16-beta
2 validations performed. 1 success(es), 1 warning(s), and 0 error(s).

Validation Warnings:
 - A pending system reboot request has been detected, however, this is
   being ignored due to the current Chocolatey configuration.  If you
   want to halt when this occurs, then either set the global feature
   using:
     choco feature enable -name=exitOnRebootDetected
   or pass the option --exit-when-reboot-detected.

Installing the following packages:
your-package
By installing you accept licenses for the packages.

your-ps-module.extension v0.0.1
your-ps-module.extension package files install completed. Performing other installation steps.
Installing module your-ps-module to C:\Program Files\WindowsPowerShell\Modules ...
The PowerShell module your-ps-module was successfully installed!
 Installed/updated your-ps-module extensions.
 The install of your-ps-module.extension was successful.
  Software installed to 'C:\ProgramData\chocolatey\extensions\your-ps-module'

your-package v0.0.1
your-package package files install completed. Performing other installation steps.
...
```
As you may see, according to the Chocolatey's logic, the dependencies (i.e. the your-ps-module extension) are installed before proceeding with the installation of the Chocolatey package.

### ...in a shell session
Once your package is installed, to call your custom functions when operating on your application suite, just invoke them on any shell (we automatically imported the `your-ps-module` by using the `$profile` file: otherwise, just type `Import-module your-ps-module`). 

For instance, you may want to know the list of all the functions included in the module and available to your current session:

```powershell
Get-Command -Module your-ps-module
```
