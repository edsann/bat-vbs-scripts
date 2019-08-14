# Sending an e-mail when connection to SQL Server is lost

Try
{
    # Cycling test connection to SQL Server
    While(1 -eq 1)
    {
        # SQLcmd command connecting to Server Instance
        # Insert full instance name in SERVERNAME\INSTANCENAME
        Invoke-Sqlcmd -ServerInstance "SERVERNAME\INSTANCENAME" -Query "DECLARE @ConnectionTest int;"
        
        # Wait 5 seconds
        sleep 5
    }
}
Catch
{
    # Sending an email
    
    # Fill with SMTP Parameters
    $smtpServer = “SMTPSERVER”
    $smtpFrom = “SENDERADDRESS@DOMAIN.COM”
    $smtpTo = “RECIPIENTADDRESS@DOMAIN.COM”
    $smtpSubject = “SUBJECT”
    $username = “CONNECTIONUSERNAME”
    $password = “CONNECTIONPASSWORD”
    $body = “BODY”
    
    # Connect to $smtpserver
    $smtp = New-Object -TypeName “Net.Mail.SmtpClient” -ArgumentList $smtpServer
    
    # Use network credentials
    $smtp.Credentials = New-Object system.net.networkcredential($username, $Password);
    
    # Compose the body with Get-Date and $body
    $smtpBody = “[$(Get-Date -Format HH:mm:ss)] $body”

    # Send the email
    $smtp.Send($smtpFrom, $smtpTo, $smtpSubject, $smtpBody)
} 
 
