# Source: https://adamtheautomator.com/building-progress-bar-powershell-scripts/

function Write-ProgressHelper {
	param (
	    [int]$StepNumber,
	    [string]$Message
	)

	Write-Progress -Activity 'Title' -Status $Message -PercentComplete (($StepNumber / $steps) * 100)
}

$script:steps = ([System.Management.Automation.PsParser]::Tokenize((gc "$PSScriptRoot\$($MyInvocation.MyCommand.Name)"), [ref]$null) | where { $_.Type -eq 'Command' -and $_.Content -eq 'Write-ProgressHelper' }).Count

$stepCounter = 0

Write-ProgressHelper -Message 'Doing something' -StepNumber ($stepCounter++)
Start-Sleep -Seconds 5

## Some process here

Write-ProgressHelper -Message 'Doing something2' -StepNumber ($stepCounter++)

Start-Sleep -Seconds 5

## Some process here

Write-ProgressHelper -Message 'Doing something3' -StepNumber ($stepCounter++)

Start-Sleep -Seconds 5

## Some process here
