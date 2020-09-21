@ECHO OFF

REM ---------- Parametri log ----------------------

REM SET LOG = YOUR/LOG/FILE/PATH
REM DATE /T >> %LOG%
REM TIME /T >> %LOG%
REM ECHO. INIZIO PROCESSO DI BACKUP

REM ---------- Copia Notes in OneDrive ----------------------

SET LocalOneDrive = YOUR/LOCAL/ONEDRIVE/PATH
SET Notes = YOUR/LOCAL/NOTES/PATH
SET RenameFilePath = /YOUR/LOCAL/RENAMEFILEEXE/PATH
cd Notes
copy appunti.txt LocalOneDrive
REM ECHO. File appunti copiato in Onedrive >> LOG

cd LocalOneDrive
RenameFilePath\renamefile.exe Notes.txt Notes Notes_%%D.txt
REM ECHO. File appunti rinominato con dataora >> LOG

REM ---------- Copia tasks in OneDrive ----------------------

SET TasksPath = YOUR/LOCAL/TASKS/PATH
REM ECHO. TASKS >> YOUR/LOG/FILE/PATH
cd TasksPath
copy Tasks.txt LocalOneDrive
REM ECHO. File tasks copiato in Onedrive >> LOG

cd LocalOneDrive
RenameFilePath\renamefile.exe tasks.txt LocalOneDrive tasks_%%D.txt
REM ECHO. File tasks rinominato con dataora >> LOG

REM ---------- Cancella file vecchi ----------------------

REM Comandi della funzione forfiles
REM p = path
REM s = cerca anche nelle subdirectory del path principale
REM m = file con criteri (mark) specificati
REM d = ultima modifica più vecchia di (giorni)
REM c = esegui il comando
SET percorso = LocalOneDrive
Forfiles /p percorso /s /m *.* /d -10 /c "cmd /c del /q @percorso"
REM ECHO.Rimossi vecchi file >> LOG

ECHO.
ECHO.

exit
