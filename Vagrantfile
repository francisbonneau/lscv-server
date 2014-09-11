# -*- mode: ruby -* -
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.define :pfe do |pfe| 

    pfe.vm.hostname = "pfe"
    pfe.vm.box = "ubuntu-1310-x64"
    pfe.vm.box_url = "http://puppet-vagrant-boxes.puppetlabs.com/ubuntu-1310-x64-virtualbox-puppet.box"

    # Redis
    pfe.vm.network :forwarded_port, host: 6379, guest: 6379

#    pfe.vm.network "public_network"

    # Virtualbox specific settings
    pfe.vm.provider :virtualbox do |vb|
      vb.name = "pfe"
      vb.gui = true                                        # Show the virtualbox UI
      vb.customize ["modifyvm", :id, "--memory", "500"]    # 500MB of RAM            
    end

    pfe.vm.provision "shell", path: "setup.sh"
  end

end
