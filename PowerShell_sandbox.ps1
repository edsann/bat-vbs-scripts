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


