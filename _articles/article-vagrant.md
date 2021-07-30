# Setting up multiple virtual test environments with Vagrant
## Table of contents

## Introduction

## What's Vagrant

## Install and setup Vagrant
https://www.vagrantup.com/downloads
### Installing Vagrant and creating a new project
`vagrant init --minimal`: inizializza un progetto Vagrant nella cartella locale. Documentazione [qui](https://www.vagrantup.com/docs/cli/init).

    Output:
    A `Vagrantfile` has been placed in this directory. You are now
    ready to `vagrant up` your first virtual environment! Please read
    the comments in the Vagrantfile as well as documentation on
    `vagrantup.com` for more information on using Vagrant.

Il vagrantfile minimale contiene questo ([qui](https://www.vagrantup.com/docs/vagrantfile/version) una descrizione di che cosa significa):

```ruby
# Configure
Vagrant.configure("2") do |config|

  # Base box
  config.vm.box = "StefanScherer/windows_2019"
  
end
```
### Il tuo primo Vagrant up
Sostituire "base" per esempio con con "StefanScherer/windows_2019" (dettagli su versione e provider su https://app.vagrantup.com/StefanScherer/boxes/windows_2019) per avere una versione trial da 180d di Windows Server 2019 Standard.

```powershell
vagrant up
```

L'output è 
```cmd
Bringing machine 'default' up with 'virtualbox' provider...
==> default: Importing base box 'StefanScherer/windows_2019'...
==> default: Matching MAC address for NAT networking...
==> default: Setting the name of the VM: vagrant-test_default_1627647952586_17118
==> default: Clearing any previously set network interfaces...
==> default: Preparing network interfaces based on configuration...
    default: Adapter 1: nat
==> default: Forwarding ports...
    default: 22 (guest) => 2222 (host) (adapter 1)
==> default: Booting VM...
==> default: Waiting for machine to boot. This may take a few minutes...
    default: SSH address: 127.0.0.1:2222
    default: SSH username: vagrant
    default: SSH auth method: private key
Timed out while waiting for the machine to boot. This means that
Vagrant was unable to communicate with the guest machine within
the configured ("config.vm.boot_timeout" value) time period.
```

In realtà è solo un timeout di Vagrant, ma la VM è correttamente partita in background: è possibile aprire la GUI da Virtualbox.

La VM creata ha determinate proprietà messe come default (porta 22-->2222, ) che si possono 

### Provisioning

https://www.vagrantup.com/docs/provisioning

In the config block,
```ruby
  # Provisioner: shell, inline script
  config.vm.provision "shell", inline: "Write-Host 'Here we go'; pause"
```



### Run the machine
`vagrant up`
`vagrant provision`
## Multi-machine configuration

