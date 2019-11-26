Vagrant.configure("2") do |config|
   config.vm.box = "fedora/31-cloud-base"
   # Make sure that the static IP does not collide with any other machines on the same network.
   config.vm.network "private_network", ip: "192.168.50.4"
   config.vm.network "forwarded_port", guest: 443, host: 8443
   # Should you wish to mount a local development folder, uncomment and edit the below
   # config.vm.synced_folder "/home/user/keylime/", "/root/keylime-dev", type: "sshfs"
   config.vm.provider "libvirt" do |vb|
     vb.random :model => 'random'
     vb.memory = "4096"
     vb.cpus = "4"
   end

   config.vm.provision "ansible_local" do |ansible|
       ansible.playbook = "playbook.yml"
  end
end
