# Create package msi in current dir
& "./mrt7526.exe" /s /x /b"." /v"qn"
# Silently install msi
& "msiexec.exe" /qn /i 'Micronpass Application Suite.msi'

# Check if everything has been correctly installed
