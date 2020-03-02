#Translated XML config
$xml = [xml] (Get-Content "C:\MPW\MicronConfig\config.exe.config")

# Read value from dbengine
$dbengine = $xml.SelectSingleNode('//add[@key="dbEngine"]').Value
$mydbengine = "$("//add[@key='")$($dbengine)$("Str']")"

# Read value from SqlStr and print it on file
$connectionstring = $xml.SelectSingleNode($mydbengine).Value | Out-File "C:\MPW\temp.txt" -append

#write-output $connectionstring
