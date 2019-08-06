REM Automatically recycle an application pool on IIS

@echo off

echo Application pools:
echo.
C:\Windows\System32\inetsrv\appcmd.exe list apppool
echo.
echo Pool name:
set /p App=
echo.
echo Stopping... ...
C:\Windows\System32\inetsrv\appcmd stop apppool /apppool.name:%App%
echo.
echo Starting... ...
C:\Windows\System32\inetsrv\appcmd start apppool /apppool.name:%App%
echo.
pause
