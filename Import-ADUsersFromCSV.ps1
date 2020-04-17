# Extract users from each OU-related CSV file and import them in AD

Import-Module ActiveDirectory

# Create an OU for each CSV file
cd C:\DataFiles
$files = Get-ChildItem -Filter *.csv

foreach ($file in $files) {

    # Get file name without extension
    $OUName = ($file).BaseName
    
    # Create AD OU with OUName.LandonHotel.com, protected from accidental deletion
    New-ADOrganizationalUnit -Name $OUName -Path "DC=LandonHotel,DC=com" -ProtectedFromAccidentalDeletion $True
    $OULocation = "OU=" + $OUName + ",DC=" + $DomainName +",DC=com"

    # Import content from CSV file and create AD user into the corresponding OU
    Import-CSV -Delimiter ',' -Path $file | 
    New-ADUser -Name $_.'Name' -Path $OULocation -GivenName $_."GivenName" -SamAccountName $_."SamAccountName" -ChangePasswordAtLogon $true -Enabled $true -AccountPassword (ConvertTo-SecureString $_."Password" -AsPlainText -force)
}
