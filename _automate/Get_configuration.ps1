#Translated XML config
$xml = [xml] (Get-Content "C:\MPW\MicronConfig\config.exe.config")

# Read value from dbengine
$dbengine = $xml.SelectSingleNode('//add[@key="dbEngine"]').Value
$mydbengine = "$("//add[@key='")$($dbengine)$("Str']")"

# Read value from SqlStr and print it on file
$connectionstring = $xml.SelectSingleNode($mydbengine).Value | Out-File "C:\MPW\temp.txt" -append

# Get Connection String parameters
$datasource = [regex]::Match($connectionstring, 'Data Source=([^;]+)').Groups[1].Value
$initialcatalog = [regex]::Match($connectionstring, 'Initial Catalog=([^;]+)').Groups[1].Value
$userid = [regex]::Match($connectionstring, 'User ID=([^;]+)').Groups[1].Value
$password = [regex]::Match($connectionstring, 'Password=([^;]+)').Groups[1].Value

#write-output $connectionstring

#Connect to SQL Server
#Set General parameters (T05COMFLAGS)
#Create Internal Company utility
#Create fictitious reference employee
#Associate ref.empl. with admin user
