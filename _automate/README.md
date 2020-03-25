## Automate

Content:
- `IIS_install.ps1` installs Internet Information Services roles and features: the required features list is provided as input; the script gets the OS infos to run the client- or server-related installation.
- `MRT_install.ps1` installs the Application Suite executable; it extracts the MSI from the EXE and runs it silently; all the default values are used in the installation.
- `IIS_configure.ps1` creates the required application pool and configures it as needed, then moves the web applications inside of it.
- `MPW_Initial_configuration.ps1` reads the connection strings of the application and sets the initial values.

To do:
- Implement less variables and more pipeline
