# https://stackoverflow.com/questions/28481811/how-to-correctly-check-if-a-process-is-running-and-stop-it

function Stop-ProcessGracefully {
    param (
        [string]$ProcessName
    )

    $Process = Get-Process $ProcessName -ErrorAction SilentlyContinue
    if ($Process) {
        # try gracefully first
        $Process.CloseMainWindow()
        # kill after five seconds
        Start-Sleep -Seconds 5
        if (!$Process.HasExited) {
            $Process | Stop-Process -Force
        }
    }
    Remove-Variable firefox

}