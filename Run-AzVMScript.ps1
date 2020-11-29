# It runs a Powershell script on the VM called 'testvm' belonging to resource group 'testresourcegroup'

az vm run-command invoke --command-id RunPowerShellScript -n testvm -g testresourcegroup --scripts $script
