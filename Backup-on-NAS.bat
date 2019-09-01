:: Backup-on-NAS.bat
:: Automatic task to copy db .bak files on NAS
:: Run with the same user as in the 'net use'


:: Mapping of the shared resource SHARE-NAME (DOMAIN\USERNAME and PASSWORD for connection)
net use \\SHARE-NAME PASSWORD /USER:DOMAIN\USERNAME 

:: Log file
set logfile=\\SHARE-NAME\Backup-on-NAS_log.txt

:: Timestamp starting point
ECHO Start task %Date% %Time% >> %logfile%

:: Copy with automatic overwriting (/Y) of all folders and subfolders (/S)
xcopy /Y/S C:\SOURCE-BACKUP-FOLDER\*.bak \\SHARE-NAME\BACKUP-FOLDER\

:: Timestamp ending point
ECHO Task succeeded %Date% %Time% >> %logfile%

:: Blank line
ECHO. >> %logfile%
