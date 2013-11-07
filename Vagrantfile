# -*- mode: ruby -*-
# vi: set ft=ruby :

#
# Vagrant file for Minecraft server.
#
Vagrant::Config.run do |config|
  # Every Vagrant virtual environment requires a box to build off of.
  # This server was build using Ubuntu 12.04 LTS, "precise pangolin".
  # Before using this box, you must add it; see the README.md.
  config.vm.box = "puppetlabs-precise"

  # The url from where the 'config.vm.box' box will be fetched if it
  # doesn't already exist on the user's system.
  config.vm.box_url = "http://puppet-vagrant-boxes.puppetlabs.com/ubuntu-server-12042-x64-vbox4210.box"

  # Assign this VM to a host-only network IP.  You can play this Minecraft
  # Server from the host machine as well as any other machines on the same
  # network by specifying the IP address below as the server IP address in
  # the Minecraft client.
  config.vm.network :hostonly, "10.20.30.40"

  # Assign this VM to a bridged network, allowing you to connect directly to a
  # network using the host's network device. This makes the VM appear as another
  # physical device on your network.
  # config.vm.network :bridged

  # Forward a port from the guest to the host, which allows for outside
  # computers to access the VM, whereas host only networking does not.
  config.vm.forward_port 25565, 2555

  # Provision Minecraft Server with puppet.
  # See puppet/manifests/minecraft.pp for details.
  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = "puppet/manifests"
    puppet.module_path = "puppet/modules"
    puppet.manifest_file  = "minecraft.pp"
    puppet.facter = {
      "vagrant" => "1"
    }
  end
end
