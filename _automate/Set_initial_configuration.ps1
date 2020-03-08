# MRT 7.50

#Translated XML config
$xml = [xml] (Get-Content "C:\MPW\MicronConfig\config.exe.config")

# Read value from dbengine
$dbengine = $xml.SelectSingleNode('//add[@key="dbEngine"]').Value
$mydbengine = "$("//add[@key='")$($dbengine)$("Str']")"

# Read value from SqlStr and print it on file
$connectionstring = $xml.SelectSingleNode($mydbengine).Value #| Out-File "C:\MPW\temp.txt" -append

# Get Connection String parameters
$datasource = [regex]::Match($connectionstring, 'Data Source=([^;]+)').Groups[1].Value
$initialcatalog = [regex]::Match($connectionstring, 'Initial Catalog=([^;]+)').Groups[1].Value
$userid = [regex]::Match($connectionstring, 'User ID=([^;]+)').Groups[1].Value
$password = [regex]::Match($connectionstring, 'Password=([^;]+)').Groups[1].Value

# Import SQL PowerShell module
Get-Command -Module SQLPS

# Extract SQL Server version
Invoke-Sqlcmd -ServerInstance $datasource -Database $initialcatalog -Query "SELECT @@VERSION"

# Configuration query
$InitialConfigurationQuery = "
    /* Set GDPR flags to default */
    UPDATE T05COMFLAGS SET T05VALORE='1' WHERE T05TIPO='GDPRMODEDIP'
    UPDATE T05COMFLAGS SET T05VALORE='1' WHERE T05TIPO='GDPRMODEEST'
    UPDATE T05COMFLAGS SET T05VALORE='1' WHERE T05TIPO='GDPRMODEVIS'
    UPDATE T05COMFLAGS SET T05VALORE='1' WHERE T05TIPO='GDPRMODEUSR'
    UPDATE T05COMFLAGS SET T05VALORE='ANONYMOUS' WHERE T05TIPO='GDPRANONYMTEXT'
    /* Create utilities internal company */
    INSERT INTO T71COMAZIENDEINTERNE VALUES (N'UTIL',N'_UTILITIES',N'INSTALLATORE',N'20000101000000',N'',N'')
    /* Create reference employee */
    INSERT INTO T26COMDIPENDENTI VALUES (N'00000001',N'_DIP.RIF', N'_DIP.RIF', N'', N'', N'', N'', N'0', N'', N'INSTALLATORE', N'20000101000000', N'', N'', N'', N'', N'20000101', N'', N'0', N'', N'UTIL', N'M', N'', N'1', N'20000101000000', N'99991231235959', N'', N'', N'', N'', N'', N'', N'', N'', N'', N'', N'')
    /* Assign ref.empl. to admin user */
    INSERT INTO T21COMUTENTI (T21DEFDIPRIFEST,T21DEFAZINTEST,T21DEFDIPRIFVIS,T21DEFAZINTVIS) VALUES ('00000001','UTIL','00000001','UTIL')
"

# Apply query
# To extract some results:    
# | ft (format table)
# | Out-GridView (open in GridView)
Invoke-Sqlcmd -ServerInstance $datasource -Database $initialcatalog -Query $InitialConfigurationQuery

#write-output $connectionstring

