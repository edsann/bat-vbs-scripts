# Send an email via PowerShell

# Create credentials
$SmtpUsername = "USERNAME"
$SmtpPassword = ConvertTo-SecureString -String "PASSWORD" -AsPlainText -Force
$SmtpCredentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $SmtpUsername,$SmtpPassword

$Argumentss = @{
  To = "recipient@recipient.com" # Insert recipient here
  From = "sender@sender.com" # Insert sender here
  CC = "copy@copy.it" # Insert CC addresses here
  Subject = "test subject" # Insert subject here
  Body = "test body" # Insert body here
  Credential = $SmtpCredentials
  SmtpServer = "SMTPSERVER"  # Insert SMTP server here
}

Send-MailMessage $Arguments
