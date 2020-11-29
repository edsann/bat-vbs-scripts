# It checks if a Powershell module is already available; if not, it downloads and installs it
# Only on Powershell 7.x

(Get-Module -listavailable MODULENAME) ?? (Install-Module MODULENAME)
