:: Batch file to export the results of a SQL query on a file
:: 
:: Parameters:
:: SERVER-NAME\INSTANCE-NAME, DATABASE-NAME, USERNAME, PASSWORD (your connection parameters)
:: QUERY (your full query)
:: DESTINATION-FULL-PATH (the full path of the destination file)
::
:: Notes:
:: -h -1 (remove the header)
:: -s "" (no separator)

SQLCMD -S SERVER-NAME\INSTANCE-NAME -d DATABASE-NAME -U USERNAME -P PASSWORD  -h -1 -Q "QUERY" -s "" > "DESTINATION-FULL-PATH" 
