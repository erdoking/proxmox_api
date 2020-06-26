# proxmox_api

This `proxmox_api` module allows you to simply and programatically control the [Proxmox Hypervisor](https://proxmox.com/en/).

#### Table of Contents

1. [Description](#description)
2. [Setup requirements](#setup-requirements)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Limitations - OS compatibility, etc.](#limitations)

## Description

This `proxmox_api` module allows you to perform several functions. Currently, this includes:

1. Create a GenericCloud Cloud-Init enabled image by simply providing some values
1. Clone an existing template VM.

## Setup Requirements

`proxmox_api` requires the [puppetlabs/stdlib v6.3.0](https://forge.puppet.com/puppetlabs/stdlib) library or later to your Puppetfile.

## Usage

Examples for each of the commands are below:

### Create new GenericCloud VM Template

```ruby
    proxmox_api::qemu::create_genericcloud {'Ubuntu2004-Template':
      node              => 'pmx',
          # Proxmox Node to create the VM on
      vm_name           => 'Ubuntu2004-Template',
          # New VM Template Name
      ci_username       => 'ubuntu',
          # Set the Cloud-Init Username
      interface         => 'vmbr0',
          # Set the Proxmox Network adapter to connect the template to
      stor              => 'nvmestor',
          # Set the storage volume for the VM Template
      vmid              =>  9001,
          # Set the ID for the new VM Template
      image_type        => 'img',
          # File type of the URL below
      cloudimage_source => 'https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img',
          # URL of the GenericCloud image
    }
```

### Cloning an existing VM Template

```ruby
    proxmox_api::qemu::clone {'test':
      node             => 'pmx',
          # Proxmox Node to create the VM on
      vm_name          => 'TesterMcTesterson',
          # New VM Name
      clone_id         => 1001,
          # The ID of the VM template
      disk_size        => 20,
          # Size of the new disk in GB
      cpu_cores        => 2,
          # Number of CPU cores
      memory           => 4096,
          # Amount of RAM in MB
      ci_username      => 'root',
          # Set the Cloud-Init Username
      ci_password      => 'password',
          # Set the Cloud-Init Password
      protected        => true,
          # Enable the 'Protected' flag
      ipv4_static      => true,
          # [OPTIONAL] Use Static IP
      ipv4_static_cidr => '192.168.1.20/24',
          # [OPTIONAL] Static IP and Subnet Mask
      ipv4_static_gw   => '192.168.1.1',
          # [OPTIONAL] Gateway Address
    }
```

## Limitations

This is currently being developed and tested against a single [Proxmox 6.2-4](https://pve.proxmox.com/wiki/Roadmap#Proxmox_VE_6.2) node, and is not being actively tested against earlier versions. I cannot promise that things will work as expected if you are running earlier versions of Proxmox.

## Development

If there are features that this does not perform or if there are bugs you are encountering, [please feel free to open an issue](https://github.com/danmanners/proxmox_api/issues).
