# Install and register puppet agent in LXC container
# need to run on proxmox server directly
#
# Paramters:
#   [*lxc_id*]            - id of new lxc container
#   [*puppetserver_id*]   - OPTIONAL: id of puppetmaster lxc container if given we will try to clean and sign the new vm
#   [*puppetserver_name*] - OPTIONAL: name of puppetmaster for agent config
#   [*certname*]          - OPTIONAL: certname of new vm if given we will try to clean and sign the new vm
#   [*puppetversion*]     - OPTIONAL: for other versions, default to 7
#
define proxmox_api::lxc::puppetagent (
  ## Default Settings
  Integer[1]                     $lxc_id,
  Optional[Integer[1]]           $puppetserver_id,
  Optional[String[1]]            $puppetserver_name,
  Optional[String[1]]            $certname            , 
  Optional[Integer]              $puppetversion       = 7,
) {
    
  # Get and parse the facts for VMs, Storage, and Nodes.
  $proxmox_qemu     = parsejson($facts['proxmox_qemu'])

  # Generate a list of VMIDS
  $vmids = $proxmox_qemu.map|$hash|{$hash['vmid']}
 
  # Evaluate variables to make sure we're safe to continue.
  # Confirm that the Clone ID is not the same as the New ID.
  if ($lxc_id in $vmids) {

    ## defaults
    Exec {
      path    => ["/usr/bin","/usr/sbin", "/bin"],
    }


    exec { 'apt update':
      command => "pct exec ${lxc_id} -- apt update",
    }

    exec { 'install dependencies':
      command => "pct exec ${lxc_id} -- apt install wget lsb-release -y",
    }

    exec { 'download puppet':
      ## eg: wget -O /tmp/puppet7-release-buster.deb https://apt.puppet.com/puppet7-release-buster.deb 
      command => "pct exec ${lxc_id} -- bash -c 'wget -O /tmp/puppet${puppetversion}-release-`lsb_release -cs`.deb https://apt.puppet.com/puppet${puppetversion}-release-`lsb_release -cs`.deb'",
    }

    exec { 'install puppet':
      command => "pct exec ${lxc_id} -- bash -c 'dpkg -i /tmp/puppet${puppetversion}-release-`lsb_release -cs`.deb'",
    }

    exec { 'apt update 2':
      command => "pct exec ${lxc_id} -- apt update",
    }

    exec { 'apt upgrade':
      command => "pct exec ${lxc_id} -- apt upgrade -y",
    }

    if ($puppetserver_id) and ($certname) {
     
      notify { "The next step maybe failed without warning! It's okay when the other steps running without error ...": } 

      exec { 'ca clean on puppetmaster':
        command => "pct exec ${puppetserver_id} -- /opt/puppetlabs/server/bin/puppetserver ca clean --certname ${certname}",
        returns => [0, 1],
      }
    }

    exec { 'install puppet agent':
      command => "pct exec ${lxc_id} -- apt install puppet-agent -y",
    }

    if $puppetserver_name {
      exec { 'set puppet master':
        command => "pct exec ${lxc_id} -- /opt/puppetlabs/bin/puppet config set server \'${puppetserver_name}\' --section main",
        
      }

      exec { 'run puppet agent':
        command => "pct exec ${lxc_id} -- /opt/puppetlabs/bin/puppet agent -t",
        returns => 1, 
      }
    }

    if $puppetserver_id {
      ## necessary step on puppermaster
      exec { 'sign puppet agent':
        command => "pct exec ${puppetserver_id} -- /opt/puppetlabs/server/bin/puppetserver ca sign --certname ${certname}"
      }

      notify { "The next step can running for a long time! Timout set to 15 minutes ...": }

      exec { 'run puppet agent 2':
        command => "pct exec ${lxc_id} -- /opt/puppetlabs/bin/puppet agent -t",
        timeout  => 900,
        returns => [0, 2],
      }

    }

  }
}
