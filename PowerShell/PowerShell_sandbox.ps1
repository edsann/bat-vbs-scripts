# Get the list of all services (format-table is the default format)
Get-Service
Get-Service | format-list
# List the services, sorting by property 'status'
Get-Service | sort-object -property status | format-table
# List all properties and methods of Get-Service
Get-Service | Get-Member
# List the services in the Grid View
Get-Service | out-gridview
# List services from two machines
Get-Service -ComputerName APPSERVER, DBSERVER | format-table machinename, name, status

# List services and print them in txt file
Get-Service -Name "btService*" | out-file C:\services.txt
# List services and print them in CSV file
Get-Service | export-csv C:\services.csv -Delimiter ';'
# List all stopped services
Get-Service | where-Object {$_.status -eq "Stopped"} 

# Run, stop, pause services
Start-Service -Name "btService*"
Stop-Service -Name "btService*"		# equivalent to set-service -name "btService*" -status Stopped
Restart-Service -Name "btService*"

#	es. get-service -displayname "*shrew*" | start-service

# Set automatic startup
Set-Service -Name "btService*" -StartupType Automatic
# Set automatic restart on failure
& sc.exe failure btService reset= 30 actions= restart/5000

# Very simple function
function add 			# Function name
>> {				
>> $add = [int](2+2)		# Variable
>> write-output "$add"		# Print result
>> }


get-help	# alias: gh
get-command 	# Lists all functions and cmdlets
ise		# Run PowerShell ISE

-whatif		# Risk Mitigation parameter: Run simulation	
	
# es. get-service | stop-service -whatif		# Simulate stopping all the services in the system

-confirm	# Risk Mitigation parameter: Ask for confirmation on each command [Y] Yes [A] Yes to all [N] No [L] No to all [S] Suspend

# Current version of PS
# To upgrade, search for latest WMF version for your OS
$PSVersionTable		# Prints all of it
$PSVersion.PSVersion	# Prints the detailed first item
# Windows PowerShell is installed in C:\Windows\System32\WindowsPowerShell


# List all the modules available but not loaded in PoSH
Get-Module -ListAvailable 
# Check execution policy for foreign scripts (Restricted, Allsigned, RemoteSigned, Unrestricted)
Get-ExecutionPolicy
Set-ExecutionPolicy unrestricted 	# Watch out dude!
# Import module
Import-Module -name applocker
# List installed module filtering by name
Get-command -module applocker

# List Windows Feature (Windows server only)
Get-WindowsFeature 
# Install IIS
Get-WindowsFeature -Name Web-Server | Install-WindowsFeature

# Retrieve content from the Internet (similar to wget in Linux)
Invoke-WebRequest -Uri [ADDRESS] -Outfile .\PSCore.msi


# Install PowerShell Core
# If .NET Core SDK already installed:
dotnet tool install --global PowerShell

# PowerShell Core is installed in C:\Program Files\PowerShell
# Run PowerShell Core: cmd prompt > pwsh



# Get the list of all services (format-table is the default format)
Get-Service
Get-Service | format-list
# List the services, sorting by property 'status'
Get-Service | sort-object -property status | format-table
# List all properties and methods of Get-Service
Get-Service | Get-Member
# List the services in the Grid View
Get-Service | out-gridview
# List services from two machines
Get-Service -ComputerName APPSERVER, DBSERVER | format-table machinename, name, status

# List services and print them in txt file
Get-Service -Name "btService*" | out-file C:\services.txt
# List services and print them in CSV file
Get-Service | export-csv C:\services.csv -Delimiter ';'
# List all stopped services
Get-Service | where-Object {$_.status -eq "Stopped"} 

# Run, stop, pause services
Start-Service -Name "btService*"
Stop-Service -Name "btService*"		# equivalent to set-service -name "btService*" -status Stopped
Restart-Service -Name "btService*"

#	es. get-service -displayname "*shrew*" | start-service

# Set automatic startup
Set-Service -Name "btService*" -StartupType Automatic
# Set automatic restart on failure
& sc.exe failure btService reset= 30 actions= restart/5000

# Very simple function
function add 			# Function name
>> {				
>> $add = [int](2+2)		# Variable
>> write-output "$add"		# Print result
>> }


get-help	# alias: gh
get-command 	# Lists all functions and cmdlets
ise		# Run PowerShell ISE

-whatif		# Risk Mitigation parameter: Run simulation	
	
# es. get-service | stop-service -whatif		# Simulate stopping all the services in the system

-confirm	# Risk Mitigation parameter: Ask for confirmation on each command [Y] Yes [A] Yes to all [N] No [L] No to all [S] Suspend

# Create a scheduled task from PowerShell
# This opens and runs PowerShell to execute it
$RunScript = New-ScheduledTaskAction -Execute PowerShell.exe -Argument /PATH/TO/SCRIPT.ps1
$Monday800am = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Monday -At 8:00am
Register-ScheduledTask -Action $RunScript -Trigger $Monday800am -TaskName "TaskName"


# Create a scheduled background job from PowerShell
# Contrary to tasks, jobs are more PowerShell-specific
$TuesdayLunch = New-JobTrigger -Weekly -DaysOfWeek Tuesday -At 12:30pm
$NoNet = New-ScheduledJobOption -RequireNetwork
# Prompts for password of the USER provided
Register-ScheduledJob -Name UpdateHelp -Trigger $TuesdayLunch -ScheduledJobOption $NoNet -ScriptBlock {Update-Help} -Credential DOMAIN\USERNAME
# This job is saved in the Task Scheduler in Task Scheduler Library > Microsoft > Windows > PowerShell > Scheduled Job
