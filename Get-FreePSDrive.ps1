# It gets the free space from system drive

(Get-PSDrive $Env:SystemDrive.Trim(':')).Free/1GB

