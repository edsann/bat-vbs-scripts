# Convert app config file into XML format 
$xml = [xml] (Get-Content "C:\MPW\MicronConfig\config.exe.config")

# Read value from dbengine and print it on file
$xml.SelectSingleNode('//add[@key="dbEngine"]').Value | Out-File "C:\MPW\temp.txt" -append

# Read value from SqlStr and print it on file
$xml.SelectSingleNode('//add[@key="SqlStr"]').Value | Out-File "C:\MPW\temp.txt" -append
