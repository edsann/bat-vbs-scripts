# List the colors available in Powershell
[Enum]::GetValues([System.ConsoleColor])

# Change the color from default to DarkRed of a specific property in the console (e.g. strings)
Set-PSReadLineOption -TokenKind String -ForegroundColor White # Windows Powershell
Set-PSReadLineOption -Colors @{ "String" = "White" } 

