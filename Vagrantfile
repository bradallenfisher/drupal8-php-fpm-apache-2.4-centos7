# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # centos 6.5
  config.vm.box = "bradallenfisher/centos7"
  
  # ip address
  config.vm.network "private_network", ip: "192.168.8.8"
  
  # host name
  config.vm.hostname = "drupal8.phpfpm.dev"
  
  # virtual box name
  config.vm.provider "virtualbox" do |v|
    v.name = "drupal8"
    v.memory = 4096
    v.cpus = 2
  end

  # run script as root
  config.vm.provision "shell",
    path: "install/root.sh"
    
  # run script as vagrant user
  config.vm.provision "shell",
    path: "install/post-install.sh",
    privileged: FALSE

end
