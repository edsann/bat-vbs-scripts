'VBScript Example
Set WshShell = WScript.CreateObject("WScript.Shell")

'Run executable
WshShell.Run "%windir%\notepad.exe"

'Activate running program
'Syntax: objShell.AppActivate strApplicationTitle
'The AppActivate method tries to activate an application whose title is the nearest match to strApplicationTitle.
WshShell.AppActivate "Notepad"

'Sleep for 1 sec
Wscript.Sleep 1000

'Sendkeys
WshShell.SendKeys "Hello World!"
WshShell.SendKeys "{ENTER}"
WshShell.SendKeys "abc"
WshShell.SendKeys "{CAPSLOCK}"
WshShell.SendKeys "def"
