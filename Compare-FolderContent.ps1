# Compare files from two different folders that should have the same files/subfolders structure

$FirstFolder = Get-Childitem "C:\TEMP"
$SecondFolder = Get-Childitem "C:\TEMP2"

Compare-Object -ReferenceObject ($FirstFolder).Name -DifferenceObject ($SecondFolder).Name
