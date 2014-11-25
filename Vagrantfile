#
# LSCV (Linux System Call Visualization) project
# Francis Bonneau, autumn 2014
# Created for the course GTI792 at l'ÉTS (http://etsmtl.ca/)
#
# Vagrant configuration file to setup a Ubuntu 13.10 VM 
#

Vagrant.configure("2") do |config|

  config.vm.define :lscv do |lscv| 

    lscv.vm.hostname = "lscv"
    lscv.vm.box = "ubuntu-1310-x64"
    lscv.vm.box_url = "http://puppet-vagrant-boxes.puppetlabs.com/ubuntu-1310-x64-virtualbox-puppet.box"

    # Redis
    lscv.vm.network :forwarded_port, host: 6379, guest: 6379

    # lscv.vm.network "public_network"

    # Virtualbox specific settings
    lscv.vm.provider :virtualbox do |vb|
      vb.name = "lscv"

      # Show the virtualbox UI
      vb.gui = true                                        

      # 500MB of RAM
      vb.customize ["modifyvm", :id, "--memory", "500"]

    end

    lscv.vm.provision "shell", path: "vagrant/vagrant_setup.sh"
  end

end
