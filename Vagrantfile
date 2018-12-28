Vagrant.configure("2") do |config|
   config.vm.box = "fedora/28-cloud-base"
   config.vm.network "forwarded_port", guest: 443, host: 8443
   config.vm.provider "libvirt" do |vb|
     vb.random :model => 'random'
     vb.memory = "2048"
     vb.cpus = "2"
   end
   config.vm.provision "ansible_local" do |ansible|
       ansible.galaxy_role_file = 'requirements.yml'
       ansible.playbook = "playbook.yml"
  end
end
